require 'rspec'
require_relative '../src/multi_method'
#require_relative '../src/overload_module'

class ClaseParaTest
  extend MultiMethods
  def suma(a, b)
    a + b
  end

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
    @instancia = ClaseParaTest.new
    @objeto = Object.new
  end

  describe "Casos de prueba de definiciones parciales" do

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

    it "3 partial def con la misma firma(nombre y cantidad y tipo de datos se pisan" do
      expect(@instancia.metodo_loco(3)).to eq(3)

      ClaseParaTest.partial_def(:metodo_loco,[Numeric]) {|n1| n1 *2}
      expect(@instancia.metodo_loco(3)).to eq(6)

      ClaseParaTest.partial_def(:metodo_loco,[Numeric]) {|n1| n1 * n1}
      expect(@instancia.metodo_loco(3)).to eq(9)
    end

    it "Las instancias responden a los multimetodos" do
      expect(@instancia.respond_to? :concat).to eq(true)
      expect(@instancia.respond_to? :nacho).to eq(true)
      expect(@instancia.respond_to? :concatenar).to eq(false)
    end

=begin  TODO Esto no está funcionando.
    it "Invocar a self dentro de un multimetodo funciona" do
      expect(@instancia.sumar_numeros(1,1)).to eq(2)
    end
=end
  end
end