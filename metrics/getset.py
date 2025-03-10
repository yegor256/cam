#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

# This metric counts the number of getter and setter methods in a class.

import sys
from antlr4 import FileStream, CommonTokenStream, ParseTreeWalker
from generated.JavaLexer import JavaLexer
from generated.JavaParser import JavaParser
from generated.JavaParserListener import JavaParserListener
from antlr4.error.ErrorListener import ErrorListener

sys.setrecursionlimit(10000)

class MyErrorListener(ErrorListener):
    def __init__(self):
        super(MyErrorListener, self).__init__()
        self.has_errors = False

    def syntaxError(self, recognizer, offendingSymbol, line, column, msg, e):
        has_errors = True


class GetSetMethodListener(JavaParserListener):
    def __init__(self):
        super().__init__()
        self.getter_count = 0
        self.setter_count = 0


    def enterMethodDeclaration(self, ctx: JavaParser.MethodDeclarationContext):
        method_name = ctx.children[1].getText()
        params = ctx.formalParameters().formalParameterList()
        if method_name.startswith('get') and params is None:
            self.getter_count += 1
        elif method_name.startswith('set') and params and len(params.formalParameter()) == 1:
            self.setter_count += 1


def parse_java_file(java_file):
    error_listener = MyErrorListener()
    lexer = JavaLexer(FileStream(java_file))
    lexer.removeErrorListeners()
    lexer.addErrorListener(error_listener)
    tokens = CommonTokenStream(lexer)
    parser = JavaParser(tokens)
    parser.removeErrorListeners()
    parser.addErrorListener(error_listener)
    tree = parser.compilationUnit()
    if error_listener.has_errors:
        return None, None
    walker = ParseTreeWalker()
    listener = GetSetMethodListener()
    walker.walk(listener, tree)
    return listener.getter_count, listener.setter_count


if __name__ == '__main__':
    java = sys.argv[1]
    metrics = sys.argv[2]
    try:
        getter_count, setter_count = parse_java_file(java)
        if getter_count or setter_count:
            with open(metrics, 'a', encoding='utf-8') as m:
                m.write(f'Getters {getter_count} The number of getter methods\n')
                m.write(f'Setters {setter_count} The number of setter methods\n')
    except FileNotFoundError as exception:
        message = f"{type(exception).__name__} {str(exception)}: {java}"
        sys.exit(message)
