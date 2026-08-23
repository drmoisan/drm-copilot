# QA Gate — Final Python Linting — [P8-T2]

Timestamp: 2026-08-23T03-40

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T2]

Command: `poetry run ruff check .`

EXIT_CODE: 0

## Final output line, verbatim

```text
All checks passed!
```

The output's final line is exactly `All checks passed!`. **PASS.**

## The observation: no `Fixed ` output line

```text
$ poetry run ruff check . 2>&1 | grep -c '^Fixed '
0
```

Zero output lines begin with the literal `Fixed `. **PASS.**

## Why this command deliberately keeps the fixing form

Unlike [P0-T3] and [P2-T3], which pass `--no-fix`, this invocation uses the repository's configured
form. That is intentional: this is the toolchain loop's lint stage and the loop is meant to apply
fixes. What it must not do is apply one invisibly.

The repository configuration sets both switches, verified in `pyproject.toml`:

```text
91:fix = true
92:show-fixes = true
```

So Ruff rewrites fixable violations, still exits 0 when it does, and prints a `Fixed N error:` line
when it does. An exit-code-only gate therefore cannot observe an auto-fix, while the cross-language
toolchain rule requires a restart from the first stage whenever any stage auto-fixes a file — an
obligation that cannot be discharged by a signal nobody reads. The absence of the fix-indicator line
is that signal, in the same shape as the [P8-T1] formatter gate.

Had a `Fixed ` line appeared, the lint stage would have changed a file and the Phase 8 restart clause
would apply. None appeared.

## Restart-clause status

The lint stage changed no file, so the restart clause is not triggered by this task.

## Output Summary

Exit code 0. Final output line exactly `All checks passed!`, zero `Fixed ` lines. The lint stage of
the final toolchain loop is clean and changed no file, and the fix-indicator observation confirms
that rather than inferring it from the exit code.
