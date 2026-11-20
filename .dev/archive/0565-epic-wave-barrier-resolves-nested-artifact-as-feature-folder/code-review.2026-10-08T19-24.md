# Code Review: Shared feature-folder resolver for the enforcement hooks (#565, bundles #568 and #696)

---

**Review Date:** 2026-10-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue #565 in the branch name.
**Base Branch:** `origin/epic/enforcement-hook-precision-integration` (merge-base `991aae0a`)
**Head Branch:** `bug/epic-wave-barrier-resolves-nested-artifact-as-feature-folder-exec-565` @ `2aa326cc`
**Review Type:** Initial review

---

## Executive Summary

The branch replaces the length-sorted prompt scan in five resolvers with one pure resolver, `feature-folder-resolution.ps1`, that extracts the folder segment structurally (R1), maps candidates to checkpoint records through a union issue/folder index (R2), prunes cited dependencies in the epic gates (R3), and reports `Resolved`, `NoTarget`, or `Ambiguous` (R4-R6). It also fixes integer `depends_on` edges in the epic wave barrier, makes the feature-folder-order gate work-mode aware and timestamp aware (#568), and adds direct coverage of `Get-PrdFeatureCheckpointFolder` (#696). Evidence reviewed: the full branch diff, the regenerated PR context, the feature evidence tree, the coverage XML (parsed independently), a re-run of 12 targeted Pester suites (382 pass), and three behavioral probes run by this review.

The resolver is small, pure, fully covered, and byte-identical across surfaces and bundles. The barrier hooks are thin delegates with guarded dot-sources that fail closed. One defect was found in the preimplementation gate's `-modes.ps1` integration: the tie-break issue number is taken from `Find-OrchestrationDelegationIssueNumber`, which also returns the first bare `#<n>` anywhere in the prompt. The spec limits the tie-break to the canonical issue-number line (or the keyed `issue_num:` form in `-modes.ps1`) and states that prompt position takes no part in selection. A probe confirms the gate can allow a delegation by selecting a cited non-target item whose number appears first as `#<n>`, including a case where the baseline length rule would have denied.

**What changed:**
New pure resolver (373 lines, two identical copies plus two mirrors); five resolvers converted to delegates; `Test-EpicWaveBarrierDependenciesMerged` resolves edges through `Find-FeatureFolderRecord`; readiness predicates in both `-modes.ps1` files accept a candidate array and emit `target-ambiguous`; `enforce-feature-folder-order.ps1` gains a plan-leaf pattern, `Get-FeatureFolderIssueContent`, and a mode-specific prerequisite set; `Resolve-PrdFeatureWorkMode` delegates; both core pack manifests register the resolver.

**Top 3 risks:**
1. The `-modes.ps1` tie-break accepts a positional bare `#<n>` as the declared issue number, so a cited sibling can be selected and a delegation allowed for the wrong record (CR-1).
2. A folder token immediately followed by `)` or `]` (for example `(docs/features/active/x)`) yields a second, unmatched candidate `x)`, producing a false `Ambiguous` deny where the baseline resolved correctly (CR-2).
3. The feature-folder-order gate now fires on every timestamped plan write and edit; folders without a work-mode marker are held to the full-feature set (activation probe: 52 allow, 0 deny across current active folders, so present impact is nil).

**PR readiness recommendation:** **Needs Revision** - CR-1 is a fail-open path in an enforcement gate that contradicts the spec's R4/R6 contract; the fix is small and local to both `-modes.ps1` files.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (blocking) | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (and mirrors) | `Get-EpicOrchestrationReadinessFailure` and `Get-ParallelOrchestrationReadinessFailure` (`$IssueNumber` -> `-DeclaredIssueNumber`); source `Find-OrchestrationDelegationIssueNumber` lines 246-268 | CR-1: The tie-break number passed as `-DeclaredIssueNumber` comes from `Find-OrchestrationDelegationIssueNumber`, which falls back to the first bare `#<n>` anywhere in the prompt. Spec R4 limits the tie-break to the canonical issue-number line (Technical specifications: "otherwise the existing keyed `issue_num:` form in `-modes.ps1`"), and R6 states prompt position takes no part. The function's own header justifies the hash form only because it "widens the SEARCH only ... an unmatched number yields no record and denies"; used as a tie-break it now selects a record and can allow. | Pass only the keyed form (`issue_num:` / `issue number:`) as `-DeclaredIssueNumber` (for example a `-KeyedOnly` switch or a separate keyed finder), keep the hash form only for the zero-candidate D3 fallback, and add a case per surface: two cited non-dependency items, target `merged`, sibling `not_started`, prompt containing `#<sibling>` and no keyed line, expected `target-ambiguous`. | Fail-open in a preimplementation gate: the readiness predicates evaluate the sibling's `merge_status`, not the target's. Regression vs baseline when the target slug is the longer one. | Probe `probe565b.ps1` (this review): items `target-a-with-a-much-longer-slug-301` (`merged`) and `b-302` (`not_started`); without `#302` -> `target-ambiguous: ...`; with `Coordinate with #302.` -> `issue=302 failure=[]` (allow). Baseline length rule would select 301 and fail `merge_status`. Existing M4q passes `-IssueNumber '301'` directly and does not exercise the hash form. |
| Minor | `.claude/hooks/feature-folder-resolution.ps1` (all copies) | `Find-FeatureFolderCandidate`, `TrimEnd('.', ',', ';', ':')` | CR-2: Closing brackets and Markdown emphasis are not trimmed. `(docs/features/active/x-301) and docs/features/active/x-301/spec.md` yields candidates `x-301)` and `x-301` -> `Ambiguous`; `**docs/features/active/x-301**` yields `x-301**`, which matches no record. The baseline resolved both prompts to `x-301`. The implementation follows spec R1 as written. | Amend R1 (spec) and the resolver to also trim `)`, `]`, `>`, `*`, and `_` from the folder segment, with S06 rows for each. File as a follow-up if not taken in this PR. | False deny on a plausible prompt shape, the defect class this issue targets; fail-closed, so not a safety regression. | Probe `probe565c.ps1` (this review): `candidates=x-301)|x-301 status=Ambiguous` (twice), `candidates=x-301** status=Resolved` with no record. |
| Minor | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, Codex copy | `Find-OrchestrationModeRecord` lines 324-356 | CR-3: Spec ("Callers") states `Find-OrchestrationModeRecord` becomes a thin delegate to the shared resolver. It was left unchanged, so `-modes.ps1` keeps a second record lookup that compares case-insensitively (`-eq`) while `Find-FeatureFolderRecord` compares ordinally (`-ceq`). | Delegate to `Find-FeatureFolderRecord` (folder first, then issue number) or record the deviation in the spec. | Two lookup rules can disagree on case-variant folder names; C1b (#732) and C6 consume this API. | `git diff ... -- .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` shows no change to the function. |
| Nit | `.claude/hooks/enforce-epic-wave-barrier.ps1`, `enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-drift-gate.ps1` | import-failure deny reason (lines 271-273, 240-242, 322-324) | CR-4: A failed dot-source of the resolver denies with "the worktree-resolution module 'feature-folder-resolution.ps1'". The resolver is not a worktree-resolution module. | Change the wording to "the dependency '<name>'". | Accurate deny reasons shorten diagnosis. | W9/C7/D7 assert the file name only, so the wording change does not affect tests. |
| Info | Claude and Codex `-modes.ps1` | whole file | CR-5: Line counts grew 480 -> 489 (Claude) and 477 -> 486 (Codex); the spec expected the delegation to shrink both. Both remain under 500. | Note the reduced headroom (11 and 14 lines) for C1b (#732). | Downstream merge planning. | `wc -l` (this review); spec Constraints. |
| Info | 7 modified hooks | dot-source guard catch bodies | CR-6: 9 changed lines are uncovered; each is the catch body of the resolver dot-source guard. | None required. | Executing them in-process requires removing the sibling file at load time (a temporary-file pattern). The flags they set are driven directly and AST-checked. | `evidence/qa-gates/coverage-changed-lines.3.2026-10-08T19-13.md`. |
| Info | `.claude/hooks/enforce-feature-folder-order.ps1` | `Test-IsFeaturePlanPath` | CR-7: The gate now covers timestamped plan writes and edits in active and archive folders; an unmarked folder requires `user-story.md`. | None for this PR; the risk is documented in spec Risks. | Executors editing plan checkboxes in an unmarked full-bug folder would be denied. | `evidence/other/activation-probe.2026-10-08T19-09.md` (52 allow, 0 deny). |

One blocking finding (CR-1). No other Blocker or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The resolver is pure (no `Import-Module`, filesystem cmdlet, process, web, or `$env:` use; verified by search) and declares functions only, so dot-sourcing it is side-effect free.
- Selection is independent of candidate length and order; O01 proves this for both orders and either-longer slug.
- Dependency pruning computes transitive closures and keeps both members of a cycle, which fails closed to `Ambiguous`.
- The wave barrier's integer `depends_on` defect is fixed by routing each raw edge through the union index rather than stringifying it.
- Each consuming hook guards the dot-source and keeps the first recorded failure; `-modes.ps1` uses a modes-local flag so the target finder returns nothing and readiness reports `feature-folder-resolution-import`.
- `Resolve-PrdFeatureWorkMode` keeps its `$null` contract by passing `-UnresolvedMode ''`, so the planner gate's deny-on-unknown branch is unchanged.

#### API and safety notes

- All new functions use `[CmdletBinding()]`, `[OutputType()]`, and explicit `AllowNull`/`AllowEmptyString`/`AllowEmptyCollection` attributes; iteration 1 analyzer findings (PSUseOutputTypeCorrectly) were fixed with `[string[]]` returns.
- `Select-FeatureFolderTarget` returns a fixed-shape `pscustomobject` (`Status`, `Record`, `Basename`, `Remaining`, `Detail`), matching the spec contract consumed by C1b and C6.
- No state-changing actions; ShouldProcess not applicable.

#### Error handling and logging

- Ambiguity deny reasons keep each gate's leading token and list the remaining candidates (W5, C5, D5, M5).
- `Get-FeatureFolderIssueContent` returns `$null` on absence or read error, which resolves to the full-feature prerequisite set (fail closed), as the spec requires.

---

## Test Quality Audit

The new suites cover every item of the spec Test Strategy matrix per resolver, the #621/#508 regression fixture on three gates, the #568 mode table and near-miss paths, and the #696 read/parse/extract body with exact `-LiteralPath` assertions. This review re-ran 12 suites (8 new, 4 existing) with 382 passing cases and 0 failures. Fail-before evidence exists for every converted resolver under `evidence/regression-testing/`.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1` and the Codex twin - direct API coverage plus a hash-equality assertion; the two suites differ only in the surface label and target path.
- `tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1` - matrix 1-7, integer edges, guard AST check, lifecycle prefixes.
- `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1`, `enforce-parallel-drift-gate.FolderResolution.Tests.ps1` - matrix 1-6 including the canonical-line tie-break; D8 proves the probe uses the target folder.
- Claude and Codex `...-mode-resolution.TargetFolder.Tests.ps1` - matrix 1-7, D3 fallback; gap: no case exercises the bare `#<n>` source of the tie-break (CR-1).
- `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1` - F1-F19, E1-E3; issue-content seam mocked at Describe scope.
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1` - K1-K6 without mocking the function under test.
- `evidence/qa-gates/junit-failing-set.3.2026-10-08T19-13.md` - failing set identical to baseline.

### Quality assessment prompts

- **Determinism:** literal JSON fixtures, mocked read and resolution seams, synthetic absolute paths.
- **Isolation:** one prompt form or rule per `It`; import-failure flags restored in `finally`.
- **Speed:** the targeted run completes in a single short invocation.
- **Diagnostics:** deny-reason assertions match leading tokens and candidate names; `-Because` on structural assertions.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | PASS | No process launch added; resolver purity search clean. |
| Input validation at boundaries | PARTIAL | Tie-break input accepts a positional bare `#<n>` in `-modes.ps1` (CR-1); candidate trim set omits closing brackets (CR-2). |
| Error handling remains explicit | PASS | Guarded dot-sources fail closed; read seam returns `$null` to the stricter set. |
| Configuration / path handling is safe | PASS | Plan-leaf regex anchored; nested `research/plan.md` and `plan.2026-08-23.md` rejected (F4-F6). |

---

## Research Log

No external research was required. Behavior claims for CR-1 and CR-2 were verified by running the branch code with probe scripts in the session scratchpad (`probe565.ps1`, `probe565b.ps1`, `probe565c.ps1`), invoked through `sh run565.sh`.

---

## Verdict

The implementation is well structured, pure where the spec requires purity, fully mirrored, and covered at or above policy thresholds; the nested-artifact and upstream-dependency defects that motivated #565 are fixed in all five resolvers, and #568 and #696 are delivered. The branch is not ready for normal PR flow because of CR-1: in both `-modes.ps1` surfaces a bare `#<n>` anywhere in the prompt acts as the declared-target tie-break, contrary to spec R4/R6, and a probe shows the gate allowing a delegation by evaluating a cited sibling's record. Restricting the tie-break to the keyed form and adding one regression case per surface resolves the blocker. CR-2 and CR-3 are recommended in the same pass or as filed follow-ups.
