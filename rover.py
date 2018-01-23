#!/usr/bin/python
'''
    A mars rover moves on a grid of fixed height and width according to a set of
    predefined rotation or movement instructions.
    
    We read an initial grid size as an integer, where the first digit describes the
    grid width, and the second digit describes the height.
    
    The following input line contains the starting position as an integer, followed 
    by the initial direction.
    
    The third and last input line contains a set of movement instructions, where:
        M = move one block in current direction
        L = rotate direction left
        R = rotate direction right
    
    This program outputs the final position (x, y) and direction the rover is facing.
'''
from sys import stdin, stdout, stderr
import re

class Rover(object):
    directions = "NESW"  # clockwise increment direction = 0,1,2,3 for N,E,S,W
    
    def __init__(self):
        ''' Read, interpret instructions, and report a final position after 
            applying instruction list
        '''
        try:
            width, height = self.grid_size()
            xy_pos, direction = self.initial_pos(width, height)
            movements = self.read_movements()        
            summary, direction = self.translate_movements(movements, direction)
            final_x = self.process_summary(summary, 3, 1, xy_pos[0], width)            
            final_y = self.process_summary(summary, 2, 0, xy_pos[1], height)
            if final_x < 0:
                raise ValueError('Horizontal movement out of range.\n')
            elif final_y < 0:
                raise ValueError('Vertical movement out of range.\n')
            else:
                stdout.write("%s %s %s\n" % (final_x, final_y, self.directions[direction]))            
        except ValueError as e:
            stderr.write(str(e))

    def grid_size(self):
        ''' Read the grid size from stdin. '''
        sz = re.match(r"^([1-9])([1-9])$", stdin.readline())
        if sz is None:
            msg = ('Invalid grid size provided. \n'
                   'Expected format is a two digit number with the first numeral\n'
                   ' as width, and the second numeral being height. eg. 88.\n')
            raise ValueError(msg)
        return int(sz.group(1)), int(sz.group(2))

    def initial_pos(self, width, height):
        ''' Read the initial position from stdin. '''
        init_pos = re.match(r"^([1-9])([1-9]) ([NSEW])$", stdin.readline())
        if init_pos is None:
            msg = ('Unexpected format for starting position and direction.\n'
                   'Expect: xy D\n'
                   ' where x and y are single digit numbers, and D is one of NESW.')
            raise ValueError(msg)
        xy_pos = (int(init_pos.group(1)), int(init_pos.group(2)))
        if xy_pos[0] > width or xy_pos[1] > height:
            msg = 'Initial coordinate positions exceed grid size.'
            raise ValueError(msg)
        direction = self.directions.index(init_pos.group(3))  # initial direction
        return xy_pos, direction

    def read_movements(self):
        ''' Read movements from stdin '''
        movements = stdin.readline().strip()
        if len(movements) is 0:
            raise ValueError('No movement instructions were supplied.\n')
        if len(set(movements) - set('LRM')) > 0:
            raise ValueError('Movement instructions may contain only L, R or M.\n')
            
        movements = list(movements)
        movements.reverse()   # set up movements stack
        return movements
    
    def process_summary(self, summary, minus, plus, pos, a_max):
        ''' Update current position using movement summaries,
            and check for bounds of the grid being exceeded.
        '''
        for direction, delta in summary:
            if direction == minus:
                pos -= delta 
            elif direction == plus:
                pos += delta
            if pos < 1 or pos > a_max:
                return -1
        return pos
        
    def turn(self, direction, lr):
        '''  Turn left or right by incrementing or decrementing
            the current direction.
        '''
        if lr == 'L':
            direction -= 1
        elif lr == 'R':
            direction += 1
        return (direction + 4) % 4

    def translate_movements(self, movements, direction):
        '''  Produce a summary of movements and a 
            final direction by stepping once through
            movement instructions.
        '''
        summary = []
        n = 0
        curr = None
        while len(movements):
            curr = movements.pop()
            if curr in ['L', 'R']:
                if n > 0:
                    summary.append((direction, n))
                direction = self.turn(direction, curr)
                n = 0
            elif curr == 'M':
                n += 1
        if n > 0:
            summary.append((direction, n))
        return summary, direction
        
if __name__ == "__main__":
    Rover()

