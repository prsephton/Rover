% Uses SWI Prolog
%
%  Goal :-
%    Read the first line, interpret it as width and height,
%    Read the second line, interpret it as x, y pos and direction,
%    Read the third line, apply instructions in the line,
%    Output the final position and direction
%
%  With Prolog development, each predicate may succeed or fail, and
%  so testing and conditions form part of the code.
%
%  Each individual predicate may be tested in isolation.  For example,
%     turn(From, Dir, To),
%     writef("Turn %w from %w faces %w\n", [Dir, From, To]),
%     fail.
%  produces:
%     Turn L from E faces N
%     Turn L from S faces E
%     Turn L from W faces S
%     Turn L from N faces W
%     Turn R from N faces E
%     Turn R from E faces S
%     Turn R from S faces W
%     Turn R from W faces N
%
%  To run this program, install SWI Prolog, and do:
%     swipl -g script -s rover.pl
%
go :-
	get_gridsize(H, V),
	get_start_pos(H, V, X, Y, Direction),
	get_instructions(IList),
	process(pos(X, Y, Direction), size(H, V), IList, pos(Xf, Yf, Facing)),
	writef("%w %w %w", [Xf, Yf, Facing]), nl.

script :- go, fail.
script :- halt.

read_line(Line) :-  % Just read a single line and return the list of characters
	read_line_to_string(current_input, String),
	string_chars(String, Line).

% Reads the grid size as a two digit integer.  Fails if we cannot.
get_gridsize(H, V) :-
	read_line([Hc, Vc]),
	number_chars(H, [Hc]), number_chars(V, [Vc]),
	check_grid_range(H, V), !.
get_gridsize(_, _) :-
	write('Cannot read grid size.'), nl, fail.

% Checks the range of the grid size values
check_grid_range(H, V) :- between(1, 9, H), between(1, 9, V), !.
check_grid_range(H, V) :- writef('Grid values %w are out of range.', [[H, V]]), nl, fail.

% Reads the starting position and direction as a two digit integer
% followed by a space and a direction indicator.  Fails if it cannot.
get_start_pos(HSize, VSize, X, Y, Direction) :-
	read_line([Xc, Yc, ' ', Direction]),
	number_chars(X, [Xc]), number_chars(Y, [Yc]),
	check_grid_pos(X, HSize, 'Horizontal'), check_grid_pos(Y, VSize, 'Vertical'),
	check_direction(Direction), !.

% Checks that the position is valid, and fails if it is not.
check_grid_pos(Pos, Size, _) :- between(1, Size, Pos), !.
check_grid_pos(_, _, What) :- writef("%s position is outside the grid", [What]), nl, fail.

% Checks that the direction is in the valid set of directions, or fails
check_direction(Direction) :- memberchk(Direction, ['N', 'E', 'S', 'W']), !.
check_direction(Direction) :- writef("%s is not a valid direction", [Direction]), nl, fail.

% Reads the instruction list and checks that it is valid.
get_instructions(IList) :- read_line(IList), check_instructions(IList), !.

% Check whether each instruction in the list is valid, or fails.
valid_instruction_set([]).
valid_instruction_set([I|Iset]) :-
	writef("Instructions contain invalid characters: %w", [I|Iset]), nl, fail.
	
check_instructions([I|IList]) :-
	list_to_ord_set([I|IList], Iset),
	ord_subtract(Iset, ['L','M','R'], Remaining),
	valid_instruction_set(Remaining).

% The set of valid turns.  Right from N is E, and left from E is N
turns('N', 'E').
turns('E', 'S').
turns('S', 'W').
turns('W', 'N').

% Execute a turn in the indicated direction, returning the new direction
turn(Direction, 'L', NewDirection) :- turns(NewDirection, Direction).
turn(Direction, 'R', NewDirection) :- turns(Direction, NewDirection).

% Effect of movement on position, given the current direction
add('N', in(X,Y), size(_, H), out(X,Yo)) :- Yo is Y + 1, check_grid_pos(Yo, H, "Vertical").
add('S', in(X,Y), size(_, H), out(X,Yo)) :- Yo is Y - 1, check_grid_pos(Yo, H, "Vertical").
add('E', in(X,Y), size(W, _), out(Xo,Y)) :- Xo is X + 1, check_grid_pos(Xo, W, "Horizontal").
add('W', in(X,Y), size(W, _), out(Xo,Y)) :- Xo is X - 1, check_grid_pos(Xo, W, "Horizontal").

% process(pos(X,Y,Facing), size(W, H), [Ins|Instructions], Final)
process(pos(X,Y,Facing), _, [], pos(X,Y,Facing)).
process(pos(X,Y,Facing), Size, ['M'|Instructions], Final) :-
	add(Facing, in(X,Y), Size, out(Xo,Yo)), !, process(pos(Xo,Yo,Facing), Size, Instructions, Final).
process(pos(X,Y,Facing), Size, [T|Instructions], Final) :-
	turn(Facing, T, NewDirection), !, process(pos(X,Y,NewDirection), Size, Instructions, Final).
