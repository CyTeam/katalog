# encoding: UTF-8

# Google analytics middleware.
begin
  if Object.const_defined?(:Rack) && Rack.const_defined?(:GoogleAnalytics) && Settings['google_analytics']
    Rails.application.config.middleware.use('Rack::GoogleAnalytics', tracker: Settings.google_analytics.api_key, anonymize_ip: Settings.google_analytics.anonymize_ip)
  end
rescue
end
