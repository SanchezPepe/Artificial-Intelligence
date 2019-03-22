/**
Al inicio el sistema recibe:
    1.- Las fichas asignadas ------------ LISTO
    2.- Quién tira primero - quién tuvo la mula más grande  ----- LISTO. Se indica por meido de turno(X). 
       X = 1, es nuestro turno. X = 0, es turno del contrincante. Por default está en 1 al inicio del juego. 

Funciones a implementar:
    1.- Tomar del pozo (robar) ---------- LISTO
    2.- Tirar ficha
    3.- Tirar ficha rival -------------- LISTO
    4.- Función eurística (28-Tiradas-Mías= Fichas del Rival y pozo)
        a) Cuando el rival tome del pozo, guardar las fichas que no tiene
        b) Deshacerse lo más rápido posible de las mulas
        c) Mantener variada la mano de fichas
    5.- Imprimir tablero ------------  LISTO
    

    Links
    List sort: https://stackoverflow.com/questions/8429479/sorting-a-list-in-prolog
**/
:- ensure_loaded(fichas).
:- dynamic posibles/1.

tirar([3,4]).
der(2).
izq(3).

mano2([[1,3],[4,0],[1,1],[5,3],[0,0]]).
posibles([]).

numeros([7,7,7,7,7,7,7]).

/* Aqui le cargamos las fichas que nos reparten al inicio del juego. 
Se tiene que llamar "inicio." e ingresar las 7 fichas, y posteriormente poner "fin.". */

repite.
repite:-
    repite.

inicio():-
    write("Ingresa las 7 fichas iniciales. "),nl,
    repite,
    read(Ficha), 
    mano(X),   
    append(X,[Ficha],Y),
    retract(mano(X)),
    assert(mano(Y)),
    retract(desconocidas(Ficha)),
    Ficha==fin.

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

reverse([],Z,Z).
reverse([H|T],Z,Acc):-
    reverse(T,Z,[H|Acc]).

extremoIzq():-
    tablero([H|_]),
    extremoIzq(H).
extremoIzq([H|_]):-
    retractall(extremoIzquierdo(_)),
    assert(extremoIzquierdo(H)).

extremoDer():-
    tablero([_|T]),
    reverse(T,X,[]),
    extremoDer(X),!.
extremoDer([H|_]):-
    reverse(H,X,[]),
    is_list(X),
    extremoDer(X),!.
extremoDer([H|_]):-
    retractall(extremoDerecho(_)),
    assert(extremoDerecho(H)).


tiroOponente:-
    write("¿El oponente tiró alguna ficha? si/no"),nl,
    read(Resp),
    Resp==si,
    write("¿Qué ficha tiró el oponente?"),nl,
    read(Ficha),
    retract(desconocidas(Ficha)),
    tablero(X),
    append(X,[Ficha],Y),
    retract(tablero(X)),
    assert(tablero(Y)),
    extremoDer,
    extremoIzq.

/**
 * Regla que decrementa la lista que guarda cuántas fichas quedan de cada grupo, se utliza en la 
 * función eurística para dar información al sistema al momento de utlizar la función eurística.
 **/
decrementa(X):-
    numeros(Y),
    % Obtiene de la lista
    nth0(X,Y,Z),
    % Quita de la lista
    nth1(X,Y, _, W),
    A is Z-1,
    % Inserta en la lsita
    nth0(X, B, A, W),
    retract(numeros(Y)),
    assert(numeros(B)).

/**
 * Regla que busca las fichas posibles para tirar en cada jugada dependiendo del estado actual del tablero.
 * Regresa una sublista posibles([]) de la mano actual
 **/
movimientosPosibles([]).
movimientosPosibles([H|T]) :-
    extremoDer(Y),
    extremoIzq(X),
    posibles(W),
    (member(X, H) ; member(Y,H)),
    append(W, [H], Z),
    retract(posibles(W)),
    assert(posibles(Z)),
    movimientosPosibles(T).
movimientosPosibles([_|T]):-
    movimientosPosibles(T).


