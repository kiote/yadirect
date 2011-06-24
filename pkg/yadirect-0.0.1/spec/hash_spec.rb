#encoding: utf-8
require 'spec_helper'
require 'hash'

describe Hash do
  it "should return camelize keys of hash" do
    hash = {:name => "Таня", :last_name => "Сенникова", 
            :options => {:size => 3, :smlie => {:form_face => "Cool"}}}
    camelize_hash = hash.camelize_keys
    puts camelize_hash
  end
end

