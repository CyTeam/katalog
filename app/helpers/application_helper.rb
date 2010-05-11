module ApplicationHelper
  def navigation_item(title, *args)
    if current_page?(*args)
      link = tag("span", :class => "active") + title.html_safe + "</span>".html_safe
      item = tag("li", :class => "active") + link + "</li>".html_safe
    else
      item = tag("li") + link_to(title, *args) + "</li>".html_safe
    end

    return item
  end
end
