require 'rspec'
require_relative '../src/multi_method'

Object.include(MultiMethods)

class ClaseParaTest
  def suma(a, b)
    a + b
  end
  def heredame_normal
    "Heredado Normal"
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
    ClaseParaTest.partial_def(:heredame, []) { "Me heredaste! =)" }
    ClaseParaTest.partial_def(:heredame_partial, []) { "Me heredaste! =)" }
    ClaseBlah.partial_def(:magia,[Numeric]) {|a| a}
    @instancia_de_subclase = ClaseBlah.new
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
      expect(@instancia.respond_to? :concat).to eq(true)
      expect(@instancia.respond_to? :nacho).to eq(true)
      expect(@instancia.respond_to? :concatenar).to eq(false)
      expect(@instancia.respond_to? :suma).to eq(true)
      expect(@instancia.respond_to?(:concat, false, [Integer,Integer])).to eq(true)
      expect(@instancia.respond_to?(:concat, false, [])).to eq(false)
      expect(@instancia.respond_to?(:nacho, false, [Integer, String, Integer])).to eq(true)
      expect(@instancia.respond_to? :eql?).to eq(true)
    end

    it "Invocar a self dentro de un multimetodo funciona" do
      expect(@instancia.sumar_numeros(1,1)).to eq(2)
    end
  end

  describe "Tests de ejecución de multimetodos definidos en la INSTANCIA" do
    it "Definir un nuevo multimetodo en una instancia" do
      @instancia.partial_def(:multiplicar,[Integer,Integer]) do |a,b|
        a*b
      end
      expect(@instancia.multiplicar(2,3)).to eq(6)
    end

    it "Redefinir un multimetodo en una instancia modificando uno que estaba definido en la clase" do
      expect(@instancia.concat(2,3)).to eq(5)
      @instancia.partial_def(:concat,[Integer,Integer]) do |a,b|
        a*b
      end
      expect(@instancia.concat(2,3)).to eq(6)
    end

    it "Si redefino un multimetodo en una instancia no pierdo el de mi superclase" do
      @instancia.partial_def(:sumar_numeros, [Integer,Integer,Integer]) { |a,b,c| a+b+c}
      a = ClaseParaTest.new
      expect(@instancia.sumar_numeros(1,1,1)).to eq(3)
      expect(@instancia.sumar_numeros(1,1)).to eq(2)
      expect(a.sumar_numeros(1,1)).to eq(2)
    end

    it "Definir un multimetodo solo para una instancia sin que sea para toda la clase" do
      a = ClaseParaTest.new
      b = ClaseParaTest.new
      a.partial_def(:concat,[Integer,Integer]) do |a,b|
        a*b
      end
      expect(a.concat(2,3)).to eq(6)
      expect(b.concat(2,3)).to eq(5)
    end
  end

  describe "Tests de ejecución sobre herencia de clases" do
    it "Invocar a self dentro de un multimétodo" do
      expect(@instancia.sumar_numeros(1,2)).to eq(3)
    end

    it "Se heredan los multimétodos" do
      #instancia_de_subclase solo tiene definido el multimétodo 'magia'
      expect(@instancia_de_subclase.concat(1,1)).to eq(2)
      expect(@instancia_de_subclase.nacho(1,1,1)).to eq(3)
      expect(@instancia_de_subclase.heredame).to eq("Me heredaste! =)")
    end

    it "Se redefine un metodo comun en una subclase con multimetodo heredado" do
      expect(ClaseBlah.new.heredame_partial).to eq("Me heredaste! =)")
      class ClaseBlah
        def heredame_partial
          "Redefinido!"
        end
      end
      expect(ClaseBlah.new.heredame_partial).to eq("Redefinido!")
    end

    it "Se redefine un multimetodo en una subclase con metodo comun heredado" do
      expect(ClaseBlah.new.heredame_normal).to eq("Heredado Normal")
      ClaseBlah.partial_def(:heredame_normal,[]) {"Redefinido Partial!"}
      expect(ClaseBlah.new.heredame_normal).to eq("Redefinido Partial!")
    end

    it "Se redefine un multimetodo en una sublcase con multimetodo heredado y complementa" do
        expect(ClaseBlah.new.heredame).to eq("Me heredaste! =)")
        ClaseBlah.partial_def(:heredame,[String]) {|string| string}
        ClaseBlah.partial_def(:heredame,[String,Fixnum]) do |s,n|
          s*n
        end
        expect(ClaseBlah.new.heredame("Redefinido complemento!")).to eq("Redefinido complemento!")
        expect(ClaseBlah.new.heredame("Complementado ",3)).to eq("Complementado Complementado Complementado ")
        expect(ClaseBlah.new.heredame).to eq("Me heredaste! =)")
    end

    it "Se redefine un multimetodo en una subclase con metodo comun heredado" do
      expect(ClaseBlah.new.heredame).to eq("Me heredaste! =)")
      ClaseBlah.partial_def(:heredame,[]) {"Sobreescrito!!!"}
      expect(ClaseBlah.new.heredame).to eq("Sobreescrito!!!")
      expect(ClaseParaTest.new.heredame).to eq("Me heredaste! =)")
    end




  end
end