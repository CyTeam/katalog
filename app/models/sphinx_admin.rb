# encoding: UTF-8

# This class is a parent class of SphinxAdminException and SphinxAdminWordForm.
# It creates the sphinx config files in the directory config/sphinx.
# Before sphinx search can be started these files should be created.
# The easiest way to do it is:
# * Start the rails application
# * Login with an admin user
# * Go to "Verwaltung > Volltextsuche"
# * And open the two sub links to save the forms
class SphinxAdmin < ActiveRecord::Base

  has_paper_trail :ignore => [:created_at, :updated_at]

  default_scope :order => "sphinx_admins.from ASC"

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
    all_words = words.clone

    words.map do |word|
      all_words += self.where(:from => word).pluck(:to)
      all_words += self.where(:to => word).pluck(:from)
    end

    all_words.uniq
  end

  # Saves the values as entries of SphinxAdmin.
  def self.list=(value)
    # Delete removed lines
    deleted = self.list.split("\n") - value.split("\n")

    deleted.each do |line|
      input = line.split(spacer)
      entry = self.find_by_from_and_to(input[0].strip, input[1].strip)
      entry.delete
    end

    # Create added lines
    added = value.split("\n") - self.list.split("\n")

    added.each do |line|
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
      file.write self.list
    end
  end

  def self.sync_sphinx
    self.export_file

    ThinkingSphinx::Configuration.instance.controller.index
  end
end
