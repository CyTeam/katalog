prawn_document(:page_size => 'A4', :renderer => PrawnLayout) do |pdf|
  # Draw the title
  title = [params[:signature], params[:container_type], params[:location]].map(&:presence).compact.join(' / ')
  pdf.h1 title

  # Table content creation.
  @dossiers.each do |dossier|
    pdf.text dossier.to_s

    pdf.indent 40 do
      dossier.containers.each do |container|
        pdf.text "%s@%s %s" % [container.container_type.code, container.location.code, container.period]
      end
    end
  end

  # Footer
  pdf.page_footer
end
