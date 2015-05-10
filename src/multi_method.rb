require_relative '../src/exceptions/exceptions'
require_relative '../src/sobrecarga'
require_relative '../src/partial_block'

class Module

  def partial_def(selector, lista_de_tipos, &bloque)
    agregar_sobrecarga!(Sobrecarga.new(selector, PartialBlock.new(lista_de_tipos, &bloque)))
    crear_multimetodo!(selector) unless respond_to? selector
  end

  def crear_multimetodo!(selector)
    self.send(:define_method, selector) { |*argumentos|
      begin
        overload_to_exec = nearest_overload(selector, *argumentos)
        execute(overload_to_exec, *argumentos)
      rescue NoSuchMultiMethodException
        super(*argumentos)
      end
    }
  end

  def agregar_sobrecarga!(sobrecarga)
    sobrecargas.delete_if { |s| s.sos_igual_a?(sobrecarga)}
    sobrecargas << sobrecarga
  end

  def sobrecargas(buscar_en_ancestros=false)
    if buscar_en_ancestros
      ancestors.collect {|ancestro| ancestro.sobrecargas}.flatten
    else
      @multimethods = @multimethods || Array.new
    end
  end

end

class Object

  attr_accessor :last_overload

  def partial_def(selector, lista_de_tipos, &bloque)
    singleton_class.partial_def(selector, lista_de_tipos, &bloque)
  end

  #Las sobrecargas de un objeto son las de su singleton class mas las de su clase, y opcionalmente la de sus
  #ancestros.
  def sobrecargas(incluir_ancestros=false)
    singleton_class.sobrecargas + self.class.sobrecargas(incluir_ancestros)
  end

  def existe_multimetodo?(sym, type_list)
    mock = Sobrecarga.new(sym, PartialBlock.new(type_list) { })
    sobrecargas(true).any? {|overload| overload.matcheas_con?(mock)}
  end

  def exact_overload(sym, type_list)
    mock = Sobrecarga.new(sym, PartialBlock.new(type_list) { })
    sobrecargas(true).detect {|overload| overload.sos_igual_a?(mock)}
  end

  def overloads_matching(selector, *argumentos)
    sobrecargas(true).select {|s| s.selector == selector && s.matches(*argumentos)}
  end

  def nearest_overload(sym, *arguments)
    sobrecarga = overloads_matching(sym, *arguments).min_by { |m|
      m.distancia_a_parametros(*arguments)
    }
    unless sobrecarga
      raise NoSuchMultiMethodException
    end
    sobrecarga
  end

  def inmediate_next_overload(sym, *args)
    ordered_by_distance = sobrecargas(true).sort_by {|ov| ov.distancia_a_parametros(*args)}
    index_of_last_overload = ordered_by_distance.index(last_overload)
    ordered_by_distance
        .drop(index_of_last_overload + 1)
        .detect {|ov| ov.selector == sym && ov.matches(*args)}
  end

  def respond_to?(sym, include_all=false, parameter_type = nil)
    if parameter_type.eql? nil
      super(sym, include_all)
    else
      existe_multimetodo?(sym, parameter_type)
    end
  end

  def method_missing(selector, *args, &block)
    super unless args.first.is_a? Array
    overload_to_exec = exact_overload(selector, args.first)
    execute(overload_to_exec, *args.drop(1))
  end

  def base(*args)
    if args.empty?
      self
    else
      sym = last_overload.selector
      overload_to_exec = inmediate_next_overload(sym, *args)
      execute(overload_to_exec, *args)
    end
  end

  def execute(overload, *args)
    self.last_overload = overload
    block = overload.partial_block.bloque
    instance_exec(*args, &block)
  end

end
