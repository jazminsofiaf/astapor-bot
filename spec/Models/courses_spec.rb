require 'webmock/rspec'
require 'rspec'

require_relative '../../app/models/course'

describe 'Courses' do
  context 'when is created' do
    course = Astapor::Course.new('Análisis matemático I', 'Sirne', 9325, 50)
    it 'has a name' do
      expect(course.code).to eq(9325)
    end

    it 'has a code' do
      expect(course.name).to eq('Análisis matemático I')
    end

    it 'has a teacher' do
      expect(course.teacher).to eq('Sirne')
    end

    it 'has an available quota' do
      expect(course.available_quota).to eq 50
    end
  end

  context 'when there is two courses ' do
    course = Astapor::Course.new('Análisis matemático I', 'Sirne', 9325, 50)
    course2 = Astapor::Course.new('Análisis matemático I', 'Sirne', 9325, 50)
    it 'with the same name, teacher and code, they are equals' do
      expect(course).to eq(course2)
    end
  end

  context 'when there is an inscription' do
    response = Astapor::Course.handle_response('Jazmin Ferreiro', 'jaz2', 9123, 50)
    it 'it return a message' do
      expect(response).not_to be nil
    end
  end
end
