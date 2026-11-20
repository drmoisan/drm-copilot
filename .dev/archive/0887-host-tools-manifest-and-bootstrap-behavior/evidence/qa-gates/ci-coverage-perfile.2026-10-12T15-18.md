# CI Per-File Coverage Evidence (P2-T11, AC-17)

Timestamp: 2026-10-12T15-18
Supplied-By: parallel-orchestrator (performed by item orchestrator under delegation) for the downloaded artifact `poshqc-test-results` of PR CI run 38294481892 (headSha 59fa06a04f8b75dcf9dc43466f8758f2345bd2c8)
Reader re-created: no

## Step 1: locate coverage file

Command: Glob tool, pattern `SCRATCH/887/ci-pr-887/**/powershell-coverage.xml`
Result: exactly one match, `SCRATCH/887/ci-pr-887/powershell-coverage.xml`

## Step 2: line-drift guard

Command: git fetch origin main && git diff --exit-code HEAD...origin/main -- scripts/dev-tools
EXIT_CODE: 0 (fetch exit 0; guard printed nothing and exited 0)
Observation: origin/main = 153534cdba5ea322efa8486a20df45d20ae38296, equal to `git merge-base HEAD origin/main`. No merge was required; SCRATCH/887/merge-main-887.txt was not written.

## Step 3: changed-line diff

Command: git diff -U0 origin/main...HEAD -- scripts/dev-tools > SCRATCH/887/changed-887.diff
EXIT_CODE: 0 (18 hunk headers written)

## Step 4: coverage reader

Command: poetry run python SCRATCH/887/coverage_perfile_887.py SCRATCH/887/ci-pr-887/powershell-coverage.xml HostTooling.psm1 HostBootstrapWorkspace.psm1 HostBootstrap.psm1 publish-sideloaded-extension.ps1 --diff SCRATCH/887/changed-887.diff
EXIT_CODE: 0

Reader output (verbatim):

```
FILE HostTooling.psm1 covered=40 missed=2 pct=95.24
FILE HostBootstrapWorkspace.psm1 covered=64 missed=0 pct=100.00
FILE HostBootstrap.psm1 covered=154 missed=0 pct=100.00
FILE publish-sideloaded-extension.ps1 covered=32 missed=0 pct=100.00
CHANGED HostTooling.psm1 instrumented=5 covered=5 pct=100.00 uncovered=none
CHANGED HostBootstrapWorkspace.psm1 instrumented=6 covered=6 pct=100.00 uncovered=none
CHANGED HostBootstrap.psm1 instrumented=3 covered=3 pct=100.00 uncovered=none
CHANGED publish-sideloaded-extension.ps1 instrumented=16 covered=16 pct=100.00 uncovered=none
```

## Output Summary:

PASS. Four FILE lines and four CHANGED lines; no MISSING line. Post-change line coverage: HostTooling.psm1 95.24, HostBootstrapWorkspace.psm1 100.00, HostBootstrap.psm1 100.00, publish-sideloaded-extension.ps1 100.00. Changed-line coverage is 100.00 for all four files (uncovered lists: none, none, none, none). Every value is >= 85.00. Line-drift guard passed. Coverage-exclusion absence is recorded separately by P2-T8.
