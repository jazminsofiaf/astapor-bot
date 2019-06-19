class AstaporApiError < StandardError
  attr_reader :msg
  def initialize(msg = 'api connection error')
    @msg = msg
  end
end
