# Contributing to CaM

Thank you for your interest in contributing! Please follow these guidelines to help us maintain a high-quality project.

## Branching Model
- All development should be done in feature branches, not directly on `master`.
- Name your branch descriptively, e.g., `feature/add-new-metric` or `bugfix/fix-typo`.
- Open a pull request (PR) against `master` when your changes are ready for review.

## Code Style Guides
- **Python:**
  - Follow [PEP8](https://www.python.org/dev/peps/pep-0008/) style.
  - Linting is enforced with `flake8` and `pylint` (see `.github/workflows/flake8.yml` and `.github/workflows/pylint.yml`).
- **Bash:**
  - Use [ShellCheck](https://www.shellcheck.net/) and [bashate](https://github.com/openstack/bashate) for shell scripts.
  - Linting is enforced in CI (`.github/workflows/shellcheck.yml`, `.github/workflows/bashate.yml`).
- **Markdown:**
  - Documentation should follow [Markdownlint](https://github.com/DavidAnson/markdownlint) rules (see `.github/workflows/markdown-lint.yml`).
- **General:**
  - Run `make lint` before submitting your PR to check all style and linting rules.

## Running and Adding Tests
- To run all tests locally:
  ```bash
  sudo make test lint
  ```
- To run tests in Docker:
  ```bash
  docker build . -t cam
  docker run --rm cam make test
  # Or, for a faster run if you don't change install scripts:
  docker run -v $(pwd):/c --rm yegor256/cam:0.9.3 make -C /c test
  ```
- To add a test for a new metric:
  1. Create a test script in `tests/metrics/` (see existing files for examples).
  2. Ensure your test covers both typical and edge cases for your metric.
  3. Run the full test suite to verify your test passes.

## Proposing New Metrics or Features
- To add a new metric:
  1. Create a new script in the `metrics/` directory (use `ast.py` or other scripts as examples).
  2. Add a corresponding test in `tests/metrics/`.
  3. Update documentation as needed (e.g., `metrics/README.md`).
  4. Run all tests and lint checks.
  5. Open a pull request with a clear description of your metric and its purpose.
- For other features or bug fixes:
  - Open an issue first if you are unsure about the approach.
  - Follow the same process: branch, code, test, document, and submit a PR.

## Questions?
If you have any questions, open an issue or start a discussion. We appreciate your contributions!
