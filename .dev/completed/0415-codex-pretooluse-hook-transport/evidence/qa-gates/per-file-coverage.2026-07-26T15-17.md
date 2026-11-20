# Per-File Coverage and Gap Classification (Remediation Cycle 2, Phase 4)

- **Issue:** #415
- **Task:** [P4-T3]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Finding:** R-COV
- **Source XML:** `artifacts/pester/powershell-coverage.xml`, produced by the [P4-T2] LOCAL authoritative run
- **Conventions:** C3 (package-qualified extraction), C6 (guarded-entrypoint classification)

Timestamp: 2026-07-26T15-17

## Commands and Exit Codes

Command: `pwsh -NoProfile -Command "Import-Module '<REPO>/scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root '<REPO>'"` ([P4-T2])
EXIT_CODE: 0

Command: C3 extraction over `artifacts/pester/powershell-coverage.xml` — key on `package/@name` ending in
`.codex/hooks` and `sourcefile/@name`; LINE counter; missed line numbers from `sourcefile/line[@ci='0']/@nr`
EXIT_CODE: 0

Command: `grep -n "MyInvocation.InvocationName -eq" .codex/hooks/enforce-epic-child-worktree-binding.ps1 .codex/hooks/enforce-epic-planning-only.ps1` (re-measure the dot-source guard positions after the Phase 1/2 insertions)
EXIT_CODE: 0

```
.codex/hooks/enforce-epic-child-worktree-binding.ps1:282
.codex/hooks/enforce-epic-planning-only.ps1:270
```

Both guards moved from their planning-time positions (270 and 248) by the inserted resolver functions,
exactly as the plan anticipated.

## Output Summary

The R-COV gap is closed as a measurement matter: the coverage XML now contains both hooks. The measured
file count rose from **39 to 41** and the analyzed-command count from **4,246 to 4,594**, which is the
denominator growth [P4-T1] intended. One hook passes the >= 85% per-file line gate raw; the other does not
and defines the Phase 5 work.

### Repo-wide LINE coverage

| Point | Covered | Missed | Total | Percent |
|---|---|---|---|---|
| [P0-T6] baseline (39 files) | 2869 | 173 | 3042 | 94.31% |
| [P4-T2] after adding both hooks (41 files) | 3120 | 217 | 3337 | 93.50% |

Repo-wide LINE coverage **93.50%** — PASS against the >= 85% gate. The 0.81-point decrease is denominator
growth from the two newly measured hooks (295 additional lines, 251 of them already covered by
pre-existing and Phase 1/2 tests), not a loss of coverage on any previously measured line. No file was
removed from measurement and no threshold was changed.

### Per-file table — the two NEWLY measured hooks

| Sourcefile | Covered | Missed | Total | Percent | >= 85% raw? |
|---|---|---|---|---|---|
| `enforce-epic-child-worktree-binding.ps1` | 134 | 26 | 160 | **83.75%** | **NO** |
| `enforce-epic-planning-only.ps1` | 117 | 18 | 135 | **86.67%** | YES |

In-process entrypoint case present per C6? **Yes for both**: [P1-T2](d) for the worktree-binding hook and
[P2-T2](e) for the planning-only hook.

### Missed-line classification — `enforce-epic-child-worktree-binding.ps1` (guard at line 282)

**Pre-guard, dot-source-reachable → EXERCISABLE (19 lines).** No enclosing function here is
non-invocable, so C6's named-function exception does not apply to any of them.

| Line | Content | Enclosing function | Phase 5 target |
|---|---|---|---|
| 24 | `throw "EPIC_WORKTREE_BINDING_BLOCKED: $Name is empty."` | `ConvertFrom-CodexChildGuardJson` | empty-raw throw |
| 29 | `throw "... is malformed JSON: $_"` | `ConvertFrom-CodexChildGuardJson` | malformed-JSON throw |
| 41 | `Join-Path $BasePath $Path` | `Get-CodexChildGuardCanonicalPath` | relative-path branch |
| 75 | `if ($toolName -in @('Bash', 'shell_command'))` | `Test-CodexChildGuardMutation` | Bash/shell_command arm |
| 76 | `return $true` | `Test-CodexChildGuardMutation` | same |
| 78 | `return $false` | `Test-CodexChildGuardMutation` | unclassified tool arm |
| 93 | `return $false` | `Test-CodexChildGuardProtectedPathMutation` | non-mutation short-circuit |
| 173 | `$errors.Add($receiptError)` | `Test-CodexChildGuardAttestation` | receipt-validator error propagation |
| 176 | `$errors.Add('launch receipt validator is unavailable.')` | `Test-CodexChildGuardAttestation` | validator-absent branch |
| 185 | `$errors.Add('the checked-in deployment profile path or hash has changed.')` | `Test-CodexChildGuardAttestation` | profile mismatch |
| 189 | `$errors.Add('the hook payload model does not match the launch receipt.')` | `Test-CodexChildGuardAttestation` | payload model mismatch |
| 193 | `$errors.Add('the hook payload agent type does not match the launch receipt.')` | `Test-CodexChildGuardAttestation` | payload agent mismatch |
| 196 | `[string]$Payload.model_reasoning_effort` | `Test-CodexChildGuardAttestation` | `model_reasoning_effort` property arm |
| 198 | `[string]$Payload.reasoning_effort` | `Test-CodexChildGuardAttestation` | `reasoning_effort` fallback arm |
| 204 | `$errors.Add('the hook payload reasoning effort does not match the launch receipt.')` | `Test-CodexChildGuardAttestation` | reasoning mismatch |
| 229 | `return $null` | `Invoke-CodexEpicChildGuardDecision` | non-MCP non-mutation allow |
| 232 | `return Get-CodexChildGuardDenyDecision -Reason 'the launcher authorization receipt is missing.'` | `Invoke-CodexEpicChildGuardDecision` | receipt-missing deny |
| 236 | `... 'only repository-scoped drm-copilot MCP tools are authorized ...'` | `Invoke-CodexEpicChildGuardDecision` | non-drm MCP deny |
| 239 | `... 'nested Codex execution is prohibited inside an epic child.'` | `Invoke-CodexEpicChildGuardDecision` | nested-codex deny |

