require_relative '../src/exceptions/exceptions'
require_relative '../src/sobrecarga'
require_relative '../src/partial_block'

module OverloadModule

  attr_accessor :lista_de_multimetodos

  def method_missing(nombre_metodo, *argumentos, &bloque)
    puts "&"
    multimetodos = self.obtener_sobrecargas_validas(self.lista_de_multimetodos, nombre_metodo, *argumentos).empty?
    if multimetodos.empty?
      raise NoSuchMultiMethodException "Error, no existe el múltimétodo: :nombre", nombre: nombre_metodo
    else
      multimetodos.first.call(*argumentos)
    end
  end

  def partial_def(nombre_metodo, lista_de_tipos, &bloque)
    bloque_parcial = PartialBlock.new(lista_de_tipos, &bloque)
    una_sobrecarga = Sobrecarga.new(nombre_metodo, bloque_parcial)
    self.add_sobrecarga(una_sobrecarga)
  end

  def add_sobrecarga(una_sobrecarga)
    @lista_de_multimetodos << una_sobrecarga
  end

  def obtener_sobrecargas_validas(sobrecargas, nombre_sobrecarga, *argumentos)
    return sobrecargas.select {|s| s.nombre == nombre_sobrecarga && s.matches(*argumentos)}
  end

end



