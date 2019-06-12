class Response
  RESULT = 'resultado'.freeze
  attr_reader :msg
  def initialize(data)
    @msg = JSON.parse(data)[RESULT]
  end
end
