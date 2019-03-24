:-dynamic mano/1.
:-dynamic desconocidas/1.
:-dynamic noTiene/1. 
:-dynamic tablero/1.    
:-dynamic pozo/1.


desconocidas([[0, 0],
            [1, 0],[1, 1],
            [2, 0],[2, 1],[2, 2],
            [3, 0],[3, 1],[3, 2],[3, 3],
            [4, 0],[4, 1],[4, 2],[4, 3],[4, 4],
            [5, 0],[5, 1],[5, 2],[5, 3],[5, 4],[5, 5],
            [6, 0],[6, 1],[6, 2],[6, 3],[6, 4],[6, 5],[6, 6]]).

/*Al inicio de cada juego de 1v1, el pozo empieza en 14 fichas. */
pozo(14).  
tablero([]).
noTiene([]).
mano([]).