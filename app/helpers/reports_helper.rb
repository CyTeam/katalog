module ReportsHelper
  def orientation_for_select
    orientations = [:landscape, :portrait]
    orientations.map{|orientation| [t(orientation, :scope => 'katalog.orientation'), orientation]}
  end
  
  def report_columns_for_select
    columns = [:title, :signature, :first_document_year, :keyword_text, :container_type, :location, :document_count, :keywords]
    
    columns.map{|column| [t_attr(column, Dossier), column]}
  end
end
