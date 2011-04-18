# This class holds the specific values for the sphinx word forms config.
class SphinxAdminWordForm < SphinxAdmin

  # The file name for the word forms.
  def self.file_name
    'wordforms.txt'
  end

  # The spacer sign for the word forms.
  def self.spacer
    '>'
  end
end
