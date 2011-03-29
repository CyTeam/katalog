class SearchReplace < FormtasticFauxModel
  
  attr_accessor :search, :replace, :columns
  
  validates_presence_of :search, :replace, :columns
  
  def self.editable_attributes
    [:signature, :description, :title]
  end
  
  self.types = {
    :search => :string,
    :replace => :string,
    :columns => :string
  }
end