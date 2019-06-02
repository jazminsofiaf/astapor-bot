require 'telegram/bot'
require_relative 'message_handler'
class BotClient
  def initialize(token = ENV['TELEGRAM_TOKEN'])
    @token = token
    @logger = Logger.new(STDOUT)
    @guarani = GuaraniClient.new
  end

  def handle_message(message, bot)
    @logger.debug "@#{message.from.username}: #{message.inspect}"
    MessageHandler.new.handle(message, bot)
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
