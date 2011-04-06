# This class is a parent class of SphinxAdminException and SphinxAdminWordForm.
# It creates the sphinx config files in the directory config/sphinx.
# Before sphinx search can be started these files should be created.
# The easiest way to do it is:
# * Start the rails application
# * Login with an admin user
# * Go to "Verwaltung > Volltextsuche"
# * And open the two sub links to save the forms
class SphinxAdmin < ActiveRecord::Base

  # The default folder for the config files.
  FOLDER = Rails.root.join('config', 'sphinx')

  # The default spacer sign.
  def spacer
    self.class.spacer
  end

  # Imports entries from db seeds.
  def self.seed
    self.import_file(Rails.root.join('db', 'seeds', 'sphinx', file_name))
    self.export_file
  end

  def to_s
    "#{from} #{spacer} #{to}"
  end

  # Splits the input with the spacer and saves them.
  def value=(input)
    values = input.split(spacer)
    self.from = values[0].strip
    self.to   = values[1].strip
  end

  # Find by value searches in find_by_from and find_by_to.
  def self.find_by_value(value)
    sphinx_admin = self.find_by_from(value)
    sphinx_admin = self.find_by_to(value) unless sphinx_admin

    sphinx_admin
  end

  #
  def self.extend_words(words)
    words.inject([]) do |out, word|
      sphinx_admin = find_by_value(word)
      if sphinx_admin
        out << sphinx_admin.from
        out << sphinx_admin.to
      end
      out << word
    end.uniq
  end

  # Saves the values as entries of SphinxAdmin.
  def self.list=(value)
    self.delete_all
    
    value.each_line do |line|
      self.create(:value => line) unless line.blank?
    end
    
    self.sync_sphinx
  end

  # Returns all entries of a type (SphinxAdminException or SphinxAdminWordForms).
  def self.list
    self.all.join("\n")
  end
  
  private # :nodoc
  
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
