require 'rspec'
require 'json'
require_relative '../../app/helpers/response'

describe 'Response' do
  context 'when call guarani ' do
    it 'parse the response' do
      res = Response.new({ resultado: 'inscripcion_creada' }.to_json)
      expect(res.msg).to eq('inscripcion_creada')
    end

    it 'parse the error' do
      res = Response.new({ error: 'ERROR DE INSCRIPCION' }.to_json)
      expect(res.msg).to eq('ERROR DE INSCRIPCION')
    end
  end
end
