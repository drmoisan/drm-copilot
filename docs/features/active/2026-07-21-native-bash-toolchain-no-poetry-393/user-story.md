# `native-bash-toolchain-no-poetry` — User Story

- Issue: #393
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-21T18-19

## Story Statement

- As a developer running the bash quality-control toolchain under WSL, I want `scripts/bash/shell-qc.sh`
  to run `check`, `format`, and `test` (including coverage) without a Python interpreter or a
  Poetry-managed virtual environment, so that I can lint, format, and test shell scripts using
  only the native tools the scripts themselves require (`shfmt`, `shellcheck`, `bats`, `kcov`).
- As a CI workflow maintainer, I want `_shell-coverage.yml` and `_build-check.yml` to invoke the
  native bash wrapper directly, so that the shell quality-control path no longer installs Poetry
  or a Python virtual environment to run bash-only checks.

## Problem / Why

The repository's shell (bash) quality-control toolchain is driven by a Python module,
`scripts/dev_tools/shell_qc.py`, invoked through Poetry console scripts
(`poetry run shell-qc check|format|test`, plus `shell-qc-check|format|test`). This couples
the bash toolchain to a Python interpreter and a Poetry-managed virtual environment. The
toolchain is intended to run under WSL and must not depend on Python or Poetry. The
toolchain is also undocumented in `.claude/rules/`, which lists `python.md`, `powershell.md`,
`typescript.md`, and `csharp.md` but no bash/shell rule, so skills and agents have no
authoritative shell toolchain reference.

## Personas & Scenarios

- Persona: Developer working on shell scripts under `tools/` and `scripts/` from a WSL shell.
  - Who: a repository contributor editing or adding `.sh` files or bash-shebang scripts.
  - What they care about: fast, direct feedback from `shfmt`/`shellcheck`/`bats` without
    waiting on a Python virtual environment to build or activate.
  - Their constraints: works inside WSL on Windows; does not want a Poetry install or a
    `.venv` as a prerequisite for a purely bash-tooling task.
  - Their goals and frustrations: wants `check`, `format`, and `test` to behave exactly as
    they did under the Python wrapper (same discovery rules, same skip messages, same exit
    codes) so muscle memory and existing task/CI expectations still hold; frustrated when a
    bash-only task requires standing up a Python toolchain first.
  - Their context and motivations: this developer may not have Poetry installed at all, or
    may be working in an environment where installing it is undesirable.
- Scenario: A developer adds a new script under `scripts/` and runs the toolchain locally
  before pushing.
  - Who is acting: the developer described above.
  - What triggered the action: a new or modified `.sh` file needs formatting and linting
    before commit.
  - What steps do they take: run `bash scripts/bash/shell-qc.sh format`, then `bash
    scripts/bash/shell-qc.sh check`, then `bash scripts/bash/shell-qc.sh test`, optionally with
    `--coverage`.
  - What obstacles or decisions occur: if `shfmt`, `shellcheck`, `bats`, or `kcov` is missing
    locally, the wrapper must report exactly which tool is missing and how to install it,
    with exit code 127, rather than failing with a Python traceback or an unclear error.
  - What outcome do they expect: the same discovery, linting, and coverage behavior as the
    prior Python-driven toolchain, but with zero Python or Poetry involvement at any step.
- Scenario: A CI workflow run executes the shell coverage job on `ubuntu-latest`.
  - Who is acting: the `_shell-coverage.yml` reusable workflow (triggered via `ci.yml` or
    `workflow_dispatch`).
  - What triggered the action: a push or pull request that touches shell scripts or the
    workflow files themselves.
  - What steps do they take: install `shellcheck`/`shfmt`/`bats`/`kcov` (unchanged steps),
    then invoke `bash scripts/bash/shell-qc.sh test --coverage` directly, with no Python
    setup, no Poetry install, and no cached virtual environment.
  - What obstacles or decisions occur: the workflow must still upload `cov.xml` under
    `artifacts/pester/kcov/**` as before; removing the Python/Poetry steps must not change
    that artifact contract.
  - What outcome do they expect: a green CI run that produces the same coverage artifact and
    summary output as the Python-driven toolchain did, without the Poetry install steps.

## Acceptance Criteria

- [x] AC1: A native bash wrapper `scripts/bash/shell-qc.sh` provides `check`, `format`, and
      `test` subcommands that invoke `shfmt`, `shellcheck`, and `bats` directly, with no
      Python and no Poetry involved.
- [x] AC2: The `test` subcommand supports a coverage mode that runs `bats` under `kcov` and
      emits a Cobertura `cov.xml`, preserving the prior behavior.
- [x] AC3: The wrapper reproduces the prior discovery rules: searches `tools/` and
      `scripts/`; recognizes `.sh` suffix or bash/sh shebang; excludes `.venv`, `.git`,
      `node_modules`, `dist`, `build`; runs bats against `tests/shell` and `tests/bash` when
      present.
- [x] AC4: `scripts/dev_tools/shell_qc.py` is removed and all five Poetry console-script
      entries referencing it are removed from `pyproject.toml`.
- [x] AC5: No component of the shell toolchain (local or CI) invokes Python or Poetry.
- [x] AC6: `.github/workflows/_shell-coverage.yml` and `.github/workflows/_build-check.yml`
      invoke the native bash wrapper with no Poetry install or `poetry run`.
- [x] AC7: `.claude/rules/shell.md` exists, is path-scoped to shell files, and documents the
      native toolchain, invocation, and coverage policy.
- [x] AC8: The native wrapper is covered by bats tests under `tests/shell/`.
- [x] AC9: A green CI run against the branch head verifies the modified workflows
      (`modified-workflow-needs-green-run`).

## Non-Goals

- Porting the Python module's `pyright` subcommand into the native bash toolchain. It is
  Python tooling, not bash tooling; carrying it forward would reintroduce the Poetry
  dependency this feature exists to remove. Pyright remains reachable via `poetry run
  pyright` per `.claude/rules/python.md`, independent of this change.
- Changing Poetry's role for the rest of the Python toolchain (black/ruff/pyright/pytest);
  only the shell-qc console-script surface is removed from `pyproject.toml`.
- Providing a dual-path (Python-and-bash) interim toolchain; this is an atomic replacement of
  the shell toolchain's entry point, not a phased or feature-flagged migration.
