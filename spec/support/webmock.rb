# frozen_string_literal: true

require 'webmock/rspec'

RSpec.configure do |config|
  ##
  # Use WebMock to mock network connections. To temporarily re-enable network
  # connections within tests, toggle the WebMock.disable_net_connect! /
  # WebMock.enable_net_connect! setting.
  # Allow connections to local services / localhost
  allowed_sites = ['localhost', 'chromedriver.storage.googleapis.com', '127.0.0.1', 'github.com',
                   'objects.githubusercontent.com']

  # Add net_http_connect_on_start: true, to fix intermittent errors:
  #        "Failed to open TCP connection ... Too many open files"
  # https://stackoverflow.com/a/65946077
  # https://github.com/bblimke/webmock#connecting-on-nethttpstart
  WebMock.disable_net_connect!(allow: allowed_sites, net_http_connect_on_start: true)
  # WebMock.enable_net_connect!

  config.before(:each) do
    stub_request(:get, 'https://api.orcid.org/v3.0/apiStatus')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200,
                 body: '{"tomcatUp":true,"dbConnectionOk":true,"readOnlyDbConnectionOk":true,"overallOk":true}',
                 headers: {})
  end
end
