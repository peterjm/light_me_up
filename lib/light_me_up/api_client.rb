require 'net/http'
require 'json'

module LightMeUp
  class ApiClient
    DEFAULT_PORT = 9123
    LIGHTS_PATH = "/elgato/lights"
    OPEN_TIMEOUT = 2 # seconds
    READ_TIMEOUT = 2 # seconds

    def initialize(ip_address:, port: DEFAULT_PORT)
      raise Error, "No ip_address specified." unless ip_address && ip_address != ""
      @ip_address = ip_address
      @port = port
    end

    def status
      response = get(lights_uri)
      LightSerializer.deserialize(response).first
    end

    def toggle
      with_connection do |http|
        current_status = status

        if current_status.on
          turn_light_off
        else
          turn_light_on
        end
      end
    end

    def set(on: nil, brightness: nil, temperature: nil)
      update_light(Light.new(on: on, brightness: brightness, temperature: temperature))
    end

    def turn_light_on
      set(on: true)
    end

    def turn_light_off
      set(on: false)
    end

    def set_brightness(brightness)
      set(brightness: brightness)
    end

    def set_temperature(temperature)
      set(temperature: temperature)
    end

    private

    attr_reader :ip_address, :port, :connection

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
        lights: lights.map { |l| LightSerializer.serialize(l) }
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

    def with_connection
      Net::HTTP.start(ip_address, port, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |connection|
        @connection = connection
        yield
      end
    rescue Errno::EHOSTDOWN, Net::OpenTimeout
      raise Error, "Couldn't connect to lights."
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
      request['Content-Type'] = "application/json"
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
