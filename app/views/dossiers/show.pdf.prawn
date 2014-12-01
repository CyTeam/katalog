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
    pdf.indent(10) do
      description = sanitize(pdf.list(@dossier.description), :tags => %w(i u b strong a sub sup), :attributes => %w(href))
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
    split_decades(@dossier.numbers.documents_present).each do |decade|
      header = decade.inject([]) do |out, year|
        out << year.period.to_s

        out
      end

      row = decade.inject([]) do |out, year|
        out << year.amount.to_s

        out
      end

      pdf.indent(10) do
        pdf.table [header] + [row] do
          cells.align = :right
          cells.width = 40
          cells.border_width = 0.5
          row(0).size = 5
        end
      end

      pdf.text " "
    end

    pdf.indent(10) do
      pdf.text " "
      pdf.text t('katalog.total') + ": " + @dossier.document_count.to_s
    end

    pdf.move_down(10)
  end

  if @dossier.containers.present?
    pdf.text t_attr(:containers), :size => 12
    pdf.indent(10) do
     @dossier.containers.each do |container|
       pdf.text t_attr(:container_type, Container) + ": " + container.container_type.to_s
       pdf.text t_attr(:location, Container) + ": " + container.location.to_s
       pdf.text t_attr(:period, Container) + ": " + container.period.to_s unless container.period.blank?
     end
    end
    pdf.move_down(20)
  end

  # Footer
  pdf.page_footer
end
