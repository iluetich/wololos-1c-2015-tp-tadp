require 'rspec'
require_relative '../src/partial_block'
require_relative '../src/exceptions/exceptions'

describe "ContextUp" do

  before(:all) do
    @hello_block = PartialBlock.new([String]) {|who| "Hello #{who}!"}
    @array_block = PartialBlock.new([Object,Object]) {|a,b| [a,b] }
    @pi_block = PartialBlock.new([]) {3.14159265359}
    @sumador_block = PartialBlock.new([Integer, Integer]) {|n, m| n + m}
    @exploding_block = PartialBlock.new([Array, Symbol]) {|array, simbolo| "sarazaza"}
  end

  describe "Calling PartialBlocks with correct parameters" do

    it "Devuelve un Hello mas parámetro String" do
      expect(@hello_block.call("mundo")).to eq("Hello mundo!")
    end

    it "Devuelve un array de 2 Object" do
      expect(@array_block.call(2,5)).to eq([2,5])
      expect(@array_block.call("hola", 200)).to eq(["hola", 200])
    end

    it "Devuelve 'pi' sin asignarle parámetros" do
      expect(@pi_block.call).to eq(3.14159265359)
    end

    it "Devuelve la suma de 2 y 3, que es 5" do
      expect(@sumador_block.call(2,3)).to eq(5)
    end

  end

  describe "Calling PartialBlocks with incorrect parameters" do
    it "Si llamo a un bloque con menos parámetros no matchea" do
      expect(@exploding_block.matches(10)).to eq(false)
    end

    it "Si llamo a un bloque con más parámetros no matchea" do
      expect(@exploding_block.matches("Hola", Object.new, 1000)).to eq(false)
    end

    it "Si llamo a un bloque con parámetros de tipos erróneos tira ArgumentsTypeException" do
      expect { @exploding_block.call(10, "super saraza") }.to raise_error(ArgumentTypeException)
      expect { @exploding_block.call("Hola", 2) }.to raise_error(ArgumentTypeException)
    end

  end
end