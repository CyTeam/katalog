# encoding: UTF-8

# This class is a sub class of ActAsTaggableOn and provides the information about the dossier keywords.
class Keyword < ActsAsTaggableOn::Tag

  # PaperTrail: change log
  has_paper_trail :ignore => [:created_at, :updated_at]

  # Scopes
  scope :by_character, lambda {|value| where("name LIKE CONCAT(?, '%')", value)}
  scope :characters, select("DISTINCT substring(upper(name), 1, 1) AS letter").having("letter BETWEEN 'A' AND 'Z'")
  default_scope joins(:taggings).where('taggings.context' => 'keywords').order("case when name regexp '^[[:alpha:]]' then 0 when name regexp '^[0-9]' then 1 else 2 end, name").order('name')

  # The list of all characters.
  def self.character_list
    characters.map{|t| t.letter}
  end

  scope :filter_tags,
    select("tags.*, COUNT(*) AS count").joins('JOIN dossiers ON dossiers.id = taggings.taggable_id').having("COUNT(*) >= 2").group("tags.id").order("COUNT(*)").limit(12)
end
