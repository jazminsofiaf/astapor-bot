class Response
  RESULT = 'resultado'.freeze
  ERROR = 'error'.freeze
  TADA = '\U0001F389'.freeze
  NO_GOOD = '\U0001F645'.freeze
  X = '\U0000274C'.freeze

  BOT_RESPONSES = {
    'INSCRIPCION_CREADA' => "Listo! ya estas inscripto #{TADA.encode('utf-8')}",
    'CUPO_COMPLETO' => "Oups, no es posible realizar la inscripcion #{X.encode('utf-8')}"\
                       "el cupo ya está completo #{NO_GOOD.encode('utf-8')}",
    'INSCRIPCION_DUPLICADA' => 'Ya estas incripto'
  }.freeze
  attr_reader :msg
  def initialize(data)
    response = JSON.parse(data)
    result = response[RESULT] || response[ERROR]
    @msg = BOT_RESPONSES[result] || result
  end
end
