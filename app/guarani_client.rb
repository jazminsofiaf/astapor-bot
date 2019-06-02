require 'faraday'
class GuaraniClient
  GUARANI_URL = 'https://reqres.in/api'.freeze
  WELCOME_PATH = 'users/2'.freeze
  def welcome_message
    connection = Faraday.new(url: GUARANI_URL)
    response = connection.get WELCOME_PATH
    response.body
  end
end
