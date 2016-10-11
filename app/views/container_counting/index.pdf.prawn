prawn_document(:page_size => 'A4', :renderer => PrawnLayout) do |pdf|
  # Draw the title
  title = [params[:signature], params[:container_type], params[:location]].map(&:presence).compact.join(' / ')
  pdf.h1 title

  # Table content creation.
  @dossiers.each do |dossier|
    pdf.text dossier.to_s

    pdf.indent 40 do
      container_type, container_location = ''
      container_period = []

      dossier.containers.each do |container|
        if container_type == container.container_type.code && container_location == container.location.code
          container_period << container.period
        else
          container_type = container.container_type.code
          container_location = container.location.code
          container_period << container.period
        end

      end
      pdf.text "%s@%s %s" % [container_type, container_location, container_period.join(', ')]
    end
  end

  # Footer
  pdf.page_footer
end
