require_relative '../src/exceptions/exceptions'
require_relative '../src/sobrecarga'
require_relative '../src/partial_block'

class Module

  attr_accessor :last_multimethod

  def partial_def(sym, type_list, &bloque)
    multimethod_create!(sym) unless multimethod_exists_with? sym
    multimethod_add_new!(Sobrecarga.new(sym, PartialBlock.new(type_list, &bloque)))
  end

  def multimethod_create!(sym)
    self.send(:define_method, sym) { |*args|
      multimethod_to_exec = singleton_class.multimethod_closest_to(sym, *args)
      execute(multimethod_to_exec, *args)
    }
  end

  def multimethod_add_new!(new_multimethod)
    multimethods.delete_if { |s| s.sos_igual_a?(new_multimethod)}
    multimethods << new_multimethod
  end

  def multimethods(buscar_en_ancestros=false)
    if buscar_en_ancestros
      ancestors.collect {|ancestro| ancestro.multimethods}.flatten
    else
      @multimethods = @multimethods || Array.new
    end
  end

  def multimethod_exists_with?(sym, type_list=nil)
    return multimethods.any? { |m| m.selector == sym } if type_list.eql? nil
    mock = Sobrecarga.new(sym, PartialBlock.new(type_list) { })
    multimethods(true).any? {|m| m.matcheas_con?(mock)}
  end

  def multimethods_matching(sym, *argumentos)
    matching_multimethods = multimethods(true).select {|m| m.selector == sym && m.matches(*argumentos)}
    if matching_multimethods.empty?
      raise NoSuchMultiMethodException
    else
      matching_multimethods
    end
  end

  def multimethod_strict_as(sym, type_list)
    mock = Sobrecarga.new(sym, PartialBlock.new(type_list) { })
    multimethods(true).detect {|m| m.sos_igual_a?(mock)}
  end

  def multimethod_closest_to(sym, *args)
    multimethods_matching(sym, *args).min_by { |m| m.distancia_a_parametros(*args) }
  end

  def multimethod_next_generic(sym, *args)
    ordered_by_distance = multimethods_matching(sym, *args).sort_by {|m| m.distancia_a_parametros(*args)}
    last_multimethod_index = ordered_by_distance.index(last_multimethod)
    ordered_by_distance
        .drop(last_multimethod_index + 1)
        .detect {|m| m.selector == sym && m.matches(*args)}
  end

end

class Object

  def partial_def(sym, type_list, &block)
    singleton_class.partial_def(sym, type_list, &block)
  end

  def multimethods(include_ancestors=false)
    singleton_class.multimethods(include_ancestors)
  end

  def respond_to?(sym, include_all=false, type_list = nil)
    if type_list.eql? nil
      super(sym, include_all)
    else
      singleton_class.multimethod_exists_with?(sym, type_list)
    end
  end

  def base(*args)
    objeto_base = Base.new(self)
    args.empty? ? objeto_base : objeto_base.implicit_call(*args)
  end

  def execute(multimethod_to_exec, *args)
    singleton_class.last_multimethod = multimethod_to_exec
    block = multimethod_to_exec.partial_block.bloque
    instance_exec(*args, &block)
  end

end

class Base

  attr_accessor :caller

  def initialize(caller)
    self.caller = caller
  end

  def implicit_call(*args)
    last_multimethod_selector = caller.singleton_class.last_multimethod.selector
    overload = caller.singleton_class.multimethod_next_generic(last_multimethod_selector, *args)
    caller.execute(overload, *args)
  end

  def method_missing(sym, type_list, *args, &block)
    overload = caller.singleton_class.multimethod_strict_as(sym, type_list)
    caller.execute(overload, *args)
  end

end
