module ApplicationHelper
  # Navigation
  def navigation_item(title, *args)
    if current_page?(*args)
      content_tag('li', class: 'active') do
        content_tag('span', class: 'active') do
          link_to(title, *args)
        end
      end
    else
      content_tag('li') do
        link_to(title, *args)
      end
    end
  end

  # CRUD helpers
  def contextual_link(action, url, options = {})
    output = ActiveSupport::SafeBuffer.new
    options.merge!(class: "icon icon-#{action}-text", title: t_action(action))

    output << link_to(t_action(action), url, options)
  end

  def contextual_pdf_link(length = 0)
    contextual_link('print', url_for(params.merge(format: :pdf)), title: t('tooltips.dossiers.show_pdf'), target: '_blank', onclick: "javascript:return informUserAboutBigPDF(#{length});")
  end

  def contextual_function(action, function, options = {})
    output = ActiveSupport::SafeBuffer.new
    options.merge!(class: "icon icon-#{action}")

    output << link_to_function(t_action(action), function, options)
  end

  # Nested form helpers
  def show_new_form(model)
    model_name = model.to_s.underscore

    output = <<EOF
$('##{model_name}_list').replaceWith('#{escape_javascript(render('form'))}');
addReportColumnMultiselectBehaviour();
addAutofocusBehaviour();
addAutocompleteBehaviour();
addNestedFormsBehaviour();
addCorrectnessIndicatorBehaviour();
addDatePickerBehaviour();
addAutogrowBehaviour();
EOF

    output.html_safe
  end

  def active?(topic)
    if @dossier.try(:signature)
      @dossier.signature.starts_with?(topic.signature)
    elsif params[:action] == 'navigation'
      current_topic = Topic.find(params[:id])

      current_topic.signature.starts_with?(topic.signature)
    else
      # active if searched for
      params[:search] && params[:search][:text] && params[:search][:text].start_with?(topic.signature)
    end
  end

  def spelling_suggestion_link(inserted, suggested)
    search_text = params[:search][:text] if params[:search]
    if search_text
      search_text = search_text.gsub(inserted, suggested)
      search = params[:search].merge(text: search_text)

      link_to(suggested, params.merge(search: search))
    end
  end

  def string_search(query)
    query = '"' + query + '"'

    link_to(query, search: { text: query })
  end

  def user_cache_key
    cache_key = [(user_signed_in? ? :signed_in : :signed_out)]
    cache_key = current_user.roles.map { |role| role.to_s.downcase } if current_user

    cache_key.join('/')
  end

  def parsed_footer
    if Rails.env.production?
      Rails.cache.fetch('parsed_footer_value', expires_in: 24.hours) do
        mechanize = Mechanize.new
        page = mechanize.get('http://www.doku-zug.ch')
        footer = page.at('#footer').to_html
        footer.html_safe
      end
    end
  end
end
