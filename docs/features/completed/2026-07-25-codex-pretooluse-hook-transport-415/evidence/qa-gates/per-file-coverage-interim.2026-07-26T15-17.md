# Per-File Coverage — Interim Extraction and Batch-2 Gap List (Remediation Cycle 2, Phase 5)

- **Issue:** #415
- **Task:** [P5-T3]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Finding:** R-COV
- **Source XML:** `artifacts/pester/powershell-coverage.xml`, produced by the [P5-T2] LOCAL authoritative run
- **Conventions:** C3 (package-qualified extraction), C6 (guarded-entrypoint classification)

Timestamp: 2026-07-26T15-17

## Commands and Exit Codes

Command: `pwsh -NoProfile -Command "Import-Module '<REPO>/scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root '<REPO>'"` ([P5-T2])
EXIT_CODE: 0

Command: C3 extraction over `artifacts/pester/powershell-coverage.xml` — LINE counter keyed on
`package/@name` ending `.codex/hooks` plus `sourcefile/@name`; missed line numbers from
`sourcefile/line[@ci='0']/@nr`
EXIT_CODE: 0

## Output Summary

Both changed hooks now clear the >= 85% per-file line gate on their **raw** numbers, so no C6 residual
computation is required. Every exercisable missed line catalogued at [P4-T3] is covered. No exercisable
line remains, so [P6-T1] is eligible for its `NO-FURTHER-GAP` branch.

### (i) Per-file table — both new hooks plus the cycle-1 measured `.codex/hooks` set

| Sourcefile | Covered | Missed | Total | Percent | [P4-T3] | Movement | >= 85%? |
|---|---|---|---|---|---|---|---|
| `enforce-epic-child-worktree-binding.ps1` | 153 | 7 | 160 | **95.62%** | 83.75% | **+11.87** | **PASS** |
| `enforce-epic-planning-only.ps1` | 126 | 9 | 135 | **93.33%** | 86.67% | **+6.66** | **PASS** |
| `check-powershell-test-purity.ps1` | 62 | 0 | 62 | 100.00% | 100.00% | 0 | PASS |
| `check-python-test-purity.ps1` | 67 | 0 | 67 | 100.00% | 100.00% | 0 | PASS |
| `codex-pretooluse-file-mapping.ps1` | 101 | 0 | 101 | 100.00% | 100.00% | 0 | PASS |
| `enforce-checkpoint-monotonic.ps1` | 103 | 1 | 104 | 99.04% | 99.04% | 0 | PASS |
| `enforce-completion-consistency.ps1` | 136 | 0 | 136 | 100.00% | 100.00% | 0 | PASS |
| `enforce-evidence-locations.ps1` | 41 | 0 | 41 | 100.00% | 100.00% | 0 | PASS |
| `enforce-orchestration-preimplementation-gate.ps1` | 98 | 0 | 98 | 100.00% | 100.00% | 0 | PASS |
| `enforce-powershell-batch-budget.ps1` | 84 | 3 | 87 | 96.55% | 96.55% | 0 | PASS |
| `enforce-python-batch-budget.ps1` | 84 | 3 | 87 | 96.55% | 96.55% | 0 | PASS |
| `enforce-completion-helpers.ps1` (out of scope, pre-existing) | 33 | 10 | 43 | 76.74% | 76.74% | 0 | n/a |

Cycle-1 changed-file band held at **96.55% – 100.00%** with every value byte-identical to [P0-T6] and
[P4-T3]. No per-file regression anywhere in the measured set.

### (ii) `NO-GAP` records

None. The `NO-GAP` branch of [P5-T1] was not available, because [P4-T3] measured
`enforce-epic-child-worktree-binding.ps1` at 83.75% raw. Gap-closure tests were written instead: 21 cases
in `codex-worktree-binding-hook.Tests.ps1` and 10 in `codex-planning-only-hook.Tests.ps1`.

### (iii) Remaining missed lines and their C6 classification — defines Phase 6

