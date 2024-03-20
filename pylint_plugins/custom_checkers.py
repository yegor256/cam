#!/usr/bin/env python3
# The MIT License (MIT)
#
# Copyright (c) 2021-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from astroid import nodes
from pylint.checkers import BaseChecker
from pylint.lint import PyLinter


class ConstantChecker(BaseChecker):
    """Сlass for checking the correct location of constants.
    Variables in UPPERCASE should only be declared at the top level of the module
    """
    name = 'constant-checker'
    priority = -1
    msgs = {
        'E1019': (
            'Constant "%s" should be defined at the top of the module',
            'non-top-level-constant',
            'Emitted when a constant is not defined in the top level'
        )
    }

    def visit_assignname(self, node: nodes.AssignName) -> None:
        """Called when a variable definition is node in the ast tree
        """
        if node.name.isupper() and not isinstance(node.parent.parent, nodes.Module):
            self.add_message('non-top-level-constant', node=node, args=(node.name,))


def register(linter: PyLinter) -> None:
    """Function to register extra pylint checkers.
    If you want to write your own checker dont forget to register it here
    """
    linter.register_checker(ConstantChecker(linter))
