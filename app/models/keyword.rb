class Keyword < ActsAsTaggableOn::Tag
  scope :by_character, lambda {|value| where("name LIKE CONCAT(?, '%')", value)}
  scope :characters, select("DISTINCT substring(upper(name), 1, 1) AS letter").having("letter BETWEEN 'A' AND 'Z'")
  default_scope joins(:taggings).where("taggings.context = 'keywords'")

  def self.character_list
    characters.map{|t| t.letter}
  end
end
