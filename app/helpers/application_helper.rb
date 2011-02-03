module ApplicationHelper
  # Nested Form
  def remove_link_unless_new_record(fields)
    unless fields.object.new_record?
      out = ''
      out << fields.hidden_field(:_destroy)
      out << link_to_function(image_tag('icons/delete.png', :title => t('crud.delete', :model => '')), "$(this).parents('.#{fields.object.class.name.underscore}').hide();$(this).hide();$(this).prev().attr('value', '1');$(this).next().show();hideUnlessNewRecord($(this).parents('.#{fields.object.class.name.underscore}'));")
      out << link_to_function(image_tag('icons/add.png', :title => t('crud.back', :model => '')), "$(this).parents('.#{fields.object.class.name.underscore}').hide();$(this).hide();$(this).prev().prev().attr('value', 'false');$(this).prev().show();showUnlessNewRecord($(this).parents('.#{fields.object.class.name.underscore}'));", :style => 'display:none;')
      out.html_safe
    end
  end

  def add_record_link(form, klass)
    link_to_function image_tag('icons/add.png', :title => t('crud.new', :model => '')), :id => 'add_record_link' do |page|
      record = render('containers/new_form', :form => form)
      page << %{
var new_record_id = new Date().getTime();
var content = "#{ escape_javascript record }";
content = content.replace(/\\[\\d+\\]/g, "[" + new_record_id + "]");
content = content.replace(/_\\d+_/g, "_" + new_record_id + "_");
$('#container-list').append(content);
addContainerSuggestionBehaviour();
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

  # Nested form helpers
  def show_new_form(model)
    model_name = model.to_s.underscore

    output = <<EOF
$('##{model_name}_list').replaceWith('#{escape_javascript(render('form'))}');
addAutofocusBehaviour();
addAutocompleteBehaviour();
addNestedFormsBehaviour();
addCorrectnessIndicatorBehaviour();
addDatePickerBehaviour();
addAutogrowBehaviour();
EOF

    output.html_safe
  end
end
