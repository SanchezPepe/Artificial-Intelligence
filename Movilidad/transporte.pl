/**
 * metro(cuauhtemoc,19.42565962,-99.15455103,1).
 * 
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
 *      metro(estacion, lat, long, linea)
 *      metrobus(estacion, lat, long, linea)     
 **/

/**
 * Regla que permite calcular la norma euclidiana de dos estaciones, se proporcionan como parámetros las cordenadas
 * X,Y de cada estación (latitud y longitud).
 **/
:- ensure_loaded(estaciones_metro).
:- ensure_loaded(estaciones_metrobus).

normaEuclidiana(X1, Y1, X2, Y2, N):-
    X is (X2-X1),
    Y is (Y2-Y1), 
    SUM is (X*X) + (Y*Y),
    N is sqrt(SUM).