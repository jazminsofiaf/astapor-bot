require 'telegram/bot'
require_relative '../lib/message_handler'
require_relative 'guarani_client'
require 'telegram/bot'

DEFAULT_MESSAGE = 'Perdon! No se como ayudarte con eso, prueba preguntando de otra forma!'.freeze
EMPTY_COURSES_MSG = 'No hay materias disponibles'.freeze
BOOKS = '\U0001F4DA'.freeze
class Routes
  include MessageHandler

  on_message '/start' do |bot, message|
    response = GuaraniClient.new.welcome_message
    bot.api.send_message(chat_id: message.chat.id,
                         text: "#{response} #{message.from.first_name} #{BOOKS.encode('utf-8')}")
  end

  on_message '/oferta' do |bot, message|
    courses = GuaraniClient.new.courses(message.from.username)
    if courses.empty?
      bot.api.send_message(chat_id: message.chat.id, text: EMPTY_COURSES_MSG)
    else
      key_board = courses.map do |course|
        Telegram::Bot::Types::InlineKeyboardButton.new(text: course.name, callback_data: course.code.to_s)
      end

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: key_board)

      bot.api.send_message(chat_id: message.chat.id, text: 'Oferta academica', reply_markup: markup)
    end
  end

  on_response_to 'Oferta academica' do |bot, message|
    puts "response to oferta academica: #{message.data}"
    student_name = message.from.first_name + ' ' + message.from.last_name

    response = Astapor::Course.handle_response(student_name, message.from.username, message.data)
    bot.api.send_message(chat_id: message.message.chat.id, text: response)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: DEFAULT_MESSAGE)
  end
end
