require 'rspec'
require_relative '../app/guarani_client'

describe 'Guarani' do
  def mock_request(guarani_url, body)
    stub_request(:get, guarani_url)
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Faraday v0.15.4'
        }
      )
      .to_return(status: 200, body: body, headers: {})
  end

  it 'should return welcome message' do
    mock_request('https://reqres.in/api/users/2', 'hola')
    guarani_client = GuaraniClient.new
    welcome_message = guarani_client.welcome_message
    expect(welcome_message).to eq 'hola'
  end
end
