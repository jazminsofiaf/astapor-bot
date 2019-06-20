require 'telegram/bot'
require_relative '../lib/message_handler'
require_relative 'guarani_client'
require 'telegram/bot'
require_relative '../app/helpers/emoji'
require 'json'
require_relative '../app/helpers/astapor_api_error'

DEFAULT_MESSAGE = "Perdon! No se como ayudarte con eso #{Emoji.code(:speak_no_evil)}" \
                   'prueba preguntando de otra forma!'.freeze
EMPTY_COURSES_MSG = 'No hay materias disponibles'.freeze

EMPTY_INSCRIPTIONS_MSG = 'No hay inscripciones realizadas en este momento'.freeze

INSCRIPTIONS_MSG = 'Inscripciones realizadas:'.freeze

APPROVED_COURSES_MSG = 'Cantidad de materias aprobadas '.freeze

GRADES_AVERAGE_MSG = ', promedio general '.freeze

DEFAULT_ERROR_MESSAGE = 'Hubo un error'.freeze

ERROR_MSG = { JSON::ParserError => 'OUps no se como leer el mensaje de la api',
              AstaporApiError => 'Hubo un error en la api',
              StandardError => 'Oups, ocurrió un error' }.freeze

class Routes
  include MessageHandler

  on_message '/start' do |bot, message|
    response = GuaraniClient.new(bot.api.token).welcome_message
    bot.api.send_message(chat_id: message.chat.id,
                         text: "#{response} #{message.from.first_name} #{Emoji.code(:books)}")
  end

  on_message '/oferta' do |bot, message|
    courses = GuaraniClient.new(bot.api.token).courses(message.from.username)
    if courses.empty?
      bot.api.send_message(chat_id: message.chat.id, text: EMPTY_COURSES_MSG)
    else
      key_board = courses.map do |course|
        Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{course.name} (cupos disponibles: #{course.available_quota})",
                                                       callback_data: course.code.to_s)
      end

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: key_board)

      bot.api.send_message(chat_id: message.chat.id, text: 'Oferta academica', reply_markup: markup)
    end
  end

  on_message '/inscripciones' do |bot, message|
    inscriptions = GuaraniClient.new(bot.api.token).inscriptions(message.from.username)
    if inscriptions.empty?
      bot.api.send_message(chat_id: message.chat.id, text: EMPTY_INSCRIPTIONS_MSG)
    else
      msg = INSCRIPTIONS_MSG
      inscriptions.each do |course|
        msg += " #{course.name},"
      end
      bot.api.send_message(chat_id: message.chat.id, text: msg[0...msg.length - 1])
    end
  end

  on_message '/estado' do |bot, message|
    params = message.text.split(' ')
    code_index = 1
    puts "params #{params}"
    if params.length < (code_index + 1)
      bot.api.send_message(chat_id: message.chat.id, text: 'te falto el codigo de materia')
      return
    end
    puts "el indice es #{code_index}"
    course_code = message.text.split(' ')[code_index]
    puts "El curso es #{course_code}"
    response = GuaraniClient.new(bot.api.token).state(message.from.username, course_code)
    bot.api.send_message(chat_id: message.chat.id, text: response)
  end

  on_message '/promedio' do |bot, message|
    amount_approved, average = GuaraniClient.new(bot.api.token).grades_average(message.from.username)
    if amount_approved.zero?
      bot.api.send_message(chat_id: message.chat.id, text: APPROVED_COURSES_MSG + amount_approved.to_s)
    else
      bot.api.send_message(chat_id: message.chat.id, text: APPROVED_COURSES_MSG + amount_approved.to_s + GRADES_AVERAGE_MSG + average.to_s)
    end
  end

  on_response_to 'Oferta academica' do |bot, message|
    puts "response to oferta academica: #{message.data}"
    student_name = message.from.first_name + ' ' + message.from.last_name

    response = Astapor::Course.handle_response(bot.api.token, student_name, message.from.username, message.data)
    bot.api.send_message(chat_id: message.message.chat.id, text: response)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: DEFAULT_MESSAGE)
  end

  on_error do |bot, message, error|
    error_msg = ERROR_MSG[error.class] ||  DEFAULT_ERROR_MESSAGE
    bot.api.send_message(chat_id: message.chat.id, text: error_msg)
  end
end
