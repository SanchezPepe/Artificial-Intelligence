/*
    Las fichas con igual número de puntos en ambos cuadrados se conocen 
    como dobles. Así mismo, las fichas con uno de los cuadrados sin 
    puntos se llaman blancas y las que tienen un punto se conocen como 
    unos. Así, con los dos, tres, cuatro y cinco hasta llegar a los seis.
*/

ficha(0, 0).

ficha(1, 0).
ficha(1, 1).

ficha(2, 0).
ficha(2, 1).
ficha(2, 2).

ficha(3, 0).
ficha(3, 1).
ficha(3, 2).
ficha(3, 3).

ficha(4, 0).
ficha(4, 1).
ficha(4, 2).
ficha(4, 3).
ficha(4, 4).

ficha(5, 0).
ficha(5, 1).
ficha(5, 2).
ficha(5, 3).
ficha(5, 4).
ficha(5, 5).

ficha(6, 0).
ficha(6, 1).
ficha(6, 2).
ficha(6, 3).
ficha(6, 4).
ficha(6, 5).
ficha(6, 6).

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
desconocidas([0,0]|[[1,0],[1,1],[2,0],[2,1],[2,2],[3,0],[3,1],[3,2],[3,3],[4,0],[4,1],[4,2],
[4,3],[4,4],[5,0],[5,1],[5,2],[5,3],[5,4],[5,5],[6,0],[6,1],[6,2],[6,3],[6,4],[6,5],[6,6]]).

/*
Aqui le cargamos las fichas que nos reparten al inicio del juego. 
Se tiene que llamar "inicio." e ingresar las 7 fichas, y posteriormente poner "fin".
*/

mano().
repite.
repite:-
    repite.

:-dynamic mano/1.


inicio():-
    write("Ingresa las 7 fichas iniciales. "),nl,
    repite,
    read(Ficha),
    
    assert(mano(Ficha)),
    Ficha==fin.