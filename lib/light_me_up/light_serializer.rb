# frozen_string_literal: true

module LightMeUp
  class LightSerializer
    class << self
      def serialize(light)
        on_as_int = if light.on.nil?
                      nil
                    else
                      light.on ? 1 : 0
                    end

        {
          on: on_as_int,
          brightness: light.brightness,
          temperature: to_api_temperature(light.temperature),
        }.compact
      end

      def deserialize(json)
        json["lights"].map do |light|
          Light.new(
            on: light["on"] == 1,
            brightness: light["brightness"],
            temperature: to_readable_temperature(light["temperature"])
          )
        end
      end

      private

      def to_readable_temperature(api_temperature)
        scale_value(api_temperature, ApiClient::TEMPERATURE_RANGE, Light::TEMPERATURE_RANGE)
      end

      def to_api_temperature(readable_temperature)
        scale_value(readable_temperature, Light::TEMPERATURE_RANGE, ApiClient::TEMPERATURE_RANGE)
      end

      def scale_value(value, src_range, dest_range)
        scale_ratio = dest_range.size.to_f / src_range.size.to_f
        (dest_range.min + scale_ratio * (value - src_range.min)).round
      end
    end
  end
end
