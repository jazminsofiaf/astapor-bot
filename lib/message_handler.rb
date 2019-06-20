require_relative '../app/guarani_client'
require_relative '../app/helpers/astapor_api_error'
module MessageHandler
  @message_handlers = {}
  @callback_query_handlers = {}

  DEFAULT = '_default_handler_'.freeze
  ERROR = '_error_handler_'.freeze
  CODE = 0

  # module methods
  def self.message_handlers
    @message_handlers
  end

  def self.callback_query_handlers
    @callback_query_handlers
  end

  # called when the module is included
  def self.included(clazz)
    # adding class methods
    clazz.extend ClazzMethods
  end

  def handle(bot, message)
    # instance methods of any class that include it
    handler = find_handler_for(message) || default_handler(message)
    begin
      handler.call(bot, message)
    rescue StandardError => e
      puts e.msg
      error_handle(e).call(bot, message, e)
    end
  end

  module ClazzMethods
    # class methods of any class that include it
    def on_message(expected_message, &block)
      MessageHandler.message_handlers[expected_message] = block
    end

    def on_response_to(expected_message, &block)
      MessageHandler.callback_query_handlers[expected_message] = block
    end

    def default(&block)
      MessageHandler.message_handlers[DEFAULT] = block
    end

    def on_error(&block)
      MessageHandler.message_handlers[ERROR] = block
    end
  end

  def first_word(phrase)
    phrase.split(' ')[CODE]
  end

  private

  def find_handler_for(message)
    case message
    when Telegram::Bot::Types::Message
      MessageHandler.message_handlers[first_word(message.text)]
    when Telegram::Bot::Types::CallbackQuery
      MessageHandler.callback_query_handlers[message.message.text]
    end
  end

  def default_handler(message)
    MessageHandler.message_handlers[DEFAULT] ||
      (raise "Unkown message [#{message.inspect}]. Please define new handler or a default handler")
  end

  def error_handle(error)
    MessageHandler.message_handlers[ERROR] ||
      (raise "Error [#{error.msg}] raise when handling message")
  end
end
