ThinkingSphinx::Index.define :dossier, with: :active_record, delta: true do
  # Sphinx configuration:
  # Free text search
  # Needed for tag/keyword search
  set_property group_concat_max_len: 1_048_576

  # Weights
  set_property field_weights: {
    title: 500,
    parent_title: 5,
    keywords: 10
  }

  # Indexed Fields
  indexes title
  indexes description
  indexes signature

  # Use _taggings relation to fix thinking sphinx issue #167
  indexes keyword_taggings.tag.name, as: :keywords

  # Disabled due to thinking sphinx update
  # indexes direct_parents.title, as: :parent_title

  # Attributes
  has created_at, updated_at
  has "type = 'Topic'", type: :boolean, as: :is_topic
  has type
  has internal
  has "signature LIKE '17%'", type: :boolean, as: :is_local
  has signature, type: :string, as: :signature_sort
  has title
end
