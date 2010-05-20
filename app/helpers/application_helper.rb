module ApplicationHelper
  def navigation_item(title, *args)
    if current_page?(*args)
      content_tag("li", :class => "active") do
        content_tag("span", title, :class => "active")
      end
    else
      content_tag("li") do
        link_to(title, *args)
      end
    end
  end
end
