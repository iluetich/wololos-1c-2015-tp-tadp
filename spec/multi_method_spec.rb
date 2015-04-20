require 'rspec'
require_relative '../src/multi_method'
#require_relative '../src/overload_module'

class ClaseParaTest
  extend MultiMethods
  #vacía
end

describe ClaseParaTest do
  before(:all) do
    ClaseParaTest.partial_def(:nacho, [Integer, Integer, Integer]) {|a, b, c| a + b + c}
    ClaseParaTest.partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
    ClaseParaTest.partial_def(:concat, [String, Integer, Integer]) {|a, b, c| a * (b + c)}
    ClaseParaTest.partial_def(:nacho, [Integer, Object, Integer]) { |a, b, c| "Esto no debería aparecer"}
    ClaseParaTest.partial_def(:concat, [Numeric, Numeric]) {|a, b| a / b}
    ClaseParaTest.partial_def(:concat, [Object, Object]) {|o1, o2| "Objetos concatenados" }
    ClaseParaTest.partial_def(:concat, [String, Integer]) {|s1,n| s1 * n}
    @instancia = ClaseParaTest.new
    @objeto = Object.new
  end

  describe "Casos de prueba de definiciones parciales" do

    it "si llamo un multimétodo no definido, tira excepcion" do
      expect {@instancia.concatenar(1,2,3)}.to raise_exception
    end

    it "Si defino un multi-método se ejecuta aquel con los parámetros correctos" do
      expect(@instancia.concat('Hola', 3)).to eq("HolaHolaHola")
    end

    it "Si defino un multi-metodo con parámetros generales se ejecuta el más cercano" do
      expect(@instancia.concat(2.0,4.0)).to eq(0.5)
      expect(@instancia.concat(2,3)).to eq(5)
      expect(@instancia.concat("hola", 2)).to eq("holahola")
      expect(@instancia.nacho(1,1,1)).to eq(3)
    end

    it "Ejemplo del TP" do
      expect(@instancia.concat("Hello", 2)).to eq("HelloHello")
      expect(@instancia.concat(Object.new, 3)).to eq("Objetos concatenados")
    end



  end
end