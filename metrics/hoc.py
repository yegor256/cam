import pathlib
import sys

import javalang.tree
from javalang import parse
import subprocess


def hoc(file_path: str, class_name: str) -> int | None:
    path = pathlib.Path(file_path).name
    dir_path = pathlib.Path(file_path).parent
    command = (f'cd {dir_path} && git log -L:"class\\s{class_name}:{path}"'
               ' -s | grep -o -E "commit\\s\\S{40}" | wc -l')
    result = subprocess.run(command, text=True, shell=True, capture_output=True)

    # Expect error in case of inner class
    if result.stderr:
        return None

    return int(result.stdout)


if __name__ == '__main__':
    JAVA = sys.argv[1]
    METRICS = sys.argv[2]

    with open(JAVA, encoding='utf-8', errors='ignore') as f:
        try:
            to_return_hoc = {}
            ast_var = parse.parse(f.read())
            for _, node in ast_var.filter(javalang.tree.ClassDeclaration):

                node_class_name = node.name

                if node_class_name not in to_return_hoc:
                    hoc_number = hoc(JAVA, node_class_name)
                    if hoc_number:
                        to_return_hoc[node_class_name] = hoc_number

            with open(METRICS, 'a', encoding='utf-8') as m:
                for class_name in to_return_hoc:
                    m.write(f'hoc {class_name}:{to_return_hoc.get(class_name)} Hits Of Code for given class\n')
        except FileNotFoundError as exception:
            message = f"{type(exception).__name__} {str(exception)}: {JAVA}"
            sys.exit(message)
