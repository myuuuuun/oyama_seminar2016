#!/usr/bin/env python
# -*- coding: utf-8 -*-


import operator

class NumberCell(object):
    """
     ---
    |   |
     ---
    |   |
     ---

    を,
    左縦棒: [0, 1]
    中央横棒: [2, 3, 4]
    右縦棒: [5, 6]
    とする.
    """
    def __init__(self, num=None):
        self.patterns = {
            "1": [[True, True, False, False, False, False, False], [False, False, False, False, False, True, True]],
            "2": [[False, True, True, True, True, True, False]],
            "3": [[False, False, True, True, True, True, True]],
            "4": [[True, False, False, True, False, True, True]],
            "5": [[True, False, True, True, True, False, True]],
            "6": [[True, True, True, True, True, False, True]],
            "7": [[True, False, True, False, False, True, True]],
            "8": [[True, True, True, True, True, True, True]],
            "9": [[True, False, True, True, True, True, True]],
            "0": [[True, True, True, False, True, True, True]]
        }

        # list of bool: True if stick exists
        if num is None:
            self.sticks = [False for i in range(7)]
        else:
            self.sticks = self.patterns[str(num)][0]

    def eval(self):
        for i in range(10):
            if self.sticks in self.patterns[str(i)]:
                return i
        return None

    def set(self, num):
        self.sticks = self.patterns[str(num)][0]


class OperatorCell(object):
    """
      |
     ---
      |

    を, 縦棒: 0, 横棒: 1とする.
    """
    def __init__(self, sig=None):
        self.patterns = {
            "plus": [True, True],
            "minus": [False, True]
        }

        # list of bool: True if stick exists
        if sig is None:
            self.sticks = [False for i in range(2)]
        else:
            self.sticks = self.patterns[sig]


    def eval(self):
        if self.sticks == self.patterns["plus"]:
            return operator.__add__

        if self.sticks == self.patterns["minus"]:
            return operator.__sub__

        return None

    def set(self, sig):
        if sig == "plus":
            self.sticks = self.patterns["plus"]
        elif sig == "minus":
            self.sticks = self.patterns["minus"]
        raise ValueError



class EqualCell(object):
    def __init__(self):
        pass

    def eval(self):
        return operator.__eq__


class Matches(object):
    def __init__(self, lhs, rhs):
        self.lhs = lhs
        self.rhs = rhs

    def eval(self):
        lhs_list = []
        for cell in self.lhs:
            e = cell.eval()
            if e is None:
                return None
            lhs_list.append(e)

        rhs_list = []
        for cell in self.rhs:
            e = cell.eval()
            if e is None:
                return None
            rhs_list.append(e)

        


if __name__ == "__main__":
    cells = [NumberCell(9), OperatorCell("minus"), NumberCell(6), OperatorCell("minus"), NumberCell(3), EqualCell(), NumberCell(3)]
    m = Matches(cells)

    for c in cells:
        print(c.eval())

    print(m.eval())





