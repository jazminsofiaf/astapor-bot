require_relative 'emoji'
class Response
  RESULT = 'resultado'.freeze
  ERROR = 'error'.freeze

  BOT_RESPONSES = {
    'INSCRIPCION_CREADA' => "Listo! ya estas inscripto #{Emoji.code(:tada)}",
    'CUPO_COMPLETO' => "Oups, no es posible realizar la inscripcion #{Emoji.code(:x)}"\
                        "el cupo ya está completo #{Emoji.code(:no_good)}",
    'INSCRIPCION_DUPLICADA' => 'Ya estas incripto'
  }.freeze
  attr_reader :msg
  def initialize(data)
    response = JSON.parse(data)
    result = response[RESULT] || response[ERROR]
    @msg = BOT_RESPONSES[result] || result
  end
end
