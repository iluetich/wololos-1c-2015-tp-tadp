require 'rspec'
require_relative '../src/partial_block'
require_relative '../src/exceptions/exceptions'


describe "Calling PartialBlocks with correct parameters" do

  it "Devuelve un Hello mas parametro String" do
    helloblock = PartialBlock.new([String]) do |who|
      "Hello #{who}!"
    end
    expect(helloblock.call("mundo")).to eq("Hello mundo!")
  end

  it "Devuelve un array de 2 Object" do
    arrayblock = PartialBlock.new([Object,Object]) do |a,b|
      [a,b]
    end
    expect(arrayblock.call(2,5)).to eq([2,5])
    expect(arrayblock.call("hola", 200)).to eq(["hola", 200])
  end

  it "Devuelve 'pi' sin asignarle parametros" do
    pi = PartialBlock.new([]) do
      3.14159265359
    end
    expect(pi.call).to eq(3.14159265359)
  end

  it "Devuelve la suma de 2 y 3, que es 5" do
    sumador = PartialBlock.new([Integer, Integer]) do |n, m|
      n + m
    end
    expect(sumador.call(2,3)).to eq(5)
  end

end

describe "Calling PartialBlocks with incorrect parameters" do
  it "Si llamo a un bloque con menos parametros tira ArgumentsException" do
    bloque_a_romper = PartialBlock.new([Integer, String]) do |numero, palabra|
      numero * 2
    end
      expect { bloque_a_romper.call(10) }.to raise_error(ArgumentError)
  end

  it "Si llamo a un bloque con mas parametros tira ArgumentsException" do
    bloque_a_romper = PartialBlock.new([String, Object]) do |p, q|
      p
    end
    expect { bloque_a_romper.call("Hola", Object.new, 1000) }.to raise_error(ArgumentError)
  end

  it "Si llamo a un bloque con parametros de tipos erroneos tira ArgumentsTypeException" do
    bloque_a_estallar = PartialBlock.new([Integer, Integer]) do |a, b|
      a + b * a
    end
    expect { bloque_a_estallar.call(10, "super saraza") }.to raise_error(ArgumentTypeException)
  end

end