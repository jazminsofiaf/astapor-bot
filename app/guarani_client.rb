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
  INSCRIPTIONS_PATH = '/inscripciones'.freeze
  STATUS_PATH = '/materias/estado'.freeze
  GRADES_AVERAGE_PATH = '/alumnos/promedio'.freeze

  SUBJECT_KEY = 'nombre'.freeze
  TEACHER_KEY = 'docente'.freeze
  CODE_KEY = 'codigo'.freeze
  OFFER_KEY = 'oferta'.freeze
  INSCRIPTIONS_KEY = 'inscripciones'.freeze
  QUOTA_KEY = 'cupo_disponible'.freeze
  AVERAGE_KEY = 'nota_promedio'.freeze
  APPROVED_COURSES_KEY = 'materias_aprobadas'.freeze
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
    courses.map do |course|
      Astapor::Course.new(course[SUBJECT_KEY],
                          course[TEACHER_KEY],
                          course[CODE_KEY],
                          course[QUOTA_KEY])
    end
  end

  def state(user_name, code)
    connection = Faraday.new(url: GUARANI_URL)
    response = connection.get STATUS_PATH, codigoMateria: code, usernameAlumno: user_name
    Response.new.handle_status(response.body)
  end

  def inscriptions(user_name)
    connection = Faraday.new(url: GUARANI_URL)
    response = connection.get INSCRIPTIONS_PATH, usernameAlumno: user_name
    inscriptions = JSON.parse(response.body)[INSCRIPTIONS_KEY]
    inscriptions.map { |course| Astapor::Course.new(course[SUBJECT_KEY], course[TEACHER_KEY], course[CODE_KEY]) }
  end

  def grades_average(user_name)
    connection = Faraday.new(url: GUARANI_URL)
    response = connection.get GRADES_AVERAGE_PATH, usernameAlumno: user_name
    grades_av = JSON.parse(response.body)[AVERAGE_KEY]
    approved_courses = JSON.parse(response.body)[APPROVED_COURSES_KEY]
    [approved_courses, grades_av]
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
    Response.new.handle_response(response.body)
  end
end
