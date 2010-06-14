class Topic < Dossier
  # Associations
  has_many :dossiers, :foreign_key => :parent_id
  
  def to_s
    "#{signature}: #{title}"
  end
  
  # Calculations
  def total_amount
    document_count
  end
  
  def document_count
    Dossier.where("signature LIKE CONCAT(?, '%')", signature).includes(:numbers).sum(:amount)
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
