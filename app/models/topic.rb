# encoding: utf-8

# This class is a subclass of Dossier, which contains many dossiers.
# It's a kind of parent for dossiers with a title and type.
class Topic < Dossier
  # Alphabetic topics
  ALPHABETIC = {
    '15.0.100' => 'Personen',
    '56.0.130' => 'Firmen',
    '56.0.500' => 'Öko-ethische Geldanlagen. Ökoinvest-Firmen',
    '81.5.000' => 'Länder'
  }

  # Checks if a signature is alphabetic.
  def self.alphabetic?(signature)
    for alphabetic in ALPHABETIC.keys
      return true if alphabetic.starts_with?(signature)
    end
    
    return false
  end

  # Returns all sub topics alphabetical.
  def self.alphabetic_sub_topics
    ALPHABETIC.collect {|key, value|
      self.by_signature(key).where(["title LIKE ?", "#{value} %"])
    }
  end

  def self.by_range(from_signature, to_signature)
    topics = self.where("signature BETWEEN ? AND ?", clean_signature(from_signature), clean_signature(to_signature))

    clean_parents(topics)
  end

  # Returns which type of Topic it is.
  def topic_type
    return if signature.nil?

    case topic_level
      when 1
        case signature.length
          when 1
            :group
          when 2
            :main
        end
      when 2
        :geo
      when 3
        :detail
    end
  end

  def topic_level
    signature.split('.').length
  end
  
  # Associations
  has_many :dossiers, :foreign_key => :parent_id

  # Returns the topic type of the children.
  def children_topic_type
    return if topic_type.nil?
    case topic_type
      when :group  then :main
      when :main   then :geo
      when :geo    then :detail
      when :detail then :dossier
    end
  end

  # Returns the children of the current topic.
  def children
    Dossier.where("signature LIKE CONCAT(?, '%')", signature).where("dossiers.id != ?", id)
  end
  
  # Grand total of documents
  def document_count(period = nil)
    topic_numbers = DossierNumber.joins(:dossier).where("signature LIKE CONCAT(?, '%')", signature)
    document_counts = period ? topic_numbers.between(period) : topic_numbers

    document_counts.sum(:amount).to_i
  end
  alias amount document_count

  # Returns the direct children of the current Topic.
  def direct_children
    result = children
    result = result.send(children_topic_type) if children_topic_type
    
    result
  end

  # Attribute handlers
  def update_signature(value)
    children.each do |child|
      child.signature = child.signature.gsub(/^#{self.signature}/, value)
      child.save
    end
    
    self.signature = value

    save
  end
  
  # Customized import filter for a Topic.
  def self.import_filter
    /^[0-9][.0-9]*$/
  end

  # Customized row import for a Topic.
  def self.import(row)
    self.new.import(row)
  end

  # Customized row import for the current Topic.
  def import(row)
    self.signature = row[0]
    self.title     = row[1]
    puts self unless Rails.env.test?

    self
  end
end
