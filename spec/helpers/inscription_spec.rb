require 'rspec'
require_relative '../../app/helpers/inscription'

describe 'InscriptionParser' do
  context 'with a user and code' do
    body = Inscription.new.body('Jazmin Ferreiro', 'jaz2', 1234)
    it 'create a json body to incribe in astapor guarani api' do
      expected_body = {
        nombre_completo: 'Jazmin Ferreiro',
        codigo_materia: 1234,
        username_alumno: 'jaz2'
      }.to_json
      expect(body).to eq(expected_body)
    end
  end
end
