prawn_document(:page_size => 'A4', :filename => "#{@dossier.to_s}.pdf", :renderer => PrawnLayout) do |pdf|
  # Heading
  pdf.h1 @dossier.title
  
  # Body
  pdf.text @dossier.signature, :size => 12
  pdf.indent(10) do
    for parent in @dossier.parents
      pdf.text link_to_topic(parent), :inline_format => true
    end
  end
  pdf.move_down(10)

  if @dossier.description.present?
    pdf.text t_attr(:description), :size => 12
    pdf.indent(10) do
      description = sanitize(auto_link(@dossier.description), :tags => %w(i u b strong a), :attributes => %w(href))
      pdf.text description, :inline_format => true
    end
    pdf.move_down(10)
  end

  pdf.text t_attr(:keywords), :size => 12
  pdf.indent(10) do
    for keyword in @dossier.keywords.order('name') do
      pdf.text keyword.name
    end
  end
  pdf.move_down(10)
  
  if @dossier.related_to.present?
    pdf.text t_attr(:relation_list), :size => 12
    pdf.indent(10) do
      for relation in @dossier.relation_titles do
        pdf.text link_to(relation, search_dossiers_url(:search => {:text => relation})), :inline_format => true
      end
    end
    pdf.move_down(10)
  end

  if @dossier.years_counts.present?
    pdf.text t_attr(:dossier_number_list), :size => 12

    years = @dossier.years_counts(1)
    header = years.inject([]) do |out, year|
      out << year[:period].to_s

      out
    end

    row = years.inject([]) do |out, year|
      out << year[:count].to_s

      out
    end

    pdf.table [header] + [row] do
      row(0).size = 5
      row(0).font_style = :bold
    end

    pdf.indent(10) do
      pdf.text " "
      pdf.text t('katalog.total') + ": " + @dossier.document_count.to_s
    end
    pdf.move_down(10)
  end

  if @dossier.containers.present?
    container_header = [t_attr(:container_type, Container), t_attr(:location, Container), t_attr(:period, Container)]
    container_rows = @dossier.containers.inject([]) {|out, container| out << [container.container_type.to_s, container.location.to_s, (container.period.blank? ? '' : container.period.to_s)]; out }
    
    pdf.text t('katalog.title.document_count_html', :document_count => number_with_delimiter(@dossier.document_count), :first_document => @dossier.first_document_on.try(:strftime, '%Y')), :size => 12, :inline_format => true
    
    pdf.table [container_header] + container_rows do
      row(0).font_style = :bold
    end
    pdf.move_down(20)
  end

  # Footer
  pdf.page_footer
end
