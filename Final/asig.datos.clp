(deftemplate asignatura
  (slot id)
  (slot nombre)
  (slot curso)
  (slot creditos (default 6))
  (slot dificultad (allowed-values baja media alta))
  (slot carga (allowed-values baja media alta))
  (slot tipo (allowed-values teorica practica))
  (slot programar (allowed-values baja media alta))
  (slot hardware (allowed-values si no) (default no))
  (multislot areas (allowed-values IA BD DS RS WB HW IT))
)

; Definimos las opciones que tendrá el usuario
(deffacts Opciones
  (Opciones a b c)
)

(deffacts Equivalencias_cat
  (equivalencia_cat nota u1 5)
  (equivalencia_cat nota u2 8)
  (equivalencia_cat horas u1 2)
  (equivalencia_cat horas u2 4)
)

(deffacts Equivalencia_areas
  (equivalencia_area IA "Inteligencia artificial")
  (equivalencia_area BD "Bases de datos")
  (equivalencia_area DS "Desarrollo de software")
  (equivalencia_area RS "Redes")
  (equivalencia_area IT "Informatica Teorica")
  (equivalencia_area WB "Tecnologias web")
  (equivalencia_area HW "Hardware")
)

(deffacts Asignaturas_favoritas
  (Asignatura_fav MAC)
  (Explicacion_fav MAC "Es la asignatura favorita del experto y la recomienda siempre.%n    Considera que es una asignatura esencial para todo ingenier@ informatic@, a pesar de su dificultad")
)

(deffacts Por_defecto
  (variable nota M)
  (variable horas M)
  (variable areas DS)
  (variable capacidad M)
  (variable programacion A)
  (variable practicas M))

; Definimos las asignaturas que conoce el experto
(deffacts Asignaturas
  (asignatura
    (id NPI)
    (nombre "Nuevos Paradigmas de Interaccion")
    (curso 4)
    (dificultad media)
    (carga alta)
    (tipo practica)
    (programar media)
    (hardware si)
    (areas IA DS HW))
  (asignatura
    (id VC)
    (nombre "Vision por Computador")
    (curso 4)
    (dificultad alta)
    (carga alta)
    (tipo teorica)
    (programar alta)
    (areas IA))
  (asignatura
    (id IC)
    (nombre "Ingeniera del Conocimiento")
    (curso 3)
    (dificultad baja)
    (carga media)
    (tipo teorica)
    (programar baja)
    (areas IA IT))
  (asignatura
    (id MAC)
    (nombre "Modelos Avanzados de Computacion")
    (curso 3)
    (dificultad alta)
    (carga media)
    (tipo teorica)
    (programar baja)
    (areas IT))
  (asignatura
    (id DGP)
    (nombre "Direccion y Gestion de Proyectos")
    (curso 4)
    (dificultad baja)
    (carga media)
    (tipo teorica)
    (programar baja)
    (areas DS BD))
  (asignatura
    (id MDA)
    (nombre "Metodologias de Desarrollo Agiles")
    (curso 4)
    (dificultad baja)
    (carga media)
    (tipo teorica)
    (programar baja)
    (areas DS BD))
  (asignatura
    (id DBA)
    (nombre "Desarrollo Basado en Agentes")
    (curso 4)
    (dificultad media)
    (carga alta)
    (tipo practica)
    (programar baja)
    (areas DS BD))
  (asignatura
    (id SG)
    (nombre "Sistemas Graficos")
    (curso 3)
    (dificultad media)
    (carga media)
    (tipo practica)
    (programar alta)
    (areas DS))
  (asignatura
    (id SIBW)
    (nombre "Sistemas de Informacion Basados en Web")
    (curso 3)
    (dificultad baja)
    (carga media)
    (tipo practica)
    (programar media)
    (areas DS WB BD))
  (asignatura
    (id DSD)
    (nombre "Desarrollo de Sistemas Distribuidos")
    (curso 3)
    (dificultad alta)
    (carga media)
    (tipo practica)
    (programar alta)
    (hardware si)
    (areas DS HW))
  (asignatura
    (id CPD)
    (nombre "Centros de Procesamiento de Datos")
    (curso 4)
    (dificultad baja)
    (carga media)
    (tipo practica)
    (programar media)
    (hardware si)
    (areas HW BD))
  (asignatura
    (id SE)
    (nombre "Sistemas Empotrados")
    (curso 4)
    (dificultad media)
    (carga baja)
    (tipo practica)
    (programar media)
    (hardware si)
    (areas DS HW))
  (asignatura
    (id TR)
    (nombre "Tecnologias de Red")
    (curso 4)
    (dificultad alta)
    (carga media)
    (tipo teorica)
    (programar baja)
    (areas RS))
  (asignatura
    (id AS)
    (nombre "Arquitectura de Sistemas")
    (curso 3)
    (dificultad baja)
    (carga media)
    (tipo teorica)
    (programar media)
    (hardware si)
    (areas DS HW))
  (asignatura
    (id SMP)
    (nombre "Sistemas con Microprocesadores")
    (curso 3)
    (dificultad media)
    (carga media)
    (tipo practica)
    (programar baja)
    (hardware si)
    (areas HW))
  (asignatura
    (id ACAP)
    (nombre "Arquitectura y Computacion de Altas Prestaciones")
    (curso 3)
    (dificultad alta)
    (carga media)
    (tipo practica)
    (programar media)
    (areas DS))
  (asignatura
    (id BDD)
    (nombre "Bases de Datos Distribuidas")
    (curso 4)
    (dificultad media)
    (carga media)
    (tipo practica)
    (programar media)
    (areas BD))
  (asignatura
    (id IN)
    (nombre "Inteligencia de Negocio")
    (curso 4)
    (dificultad media)
    (carga alta)
    (tipo teorica)
    (programar alta)
    (areas IA))
  (asignatura
    (id RI)
    (nombre "Recuperacion de la Informacion")
    (curso 4)
    (dificultad media)
    (carga baja)
    (tipo teorica)
    (programar media)
    (areas DS))
  (asignatura
    (id ABD)
    (nombre "Administracion de Bases de Datos")
    (curso 3)
    (dificultad media)
    (carga baja)
    (tipo practica)
    (programar baja)
    (areas BD))
  (asignatura
    (id PW)
    (nombre "Programacion Web")
    (curso 3)
    (dificultad baja)
    (carga baja)
    (tipo practica)
    (programar media)
    (areas WB DS))
  (asignatura
    (id SMD)
    (nombre "Sistemas Multidimensionales")
    (curso 3)
    (dificultad alta)
    (carga baja)
    (tipo practica)
    (programar media)
    (areas BD))
  (asignatura
    (id DAI)
    (nombre "Desarrollo de Aplicaciones para Internet")
    (curso 4)
    (dificultad baja)
    (carga baja)
    (tipo practica)
    (programar baja)
    (areas DS WB))
  (asignatura
    (id IV)
    (nombre "Infraestructura Virtual")
    (curso 4)
    (dificultad media)
    (carga alta)
    (tipo teorica)
    (programar baja)
    (areas DS))
  (asignatura
    (id SPSI)
    (nombre "Seguridad y Proteccion de los Sistemas Informaticos")
    (curso 4)
    (dificultad alta)
    (carga baja)
    (tipo teorica)
    (programar baja)
    (areas IT))
  (asignatura
    (id CUIA)
    (nombre "Computacion Ubicua e Inteligencia Ambiental")
    (curso 3)
    (dificultad baja)
    (carga media)
    (tipo practica)
    (programar media)
    (hardware si)
    (areas DS HW))
  (asignatura
    (id SWAP)
    (nombre "Servidores Web de Altas Prestaciones")
    (curso 3)
    (dificultad baja)
    (carga alta)
    (tipo practica)
    (programar baja)
    (areas WB))
  (asignatura
    (id TW)
    (nombre "Tecnologias Web")
    (curso 3)
    (dificultad baja)
    (carga media)
    (tipo practica)
    (programar media)
    (areas WB))
)

