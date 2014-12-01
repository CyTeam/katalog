# This class is a sub class of ActAsTaggableOn and provides the information about the dossier keywords.
class Tag < ActsAsTaggableOn::Tag
  # PaperTrail: change log
  has_paper_trail ignore: [:created_at, :updated_at]

  # Scopes
  scope :by_character, lambda { |value| where("name LIKE CONCAT(?, '%')", value) }
  scope :characters, -> { select('DISTINCT substring(upper(name), 1, 1) AS letter').having("letter BETWEEN 'A' AND 'Z'") }
  default_scope -> { joins(:taggings).where('taggings.context' => 'tags') }

  # The list of all characters.
  def self.character_list
    characters.map(&:letter)
  end

  # Dossier scopes
  scope :by_signature, lambda { |value| where("dossiers.signature LIKE CONCAT(?, '%')", value) }

  scope :filter_tags, -> {
    select('tags.*, COUNT(*) AS count').joins('JOIN dossiers ON dossiers.id = taggings.taggable_id').group('tags.id').order('COUNT(*) DESC').limit(36)
  }
end
