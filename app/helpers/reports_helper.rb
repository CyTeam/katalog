module ReportsHelper
  def level_for_select
    (1..4).map{|level| [t(level, :scope => 'katalog.reports.level'), level]}
  end
  
  def orientation_for_select
    orientations = [:landscape, :portrait]
    orientations.map{|orientation| [t(orientation, :scope => 'katalog.orientation'), orientation]}
  end
  
  # Build collection for report columns multi select
  #
  # It adds the selected columns first, in the correct order, then comes the available ones.
  def report_columns_for_select(report)
    available_columns = [:signature, :title, :first_document_year, :keyword_text, :container_type, :location, :document_count]

    columns = report.columns + (available_columns - report.columns)
    columns.map{|column| [t_attr(column, Dossier), column]}
  end
end
