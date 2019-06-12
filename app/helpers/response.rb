class Response
  RESULT = 'resultado'.freeze
  ERROR = 'error'.freeze
  attr_reader :msg
  def initialize(data)
    response = JSON.parse(data)
    @msg = response[RESULT] || response[ERROR]
  end
end