/**
 * Min max
 **/

minimax(Player, Board, NextMove, Eval, Depth) :-
	Depth < 5,
	NewDepth is Depth + 1,
	next_player(Player, OtherPlayer),
	list_available_moves(Board, OtherPlayer, Moves),
	best(OtherPlayer, Moves, NextMove, Eval, NewDepth), !.

minimax(Player, Board, _, Eval, Depth) :-
	evaluate_board(Board, Eval, 1), !.

best(Player, [Move], Move, Eval, Depth) :-
	move_board(Move, Board),
	minimax(Player, Board, _, Eval, Depth), !.

best(Player, [Move|Moves], BestMove, BestEval, Depth) :-
	dechain(Move, Move1),
	move_board(Move1, Board),
	minimax(Player, Board, NextMove, Eval, Depth),
	best(Player, Moves, BestMove1, BestEval1, Depth),
	better_of(Player, Move1, Eval, BestMove1, BestEval1, BestMove, BestEval).

dechain([Move],Move).
dechain([Move|Moves],Last) :- last(Moves, Last).
dechain(Move, Move).


maximizing(white).
minimizing(black).

move_board(m(_,_,_,_, Board), Board).
move_board(e(_,_,_,_, Board), Board).
%move_board([e(_,_,_,_, Board)], Board).
better_of(Player, Move1, Eval1, Move2, Eval2, Move1, Eval1) :-
	maximizing(Player),
	Eval1 >= Eval2, !.
better_of(Player, Move1, Eval1, Move2, Eval2, Move2, Eval2) :-
	maximizing(Player),
	Eval2 >= Eval1, !.

better_of(Player, Move1, Eval1, Move2, Eval2, Move1, Eval1) :-
	minimizing(Player),
	Eval1 =< Eval2, !.
better_of(Player, Move1, Eval1, Move2, Eval2, Move2, Eval2) :-
	minimizing(Player),
	Eval2 =< Eval1, !.

alphabeta(Player, Alpha, Beta, Board, NextMove, Eval, Depth) :-
	Depth < 30,
	NewDepth is Depth + 1,
	list_available_moves(Board, Player, Moves),
	bounded_best(Player, Alpha, Beta, Moves, NextMove, Eval, NewDepth), !.

alphabeta(Player, Alpha, Beta, Board, NextMove, Eval, Depth) :-
	evaluate_board(Board, Eval, 1), !.

bounded_best(Player, Alpha, Beta, [Move|Moves], BestMove, BestEval, Depth) :-
	dechain(Move, Move1),
	move_board(Move1, Board),
	next_player(Player, NextPlayer),
	alphabeta(NextPlayer, Alpha, Beta, Board, _, Eval, Depth),
	good_enough(Player, Moves, Alpha, Beta, Move1, Eval, BestMove, BestEval, Depth).

good_enough(Player, [], _, _, Move, Eval, Move, Eval, Depth) :- !.

good_enough(Player, _, Alpha, Beta, Move, Eval, Move, Eval, Depth) :-
	minimizing(Player), Eval > Alpha, !.

good_enough(Player, _, Alpha, Beta, Move, Eval, Move, Eval, Depth) :-
	maximizing(Player), Eval < Beta, !.

good_enough(Player, Moves, Alpha, Beta, Move, Eval, BestMove, BestEval, Depth) :-
	new_bounds(Player, Alpha, Beta, Eval, NewAlpha, NewBeta),
	bounded_best(Player, NewAlpha, NewBeta, Moves, Move1, Eval1, Depth),
	better_of(Player, Move, Eval, Move1, Eval1, BestMove, BestEval).

new_bounds(Player, Alpha, Beta, Eval, Eval, Beta) :-
	minimizing(Player), Eval > Alpha, !.


new_bounds(Player, Alpha, Beta, Eval, Alpha, Eval) :-
	maximizing(Player), Eval < Beta, !.


/**
['pepe.pl'].
movimientosPosibles([[5,4],[8,1], [4,2], [4,0], [1,4]]).
*/
