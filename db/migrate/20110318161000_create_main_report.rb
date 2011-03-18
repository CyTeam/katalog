class CreateMainReport < ActiveRecord::Migration
  def self.up
    Report.create!(:name => "main", :title => "Hauptreport", :orientation => "landscape", :collect_year_count => 1, :columns => ["title"])
  end

  def self.down
    Report.find_by_name('main').destroy
  end
end
