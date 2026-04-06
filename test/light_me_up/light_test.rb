# frozen_string_literal: true

require "test_helper"

module LightMeUp
  class LightTest < Minitest::Test
    def test_initializes_with_all_attributes
      light = LightMeUp::Light.new(on: true, brightness: 50, temperature: 75)

      assert light.on
      assert_equal 50, light.brightness
      assert_equal 75, light.temperature
    end

    def test_initializes_with_nil_defaults
      light = LightMeUp::Light.new

      assert_nil light.on
      assert_nil light.brightness
      assert_nil light.temperature
    end

    def test_accepts_minimum_brightness
      light = LightMeUp::Light.new(brightness: 0)
      assert_equal 0, light.brightness
    end

    def test_accepts_maximum_brightness
      light = LightMeUp::Light.new(brightness: 100)
      assert_equal 100, light.brightness
    end

    def test_rejects_brightness_below_range
      error = assert_raises(LightMeUp::Error) do
        LightMeUp::Light.new(brightness: -1)
      end
      assert_equal "Brightness must be between 0 and 100", error.message
    end

    def test_rejects_brightness_above_range
      error = assert_raises(LightMeUp::Error) do
        LightMeUp::Light.new(brightness: 101)
      end
      assert_equal "Brightness must be between 0 and 100", error.message
    end

    def test_accepts_minimum_temperature
      light = LightMeUp::Light.new(temperature: 0)
      assert_equal 0, light.temperature
    end

    def test_accepts_maximum_temperature
      light = LightMeUp::Light.new(temperature: 100)
      assert_equal 100, light.temperature
    end

    def test_rejects_temperature_below_range
      error = assert_raises(LightMeUp::Error) do
        LightMeUp::Light.new(temperature: -1)
      end
      assert_equal "Temperature must be between 0 and 100", error.message
    end

    def test_rejects_temperature_above_range
      error = assert_raises(LightMeUp::Error) do
        LightMeUp::Light.new(temperature: 101)
      end
      assert_equal "Temperature must be between 0 and 100", error.message
    end

    def test_max_brightness
      assert_equal 100, LightMeUp::Light.max_brightness
    end

    def test_min_brightness
      assert_equal 0, LightMeUp::Light.min_brightness
    end

    def test_max_temperature
      assert_equal 100, LightMeUp::Light.max_temperature
    end

    def test_min_temperature
      assert_equal 0, LightMeUp::Light.min_temperature
    end
  end
end
