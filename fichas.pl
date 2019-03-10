:-dynamic mano/1.
:-dynamic desconocidas/1.
:-dynamic turno/1.

desconocidas([0, 0]).
desconocidas([1, 0]).
desconocidas([1, 1]).
desconocidas([2, 0]).
desconocidas([2, 1]).
desconocidas([2, 2]).
desconocidas([3, 0]).
desconocidas([3, 1]).
desconocidas([3, 2]).
desconocidas([3, 3]).
desconocidas([4, 0]).
desconocidas([4, 1]).
desconocidas([4, 2]).
desconocidas([4, 3]).
desconocidas([4, 4]).
desconocidas([5, 0]).
desconocidas([5, 1]).
desconocidas([5, 2]).
desconocidas([5, 3]).
desconocidas([5, 4]).
desconocidas([5, 5]).
desconocidas([6, 0]).
desconocidas([6, 1]).
desconocidas([6, 2]).
desconocidas([6, 3]).
desconocidas([6, 4]).
desconocidas([6, 5]).
desconocidas([6, 6]).
desconocidas(fin).    /*Para que en "inicio" no de error al poner "fin"  */

turno(1).

cero(7).
uno(7).
dos(7).
tres(7).
cuatro(7).
cinco(7).
seis(7).

/*
    Suponiendo 1 vs 1
*/
pozo(14).
/*
Aqui le cargamos las fichas que nos reparten al inicio del juego. 
Se tiene que llamar "inicio." e ingresar las 7 fichas, y posteriormente poner "fin.".
*/

repite.
repite:-
    repite.

inicio():-
    write("Ingresa las 7 fichas iniciales. "),nl,
    repite,
    read(Ficha),    
    assert(mano(Ficha)),
    retract(desconocidas(Ficha)),
    Ficha==fin.