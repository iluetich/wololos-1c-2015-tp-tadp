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
    return false unless valid?(arguments, @param_types)
    puts "Checking... " + arguments.to_s + " with " + @param_types.to_s
    arguments.zip(@param_types).all? do |argument, type|
      argument.is_a? type
    end
  end

  def valid?(arguments, types)
    mandatory_types = types.select { |t| !t.eql? DefaultParameter }
    arguments.has_many_elements_as?(mandatory_types) || arguments.has_many_elements_as?(types)
  end

end