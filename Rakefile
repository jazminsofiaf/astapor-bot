require 'rubocop/rake_task'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--color --format d'
  end
rescue LoadError
  puts 'error at load rspec'
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--display-cop-names']
  task.requires << 'rubocop-rspec'
end

task default: %i[spec rubocop]
