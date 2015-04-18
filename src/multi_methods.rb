require_relative '../src/sobrecarga'
require_relative '../src/partial_block'

module MultiMethods

  attr_accessor :lista_de_multimetodos

  def partial_def(nombre_metodo, lista_de_tipos, &bloque)
    bloque_parcial = PartialBlock.new(lista_de_tipos, &bloque)
    una_sobrecarga = Sobrecarga.new(nombre_metodo, bloque_parcial)
    self.add_sobrecarga(una_sobrecarga)
  end

  def add_sobrecarga(una_sobrecarga)
    @lista_de_multimetodos << una_sobrecarga
  end

  def method_missing(nombre_metodo, *argumentos, &bloque)
    lista_de_sobrecargas = self.lista_de_multimetodos.select { |multimetodo| multimetodo.nombre == nombre_metodo }
    lista_de_matcheados = lista_de_sobrecargas.select { |multimetodo| multimetodo.matches(*args) }
    if lista_de_matcheados.empty?
      raise Exception "Error, no existe el múltimétodo #{:nombre}", nombre: nombre_metodo
    else
      lista_de_matcheados.first.call(*argumentos)
    end
  end

end



