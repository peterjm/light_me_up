module LightMeUp
  class Light
    attr_reader :on, :brightness, :temperature

    BRIGHTNESS_RANGE = (0..100)
    TEMPERATURE_RANGE = (143..344)

    class << self
      def max_brightness
        BRIGHTNESS_RANGE.last
      end

      def min_brightness
        BRIGHTNESS_RANGE.first
      end

      def max_temperature
        TEMPERATURE_RANGE.last
      end

      def min_temperature
        TEMPERATURE_RANGE.first
      end
    end

    def initialize(on: nil, brightness: nil, temperature: nil)
      validate_brightness(brightness)
      validate_temperature(temperature)

      @on = on
      @brightness = brightness
      @temperature = temperature
    end

    private

    def validate_brightness(value)
      validate_range(value, BRIGHTNESS_RANGE, "Brightness")
    end

    def validate_temperature(value)
      validate_range(value, TEMPERATURE_RANGE, "Temperature")
    end

    def validate_range(value, range, name)
      return if value.nil?
      return if range.include?(value)
      raise Error, "#{name} must be between #{range.first} and #{range.last}"
    end
  end
end
