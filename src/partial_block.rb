class Array
  def has_many_elements_as?(other_array)
    count.eql? other_array.count
  end
end

class Numeric
  def is_between(floor, top)
    self <= top && self >= floor
  end
end

class PartialBlock < Proc

  attr_accessor :block, :param_types

  def initialize(param_types, &block)
    @block = block
    @param_types = param_types
  end

  def call(*parameters)
    raise ArgumentTypeException unless matches(*parameters)
    @block.call(*parameters)
  end

  def matches(*arguments)
    return false unless valid?(arguments, @param_types)
    param_types = to_types(@param_types)
    arguments.zip(param_types).all? do |argument, type|
      argument.is_a? type
    end
  end

  def to_types(some_wrappers)
    raw_types = some_wrappers.select { |w| !w.eql? DefaultParameter }
    wrappers = some_wrappers.select { |w| w.eql? DefaultParameter }
    wrappers.map { |dp| dp.type } + raw_types
  end

  def valid?(arguments, types)
    mandatory_types = types.select { |t| !t.eql? DefaultParameter }
    arguments.count.is_between(mandatory_types.count, types.count)
  end

end