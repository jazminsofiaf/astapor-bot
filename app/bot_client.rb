require 'telegram/bot'
class BotClient
  def initialize(token = ENV['TELEGRAM_TOKEN'])
    @token = token
    @logger = Logger.new(STDOUT)
  end

  def handle_message(message, bot)
    @logger.debug "@#{message.from.username}: #{message.inspect}"
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hola #{message.from.first_name}")
    end
  end

  def run_once
    run_client do |bot|
      bot.fetch_updates { |message| handle_message(message, bot) }
    end
  end

  def start
    @logger.info "token is #{@token}"
    run_client do |bot|
      bot.listen { |message| handle_message(message, bot) }
    end
  end

  def run_client(&block)
    Telegram::Bot::Client.run(@token, logger: @logger) { |bot| block.call bot }
  end
end
