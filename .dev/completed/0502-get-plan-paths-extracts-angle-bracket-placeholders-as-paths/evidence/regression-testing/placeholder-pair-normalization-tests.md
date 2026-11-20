# Regression Tests — Placeholder-Only Overlap, Pair Level — [P5-T3]

Timestamp: 2026-08-23T05-04

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P5-T3] (revision 6 form)
State captured: POST-FIX

This task replaced the unsatisfiable conflict fixture of the original [P5-T3] with one named test per
runtime, added to the two files [P5-T8] and [P5-T9] already edit. It creates no file, so the
created-path list stays at eight.

## Python runtime

Command: `poetry run pytest "tests/scripts/dev_tools/test_blast_radius_normalization.py::test_placeholder_only_overlap_stops_conflicting_after_normalization" -v`

EXIT_CODE: 0

```text
tests/scripts/dev_tools/test_blast_radius_normalization.py::test_placeholder_only_overlap_stops_conflicting_after_normalization PASSED [100%]
1 passed in 0.07s
```

Test name: `test_placeholder_only_overlap_stops_conflicting_after_normalization`
File: `tests/scripts/dev_tools/test_blast_radius_normalization.py`

## PowerShell runtime

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` set to
`["tests/scripts/claude-lib/blast-radius"]`.

EXIT_CODE: 0

Read from `artifacts/pester/pester-junit.xml`, since the tool returns only an ok flag and a summary:

```xml
<testsuites ... name="Pester" tests="402" errors="0" failures="0" disabled="0" time="26.498">
<testsuite name="...\BlastRadiusNormalization.Tests.ps1" tests="15" errors="0" failures="0" ... time="0.403">
```

```text
Passed | conflicts before normalization and stops conflicting after it
```

Test name: `Placeholder-only overlap after normalization (issue #502).Pair-level regression for the placeholder guard.conflicts before normalization and stops conflicting after it`
File: `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1`

The normalization suite grew from 12 tests to 15 across [P5-T9] and this task, with zero failures.
The whole folder reports 402 tests, 0 errors, 0 failures.

## Both halves of the assertion are present in each test

The acceptance requires each test to assert **both** the pre-normalization conflict and the
post-normalization absence of conflict. Both are asserted in both runtimes.

| Half | Python assertion | PowerShell assertion |
| --- | --- | --- |
| pre-normalization pair **does** conflict | `assert before.conflict is True`, plus `[reason.kind for reason in before.reasons] == ["path_overlap"]` and the placeholder appearing in the reason detail | `$before['conflict'] \| Should -BeTrue`, plus a reason count of 1, kind `path_overlap`, and a `-BeLike` match on the placeholder in the detail |
| post-normalization pair does **not** conflict | `assert after.conflict is False` and `after.reasons == ()` | `$after['conflict'] \| Should -BeFalse` and a reason count of 0 |
| placeholder dropped, real entries survive | four assertions over both normalized radii | four assertions over both normalized radii |

## Why both halves are required, and which one pins the fix

**The post-normalization half is the discriminating one.** `normalize_declared_radius` and
`Get-NormalizedDeclaredRadius` re-run the classifier over each recorded entry, so normalizing routes
the comparison through the guard. Before the guard existed the classifier accepted the placeholder
token as `'concrete'` — measured directly at [P0-T12] and [P0-T13] in both runtimes — so
normalization would have **retained** the entry, the normalized pair would still have shared it, and
this assertion would have failed. That is what makes the test a regression test rather than an
observation of a passing state.

**The pre-normalization half is the control.** The conflict relation compares recorded entries by
string equality, glob match, and directory containment and never calls the classifier; its two
callers are the extraction module and the declared-radius normalization entry point. So the raw pair
contends on a shared placeholder token whether or not the guard exists. Asserting it proves nothing
about the fix, and that is precisely its value: it proves the two radii genuinely share an entry.
Without it, a construction error that left the pair disjoint from the start would satisfy the
post-normalization assertion vacuously — the unfalsifiable class the preflight loop spent five cycles
removing.

Each test's docstring or comment block records that the normalization step is what places the
assertion on the classifier's path, as the task requires.

## Construction

Both tests use the same construction, and it is the same one the [P0-T16] and [P7-T7] repro uses:

- the only shared entry is the placeholder feature-document token,
- real files are disjoint and sit under **different** feature folders,
- modules, shared surfaces, and contracts are disjoint, so no level other than the path level can
  produce a reason.

Sibling real files in the same directory do not overlap: `_directory_prefix` anchors on the entry
itself with a trailing separator, so `scripts/dev_tools/alpha_only_module.py` does not start with
`scripts/dev_tools/beta_only_module.py/`. The disjointness is therefore genuine, and the [P0-T16]
negative control independently confirmed it by reporting conflict false for the same pair of real
files pre-fix.

## PowerShell probe-literal constraint

Every probe literal in the PowerShell test is single-quoted, and the placeholder is assembled by
character concatenation so no marker form appears as a parseable sequence. The test asserts the
probe's literal content and its exact character length (17) before using it, so an expansion
introduced by a later quoting change would fail the case rather than silently classify different
text. The appended block contains **zero** double-quoted strings, verified by a fixed-string count.

## Toolchain stages for this task

| Stage | Command | Result |
| --- | --- | --- |
| Python format | `poetry run black tests/scripts/dev_tools/test_blast_radius_normalization.py` | 1 file left unchanged |
| Python lint | `poetry run ruff check --no-fix <same file>` | All checks passed! |
| Python type-check | `poetry run pyright <same file>` | 0 errors, 0 warnings, 0 informations |
| PowerShell format | `mcp__drm-copilot__run_poshqc_format` scoped to the test folder | ok |
| PowerShell analyze | `mcp__drm-copilot__run_poshqc_analyze` scoped to the test folder | ok |
| tests | both commands above | both pass |

## Output Summary

Both named tests pass, one per runtime, added to files that already existed so no new file was
created. Each asserts both halves: that the pre-normalization pair conflicts on the shared
placeholder token with exactly one `path_overlap` reason, and that the normalized pair does not
conflict at all. The post-normalization half is the discriminating one and would fail on a tree where
the classifier was never fixed, because the pre-fix classifier accepted the placeholder as
`'concrete'` and normalization would have retained it.
