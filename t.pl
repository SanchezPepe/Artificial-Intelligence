/**
 * Pruebas
 **/
:-dynamic fichasCompatiblesibles/1.

m([[2,0], [6,2], [4,4], [5,3]]).

tablero([3,4]).

fichaCompatible([H|[T|_]]):-
    tablero(X),
    (member(H, X) ; member(T, X)).

fichasCompatibles([],[]).
fichasCompatibles([H|T], X):-
    fichaCompatible(H),
    fichasCompatibles(T, Z),
    append([H], Z, X).
fichasCompatibles([_|T], X):-
    fichasCompatibles(T, X). 

test:-
    m(X),
    fichasCompatibles(X,Y), 
    write(Y), !.
