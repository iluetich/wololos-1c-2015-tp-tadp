class Sobrecarga

  def initialize (selector, partial_block)
    @selector = selector
    @partial_block = partial_block
  end

  def tipos_de_parametros
    @partial_block.tipos_de_parametros
  end

  def selector
    @selector
  end

  def partial_block
    @partial_block
  end

  def matches(*argumentos)
    @partial_block.matches(*argumentos)
  end

  def matcheas_con?(sobrecarga)
    unless @selector == sobrecarga.selector && tipos_de_parametros.count == sobrecarga.tipos_de_parametros.count
      return false
    end
    tipos_de_parametros.zip(sobrecarga.tipos_de_parametros).all? do |sc_tipo, pm_tipo|
      pm_tipo.ancestors.include?(sc_tipo)
    end
  end

  def call(*argumentos)
    @partial_block.call(*argumentos)
  end

  def distancia_a_parametros(*argumentos)
    i = distancia_total = 0
    argumentos.zip(@partial_block.tipos_de_parametros) do |argumento, tipo|
      i+=1
      distancia_total += argumento.class.ancestors.index(tipo) * i
    end
    distancia_total
  end

  def sos_igual_a?(sobrecarga)
    @selector == sobrecarga.selector && self.tipos_de_parametros == sobrecarga.tipos_de_parametros
  end

end