#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
