# S1 Sweep — Empty-Successful-Git-Output Defect Class (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P3-T2]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Finding:** S1 (Sweep)

Timestamp: 2026-07-26T15-17

## Defect Class Being Swept For

A site is a defect when **either** condition holds:

1. A `[string](<git invocation>)` result receives a **method call**, so an empty successful pipeline
   (`$null` after the cast) throws `You cannot call a method on a null-valued expression`; or
2. A guard keyed on `$LASTEXITCODE` **alone** precedes a method call, where empty successful output is
   possible.

Every verdict below was re-derived from current file content, not carried over from the plan's expected
list.

## Commands and Exit Codes

Command: `rg -n "\[string\]\((?:& git|Invoke-)" .codex`
EXIT_CODE: 0 — 4 hits.

Command: `rg -n "LASTEXITCODE" .codex`
EXIT_CODE: 0 — 7 hits.

Command (supplementary completeness check, so no git call site can escape the two mandated patterns):
`rg -n "& git" .codex`
EXIT_CODE: 0 — 8 hits. Every one is reconciled in the table below, confirming the mandated patterns left
no git invocation unadjudicated.

## Output Summary — Every Hit With a Verdict

### Pattern 1 hits — `rg -n "\[string\]\((?:& git|Invoke-)" .codex`

| # | File:line | Code | Verdict | Justification |
|---|---|---|---|---|
| 1 | `.codex/hooks/enforce-epic-planning-only.ps1:260` | `$currentBranch = [string](Invoke-EpicPlanningGit -GitArgs @('-C', $RepositoryRoot, 'branch', '--show-current'))` | **FIXED BY THIS PLAN** (A1) | The immediately following guard is `if ($LASTEXITCODE -ne 0) { throw }` then a separate `if ([string]::IsNullOrWhiteSpace($currentBranch)) { return '' }`, so `.Trim()` at line 266 is reached only for non-whitespace output. |
| 2 | `.codex/hooks/authorize-root-epic-invocation.ps1:213` | `$headSha = [string](& git -C $repositoryRoot rev-parse HEAD 2>$null)` | **SAFE** | The result feeds `-notmatch '^[0-9a-fA-F]{40,64}$'` at line 214 — a null-safe operator, not a method call. `$null` coerces to `''`, fails the hex pattern, and the existing `throw` fires. Independently, `rev-parse HEAD` cannot succeed with empty output in a repository that has a commit. `$headSha` is passed onward as a value, never method-called. |
| 3 | `.codex/hooks/record-subagent-routing-attestation.ps1:381` | `$headSha = [string](& git -C $repositoryRoot rev-parse HEAD 2>$null)` | **SAFE** | Identical construct and identical guard at line 382 (`-notmatch` on the same hex pattern). Same reasoning as #2. |
| 4 | `.codex/hooks/enforce-epic-child-worktree-binding.ps1:275` | `$liveBranch = [string](Invoke-CodexChildGuardGit -GitArgs @('-C', $RepositoryRoot, 'branch', '--show-current'))` | **FIXED BY THIS PLAN** (C1) | Line 276 now guards `$LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($liveBranch)` and returns `''`, so `.Trim()` at line 279 is unreachable for null/whitespace. This was the Blocking defect. |

### Pattern 2 hits — `rg -n "LASTEXITCODE" .codex`

