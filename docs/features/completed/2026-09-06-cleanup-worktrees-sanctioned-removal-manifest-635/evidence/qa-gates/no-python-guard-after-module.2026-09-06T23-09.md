# No-Python Guard State After The New Module

Timestamp: 2026-09-08T02-42

Task: [P1-T9]

Command:
`git grep -c -F "ships an empty allowlist" -- tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`

EXIT_CODE: 0

The recorded exit code belongs to the search command above, whose success case is 0 because the count
is at least 1. It is deliberately not the [P1-T8] run's exit code: that code belongs to
`evidence/qa-gates/batch-a-suite.2026-09-06T23-09.md`, which declares `ExpectedExitCode: 2`.
Recording it here, where no expectation is declared, would make this passing gate render as a failed
one, because `scripts/dev_tools/pr_context/verification_evidence.py:122-128` takes the last row whose
pre-colon text is exactly `EXIT_CODE` as the artifact's result and `:163-164` defaults a missing
expectation to `0`.

## Route

`pwsh` cannot be invoked in this worktree, so a single Pester suite cannot be started on its own.
[P0-T8] recorded the same constraint and read this suite's result out of the full-suite run instead,
which is the route this task uses. The `testsuite` element below is taken from the
`artifacts/pester/pester-junit.xml` written by the [P1-T8] run.

## Transcribed suite element

```
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1" tests="27" errors="0" failures="0" hostname="MEGALODON4" id="112" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1" time="1.642">
```

The transcribed start tag is not an exit code and carries no `EXIT_CODE:` row.

| Check | Required | Observed | Result |
| --- | --- | --- | --- |
| `failures` | `0` | `0` | pass |
| `errors` | `0` | `0` | pass |
| `tests` | at least 27, the count [P0-T8] recorded at baseline | 27 | pass |
| Search count for the empty-allowlist test | at least 1 | 1 | pass |

## Why both halves are needed

The suite element alone would not show the empty-allowlist test still exists — a suite whose only
assertion had been deleted would still report zero failures. The search alone would not show the test
passed. Together they show the named test `It 'ships an empty allowlist'` is still present in a suite
whose failures are zero.

The suite scans `.claude/hooks` and `.claude/lib` for `*.ps1` and `*.psm1` with an AST-based check,
so `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` entered its scope the moment it was
written. The module contains no Python invocation and no `Invoke-Expression`.

Output Summary: The no-Python guard is green with the new module in scope. Its `testsuite` element
from the [P1-T8] full-suite run reports `tests="27" errors="0" failures="0"`, matching the baseline
count [P0-T8] recorded, and the fixed-string search for the named empty-allowlist test returns a
count of 1 at exit status 0. Contributes to AC-23; AC-23 also requires the delivery-obligation run
recorded in a later phase, so it is not checked off here.