Preflight advisory honored: none of the cases above requires calling `Test-CodexChildGuardAttestation`
with `-LiveBranch ''`. That function declares `[Parameter(Mandatory)][string] $LiveBranch` without
`[AllowEmptyString()]` (line 134), so an empty value throws a parameter-binding error. Every attestation
case below passes a non-empty branch name and drives mismatch behavior through other fields, and the
empty-branch path is exercised through `Invoke-CodexEpicChildGuardDecision`, whose own `$LiveBranch`
declares `[AllowEmptyString()]` (line 217). The signature is not changed.

**Post-guard, entrypoint body → candidate `guarded-entrypoint` (7 lines):** 303, 309, 314, 319, 328,
332, 333. These sit inside the `try`/`catch` entrypoint and require an *active* attestation with
on-disk receipt, spec, and profile files. Committed tests may not create temporary files
(Hard Constraint 6), so they are not reachable from a policy-compliant committed test. They are itemized
with per-line reasons at [P6-T3] only if a residual computation is required; the Phase 5 target is to
clear the raw gate without any residual.

**Arithmetic for the Phase 5 target:** covering all 19 exercisable pre-guard lines yields
153 / 160 = **95.63%** raw. Clearing the 85% gate requires only 2 of the 19 (136 / 160 = 85.00%), so the
target has substantial margin.

### Missed-line classification — `enforce-epic-planning-only.ps1` (guard at line 270)

Raw 86.67% already passes the >= 85% gate. Classification is recorded for completeness and to define
optional margin work.

**Pre-guard, dot-source-reachable → EXERCISABLE (9 lines):**

| Line | Content | Enclosing function |
|---|---|---|
| 32 | `if ($Optional) {` | `ConvertFrom-EpicPlanningJson` |
| 33 | `return $null` | `ConvertFrom-EpicPlanningJson` |
| 35 | `throw "EPIC_PLANNING_ONLY_BLOCKED: $Name is empty."` | `ConvertFrom-EpicPlanningJson` |
| 120 | `return $true` | `Test-EpicPlanningBashAllowed` (`git add` allow) |
| 127 | `return $false` | `Test-EpicPlanningBashAllowed` (`git add` with no tokens) |
| 141 | `return $false` | `Test-EpicPlanningBashAllowed` (`git commit` with empty staged set) |
| 204 | `... 'execution-through-CI statuses must remain not-applicable during preparation.'` | `Invoke-EpicPlanningOnlyDecision` |
| 208 | `... 'preparation apply_patch input must identify planning artifact paths.'` | `Invoke-EpicPlanningOnlyDecision` |
| 245 | `... "tool '$toolName' is not classified for preparation mode."` | `Invoke-EpicPlanningOnlyDecision` |

**Pre-guard, NON-EXERCISABLE under a named reason (1 line):**

| Line | Content | Named reason |
|---|---|---|
| 252 | `return & git @GitArgs 2>$null` | `Invoke-EpicPlanningGit` is the mandated wrapper seam, and its entire body is the invocation of the live `git` executable. `.claude/rules/powershell.md` requires tests to mock the wrapper and never the executable, and prohibits unit tests from depending on live executables. Exercising this single line therefore requires the one thing the rule forbids. The line exists only to satisfy the wrapper-seam pattern; every behavior above it is fully covered through the mock. |

**Post-guard, entrypoint body → candidate `guarded-entrypoint` (8 lines):** 281, 288, 289, 290, 295,
304, 308, 309. Lines 288–290 are the staged-paths block for a `git commit` payload, and 295 is the push
resolver call. Per [P2-T2] a push-shaped payload is deliberately not driven through the entrypoint
in-process, because the entrypoint reads the mutable repository checkpoint
`artifacts/orchestration/orchestrator-state.json` and the assertion would be nondeterministic; the push
mapping is locked at the decision layer instead. The in-process entrypoint case that does exist
([P2-T2](e)) covers the benign path.

**Arithmetic:** covering all 9 exercisable pre-guard lines yields 126 / 135 = **93.33%** raw.

### Cycle-1 measured `.codex/hooks` files — no regression versus [P0-T6]

| Sourcefile | [P0-T6] | [P4-T2] | Regression? |
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

Cycle-1 changed-file band held at **96.55% – 100.00%**; every value is byte-identical to baseline. No
per-file regression.

## Phase 5 Work Definition

1. `enforce-epic-child-worktree-binding.ps1` — **83.75% raw, gate FAILED.** Add dot-sourced unit cases
   for all 19 exercisable pre-guard missed lines listed above.
2. `enforce-epic-planning-only.ps1` — **86.67% raw, gate passed.** Add cases for the 9 exercisable
   pre-guard missed lines to build margin.
3. Neither hook's raw gate may be met by shrinking a denominator, removing a file from
   `CodeCoverage.Path`, or weakening an assertion.

Because one hook is below 85%, the `NO-GAP` branch of [P5-T1] is **not** available; gap-closure tests are
required.

EXIT_CODE: 0
