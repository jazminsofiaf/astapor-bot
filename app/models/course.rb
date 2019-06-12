require_relative '../../app/guarani_client'
module Astapor
  class Course
    attr_reader :code, :name, :teacher

    def initialize(name, teacher, code)
      @code = code
      @name = name
      @teacher = teacher
    end

    def ==(other)
      (other.class == self.class) &&
        (other.name == name) &&
        (other.code == code) &&
        (other.teacher == teacher)
    end

    def self.handle_response(student_name, user_name, course_code)
      GuaraniClient.new.inscribe(student_name, user_name, course_code)
    end
  end
end
