require 'rspec'
require_relative '../../app/models/course'

describe 'Courses' do
  context 'when is created' do
    course = Course.new(9325, 'Análisis matemático I')
    it 'has a name' do
      expect(course.code).to eq(9325)
    end

    it 'has a code' do
      expect(course.name).to eq('Análisis matemático I')
    end
  end
end
