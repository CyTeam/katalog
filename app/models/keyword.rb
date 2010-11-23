class Keyword < ActsAsTaggableOn::Tag
  scope :by_character, lambda {|value| where("name LIKE CONCAT(?, '%')", value)}
end
