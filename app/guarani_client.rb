require 'faraday'
class GuaraniClient
  def welcome_message
    connection = Faraday.new(url: 'https://reqres.in/api')
    response = connection.get 'users/2'
    response.body
  end
end
