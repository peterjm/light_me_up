require 'optparse'

module LightMeUp
  class OptionParser
    MESSAGES = {
      help: "Prints this help message",
      toggle: "Toggle whether the lights are on or off",
      on: "Turn the light on",
      off: "Turn the light off",
      ip_address: "Specify the IP address",
      defaults: "Set to default values",
      brightness: "Set the brightness (%d to %d)" %
        [LightMeUp::Light.min_brightness, LightMeUp::Light.max_brightness],
      temperature: "Set the temperature (%d to %d)" %
        [LightMeUp::Light.min_temperature, LightMeUp::Light.max_temperature],
    }

    attr_reader :program_name, :options, :default_settings

    def initialize(program_name:, starting_options:, default_settings:)
      @program_name = program_name
      @options = starting_options.dup
      @default_settings = default_settings.dup
    end

    def parse(input_options)
      parser.parse!(input_options)
      options
    end

    def help_message
      parser.to_s
    end

    private

    def parser
      @parser ||= ::OptionParser.new do |opts|
        opts.banner = "Usage: #{program_name} [options]"

        opts.on("-h", "--help", MESSAGES[:help]) do
          options[:help] = true
        end

        opts.on("-T", "--toggle", MESSAGES[:toggle]) do
          options[:toggle] = true
        end

        opts.on("-o", "--on", MESSAGES[:on]) do
          options[:on] = true
        end

        opts.on("-O", "--off", MESSAGES[:off]) do
          options[:on] = false
        end

        opts.on("-i", "--ip-address=IP_ADDRESS", MESSAGES[:ip_address]) do |ip_address|
          options[:ip_address] = ip_address
        end

        opts.on("-d", "--defaults", MESSAGES[:defaults]) do
          options.merge!(default_settings)
        end

        opts.on("-bBRIGHTNESS", "--brightness=BRIGHTNESS", MESSAGES[:brightness]) do |brightness|
          options[:brightness] = brightness.to_i
        end

        opts.on("-tTEMPERATURE", "--temperature=TEMPERATURE", MESSAGES[:temperature]) do |temperature|
          options[:temperature] = temperature.to_i
        end
      end
    end
  end
end
