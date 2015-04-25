require_relative '../src/exceptions/exceptions'
require_relative '../src/sobrecarga'
require_relative '../src/partial_block'

module MultiMethods

  def crear_multimetodo!(selector)
    contexto = self
    self.send(:define_method, selector) { |*argumentos|
      begin
        comportamiento = contexto.obtener_partial_block(selector, *argumentos).bloque
        instance_exec(*argumentos, &comportamiento)
      rescue NoSuchMultiMethodException
        super(*argumentos)
      end
    }
  end

  def partial_def(selector, lista_de_tipos, &bloque)
    contexto = self.obtener_contexto
    contexto.agregar_sobrecarga!(Sobrecarga.new(selector, PartialBlock.new(lista_de_tipos, &bloque)))
    contexto.crear_multimetodo!(selector) unless contexto.respond_to?(selector)
  end

  def agregar_sobrecarga!(sobrecarga)
    self.sobrecargas.delete_if{ |s| s.sos_igual_a?(sobrecarga.selector, sobrecarga.tipos_de_parametros) }
    self.sobrecargas << sobrecarga
  end
  
  def sobrecargas(buscar_en_ancestros=false)
    unless buscar_en_ancestros
      return (@lista_de_multimetodos = @lista_de_multimetodos || [])
    end
    overloads = []
    obtener_contexto.ancestors.each do |viejo|
      overloads += viejo.sobrecargas
    end
    overloads
  end

  def seleccionar_sobrecargas_aplicables(selector, *argumentos)
    self.sobrecargas(true).select { |s| s.selector == selector && s.matches(*argumentos) }
  end

  def obtener_partial_block(selector, *argumentos)
    unless (sobrecarga = self.seleccionar_sobrecargas_aplicables(selector, *argumentos).min_by { |m| m.distancia_a_parametros(*argumentos) })
      raise NoSuchMultiMethodException
    end
    sobrecarga.partial_block
  end

  #Si soy una clase, yo mismo, si soy una instancia, mi singleton_class
  def obtener_contexto
    self.is_a?(Class) ? self : self.singleton_class
  end

  #Busco en mi singleton_class o en mi class. Con que esté en alguna me basta.
  def existe_multimetodo?(symbol, lista_de_tipos)
    self.singleton_class.sobrecargas.any? {|s| s.matcheas_con?(symbol, lista_de_tipos)} or
        self.class.ancestors.any? do |ancestro|
          ancestro.sobrecargas.any? {|s| s.matcheas_con?(symbol, lista_de_tipos)}
        end
  end

  def respond_to?(*args)
    case args.size
      when 1 # => Método normal o multimetodo sin tipos.
        super(args[0])
      when 2 # => Método normal
        super(args[0], args[1])
      when 3 # => Multimétodo
        self.existe_multimetodo?(args[0],args[2])
      else
        raise ArgumentError 'Cantidad incorrecta de argumentos para "respond_to?"'
    end
  end

  def method_missing(selector, *args, &block)
    super(selector,*args,&block) unless args[0].is_a?(Array)
    #por convención, recibo una lista de tipos en el primer argumentos
    lista_de_tipos = args.shift
    #Si encuentro una sobrecarga que matchee exactamente con la lista de tipos, me la quedo y la ejecuto.
    super(selector,*args,&block) unless (overload_a_ejecutar = self.sobrecargas(true).detect {|ov| ov.sos_igual_a?(selector, lista_de_tipos)})
    overload_a_ejecutar.call(*args)
  end

  def base(*args)
    self
  end
end
