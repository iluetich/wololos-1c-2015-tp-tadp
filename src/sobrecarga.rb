class Sobrecarga
  attr_accessor :nombre, :bloque_parcial

  def initialize (un_nombre, un_bloque_parcial)
    nombre = un_nombre
    bloque_parcial = un_bloque_parcial
  end

  def matches(*argumentos)
    bloque_parcial.matches(*argumentos)
  end

  def call(*argumentos)
    bloque_parcial.call(*argumentos)
  end

end