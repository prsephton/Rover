import unittest
import sys
from StringIO import StringIO
import rover

class TestSpecification(unittest.TestCase):
    
    def run_rover(self, spec):
        err = rover.stderr = StringIO()
        out = rover.stdout = StringIO()
        rover.stdin = StringIO(spec)
        
        rover.Rover()    
        
        rover.stderr = sys.stderr
        rover.stdout = sys.stdout
        rover.stdin = sys.stdin
        return out, err
    
    def test_specification(self):
        out, _err = self.run_rover("88\n12 E\nMMLMRMMRRMML\n")
        self.assertEqual(out.getvalue(), '3 3 S\n')
        
    def test_alternate2(self):
        out, _err = self.run_rover("88\n12 S\nMLLMMMRMM\n")
        self.assertEqual(out.getvalue(), '3 4 E\n')
        
    def test_bounds(self):
        _out, err = self.run_rover("88\n12 S\nMM\n")
        self.assertIn('Vertical movement out of range.', err.getvalue())
        
    def test_grid_size(self):
        _out, err = self.run_rover("00\n12 S\nMM\n")
        self.assertIn('grid size', err.getvalue())
        
    def test_positions(self):
        _out, err = self.run_rover("55\n64 S\nMM\n")
        self.assertIn('positions exceed grid size', err.getvalue())

    def test_directions(self):
        _out, err = self.run_rover("55\n44 Q\nMM\n")
        self.assertIn('starting position and direction', err.getvalue())
        
    def test_movements1(self):
        _out, err = self.run_rover("55\n44 S\nMMFLLLR\n")
        self.assertIn('instructions may contain only', err.getvalue())
        
    def test_movements2(self):
        _out, err = self.run_rover("55\n44 S\n\n")
        self.assertIn('No movement instructions were supplied', err.getvalue())

if __name__ == '__main__':
    unittest.main()
