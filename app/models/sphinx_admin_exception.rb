# This class holds the specific values for the sphinx exceptions config.
class SphinxAdminException < SphinxAdmin
  # The file name for the sphinx exceptions.
  def self.file_name
    'exceptions.txt'
  end

  # The spacer sign for the sphinx exceptions.
  def self.spacer
    '=>'
  end
end
