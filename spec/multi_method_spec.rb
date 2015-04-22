require 'rspec'
require_relative '../src/multi_method'

Object.include(MultiMethods)

class ClaseParaTest
  def suma(a, b)
    a + b
  end
end

class ClaseBlah < ClaseParaTest
  #vacio
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
    ClaseParaTest.partial_def(:sumar_numeros, [Numeric, Numeric]) {|n, m| self.suma(n,m)}
    ClaseParaTest.partial_def(:metodo_loco,[Numeric]) {|n1| n1 * 1}
    ClaseBlah.partial_def(:suma,[Numeric]) {|a| a}
    @instancia_loca = ClaseBlah.new
    @instancia = ClaseParaTest.new
    @objeto = Object.new
  end

  describe "Tests de ejecución de multimetodos definidos en la clase" do

    it "Si llamo un multimétodo no definido, tira excepcion" do
      expect {@instancia.concatenar(1,2,3)}.to raise_exception
    end

    it "Se ejecuta el mas cercano" do
      expect(@instancia.concat(2.0,4.0)).to eq(0.5)
      expect(@instancia.concat(2,3)).to eq(5)
      expect(@instancia.concat("hola", 2)).to eq("holahola")
      expect(@instancia.nacho(1,1,1)).to eq(3)
    end

    it "Ejemplo del TP" do
      expect(@instancia.concat("Hello", 2)).to eq("HelloHello")
      expect(@instancia.concat(Object.new, 3)).to eq("Objetos concatenados")
    end

    it "3 multimetodos con la misma firma se sobre-escriben" do
      expect(@instancia.metodo_loco(3)).to eq(3)

      ClaseParaTest.partial_def(:metodo_loco,[Numeric]) {|n1| n1 *2}
      expect(@instancia.metodo_loco(3)).to eq(6)

      ClaseParaTest.partial_def(:metodo_loco,[Numeric]) {|n1| n1 * n1}
      expect(@instancia.metodo_loco(3)).to eq(9)
    end

    it "Las instancias responden a los multimetodos" do
      #TODO falta extender respond_to? a 3 parámetros. (ver ejemplo de TP)
      expect(@instancia.respond_to? :concat).to eq(true)
      expect(@instancia.respond_to? :nacho).to eq(true)
      expect(@instancia.respond_to? :concatenar).to eq(false)
    end

    it "Invocar a self dentro de un multimetodo funciona" do
      expect(@instancia.sumar_numeros(1,1)).to eq(2)
    end

  end

  describe "Tests de ejecución sobre herencia de clases" do
    it "Funciona method lookup" do
      expect(@instancia_loca.suma(1,2)).to eq(3)
    end
  end
end