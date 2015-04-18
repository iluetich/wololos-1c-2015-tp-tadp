class Sobrecarga

  def initialize (un_nombre, un_bloque_parcial)
    @nombre = un_nombre
    @bloque_parcial = un_bloque_parcial
  end

  def nombre
    @nombre = @nombre || "sin nombre"
  end

  def matches(*argumentos)
    @bloque_parcial.matches(*argumentos)
  end

  def call(*argumentos)
    @bloque_parcial.call(*argumentos)
  end

  def distancia_a_parametros(*argumentos)
    tipos_argumentos = @bloque_parcial.tipos_de_parametros
    indice = 0
    distancia_total = 0
    argumentos.each do |arg|
      distancia_parametro = arg.class.ancestors.index(tipos_argumentos[indice])
      indice += 1
      distancia_total += distancia_parametro * indice
    end
    distancia_total
  end

end