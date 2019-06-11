require 'webmock/rspec'
require_relative '../app/guarani_client'
require_relative '../app/models/course'

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
    mock_request('https://astapor-api.herokuapp.com/welcome_message', 'hola')
    guarani_client = GuaraniClient.new
    welcome_message = guarani_client.welcome_message
    expect(welcome_message).to eq 'hola'
  end

  offer = '{"oferta":[{"nombre":"Algo3","codigo":7507,"docente":"Fontela","cupo":50,"modalidad":"parciales"},{"nombre":"TDD","codigo":7510,"docente":"Emilio","cupo":60,"modalidad":"coloquio"}]}'

  algo3 = Course.new('Algo3', 'Fontela', 7507)
  tdd = Course.new('TDD', 'Emilio', 7510)

  it 'should return list of courses' do
    mock_request('https://astapor-api.herokuapp.com/materias', offer)
    courses = GuaraniClient.new.courses
    expect(courses).to eq [algo3, tdd]
  end
end
