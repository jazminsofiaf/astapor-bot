require 'json'
class Inscription
  def body(name, username, code)
    {
      nombre_completo: name,
      codigo_materia: code,
      username_alumno: username
    }.to_json
  end
end
