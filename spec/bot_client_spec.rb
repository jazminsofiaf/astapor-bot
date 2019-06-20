require 'webmock/rspec'
require_relative '../app/bot_client'

def get_updates(token, text_message)
  body = { "ok": true, "result": [{ "update_id": 115_760_237,
                                    "message": { "message_id": 1,
                                                 "from": { "id": 201_878_053,
                                                           "is_bot": false,
                                                           "first_name": 'Jazmin',
                                                           "last_name": 'Ferreiro',
                                                           "username": 'jaz' },
                                                 "chat": { "id": 201_878_053,
                                                           "first_name": 'Jazmin',
                                                           "last_name": 'Ferreiro',
                                                           "type": 'private' },
                                                 "date": 1_559_434_401,
                                                 "text": text_message,
                                                 "entities": [{ "offset": 0,
                                                                "length": 6,
                                                                "type": 'bot_command' }] } }] }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def send_message(token, text_message)
  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: { 'chat_id' => '201878053', 'text' => text_message },
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => 'Faraday v0.15.4'
      }
    )
    .to_return(status: 200, body: ''.to_json, headers: {})
end

def mock_post_request(guarani_url, body, response)
  stub_request(:post, guarani_url)
    .with(body: body)
    .to_return(status: 200, body: response, headers: {})
end

def mock_get_request(url, response)
  stub_request(:get, url)
    .to_return(status: 200, body: response, headers: {})
end

def send_options(token, title, options)
  body = { "ok": true, "result": [{ "update_id": 115_760_237,
                                    "message": { "message_id": 1,
                                                 "from": { "id": 201_878_053,
                                                           "is_bot": false,
                                                           "first_name": 'Jazmin',
                                                           "last_name": 'Ferreiro' },
                                                 "chat": { "id": 201_878_053,
                                                           "first_name": 'Jazmin',
                                                           "last_name": 'Ferreiro',
                                                           "type": 'private' },
                                                 "date": 1_559_434_401,
                                                 "text": title,
                                                 "entities": [{ "offset": 0,
                                                                "length": 6,
                                                                "type": 'bot_command' }] } }] }

  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: {
        'chat_id' => '201878053',
        'reply_markup' => options,
        'text' => 'Oferta academica'
      }
    ).to_return(status: 200, body: body.to_json, headers: {})
end

describe 'BotClient' do
  it 'should get a /start message and respond with Hola ' do
    get_updates('fake_token', '/start')
    mock_get_request('https://astapor-api.herokuapp.com/welcome_message', 'Hola')
    send_message('fake_token', "Hola Jazmin \u{1F4DA}")
    app = BotClient.new('fake_token')
    app.run_once
  end

  it 'should get a /oferta message and respond with an inline keyboard' do
    token = 'fake_token'

    offer = '{"oferta":[{"nombre":"Algo3","codigo":7507,"docente":"Fontela","cupo":50,"cupo_disponible":35,"modalidad":"parciales"},
    {"nombre":"TDD","codigo":7510,"docente":"Emilio","cupo":60,"cupo_disponible":50,"modalidad":"coloquio"}]}'

    get_updates(token, '/oferta')
    mock_get_request('https://astapor-api.herokuapp.com/materias?usernameAlumno=jaz', offer)
    options = '{"inline_keyboard":[[{"text":"Algo3 (cupos disponibles: 35)","callback_data":"7507"}],[{"text":"TDD (cupos disponibles: 50)","callback_data":"7510"}]]}'
    send_options(token, 'Oferta academica', options)

    app = BotClient.new(token)

    app.run_once
  end

  context 'when there is no offer available' do
    it 'should return a message' do
      token = 'fake_token'

      offer = '{"oferta":[]}'

      get_updates(token, '/oferta')
      mock_get_request('https://astapor-api.herokuapp.com/materias?usernameAlumno=jaz', offer)

      send_message(token, 'No hay materias disponibles')

      app = BotClient.new(token)

      app.run_once
    end
  end

  it 'should get a /inscripciones message and respond with listed messages' do
    token = 'fake_token'

    inscriptions = '{"inscripciones":[{"nombre":"Algo3","codigo":7507,"docente":"Fontela","cupo":50,"modalidad":"parciales"},
    {"nombre":"TDD","codigo":7510,"docente":"Emilio","cupo":60,"modalidad":"coloquio"}]}'

    get_updates(token, '/inscripciones')
    mock_get_request('https://astapor-api.herokuapp.com/inscripciones?usernameAlumno=jaz', inscriptions)
    send_message(token, 'Inscripciones realizadas: Algo3, TDD')

    app = BotClient.new(token)

    app.run_once
  end

  context 'when there are no inscriptions done' do
    it 'should return a message' do
      token = 'fake_token'

      inscriptions = '{"inscripciones":[]}'

      get_updates(token, '/inscripciones')
      mock_get_request('https://astapor-api.herokuapp.com/inscripciones?usernameAlumno=jaz', inscriptions)

      send_message(token, 'No hay inscripciones realizadas en este momento')

      app = BotClient.new(token)

      app.run_once
    end
  end

  it 'should get a /promedio message and respond with a message' do
    token = 'fake_token'

    average = '{"materias_aprobadas":2,"nota_promedio":8}'

    get_updates(token, '/promedio')
    mock_get_request('https://astapor-api.herokuapp.com/alumnos/promedio?usernameAlumno=jaz', average)
    send_message(token, 'Cantidad de materias aprobadas 2, promedio general 8')

    app = BotClient.new(token)

    app.run_once
  end

  context 'when there are no approved courses' do
    it 'should return a message' do
      token = 'fake_token'

      average = '{"materias_aprobadas":0,"nota_promedio":"nil"}'

      get_updates(token, '/promedio')
      mock_get_request('https://astapor-api.herokuapp.com/alumnos/promedio?usernameAlumno=jaz', average)

      send_message(token, 'Cantidad de materias aprobadas 0')

      app = BotClient.new(token)

      app.run_once
    end
  end
end
