/**
 * Programar un mini-Router y realizar experimentos con él. 
 * Router es un sistema de inteligencia artificial que usa múltiples estrategias de razonamiento para planear rutas.
 * El mini-Router debe hacer lo mismo pero en un dominio diferente
 * Combina aspectos de:
 *      Razonamiento basado en casos
 *      Razonamiento a través de un modelo/mapa organizado jerárquicamente
 *      Búsqueda A* (cuando debe buscar dentro de una sola zona dentro de su mapa jerárquico). 
 * Tipo de experimentos interesantes
 *      ¿Alguno de los métodos de razonamiento que utiliza el sistema es más eficiente que los otros? 
 *      ¿Alguno de los métodos de razonamiento que utiliza el sistema garantiza la obtención de soluciones de mejor calidad que los otros?
 *      ¿Integrar los tres métodos de razonamiento es mejor que utilizar cualquiera de ellos por separado? 
 *      ¿A partir de qué momento resulta ser contraproducente seguir almacenando casos específicos de problemas resueltos
 *      (y cómo medirlo para que un sistema sea capaz de auto-monitorearse y decidirlo)? 
 * Para realizar este proyecto parte de la investigación independiente que se tendrá que realizar consistirá en la 
 *      Obtención y captura del conocimiento geográfico relevante (por ejemplo, coordenadas, distancias, tiempos de recorrido,
 * conexiones) que se necesite para describir el espacio dentro del cual se van a planear las rutas. 
 *      Elegir una función heurística adecuada (puede depender de la disponibilidad de datos adecuados) para la ejecución del algoritmo A*.
 *
 * FORMATO ESTACIONES:
 *      metro(estacion, lat, long, linea, orden)
 *      metrobus(estacion, lat, long, linea, orden)     
 **/

/**
 * Regla que permite calcular la norma euclidiana de dos estaciones, se proporcionan como parámetros las cordenadas
 * X,Y de cada estación (latitud y longitud).
 **/
:- ensure_loaded(estaciones_metro).
:- ensure_loaded(estaciones_metrobus).
:-dynamic path/1.

path([]).

norma(Est1,Est2,Dist):-
    metro(Est1,Cord1,Cord2,_,_),
    metro(Est2,C1,C2,_,_),
    normaEuclidiana(Cord1,Cord2,C1,C2,Dist),!.
norma(Est1,Est2,Dist):-
    mb(Est1,Cord1,Cord2,_,_),
    mb(Est2,C1,C2,_,_),
    normaEuclidiana(Cord1,Cord2,C1,C2,Dist),!.


normaEuclidiana(X1, Y1, X2, Y2, N):-
    X is (X2-X1),
    Y is (Y2-Y1), 
    SUM is (X*X) + (Y*Y),
    N is 100*sqrt(SUM).

/**
 * Funciones auxiliares 
 *      Fn que regrese estación (es) cercanas con el peso.
 *      Modificar norma para que funcione con los nombres.
 *
 **/
a_star(Node, Goal,X,Peso):-
    metro(Goal, NX,NY, Line, IndexG),
    metro(Node, GX,GY, Line, Index),
    I is Index-1,
    D is Index+1,
    metro(Izq,X1,Y1,Line, I),
    metro(Der,X2,Y2,Line, D),
    normaEuclidiana(X1, Y1, NX, NY, Res),
    normaEuclidiana(X2, Y2, NX, NY, Res2),
    Res > Res2, % Es la estación derecha
    X is Der,
    Peso is Res2.


/**
 * Se da el punto incio y el de llegada, se regresa
 * una lista con las instrucciones
 **/
a_star(Start, Weight, Goal, Res):-
    Start is Goal, !.
a_star(Start, Weight, Goal, Res):-!.

