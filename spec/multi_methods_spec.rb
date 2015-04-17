require 'rspec'

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