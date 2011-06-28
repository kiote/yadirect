#encoding: utf-8
require 'spec_helper'
require 'yadirect'
require 'json'

describe Yadirect::Proxy do

  before(:all) do
    cert_dir = '/home/sashich/cert'
    cert_key = File.join(cert_dir, 'private.key')
    cacert = File.join(cert_dir, 'cacert.pem')
    cert = File.join(cert_dir, 'cert.crt')
    params  = {:cert_key => cert_key, :cacert => cacert, :cert => cert}

    puts params.inspect
    @proxy = Yadirect::Proxy.new(params)
  end

  it "PingAPI" do
    result = @proxy.ping_api
    result.should == 1
  end

  it "GetKeywordsSuggestion" do
    suggestions = @proxy.get_keywords_suggestion(:keywords => ["недвижимость"])
    suggestions.should_not be nil
    suggestions.empty?.should be false
  end

  it "GetRegions" do
    regions = @proxy.get_regions
    regions.should_not be nil
    regions.empty?.should be false
  end

  it "GetCampaignsList" do
    campaigns = @proxy.get_campaigns_list "mr.sashich"
    campaigns.should_not be nil
    campaigns.empty?.should be false
  end

  it "GetWordstatReportList" do
    list = @proxy.get_wordstat_report_list
    list.should_not be nil
    list.empty?.should be false
  end

  it "GetBanners" do
    banners = @proxy.get_banners :campaign_ids=>[2929027]
    banners.should_not be nil
    banners.empty?.should be false
  end


end
