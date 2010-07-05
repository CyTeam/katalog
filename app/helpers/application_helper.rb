module ApplicationHelper
  # i18n
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

  def t_confirm_delete(record)
    t('messages.confirm_delete', :record => "#{t_model(record.class)} #{record.to_s}")
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
end
