module DefaultParameter

  def self.as(type)
    @type = type
  end

  def self.type
    @type ||= Object
  end
end

Object.include(DefaultParameter)