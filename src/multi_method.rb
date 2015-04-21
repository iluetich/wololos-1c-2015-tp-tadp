require_relative '../src/exceptions/exceptions'
require_relative '../src/sobrecarga'
require_relative '../src/partial_block'

module MultiMethods

  def crear_multimetodo(nombre_multimetodo)
    self.send(:define_method, nombre_multimetodo) { |*argumentos|
      sobrecargas = self.class.obtener_sobrecargas_validas(self.class.multimetodos, nombre_multimetodo, *argumentos)
      comportamiento = self.class.obtener_partial_block(sobrecargas, *argumentos).bloque
      self.instance_exec *argumentos, &comportamiento
    }
  end

  def partial_def(nombre_multimetodo, lista_de_tipos, &bloque)
    bloque_parcial = PartialBlock.new(lista_de_tipos, &bloque)
    una_sobrecarga = Sobrecarga.new(nombre_multimetodo, bloque_parcial)
    self.agregar_sobrecargar(una_sobrecarga, nombre_multimetodo, bloque_parcial)
    #Con el unless nos evitamos pisar las definiciones una y otra vez de una sobrecarga.
    self.crear_multimetodo(nombre_multimetodo) unless self.respond_to? nombre_multimetodo
  end

  def agregar_sobrecargar(una_sobrecarga, nombre_multimetodo, bloque_parcial)
    self.multimetodos.delete_if{ |s| s.es_misma_firma(nombre_multimetodo, bloque_parcial) }
    self.multimetodos << una_sobrecarga
  end

  def multimetodos
    @lista_de_multimetodos = @lista_de_multimetodos || []
  end

  def obtener_sobrecargas_validas(sobrecargas, nombre_sobrecarga, *argumentos)
    sobrecargas.select { |s| s.nombre == nombre_sobrecarga && s.matches(*argumentos) }
  end

  def obtener_partial_block(sobrecargas, *argumentos)
    sobrecargas.min_by { |m| m.distancia_a_parametros(*argumentos) }.bloque
  end

end
