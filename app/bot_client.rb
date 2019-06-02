require 'telegram/bot'
class BotClient
  def initialize(token = ENV['TELEGRAM_TOKEN'])
    @token = token
  end

  def run
    Telegram::Bot::Client.run(@token) do |bot|
      bot.fetch_updates do |message|
        bot.api.send_message(chat_id: message.chat.id,
                             text: "Hola #{message.from.first_name}")
      end
    end
  end
end
