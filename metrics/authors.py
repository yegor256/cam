import sys
from subprocess import Popen, PIPE


def noca(path: str) -> int:
    """
    calculate number of Committers/Authors
    :param path path to java file
    :rtype: int
    :return number of Committers/Authors
    """
    cd_comm: str = f"cd {'/'.join(path.split('/')[:-1])}"
    log_comm: str = f"git log --pretty=format:'%an%x09' {path} | sort | uniq"

    with Popen(
            f"({cd_comm} && {log_comm})",
            shell=True,
            stdout=PIPE,
            stderr=PIPE,
            universal_newlines=True
    ) as process:
        output, errors = process.communicate()
        del errors

    authors: list[str] = output.split()
    return len(authors)


if __name__ == '__main__':
    java: str = sys.argv[1]
    metrics: str = sys.argv[2]

    try:
        with open(metrics, 'a', encoding='utf-8') as metric:
            metric.write(f'authors {noca(java)}: '
                         f'Number of Committers/Authors\n')
    except FileNotFoundError as exception:
        message: str = f"{type(exception).__name__} {str(exception)}: {java}"
        sys.exit(message)
