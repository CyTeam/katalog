class SphinxAdmin < ActiveRecord::Base
  FOLDER = Rails.root.join('config', 'sphinx')

  cattr_accessor :file_name
  cattr_accessor :spacer
  
  def self.rewrite
    self.delete_all
    self.import_file
    self.export_file
  end

  def value
    "#{from} #{spacer} #{to}"
  end

  def value=(input)
    values = divide_input(input)
    self.to    = values[:to]
    self.from  = values[:from]
  end
  
  private

  def write_file
    file = File.new(FOLDER.join(FILE_NAME), "w+")
    self.all.each do |ex|
      file.puts ex.spacer
    end
    file.close
  end

  def divide_input(input)
    values = input.split(spacer)
    a = Hash.new
    a[:from] = values[0].strip
    a[:to] = values[1].strip

    a
  end

  def self.import_file
    File.open(FOLDER.join(self.file_name), "r") do |file|
      file.each do |line|
        self.create(:value => line) unless line.blank?
      end
    end
  end

  def self.export_file
    File.open(FOLDER.join(self.file_name), "w+") do |file|
      self.all.each do |ex|
        file.puts ex.value
      end
    end
  end
end
