require 'rspec'
require 'json'
require_relative '../../app/helpers/response'

describe 'Response' do
  context 'when call guarani ' do
    it 'parse the response' do
      res = Response.new({ resultado:  'INSCRIPCION_CREADA' }.to_json)
      expect(res.msg).to eq('Listo! ya estas inscripto :tada:')
    end

    it 'parse the error' do
      res = Response.new({ error: 'ERROR DE INSCRIPCION' }.to_json)
      expect(res.msg).to eq('ERROR DE INSCRIPCION')
    end
  end
end
