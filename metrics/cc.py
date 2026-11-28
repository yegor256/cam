#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

"""Source-level Cognitive Complexity, with PMD-compatible executable aggregation."""

import sys
from collections.abc import Callable
from typing import Any

import javalang

TREE = javalang.tree
EXECUTABLES = (TREE.MethodDeclaration, TREE.ConstructorDeclaration)
STRUCTURAL = (
    TREE.ForStatement, TREE.WhileStatement, TREE.DoStatement,
    TREE.TernaryExpression, TREE.CatchClause, TREE.SwitchStatement,
)


class Complexity:
    """Score one executable; boolean runs end at block statement boundaries."""

    def __init__(self, ancestors: list[Any], selected: set[int], cycles: set[int]) -> None:
        self.cycles = cycles
        self.ancestors = ancestors
        self.selected = selected
        self.methods = [node for node in ancestors if isinstance(node, TREE.MethodDeclaration)]
        self.classes = []
        for node in ancestors:
            if isinstance(node, TREE.ClassDeclaration):
                self.classes.append(node)
            elif isinstance(node, TREE.ClassCreator) and node.body is not None:
                self.classes.append(TREE.ClassDeclaration(name='', body=node.body))

    @staticmethod
    def binding_type(declarations: list[Any], name: str) -> str | None:
        """Return an empty type for a bound but uninferred name, never a class name."""
        for declaration in reversed(declarations):
            names = [variable.name for variable in getattr(declaration, 'declarators', [])]
            names.append(getattr(declaration, 'name', getattr(declaration, 'member', None)))
            if name in names:
                if (kind := getattr(declaration, 'type', None)) is None:
                    return ''
                dimensions = getattr(kind, 'dimensions', None)
                return str(kind.name) + ('[]' if dimensions else '')
        return None

    @staticmethod
    def control_bindings(parent: Any, child: Any) -> list[Any]:
        """Limit loop, catch and resource bindings to their Java scopes."""
        result = []
        if isinstance(parent, TREE.CatchClause):
            parameter = parent.parameter
            kind = TREE.ReferenceType(name=parameter.types[0]) if len(parameter.types) == 1 else None
            result = [TREE.FormalParameter(name=parameter.name, type=kind)]
        elif isinstance(parent, TREE.ForStatement) and child is parent.body:
            control = parent.control
            if isinstance(control, TREE.EnhancedForControl):
                result = [control.var]
            elif isinstance(control.init, TREE.VariableDeclaration):
                result = [control.init]
        elif isinstance(parent, TREE.ForControl) and child is not parent.init:
            if isinstance(parent.init, TREE.VariableDeclaration):
                result = [parent.init]
        elif isinstance(parent, TREE.TryStatement) and child is parent.block:
            result = list(parent.resources or [])
        return result

    @classmethod
    def visible_bindings(cls, parent: Any, child: Any) -> list[Any]:
        """Collect only declarations whose lexical scope contains this call."""
        result = []
        if isinstance(parent, list):
            before = parent[:next((index for index, item in enumerate(parent)
                                   if item is child), len(parent))]
            statements = [statement for item in before
                          for statement in (item.statements if isinstance(item, TREE.SwitchStatementCase)
                                            else [item])]
            result = [item for item in statements
                      if isinstance(item, (TREE.LocalVariableDeclaration, TREE.TryResource))]
        elif isinstance(parent, EXECUTABLES + (TREE.LambdaExpression,)):
            result = list(parent.parameters)
        elif isinstance(parent, (TREE.ClassDeclaration, TREE.ClassCreator)) and child is parent.body:
            result = [item for item in parent.body or [] if isinstance(item, TREE.FieldDeclaration)]
        elif isinstance(parent, (TREE.LocalVariableDeclaration, TREE.VariableDeclaration)):
            # A declarator is in scope in its own initializer, but later ones are not.
            names = []
            for variable in parent.declarators:
                names.append(variable)
                if variable is child:
                    break
            result = [TREE.VariableDeclaration(type=parent.type, declarators=names)]
        else:
            result = cls.control_bindings(parent, child)
        return result

    def variable_type(self, name: str) -> str | None:
        """Resolve from the call outwards, respecting blocks and captured bindings."""
        children = self.ancestors[1:] + [None]
        for parent, child in reversed(list(zip(self.ancestors, children))):
            if (kind := self.binding_type(self.visible_bindings(parent, child), name)) is not None:
                return kind
        return None

    def argument_type(self, node: Any) -> str | None:
        """Infer simple argument types to distinguish same-arity overloads."""
        result = None
        if isinstance(node, TREE.MemberReference) and not node.qualifier:
            result = self.variable_type(node.member)
        elif isinstance(node, TREE.Literal):
            if node.value in ('true', 'false'):
                result = 'boolean'
            elif node.value.startswith('"'):
                result = 'String'
            elif node.value.startswith("'"):
                result = 'char'
            elif node.value != 'null':
                result = 'int' if node.value.isdigit() else None
        elif isinstance(node, TREE.BinaryOperation):
            left = self.argument_type(node.operandl)
            right = self.argument_type(node.operandr)
            result = left if left == right else None
        return result

    def resolve_call(self, node: Any) -> Any:
        """Resolve unambiguous source-local calls, without guessing external types."""
        if id(node) in self.selected:
            return None
        scopes = list(reversed(self.classes))
        receiver = next((parent for parent in reversed(self.ancestors)
                         if isinstance(parent, TREE.This)
                         and parent.selectors and parent.selectors[0] is node), None)
        if receiver is not None:
            names = {id(scope): '.'.join(item.name for item in self.classes[:index + 1]
                                         if item.name)
                     for index, scope in enumerate(self.classes)}
            scopes = ([scope for scope in scopes
                       if receiver.qualifier in (scope.name, names[id(scope)])][:1]
                      if receiver.qualifier else scopes[:1])
        elif node.qualifier:
            kind = self.variable_type(node.qualifier)
            name = node.qualifier if kind is None else kind
            scopes = [scope for scope in scopes if scope.name == name][:1]
        for scope in scopes:
            members = [member for member in scope.body
                       if isinstance(member, TREE.MethodDeclaration) and member.name == node.member]
            candidates = [member for member in members
                          if len(member.parameters) == len(node.arguments)]
            if len(candidates) > 1:
                types = [self.argument_type(argument) for argument in node.arguments]
                candidates = [member for member in candidates
                              if [parameter.type.name for parameter in member.parameters] == types]
            if members:
                return candidates[0] if len(candidates) == 1 else None
        return None

    def visit(self, node: Any, nesting: int = 0) -> int:
        """Dispatch explicit traversal rules; try itself has no structural cost."""
        if isinstance(node, (list, tuple)):
            return sum(self.visit(child, nesting) for child in node)
        if not isinstance(node, javalang.ast.Node):
            return 0
        handlers: dict[Any, Callable[[Any, int], int]] = {
            TREE.IfStatement: self.if_statement,
            TREE.BinaryOperation: self.binary,
            TREE.MethodDeclaration: self.executable,
            TREE.ConstructorDeclaration: self.executable,
            TREE.ClassDeclaration: self.class_declaration,
            TREE.ClassCreator: self.creator,
            TREE.LambdaExpression: self.lambda_expression,
            TREE.TryStatement: self.try_statement,
        }
        if type(node) in handlers:
            return handlers[type(node)](node, nesting)
        score = 0
        if isinstance(node, (TREE.BreakStatement, TREE.ContinueStatement)):
            score = int(node.goto is not None)
        if isinstance(node, STRUCTURAL):
            score += 1 + nesting
            nesting += 1
        return score + sum(self.visit(child, nesting) for child in node.children)

    def if_statement(self, node: Any, nesting: int, else_if: bool = False) -> int:
        """Else-if/else add a flat point and nest only their own bodies."""
        score = self.visit(node.condition, nesting)
        score += 1 if else_if else 1 + nesting
        score += self.visit(node.then_statement, nesting + 1)
        if isinstance(node.else_statement, TREE.IfStatement):
            score += self.if_statement(node.else_statement, nesting, True)
        elif node.else_statement is not None:
            score += 1 + self.visit(node.else_statement, nesting + 1)
        return score

    def binary(self, node: Any, nesting: int) -> int:
        """Count changes between operators in source order, rather than AST preorder."""
        if node.operator in ('&&', '||'):
            operators, operands = self.logical_chain(node)
            changes = sum(operator != previous for previous, operator
                          in zip([''] + operators, operators))
            return changes + sum(self.visit(operand, nesting) for operand in operands)
        return sum(self.visit(child, nesting) for child in node.children)

    def executable(self, node: Any, nesting: int) -> int:
        """Keep lexical method context for source-local recursive calls."""
        if method := isinstance(node, TREE.MethodDeclaration):
            self.methods.append(node)
        score = self.visit(node.body, nesting) + int(method and id(node) in self.cycles)
        if method:
            self.methods.pop()
        return score

    def class_declaration(self, node: Any, nesting: int) -> int:
        """Local classes increase nesting while their bodies are visited."""
        self.classes.append(node)
        score = self.visit(node.body, nesting + 1)
        self.classes.pop()
        return score

    def creator(self, node: Any, nesting: int) -> int:
        """Anonymous bodies nest; constructor arguments keep the current level."""
        score = self.visit(node.arguments, nesting) + self.visit(node.selectors, nesting)
        if node.body is not None:
            scope = TREE.ClassDeclaration(name='', body=node.body)
            score += self.class_declaration(scope, nesting)
        return score

    def lambda_expression(self, node: Any, nesting: int) -> int:
        """Lambdas increase nesting without adding a point themselves."""
        return self.visit(node.body, nesting + 1)

    def try_statement(self, node: Any, nesting: int) -> int:
        """Try, resources and finally keep their level; catches are structural."""
        return (self.visit(node.resources, nesting) + self.visit(node.block, nesting)
                + self.visit(node.catches, nesting) + self.visit(node.finally_block, nesting))

    def logical_chain(self, node: Any, root: bool = True) -> tuple[list[str], list[Any]]:
        """Flatten in source order; a negated group starts an independent sequence."""
        if (isinstance(node, TREE.BinaryOperation) and node.operator in ('&&', '||')
                and (root or '!' not in getattr(node, 'prefix_operators', []))):
            left, first = self.logical_chain(node.operandl, False)
            right, second = self.logical_chain(node.operandr, False)
            return left + [node.operator] + right, first + second
        return [], [node]


