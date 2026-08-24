# Baseline — Python Linting — [P0-T3]

Timestamp: 2026-08-23T00-09

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T3]
State captured: PRE-CHANGE baseline

Command: `poetry run ruff check --no-fix .`

EXIT_CODE: 0

## Finding count

0 findings.

Ruff's final output line was exactly:

```text
All checks passed!
```

Ruff reports no finding count on a clean run; it emits the all-clear line instead. The finding
count of 0 is therefore read from that line together with the zero exit code.

## Why `--no-fix` is required and was not dropped

The repository `pyproject.toml` sets `fix = true` under the Ruff configuration. The bare
`poetry run ruff check .` form therefore rewrites every fixable violation in place and still
exits 0. Run as a baseline, that form would mutate the tree before the baseline it exists to
establish, and would report a clean exit for a tree it had just edited. `--no-fix` suppresses
the fix, making the invocation genuinely read-only and restoring exit-code fidelity, so a
non-zero exit means findings exist. The flag is hidden from `ruff check --help` but is honoured.
This mirrors the `--check` flag on the formatter at [P0-T2].

Read-only confirmation, taken immediately after the run:

```text
$ git status --porcelain -- '*.py'
(no output)
```

No Python file was modified by the lint invocation.

## Output Summary

Baseline Python lint is clean: exit code 0, 0 findings, `All checks passed!`. The tree was not
modified by the invocation.
