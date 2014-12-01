module ReportsHelper
  def level_for_select
    (1..4).map { |level| [t(level, scope: 'katalog.reports.level'), level] }
  end

  def orientation_for_select
    orientations = [:landscape, :portrait]
    orientations.map { |orientation| [t(orientation, scope: 'katalog.orientation'), orientation] }
  end

  def report_column_names_for_select(report)
    available_columns = %w(signature title first_document_year keyword_text container_type location document_count)

    if report.column_names.blank?
      columns = available_columns
    else
      columns = report.column_names + (available_columns - report.column_names)
    end

    columns.reject(&:empty?).map { |column| [t_attr(column, Dossier), column] }
  end
end
