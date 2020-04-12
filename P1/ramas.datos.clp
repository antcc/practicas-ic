;;;;;;;;;;;;;;;; RECOMENDACION DE UNA RAMA (DATOS) ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Recogemos los hechos estaticos que representan el problema
;;; de recomendar una rama de Ingenieria Informatica como lo
;;; haria un estudiante.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ingenieria del Conocimiento. Curso 2019/20.
;;; Antonio Coin Castro.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;
;;;;;; CONTROL DE LOS MODULOS
;;;;;;

(deffacts Control_modulos
(Lista_modulos Inicializar Preguntar Puntuar Aconsejar)
)

(defrule Avanza_modulo
?f <- (Lista_modulos ?siguiente $?resto)
=>
(focus ?siguiente)
(retract ?f)
(assert (Lista_modulos $?resto))
)


;;;;;;
;;;;;; MODULO PARA HECHOS ESTATICOS
;;;;;;

(defmodule Hechos
  (export deftemplate ?ALL))

  ;;;;;; INFORMACION DE LAS RAMAS

  ;;; Definimos las ramas consideradas, sus nombres y una descripcion.

  (deffacts Ramas
  (Rama CSI)
  (Rama IS)
  (Rama IC)
  (Rama SI)
  (Rama TI)
  )

  (deffacts Nombres_ramas
  (Nombre_rama CSI "Computacion y Sistemas Inteligentes")
  (Nombre_rama IS "Ingenieria del Software")
  (Nombre_rama IC "Ingenieria de Computadores")
  (Nombre_rama SI "Sistemas de Informacion")
  (Nombre_rama TI "Tecnologias de la Informacion")
  )

  (deffacts Descripciones_ramas
  (Descripcion CSI (format nil "En esta rama hay una gran exigencia tanto a nivel de matematicas
  como de programacion, pero se puede sobrellevar siendo trabajador. Deberias tener una buena nota.
  Es una buena forma de acabar como docente."))
  (Descripcion IS (format nil "Si te gusta la programacion y no tienes ningun otro interes
  particular, esta rama es una buena eleccion, aunque no vas a ver mucho sobre hardware.
  No viene mal tener buena nota."))
  (Descripcion IC (format nil "La rama del hardware por excelencia. Si quieres huir de las
  matematicas y eres trabajador, las empresas lo valoraran bastante."))
  (Descripcion SI (format nil "En esta rama se tocan temas tanto de programacion, como de
  tecnologias web y de bases de datos. Un buen popurri que te permitira preparar unas oposiciones
  para trabajar en la administracion."))
  (Descripcion TI (format nil "En esta rama se valora el interes por tecnologias mas alla de la
  programacion pura, en la que no es del todo imprescindible ser muy trabajador o tener buena nota.
  No veras muchas matematicas y podras trabajar donde quieras."))
  )


  ;;;;;; FACTORES PARA ELECCION DE RAMA

  ;;; Hay una serie de factores que nos ayudan a tomar la decision.
  ;;; Inicialmente no conocemos el valor de ninguno de ellos.
  ;;;
  ;;; El experto utiliza el grado de afinidad con las matematicas,
  ;;; que es un numero flotante entre 0 y 10. Tras una adecuada conversion,
  ;;; se representa por (Evaluacion mat bajo|medio|alto).
  ;;;
  ;;; El experto utiliza la informacion sobre si le gusta el hardware,
  ;;; a lo que puede contestar Si (S), No (N) o No se (NS).
  ;;; Se representa por (Evaluacion hw S|N|NS)
  ;;;
  ;;; El experto utiliza el grado de afinidad con la programacion,
  ;;; que es un numero flotante entre 0 y 10. Tras una adecuada conversion,
  ;;; se representa por (Evaluacion prog bajo|medio|alto).
  ;;;
  ;;; El experto utiliza la nota media actual del usuario,
  ;;; que es un numero flotante entre 5 y 10. Tras una adecuada conversion,
  ;;; se representa por (Evaluacion nota bajo|medio|alto).
  ;;;
  ;;; El experto utiliza la informacion sobre si es trabajador
  ;;; a lo que puede contestar Si (S), No (N) o No se (NS).
  ;;; Se representa por (Evaluacion trabajador S|N|NS)
  ;;;
  ;;; El experto utiliza la informacion sobre si le gustan las tecnologias web
  ;;; a lo que puede contestar Si (S), No (N) o No se (NS).
  ;;; Se representa por (Evaluacion web S|N|NS)
  ;;;
  ;;; El experto utiliza la informacion sobre donde quiere trabajar en un futuro
  ;;; a lo que puede contestar Docencia (D), Adm. Publica (P), Empresa (E) o No se (NS).
  ;;; Se representa por (Evaluacion futuro D|P|E|NS)
  ;;;
  ;;; El experto utiliza la informacion sobre si le gustan las bases de datos
  ;;; a lo que puede contestar Si (S), No (N) o No se (NS).
  ;;; Se representa por (Evaluacion bbdd S|N|NS)

  (deffacts Evaluacion_inicial
  (Evaluacion mat desconocido)
  (Evaluacion hw desconocido)
  (Evaluacion prog desconocido)
  (Evaluacion nota desconocido)
  (Evaluacion trabajador desconocido)
  (Evaluacion web desconocido)
  (Evaluacion futuro desconocido)
  (Evaluacion bbdd desconocido)
  )

  ;;; Expresion en lenguaje natural de las distintas cosas que contribuyen
  ;;; a la eleccion de rama.

  (deffacts Equivalencia_texto_factores
  (Equivalencia_texto mat "Tu grado de interes por las matematicas es ")
  (Equivalencia_texto hw "Te gusta el hardware: ")
  (Equivalencia_texto prog "Tu grado de interes por la programacion es ")
  (Equivalencia_texto nota "Tu nota media es ")
  (Equivalencia_texto trabajador "Eres trabajador: ")
  (Equivalencia_texto web "Te gustan las tecnologias web: ")
  (Equivalencia_texto futuro "En el futuro quieres trabajar en: " )
  (Equivalencia_texto bbdd "Te interesan las bases de datos: ")
  )


  ;;;;;; CONTRIBUCION A LAS RAMAS

  ;;; Definimos ahora una serie de factores que contribuyen a la eleccion de rama,
  ;;; tanto numericos como categoricos. La contribucion viene marcada por un factor
  ;;; entre 0.5 y 1 (se considera que un factor menor de 0.5 es igual que no contribuir).
  ;;; Todos los factores tendran posteriormente asignado un valor numerico entre 0 y 10,
  ;;; que al multiplicarlo por su factor de contribucion representara la contribucion real.

  (deffacts Contribuciones
  ; CSI
  (Contribuye mat CSI 1)
  (Contribuye prog CSI 0.75)
  (Contribuye nota CSI 0.75)
  (Contribuye trabajador CSI 0.75)
  (Contribuye docencia CSI 0.5)
  ; IS
  (Contribuye mat IS 0.75)
  (Contribuye prog IS 1)
  (Contribuye nota IS 0.75)
  (Contribuye trabajador IS 0.5)
  (Contribuye docencia IS 0.5)
  (Contribuye empresa IS 0.5)
  ; IC
  (Contribuye hw IC 1)
  (Contribuye prog IC 0.5)
  (Contribuye trabajador IC 0.75)
  (Contribuye empresa IC 1)
  ; SI
  (Contribuye prog SI 0.75)
  (Contribuye trabajador SI 0.75)
  (Contribuye web SI 0.75)
  (Contribuye publica SI 1)
  (Contribuye bbdd SI 1)
  ; TI
  (Contribuye prog TI 0.5)
  (Contribuye web TI 1)
  (Contribuye publica TI 1)
  (Contribuye empresa TI 1)
  (Contribuye bbdd TI 0.5)
  )

  ;;; Del mismo modo se definen contribuciones "inversas" con un factor en (0, 2],
  ;;; haciendo que la contribucion de algunos factores sea inversamente proporcional
  ;;; cuando el valor del factor sea bajo.

  (deffacts Contribuciones_inversas
  ; CSI
  (Contribuye_inv hw CSI 1)
  (Contribuye_inv web CSI 0.9)
  ; IS
  (Contribuye_inv hw IS 1.5)
  (Contribuye_inv bbdd IS 0.75)
  ; IC
  (Contribuye_inv mat IC 1.5)
  (Contribuye_inv web IC 1)
  (Contribuye_inv bbdd IC 1)
  ; SI
  (Contribuye_inv mat SI 1.5)
  (Contribuye_inv hw SI 1)
  ; TI
  (Contribuye_inv mat TI 2)
  (Contribuye_inv hw TI 1)
  (Contribuye_inv nota TI 1)
  (Contribuye_inv trabajador TI 0.75)
  )

  ;;;;;; PUNTUACION

  ;;; Todas las ramas tienen una puntuacion acumulada, resultado de sumar
  ;;; las contribuciones de los distintos factores. Inicialmente es 0.

  (deffacts Puntuacion_inicial
  (Puntuacion CSI 0)
  (Puntuacion IS 0)
  (Puntuacion IC 0)
  (Puntuacion SI 0)
  (Puntuacion TI 0)
  )

  ;;;;;; MOTIVOS

  ;;; Almacenaremos por cada rama los motivos que nos llevan a escogerla.
  ;;; Inicialmente son vacios.

  (deffacts Motivos_iniciales
  (Motivo CSI "")
  (Motivo IS "")
  (Motivo IC "")
  (Motivo SI "")
  (Motivo TI "")
  )
