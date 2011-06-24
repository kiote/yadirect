require 'string'

class Hash
  def camelize_keys
    hash = {}
    self.each do |k, v| 
      key = k.to_s.to_camelcase
      value = v.is_a?(Hash) ? v.camelize_keys : v
      hash.store(key, value)
    end
    return hash
  end
end
