# Phase 0 Finding — a Baseline Command Rewrote a Tracked File

Timestamp: 2026-08-30T06-22
Raised by: [P0-T13]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -CI"`

EXIT_CODE: 0

Output Summary: The [P0-T13] baseline command rewrote the tracked file `testResults.xml` at the
worktree root. The plan's "Command Forms" section asserts that every Phase 0 baseline is read-only.
That assertion does not hold for [P0-T13]. Baseline validity is unaffected, because the write
occurred at the last Phase 0 task, after every other baseline had been captured. The file was
restored to its `HEAD` content so the phase-boundary commit is not polluted.

## What the Plan Asserts

Under "Read-only baselines", the plan states:

> Every Phase 0 baseline uses a read-only command (`shell-qc.sh check`, `black --check`,
> `ruff check`, `pyright`, `prettier --check`, `eslint`, `tsc`). No write-mode formatter runs
> before a baseline is captured, so no baseline can be taken after a formatter has silently
> repaired pre-existing drift.

That enumeration omits the [P0-T13] Pester command, which is the one Phase 0 command that writes.

## What the Tree Shows

`Invoke-Pester -CI` enables JUnit/NUnit result-file output. Pester wrote its result document to
`testResults.xml` at the worktree root. That path is a **tracked** file, confirmed with
`git ls-files --error-unmatch testResults.xml`.

Observed diff against `HEAD` before restoration:

```
 testResults.xml | 369 ++++++--------------------------------------------------
 1 file changed, 40 insertions(+), 329 deletions(-)
```

The committed content was a Pester result document dated `2026-05-24` covering `total="124"` tests
from a different suite (`check-powershell-test-purity.Tests.ps1` among others), recorded with
`cwd="C:\Users\DanMoisan\repos\drm-copilot"`. The run replaced it with a document dated
`2026-08-30`, `total="27"`, `cwd` pointing at this worktree, covering only
`enforcement-hooks-no-python-invocation.Tests.ps1`.

Both the old and the new document record `failures="0"`.

## Impact Assessment

- **No baseline is invalidated.** [P0-T13] is the final Phase 0 task. Every other baseline was
  captured before this write, so none was taken after a tool silently repaired drift. The specific
  hazard the plan's read-only clause guards against did not occur.
- **The [P0-T13] result itself is unaffected.** Its acceptance rests on the Pester summary and the
  exit code, both recorded in
  `evidence/baseline/powershell-no-python-invocation.2026-08-30T06-22.md`. Writing the result file
  is Pester's normal `-CI` behavior and does not change the pass/fail outcome.
- **Commit hygiene was the live risk.** The orchestrator commits at the phase boundary. Left
  modified, this file would have entered the feature commit as an unrelated tracked-file change.

## Action Taken

`testResults.xml` was restored to its `HEAD` content with
`git checkout -- testResults.xml`. The file is a regenerable run artifact, so the restoration
discards no information that a later Pester run cannot reproduce. After restoration,
`git status --porcelain` over the worktree, excluding this feature's own folder, reports no
modifications.

No other file was touched by this action.

## Recommendation for Later Phases

Phases 4 through 6 run further PowerShell and whole-tree suites. Any `Invoke-Pester -CI` invocation
will rewrite `testResults.xml` again. Two options for the orchestrator, neither of which this
executor selected unilaterally:

1. Exclude `testResults.xml` from feature commits and restore it after each Pester run, as done
   here.
2. Treat the churn as expected and let it ride, accepting an unrelated file in the feature diff.

The underlying condition — a regenerable per-run result artifact being tracked in git — is outside
this feature's scope and is recorded here as an observation rather than proposed as work.
