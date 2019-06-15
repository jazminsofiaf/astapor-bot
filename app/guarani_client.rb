require 'faraday'
require 'json'
require 'telegram/bot'
require_relative '../app/models/course'
require_relative '../app/helpers/inscription'
require_relative '../app/helpers/response'
class GuaraniClient
  GUARANI_URL = 'https://astapor-api.herokuapp.com'.freeze
  WELCOME_PATH = '/welcome_message'.freeze
  COURSE_PATH = '/materias'.freeze
  INSCRIPTION_PATH = '/alumnos'.freeze

  SUBJECT_KEY = 'nombre'.freeze
  TEACHER_KEY = 'docente'.freeze
  CODE_KEY = 'codigo'.freeze
  OFFER_KEY = 'oferta'.freeze
  CONTENT_TYPE = 'Content-Type'.freeze
  APPLICATION_JSON = 'application/json'.freeze

  def initialize
    @logger = Logger.new(STDOUT)
  end

  def welcome_message
    connection = Faraday.new(url: GUARANI_URL)
    response = connection.get WELCOME_PATH
    response.body
  end

  def courses(user_name)
    connection = Faraday.new(url: GUARANI_URL)
    response = connection.get COURSE_PATH, usernameAlumno: user_name
    courses = JSON.parse(response.body)[OFFER_KEY]
    courses.map { |course| Astapor::Course.new(course[SUBJECT_KEY], course[TEACHER_KEY], course[CODE_KEY]) }
  end

  def inscribe(name, username, code)
    inscription_body = Inscription.new.body(name, username, code)
    @logger.debug "body inscription: #{inscription_body}"
    connection = Faraday.new(url: GUARANI_URL)
    response = connection.post do |req|
      req.url INSCRIPTION_PATH
      req.headers[CONTENT_TYPE] = APPLICATION_JSON
      req.body = inscription_body
    end
    Response.new(response.body).msg
  end
end
