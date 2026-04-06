# frozen_string_literal: true

require "test_helper"

module LightMeUp
  class ApiClientTest < Minitest::Test
    def test_requires_ip_address
      error = assert_raises(LightMeUp::Error) do
        LightMeUp::ApiClient.new(ip_address: nil)
      end
      assert_equal "No ip_address specified.", error.message
    end

    def test_requires_non_empty_ip_address
      error = assert_raises(LightMeUp::Error) do
        LightMeUp::ApiClient.new(ip_address: "")
      end
      assert_equal "No ip_address specified.", error.message
    end

    def test_status_returns_light
      json = { "numberOfLights" => 1, "lights" => [{ "on" => 1, "brightness" => 50, "temperature" => 200 }] }
      client = build_client(get_response: success_response(json))

      light = client.status

      assert light.on
      assert_equal 50, light.brightness
    end

    def test_update_sends_put_request
      json = { "numberOfLights" => 1, "lights" => [{ "on" => 1, "brightness" => 75, "temperature" => 200 }] }
      client = build_client(put_response: success_response(json))

      light = client.update(on: true, brightness: 75)

      assert light.on
      assert_equal 75, light.brightness
    end

    def test_turn_light_on
      json = { "numberOfLights" => 1, "lights" => [{ "on" => 1, "brightness" => 50, "temperature" => 200 }] }
      client = build_client(put_response: success_response(json))

      light = client.turn_light_on

      assert light.on
    end

    def test_turn_light_off
      json = { "numberOfLights" => 1, "lights" => [{ "on" => 0, "brightness" => 50, "temperature" => 200 }] }
      client = build_client(put_response: success_response(json))

      light = client.turn_light_off

      refute light.on
    end

    def test_toggle_from_on_to_off
      status_json = { "numberOfLights" => 1, "lights" => [{ "on" => 1, "brightness" => 50, "temperature" => 200 }] }
      update_json = { "numberOfLights" => 1, "lights" => [{ "on" => 0, "brightness" => 50, "temperature" => 200 }] }
      client = build_client(get_response: success_response(status_json), put_response: success_response(update_json))

      light = client.toggle

      refute light.on
    end

    def test_toggle_from_off_to_on
      status_json = { "numberOfLights" => 1, "lights" => [{ "on" => 0, "brightness" => 50, "temperature" => 200 }] }
      update_json = { "numberOfLights" => 1, "lights" => [{ "on" => 1, "brightness" => 50, "temperature" => 200 }] }
      client = build_client(get_response: success_response(status_json), put_response: success_response(update_json))

      light = client.toggle

      assert light.on
    end

    def test_host_down_raises_friendly_error
      client = build_client(error: Errno::EHOSTDOWN)

      error = assert_raises(LightMeUp::Error) do
        client.status
      end
      assert_equal "Couldn't connect to lights.", error.message
    end

    def test_timeout_retries_then_raises
      client = build_client(error: Net::OpenTimeout, retries: 1)

      error = assert_raises(LightMeUp::Error) do
        client.status
      end
      assert_equal "Timeout connecting to lights.", error.message
    end

    def test_http_error_raises
      response = Net::HTTPInternalServerError.new("1.1", "500", "Internal Server Error")
      response.instance_variable_set(:@read, true)
      response.body = "something went wrong"
      client = build_client(get_response: response)

      assert_raises(LightMeUp::Error) do
        client.status
      end
    end

    private

    def build_client(get_response: nil, put_response: nil, error: nil, retries: 0)
      client = LightMeUp::ApiClient.new(ip_address: "192.168.1.100", retries: retries)
      stub_http = build_stub_http(get_response: get_response, put_response: put_response, error: error,
                                  retries: retries)

      client.define_singleton_method(:start_connection) do |&block|
        @connection = stub_http
        block.call
      ensure
        @connection = nil
      end

      client
    end

    def build_stub_http(get_response: nil, put_response: nil, error: nil, retries: 0)
      stub_http = Object.new

      if error
        total_attempts = retries + 1
        attempt = 0
        stub_http.define_singleton_method(:request) do |_req|
          attempt += 1
          raise error if attempt <= total_attempts
        end
      else
        responses = []
        responses << get_response if get_response
        responses << put_response if put_response
        stub_http.define_singleton_method(:request) do |_req|
          responses.shift
        end
      end

      stub_http
    end

    def success_response(json)
      response = Net::HTTPSuccess.new("1.1", "200", "OK")
      response.instance_variable_set(:@read, true)
      response.body = json.to_json
      response.content_type = "application/json"
      response
    end
  end
end
