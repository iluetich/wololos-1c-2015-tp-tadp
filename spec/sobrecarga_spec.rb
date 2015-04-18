 require 'rspec'
require_relative '../src/partial_block'
require_relative '../src/sobrecarga'

describe "Tests sobre distancia de parámetros" do

  it "Distancia de Numeric a 3 es 2 y a 3.0 es 1" do
    b = PartialBlock.new([Numeric]) {|a| a+a}
    sobrecarga = Sobrecarga.new("sobrecarga_test", b)
    expect(sobrecarga.distancia_a_parametros(3)).to eq(2)
    expect(sobrecarga.distancia_a_parametros(3.0)).to eq(1)
  end

  it "Distancia de [Numeric, Integer] a (3.0, 3) es 3 y a (3, 3) es 4" do
    b = PartialBlock.new([Numeric, Integer]) {|a, b| "saraza" }
    sobrecarga = Sobrecarga.new("sobrecarga_test", b)
    expect(sobrecarga.distancia_a_parametros(3.0, 3)).to eq(3)
    expect(sobrecarga.distancia_a_parametros(3, 3)).to eq(4)
  end

end