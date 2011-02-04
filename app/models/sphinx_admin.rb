class SphinxAdmin < ActiveRecord::Base

  FOLDER = "#{Rails.root}/config/sphinx/"

  def self.initial_import
    import_file('exceptions.txt', SphinxAdminException)
    import_file('wordforms.txt', SphinxAdminWordForm)
    write_file('exceptions.txt', SphinxAdminException)
    write_file('wordforms.txt', SphinxAdminWordForm)
  end

  def value
    "#{from} #{SPACER} #{to}"
  end

  def value=(input)
    values = divide_input(input)
    self.to    = values[:to]
    self.from  = values[:from]
  end

  private

  def write_file
    file = File.new("#{FOLDER}#{FILE_NAME}", "w+")
    self.all.each do |ex|
      file.puts ex.from + ' ' + SPACER + ' ' + ex.to
    end
    file.close
  end

  def divide_input(input)
    values = input.split(SPACER)
    a = Hash.new
    a[:from] = values[0].strip
    a[:to] = values[1].strip

    a
  end

  def self.import_file(name, model)
    file = File.new("#{FOLDER}#{name}", "r")
    file.each do |line|
      model.create(:value => line) unless line.strip.empty?
    end
    file.close
  end

  def self.write_file(name, model)
    file = File.new("#{FOLDER}#{name}", "w+")
    model.all.each do |ex|
      file.puts ex.from + ' ' + SPACER + ' ' + ex.to
    end
    file.close
  end
end
