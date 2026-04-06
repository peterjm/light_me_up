# frozen_string_literal: true

require "test_helper"

module LightMeUp
  class LightSerializerTest < Minitest::Test
    def test_serialize_all_fields
      light = LightMeUp::Light.new(on: true, brightness: 50, temperature: 50)
      result = LightMeUp::LightSerializer.serialize(light)

      assert_equal 1, result[:on]
      assert_equal 50, result[:brightness]
      assert_includes LightMeUp::ApiClient::TEMPERATURE_RANGE, result[:temperature]
    end

    def test_serialize_on_true
      light = LightMeUp::Light.new(on: true)
      result = LightMeUp::LightSerializer.serialize(light)

      assert_equal 1, result[:on]
    end

    def test_serialize_on_false
      light = LightMeUp::Light.new(on: false)
      result = LightMeUp::LightSerializer.serialize(light)

      assert_equal 0, result[:on]
    end

    def test_serialize_compacts_nil_values
      light = LightMeUp::Light.new(on: true)
      result = LightMeUp::LightSerializer.serialize(light)

      assert_equal({ on: 1 }, result)
      refute result.key?(:brightness)
      refute result.key?(:temperature)
    end

    def test_serialize_nil_on
      light = LightMeUp::Light.new(brightness: 50)
      result = LightMeUp::LightSerializer.serialize(light)

      refute result.key?(:on)
      assert_equal 50, result[:brightness]
    end

    def test_serialize_temperature_min
      light = LightMeUp::Light.new(temperature: 0)
      result = LightMeUp::LightSerializer.serialize(light)

      assert_equal 143, result[:temperature]
    end

    def test_serialize_temperature_max
      light = LightMeUp::Light.new(temperature: 100)
      result = LightMeUp::LightSerializer.serialize(light)

      assert_equal 343, result[:temperature]
    end

    def test_deserialize_single_light
      json = {
        "numberOfLights" => 1,
        "lights" => [
          { "on" => 1, "brightness" => 75, "temperature" => 143 }
        ],
      }

      lights = LightMeUp::LightSerializer.deserialize(json)

      assert_equal 1, lights.size
      light = lights.first
      assert light.on
      assert_equal 75, light.brightness
      assert_equal 0, light.temperature
    end

    def test_deserialize_off_light
      json = {
        "numberOfLights" => 1,
        "lights" => [
          { "on" => 0, "brightness" => 50, "temperature" => 244 }
        ],
      }

      light = LightMeUp::LightSerializer.deserialize(json).first

      refute light.on
    end

    def test_deserialize_temperature_max
      json = {
        "numberOfLights" => 1,
        "lights" => [
          { "on" => 1, "brightness" => 50, "temperature" => 343 }
        ],
      }

      light = LightMeUp::LightSerializer.deserialize(json).first

      assert_equal 100, light.temperature
    end

    def test_serialize_deserialize_roundtrip
      light = LightMeUp::Light.new(on: true, brightness: 80, temperature: 65)
      serialized = LightMeUp::LightSerializer.serialize(light)

      json = { "lights" => [serialized.transform_keys(&:to_s)] }
      deserialized = LightMeUp::LightSerializer.deserialize(json).first

      assert_equal light.on, deserialized.on
      assert_equal light.brightness, deserialized.brightness
      assert_equal light.temperature, deserialized.temperature
    end
  end
end
