require 'rspec'
require_relative '../../lib/message_handler'

class DummyClass
  include MessageHandler
end

describe 'Message handler' do
  context 'when handle first word only' do
    dc =  DummyClass.new

    it 'should get first word of a phrase to compare' do
      expect(dc.first_word('/estado 1001')).to eq('/estado')
    end
  end
end
