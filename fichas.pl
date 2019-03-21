:-dynamic mano/1.
:-dynamic desconocidas/1.
:-dynamic turno/1.
:-dynamic noTiene/1. 
:-dynamic tablero/1.    
:-dynamic extremoDerecho/1.
:-dynamic extremoIzquierdo/1.
:-dynamic pozo/1.

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
desconocidas(fin).    

pozo(14).  /*Al inicio de cada juego de 1v1, el pozo empieza en 14 fichas. */

tablero([]).

noTiene([]).

mano([]).