require 'dotenv'
Dotenv.load

class Settings < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env
end