module LightMeUp
  class SettingsUpdate
    attr_reader :api_client, :options, :help_message, :output_stream, :error_output_stream

    def initialize(api_client, options, help_message, output_stream=STDOUT, error_output_stream=STDERR)
      @api_client = api_client
      @options = options
      @help_message = help_message
      @output_stream = output_stream
      @error_output_stream = error_output_stream
    end

    def perform
      if options[:help]
        puts parser.help_message
        return true
      end

      if options[:toggle]
        if settings_options.any?
          error_output_stream.puts "Toggle is not compatible with setting other options."
          output_stream.puts help_message
          return false
        end

        api_client.toggle
        return true
      end

      if settings_options.any?
        api_client.set(**settings_options)
        return true
      end

      output_stream.puts help_message
      return false
    rescue LightMeUp::Error => e
      error_output_stream.puts e.message
      return false
    end

    private

    def settings_options
      @settings_options ||= options.slice(:on, :brightness, :temperature)
    end
  end
end