; (regla NUM antecedentes RESPUESTA1 VALOR1 RESPUESTA2 VALOR2 ...)
; (regla NUM consecuentes 1|-1 CARACTERISTICA VALOR_AFECTADO_1 VALOR_AFECTADO_2 ...)
(deffacts Reglas
  ; Dificultad (+)
  (regla 1 antecedentes nota M capacidad A)
  (regla 1 consecuentes 1 dificultad alta)
  (regla 1 explicacion "Es dificil, pero por tu gran capacidad de trabajo y tu nota media creo que no tendras problemas")
  (regla 2 antecedentes nota A capacidad A)
  (regla 2 consecuentes 1 dificultad alta)
  (regla 2 explicacion "Es dificil, pero por tu gran capacidad de trabajo y tu nota media creo que no tendras problemas")
  (regla 3 antecedentes capacidad A)
  (regla 3 consecuentes 1 dificultad media baja)
  (regla 3 explicacion "Es de dificultad media o baja, facilmente superable con tu capacidad de trabajo")
  (regla 4 antecedentes capacidad M)
  (regla 4 consecuentes 1 dificultad media baja)
  (regla 4 explicacion "Es de dificultad media o baja, no deberias tener problemas con tu capacidad de trabajo")
  (regla 5 antecedentes nota A capacidad B)
  (regla 5 consecuentes 1 dificultad media)
  (regla 5 explicacion "Es de dificultad media, aunque tu capacidad sea baja como tienes una muy buena nota creo que puedes superarla")
  (regla 6 antecedentes nota M capacidad B)
  (regla 6 consecuentes 1 dificultad media)
  (regla 6 explicacion "Es de dificultad media, aunque tu capacidad sea baja como tienes una buena nota creo que puedes superarla")
  (regla 7 antecedentes capacidad B)
  (regla 7 consecuentes 1 dificultad baja)
  (regla 7 explicacion "Es de dificultad baja, te la recomiendo porque tu capacidad de trabajo es baja")

  ; Carga (+)
  (regla 8 antecedentes horas A)
  (regla 8 consecuentes 1 carga alta media)
  (regla 8 explicacion "Tiene una carga media o alta, pero con las horas que le dedicas al estudio ira bien")
  (regla 9 antecedentes horas M)
  (regla 9 consecuentes 1 carga media baja)
  (regla 9 explicacion "Tiene una carga normal o baja, con las horas que le dedicas al estudio es suficiente para superarla")
  (regla 10 antecedentes horas B capacidad A)
  (regla 10 consecuentes 1 carga media baja)
  (regla 10 explicacion "Tiene una carga media o baja, aunque no le dedicas mucho tiempo al estudio como tienes gran capacidad de trabajo creo que te ira bien")
  (regla 11 antecedentes horas B capacidad M)
  (regla 11 consecuentes 1 carga baja)
  (regla 11 explicacion "Tiene una carga baja, te la recomiendo porque no le dedicas demasiado tiempo al estudio")
  (regla 12 antecedentes horas B capacidad B)
  (regla 12 consecuentes 1 carga baja)
  (regla 12 explicacion "Tiene una carga baja, te la recomiendo porque no le dedicas demasiado tiempo al estudio")

  ; Hardware (+)
  (regla 13 antecedentes programacion B practicas A)
  (regla 13 consecuentes 1 hardware si)
  (regla 13 explicacion "Toca temas de hardware, como no te apasiona la programacion pero si las aplicaciones practicas, quizas esto te guste")

  ; Programar (+)
  (regla 14 antecedentes programacion A)
  (regla 14 consecuentes 1 programar alta media)
  (regla 14 explicacion "Tiene un contenido medio o alto en programacion, acorde a tu gusto por ella (alto)")
  (regla 15 antecedentes programacion M)
  (regla 15 consecuentes 1 programar media)
  (regla 15 explicacion "Tiene un contenido medio en programacion, acorde a tu gusto por ella (medio)")
  (regla 16 antecedentes programacion B)
  (regla 16 consecuentes 1 programar baja)
  (regla 16 explicacion "Tiene un contenido bajo en programacion, ya que me has dicho que no te gusta mucho")

  ; Tipo (+)
  (regla 17 antecedentes practicas A)
  (regla 17 consecuentes 1 tipo practica)
  (regla 17 explicacion "Tiene un contenido esencialmente practico, como me has indicado que prefieres")
  (regla 18 antecedentes practicas M programar A)
  (regla 18 consecuentes 1 tipo practica)
  (regla 18 explicacion "Tiene un contenido esencialmente practico, creo que es una buena eleccion por tu interes medio en las practicas y tu interes alto en la programcion")
  (regla 19 antecedentes practicas B)
  (regla 19 consecuentes 1 tipo teorica)
  (regla 19 explicacion "Tiene un contenido esencialmente teorico, ya que me has dicho que las aplicaciones practicas no son lo tuyo")

  ;;;;;;;;

  ; Dificultad (-)
  (regla 20 antecedentes nota B capacidad B)
  (regla 20 consecuentes -1 dificultad media alta)
  (regla 20 explicacion "Es de dificultad media o alta, por tu nota y tu capacidad bajas prefiero no recomendartela")

  ; Carga (-)
  (regla 21 antecedentes horas B)
  (regla 21 consecuentes -1 carga alta)
  (regla 21 explicacion "Tiene una carga alta, por las horas que le dedicas al estudio prefiero no recomendartela")
  (regla 22 antecedentes horas B capacidad M)
  (regla 22 consecuentes -1 carga media)
  (regla 22 explicacion "Tiene una carga media, por las horas que le dedicas al estudio prefiero no recomendartela")
  (regla 23 antecedentes horas B capacidad B)
  (regla 23 consecuentes -1 carga media)
  (regla 23 explicacion "Tiene una carga media, por las horas que le dedicas al estudio prefiero no recomendartela")

  ; Hardware (-)
  (regla 24 antecedentes practicas B)
  (regla 24 consecuentes -1 hardware si)
  (regla 24 explicacion "Toca temas de hardware, como no tienes interes en cosas practicas creo que no es la mejor para ti")

  ; Programar (-)
  (regla 25 antecedentes programacion B)
  (regla 25 consecuentes -1 programar medio alto)
  (regla 25 explicacion "Hay que programar bastante, y me has dicho que esto no te gusta mucho")

  ; Tipo (-)
  (regla 26 antecedentes practicas B)
  (regla 26 consecuentes -1 tipo practica)
  (regla 26 explicacion "Es practica y me has dicho que eso no te gusta")
  (regla 27 antecedentes practicas A)
  (regla 27 consecuentes -1 tipo teorica)
  (regla 27 explicacion "Es teorica y me has dicho que prefieres mas bien cosas practicas")

)