| # | File:line | Guard | Verdict | Justification |
|---|---|---|---|---|
| 5 | `.codex/scripts/epic-child-launch-runtime.ps1:15` | `if ($LASTEXITCODE -ne 0) { throw }` inside `Invoke-CodexChildGit` | **SAFE** | The wrapper's output is `@(& git @GitArgs 2>&1)` — array-wrapped at line 14, so an empty pipeline yields `@()`, never `$null`. No method call follows. Every consumer either array-wraps the result or routes through `Get-CodexChildGitScalar`. |
| 6 | `.codex/scripts/epic-child-launch-runtime.ps1:26` | `return $LASTEXITCODE -eq 0` inside `Test-CodexChildGit` | **SAFE** | Output is discarded (`*> $null` at line 25). The function returns a boolean; there is no value to method-call. |
| 7 | `.codex/hooks/record-subagent-routing-attestation.ps1:382` | `if ($LASTEXITCODE -ne 0 -or $headSha -notmatch '...')` | **SAFE** | Not a `$LASTEXITCODE`-only guard: the `-or` arm independently rejects `$null`/`''`. Same site as #3. |
| 8 | `.codex/hooks/enforce-epic-planning-only.ps1:261` | `if ($LASTEXITCODE -ne 0) { throw }` inside `Get-EpicPlanningCurrentBranch` | **FIXED BY THIS PLAN** (A1) | Deliberately `$LASTEXITCODE`-only per RD-1a (genuine git failure must keep failing closed), and it is **not** ahead of an unguarded method call: the separate `IsNullOrWhiteSpace` check at line 264 returns `''` before `.Trim()` at line 266 can run. Same site as #1. |
| 9 | `.codex/hooks/enforce-epic-planning-only.ps1:289` | `if ($LASTEXITCODE -ne 0) { throw }` after the staged-paths call | **SAFE** | Line 288 is `$stagedPaths = @(& git ... diff --cached --name-only ...)` — array-wrapped, so empty successful output yields `@()`, not `$null`. No method call follows; `Test-EpicPlanningBashAllowed` already denies an empty staged set (line 140: `$null -eq $StagedPaths -or $StagedPaths.Count -eq 0` → `$false`). Unmodified by this plan, as [P2-T1] requires. |
| 10 | `.codex/hooks/enforce-epic-child-worktree-binding.ps1:276` | `if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($liveBranch))` | **FIXED BY THIS PLAN** (C1) | Same site as #4. |
| 11 | `.codex/hooks/authorize-root-epic-invocation.ps1:214` | `if ($LASTEXITCODE -ne 0 -or $headSha -notmatch '...')` | **SAFE** | Same site as #2; the `-or` arm rejects `$null`/`''` independently. |

### Plan-directed additional verification (sites the two patterns do not match)

The plan names two further sites to verify. Neither matched either grep pattern — they use `& git`
without a `[string](...)` cast and without a `$LASTEXITCODE` guard — so they are adjudicated here
explicitly rather than by pattern.

| # | File:line | Code | Verdict | Justification |
|---|---|---|---|---|
| 12 | `.codex/hooks/enforce-epic-wave-barrier.ps1:244-249` | `$output = & git -C $RepositoryRoot worktree list --porcelain 2>$null` then `$first = @($output \| Where-Object {...} \| Select-Object -First 1)` | **SAFE** | The pipeline is filtered into an array with an explicit `if ($first.Count -eq 0) { return $RepositoryRoot }` fallback at line 246. `.Substring(...)` at line 249 executes only when `$first.Count -ge 1`, so no method call lands on a possibly-null scalar. |
| 13 | `.codex/scripts/resume-epic-child.ps1:88-91` | `$surfaceStatus = @(Invoke-CodexChildGit -GitArgs @(...))` | **SAFE** | Array-wrapped `@(...)`, so an empty successful `git status --porcelain` yields `@()`. It is consumed by `Test-CodexChildCustomizationClean -StatusLines $surfaceStatus`, which takes a collection; no scalar method call occurs. |

### Advisory (out of scope, recorded for completeness, not a defect of the swept class)

`.codex/scripts/epic-child-launch-runtime.ps1` calls
`Get-CodexChildGitScalar -GitArgs @('-C', $x, 'branch', '--show-current')` at lines 161 and 209. On a
detached HEAD that call throws `EPIC_CHILD_LAUNCH_BLOCKED: git ... did not return one value.` — an
**explicit, deliberate, fail-closed** message produced by the function's own
`$output.Count -ne 1 -or [string]::IsNullOrWhiteSpace([string]$output[0])` check at line 33, evaluated
**before** `.Trim()` at line 35. This is therefore not the swept defect class: there is no null-method
exception and the guard is not `$LASTEXITCODE`-only. It is also not the failing CI scenario — these are
launch/resume scripts for epic-child worktrees, which bind to a named branch by design, not PreToolUse
hooks invoked on a CI detached merge ref. No change is made and no scope expansion is proposed.

## Verdict

| Metric | Value |
|---|---|
| Total sites adjudicated | 13 (11 pattern hits, deduplicating to 8 distinct code sites, plus 2 plan-directed sites and 1 advisory) |
| Distinct `& git` call sites in `.codex` | 8 — all reconciled, zero unadjudicated |
| Sites fixed by this plan | 2 (`enforce-epic-child-worktree-binding.ps1`, `enforce-epic-planning-only.ps1` branch resolver) |
| Sites verdicted SAFE | 6 distinct code sites |
| **NEW defects found** | **0** |

Zero unadjudicated hits. No hit fails the defect-class test, so the FAILED branch of this task
(stop, record, return to preflight for a scope decision) is **not** taken and no scope expansion occurs.
The defect class is confined to the two hooks this plan fixes.

EXIT_CODE: 0
