require 'rspec'
require_relative '../src/partial_block'


describe "PartialBlock tests" do

  it "Devuelve un Hello mas parámetro String" do
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

  it "Devuelve 'pi' sin asignarle parámetros" do
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