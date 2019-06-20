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
    'DESAPROBADO' => "Uy #{Emoji.code(:down)} desaprobaste con un",
    'NO_INSCRIPTO' => 'No estas inscripto',
    'EN_CURSO' => 'La estas cursando'
  }.freeze

  def handle_response(data)
    response = JSON.parse(data)
    result = response[RESULT] || response[ERROR]
    BOT_RESPONSES[result] || result
  end

  def handle_status(data)
    response = JSON.parse(data)
    error = response[ERROR]
    return BOT_RESPONSES[error] unless error.nil?

    status = response[STATE]
    final_grade = response[GRADE]
    return BOT_RESPONSES[status] if is_null?(final_grade)

    "#{BOT_RESPONSES[status]} #{final_grade}"
  end

  def is_null?(grade)
    grade.nil? || (grade == 'nil') || (grade == 'null') || grade.to_s.empty?
  end
end
