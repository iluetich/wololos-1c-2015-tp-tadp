class Overload

  attr_accessor :selector, :partial_block

  def initialize(selector, partial_block)
    @selector = selector
    @partial_block = partial_block
  end

  def param_types
    @partial_block.param_types
  end

  def accepts?(*arguments)
    @partial_block.matches(*arguments)
  end

  def identical_to?(overloads)
    return false unless valid? overloads
    param_types.zip(overloads.param_types).all? do |own_param_type, param_type|
      param_type.ancestors.include?(own_param_type)
    end
  end

  def valid?(overloads)
    @selector.eql?(overloads.selector) && param_types.has_many_elements_as?(overloads.param_types)
  end

  def call(*parameters)
    @partial_block.call(*parameters)
  end

  def distance_to_params(*params)
    total_distance = 0
    params.zip(@partial_block.param_types).each_with_index do |param_with_type, index|
      total_distance += param_with_type[0].class.ancestors.index(param_with_type[1]) * (index + 1)
    end
    total_distance
  end

  def equal_to?(overload)
    @selector.eql?(overload.selector) && self.param_types.eql?(overload.param_types)
  end

end