require 'faraday'
class GuaraniClient
  GUARANI_URL = 'https://astapor-api.herokuapp.com'.freeze
  WELCOME_PATH = '/welcome_message'.freeze
  def welcome_message
    connection = Faraday.new(url: GUARANI_URL)
    response = connection.get WELCOME_PATH
    response.body
  end
end
