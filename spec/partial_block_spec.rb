require 'rspec'
require_relative '../src/partial_block'


describe "PartialBlock tests" do

  it "devuelve un hello mas parametro String" do

    helloblock= PartialBlock.new([String]) do |who|
      "Hello #{who}!"
    end

    expect(helloblock.call("mundo")).to eq("Hello mundo!")
  end

  it "devuelve un array dos parametros Object" do

    arrayblock= PartialBlock.new([Object,Object]) do |a,b|
      [a,b]
    end

    expect(arrayblock.call(2,5)).to eq([2,5])
  end

  it "devuelve pi sin parametros" do

    pi= PartialBlock.new([]) do
      3.14159265359
    end

    expect(pi.call).to eq(3.14159265359)
  end


end