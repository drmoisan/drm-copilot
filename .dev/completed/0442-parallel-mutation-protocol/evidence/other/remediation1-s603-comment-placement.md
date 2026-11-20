# Remediation Cycle 1 — S603 Suppression Placement Correction (finding R6 / P5)

Timestamp: 2026-08-09T08-45

Task: [P6-T6]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
File: `scripts/dev_tools/parallel_mutation_abandon_cli.py`

## The Finding

Line 152 carried the full pre-authorized S603 comment text as a **standalone** comment, but Ruff
honours a `noqa` only on the line of the violation, so line 152 was **inert** — it read as a
suppression while suppressing nothing — and the effective suppression on line 153 was a bare
`# noqa: S603` with no rationale.

## Before

```python
    command = [executable, *argv[1:]]
    # noqa: S603 - static analysis can't verify runtime validation
    completed = subprocess.run(  # noqa: S603
        command,
        check=False,
    )
```

## After

```python
    command = [executable, *argv[1:]]
    # S603 rationale: static analysis can't verify runtime validation. The
    # executable is resolved through shutil.which above before the call.
    completed = subprocess.run(  # noqa: S603
        command,
        check=False,
    )
```

The inert directive-shaped comment is deleted. A non-directive rationale now sits on the two lines
immediately above the effective single-line suppression, which is retained verbatim as
`completed = subprocess.run(  # noqa: S603`.

## Recorded Reason for the Format Deviation, with Measured Arithmetic

`.claude/rules/python-suppressions.md` § S603 specifies the comment format
`# noqa: S603 - static analysis can't verify runtime validation` and its enforcement checklist
requires that format be used verbatim. Composing that verbatim text onto the suppressing line is
**impossible within the repository's 88-character Black/Ruff line limit**. The composed line,
reproduced verbatim and measured:

```
    completed = subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
```

**Measured length: 95 characters** — 7 over the 88-character limit.

The two replacement rationale lines, measured at indentation 4:

| Line | Text | Measured length |
| --- | --- | --- |
| 1 | `    # S603 rationale: static analysis can't verify runtime validation. The` | **74** |
| 2 | `    # executable is resolved through shutil.which above before the call.` | **72** |

Both are within 88.

**Why the composed line cannot simply be shortened.** Shortening it enough to fit would require
renaming the `subprocess` import path, but
`tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py` monkeypatches that call as
`cli.subprocess.run`. Renaming the path would break the test's monkeypatch seam, so the call
expression's length is fixed by the test contract.

**The rule's substantive requirements are unaffected and all still met:**

- the pattern is the **pre-authorized** S603 pattern (subprocess with a `shutil.which`-validated
  executable);
- the executable is validated by `shutil.which` at line 148, immediately above, and the call fails
  fast with `AbandonSideEffectError` when resolution returns `None`;
- the suppression scope is a **single line**, not file-level;
- the rationale text is present and accurate, merely relocated to the two lines above rather than
  appended to the suppressing line.

**No other suppression mechanism changed.** No `per-file-ignores` entry, no other `# noqa`, and no
`# type: ignore` was added, removed, or altered by this task.

## Verification

Command: `grep -n "# noqa" scripts/dev_tools/parallel_mutation_abandon_cli.py`
EXIT_CODE: 0
Output Summary: exactly one match, `154:    completed = subprocess.run(  # noqa: S603`. **No line of
the file contains a `# noqa` token that suppresses nothing.**

Command: `poetry run ruff check scripts/dev_tools`
EXIT_CODE: 0
Output Summary: `All checks passed!` — the relocated rationale did not disturb the effective
suppression, so S603 is still correctly suppressed on the violating line.

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -q`
EXIT_CODE: 0
Output Summary: **29 passed** — the CLI tests still pass, confirming the `cli.subprocess.run`
monkeypatch seam is intact.
