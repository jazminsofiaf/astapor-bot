require_relative 'guarani_client'
class MessageHandler
  def initialize
    @guarani_client = GuaraniClient.new
  end

  def handle(message, bot)
    case message.text
    when '/start'
      response = @guarani_client.welcome_message
      bot.api.send_message(chat_id: message.chat.id, text: "#{response} #{message.from.first_name}")
    end
  end
end
