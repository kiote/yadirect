require 'curb'
require 'json'
require 'hashit'
require 'api_error'
require 'hash'
require 'string'

module Yadirect
  class Proxy
    EP_YANDEX_DIRECT_V4 = 'https://soap.direct.yandex.ru/json-api/v4/'

    def initialize params
      @params = params
      @locale = 'RU' || params[:locale]
    end

    def invoke method, args = {}
      json_object = {:method => method, :locale => @locale, :param => args}.to_json
      c = Curl::Easy.http_post(EP_YANDEX_DIRECT_V4, json_object) do |curl|
        curl.cacert = @params[:cacert]
        curl.certtype = "PEM"
        curl.cert_key = @params[:cert_key]
        curl.cert = @params[:cert]
        curl.headers['Accept'] = 'application/json'
        curl.headers['Content-Type'] = 'application/json'
        curl.headers['Api-Version'] = '2.2'
        curl.verbose = true if @params[:debug] == true
      end

      hash =  JSON.parse(c.body_str)

      if(hash.include?("error_code"))
        raise Yadirect::ApiError, hash
      else
        object_result = Hashit.new(hash)
        object_result.data
      end
    end

    def method_missing(name, *args, &block)
      ya_params = to_hash_params(*args)
      invoke(name.to_s.to_camelcase, ya_params)
    end

    def to_hash_params *args
      return {} if args.empty?
      first_arg = args.shift
      first_arg.is_a?(Hash) ? first_arg.camelize_keys : args
    end
  end
end
