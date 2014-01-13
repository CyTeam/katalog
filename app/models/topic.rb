# encoding: utf-8

# This class is a subclass of Dossier, which contains many dossiers.
# It's a kind of parent for dossiers with a title and type.
class Topic < Dossier
  # Alphabetic topics
  ALPHABETIC = {
    '15.0' => 'Personen',
    '56.0' => 'Firmen',
    '81.5.000' => 'Länder'
  }

  # Checks if a signature is alphabetic.
  def self.alphabetic?(signature)
    for alphabetic in ALPHABETIC.keys
      return true if signature.starts_with?(alphabetic)
    end

    return false
  end

  # Returns all sub topics alphabetical.
  def self.alphabetic_sub_topics
    ALPHABETIC.collect {|key, value|
      self.by_signature(key).where(["title LIKE ?", "#{value} %"])
    }
  end

  # Returns which type of Topic it is.
  def topic_type
    return if signature.nil?

    case level
      when 1
        :group
      when 2
        :main
      when 3
        :geo
      when 4
        :detail
    end
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

  # Returns the direct children of the current Topic.
  def direct_children
    result = children
    result = result.send(children_topic_type) if children_topic_type

    result
  end

  # Grand total of documents
  def document_count(period = nil)
    topic_numbers = DossierNumber.joins(:dossier).where("signature LIKE CONCAT(?, '%')", signature)
    document_counts = period ? topic_numbers.between(period) : topic_numbers

    document_counts.sum(:amount).to_i
  end
  alias amount document_count

  # Attribute handlers
  def update_signature(value)
    children.each do |child|
      child.signature = child.signature.gsub(/^#{self.signature}/, value)
      child.save
    end

    self.signature = value

    save
  end

  # Title which is constructed from the next childrens
  def overview_title
    "#{self.signature}: " + direct_children.collect {|c| c.title.split(".").first }.join('. ')
  end
end
