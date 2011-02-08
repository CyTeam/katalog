class SphinxAdmin < ActiveRecord::Base
  FOLDER = Rails.root.join('config', 'sphinx')

  cattr_accessor :file_name
  cattr_accessor :spacer
  
  def self.seed
    self.delete_all
    self.import_file(Rails.root.join('db', 'seeds', 'sphinx', file_name))
    FOLDER.mkpath
    self.export_file
  end

  def to_s
    "#{from} #{spacer} #{to}"
  end

  def value=(input)
    values = input.split(spacer)
    self.to    = values[0].strip
    self.from  = values[1].strip
  end
  
  private
  def self.import_file(file_name = nil)
    file_name ||= FOLDER.join(self.file_name)
    
    File.open(file_name, "r") do |file|
      file.each do |line|
        self.create(:value => line) unless line.blank?
      end
    end
  end

  def self.export_file(file_name = nil)
    file_name ||= FOLDER.join(self.file_name)

    File.open(file_name, "w+").puts self.all
  end
end
