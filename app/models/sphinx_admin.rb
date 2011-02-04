class SphinxAdmin < ActiveRecord::Base

  FOLDER = "#{Rails.root}/config/sphinx/"
  WORD_FORM_SPACER = '>'
  EXCEPTION_SPACER = "=>"

  def self.import
    exceptions = SphinxAdminException
    word_forms = SphinxAdminWordForm
    self.all.each do |e|
      e.delete
    end
    import_file('exceptions.txt', exceptions)
    import_file('wordforms.txt', word_forms)
    write_file('exceptions.txt', exceptions)
    write_file('wordforms.txt', word_forms)
  end

  def value
    "#{from} #{spacer} #{to}"
  end

  def value=(input)
    values = divide_input(input)
    self.to    = values[:to]
    self.from  = values[:from]
  end
  
  def self.spacer
    if self.name.eql?SphinxAdminException.to_s
      EXCEPTION_SPACER
    else
      WORD_FORM_SPACER
    end
  end

  def spacer
    if self.class.name.eql?SphinxAdminException.to_s
      EXCEPTION_SPACER
    else
      WORD_FORM_SPACER
    end
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
    values = input.split(spacer)
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
      file.puts ex.from + ' ' + spacer + ' ' + ex.to
    end
    file.close
  end
end
