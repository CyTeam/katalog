# This class is a sub class of FormtasticFauxModel.
# It is used to do global search and replace actions.
class SearchReplace < FormtasticFauxModel

  # The attributes of SearchReplace.
  attr_accessor :search, :replace, :columns

  # Validates the presence of all attributes.
  validates_presence_of :search, :replace, :columns

  # Defines the search and replaceable attributes in the Dossier.
  def self.editable_attributes
    ['signature', 'description', 'title', 'keywords', 'related_to']
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
      begin
        case column
        when 'keywords'
          model = ActsAsTaggableOn::Tag
          attr = 'name'
        else
          model = Dossier
          attr = column
        end

        items = model.where("`#{attr}` LIKE ?", '%' + search + '%')

        # Trigger housekeeping
        items.update_all(:delta => true, :updated_at => DateTime.now) unless column == 'keywords'

        # Replace
        items.update_all(["`#{attr}` = REPLACE(`#{attr}`, ?, ?)", search, replace])

        # Hack to trigger re-index
        Dossier.first.save
      end if check_column(column)
    end
  end

  private # :nodoc

  def check_column(column)
    return false if column.empty?
    
    SearchReplace.editable_attributes.include?column ? column : nil
  end
end