def cognitive_complexity(parsed: Any) -> int:
    """Sum independent method/constructor scores throughout the compilation unit.

    Like PMD's executable rule, an enclosing method includes local/anonymous
    bodies at increased nesting, and each nested executable is also scored
    independently. Member classes start independent scores at nesting zero.
    """
    selected = set()
    for path, node in parsed.filter(TREE.MethodInvocation):
        for parent in path:
            selectors = getattr(parent, 'selectors', None) or []
            if any(selector is node for selector in selectors):
                if not isinstance(parent, TREE.This) or selectors[0] is not node:
                    selected.add(id(node))
    graph: dict[int, set[int]] = {}
    for path, node in parsed.filter(TREE.MethodInvocation):
        owners = [parent for parent in path if isinstance(parent, EXECUTABLES)]
        if owners and isinstance(owners[-1], TREE.MethodDeclaration):
            if (target := Complexity(list(path), selected, set()).resolve_call(node)) is not None:
                graph.setdefault(id(owners[-1]), set()).add(id(target))
    cycles = recursive_methods(graph)
    return sum(Complexity(list(path), selected, cycles).visit(node)
               for path, node in parsed if isinstance(node, EXECUTABLES))


def recursive_methods(graph: dict[int, set[int]]) -> set[int]:
    """Each method in a direct or indirect cycle gets exactly one point."""
    reachable = {method: set(targets) for method, targets in graph.items()}
    for intermediate in graph:
        for targets in reachable.values():
            if intermediate in targets:
                targets.update(reachable[intermediate])
    return {method for method, targets in reachable.items() if method in targets}


def main() -> None:
    """Append CoCoJ without overwriting PMD's CoCo or other metric rows."""
    if len(sys.argv) != 3:
        print(f'Usage: python {sys.argv[0]} <path to the .java file> <output file with metrics>')
        sys.exit(1)
    try:
        with open(sys.argv[1], encoding='utf-8') as source:
            parsed = javalang.parse.parse(source.read())
        if not list(parsed.filter(TREE.ClassDeclaration)):
            raise ValueError('The file does not contain a valid class declaration')
        score = cognitive_complexity(parsed)
        with open(sys.argv[2], 'a', encoding='utf-8') as output:
            output.write(f'CoCoJ {score} Cognitive Complexity computed with javalang; '
                         'sum of method and constructor scores (PMD executable aggregation)\n')
    except (OSError, ValueError, javalang.parser.JavaSyntaxError,
            javalang.tokenizer.LexerError) as error:
        sys.exit(f'Error: {error}')


if __name__ == '__main__':
    main()
