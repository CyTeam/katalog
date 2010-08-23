class PaginationListLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer

  def html_container(html)
    html += [per_page_link(25), per_page_link(50), per_page_link(200)].join(' ')
    tag(:div, html, container_attributes)
  end

  def per_page_link(count)
    "<a href='%s'>%s</a>" % [per_page_href(count), count]
  end

  def per_page_href(count)
    @base_url_params ||= begin
      url_params = base_url_params
      merge_optional_params(url_params)
      url_params
    end
    
    url_params = @base_url_params.dup
    symbolized_update(url_params, {:per_page => count})
    
    @template.url_for(url_params)
  end

end
