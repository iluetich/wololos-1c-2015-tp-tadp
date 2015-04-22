require_relative '../src/exceptions/exceptions'
require_relative '../src/sobrecarga'
require_relative '../src/partial_block'

module MultiMethods

  def crear_multimetodo(nombre_multimetodo)
    if self.superclass==Object #Solo se cumple si self NO es una singleton class de instancia
      self.send(:define_method, nombre_multimetodo) { |*argumentos|
        begin
          comportamiento = self.class.obtener_partial_block_cercano(nombre_multimetodo, *argumentos).bloque
          instance_exec(*argumentos, &comportamiento)
        rescue NoSuchMultiMethodException
          #Seguir con el method LookUp
          super(*argumentos)
        end
      }
    else
      self.send(:define_method, nombre_multimetodo) { |*argumentos|
        begin
          comportamiento = self.singleton_class.obtener_partial_block_cercano(nombre_multimetodo, *argumentos).bloque
          instance_exec(*argumentos, &comportamiento)
        rescue NoSuchMultiMethodException
          #Seguir con el method LookUp
          super(*argumentos)
        end
      }
    end
  end

  def partial_def(nombre_multimetodo, lista_de_tipos, &bloque)
    if self.instance_of?(Class)
      destino = self #Porque estoy en una clase
    else
      destino = self.singleton_class #Porque estoy en una instancia
    end
    destino.sobre_cargar(Sobrecarga.new(nombre_multimetodo, PartialBlock.new(lista_de_tipos, &bloque)), nombre_multimetodo)
    destino.crear_multimetodo(nombre_multimetodo) unless destino.respond_to? nombre_multimetodo
  end

  def sobre_cargar(una_sobrecarga, nombre_multimetodo)
    self.multimetodos.delete_if{ |s| s.es_misma_firma(nombre_multimetodo, una_sobrecarga.partial_block) }
    self.agregar_sobre_carga(una_sobrecarga)
  end

  def agregar_sobre_carga(una_sobrecarga)
    self.multimetodos << una_sobrecarga
  end

  def multimetodos
    @lista_de_multimetodos = @lista_de_multimetodos || []
  end

  def select_sobre_cargas(nombre_sobrecarga, *argumentos)
    self.multimetodos.select { |s| s.nombre == nombre_sobrecarga && s.matches(*argumentos) }
  end

  def obtener_partial_block_cercano(nombre_sobre_carga, *argumentos)
    sobre_carga = self.select_sobre_cargas(nombre_sobre_carga, *argumentos).min_by { |m| m.distancia_a_parametros(*argumentos) }
    if sobre_carga.eql? nil
      raise NoSuchMultiMethodException
    end
    sobre_carga.partial_block
  end

end
