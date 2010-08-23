class PaginationListLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer

  def html_container(html)
    html += [per_page_link(25), per_page_link(50), per_page_link(200)].join(' ')
    tag(:div, html, container_attributes)
  end

  def per_page_link(count)
    "<a class='per_page' href='%s'>%s</a>" % [per_page_href(count), count]
  end

  def per_page_href(count)
    params = @template.params.merge({:per_page => count})
    
    @template.url_for(params)
  end

end
