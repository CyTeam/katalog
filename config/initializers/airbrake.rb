# Airbrake configuration
begin
  if Object.const_defined?(Airbrake) && Settings['airbrake']
    Airbrake.configure do |config|
      config.api_key = Settings.airbrake.api_key
    end
  end
rescue
end
