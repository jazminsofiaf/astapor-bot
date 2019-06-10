require 'telegram/bot'
require_relative '../lib/message_handler'
require_relative 'guarani_client'
require 'telegram/bot'

DEFAULT_MESSAGE = 'Perdon! No se como ayudarte con eso, prueba preguntando de otra forma!'.freeze

class Routes
  include MessageHandler

  on_message '/start' do |bot, message|
    response = GuaraniClient.new.welcome_message
    bot.api.send_message(chat_id: message.chat.id, text: "#{response} #{message.from.first_name}")
  end

  on_message '/oferta_academica' do |bot, message|
    key_board = [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Algebra', callback_data: 7514),
                 Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Analisis', callback_data: 7515)]
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: key_board)

    bot.api.send_message(chat_id: message.chat.id, text: 'Oferta academica', reply_markup: markup)
  end

  on_response_to 'Quien se queda con el trono?' do |bot, message|
    response = Tv::Series.handle_response message.data
    bot.api.send_message(chat_id: message.message.chat.id, text: response)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: DEFAULT_MESSAGE)
  end
end
