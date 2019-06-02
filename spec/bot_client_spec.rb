require 'webmock/rspec'
require_relative '../app/bot_client'

def get_updates(token, text_message)
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

def moke_get_request(url, response)
  stub_request(:get, url)
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v0.15.4'
      }
    )
    .to_return(status: 200, body: response, headers: {})
end

describe 'BotClient' do
  it 'should get a /start message and respond with Hola ' do
    get_updates('fake_token', '/start')
    moke_get_request('https://reqres.in/api/users/2', 'Hola')
    send_message('fake_token', 'Hola Jazmin')
    app = BotClient.new('fake_token')
    app.run_once
  end
end
