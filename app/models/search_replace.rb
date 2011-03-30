class SearchReplace < FormtasticFauxModel
  
  attr_accessor :search, :replace, :columns
  
  validates_presence_of :search, :replace, :columns
  
  def self.editable_attributes
    ['signature', 'description', 'title']
  end
  
  self.types = {
    :search => :string,
    :replace => :string,
    :columns => :string
  }
  
  def do
    columns.each do |column|
      Dossier.update_all(["#{column} = replace(#{column}, ?, ?)", search, replace], ["#{column} LIKE ?", '%' + search + '%']) if check_column(column)
    end
  end

  private
  def check_column(column)
    return false if column.empty?
    
    SearchReplace.editable_attributes.include?column ? column : nil
  end
end