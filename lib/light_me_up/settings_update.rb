# frozen_string_literal: true

module LightMeUp
  class SettingsUpdate
    attr_reader :api_client, :options

    class ToggleIncompatible < Error; end
    class InvalidOptions < Error; end

    def initialize(api_client, options)
      @api_client = api_client
      @options = options
    end

    def perform
      settings_options = options.slice(:toggle, :on, :brightness, :temperature)
      if settings_options.delete(:toggle)
        raise ToggleIncompatible, "is not compatible with on or off" if settings_options.key?(:on)

        api_client.toggle(**settings_options)
      elsif settings_options.any?
        api_client.update(**settings_options)
      else
        raise InvalidOptions, "At least one option must be provided"
      end
    end
  end
end
