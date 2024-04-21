#!/usr/bin/env python3
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
    with open(java, encoding='utf-8', errors='ignore') as f:
        try:
            ast = parse.parse(f.read())
            for _, tree_node in ast.filter(tree.MethodDeclaration):
                if (result := analyze_method(tree_node)):
                    method_type_result, complexity_result, branches_result = result
                    with open(metrics, 'a', encoding='utf-8') as m:
                        m.write(f'Method name: {method_type_result}; Complexity: {complexity_result}; Branches: {branches_result}\n')
        except FileNotFoundError as exception:
            message = f"{type(exception).__name__} {str(exception)}: {java}"
            sys.exit(message)
