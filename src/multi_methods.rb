require_relative '../src/overload'
require_relative '../src/partial_block'

class NoSuchMultiMethodException < Exception
end
class ArgumentTypeException < Exception
end

class Module

  #TODO poder dejar parámetros por default (tomar menos parámetros de los que necesito y ejecutarme)

  attr_accessor :m_method_stack

  def partial_def(sym, type_list, &bloque)
    m_method_define!(sym) unless m_method_exists_with? sym
    m_method_add_new!(Overload.new(sym, PartialBlock.new(type_list, &bloque)))
  end

  def m_method_define!(sym)
    self.send(:define_method, sym) { |*args|
      m_method_to_exec = singleton_class.m_method_closest_to(sym, *args)
      execute(m_method_to_exec, *args)
    }
  end

  def m_method_add_new!(new_m_method)
    m_methods.delete_if { |s| s.equal_to?(new_m_method) }
    m_methods << new_m_method
  end

  def m_methods(include_ancestors = false)
    if include_ancestors
      ancestors.flat_map { |ancestor| ancestor.m_methods }
    else
      @m_methods ||= Array.new
    end
  end

  def m_method_exists_with?(sym, type_list = nil)
    return m_methods.any? { |m| m.selector.eql?(sym) } if type_list.nil?
    mock = Overload.new(sym, PartialBlock.new(type_list) {})
    m_methods(true).any? { |m| m.identical_to?(mock) }
  end

  def m_methods_match(sym, *arguments)
    matched_m_methods = m_methods(true).select { |m| m.selector.eql?(sym) && m.accepts?(*arguments) }
    raise NoSuchMultiMethodException.new("Multimethod: #{sym} called with: #{arguments} does not exists") if matched_m_methods.empty?
    matched_m_methods
  end

  def m_method_strict_as(sym, type_list)
    mock = Overload.new(sym, PartialBlock.new(type_list) {})
    m_methods(true).detect { |m| m.equal_to?(mock) }
  end

  def m_method_closest_to(sym, *args)
    m_methods_match(sym, *args).min_by { |m| m.distance_to_params(*args) }
  end

  def m_method_next_generic(sym, *args)
    ordered_by_distance = m_methods_match(sym, *args).sort_by { |m| m.distance_to_params(*args) }
    last_m_method_index = ordered_by_distance.index(last_m_method)
    ordered_by_distance
        .drop(last_m_method_index + 1)
        .detect { |m| m.selector.eql?(sym) && m.accepts?(*args) }
  end

  def m_method_stack
    @multi_method_stack ||= Array.new
  end

  def last_m_method
    m_method_stack.last
  end

  def executing(m_method)
    m_method_stack.push m_method
  end

  def release(m_method)
    i = m_method_stack.find_index { |m| m.eql? m_method }
    m_method_stack.delete_at i
  end

end

class Object

  def partial_def(sym, type_list, &block)
    singleton_class.partial_def(sym, type_list, &block)
  end

  def m_methods(include_ancestors = false)
    singleton_class.m_methods(include_ancestors)
  end

  def respond_to?(sym, include_all = false, type_list = nil)
    type_list.nil? ? super(sym, include_all) : singleton_class.m_method_exists_with?(sym, type_list)
  end

  def base(*args)
    base_object = Base.new(self)
    args.empty? ? base_object : base_object.implicit_call(*args)
  end

  def execute(m_method_to_exec, *args)
    block = m_method_to_exec.partial_block

    singleton_class.executing m_method_to_exec
    return_of_execution = instance_exec(*args, &block)
    singleton_class.release m_method_to_exec
    return_of_execution
  end

end

class Base

  attr_accessor :caller

  def initialize(caller)
    @caller = caller
  end

  def implicit_call(*args)
    selector = caller.singleton_class.last_m_method.selector
    overload = caller.singleton_class.m_method_next_generic(selector, *args)
    caller.execute(overload, *args)
  end

  def method_missing(sym, type_list, *args, &block)
    overload = caller.singleton_class.m_method_strict_as(sym, type_list)
    caller.execute(overload, *args)
  end

end