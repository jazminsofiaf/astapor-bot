require 'faraday'
require 'json'
require_relative '../app/models/course'
class GuaraniClient
  GUARANI_URL = 'https://astapor-api.herokuapp.com'.freeze
  WELCOME_PATH = '/welcome_message'.freeze
  COURSE_PATH = '/materias'.freeze

  SUBJECT_KEY = 'nombre'.freeze
  TEACHER_KEY = 'docente'.freeze
  CODE_KEY = 'codigo'.freeze
  OFFER_KEY = 'oferta'.freeze

  def welcome_message
    connection = Faraday.new(url: GUARANI_URL)
    response = connection.get WELCOME_PATH
    response.body
  end

  def courses
    connection = Faraday.new(url: GUARANI_URL)
    response = connection.get COURSE_PATH
    courses = JSON.parse(response.body)[OFFER_KEY]
    courses.map { |course| Course.new(course[SUBJECT_KEY], course[TEACHER_KEY], course[CODE_KEY]) }
  end
end
