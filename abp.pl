/**
 * alpha_beta()
 * 
 **/

turno(1, 0).
turno(0, 1).

evaluate_and_choose(Jugador1,[Ficha|Resto],Posicion,Profundidad,Alpha,Beta,Record,Mejor) :-
   compatibles(Jugador1, Ficha, Movs),
   turno(Jugador1,Jugador2),
   alpha_beta(Jugador2 ,Profundidad,Movs,Alpha,Beta,_OtroMov,Peso),
   Peso1 is -Peso,
   poda(Jugador1,Ficha,Peso1,Profundidad,Alpha,Beta,Resto,Posicion,Record,Mejor).
evaluate_and_choose(_Player,[],_Posicion,_D,Alpha,_Beta,Move,(Move,Alpha)).

poda(_Jugador,Ficha,Peso,_Profundidad,_Alpha,Beta,_Resto,_Posicion,_Record,(Ficha,Peso)) :- 
   Peso >= Beta,!.
poda(Jugador,Ficha,Peso,Profundidad,Alpha,Beta,Resto,Posicion,_Record,Mejor) :- 
   Alpha < Peso,Peso < Beta,!,
   evaluate_and_choose(Jugador,Resto,Posicion,Profundidad,Peso,Beta,Ficha,Mejor).
poda(Jugador,_Ficha,Peso,Profundidad,Alpha,Beta,Resto,Posicion,Record,Mejor) :- 
   Peso =< Alpha,!,
   evaluate_and_choose(Jugador,Resto,Posicion,Profundidad,Alpha,Beta,Record,Mejor).


alpha_beta(Player,Profundidad,Posicion,Alpha,Beta,Ficha,Peso) :- 
   Profundidad > 0,
   compatibles(Player,Posicion,Movs),
   Alpha1 is -Beta,% max/min
   Beta1 is -Alpha,
   NuevaProf is Profundidad-1,
   evaluate_and_choose(Player,Movs,Posicion,NuevaProf,Alpha1,Beta1,nil,(Ficha,Peso)).
alpha_beta(_Player,0,Ficha,_Alpha,_Beta,_SinMov, Peso) :- 
   desconocidas(Desc),
   length(Desc, NumDesc),
   pozo(P),  
   pesoNodo(NumDesc, P, Ficha, Peso).

mano([[0,0], [2,1]]).
tablero([2,0]).
desconocidas([[6,0],[4,0],[2,2],[5,1]]).
pozo(14).
noTiene([]).
numeros([8,8,8,8,8,8,8]).


test:-
   Ficha = [2,0],
   compatibles(1, Ficha, Moves),
   write(Moves).
   %pesoNodo(L, P, Ficha, Peso),
   %write(Peso).
   
/**
* Regla que asigna un peso a un nodo determinado dependiendo del estado actual del
* juego, para la determinación del peso se consideran las fichas que el sistema
* desconoce, el número de fichas en el pozo, cúantas fichas compatibles con el 
* tablero quedan todavía y las fichas que sabemos que el rival no tiene por que
* ha pasado.
* **/
pesoNodo(Desconocidas, NumPozo, [H|[T]], Peso):-
   noTiene(N),
   numeros(Nums),
   nth0(H,Nums,L1),
   nth0(T,Nums,L2),
   estimacion(Desconocidas, NumPozo, L1, E1),
   estimacion(Desconocidas, NumPozo, L2, E2),
   Estimacion is E1 + E2,
   Tab = [H|[T]],
   rivalPaso(N, Tab, NoTiene),
  Peso is Estimacion + NoTiene.

/**
* Regla que evalua si el rival no tiene un número (la lista 'noTiene' registra 
* cuando el rival toma del pozo o pasa)
* **/
rivalPaso(_,[], 0):- !.
rivalPaso(RivalPaso, [H|T], Ans):-
   member(H, RivalPaso),
   rivalPaso(RivalPaso, T, Resp),
   Ans is 2 + Resp, !.
rivalPaso(RivalPaso, [_|T], Ans):-
   rivalPaso(RivalPaso, T, Ans).

/* Regla que estima la posibilidad de que el rival no tenga un número determinado,
* recibe el número de fichas desconocidas totales. Utilizar para generar la estimación
* la lista que guarda cuantas fichas de cada grupo aún se desconocen.
*/
estimacion(Desconocidas, NumPozo, QuedanNum, Estimacion):-
  (NumPozo = 0) -> Estimacion is 0;
  (NumPozo \= 0) -> Estimacion is (1-(QuedanNum/Desconocidas)).

% Reglas Auxiliares

/**
* Reglas que compara dos fichas para comprobar si se puede utilizar en el tiro.
* */
fichaCompatible(Tablero, [H|[T|_]]):-
   (member(H, Tablero) ; member(T, Tablero)).

/**
* Regla que recibe el estado del tablero y un conjunto de fichas. Regresa una lista
* de fichas que se pueden tirar. Ya sea de la mano o de las desconocidas 
**/

fichasCompatibles(_,[],[]).
fichasCompatibles(Tablero, [H|T], X):-
   fichaCompatible(Tablero, H),
   fichasCompatibles(Tablero, T, Z),
   append([H], Z, X).
fichasCompatibles(Tablero,[_|T], X):-
   fichasCompatibles(Tablero, T, X). 

/**
* Fichas compatibles para una mano determinada
* **/
compatibles(0, Ficha, Moves):-
   desconocidas(X),
   fichasCompatibles(Ficha, X, Moves), !.
compatibles(1, Ficha, Moves):-
   mano(X),
   fichasCompatibles(Ficha, X, Moves), !.

max(X, Y, Z):-
   Z is max(X, Y).

min(X, Y, Z):-
   Z is min(X, Y).

/**
 * Regla que decrementa el hecho que guarda cuántas fichas quedan de cada número para
 * una lista específica 
 * **/
decrementaListaAux(Index, Lista, Ret):-
