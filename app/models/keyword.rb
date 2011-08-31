# This class is a sub class of ActAsTaggableOn and provides the information about the dossier keywords.
class Keyword < ActsAsTaggableOn::Tag

  # PaperTrail: change log
  has_paper_trail :ignore => [:created_at, :updated_at]

  # Scopes
  scope :by_character, lambda {|value| where("name LIKE CONCAT(?, '%')", value)}
  scope :characters, select("DISTINCT substring(upper(name), 1, 1) AS letter").having("letter BETWEEN 'A' AND 'Z'")
  default_scope joins(:taggings).where('taggings.context' => 'keywords')

  # The list of all characters.
  def self.character_list
    characters.map{|t| t.letter}
  end
end
