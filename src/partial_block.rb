class NumParametersExeption < RuntimeError
end

class TypeParametersExeption < RuntimeError
end



class PartialBlock

  def initialize(clase,&block)
    @bloque=block
    @clase=clase
  end

  def call(*algos)
      if self.matches(*algos)
        @bloque.call(*algos)
      else
        raise TypeParametersExeption, 'Diferente tipo de parametros'
      end
  end


  def matches(*algos)
    if algos.size==@clase.size
      i=0
      algos.all? do |algo|
        i+=1
        algo.is_a?(@clase[i-1])
      end
    else
      raise NumParametersExeption, 'Diferente cantidad de parametros'
    end
  end


end

