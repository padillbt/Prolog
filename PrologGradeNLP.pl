%% The final project will be used to make prolog do some natural language
%% processing.

%% BEFORE YOU START, take a look at the book chapter "Prolog Grammar Rules"
%% on Moodle.

%% The basic ideal will be to build a system with knowledge of student
%% grades, and a processing system that respond to human queries about
%% grade results.  You can see what the knowledge looks like here:

grade(steve,boy,97).
grade(anne,girl,97).
grade(sally,girl,88).
grade(mike,boy,77).
grade(cathy,girl,81).

% Stage A: Writing a basic parse
%
% Stage A of this project will focus on the design of a single parse
% function.  This is the heart of our NLP engine, and we'll want to
% make it as extensible as possible.
%
% Parse will be used like this:
%
% ?- parse([what,is,the,highest,grade],Result).
% Result = 97
%
% Note that the input is a list of atoms, all lowercase.  The type of
% result will vary depending on the question asked, but will always
% be relatively simple.  Certian questions, however, can have more
% than one valid response (e.g. WHO has the highest grade will return
% two responses...but this can be handled in the usual prolog way).

% Stage A1 [5 points].  Make the example parse above work.

find_max(Gender, Grade, X) :- have_grade(Gender, Grade,X), findall(Score, have_grade(Gender, Grade,Score),Scores), forall(member(Score,Scores), Score =< X),!.


% Stage A2 [5 points].  Modify the code so that it will also return
% the lowest grade.

find_minimum(Gender, Grade, X) :- have_grade(Gender, Grade,X), findall(Score, have_grade(Gender, Grade,Score),Scores), forall(member(Score,Scores), Score >= X), !.

% Stage A3 [5 points].  Modify the code above so you can use a variety
% of synomyns for highest/lowest (largest, biggest, best, or whatever).


% Stage A4 [10 points].  Modify the code so that you can ask
% [who,has,the,highest,grade] and simliar queries (should return a
% name).  You'll want to be careful to prevent too much duplication.

has_highest_grade(Gender, Grade, X) :- grade(X,Gender,Y), find_max(Gender, Grade, Y).
has_lowest_grade(Gender, Grade, X) :- grade(X,Gender,Y), find_minimum(Gender, Grade, Y).

%
% Stage A5 [5 points].  Modify the code so that you can restrict the
% range of the search.  If I say [...,above,82] it should restrict the
% search to grades above 82.  If If I say [...,above,mike] and mike is
% a name in the db, it should restrict the grades to grades above that
% student's grade.

above_grade(Gender, Grade, Result) :- grade(_,Gender,Result), Result > Grade.
above_Student(Gender, Student, Result) :- grade(Student,_,Grade), grade(_,Gender,Result), Result > Grade.

below_grade(Gender, Grade, Result) :- grade(_,Gender,Result), Result < Grade.
below_Student(Gender, Student, Result) :- grade(Student,_,Grade), grade(_,Gender,Result), Result < Grade.

% Stage A6 [5 points].  Same as above, but now if I say [...,for,girls]
% it should restrict the search to girls.  If I say [...,for,a,students]
% it should restrict the grades for students who have a grade in the 90s.

bottom_grade(a,90).
bottom_grade(b,80).
bottom_grade(c,70).
bottom_grade(d,60).
bottom_grade(f,0).

top_grade(a,100).
top_grade(b,89).
top_grade(c,79).
top_grade(d,69).
top_grade(f,59).

have_grade(Gender,Grade, X) :- bottom_grade(Grade,Low), top_grade(Grade, High), grade(_,Gender,X), X > Low, X =< High.

who_has_grade(Gender,Grade,Name) :- bottom_grade(Grade,Low), top_grade(Grade, High), grade(Name,Gender,X), X > Low, X =< High.

% Stage A7 [5 points].  Add the ability to have unlimited restrictions
% with "who are".  So I can say
% [...,for,girls,who,are,b,students,who,are,above,85].
%
% That last one may be tricky - remember it's only worth 5 points if you
% skip it.
%
% Stage B [30 points]: Handling Input

% We would like to be able to access this function without using
% prolog's strange interface.  Instead, I'd like to be able to run a
% prolog function that puts prolog into an input mode where I can
% just type questions and it will answer.
%
% For example:
%% ?- do_nlp(start). % I couldn't get do_nlp to compile without a parameter
%% |: what is the highest grade?
%% 97
%% |: what is the lowest grade?
%% 77
%% |: done?
%% bye
%% true .
% Some restrictions:
%
% Questions will always be just a series of words seperated by spaces
% - no commas or other strangeness.
%
% Questions will always end with a ?
%
% Everything is always is lowercase
%
% done? ends the loop
%
% hint: note that once you finish parsing a question, a '\n' is likely still
% stored in input and will be returned as a character when you next call
% get_char.  Make sure your input ignores it or your 2nd parse may be messed
% up.
%

get_string(X) :- get_code(Y), get_string_helper([],X,Y).
% get_string_helper(List,Result, 10) :- reverse(List, Reverse), string_codes(Result, Reverse), !.
get_string_helper(List,Result, 10) :- reverse(List, Result), !.
get_string_helper(List,Result, X) :- get_code(Y), get_string_helper([X|List],Result,Y).

% take input and split based on spaces
get_words(X) :- get_string(Y), string_codes(Y, Z), get_words_helper(Z,X).

split([32|List],[],List).
split([63],[],List).
split([H|List],[H|Part],Remainder) :- split(List,Part,Remainder).

multiple_splits([],Part,Result) :- reverse(Part,Result).
multiple_splits(List,Part,Result) :- split(List,A,B), multiple_splits(B,[A|Part],Result).

to_string([],Part,Result) :- reverse(Part,Result).
to_string([H|T],Part,Result) :- atom_codes(Word,H), to_string(T,[Word|Part],Result).

to_array([],Part,Result) :- reverse(Part,Result).
to_array([H|T],Part,Result) :- string_codes(H,Word), to_array(T,[Word|Part],Result).

do_nlp :- do_nlp_helper(start).
do_nlp_helper([done]) :- print('good bye').
do_nlp_helper(Stop) :- get_string(X), multiple_splits(X, [], Y), to_string(Y,[],Result), do_nlp_helper(Result).


% Stage C [30 points]: Improved parsing
%
% It's up to you!  Expand the NLP parser to be able to answer a
% greater variety of questions.  You should at least include 2 new
% structurally different questions (e.g. count the students that, is
% it true that) that have some internal variations.  Beyond that, have
% a good time.  Feel free to improve output, do error handling - just
% make some signifigant improvements of yur own.
%
% Include in the comments a fairly complete description of the kinds
% of new questions you support and any other features you added.

% Count the students that are <gender>
count_gender(Gender,X) :- grade(_,Gender,_), findall(Person, grade(_,Gender,_),People), length(People, X), !.

