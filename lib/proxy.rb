# encoding: utf-8
require 'curb'
require 'json'
require 'hashit'
require 'api_error'
require 'hash'
require 'string'

module Yadirect
  class Proxy
    EP_YANDEX_DIRECT_V4 = {
        :v4      => 'https://soap.direct.yandex.ru/json-api/v4/',
        :v4_live => 'https://soap.direct.yandex.ru/live/v4/json/'
    }
    attr_accessor :debug, :locale

    def initialize params, version = :v4_live
      @params = params
      @locale = 'RU' || params[:locale]
      @debug = false || params[:debug]
      @version = version
    end

    def invoke method, args = {}
      json_object = {:method => method, :locale => @locale, :param => args}.to_json
      # из-за того, что яндекс не принимает закодированные UTF-строки, по крайней мере в CreateWordstatCollect
      # приходится их раскодировать обратно
      json_object.gsub!(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}

      puts "yadirect input: #{json_object}" if @debug
      c = Curl::Easy.http_post(EP_YANDEX_DIRECT_V4[@version], json_object) do |curl|
        curl.cacert = @params[:cacert]
        curl.certtype = "PEM"
        curl.cert_key = @params[:cert_key]
        curl.cert = @params[:cert]
        curl.headers['Accept'] = 'application/json'
        curl.headers['Content-Type'] = 'application/json'
        curl.headers['Api-Version'] = '2.2'
      end

      hash =  JSON.parse(c.body_str)
      puts "yadirect output: #{hash}" if @debug

      if (hash.include?("error_code"))
        raise Yadirect::ApiError, hash
      else
        object_result = Hashit.new(hash)
        object_result.data
      end
    end

    def method_missing(name, *args, &block)
      ya_params = to_hash_params(*args)
      object = invoke(name.to_s.to_camelcase, ya_params)
    end

    def to_hash_params *args
      return {} if args.empty?
      params = args.first[:params]
      return params.is_a?(Hash) ? params.camelize_keys : 
         params.is_a?(Array) ? params.flatten : params
    end

  end
end