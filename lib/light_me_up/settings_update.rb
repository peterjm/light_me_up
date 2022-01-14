# frozen_string_literal: true

module LightMeUp
  class SettingsUpdate
    attr_reader :api_client, :options

    class ToggleIncompatible < Error; end
    class NoOptionsGiven < Error; end

    def initialize(api_client, options)
      @api_client = api_client
      @options = options
    end

    def perform
      if options[:toggle]
        raise ToggleIncompatible, "is not compatible with setting other options" if settings_options.any?

        api_client.toggle
      end

      api_client.set(**settings_options) if settings_options.any?

      raise NoOptionsGiven, "provide at least one option"
    end

    private

    def settings_options
      @settings_options ||= options.slice(:on, :brightness, :temperature)
    end
  end
end
