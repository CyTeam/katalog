# This class is a sub class of FormtasticFauxModel.
# It is used to do global search and replace actions.
class SearchReplace < FormtasticFauxModel

  # The attributes of SearchReplace.
  attr_accessor :search, :replace, :columns

  # Validates the presence of all attributes.
  validates_presence_of :search, :replace, :columns

  # Defines the search and replaceable attributes in the Dossier.
  def self.editable_attributes
    ['signature', 'description', 'title', 'keywords', 'relation_list']
  end

  # Definies the attribute types of this model.
  self.types = {
    :search => :string,
    :replace => :string,
    :columns => :string
  }

  # Does the search and replace action.
  def do
    columns.each do |column|
      case column
      when 'keywords'
        ActsAsTaggableOn::Tag.update_all(["name = REPLACE(name, ?, ?)", search, replace], ["name LIKE ?", '%' + search + '%'])
      else
        Dossier.update_all(["#{column} = REPLACE(#{column}, ?, ?)", search, replace], ["#{column} LIKE ?", '%' + search + '%'])
      end if check_column(column)
    end
  end

  private # :nodoc

  def check_column(column)
    return false if column.empty?
    
    SearchReplace.editable_attributes.include?column ? column : nil
  end
end
