(deftemplate asignatura
  (slot id)
  (slot nombre)
  (slot curso)
  (slot creditos (default 6))
  (slot dificultad (allowed-values baja media alta))
  (slot carga (allowed-values baja media alta))
  (slot tipo (allowed-values teorica aplicada))
  (slot programar (allowed-values baja media alta))
  (multislot areas (allowed-values IA BD DS RS WB HW))
)

; Definimos las opciones que tendrá el usuario
(deffacts Opciones
  (Opciones a b c)
)

(deffacts Equivalencias_cat
  (equivalencia_cat nota u1 5.0)
  (equivalencia_cat nota u2 8.0)
  (equivalencia_cat superados u1 80)
  (equivalencia_cat superados u2 160)
)

(deffacts Equivalencia_areas
  (equivalencia_area IA "Inteligencia artificial")
  (equivalencia_area BD "Bases de datos")
  (equivalencia_area DS "Desarrollo de software")
  (equivalencia_area RS "Redes")
  (equivalencia_area WB "Tecnologias web")
  (equivalencia_area HW "Hardware")
)

(deffacts Asignaturas_favoritas
  (Asigantura_fav MAC)
  (Explicacion_fav MAC "Es la asignatura favorita del experto y la recomineda siempre.%n  Considera que es una asignatura esencial para todo ingenier@ informatic@,%n  a pesar de su dificultad")
)

(deffacts Por_defecto
  (Por_defecto programacion alta)
  (Por_defecto practicas media))

; Definimos las asignaturas que conoce el experto
(deffacts Asignaturas
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
    (areas IA DS))
  (asignatura
    (id AA)
    (nombre "Aprendizaje Automatico")
    (curso 3)
    (dificultad media)
    (carga alta)
    (tipo teorica)
    (programar alta)
    (areas IA))
  (asignatura
    (id MAC)
    (nombre "Modelos Avanzados de Computacion")
    (curso 3)
    (dificultad alta)
    (carga media)
    (tipo teorica)
    (programar baja)
    (areas IA))
)

; (regla #num antecedentes RESPUESTA1 VALOR1 RESPUESTA2 VALOR2 ...)
; (regla #num consecuente 1|(-1) CARACTERISTICA VALOR_AFECTADO)
(deffacts Reglas
  (regla 1 antecedentes nota M superados A)
  (regla 1 consecuente 1 dificultad alta)
  (regla 1 explicacion "si tal tal")
)
