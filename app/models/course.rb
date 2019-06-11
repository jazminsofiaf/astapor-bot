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
end
