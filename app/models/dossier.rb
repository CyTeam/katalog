class Dossier < ActiveRecord::Base
  # Validations
  validates_presence_of :signature, :title
  
  # Scopes
  scope :by_signature, lambda {|value| where("signature LIKE CONCAT(?, '%')", value)}
  scope :by_title, lambda {|value| where("title LIKE CONCAT('%', ?, '%')", value)}
  scope :by_location, lambda {|value| where(:location_id => Location.find_by_code(value))}
  scope :by_kind, lambda {|value| where(:kind => value)}

  # Ordering
  # BUG: Beware of SQL Injection
  scope :order_by, lambda {|value| order("CONCAT(#{value}, IF(type IS NULL, '.a', ''))")}
  
  # Associations
  has_many :numbers, :class_name => 'DossierNumber'
  accepts_nested_attributes_for :numbers
  has_many :containers
    
  # Tags
  acts_as_taggable
  
  # Attributes
  def location=(value)
    if value.is_a?(String)
      write_attribute(:location, Location.find_by_code(value))
    else
      write_attribute(:location, value)
    end
  end
  
  def signature=(value)
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
  
  def document_count
    numbers.sum(:amount)
  end
  
  def find_parent
    TopicDossier.where(:signature => signature).first
  end
  
  # Importer
  def self.truncate_title(value)
    months = "(Jan.|Feb.|März|Apr.|Mai|Jun.|Jul.|Aug.|Sep.|Okt.|Nov.|Dez.)"
    year = "[0-9]{4}"
    date = "([0-9]{1,2}.)?[ ]*((#{months}|#{year})[ ]*){1,2}"
    date_range = "#{date}([ ]*-[ ]*(#{date})?)?"
    
    value.gsub(/[ ]*#{date_range}[ ]*$/, '')
  end
  
  def self.import_filter
    /^[0-9]{2}\.[0-9]\.[0-9]{3}$/
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
    dossier_rows = rows.select{|row| TopicDossier.import_filter.match(row[0]) && row[9].present?}

    new_dossier = true
    title = nil
    dosser = nil
    transaction do
      for row in dossier_rows
      begin
        # Start new dossier if title changed
        old_title = title
        title = Dossier.truncate_title(row[1])
        new_dossier = (old_title != title)
        
        if new_dossier
          dossier = self.create(
            :signature         => row[0],
            :title             => title
          )
        end
        
        # containers
        dossier.containers << Container.import(row, dossier)
        
        # tags and keywords
        dossier.keywords = row[13..15].compact.join(', ').presence
        
        tags = row[13..15].compact.map{|sentence| sentence.split(/[ .();,:-]/)}.flatten.uniq.select{|t| t.present?}
        tags += row[1].split(/[ .();,:-]/).uniq.select{|t| t.present?}
        dossier.tag_list << tags.uniq.compact
        
        # before 1990
        dossier.numbers.create(
          :to     => '1989-12-31',
          :amount => row[16].nil? ? nil : row[16].delete("'").to_i
        )
        # 1990-1993
        dossier.numbers.create(
          :from   => '1990-01-01',
          :to     => '1993-12-31',
          :amount => row[17].nil? ? nil : row[17].delete("'").to_i
        )
        # 1994-
        year = 1994
        for amount in row[18..36]
          dossier.numbers.create(
            :from   => Date.new(year, 1, 1),
            :to     => Date.new(year, 12, 31),
            :amount => amount.nil? ? nil : amount.delete("'").to_i
          )
          year += 1
        end
        
        dossier.save!
      rescue Exception => e
        puts e.message
      end
      end
    end
  end
end
