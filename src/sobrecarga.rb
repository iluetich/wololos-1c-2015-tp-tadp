class Sobrecarga

  def initialize (un_nombre, un_bloque_parcial)
    @nombre = un_nombre
    @bloque_parcial = un_bloque_parcial
  end

  def tipos_de_parametros
    @bloque_parcial.tipos_de_parametros
  end

  def nombre
    @nombre = @nombre || "sin nombre"
  end

  def partial_block
    @bloque_parcial
  end

  def matches(*argumentos)
    @bloque_parcial.matches(*argumentos)
  end

  def call(*argumentos)
    @bloque_parcial.call(*argumentos)
  end

  def distancia_a_parametros(*argumentos)
    i = distancia_total = 0
    argumentos.zip(@bloque_parcial.tipos_de_parametros) do |argumento, tipo|
      i+=1
      distancia_total += argumento.class.ancestors.index(tipo) * i
    end
    distancia_total
  end

  def es_misma_firma(nombre_multimetodo, bloque_parcial)
    @nombre == nombre_multimetodo && self.tipos_de_parametros == bloque_parcial.tipos_de_parametros
  end

end