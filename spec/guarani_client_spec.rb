require 'webmock/rspec'
require_relative '../app/guarani_client'
require_relative '../app/models/course'

describe 'Guarani' do
  def mock_get_request(guarani_url, response)
    stub_request(:get, guarani_url)
      .to_return(status: 200, body: response, headers: {})
  end

  def mock_post_request(guarani_url, body, response)
    stub_request(:post, guarani_url)
      .with(body: body)
      .to_return(status: 200, body: response, headers: {})
  end

  it 'should return welcome message' do
    mock_get_request('https://astapor-api.herokuapp.com/welcome_message', 'hola')
    guarani_client = GuaraniClient.new
    welcome_message = guarani_client.welcome_message
    expect(welcome_message).to eq 'hola'
  end

  offers = '{"oferta":[{"nombre":"Algo3","codigo":7507,"docente":"Fontela","cupo":50,"modalidad":"parciales"},{"nombre":"TDD","codigo":7510,"docente":"Emilio","cupo":60,"modalidad":"coloquio"}]}'

  algo3 = Astapor::Course.new('Algo3', 'Fontela', 7507)
  tdd = Astapor::Course.new('TDD', 'Emilio', 7510)

  it 'should return list of courses' do
    mock_get_request('https://astapor-api.herokuapp.com/materias?usernameAlumno=jaz', offers)
    courses = GuaraniClient.new.courses('jaz')
    expect(courses).to eq [algo3, tdd]
  end

  context 'when there is no offer available' do
    it 'should return empty list' do
      mock_get_request('https://astapor-api.herokuapp.com/materias?usernameAlumno=jaz', '{"oferta":[]}')
      courses = GuaraniClient.new.courses('jaz')
      expect(courses).to eq []
    end
  end

  it 'should make an inscription' do
    body = { 'nombre_completo' => 'Jazmin Ferreiro',
             'codigo_materia' => 1234,
             'username_alumno' => 'jaz2' }.to_json
    success = { "resultado": 'inscripcion_creada' }.to_json
    mock_post_request('https://astapor-api.herokuapp.com/alumnos', body, success)
    result_msg = GuaraniClient.new.inscribe('Jazmin Ferreiro', 'jaz2', 1234)
    expect(result_msg).to eq('inscripcion_creada')
  end
end
