require_relative '../src/exceptions/exceptions'
require_relative '../src/sobrecarga'
require_relative '../src/partial_block'

module MultiMethods

  def partial_def(nombre_metodo, lista_de_tipos, &bloque)

    bloque_parcial = PartialBlock.new(lista_de_tipos, &bloque)
    una_sobrecarga = Sobrecarga.new(nombre_metodo, bloque_parcial)
    self.add_sobrecarga(una_sobrecarga)
    self.send(:define_method, nombre_metodo) { |*argumentos|
      my_name = nombre_metodo
      sobrecargas = self.class.obtener_sobrecargas_validas(self.class.multimetodos, my_name, *argumentos)
      self.class.elegir_mas_cercano(sobrecargas, *argumentos).call(*argumentos)
    }

  end

  def multimetodos
    @lista_de_multimetodos = @lista_de_multimetodos || []
  end

  def add_sobrecarga(una_sobrecarga)
    self.multimetodos << una_sobrecarga
  end

  def obtener_sobrecargas_validas(sobrecargas, nombre_sobrecarga, *argumentos)
    return sobrecargas.select {|s| s.nombre == nombre_sobrecarga && s.matches(*argumentos)}
  end

  def elegir_mas_cercano(sobrecargas, *argumentos)
    sobrecargas.min_by { |m| m.distancia_a_parametros(*argumentos) }
  end

end
