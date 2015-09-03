class Array
  def has_many_elements_as?(other_array)
    count.eql? other_array.count
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
    return false unless arguments.has_many_elements_as?(@param_types)
    arguments.zip(@param_types).all? do |argument, type|
      argument.is_a? type
    end
  end

end