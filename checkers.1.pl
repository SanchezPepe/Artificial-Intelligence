evaluate_board(Board, 200, _):-
    \+list_available_moves(Board,black,_),
    list_available_moves(Board,white,_), !.
evaluate_board(Board, -200, _):-
    \+list_available_moves(Board,white,_),
    list_available_moves(Board,black,_), !.

evaluate_board(Board, 0, Iterator) :-  Iterator > 8, !.

evaluate_board(Board, Eval, Iterator) :- 
    arg(Iterator, Board, Line), !,
    evaluate_line(Line, LineEval, Iterator, 1),
    IteratorNext is Iterator + 1,
    evaluate_board(Board, RemainingEval, IteratorNext),
    Eval is LineEval + RemainingEval.

evaluate_line(Line, 0, _, Column) :- Column > 8, !.

evaluate_line(Line, Eval, Row, Column) :-
	arg(Column, Line, Piece), !,
	piece_value(Piece, PieceValue),
	board_weight(Piece,Column,Row,W),
	IteratorNext is Column + 1,
	evaluate_line(Line, RemainingEval, Row, IteratorNext),
	Eval is RemainingEval + PieceValue * W.


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

%% code_to_number(Code, Number) :-
%% 	Code >= 49,
%% 	Code =< 56,
%% 	Number is Code - 48.
