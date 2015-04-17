module MultiMethods

  def crear_metodo
    #Envío a la clase el método 'define_method', con el nombre del método y su lógica en forma de bloque.
    #FIXME debería llamar a class? o sólo self funciona? Y los que incluyan a este módulo?
    self.send(:define_method, nombre_metodo, bloque)
  end

  def partial_def (nombre_metodo, lista_de_tipos, &bloque)
    #En algún momento tengo que llamar a 'crear_metodo'
  end

end