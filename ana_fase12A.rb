#TODO: this file contains now the code for applying a rule. It needs to be modified in order to execute the learning task of the first phase

#class Numeric of Ruby
class Numeric
	#returns:: this number
	#This method is defined in the API of SketchUp in order to work with meters instead of inches. When this command is used, we are working without SkethUp,
	#so we do not need this conversion. We define thus this method for avoiding errors when the invocations of .m are done; since Ruby does not define it.
	#Obviously, when SketchUp is not being used, this method does not do anything, returning the same number.
	def m
		return self
	end
end

require "#{File.dirname(__FILE__)}/../main-structures"
require "#{File.dirname(__FILE__)}/../utils"
require "#{File.dirname(__FILE__)}/../sustainable-scheme-generator"
require 'csv' 

#Esta prueba sirve para lanzar un experimento bajo los siguientes parametros
#Los resultados que genera la prueba son almacenados en el directorio /fase1

#---------------------------------PARAMETROS DE LA PRUEBA------------------------
eco=false

alpha1 = 0.1
alpha2 = 0.01
epsilon1 = 0.2
epsilon2 = 0.1
gamma = 1
lambda = 0.5 #Valor original 0.5
n_episodes1 = 1500
n_episodes2 = 500
num_rasgos1 = 6 #Numero de rasgos usados en la funcion lineal, incluyendo el termino independiente
num_rasgos2 = 12
guarda_cada = 1 #Cada cuantos episodios guarda el método Sarsa o Q los coeficientes de las politicas en el fichero

peso_compacidad = 0.9
peso_perimetro = 0.1
recompensa_maxima1 = -27
recompensa_maxima2 = 9

ultimos_coeficientes1 = Array.new(num_rasgos1, 0.0)
ultimos_coeficientes2 = Array.new(num_rasgos2, 0.0)
#Variables para los test
cada = 1 #Cada cuantos episodios de entrenamiento se va a evaluar la politica
num_test_cada_politica = 1.0 #Numero de pruebas de cada evaluacion           

grafica_recompensas1 = Array.new(n_episodes1/cada, 0.0) #Array que almacena las recompensas con las que se implimentara la grafica
grafica_recompensas2 = Array.new(n_episodes2/cada, 0.0)
nombre_directorio_prueba1= "fase12A1/prueba1"
nombre_directorio_prueba2= "fase12A1/prueba2"

forma_inicial = "walls-axiom4.txt" 
directorio_fase1 = "#{Dir.pwd}/fase12A1/salida_fase1.txt"
directorio_fase2 = "#{Dir.pwd}/fase12A1/salida_fase2.txt" 


archivo_idf="C:\\Users\\anabelen\\Documents\\ecoShade\\Exercise2A.idf"
#------------------------------------------------------------------------------------------------


Shade.using_sketchup = false
#Create the project
ShadeUtils.create_default_project

#Set list of constraint names and classes
ShadeUtils.add_cg_names()

#Search for custom constraints
ShadeUtils.load_custom_constraints()

#Search for custom goals
ShadeUtils.load_custom_goals()

project_directory = "#{File.dirname(__FILE__)}/temp/project.txt" #A.Carga la gramática
project_directory.gsub!("/", "\\")

#Create the problem module for the phase 1
problem_module=Phase1ProblemModule.new(6,1,48, peso_compacidad, peso_perimetro, 90) #A.Phase1ProblemModule(nrasgos, lado pared, estadoFinal)


Shade.project.load(project_directory)
Shade.project.execution.reset
	
ls = LabelledShape.new(Array.new,Array.new) #A.Carga la forma inicial
ls.load(forma_inicial)
problem_module.set_state(State.new(ls.clone)) 


axiomas= Array.new(1,nil)
axiomas[0]= LabelledShape.new(Array.new,Array.new)
axiomas[0].load("#{Dir.pwd}/formasFase2/forma2.txt")

for i in 0..num_rasgos1-1
  ultimos_coeficientes1[i]=rand-0.5 #Numero aleatorio entre -0.5 y 0.5
end

