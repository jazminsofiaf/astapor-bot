require 'rspec'
require 'json'
require_relative '../../app/helpers/response'

describe 'Response' do
  context 'when call guarani ' do
    it 'parse the response' do
      res = Response.new.handle_response({ resultado: 'INSCRIPCION_CREADA' }.to_json)
      expect(res).to eq("Listo! ya estas inscripto \u{1F389}")
    end

    it 'parse the error' do
      res = Response.new.handle_response({ error: 'ERROR DE INSCRIPCION' }.to_json)
      expect(res).to eq('ERROR DE INSCRIPCION')
    end
  end

  context 'when call guarani status' do
    it 'parse the error' do
      res = Response.new.handle_status({ error: 'MATERIA_NO_EXISTE' }.to_json)
      expect(res).to eq("Opsi, esa materia no existe  \u{1F616}")
    end

    it 'parse the pass' do
      res = Response.new.handle_status({ estado: 'APROBADO', nota_final: 10 }.to_json)
      expect(res).to eq("Felicitaciones \u{1F44D} aprobaste con un 10")
    end

    it 'parse the fail' do
      res = Response.new.handle_status({ estado: 'DESAPROBADO', nota_final: 1 }.to_json)
      expect(res).to eq("Uy \u{1F44E} desaprobaste con un 1")
    end

    it 'parse not enrolled in' do
      res = Response.new.handle_status({ estado: 'NO_INSCRIPTO', nota_final: nil }.to_json)
      expect(res).to eq('No estas inscripto')
    end

    it 'parse under way' do
      res = Response.new.handle_status({ 'estado': 'EN_CURSO', 'nota_final': 'null' }.to_json)
      expect(res).to eq('La estas cursando')
    end
  end
end
