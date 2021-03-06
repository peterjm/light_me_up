# frozen_string_literal: true

require "net/http"
require "json"

module LightMeUp
  class ApiClient # rubocop:disable Metrics/ClassLength
    DEFAULT_PORT = 9123
    LIGHTS_PATH = "/elgato/lights"
    OPEN_TIMEOUT = 2 # seconds
    READ_TIMEOUT = 2 # seconds
    MAX_RETRIES = 2

    TEMPERATURE_RANGE = (143..344).freeze

    def initialize(ip_address:, retries: MAX_RETRIES, port: DEFAULT_PORT)
      raise Error, "No ip_address specified." unless ip_address && ip_address != ""

      @ip_address = ip_address
      @port = port
      @max_retries = retries
    end

    def status
      response = get(lights_uri)
      LightSerializer.deserialize(response).first
    end

    def toggle(brightness: nil, temperature: nil)
      with_connection do |_http|
        current_status = status

        if current_status.on
          update(on: false, brightness: brightness, temperature: temperature)
        else
          update(on: true, brightness: brightness, temperature: temperature)
        end
      end
    end

    def update(on: nil, brightness: nil, temperature: nil)
      update_light(Light.new(on: on, brightness: brightness, temperature: temperature))
    end

    def turn_light_on
      update(on: true)
    end

    def turn_light_off
      update(on: false)
    end

    def update_brightness(brightness)
      update(brightness: brightness)
    end

    def update_temperature(temperature)
      update(temperature: temperature)
    end

    private

    attr_reader :ip_address, :port, :connection, :max_retries

    def lights_uri
      URI::HTTP.build(host: ip_address, port: port, path: LIGHTS_PATH)
    end

    def update_light(settings)
      response = put(lights_uri, build_light_configuration_data([settings]))
      LightSerializer.deserialize(response).first
    end

    def build_light_configuration_data(lights)
      {
        numberOfLights: lights.size,
        lights: lights.map { |l| LightSerializer.serialize(l) },
      }
    end

    def get(uri)
      perform_request(:get, uri)
    end

    def put(uri, data = {})
      perform_request(:put, uri) do |request|
        request.body = data.to_json
      end
    end

    def connected?
      !!@connection
    end

    def with_connection(&block)
      retries = 0
      begin
        start_connection(&block)
      rescue Errno::EHOSTDOWN
        raise Error, "Couldn't connect to lights."
      rescue Net::OpenTimeout
        raise Error, "Timeout connecting to lights." if retries >= max_retries

        retries += 1
        retry
      end
    end

    def start_connection
      Net::HTTP.start(ip_address, port, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |connection|
        @connection = connection
        yield
      end
    ensure
      @connection = nil
    end

    def perform_request(method, uri, &block)
      if connected?
        perform_request_with_connection(method, uri, &block)
      else
        with_connection do
          perform_request_with_connection(method, uri, &block)
        end
      end
    end

    def perform_request_with_connection(method, uri, &block)
      request = build_request(method, uri)
      request["Content-Type"] = "application/json"
      block.call(request) if block_given?
      response = connection.request(request)

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      else
        raise Error, response.body
      end
    end

    def build_request(method, uri)
      case method
      when :get
        Net::HTTP::Get.new(uri)
      when :put
        Net::HTTP::Put.new(uri)
      else
        raise ArgumentError, "unhandled method type: #{method}"
      end
    end
  end
end
