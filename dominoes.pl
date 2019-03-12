/**
Al inicio el sistema recibe:
    1.- Las fichas asignadas ------------ LISTO
    2.- Quién tira primero - quién tuvo la mula más grande  ----- LISTO. Se indica por meido de turno(X). 
       X = 1, es nuestro turno. X = 0, es turno del contrincante. Por default está en 1 al inicio del juego. 

Funciones a implementar:
    1.- Tomar del pozo (robar) ---------- LISTO
    2.- Tirar ficha
    3.- Tirar ficha rival
    4.- Función eurística (28-Tiradas-Mías= Fichas del Rival y pozo)
        a) Cuando el rival tome del pozo, guardar las fichas que no tiene
        b) Deshacerse lo más rápido posible de las mulas
        c) Mantener variada la mano de fichas
    5.- Imprimir tablero
    

    Links
    List sort: https://stackoverflow.com/questions/8429479/sorting-a-list-in-prolog
**/
:- ensure_loaded(fichas).

roba:-
   pozo(0),
   pasa.
roba:-
    write("Dame la ficha que robo. "),nl,
    read(Ficha),
    assert(mano(Ficha)),
    retract(desconocidas(Ficha)).
pasa:-
    assert(turno(0)),
    retractall(turno(1)).

tiroOponente:-
    /*
    Preguntar si el oponente roba o pasa.
    Meter los valores con los que pasó a robaOPaso.

    */

tiroOponente:-
    /*
    Meter la ficha al tablero
    Quitar de desconocidas.
    Cambiar turno
    */

