;;; Antonio Coín Castro.
;;; Ejercicio 8: Escritura en archivos.

(deffacts Fichero
  (NombreFichero datos.txt)
)

; Abrimos el fichero para escribir (modo append)
(defrule Abrir
  (declare (salience 1))
  (WRITE $?)
  (NombreFichero ?d)
  (not (Abierto))
  =>
  (open ?d file "a")
  (assert (Abierto))
)

; NOTA: Podríamos escribir directamente el contenido entero del vector
; con el wildcard $?contenido, pero en ese caso se imprimen también unos
; paréntesis automáticamente. Es por esto que implementamos una escritura
; palabra a palabra.

; Procesamos una instrucción WRITE cada vez, para que no se
; mezclen si tenemos varias.
(defrule Escribir_vector
  (declare (salience -1))
  ?f <- (WRITE $?contenido)
  =>
  (retract ?f)
  (assert (Escribir ?contenido))
)

; Escribimos a un fichero
(defrule Escribir
  ?f <- (Escribir ?elem $?resto)
  =>
  (printout file ?elem " ")
  (retract ?f)
  (assert (Escribir ?resto))
)

; Cerramos el fichero
(defrule Cerrar
  ?f <- (Escribir)
  ?g <- (Abierto)
  =>
  (printout file crlf)
  (close file)
  (retract ?f ?g)
)
