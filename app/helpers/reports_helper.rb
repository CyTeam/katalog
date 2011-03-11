module ReportsHelper
  def level_for_select
    (1..4).map{|level| [t(level, :scope => 'katalog.reports.level'), level]}
  end
  
  def orientation_for_select
    orientations = [:landscape, :portrait]
    orientations.map{|orientation| [t(orientation, :scope => 'katalog.orientation'), orientation]}
  end
  
  def report_columns_for_select
    columns = [:signature, :title, :first_document_year, :keyword_text, :container_type, :location, :document_count, :keywords]
    
    columns.map{|column| [t_attr(column, Dossier), column]}
  end
end
