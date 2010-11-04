module ApplicationHelper
  # i18n
  def t_paginate(collection = nil, options = {})
    options.merge!(:previous_label => t('crud.previous'), :next_label => t('crud.next'))

    will_paginate(collection, options)
  end
  
  def t_attr(attribute, model = nil)
    if model.is_a? Class
      model_name = model.name.underscore
    elsif model.nil?
      model_name = controller_name.singularize
    end
    t(attribute, :scope => [:activerecord, :attributes, model_name])
  end

  def t_model(model = nil)
    if model.is_a? Class
      model_name = model.name.underscore
    elsif model.nil?
      model_name = controller_name.singularize
    end
    t(model_name, :scope => [:activerecord, :models])
  end

  def t_crud(action = nil, model = nil)
    if model.is_a? Class
      model_name = model.name.underscore
    elsif model.nil?
      model_name = controller_name.singularize
    end
    
    action ||= action_name
    t(action, :scope => :crud, :model => model_name.capitalize)
  end
  
  def t_confirm_delete(record)
    t('messages.confirm_delete', :record => "#{t_model(record.class)} #{record.to_s}")
  end

  # Nested Form
  def remove_link_unless_new_record(fields)
    unless fields.object.new_record?
      out = ''
      out << fields.hidden_field(:_destroy)
      out << link_to_function(image_tag('icons/delete.png', :title => t('crud.delete', :model => '')), "$(this).up('.#{fields.object.class.name.underscore}').hide(); $(this).previous().value = '1'")
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
