require 'rspec'
require_relative '../src/multi_method'
require_relative '../src/overload_module'

describe "Casos de prueba de definiciones parciales" do
  it "si sobre-cargo un mensaje 2 veces, tengo 2 multimetodos" do
    class TestingA
      include MultiMethod
      extend OverloadModule
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
    end
    expect(TestingA.lista_de_multimetodos.count).to eq(2)
  end

  it "si llamo un multimétodo no definido, tira excepcion" do
    class TestingB
      include MultiMethod
      extend OverloadModule
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
    end
    expect { TestingB.new.nacho(1,2,3) }.to raise_exception
  end

  it "Si defino un multi-método se ejecuta aquel con los parámetros correctos" do
    class TestingC
      include MultiMethod
      extend OverloadModule
      partial_def(:concat, [String, Integer, Integer]) {|a, b, c| a * (b + c)}
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
    end
    expect(TestingC.new.concat('Hola', 3)).to eq("HolaHolaHola")
  end

  it "Si defino un multi-metodo con parámetros generales se ejecuta el más cercano" do
    class TestingD
      include MultiMethod
      extend OverloadModule
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
      partial_def(:concat, [Object, Integer]) {|a, b| a.name + b.name}
      partial_def(:nacho, [Integer, Integer, Integer]) {|a, b, c| a + b + c}
    end

    instancia = TestingD.new
    objeto = Object.new

    expect(instancia.concat(2,3)).to eq(5)
    #expect(instancia.concat("hola", 2)).to eq("holahola")
    #expect(instancia.concat(objeto, 100)).to eq(objeto.name + 100.name)
    #expect(instancia.nacho(1,1,1)).to eq(3)
  end
end
