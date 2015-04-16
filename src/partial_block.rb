class PartialBlock

  def initialize(clase,&block)
    @bloque = block
    @tipos_de_parametros = clase
  end

  def call(*argumentos)
      if self.matches(*argumentos)
        @bloque.call(*argumentos)
      else
        raise ArgumentsTypeException, 'Diferente tipo de parámetros.'
      end
  end


  def matches(*argumentos)
    if argumentos.size == @tipos_de_parametros.size
      i = 0
      argumentos.all? do |argumento|
        argumento.is_a?(@tipos_de_parametros[i])
        i += 1
      end
    elsif argumentos.size < @tipos_de_parametros.size
      raise ArgumentsException, 'Cantidad insuficiente de argumentos.'
    else
      raise ArgumentsException, 'Demasiados argumentos.'
    end
  end


end

