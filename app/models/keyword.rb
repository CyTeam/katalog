class Keyword < ActsAsTaggableOn::Tag
  scope :by_character, lambda {|value| where("name LIKE CONCAT(?, '%')", value)}
  default_scope includes(:taggings).where("taggings.context = 'keywords'")
end
