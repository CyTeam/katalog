module ApplicationHelper
  # Nested Form
  def remove_link_unless_new_record(fields)
    unless fields.object.new_record?
      out = ''
      out << fields.hidden_field(:_destroy)
      out << link_to_function(image_tag('icons/delete.png', :title => t('crud.delete', :model => '')), "$(this).parents('.#{fields.object.class.name.underscore}').hide(); $(this).prev().attr('value', '1')")
      out.html_safe
    end
  end

  def add_record_link(form, klass)
    link_to_function image_tag('icons/add.png', :title => t('crud.new', :model => '')) do |page|
      record = render('containers/new_form', :form => form)
      page << %{
var new_record_id = "new_" + new Date().getTime();
$('container-list').insert({ bottom: "#{ escape_javascript record }".replace(/new_\\d+/g, new_record_id) });
}
    end
  end

  # Navigation
  def navigation_item(title, *args)
    if current_page?(*args)
      content_tag("li", :class => "active") do
        content_tag("span", :class => "active") do
          link_to(title, *args)
        end
      end
    else
      content_tag("li") do
        link_to(title, *args)
      end
    end
  end

  # CRUD helpers
  def contextual_link(action, url, options = {})
    output = ActiveSupport::SafeBuffer.new
    options.merge!(:class => "icon icon-#{action}")
    
    output << link_to(t_action(action), url, options)
  end

  def contextual_function(action, function, options = {})
    output = ActiveSupport::SafeBuffer.new
    options.merge!(:class => "icon icon-#{action}")
    
    output << link_to_function(t_action(action), function, options)
  end
end
