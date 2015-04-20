class PartialBlock

  def initialize(array_tipos_de_parametros,&block)
    @bloque = block
    @tipos_de_parametros = array_tipos_de_parametros
  end

  def tipos_de_parametros
    @tipos_de_parametros = @tipos_de_parametros || []
  end

  def call(*argumentos)
    raise ArgumentTypeException unless self.matches(*argumentos)
      @bloque.call(*argumentos)
  end

  def matches(*argumentos)
    return false unless argumentos.size == @tipos_de_parametros.size
    argumentos.zip(@tipos_de_parametros).all? do |argumento, tipo|
      argumento.is_a? tipo
    end
  end

end

