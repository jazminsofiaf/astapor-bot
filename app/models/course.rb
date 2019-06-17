require_relative '../../app/guarani_client'
module Astapor
  class Course
    attr_reader :code, :name, :teacher, :available_quota

    def initialize(name, teacher, code, av_quota = 100)
      @code = code
      @name = name
      @teacher = teacher
      @available_quota = av_quota
    end

    def ==(other)
      (other.class == self.class) &&
        (other.name == name) &&
        (other.code == code) &&
        (other.teacher == teacher)
    end

    def self.handle_response(student_name, user_name, course_code, _av_quota)
      GuaraniClient.new.inscribe(student_name, user_name, course_code)
    end
  end
end
