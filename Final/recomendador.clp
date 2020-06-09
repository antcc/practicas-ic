;;;;;;;;;;;;;;;; SISTEMA EXPERTO RECOMENDADOR ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Sistema experto para resolver el problema de recomendar asignaturas
;;; y ramas de Ingenieria Informatica como lo haria un estudiante.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ingenieria del Conocimiento. Curso 2019/20.
;;; Antonio Coin Castro.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Iniciamos el sistema preguntando que quiere hacer el usuario
(deffacts Inicializar_menu_principal
  (Preguntar_inicial)
)

; Reseteamos el conocimiento
(defrule Resetear
  ?f <- (Resetear)
  =>
  (retract ?f)
  (reset)
)

; Hacemos la pregunta del menu principal
(defrule Preguntar_menu_principal
  ?f <- (Preguntar_inicial)
  =>
  (printout t "Elige una de estas opciones:" crlf)
  (printout t "  a] Recomendar ramas" crlf "  b] Recomendar asignaturas" crlf "  c] Salir" crlf)
  (printout t "Opcion elegida: ")
  (retract ?f)
  (assert (OpcionElegidaMenu (read)))
)

; Comprobamos que la opción esté entre las permitidas
(defrule Opcion_no_valida_menu_principal
  ?f <- (OpcionElegidaMenu ?r & ~a & ~b & ~c)
  =>
  (printout t "La opcion " ?r " no es valida." crlf)
  (retract ?f)
  (assert (Preguntar_inicial))
)

; Activamos subsistema A: recomendar rama
(defrule Modulo_recomendar_rama
  ?f <- (OpcionElegidaMenu a)
  =>
  (retract ?f)
  (assert (modulo PREGUNTAR_RECOMENDAR_RAMA))
)

; Activamos subsistema B: recomendar asignaturas
(defrule Modulo_recomendar_asig
  ?f <- (OpcionElegidaMenu b)
  =>
  (retract ?f)
  (assert (modulo MENU_RECOMENDAR_ASIG))
)
