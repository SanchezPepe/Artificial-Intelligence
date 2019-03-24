:- ensure_loaded(pepe).

n([7,7,7,7,7,7,7]).
% Para pruebas
ma([[5,2],[8,1], [4,2], [4,0], [1,4]]).
%manoCompatible([2,1], [[5,2],[8,1], [4,2], [4,0], [1,4]], C).

decrementaListaAux(Index, Lista, Ret):-
    % Obtiene de la lista
    nth0(Index,Lista,Cant),
    % Quita de la lista
    nth1(Index,Lista, _, W),
    Dec is Cant-1,
    % Inserta en la lsita
    nth0(Index, Nva, Dec, W),
    append(Nva, [], Ret).


bestMove(Nodo, Prof, Ficha):-
    alfabeta(Nodo, Prof,-50, 50, 1, Peso),
    write('Mi tiro es: '+ Peso),
    Ficha is Peso.



%Para cada hijo del nodo
%iteraNodosHijo(_,_,0, Peso):-
% iteraNodosHijo(TABLERO, COMPATIBLES, PROFUNDIDAD, PESO).
iteraNodosHijo(_,[], _, _).    
iteraNodosHijo(Nodo, [Ficha|Resto], Prof, Peso):-
    manoCompatible(Tab, Ficha, [H|T]).  %Tiene las fichas compatibles con Nodo.


%LLAMADA INICIAL = alfabeta(origen, profundidad, -inf, +inf, max) 
abp(Nodo, 0, _, _, _, Peso):-
    pesoNodo(Nodo, Peso).
% MAX
abp(Nodo, Prof, Alfa, Beta, 1, Peso):-
    ProfR is Prof-1,
    desconocidas(D),
    desconocidasCompatibles(Nodo, [DescComp|Resto]),
    % PARA CADA HIJO DEL NODO
    alfabeta(Hijo, ProfR, Alfa, Beta, 0, Peso2),
    Alfa is max(Alfa, Peso2),
    Alfa >= Beta,
    %poda(Beta)
    Peso is Alfa.
% MIN
abp(Nodo, Prof, Alfa, Beta, 0, Peso):-
    ProfR is Prof-1,
    mano(Mano),
    manoCompatible(Nodo, Mano, [Compat|Resto]),
    % PARA CADA HIJO DEL NODO
    alfabeta(Hijo, ProfR, Alfa, Beta, 0, Peso2),
    Beta is min(Beta, Peso2),
    Alfa >= Beta,
    poda(Alfa),
    % PARA CADA HIJO DEL NODO
    Peso is Beta.

/**
 * Funciones Auxiliares
 * **/
/**
 * Fichas compatibles para una mano determinada
 * **/
manoCompatible(Tab, Mano, Compat):-
    fichasCompatibles(Tab, Mano, Compat), !.

desconocidasCompatibles(Tab, Desc):-
    desconocidas(X),
    fichasCompatibles(Tab, X, Desc), !.

max(X, Y, Z):-
    Z is max(X, Y).

min(X, Y, Z):-
    Z is min(X, Y).

fichaCompatible(Tablero, [H|[T|_]]):-
    (member(H, Tablero) ; member(T, Tablero)).

fichasCompatibles(_,[],[]).
fichasCompatibles(Tablero, [H|T], X):-
    fichaCompatible(Tablero, H),
    fichasCompatibles(Tablero, T, Z),
    append([H], Z, X).
fichasCompatibles(Tablero,[_|T], X):-
    fichasCompatibles(Tablero, T, X). 

/**
 * Regla que asigna un peso a un nodo determinado dependiendo del estado actual del
 * juego, para la determinación del peso se consideran las fichas que el sistema
 * desconoce, el número de fichas en el pozo, cúantas fichas compatibles con el 
 * tablero quedan todavía y las fichas que sabemos que el rival no tiene por que
 * ha pasado.
 * **/
pesoNodo(Nodo, S):-
    numeros(Y), 
    extremoDerecho(ED), 
    extremoIzquierdo(EI),
    rivalPaso(ED, Y),
    rivalPaso(EI, Z),
    estimacion(Nodo, X),
	S is (2*X)+Y+Z.

/**
 * Regla que evalua si el rival no tiene un número (la lista 'noTiene' registra 
 * cuando el rival toma del pozo o pasa)
 * **/
rivalPaso(Num, Resp):-
    noTiene(X),
    member(Num, X) -> Resp is 2;
    Resp is 0.

/* Regla que estima la posibilidad de que el rival no tenga un número determinado,
 * recibe el número de fichas desconocidas totales. Utilizar para generar la estimación
 * la lista que guarda cuantas fichas de cada grupo aún se desconocen.
 */
estimacion(Num, Est):-
    length(desconocidas, Desc),
    pozo(TamPozo),
    numeros(Y),
    nth0(Num, Y, X),
	(TamPozo = 0) -> Est is 0;
	(TamPozo \= 0) -> Est is (1-(X/Desc)).

% Estimación
funEstimadora(Desconocidas, NumPozo, QuedanNum, Estimacion):-
	(NumPozo = 0) -> Estimacion is 0;
	(NumPozo \= 0) -> Estimacion is (1-(QuedanNum/Desconocidas)).

% Rival pasó
funPasa(_,[], 0):- !.
funPasa(RivalPaso, [H|T], Ans):-
    member(H, RivalPaso),
    funPasa(RivalPaso, T, Resp),
    Ans is 2 + Resp, !.
funPasa(RivalPaso, [_|T], Ans):-
    funPasa(RivalPaso, T, Ans).

% PESO
heuristica(Desconocidas, NumPozo, NumTablero, Ficha, Peso):-
    noTiene(N),
    funEstimadora(Desconocidas, NumPozo, NumTablero, Estimacion), 
    funPasa(N, Ficha, NoTiene),
	Peso is (2*Estimacion) + NoTiene.
