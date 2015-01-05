:- lib(ic).
:- lib(ic_global).

% http://ic.pics.livejournal.com/avva/111931/80092/80092_original.jpg
problem([](
        [](>,<,>,<,<,>),
        [](^,v,^,v,v,^,^,^,^),
        [](>,<,<,<,>,>),
        [](v,^,^,^,^,v,^,v,^),
        [](<,>,<,>,>,<),
        [](>,<,>,<,<,<),
        [](v,^,^,v,^,v,^,v,v),
        [](<,<,<,>,>,<),
        [](v,v,v,^,v,^,v,^,^),
        [](>,>,>,<,<,>),
        [](>,>,<,>,>,<),
        [](v,^,v,^,^,^,v,^,v),
        [](<,>,<,>,<,>),
        [](^,^,^,v,v,^,v,v,v),
        [](<,>,>,<,<,>)
    )).

model(Sudoku) :-
    % standard sudoku constraints
    dim(Sudoku, [9, 9]),
    Sudoku :: 1..9,
    alldifferent_matrix(Sudoku),
    ( multifor([I, J], 0, 2), param(Sudoku) do
        Square is Sudoku[3*I+1..3*I+3, 3*J+1..3*J+3],
        flatten(Square, SquareVars),
        ic:alldifferent(SquareVars)
    ),
    problem(Problem),
    % greater-than horizontal constraints
    ( for(I, 1, 9), param(Sudoku, Problem) do
        ( for(B, 1, 6), param(Sudoku, Problem, I) do
            A is 5 * ((I - 1) div 3) + 2 * ((I - 1) mod 3) + 1,
            J is 3 * ((B - 1) div 2) + ((B - 1) mod 2) + 1,
            Rel is Problem[A, B],
            call(Rel, Sudoku[I, J], Sudoku[I, J + 1])@ic
        )
    ),
    % greater-than vertical constraints
    ( for(J, 1, 9), param(Sudoku, Problem) do
        ( for(T, 1, 6), param(Sudoku, Problem, J) do
            A is 5 * ((T - 1) div 2) + 2 * ((T - 1) mod 2 + 1),
            B is J,
            I is 3 * ((T - 1) div 2) + ((T - 1) mod 2) + 1,
            RelSymb is Problem[A, B],
            ( RelSymb == '^' ->
                Rel = '<'
            ;
                Rel = '>'
            ),
            call(Rel, Sudoku[I, J], Sudoku[I + 1, J])@ic
        )
    ).

find(Sudoku) :-
    search(Sudoku, 0, most_constrained, indomain_min, complete, []).

main :-
    model(Sudoku),
    find(Sudoku),
    ( foreacharg(Row, Sudoku) do
        array_list(Row, List),
        concat_string(List, Str),
        writeln(Str)
    ).
