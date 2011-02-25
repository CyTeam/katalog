class SeedDefaultReports < ActiveRecord::Migration
  def self.up
    Report.create(
      :name        => 'index',
      :title       => 'Themenübersicht',
      :orientation => 'portrait',
      :columns     => [:signature, :title, :document_count],
      :level       => 2,
      :per_page    => 'all'
    )
    Report.create(
      :name        => 'overview',
      :title       => 'Detailreport',
      :orientation => 'landscape',
      :columns     => [:signature, :title, :first_document_year, :container_type, :location, :keyword_text]
    )
    Report.create(
      :name        => 'year',
      :title       => 'Jahresreport',
      :orientation => 'landscape',
      :columns     => [:signature, :title, :first_document_year],
      :collect_year_count => 1
    )
    Report.create(
      :name        => '5-year',
      :title       => '5-Jahresreport',
      :orientation => 'portrait',
      :columns     => [:signature, :title, :document_count],
      :level       => 2,
      :per_page    => 'all',
      :collect_year_count => 5
    )
  end

  def self.down
  end
end
