require 'rspec'
require_relative '../src/exceptions/exceptions'
require_relative '../src/partial_block'
require_relative '../src/sobrecarga'

describe "ContextUp" do

  before(:all) do
    bloque_doble = PartialBlock.new([Numeric]) {|a| a + a}
    bloque_saraza = PartialBlock.new([Numeric, Integer]) {|a, b| "saraza"}
    @sobrecarga_doble = Sobrecarga.new(:matrix_recargado, bloque_doble)
    @sobrecarga_saraza = Sobrecarga.new(:matrix_recargado, bloque_saraza)
  end

  describe "Tests sobre igualdad de sobrecargas y matcheos con parametros" do
    it "Las sobrecargas 'doble' y 'saraza' no son misma firma" do
      expect(@sobrecarga_doble.sos_igual_a?(@sobrecarga_saraza)).to eq(false)
      expect(@sobrecarga_doble.sos_igual_a?(@sobrecarga_doble)).to eq(true)
    end

    it "Una lista de sub-tipos de los tipos de parametros de una sobrecarga son matcheables" do
      an_overload = Sobrecarga.new(:matrix_recargado, PartialBlock.new([Integer]) { })
      other_overload = Sobrecarga.new(:matrix_recargado, PartialBlock.new([Integer, Integer]) { })
      expect(@sobrecarga_doble.matcheas_con?(an_overload)).to eq(true)
      expect(@sobrecarga_saraza.matcheas_con?(other_overload)).to eq(true)
    end
  end

  describe "Tests sobre distancia de parametros" do

    it "Distancia de Numeric a 3 es 2 y a 3.0 es 1" do
      expect(@sobrecarga_doble.distancia_a_parametros(3)).to eq(2)
      expect(@sobrecarga_doble.distancia_a_parametros(3.0)).to eq(1)
    end

    it "Distancia de [Numeric, Integer] a (3.0, 3) es 3 y a (3, 3) es 4" do
      b = PartialBlock.new([Numeric, Integer]) {|a, b| "saraza" }
      sobrecarga = Sobrecarga.new("sobrecarga_test", b)
      expect(@sobrecarga_saraza.distancia_a_parametros(3.0, 3)).to eq(3)
      expect(@sobrecarga_saraza.distancia_a_parametros(3, 3)).to eq(4)
    end
  end
  describe "Tests sobre ejecucion" do
    it "Llamar a la sobrecarga_doble con un numero funciona" do
      expect(@sobrecarga_doble.call(0)).to eq(0)
      expect(@sobrecarga_doble.call(100)).to eq(200)
    end

    it "Llamar a la sobrecarga_saraza con 2 numeros funciona" do
      expect(@sobrecarga_saraza.call(1,1)).to eq("saraza")
      expect(@sobrecarga_saraza.call(100,21221)).to eq("saraza")
    end

    it "Llamar a las sobrecargas con parametros erroneos arroja exception" do
      expect {@sobrecarga_doble.call("Hola")}.to raise_error(ArgumentTypeException)
      expect {@sobrecarga_saraza.call}.to raise_error(ArgumentTypeException)
    end
  end
end
