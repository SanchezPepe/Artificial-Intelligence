/**
 * 
 **/

normaEuclidiana(S1,S2, N):-
    SUM is (S1*S1) + (S2*S2),
    N is sqrt(SUM).