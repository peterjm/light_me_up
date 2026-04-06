# frozen_string_literal: true

require "test_helper"

module LightMeUp
  class SettingsUpdateTest < Minitest::Test
    def test_toggle_calls_toggle_on_api_client
      api_client = FakeApiClient.new
      LightMeUp::SettingsUpdate.new(api_client, { toggle: true }).perform

      assert_equal :toggle, api_client.last_call
      assert_equal({}, api_client.last_args)
    end

    def test_toggle_passes_brightness_and_temperature
      api_client = FakeApiClient.new
      LightMeUp::SettingsUpdate.new(api_client, { toggle: true, brightness: 50, temperature: 75 }).perform

      assert_equal :toggle, api_client.last_call
      assert_equal({ brightness: 50, temperature: 75 }, api_client.last_args)
    end

    def test_toggle_with_on_raises_error
      assert_raises(LightMeUp::SettingsUpdate::ToggleIncompatible) do
        LightMeUp::SettingsUpdate.new(FakeApiClient.new, { toggle: true, on: true }).perform
      end
    end

    def test_toggle_with_on_false_raises_error
      assert_raises(LightMeUp::SettingsUpdate::ToggleIncompatible) do
        LightMeUp::SettingsUpdate.new(FakeApiClient.new, { toggle: true, on: false }).perform
      end
    end

    def test_on_calls_update
      api_client = FakeApiClient.new
      LightMeUp::SettingsUpdate.new(api_client, { on: true }).perform

      assert_equal :update, api_client.last_call
      assert_equal({ on: true }, api_client.last_args)
    end

    def test_off_calls_update
      api_client = FakeApiClient.new
      LightMeUp::SettingsUpdate.new(api_client, { on: false }).perform

      assert_equal :update, api_client.last_call
      assert_equal({ on: false }, api_client.last_args)
    end

    def test_brightness_calls_update
      api_client = FakeApiClient.new
      LightMeUp::SettingsUpdate.new(api_client, { brightness: 80 }).perform

      assert_equal :update, api_client.last_call
      assert_equal({ brightness: 80 }, api_client.last_args)
    end

    def test_temperature_calls_update
      api_client = FakeApiClient.new
      LightMeUp::SettingsUpdate.new(api_client, { temperature: 60 }).perform

      assert_equal :update, api_client.last_call
      assert_equal({ temperature: 60 }, api_client.last_args)
    end

    def test_multiple_settings_calls_update
      api_client = FakeApiClient.new
      LightMeUp::SettingsUpdate.new(api_client, { on: true, brightness: 80, temperature: 60 }).perform

      assert_equal :update, api_client.last_call
      assert_equal({ on: true, brightness: 80, temperature: 60 }, api_client.last_args)
    end

    def test_no_options_raises_error
      assert_raises(LightMeUp::SettingsUpdate::InvalidOptions) do
        LightMeUp::SettingsUpdate.new(FakeApiClient.new, {}).perform
      end
    end

    def test_ignores_non_settings_options
      assert_raises(LightMeUp::SettingsUpdate::InvalidOptions) do
        LightMeUp::SettingsUpdate.new(FakeApiClient.new, { ip_address: "1.2.3.4" }).perform
      end
    end

    class FakeApiClient
      attr_reader :last_call, :last_args

      def toggle(**kwargs)
        @last_call = :toggle
        @last_args = kwargs
      end

      def update(**kwargs)
        @last_call = :update
        @last_args = kwargs
      end
    end
  end
end
