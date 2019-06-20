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

  offers = '{"oferta":[{"nombre":"Algo3","codigo":7507,"docente":"Fontela","cupo":50,"cupo_disponible":35,"modalidad":"parciales"},
  {"nombre":"TDD","codigo":7510,"docente":"Emilio","cupo":60,"cupo_disponible":50,"modalidad":"coloquio"}]}'
  inscriptions = '{"inscripciones":[{"nombre":"Algo3","codigo":7507,"docente":"Fontela","cupo":50,"modalidad":"parciales"},
  {"nombre":"TDD","codigo":7510,"docente":"Emilio","cupo":60,"modalidad":"coloquio"}]}'
  average = '{"materias_aprobadas":2,"nota_promedio":8}'

  algo3 = Astapor::Course.new('Algo3', 'Fontela', 7507, 35)
  tdd = Astapor::Course.new('TDD', 'Emilio', 7510, 50)

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

  it 'should return list of courses where the student is inscribed' do
    mock_get_request('https://astapor-api.herokuapp.com/inscripciones?usernameAlumno=jaz', inscriptions)
    inscriptions = GuaraniClient.new.inscriptions('jaz')
    expect(inscriptions).to eq [algo3, tdd]
  end

  context 'when there are no inscriptions done by the student' do
    it 'should return empty list' do
      mock_get_request('https://astapor-api.herokuapp.com/inscripciones?usernameAlumno=jaz', '{"inscripciones":[]}')
      inscriptions = GuaraniClient.new.inscriptions('jaz')
      expect(inscriptions).to eq []
    end
  end

  it 'should return a 2 and an 8 when the amount of approved courses is 2 and the total average is 8' do
    mock_get_request('https://astapor-api.herokuapp.com/alumnos/promedio?usernameAlumno=jaz', average)
    amount_approved, average = GuaraniClient.new.grades_average('jaz')
    expect(amount_approved).to eq 2
    expect(average).to eq 8
  end

  it 'should return error message if sth goes wrong' do
    mock_get_request('https://astapor-api.herokuapp.com/materias/estado?codigoMateria=1001&usernameAlumno=jaz',
                     { error: 'MATERIA_NO_EXISTE' }.to_json)
    result_msg = GuaraniClient.new.state('jaz', '1001')
    expect(result_msg).to eq("Opsi, esa materia no existe  \u{1F616}")
  end

  it 'should return pass status for course' do
    mock_get_request('https://astapor-api.herokuapp.com/materias/estado?codigoMateria=1001&usernameAlumno=jaz',
                     { estado: 'APROBADO', nota_final: 10 }.to_json)
    result_msg = GuaraniClient.new.state('jaz', '1001')
    expect(result_msg).to eq("Felicitaciones \u{1F44D} aprobaste con un 10")
  end

  it 'should return fail status for course' do
    mock_get_request('https://astapor-api.herokuapp.com/materias/estado?codigoMateria=1001&usernameAlumno=jaz',
                     { estado: 'DESAPROBADO', nota_final: 5 }.to_json)
    result_msg = GuaraniClient.new.state('jaz', '1001')
    expect(result_msg).to eq("Uy \u{1F44E} desaprobaste con un 5")
  end

  it 'should return not enrolled in' do
    mock_get_request('https://astapor-api.herokuapp.com/materias/estado?codigoMateria=1001&usernameAlumno=jaz',
                     { estado: 'NO_INSCRIPTO', nota_final: nil }.to_json)
    result_msg = GuaraniClient.new.state('jaz', '1001')
    expect(result_msg).to eq('No estas inscripto')
  end

  it 'should return on going' do
    mock_get_request('https://astapor-api.herokuapp.com/materias/estado?codigoMateria=1001&usernameAlumno=jaz',
                     { estado: 'EN_CURSO', nota_final: 'null' }.to_json)
    result_msg = GuaraniClient.new.state('jaz', '1001')
    expect(result_msg).to eq('La estas cursando')
  end
end
