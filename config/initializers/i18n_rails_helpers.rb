# encoding: UTF-8

require 'i18n_rails_helpers'

ContextualLinkHelpers.class_eval do
  def icon_link_to(action, url, options = {})
    options.merge!(:class => "icon icon-#{action}", :title => t("tooltips.contextual.#{action}", :default => t_action(action)))

    link_to(t_action(action), url, options)
  end
end
