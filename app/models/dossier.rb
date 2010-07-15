class Dossier < ActiveRecord::Base
  # Validations
  validates_presence_of :signature, :title
  
  # Scopes
  scope :by_signature, lambda {|value| where("signature LIKE CONCAT(?, '%')", value)}
  scope :by_title, lambda {|value| where("title LIKE CONCAT('%', ?, '%')", value)}
  # TODO: check if arel provides nicer code:
  scope :by_location, lambda {|value| where(:id => Container.where('location_id = ?', Location.find_by_code(value)).map{|c| c.dossier_id}.uniq)}
  scope :by_kind, lambda {|value| where(:id => Container.where('container_type_id = ?', ContainerType.find_by_code(value)).map{|c| c.dossier_id}.uniq)}

  # Ordering
  # BUG: Beware of SQL Injection
  scope :order_by, lambda {|value| order("CONCAT(#{value}, IF(type IS NULL, '.a', ''))")}
  
  # Associations
  has_many :numbers, :class_name => 'DossierNumber', :dependent => :destroy
  accepts_nested_attributes_for :numbers
  has_many :containers, :dependent => :destroy
    
  # Tags
  acts_as_taggable
  acts_as_taggable_on :keywords
  
  # Helpers
  def to_s
    "#{signature}: #{title}"
  end
  
  # Attributes
  def location=(value)
    if value.is_a?(String)
      write_attribute(:location, Location.find_by_code(value))
    else
      write_attribute(:location, value)
    end
  end
  
  def signature=(value)
    value.strip!
    write_attribute(:signature, value)
    
    group = value[0,1]
    topic, geo, dossier = value.split('.')
    new_signature = [topic, dossier, geo].compact.join('.')
    write_attribute(:new_signature, new_signature)
  end
  
  # Calculations
  def first_document_on
    containers.minimum(:first_document_on)
  end
  
  def locations
    containers.collect{|c| c.location}.uniq
  end
  
  def container_types
    containers.collect{|c| c.container_type}.uniq
  end
  
  def document_count
    numbers.sum(:amount)
  end
  
  def find_parent
    TopicDossier.where(:signature => signature).first
  end
  
  # Importer
  def self.filter_tags(values)
    values.reject!{|value| value.match /^[0-9.']*$/}
    values.reject!{|value| value.match /^(Jan|Feb|März|Apr|Mai|Juni|Juli|Aug|Sep|Sept|Okt|Nov|Dez)$/}

    return values
  end
  
  def self.extract_tags(values)
    filter_tags(values.compact.map{|sentence| sentence.split(/[ .();,:-]/)}.flatten.uniq.select{|t| t.present?}).compact
  end
  
  def self.extract_keywords(values)
    value_list = values.join('. ')

    # Build quotation substitutes
    abbrs = ["betr.", "Kt.", "Präs.", "St.", "EXPO.02", "Abst.", "Lib.", "gest.", "ex.", "Hrsg.", "S.o.S", "s.a.", "Dr.", "jur.", "etc.", "ca.", "Schweiz.", "Dir.", "Hist.", "Chr.", "ev.-ref.", "Kand.", "ev.", "ref."]
    quoted_abbrs = {}
    for abbr in abbrs
      quoted_abbrs[abbr] = abbr.gsub('.', '|')
    end
    
    # Quote abbreviations
    quoted_abbrs.each{|abbr, quoted_abbr| value_list.gsub!(abbr, quoted_abbr)}
    
    # Quote dates
    # TODO: Check if this could be done much simpler using gsub and block
    list = value_list
    quoted = ""
    while match = /#{date_range}/.match(list)
      quoted += match.pre_match
      
      date = list.slice(match.begin(0)..match.end(0)-1)
      quoted += date.gsub('.', '|')
      
      list = match.post_match
    end
    value_list = quoted + list
    
    # Quote initials
    value_list.gsub!(/((^|[ ])[A-Z])\./, '\1|')
    
    # Split and unquote
    keywords = value_list.split('.')
    keywords.map!{|keyword| keyword.gsub('|', '.')}
    
    # Cleanup
    keywords.compact!
    keywords.map!{|value| value.strip.presence}

    return keywords
  end

  def self.date_range
    month_abbrs = '(Jan\.|Feb\.|März|Apr\.|Mai|Juni|Juli|Aug\.|Sep\.|Sept\.|Okt\.|Nov\.|Dez\.)'
    month_ordinals = '([1-9]\.|1[0-2]\.)'
    
    year = '[0-9]{4}'
    date = "([0-9]{1,2}\\.)?[ ]*((#{month_abbrs}|#{month_ordinals}|#{year})[ ]*){1,2}"
    date_range = "#{date}([ ]*-[ ]*(#{date})?)?"
    
    return "[ ]*#{date_range}[ ]*"
  end
  
  def self.truncate_title(value)
    
    value.gsub(/ #{date_range}$/, '')
  end
  
  def self.import_filter
    /^[0-9]{2}\.[0-9]\.[0-9]{3}$/
  end
  
  def import_numbers(row)
    # before 1990
    numbers.create(
      :to     => '1989-12-31',
      :amount => row[16].nil? ? nil : row[16].delete("'").to_i
    )
    # 1990-1993
    numbers.create(
      :from   => '1990-01-01',
      :to     => '1993-12-31',
      :amount => row[17].nil? ? nil : row[17].delete("'").to_i
    )
    # 1994-
    year = 1994
    for amount in row[18..36]
      numbers.create(
        :from   => Date.new(year, 1, 1),
        :to     => Date.new(year, 12, 31),
        :amount => amount.nil? ? nil : amount.delete("'").to_i
      )
      year += 1
    end
  end
  
  def import_keywords(row)
    keys = self.class.extract_keywords(row[13..15])
    self.keyword_list.add(keys)
    
    ts = self.class.extract_tags([row[13..15]])
    ts += self.tag_list unless self.tag_list.nil?
    tag_list = ts
  end
  
  def import(row)
    # containers
    containers << Container.import(row, self)
    
    self.related_to = row[12]

    # tags and keywords
    ts = self.class.extract_tags([row[1]])
    self.tag_list = ts
    import_keywords(row)
    
    import_numbers(row)
  end
  
  def self.import_all(rows)
    new_dossier = true
    title = nil
    dossier = nil
    for row in rows
      transaction do
      begin
        # Skip empty rows
        next if row.select{|column| column.present?}.empty?
        
        # Only import keywords if row has no reference
        if row[0].blank? && (row[13].present? || row[14].present? || row[15].present?)
          dossier.import_keywords(row)
          dossier.save!
          next
        end
        
        old_title = title
        title = Dossier.truncate_title(row[1])
        new_dossier = (old_title != title)
        
        if new_dossier
          dossier = self.create(
            :signature         => row[0],
            :title             => title
          )
        end
        
        dossier.import(row)
        
        dossier.save!
      rescue Exception => e
        puts e.message
#        puts e.backtrace
      end
      puts dossier unless Rails.env.test?
      end
    end
  end
  
  def self.import_filter(rows)
    signature_filter = /^[ ]*[0-9]{2}\.[0-9]\.[0-9]{3}[ ]*$/

    rows.select{|row| (signature_filter.match(row[0]) && row[9].present?) || (row[0].blank? && (row[13].present? || row[14].present? || row[15].present?))}
  end
  
  def self.import_from_csv(path)
    # Load file at path using ; as delimiter
    rows = FasterCSV.read(path, :col_sep => ';')
    
    # Select rows containing topics
    topic_group_rows = rows.select{|row| TopicGroup.import_filter.match(row[0])}
    topic_group_rows.map{|row| TopicGroup.import(row).save!}
    
    topic_rows = rows.select{|row| Topic.import_filter.match(row[0])}
    topic_rows.map{|row| Topic.import(row).save!}

    topic_rows = rows.select{|row| TopicGeo.import_filter.match(row[0])}
    topic_rows.map{|row| TopicGeo.import(row).save!}

    topic_rows = rows.select{|row| TopicDossier.import_filter.match(row[0]) && row[9].blank?}
    topic_rows.map{|row| TopicDossier.import(row).save!}

    # Select rows containing main dossier records by simply testing on two columns in first row
    import_all(import_filter(rows))
  end
end
