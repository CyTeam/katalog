prawn_document(:page_size => 'A4', :renderer => DossiersHelper::Prawn) do |pdf|

  # Style
  pdf.default_font

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

  pdf.text t_attr(:description), :size => 12
  pdf.indent(10) do
    description = sanitize(auto_link(@dossier.description), :tags => %w(i em b strong a), :attributes => %w(href))
    pdf.text description, :inline_format => true
  end
  pdf.move_down(10)
  
  pdf.text t_attr(:keywords), :size => 12
  pdf.indent(10) do
    for keyword in @dossier.keywords.order('name') do
      pdf.text keyword.name
    end
  end
  pdf.move_down(10)
  
  pdf.text t_attr(:relation_list), :size => 12
  pdf.indent(10) do
    for relation in @dossier.relation_titles do
      pdf.text link_to(relation, search_dossiers_url(:search => {:text => relation})), :inline_format => true
    end
  end
  pdf.move_down(10)

  # Footer
  pdf.page_footer
end
