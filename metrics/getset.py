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

import sys
from javalang import tree, parse

sys.setrecursionlimit(10000)


def is_getter_or_setter(method: tree.MethodDeclaration) -> str | None:
    """Figures out whether a method is a getter or a setter."""
    if isinstance(method, tree.MethodDeclaration):
        if method.name.startswith("get") and len(method.parameters) == 0:
            return "getter"
        if method.name.startswith("set") and len(method.parameters) == 1:
            return "setter"
    return None


def count_branches(node: tree.Node) -> int:
    """Counts the number of branches in a method."""
    count = 0
    if isinstance(node, (tree.IfStatement, tree.WhileStatement, tree.ForStatement,
                         tree.DoStatement, tree.SwitchStatement, tree.CatchClause)):
        count = 1
    return count


def analyze_method(method: tree.MethodDeclaration) -> tuple[str, int, int] | None:
    """Analyzes the complexity of the method."""
    if not (method_type := is_getter_or_setter(method)):
        return None

    complexity = 0
    branches = 1
    for _, statement_node in method.filter(tree.Statement):
        branches += count_branches(statement_node)

        if method_type == "setter":
            # Increase complexity for each additional variable assignment
            if isinstance(statement_node, tree.Assignment) and statement_node.expressionl != method.parameters[0].name:
                complexity += 1

        elif method_type == "getter":
            # Increase complexity for each statement not related to the returned variable
            if not (isinstance(statement_node, tree.ReturnStatement)
                    and statement_node.expression.selectors[0].member == method.name[3:].lower()):
                complexity += 1

    # Increase complexity for branching
    complexity += branches

    return method_type, complexity, branches


if __name__ == '__main__':
    java = sys.argv[1]
    metrics = sys.argv[2]

    getter_max_complexity = 0
    setter_max_complexity = 0
    with open(java, encoding='utf-8', errors='ignore') as f:
        try:
            ast = parse.parse(f.read())
            for _, tree_node in ast.filter(tree.MethodDeclaration):
                if (result := analyze_method(tree_node)):
                    method_type_result, complexity_result, branches_result = result
                    if (method_type_result == 'getter' and complexity_result > getter_max_complexity):
                        getter_max_complexity = complexity_result

                    if (method_type_result == 'setter' and complexity_result > setter_max_complexity):
                        setter_max_complexity = complexity_result

            with open(metrics, 'a', encoding='utf-8') as m:
                m.write(f'MaxGetterComplexity {getter_max_complexity} The maximum complexity of a getter method\n')
                m.write(f'MaxSetterComplexity {setter_max_complexity} The maximum complexity of a setter method\n')
        except FileNotFoundError as exception:
            message = f"{type(exception).__name__} {str(exception)}: {java}"
            sys.exit(message)
