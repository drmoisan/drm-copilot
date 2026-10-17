# NB-4 Follow-Up After Main Moved (P8-T17)

Timestamp: 2026-10-16T04-25

Branch taken: follow-up. The greatest `main-freshness-pre-nb4-commit.*.md` (`main-freshness-pre-nb4-commit.2026-10-16T04-22.md`) recorded `MAIN-MOVED`, and P7-T2 recorded `NO-MERGE-NEEDED` (not `MERGE-ABORTED`).

## Gate 1: merge

Command: git merge --no-ff -F SCRATCH/929/P8-T17-merge-msg.txt origin/main
EXIT_CODE: 0
Output (summary): `Merge made by the 'ort' strategy.`; 37 files changed, 1899 insertions, all under `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/` (35 files) and two test files `tests/scripts/claude-runtime/...preimplementation-gate-epic-scope.Decision.Tests.ps1` and `...-import-failure-exemptions.FailClosed.Tests.ps1` (PR #947, issue #936). No conflict.

Merge outcome: `MERGED`
Merge commit: `dc91a92d58c8d2aa1ad99bcc86ad2f25dd604138` (subject `chore(929): merge origin/main after NB-4 conversion`; message ends with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`)
Conflicted paths: none

## Gate 2: E3 locate

See `evidence/other/e3-folder-location-follow-up.2026-10-16T04-24.md`: `E3_SPEC: docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md`; clarification lines present at 378 and 388; no re-insertion.

## Gate 3: census (first run)

Command: sh SCRATCH/929/P8-T17-2.sh
Script: `foreach ($p in @('New-SubagentStopEnvelopeJson','Builds and returns envelope JSON text only')) { $m = @(Get-ChildItem -Path tests -Recurse -Include *.ps1 | Select-String -SimpleMatch -Pattern $p); 'CENSUS_TOTAL | ' + $p + ' | ' + $m.Count; $m | Group-Object Path | ForEach-Object { 'CENSUS_PATH | ' + (Resolve-Path -Relative -LiteralPath $_.Name) + ' | ' + $_.Count } }`
EXIT_CODE: 0
Output:
```
CENSUS_TOTAL | New-SubagentStopEnvelopeJson | 0
CENSUS_TOTAL | Builds and returns envelope JSON text only | 0
```

ADDITIONAL paths: none (no `CENSUS_PATH |` line; no call site was merged from `main`).

## Gate 4: census (second run)

Command: sh SCRATCH/929/P8-T17-2.sh
EXIT_CODE: 0
Output:
```
CENSUS_TOTAL | New-SubagentStopEnvelopeJson | 0
CENSUS_TOTAL | Builds and returns envelope JSON text only | 0
```

## Gate 5: eight-suite runner

Command: sh SCRATCH/929/P8-T17-3.sh
Script: the eight-suite runner body (Fixed names), verbatim as in `nb4-suites.2026-10-16T04-20.md`.
EXIT_CODE: 0
Output (totals):
```
FAILED=0
FAILED_BLOCKS=0
FAILED_CONTAINERS=0
PASSED=224
```
The full output is line-for-line identical to the P8-T12 output in `nb4-suites.2026-10-16T04-20.md` (`diff` exited 0 with no output).

Output Summary: Follow-up branch taken; merge outcome `MERGED` at `dc91a92d58c8d2aa1ad99bcc86ad2f25dd604138`; no `ADDITIONAL:` path; both census totals are `0` on the second run; the runner exits 0 with `FAILED=0` and `PASSED=224`. The follow-up commit hash is recorded below after the commit.

Follow-up commit: `e0e3d76136c2fd62db41c723f0d76159bf5bc689` (pushed; `git status --porcelain -- . ":(exclude)SCRATCH"` listed nothing after the push).
