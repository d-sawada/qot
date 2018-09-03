require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module QueenOfTime
  class Application < Rails::Application
    config.load_defaults 5.2

    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]

    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_types = [:datetime, :time]

    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      %Q(#{html_tag}).html_safe
    end

    config.autoload_paths += Dir["#{config.root}/constants/*"]
  end
end
