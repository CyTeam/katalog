# This class is a sub class of FormtasticFauxModel.
# It is used to do global search and replace actions.
class SearchReplace < FormtasticFauxModel
  # The attributes of SearchReplace.
  attr_accessor :search, :replace, :columns

  # Validates the presence of all attributes.
  validates_presence_of :search, :replace, :columns

  # Defines the search and replaceable attributes in the Dossier.
  def self.editable_attributes
    %w(signature description title keywords)
  end

  # Defines the attribute types of this model.
  self.types = {
    search: :string,
    replace: :string,
    columns: :string
  }

  # Does the search and replace action.
  def do
    changed_objects = []

    columns.each do |column|
      # Guard
      next unless check_column(column)

      case column
      when 'keywords'
        dossiers = ActsAsTaggableOn::Tag.where('name LIKE ?', '%' + search + '%').joins(:taggings).collect { |tag| tag.taggings.collect(&:taggable) }.flatten.uniq

        # Filter out case insensitive matches
        dossiers = dossiers.select do |dossier|
          dossier.keyword_list.match(search) || dossier.tag_list.match(search)
        end

        dossiers.map do|dossier|
          dossier.keyword_list = dossier.keyword_list.to_s.gsub(search, replace)
          dossier.tag_list = dossier.tag_list.to_s.gsub(search, replace)

          dossier.touch
          dossier.save
          changed_objects << dossier
        end
      else
        dossiers = Dossier.where("`#{column}` LIKE ?", '%' + search + '%')

        # Filter out case insensitive matches
        dossiers = dossiers.select do |dossier|
          dossier[column].match(search)
        end

        dossiers.map do|dossier|
          if dossier[column]
            dossier[column] = dossier[column].gsub(search, replace)

            dossier.touch
            dossier.save
            changed_objects << dossier
          end
        end
      end
    end

    changed_objects
  end

  private # :nodoc

  def check_column(column)
    return false if column.empty?

    SearchReplace.editable_attributes.include? column ? column : nil
  end
end
