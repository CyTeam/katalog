class SphinxAdmin < ActiveRecord::Base
  FOLDER = Rails.root.join('config', 'sphinx')

  cattr_accessor :file_name
  cattr_accessor :spacer
  
  def self.seed
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
  
  def self.import_text(value)
    self.delete_all
    
    value.each do |line|
      self.create(:value => line) unless line.blank?
    end
  end
  
  private
  after_save :sync_sphinx
  after_destroy :sync_sphinx
  
  def self.import_file(file_name = nil)
    file_name ||= FOLDER.join(self.file_name)
    
    self.import_text File.read(file_name)
  end

  def self.export_file(file_name = nil)
    file_name ||= FOLDER.join(self.file_name)

    File.open(file_name, "w+").puts self.all
  end
  
  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "rake #{task} #{args.join(' ')} 2>&1 >> #{Rails.root}/log/#{Rails.env}.log &"
  end

  def sync_sphinx
    self.class.export_file
    
    call_rake("thinking_sphinx:reindex")
  end
end
