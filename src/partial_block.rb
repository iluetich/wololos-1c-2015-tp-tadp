class PartialBlock < Proc

  def initialize(array_tipos_de_parametros,&block)
    @bloque = block
    @tipos_de_parametros = array_tipos_de_parametros
  end

  def call(*argumentos)
      if self.matches(*argumentos)
        @bloque.call(*argumentos)
      else
        raise ArgumentTypeException.new, 'Diferente tipo de parametros.'
      end
  end

  def matches(*argumentos)
    if argumentos.size == @tipos_de_parametros.size
      i = 0
      argumentos.all? do |argumento|
        i += 1
        argumento.is_a?(@tipos_de_parametros[i-1])
      end
    else
      false
    end
  end

  def tipos_de_parametros
    @tipos_de_parametros = @tipos_de_parametros || []
  end

end

