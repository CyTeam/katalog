class UseStringsForReportColumnNames < ActiveRecord::Migration
  def self.up
    Report.find_each {|report|
      columns = report.columns
      report.columns = columns.map{|column| column.to_s}
      report.save(false)
    }
  end

  def self.down
  end
end
