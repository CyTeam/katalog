class SearchReplace < FormtasticFauxModel
  
  attr_accessor :search, :replace, :columns
  
  validates_presence_of :search, :replace, :columns
  
  def self.editable_attributes
    ['signature', 'description', 'title', 'keywords', 'relation_list']
  end
  
  self.types = {
    :search => :string,
    :replace => :string,
    :columns => :string
  }
  
  def do
    columns.each do |column|
      case column
      when 'keywords'
        ActsAsTaggableOn::Tag.update_all(["title = REPLACE(title, ?, ?)", search, replace], ["title LIKE ?", '%' + search + '%'])
      else
        Dossier.update_all(["#{column} = REPLACE(#{column}, ?, ?)", search, replace], ["#{column} LIKE ?", '%' + search + '%'])
      end if check_column(column)
    end
  end

  private
  def check_column(column)
    return false if column.empty?
    
    SearchReplace.editable_attributes.include?column ? column : nil
  end
end