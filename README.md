# Rover
A coding challenge

## Requirements:

The program reads three lines of text, the first containing a grid size, the second 
containing a starting position and direction, and the third having a list of 
movement instructions.

The task is to interpret the input, calculate the final position, and report it.

The grid size is specified as an integer (S) consisting of two numerals.

	width = S / 10     (Horizontal)
	height = S mod 10  (Vertical)

Although it is not explicitly stated in the instructions, we assume that it is 
illegal to move outside of the grid boundaries.

We may assume that an invalid position or instruction is to be reported as an error.

As per the given example, for the provided input:

	88
	12 E
	MMLMRMMRRMML
	
the reported final position should be 3 3 S

## Approach:

At first glance, thie requirements are trivial.  The **naive solution** is to build a 
software representation of the mars rover (as a class), and then place it (the rover 
object) on a grid class, and move the rover around on the grid.

However, that is a complete overkill, since all we are required to produce is a final 
position and direction.  If we wanted an interactive GUI interface, perhaps the idea
of a full "rover on a grid" model would have made sense.

Nevertheless, we will encapsulate all the functionality of this app within a class, 
simply because it is more readable than a flat procedural application.

Since the specification is for a program which reads standard input and writes standard 
output, we will test the application by providing various inputs and checking for the
expected output.  Black box style.

What we need to know are:

	The bounds of the grid- in the above case 8 by 8
	The current position  (x,y cartesian)
	The current direction  (N,S,E or W)
	The displacement that the movement instructions produce
	
The sequence MMLMRMMRRMML may be interpreted, starting with the original direction, 
facing east as: E2N1E2W2S by replacing consecutive M's by the length of each segment,
and by replacing consecutive L or R instructions by the new direction.

Rewriting the navigation string simplifies calculation greatly, as we can simply add 
cardinal direction movements, N being opposite of S, and E being opposite of W.

So, we have (in the above string):

	E2
	N1
	E2     
	W2
	S  (final direction)

The number after the direction can never be larger than 9, that being the largest 
possible grid dimension (according to spec).  If it is, there is an error.

We can rewrite that using H and V for Horizontal and Vertical as:

	H+2
	V+1
	H+2
	H-2
	S  (final direction)

The last H+2 and H-2 obviously cancel out, leaving us with a movement of a single block 
north and 2 blocks east.  So we effectively moved from position (1, 2) to (1+2, 2+1)
or (3, 3). 

To achieve (N = -Vertical, S = +Vertical, W = -Horizontal, E = +Horizontal) for the 
cardinal directions, we can simply use NESW=[0,1,2,3] for addition being clockwise 
rotation and subtraction anti-clockwise.  We can use modulus 4 to ensure range is 
always valid.
	
## Usage:
   We expect the textual input on standard input, and will write the result to standard out,
	as described in the specification.
	
   You can run the program by typing:
   
    python rover.py
   
   You can run the tests by typing
   
    python -m unittest -v tests
     
