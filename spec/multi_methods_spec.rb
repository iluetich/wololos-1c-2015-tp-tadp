require 'rspec'
require_relative '../src/multi_methods'
require_relative '../src/gilada'

describe "Definir un método en ejecución funciona como se espera" do
  it "defino a Roberto y no sabe sumar, si le pido sumar explota de rabia" do
    class Roberto
      #no sé sumar
    end
    instancia = Roberto.new
    expect { instancia.suma(1,2) }.to raise_error(NoMethodError)
  end

  it "Roberto no sabía sumar, pero ahora aprende" do
    class Roberto
      def aprender_a_sumar_dinamicamente
        self.class.send(:define_method, 'suma', proc { |a, b| a + b })
      end
    end
    instancia = Roberto.new
    instancia.aprender_a_sumar_dinamicamente
    expect(instancia.suma(1,2)).to eq (3)
  end
end

describe "Casos de prueba de definiciones parciales" do
  it "si sobre-cargo un mensaje 2 veces, tengo 2 multimetodos" do
    class A
      extend MultiMethods
      self.lista_de_multimetodos=[] #FIXME!
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
    end
    expect(A.lista_de_multimetodos.count).to eq(2)
  end

  it "si llamo un multimétodo no definido, tira excepcion" do
    class A
      extend MultiMethods
      self.lista_de_multimetodos=[] #FIXME!
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
    end
    expect { A.new.nacho(1,2,3) }.to raise_exception
  end

  it "Si defino un multimetodo se ejecuta aquel con los parametros correctos" do
    class A
      extend MultiMethods
      self.lista_de_multimetodos=[] #FIXME!
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
    end
    expect(A.new.concat("Hola", 3)).to eq("HolaHolaHola")
  end

  it "puedo sobre-cargar métodos en Ruby" do
    class A
      extend MultiMethods#FIXME !
      self.lista_de_multimetodos=[] #FIXME!
      partial_def(:concat, [Integer, Integer]) {|a, b| a + b}
      partial_def(:concat, [String, Integer]) {|a, b| a * b}
      partial_def(:concat, [Object, Integer]) {|a, b| a.name + b.name}
      partial_def(:nacho, [Integer, Integer, Integer]) {|a, b, c| a + b + c}
    end

    instancia = A.new
    objeto = Object.new

    #expect(instancia.concat("hola", 2)).to eq("holahola")
    #expect(instancia.concat(2,3)).to eq(5)
    expect(instancia.concat(objeto, 100)).to eq(objeto.name + 100.name)
    expect(instancia.nacho(1,1,1)).to eq(3)
  end
end
