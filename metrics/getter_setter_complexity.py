import sys
from javalang import tree, parse

sys.setrecursionlimit(10000)


def is_getter_or_setter(method):
    """Определяет, является ли метод геттером или сеттером."""
    if isinstance(method, tree.MethodDeclaration):
        if method.name.startswith("get") and len(method.parameters) == 0:
            return "getter"
        elif method.name.startswith("set") and len(method.parameters) == 1:
            return "setter"
    return None


def count_branches(node):
    """Считает количество ветвлений в методе."""
    count = 0
    if isinstance(node, (tree.IfStatement, tree.WhileStatement, tree.ForStatement, tree.DoStatement, tree.SwitchStatement, tree.CatchClause)):
        count = 1
    return count


def analyze_method(method):
    """Анализирует сложность метода."""
    method_type = is_getter_or_setter(method)
    if not method_type:
        return None

    complexity = 0
    branches = 0
    for _, node in method.filter(tree.Statement):
        branches += count_branches(node)

        if method_type == "setter":
            # Увеличиваем сложность за каждое обновление дополнительной переменной
            if isinstance(node, tree.Assignment) and node.expressionl != method.parameters[0].name:
                complexity += 1

        elif method_type == "getter":
            # Увеличиваем сложность за каждый стейтмент, не связанный с возвращаемой переменной
            if not (isinstance(node, tree.ReturnStatement) and node.expression.member == method.name[3:].lower()):
                complexity += 1

    # Увеличение сложности за ветвления
    complexity += branches

    return method_type, complexity, branches


if __name__ == '__main__':
    JAVA = sys.argv[1]
    METRICS = sys.argv[2]
    with open(JAVA, encoding='utf-8', errors='ignore') as f:
        try:
            ast = parse.parse(f.read())
            for _, node in ast.filter(tree.MethodDeclaration):
                result = analyze_method(node)
                if result:
                    method_type, complexity, branches = result
                    with open(METRICS, 'a', encoding='utf-8') as m:
                        m.write(f'{method_type} {complexity} {branches} Branches of {node.name}\n')
        except FileNotFoundError as exception:
            message = f"{type(exception).__name__} {str(exception)}: {JAVA}"
            sys.exit(message)
