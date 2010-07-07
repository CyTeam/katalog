class Topic < Dossier
  # Associations
  has_many :dossiers, :foreign_key => :parent_id

  def children(use_new_signature = false)
    if use_new_signature
      Dossier.where("new_signature LIKE CONCAT(?, '%')", new_signature)
    else
      Dossier.where("signature LIKE CONCAT(?, '%')", signature)
    end
  end
  
  # Calculations
  def document_count(use_new_signature = false)
    children(use_new_signature).includes(:numbers).sum(:amount)
  end

  def find_parent
    TopicGroup.where(:signature => signature.first).first
  end

  # Importer
  def self.import_filter
    /^[0-9]{2}$/
  end

  def self.import(row)
    self.new.import(row)
  end
  
  def import(row)
    self.signature = row[0]
    self.title     = row[1]
    
    return self
  end
end
