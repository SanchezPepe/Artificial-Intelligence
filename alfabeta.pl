/*La funcion heuristica recibe los parámetros de la funEstimadora y la funPasa, 
los suma y regresa C. A es el número de fichas desconocidas, 
B, el número de fichas en el pozo, 
C es el número determinado del que quieres saber cuantas fichas quedan desconocidas. 
E es la lista cuando ha pa
sado el rival, 
ED el extremo derecho del tablero y EI, el izquierdo y S la suma de todo*/
funcionPeso(X):-
    random(1, 10, X).

/**
 * POSIBLES = [[5,4],[8,1], [4,2], [4,0], [1,4]]
 * LLAMADA INICIAL = alfabeta(origen, profundidad, -inf, +inf, max) 
 * */
% Caso en el que bajó hasta la profundidad deseada.
% alfabeta(Nodo, Profundidad, Alfa, Beta, Turno, Peso)
alfabeta(Nodo, 0, _, _, _, Peso):-
    funcionPeso(Nodo, Peso).
% MAX
alfabeta(Nodo, Prof, Alfa, Beta, 1, Peso):-
    posibles(X),
    % For para cada hijo del nodo
    Alfa is max(Alfa, alfabeta(Hijo, Prof-1, Alfa, Beta, 0)),
    Alfa =< Beta,
    poda(Beta),
    Peso is Alfa.
% MIN
alfabeta(Nodo, Prof, Alfa, Beta, 0, Peso):-
    posibles(X),
    Beta is min(Beta, alfabeta(Hijo, Prof-1, Alfa, Beta, 1)),
    Beta =< Alfa,
    poda(Alfa),
    Peso is Beta.

max(X, Y, Z):-
    Z is max(X, Y).

min(X, Y, Z):-
    Z is min(X, Y).

/* Regla que estima la posibilidad de que el rival no tenga un número determinado,
 * recibe el número de fichas desconocidas totales. Utilizar para generar la estimación
 * la lista queg guarda cuantas fichas de cada grupo aún se desconocen.
 */
estimacion(Num, Est):-
    length(desconocidas, Desc), 
    pozo(TamPozo),
    numeros(Y),
    nth0(Num, Y, X),
	(TamPozo = 0) -> Est is 0;
	(TamPozo \= 0) -> Est is 2*(1-(X/Desc)).

/** Regla que pondera un número con las fichas que el rival no tiene, La función recibe la lista A que contiene los números en los que el rival pasó 
 *  ha pasado, y el elemento B que es uno de los extremos del tablero, regresa C.
**/
rivalPaso(Num, Resp):-
    noTiene(X),
    member(Num, X) -> Resp is 2;
    Resp is 0.

funcionPeso(C, S):-
    numeros(Y), 
    extremoDerecho(ED), 
    extremoIzquierdo(EI),
    rivalPaso(ED, Y),
    rivalPaso(EI, Z),
    estimacion(C, X),
	S is X+Y+Z.