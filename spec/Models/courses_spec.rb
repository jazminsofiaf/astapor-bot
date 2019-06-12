require 'rspec'
require_relative '../../app/models/course'

describe 'Courses' do
  context 'when is created' do
    course = Astapor::Course.new('Análisis matemático I', 'Sirne', 9325)
    it 'has a name' do
      expect(course.code).to eq(9325)
    end

    it 'has a code' do
      expect(course.name).to eq('Análisis matemático I')
    end

    it 'has a teacher' do
      expect(course.teacher).to eq('Sirne')
    end
  end

  context 'when there is two courses ' do
    course = Astapor::Course.new('Análisis matemático I', 'Sirne', 9325)
    course2 = Astapor::Course.new('Análisis matemático I', 'Sirne', 9325)
    it 'with the same name, teacher and code, they are equals' do
      expect(course).to eq(course2)
    end
  end
end