**`enforce-epic-child-worktree-binding.ps1`** (dot-source guard at line 282) — 7 missed lines, **all
post-guard**, zero exercisable:

| Line | Content | C6 classification |
|---|---|---|
| 303 | `Get-Content -Raw -LiteralPath $attestation.receipt_path` | post-guard entrypoint |
| 309 | `(Get-FileHash -LiteralPath $attestation.spec_path -Algorithm SHA256).Hash.ToLowerInvariant()` | post-guard entrypoint |
| 314 | `ConvertFrom-CodexChildGuardJson -Raw $receiptRaw -Name 'launch receipt'` | post-guard entrypoint |
| 319 | `(Get-FileHash -LiteralPath ([string]$receipt.profile_path) ...).Hash.ToLowerInvariant()` | post-guard entrypoint |
| 328 | `$decision \| ConvertTo-Json -Compress -Depth 5 \| Write-Output` | post-guard entrypoint |
| 332 | `[Console]::Error.WriteLine([string]$_)` | post-guard entrypoint |
| 333 | `exit 2` | post-guard entrypoint |

All 19 exercisable pre-guard lines from [P4-T3] (24, 29, 41, 75, 76, 78, 93, 173, 176, 185, 189, 193, 196,
198, 204, 229, 232, 236, 239) are now **covered**.

**`enforce-epic-planning-only.ps1`** (dot-source guard at line 270) — 9 missed lines: 8 post-guard plus
the 1 pre-guard line already classified non-exercisable under a named reason at [P4-T3]:

| Line | Content | C6 classification |
|---|---|---|
| 252 | `return & git @GitArgs 2>$null` | pre-guard, non-exercisable under the [P4-T3] named reason: `Invoke-EpicPlanningGit` is the mandated wrapper seam and its whole body is the live-`git` invocation, which `.claude/rules/powershell.md` forbids unit tests from calling |
| 281 | `''` (the else arm of the checkpoint read) | post-guard entrypoint |
| 288 | `$stagedPaths = @(& git -C $repositoryRoot diff --cached ...)` | post-guard entrypoint |
| 289 | `if ($LASTEXITCODE -ne 0) {` | post-guard entrypoint |
| 290 | `throw 'EPIC_PLANNING_ONLY_BLOCKED: staged paths could not be resolved before commit.'` | post-guard entrypoint |
| 295 | `$currentBranch = Get-EpicPlanningCurrentBranch -RepositoryRoot $repositoryRoot` | post-guard entrypoint |
| 304 | `$decision \| ConvertTo-Json -Compress -Depth 5 \| Write-Output` | post-guard entrypoint |
| 308 | `[Console]::Error.WriteLine([string]$_)` | post-guard entrypoint |
| 309 | `exit 2` | post-guard entrypoint |

All 9 exercisable pre-guard lines from [P4-T3] (32, 33, 35, 120, 127, 141, 204, 208, 245) are now
**covered**.

**Remaining exercisable missed lines, both hooks: 0.** Because both hooks pass the raw >= 85% gate, C6's
residual rule does not apply and no post-guard line needs to be excluded from any denominator. The
post-guard lines are itemized above for the [P6-T3] record, not to shrink a denominator.

### (iv) Repo-wide line percentage

```
REPO-WIDE LINE: covered=3148 missed=189 total=3337 percent=94.34%
```

Repo-wide LINE coverage: **94.34%**. Verdict versus the >= 85% gate: **PASS**. Higher than the [P0-T6]
baseline of 94.31% despite a denominator 295 lines larger. PowerShell branch coverage is not separately
emitted by this toolchain (documented limitation, `spec.md:248`).

## Phase 6 Eligibility

[P6-T1]'s `NO-FURTHER-GAP` branch condition is satisfied on both counts:

- section (iii) lists **no remaining exercisable missed lines** for either hook, and
- section (iv) shows repo-wide **94.34% >= 85%**.

[P6-T1] therefore creates no files and records `NO-FURTHER-GAP`. [P6-T2] runs unconditionally regardless.

EXIT_CODE: 0
