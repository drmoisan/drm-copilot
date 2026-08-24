# Per-File Coverage — Final Verification (Remediation Cycle 2, Phase 6)

- **Issue:** #415
- **Task:** [P6-T3]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Finding:** R-COV
- **Source XML:** `artifacts/pester/powershell-coverage.xml`, produced by the [P6-T2] LOCAL authoritative run
- **Conventions:** C3 (package-qualified extraction), C6 (guarded-entrypoint classification and residual rule)

Timestamp: 2026-07-26T15-17

## Commands and Exit Codes

Command: `pwsh -NoProfile -Command "Import-Module '<REPO>/scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root '<REPO>'"` ([P6-T2])
EXIT_CODE: 0

Command: C3 extraction over `artifacts/pester/powershell-coverage.xml` — LINE counter keyed on
`package/@name` ending `.codex/hooks` plus `sourcefile/@name`; missed line numbers from
`sourcefile/line[@ci='0']/@nr`
EXIT_CODE: 0

Command: `grep -n "MyInvocation.InvocationName -eq" <both hooks>` (guard positions used for the C6 split)
EXIT_CODE: 0 — `enforce-epic-child-worktree-binding.ps1:282`, `enforce-epic-planning-only.ps1:270`.

## Output Summary

Both changed production hooks pass the >= 85% per-file line-coverage gate on their **raw** numbers. No C6
residual computation is required, no denominator was shrunk, no threshold was changed, no file was removed
from `CodeCoverage.Path`, and no assertion was weakened. The RD-4 failure branch is **not** taken.

### (i) Per-file table — both newly measured hooks

| Sourcefile | Covered | Missed | Total | Raw percent | Gate (>= 85%) |
|---|---|---|---|---|---|
| `.codex/hooks/enforce-epic-child-worktree-binding.ps1` | 153 | 7 | 160 | **95.62%** | **PASS** |
| `.codex/hooks/enforce-epic-planning-only.ps1` | 126 | 9 | 135 | **93.33%** | **PASS** |

Trajectory across the cycle:

| Hook | [P0-T6] | [P4-T3] | [P5-T3] | [P6-T3] |
|---|---|---|---|---|
| `enforce-epic-child-worktree-binding.ps1` | not measured | 83.75% | 95.62% | **95.62%** |
| `enforce-epic-planning-only.ps1` | not measured | 86.67% | 93.33% | **93.33%** |

### (ii) C6 residual computation

**Not applicable — and deliberately so.** C6 permits a residual
(`covered / (instrumented − justified-guarded-entrypoint instrumented)`) only "for a hook below 85% raw",
and states the residual "is never a substitute for a failing raw number". Both hooks are **above** 85%
raw, so no post-guard line is excluded from any denominator and no residual is computed. Every one of the
295 instrumented lines across the two hooks remains in the denominator.

For the audit record, had a residual been needed the excluded sets would have been the post-guard lines
itemized in section (iii); they are listed there as classification evidence only, not as an exclusion.

### (iii) Confirmation that no exercisable line remains uncovered

