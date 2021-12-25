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
          temperature: light.temperature,
        }.compact
      end

      def deserialize(json)
        json["lights"].map do |light|
          Light.new(
            on: light["on"] == 1,
            brightness: light["brightness"],
            temperature: light["temperature"],
          )
        end
      end
    end
  end
end
