class Topic < Dossier
  def topic_type
    return if signature.nil?
    
    case signature.length
      when 1: :group
      when 2: :main
      when 4: :geo
      when 8: :detail
    end
  end
  
  # Associations
  has_many :dossiers, :foreign_key => :parent_id
  
  def children_topic_type
    return if topic_type.nil?
    case topic_type
      when :group  then :main
      when :main   then :geo
      when :geo    then :detail
      when :detail then :dossier
    end
  end

  def children(use_new_signature = false)
    if use_new_signature
      Dossier.where("new_signature LIKE CONCAT(?, '%')", new_signature).where("dossiers.id != ?", id)
    else
      Dossier.where("signature LIKE CONCAT(?, '%')", signature).where("dossiers.id != ?", id)
    end
  end
  
  def direct_children(use_new_signature = false)
    # TODO: support or drop new_signature
    result = children(use_new_signature)
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
  
  # Calculations
  def document_count(use_new_signature = false)
    children(use_new_signature).includes(:numbers).sum(:amount).to_i
  end

  # Importer
  def self.import_filter
    /^[0-9][.0-9]*$/
  end

  def self.import(row)
    self.new.import(row)
  end
  
  def import(row)
    self.signature = row[0]
    self.title     = row[1]
    puts self unless Rails.env.test?

    self
  end
end