for i in 0..num_rasgos2-1
  ultimos_coeficientes2[i]=rand-0.5 #Numero aleatorio entre -0.5 y 0.5
end

#=begin 14/02/2019
politica_fase1 = entrenamiento(alpha1,epsilon1,gamma,lambda,n_episodes1,problem_module,axiomas,
          false, #False=recompensa solo en estados finales
          #"#{Dir.pwd}/#{nombre_directorio_prueba}/politicas_fase2_testQ" #Directorios false para que no gaste tiempo en abrirlos
          false,
          #"#{Dir.pwd}/#{nombre_directorio_prueba}/recompensas_fase2_Q", 
          false,
          guarda_cada, ultimos_coeficientes1,cada,nombre_directorio_prueba1,num_test_cada_politica, grafica_recompensas1, archivo_idf)
       
puts "prueba politica"         
problem_module_fase1 = prueba_politica1(problem_module, politica_fase1, nombre_directorio_prueba1, recompensa_maxima1)
problem_module_fase1.save_shape_and_plot("#{Dir.pwd}/fase12A1/salidaI.txt")
puts "Acaba Fase 1"

#alcanza_maximo?(problem_module, politica_fase1, directorio_fase1, recompensa_maxima) Añadido 12/02 -- Borrar

#problem_module_fase1=Phase2ProblemModule.new(problem_module.get_state)
problem_module_fase1=Phase1ProblemModule.new(6,1,48, peso_compacidad, peso_perimetro, 90)
lsa = LabelledShape.new(Array.new,Array.new)
lsa.load("#{Dir.pwd}/30formas/forma21.txt")
problem_module_fase1.set_state(State.new(lsa))


pt=problem_module_fase1.clean_walls(Dir.pwd)
problem_module.set_state(State.new(pt.clone))
problem_module.save_shape_and_plot("#{Dir.pwd}/fase12A1/salida_prueba.txt")

#Comienza la fase 2: 
#1. Se almacena en un array todas las posibles posiciones donde puede localizarse la entrada
#2. Se recorre el array hasta encontrar una posición que permita que se cumplan todos los criterios (entrenamiento)
#3. Se genera una forma con la recompensa maxima
=begin

 #recompensa=0
 #while (recompensa != recompensa_maxima2)
  problem_module2=Phase2ProblemModule.new(problem_module.get_state)
  if(eco)
    puts "Comienzo Fase 2"
    puts "Coloca primera entrada"
  end
  #ac = problem_module2.posiciones_entrada
  #problem_module2.coloca_entrada(ac)
  
  problem_module2.save_shape_and_plot("#{Dir.pwd}/fase12A1/formaInicial1.txt")
  
  if(eco)
    puts "Entrenamiento Fase 2"
  end
  
  politica_fase2 = entrenamiento(alpha2,epsilon2,gamma,lambda,n_episodes2,problem_module2 ,axiomas,
          false, #False=recompensa solo en estados finales
          #"#{Dir.pwd}/#{nombre_directorio_prueba}/politicas_fase2_testQ" #Directorios false para que no gaste tiempo en abrirlos
          false,
          #"#{Dir.pwd}/#{nombre_directorio_prueba}/recompensas_fase2_Q",
          false,
          guarda_cada, ultimos_coeficientes2,cada,nombre_directorio_prueba2,num_test_cada_politica, grafica_recompensas2, archivo_idf)


  if(eco)
    puts "Comprueba si se alcanza valores óptimos Fase 2"
  end  
  
  #recompensa=alcanza_maximo?(problem_module2, politica_fase2, nombre_directorio_prueba2, recompensa_maxima)
  
  if(eco)
    puts "Genera forma Fase 2"
  end  
  
  
  puts "Prueba_politica"
  
  problem_module_fase2=prueba_politica2(problem_module2, politica_fase2, nombre_directorio_prueba2, recompensa_maxima2, archivo_idf)
  #problem_module_fase2B=prueba_politica2B(problem_module2, politica_fase2, nombre_directorio_prueba2, recompensa_maxima2)
  #problem_module_fase2C=prueba_politica2C(problem_module2, politica_fase2, nombre_directorio_prueba2, recompensa_maxima2)
#end


=end