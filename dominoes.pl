/**
Al inicio el sistema recibe:
    1.- Las fichas asignadas
    2.- Quién tira primero - quién tuvo la mula más grande

Funciones a implementar:
    1.- Tomar del pozo (robar)
    2.- Tirar ficha
    3.- Tirar ficha rival
    4.- Función eurística (28-Tiradas-Mías= Fichas del Rival y pozo)
        a) Cuando el rival tome del pozo, guardar las fichas que no tiene
        b) Deshacerse lo más rápido posible de las mulas
        c) Mantener variada la mano de fichas
    5.- Imprimir tablero
    

    Links
    List sort: https://stackoverflow.com/questions/8429479/sorting-a-list-in-prolog
    :)
    
**/
:- ensure_loaded(fichas).

roba:-
   pozo(0),
   pasa.
roba():-
    write("Dame la ficha que robo. "),nl,
    read(Ficha),
    assert(mano(Ficha)).
pasa:-
    turno is 0.



