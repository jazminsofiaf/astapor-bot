class Response
  RESULT = 'resultado'.freeze
  ERROR = 'error'.freeze

  BOT_RESPONSES = {
    'INSCRIPCION_CREADA' => 'Listo! ya estas inscripto',
    'CUPO_COMPLETO' => 'Oups, no es posible realizar la inscripcion, el cupo ya está completo',
    'INSCRIPCION_DUPLICADA' => 'Ya estas incripto'
  }.freeze
  attr_reader :msg
  def initialize(data)
    response = JSON.parse(data)
    result = response[RESULT] || response[ERROR]
    @msg = BOT_RESPONSES[result] || result
  end
end
