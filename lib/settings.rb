# encoding: UTF-8

class Settings < Settingslogic
  namespace Rails.env

  yml = Rails.root.join('config', 'application.yml')
  if yml.exist?
    source yml
  else
    source Rails.root.join('config', 'application.yml.example')
  end
end
