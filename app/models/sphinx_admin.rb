class SphinxAdmin < ActiveRecord::Base
  FOLDER = Rails.root.join('config', 'sphinx')

  def spacer
    self.class.spacer
  end
  
  def self.seed
    self.import_file(Rails.root.join('db', 'seeds', 'sphinx', file_name))
    self.export_file
  end

  def to_s
    "#{from} #{spacer} #{to}"
  end

  def value=(input)
    values = input.split(spacer)
    self.from = values[0].strip
    self.to   = values[1].strip
  end
  
  def self.list=(value)
    self.delete_all
    
    value.each do |line|
      self.create(:value => line) unless line.blank?
    end
    
    self.sync_sphinx
  end
  
  def self.list
    self.all.join("\n")
  end
  
  private
  
  def self.import_file(file_name = nil)
    file_name ||= FOLDER.join(self.file_name)
    
    self.list = File.read(file_name)
  end

  def self.export_file(file_name = nil)
    file_name ||= FOLDER.join(self.file_name)

    File.open(file_name, "w+") do |file|
      file.puts self.list
    end
  end
  
  def self.call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "rake #{task} #{args.join(' ')} 2>&1 >> #{Rails.root}/log/#{Rails.env}.log &"
  end

  def self.sync_sphinx
    FOLDER.mkpath
    self.export_file
    
    call_rake("thinking_sphinx:reindex")
  end
end
