class Dossier < ActiveRecord::Base
  # Scopes
  default_scope :order => 'signature'
  scope :by_signature, lambda {|value| where(:signature => value)}
  scope :by_location, lambda {|value| where(:location_id => Location.find_by_code(value))}
  scope :by_kind, lambda {|value| where(:kind => value)}

  # Associations
  belongs_to :parent, :class_name => 'Dossier'
  belongs_to :location
  has_many :numbers, :class_name => 'DossierNumber'
  accepts_nested_attributes_for :numbers
    
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
    assign_parent
  end
  
  # Calculations
  def total_amount
    numbers.sum(:amount)
  end
  
  def find_parent
    Topic.where(:signature => signature.split('.')[0]).first
  end
  
  def assign_parent
    self.parent = find_parent
  end
  
  # Importer
  def self.import_from_csv(path)
    # Load file at path using ; as delimiter
    rows = FasterCSV.read(path, :col_sep => ';')
    
    # Select rows containing topics
    topic_group_rows = rows.select{|row| TopicGroup.import_filter.match(row[0])}
    topic_group_rows.map{|row| TopicGroup.import(row).save}
    
    topic_rows = rows.select{|row| Topic.import_filter.match(row[0])}
    topic_rows.map{|row| Topic.import(row).save}

    # Select rows containing main dossier records by simply testing on two columns in first row
    dossier_rows = rows.select{|row| row[0] && row[0].split('.').count == 3}

    transaction do
      for row in dossier_rows
        dossier = self.create(
          :signature => row[0],
          :title     => row[1],
          :kind      => row[9],
          :location  => row[10]
        )

        # tags
        tags = row[13..15].compact.map{|sentence| sentence.split(/[ .();,:-]/)}.flatten.uniq.select{|t| t.present?}
        tags += row[1].split(/[ .();,:-]/).uniq.select{|t| t.present?}
        dossier.tag_list << tags.uniq.compact
        
        # before 1990
        dossier.numbers.create(
          :to     => '1989-12-31',
          :amount => row[16]
        )
        # 1990-1993
        dossier.numbers.create(
          :from   => '1990-01-01',
          :to     => '1993-12-31',
          :amount => row[17]
        )
        # 1994-
        year = 1994
        for amount in row[18..36]
          dossier.numbers.create(
            :from   => Date.new(year, 1, 1),
            :to     => Date.new(year, 12, 31),
            :amount => amount
          )
          year += 1
        end
        
        dossier.save!
      end
    end
  end
end
