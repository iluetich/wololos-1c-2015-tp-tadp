require 'rspec'
require_relative '../src/multi_method'
#require_relative '../src/overload_module'

describe "Casos de prueba de definiciones parciales" do
  it "si sobre-cargo un mensaje 2 veces, tengo 2 multimetodos" do
    class TestingA
      extend MultiMethod
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
    end
    expect(TestingA.multimetodos.count).to eq(2)
  end

  it "si llamo un multimétodo no definido, tira excepcion" do
    class TestingB
      extend MultiMethod
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
    end
    expect { TestingB.new.nacho(1,2,3) }.to raise_exception
  end

  it "Si defino un multi-método se ejecuta aquel con los parámetros correctos" do
    class TestingC
      extend MultiMethod
      partial_def(:concat, [String, Integer, Integer]) {|a, b, c| a * (b + c)}
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
    end
    expect(TestingC.new.concat('Hola', 3)).to eq("HolaHolaHola")
  end

  it "Si defino un multi-metodo con parámetros generales se ejecuta el más cercano" do
    class TestingD
      extend MultiMethod
      partial_def(:concat, [Object, Integer]) {|a, b| a.to_s + b.to_s}
      partial_def(:concat, [Numeric, Numeric]) {|a, b| a / b}
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
      partial_def(:nacho, [Integer, Object, Integer]) { |a, b, c| "Esto no debería aparecer"}
      partial_def(:nacho, [Integer, Integer, Integer]) {|a, b, c| a + b + c}
    end

    instancia = TestingD.new
    objeto = Object.new

    expect(instancia.concat(2.0,4.0)).to eq(0.5)
    expect(instancia.concat(2,3)).to eq(5)
    expect(instancia.concat("hola", 2)).to eq("holahola")
    expect(instancia.concat(objeto, 100)).to eq(objeto.to_s + 100.to_s)
    expect(instancia.nacho(1,1,1)).to eq(3)
    expect(instancia.concat(objeto, 100)).to eq(objeto.to_s + 100.to_s)
  end

  it "Si defino un multi-método con self entonces referencia a la instancia" do
    class TestingE
      extend MultiMethod
      def sumar a, b
        a + b
      end
      partial_def(:suma_parcial, [Numeric, Numeric]) {|a, b| self.sumar(a,b)}
      partial_def(:suma_parcial, [Numeric, Numeric, Numeric]) {|a, b, c| a + self.sumar(b,c)}
    end
    instancia = TestingE.new
    expect(instancia.suma_parcial(10,10)).to eq(20)
    expect(instancia.suma_parcial(10,10,10)).to eq(30)
  end


  it "Ejemplo del TP" do
    class EjemploTP
      extend MultiMethod
      partial_def :concat, [String, Integer] do |s1,n|
        s1 * n
      end
      partial_def :concat, [Object, Object] do |o1, o2|
        "Objetos concatenados"
      end
    end
    instancia = EjemploTP.new
    expect(instancia.concat("Hello", 2)).to eq("HelloHello")
    expect(instancia.concat(Object.new, 3)).to eq("Objetos concatenados")
  end

end
