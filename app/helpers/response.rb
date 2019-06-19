require_relative 'emoji'
require_relative 'astapor_api_error'
class Response
  RESULT = 'resultado'.freeze
  ERROR = 'error'.freeze
  STATE = 'estado'.freeze
  GRADE = 'nota_final'.freeze

  BOT_RESPONSES = {
    'INSCRIPCION_CREADA' => "Listo! ya estas inscripto #{Emoji.code(:tada)}",
    'CUPO_COMPLETO' => "Oups, no es posible realizar la inscripcion #{Emoji.code(:x)}"\
                        "el cupo ya está completo #{Emoji.code(:no_good)}",
    'INSCRIPCION_DUPLICADA' => 'Ya estas incripto',
    'MATERIA_NO_EXISTE' => "Opsi, esa materia no existe  #{Emoji.code(:confounded)}",
    'APROBADO' => "Felicitaciones #{Emoji.code(:up)} aprobaste con un",
    'DESAPROBADO' => "Uy #{Emoji.code(:down)} desaprobaste con un"
  }.freeze

  def handle_response(data)
    begin
      response = JSON.parse(data)
    rescue JSON::ParserError
      raise AstaporApiError, "error at parse inscriptions body:#{data}"
    end
    result = response[RESULT] || response[ERROR]
    BOT_RESPONSES[result] || result
  end

  def handle_status(data)
    begin
      response = JSON.parse(data)
    rescue JSON::ParserError
      raise AstaporApiError, "error at parse status body:#{data"
    end
    error = response[ERROR]
    return BOT_RESPONSES[error] unless error.nil?

    status = response[STATE]
    final_grade = response[GRADE]
    "#{BOT_RESPONSES[status]} #{final_grade}"
  end
end
