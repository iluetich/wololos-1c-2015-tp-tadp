require_relative '../src/exceptions/exceptions'
require_relative '../src/sobrecarga'
require_relative '../src/partial_block'

module MultiMethods

  attr_accessor :lista_de_multimetodos

  @@lista_de_multimetodos = []

  def partial_def(nombre_metodo, lista_de_tipos, &bloque)

    bloque_parcial = PartialBlock.new(lista_de_tipos, &bloque)
    una_sobrecarga = Sobrecarga.new(nombre_metodo, bloque_parcial)
    self.add_sobrecarga(una_sobrecarga)
    self.send(:define_method, nombre_metodo) { |*argumentos|
      my_name = nombre_metodo
      sobrecargas = self.class.obtener_sobrecargas_validas(@@lista_de_multimetodos, my_name, *argumentos)
      self.class.elegir_mas_cercano(sobrecargas, *argumentos).call(*argumentos)
    }

  end

  def add_sobrecarga(una_sobrecarga)
    @@lista_de_multimetodos << una_sobrecarga
  end

  def obtener_sobrecargas_validas(sobrecargas, nombre_sobrecarga, *argumentos)
    return sobrecargas.select {|s| s.nombre == nombre_sobrecarga && s.matches(*argumentos)}
  end

  def elegir_mas_cercano(sobrecargas, *argumentos)
    sobrecargas.min_by { |m| m.distancia_a_parametros(*argumentos) }
  end

end



=begin

    ##### EJEMPLOS DE USO #####


class A
  extend MultiMethods

  partial_def :concat, [String,String] do |s1,s2|
    s1 + s2
  end

  partial_def :concat, [String,Integer] do |s1,s2|
    s1 * s2
  end

  partial_def :concat, [Object,Object] do
    "dos objetos felices"
  end

  partial_def :concat, [String] do
    "un solo string!"
  end

  partial_def :concat, [Fixnum] do
    "soy un fixnum"
  end

  partial_def :saluda, [String, String, String] do |s1, s2, s3|
   s1 + ' ' + s2 + ' ' + s3
  end

end

puts A.new.concat('hello',' world!')
puts A.new.concat('hola ',3)
a = A.new
puts a.concat('hola ')
puts a.concat(3)
puts a.saluda('hola,', 'todo', 'bien?')

=end