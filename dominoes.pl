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

numeros([7,7,7,7,7,7,7]).

/* Aqui le cargamos las fichas que nos reparten al inicio del juego. 
Se tiene que llamar "inicio." e ingresar las 7 fichas, y posteriormente poner "fin.". */

main:-
    inicio,
    write("¿Quién tiene el primer movimiento? yo/el"),nl,
    read(Resp),
    Resp==yo,
    write("¿Cuál es la primera ficha que tiro? "),nl,
    read(Ficha),
    mano(X),
    delete(X,Ficha,M),
    retract(mano(X)),
    assert(mano(M)),
    actualizaPrim(Ficha),
    tiroOponente.
main:-
    primerTiroOponente.

primerTiroOponente:-
    write("¿Qué ficha tiró el oponente?"),nl,
    read(Ficha),
    retract(desconocidas(Ficha)),
    actualizaPrim(Ficha),!.

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
    Ficha==fin,!.

roba:-
   pozo(0).
roba:-
    write("Dame la ficha que robo. "),nl,
    read(Ficha), 
    mano(X),   
    append(X,[Ficha],Y),
    retract(mano(X)),
    assert(mano(Y)),
    retract(desconocidas(Ficha)),
    pozo(P),
    A is P-1,
    retract(pozo(P)),
    assert(pozo(A)).


reverse([],Z,Z).
reverse([H|T],Z,Acc):-
    reverse(T,Z,[H|Acc]).

tiroOponente:-
    write("¿El oponente tiró alguna ficha? si/no"),nl,
    read(Resp),
    Resp==si,
    write("¿Qué ficha tiró el oponente?"),nl,
    read(Ficha),
    retract(desconocidas(Ficha)),
    write("¿De qué lado del tablero tiró el oponente? d/i"),nl,
    read(Lado),
    actualizaExtremo(Ficha, Lado).

tiroOponente:-
    
    write("¿Cuántas fichas tomó del pozo? "),nl,
    read(Num),
    pozo(X),
    Y is X-Num,
    retract(pozo(X)),
    assert(pozo(Y)),
        
    extremoDerecho(ValDer),
    extremoIzquierdo(ValIzq),
    noTiene(N),
    append(N, [ValIzq], S),
    append(S, [ValDer], Z),
    retract(noTiene(N)),
    assert(noTiene(Z)).


actualizaPrim([A|ColaA]):-
     sacaCola(ColaA,B),assert(extremoDerecho(B)),
     assert(extremoIzquierdo(A)).
actualizaExtremo(Ficha, Lado):-
    (Lado=i) -> actEI(Ficha);
    actED(Ficha).
sacaCola([A|_],B):-
    B is A.
actED([A|ColaA]):-
    extremoDerecho(ED),
    (A==ED)->retractall(extremoDerecho(_)), sacaCola(ColaA,B),assert(extremoDerecho(B));
    retractall(extremoDerecho(_)),assert(extremoDerecho(A)).
actEI([A|ColaA]):-
    extremoIzquierdo(EI),
    (A==EI)->retractall(extremoIzquierdo(_)),sacaCola(ColaA,B),assert(extremoIzquierdo(B));
    retractall(extremoIzquierdo(_)),assert(extremoIzquierdo(A)).
    
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

/*extremoIzq():-
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
*/