**`enforce-epic-child-worktree-binding.ps1`** — 7 missed lines, **all post-guard** (guard at line 282), so
zero exercisable lines remain. In-process entrypoint case attempted and present: [P1-T2](d)
(`codex-detached-head-transport.Tests.ps1`, "exits 0 with no stdout for a benign Bash payload when the
attestation is dormant"). Per-line reasons:

| Line | Content | Named per-line reason |
|---|---|---|
| 303 | `Get-Content -Raw -LiteralPath $attestation.receipt_path` | Reached only when the `CODEX_EPIC_CHILD_*` attestation is **active** and `$attestation.receipt_path` names an existing file. The present entrypoint case deliberately clears the attestation (the dormant CI default), and activating it requires an on-disk launch receipt, which committed tests may not create (Hard Constraint 6 forbids temporary files). |
| 309 | `(Get-FileHash -LiteralPath $attestation.spec_path ...)` | Same active-attestation precondition, plus an existing immutable launch-spec file to hash. |
| 314 | `ConvertFrom-CodexChildGuardJson -Raw $receiptRaw -Name 'launch receipt'` | Reached only when `$receiptRaw` is non-empty, which requires the receipt file from line 303 to exist. |
| 319 | `(Get-FileHash -LiteralPath ([string]$receipt.profile_path) ...)` | Requires a parsed receipt (line 314) plus an existing deployment-profile TOML to hash. |
| 328 | `$decision \| ConvertTo-Json -Compress -Depth 5 \| Write-Output` | Reached only when the decision is non-null, i.e. a deny under an active attestation. The dormant entrypoint case correctly produces a null decision. The deny envelopes themselves are fully covered at the decision layer by the [P5-T1] cases. |
| 332 | `[Console]::Error.WriteLine([string]$_)` | The `catch` arm. Reaching it requires the entrypoint to throw, which the fix specifically eliminated for the detached-HEAD input; forcing a throw would require malformed on-disk state (a temporary file). |
| 333 | `exit 2` | Same `catch` arm as 332. |

**`enforce-epic-planning-only.ps1`** — 9 missed lines: 8 post-guard (guard at line 270) plus 1 pre-guard
line non-exercisable under a named reason. Zero exercisable lines remain. In-process entrypoint case
attempted and present: [P2-T2](e) (`codex-detached-head-transport.Tests.ps1`, "exits 0 with no stdout for
a benign Bash payload"). Per-line reasons:

| Line | Content | Named per-line reason |
|---|---|---|
| 252 | `return & git @GitArgs 2>$null` | **Pre-guard, non-exercisable.** `Invoke-EpicPlanningGit` is the wrapper seam mandated by `.claude/rules/powershell.md` ("Design Seams", wrapper function seam preferred), and its entire body is the invocation of the live `git` executable. The same rule file requires tests to mock the wrapper rather than the executable and forbids unit tests from depending on live executables. Exercising this one line therefore requires precisely what the rule prohibits. Every behavior above it — the `$LASTEXITCODE` transport throw, the empty-output `''` return, and the trimmed-name return — is fully covered through the mock by the [P2-T2] cases. |
| 281 | `''` (else arm of the checkpoint read) | Reached only when `artifacts/orchestration/orchestrator-state.json` is **absent**. That file exists in this working tree and is not test-controllable without creating or deleting repository state, which a committed test may not do. |
| 288 | `$stagedPaths = @(& git -C $repositoryRoot diff --cached ...)` | Reached only for a `git commit`-shaped Bash payload driven through the entrypoint, which would invoke live `git` against the real index — nondeterministic and a live-executable dependency. |
| 289 | `if ($LASTEXITCODE -ne 0) {` | Same staged-paths block as 288. |
| 290 | `throw '... staged paths could not be resolved before commit.'` | Same block, and additionally requires `git diff --cached` to fail. |
| 295 | `$currentBranch = Get-EpicPlanningCurrentBranch -RepositoryRoot $repositoryRoot` | Reached only for a `git push`-shaped payload through the entrypoint. [P2-T2] deliberately does **not** drive that payload through the entrypoint because the entrypoint reads the mutable repository checkpoint, making the assertion nondeterministic; the push mapping is locked at the decision layer instead, and the resolver itself is directly unit-tested. |
| 304 | `$decision \| ConvertTo-Json -Compress -Depth 5 \| Write-Output` | Reached only when the decision is non-null. The current repository checkpoint has `route_id` `large`, so the dormant entrypoint case correctly yields a null decision. All deny envelopes are covered at the decision layer by [P2-T2] and [P5-T1]. |
| 308 | `[Console]::Error.WriteLine([string]$_)` | The `catch` arm; reaching it requires the entrypoint to throw, which the fix eliminated for the detached-HEAD input. |
| 309 | `exit 2` | Same `catch` arm as 308. |

Both hooks' post-guard bodies are minimal wiring: read stdin, read on-disk state, call the decision
function, emit the envelope. All decision logic they call is covered at 100% of its exercisable lines.

### (iv) Repo-wide line percentage and verdict

```
REPO-WIDE LINE: covered=3148 missed=189 total=3337 percent=94.34%
REPO-WIDE BRANCH: not emitted by this toolchain
```

Repo-wide LINE coverage **94.34%** — **PASS** against the >= 85% gate, with a 9.34-point margin.
PowerShell branch coverage is not separately measurable in this toolchain (documented limitation,
`spec.md:248`); the >= 75% branch gate is therefore not measurable here and is unchanged by this plan.

### (v) No per-file regression in the cycle-1 measured `.codex/hooks` files versus [P0-T6]

| Sourcefile | [P0-T6] | [P6-T3] | Regression? |
|---|---|---|---|
| `check-powershell-test-purity.ps1` | 62/62 = 100.00% | 62/62 = 100.00% | no |
| `check-python-test-purity.ps1` | 67/67 = 100.00% | 67/67 = 100.00% | no |
| `codex-pretooluse-file-mapping.ps1` | 101/101 = 100.00% | 101/101 = 100.00% | no |
| `enforce-checkpoint-monotonic.ps1` | 103/104 = 99.04% | 103/104 = 99.04% | no |
| `enforce-completion-consistency.ps1` | 136/136 = 100.00% | 136/136 = 100.00% | no |
| `enforce-evidence-locations.ps1` | 41/41 = 100.00% | 41/41 = 100.00% | no |
| `enforce-orchestration-preimplementation-gate.ps1` | 98/98 = 100.00% | 98/98 = 100.00% | no |
| `enforce-powershell-batch-budget.ps1` | 84/87 = 96.55% | 84/87 = 96.55% | no |
| `enforce-python-batch-budget.ps1` | 84/87 = 96.55% | 84/87 = 96.55% | no |
| `enforce-completion-helpers.ps1` (out of scope, pre-existing) | 33/43 = 76.74% | 33/43 = 76.74% | no |

Cycle-1 changed-file reference band **96.55% – 100.00%** held exactly; every covered/missed/total triple
is byte-identical to the [P0-T6] baseline. **No per-file regression.**

## Acceptance Verdict

| Gate | Result |
|---|---|
| `enforce-epic-child-worktree-binding.ps1` >= 85% raw | PASS (95.62%) |
| `enforce-epic-planning-only.ps1` >= 85% raw | PASS (93.33%) |
| C6 residual required | No — both pass raw |
| No exercisable line uncovered (per-line reasons for every non-exercisable claim) | PASS |
| Repo-wide LINE >= 85% | PASS (94.34%) |
| No cycle-1 per-file regression | PASS |
| RD-4 failure branch taken | No |

EXIT_CODE: 0
