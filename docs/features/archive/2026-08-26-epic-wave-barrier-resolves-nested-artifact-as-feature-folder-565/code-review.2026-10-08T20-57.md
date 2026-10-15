# Code Review: Shared feature-folder resolver for the enforcement hooks (#565, bundles #568 and #696)

---

**Review Date:** 2026-10-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue #565 in the branch name.
**Base Branch:** `origin/epic/enforcement-hook-precision-integration` (merge-base `991aae0a`)
**Head Branch:** `bug/epic-wave-barrier-resolves-nested-artifact-as-feature-folder-exec-565` @ `fee3a782`
**Review Type:** Re-review after remediation cycle 1 (full branch; prior review `code-review.2026-10-08T19-24.md` at `2aa326cc`)

---

## Executive Summary

The branch replaces the length-sorted prompt scan in five resolvers with one pure resolver, `feature-folder-resolution.ps1`, that extracts the folder segment structurally (R1), maps candidates to checkpoint records through a union issue/folder index (R2), prunes cited dependencies in the epic gates (R3), and reports `Resolved`, `NoTarget`, or `Ambiguous` (R4-R6). It fixes integer `depends_on` edges in the epic wave barrier, makes the feature-folder-order gate work-mode and timestamp aware (#568), and adds direct coverage of `Get-PrdFeatureCheckpointFolder` (#696).

Remediation cycle 1 resolved the prior blocker CR-1. `Find-OrchestrationDelegationIssueNumber -KeyedOnly` now returns only the keyed `issue_num:` / `issue number:` form, and both gate main files pass that value as `-IssueNumber` (the only source of `-DeclaredIssueNumber`) and the existing keyed-or-hash value as the new `-FallbackIssueNumber`, which feeds only the `Find-OrchestrationModeRecord` lookup. A probe run by this review against both surfaces confirms the prior reproduction now denies with `target-ambiguous: target-a-with-a-much-longer-slug-301, b-302`, and a keyed `issue_num: 301` resolves the pair to the terminal target (`merge_status` deny). CR-4 (deny wording) is resolved. Evidence reviewed: full branch diff, regenerated PR context (head `fee3a782`), independent parse of `artifacts/pester/powershell-coverage.xml`, a re-run of 41 Pester suites (1386 pass, 0 fail), 11 SHA256 mirror pairs, and a behavioral probe on both surfaces.

**What changed (cumulative):**
New pure resolver (373 lines, two identical copies plus two mirrors); five resolvers converted to delegates; integer-edge fix in the wave barrier; readiness predicates in both `-modes.ps1` accept a candidate array, emit `target-ambiguous`, and take separate tie-break and fallback issue numbers; both gate main files call `Find-OrchestrationDelegationIssueNumber` twice (keyed-only and default); `enforce-feature-folder-order.ps1` gains a plan-leaf pattern, `Get-FeatureFolderIssueContent`, and a mode-specific prerequisite set; `Resolve-PrdFeatureWorkMode` delegates; both core pack manifests register the resolver; barrier import-failure reasons name "the dependency".

**Top 3 risks:**
1. A single cited folder that is not in the checkpoint still falls through to the issue-number lookup in `Find-OrchestrationModeRecord`, so a bare `#<n>` or keyed number naming another record selects that record (CR-8). Behavior is unchanged from the base branch and is pinned by an existing renamed-folder test; spec R4 describes the fallback as zero-candidate only.
2. Line headroom in the `-modes.ps1` files is now 4 (Claude, 496) and 7 (Codex, 493) lines, and the Codex gate main is at 489, which constrains C1b (#732) (CR-5).
3. Spec line 76 still lists both gate main files as excluded systems although the branch now edits them (CR-9).

**PR readiness recommendation:** **Ready with non-blocking follow-ups** - no Blocker or Major finding remains; record CR-9 (and optionally CR-8) in the spec or evidence before the PR is opened, and confirm AC item 30 in PR CI.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (was Major, blocking) | Both `-modes.ps1`, both `enforce-orchestration-preimplementation-gate.ps1` main files, mirrors | `Find-OrchestrationDelegationIssueNumber -KeyedOnly`; `Get-EpicOrchestrationReadinessFailure` / `Get-ParallelOrchestrationReadinessFailure` `-FallbackIssueNumber`; gate main lines 386-393 (Claude) and 427-434 (Codex) | CR-1: the tie-break now consumes only the keyed issue number; a bare `#<n>` no longer selects among cited candidates. | None. | Matches spec R4/R6 for the tie-break. | Probe `probe565r.ps1` (this review), both surfaces: `CR1-repro ... failure=[target-ambiguous: target-a-with-a-much-longer-slug-301, b-302]`; `keyed-301 ... failure=[merge_status]`. Tests M10p, M10e, M11p, M11e, M12a-c, M8h, M8m pass on both surfaces; fail-before evidence `evidence/regression-testing/fail-before-cr1-claude.2026-10-08T20-23.md` and `-codex`. |
| Resolved (was Nit) | `enforce-epic-wave-barrier.ps1`, `enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-drift-gate.ps1` | import-failure deny reason | CR-4: reason now reads "the dependency '<name>' failed to import". | None. | Accurate for both guarded imports sharing one flag. | W9, C7, D7 assert the new text; `evidence/regression-testing/pass-after-cr4.2026-10-08T20-33.md`. |
| Minor | Both `-modes.ps1` | `Find-OrchestrationModeRecord` called with `-TargetFolder $selection.Basename -IssueNumber $(if ($IssueNumber) {...} else { $FallbackIssueNumber })` | CR-8: when exactly one folder is cited and it matches no record, `Select-FeatureFolderTarget` returns `Resolved` with `Record = $null`, and `Find-OrchestrationModeRecord` then matches by issue number, which may be a bare `#<n>` or keyed number naming a different record. The gate evaluates that record and can allow. Spec R4 states the fallback applies to zero candidates and that a declared number "cannot select a record outside the cited set". | Clarify the spec: either document the renamed-folder fallback (cited folder absent, issue number present) as intended, or restrict it to the keyed form. Take this with the CR-3 delegation in C1b (#732). | Not a regression: the base branch passes the same keyed-or-hash value to the same lookup, and the existing test "resolves the target by issue_num when no feature-folder basename matches" pins the renamed-folder case, which AC item 19 forbids changing. | Probe (this review), both surfaces: `unrecorded-plus-hash302 folders=unrecorded-999 ... fallback=[302] failure=[]`; `keyed-outside-cited ... failure=[]`; `unrecorded-only ... failure=[target-record]`. Base code `991aae0a:.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` lines 272-273 and 458. |
| Minor | Both `enforce-orchestration-preimplementation-gate.ps1` main files | lines 386-393 (Claude), 427-434 (Codex) | CR-9: spec line 76 lists both gate main files under "Explicitly excluded systems". Remediation cycle 1 edits both (+5/-3 each). The remediation plan's write-set note justifies the edit against spec line 173 only and does not address line 76. | Record the deviation: amend the spec Scope line, or add an evidence record in the style of `evidence/other/cr3-mode-record-deviation.2026-10-08T20-35.md`. | The edit is the minimal way to separate the keyed and fallback values (the gate main is the only caller holding the prompt); the scope document should match the delivered change set. | `git diff 2aa326cc..HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1`; spec line 76; `remediation-plan.2026-10-08T19-24.md` line 77. |
| Minor | `.claude/hooks/feature-folder-resolution.ps1` (all copies) | `Find-FeatureFolderCandidate`, `TrimEnd('.', ',', ';', ':')` | CR-2 (open, carried): closing brackets and Markdown emphasis are not trimmed, so `(docs/features/active/x-301)` yields a second candidate `x-301)` and a false `Ambiguous`. The implementation follows spec R1 as written. | Amend spec R1 and the trim set; recorded as a follow-up. | Fail-closed false deny; not a safety regression. | Prior probe `probe565c.ps1`; `evidence/other/follow-ups-remediation-1.2026-10-08T20-35.md` item 1. |
| Info | Both `-modes.ps1` | `Find-OrchestrationModeRecord` | CR-3 (recorded deviation): not converted to a delegate as spec "Callers" states; it compares case-insensitively while `Find-FeatureFolderRecord` compares ordinally. | Convert in C1b (#732). | Deviation is now recorded with its rationale (existing pinned semantics). | `evidence/other/cr3-mode-record-deviation.2026-10-08T20-35.md`. |
| Info | Both `-modes.ps1`, Codex gate main | whole file | CR-5: line counts 496 (Claude `-modes.ps1`), 493 (Codex `-modes.ps1`), 467 (Claude gate main), 489 (Codex gate main); headroom 4, 7, 33, and 11 lines. | Plan C1b (#732) edits to these files with the 500-line cap in view. | Downstream merge planning. | `wc -l` (this review); `evidence/qa-gates/line-counts.rem1-1.2026-10-08T20-48.md`. |
| Info | Codex `-modes.ps1` | keyed regex `issue[_-]?num(?:ber)?\s*[:=]` | CR-10: the Codex keyed form does not accept `issue number:` (Claude does). With the CR-1 fix, a Codex prompt using `issue number: 301` with two cited folders now denies as `target-ambiguous` where Claude resolves. | None for this PR; the asymmetry is pre-existing and the remediation plan intentionally left it unchanged. | Fail-closed on Codex; not widened by the fix. | Probe (this review): `.codex issue-number-space-301 ... keyed=[] ... failure=[target-ambiguous: ...]`. |
| Info | 7 hooks modified in pass 1 | dot-source guard catch bodies | CR-6: 9 changed lines are uncovered; each is a catch body of the resolver dot-source guard. | None required. | Executing them in-process requires removing the sibling file at load time (a temporary-file pattern); the flags are driven directly and AST-checked. | This review's parse: uncovered changed lines wave 62-63, cohort 82-83, drift 93, Claude modes 41, Codex modes 41, feature-folder-order 50, prd helpers 39. |
| Info | `.claude/hooks/enforce-feature-folder-order.ps1` | `Test-IsFeaturePlanPath` | CR-7: the gate now covers timestamped plan writes and edits; an unmarked folder requires `user-story.md`. | None for this PR; documented in spec Risks. | Executors editing plan checkboxes in an unmarked full-bug folder would be denied. | `evidence/other/activation-probe.2026-10-08T19-09.md` (52 allow, 0 deny). |

No Blocker or Major findings remain. Blocking findings in this artifact: 0.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The resolver is pure (no `Import-Module`, filesystem cmdlet, process, web, or `$env:` use) and declares functions only, so dot-sourcing it is side-effect free; both copies and both mirrors hash to `2fe999cd...`.
- Selection is independent of candidate length and order (O01); dependency pruning keeps both members of a cycle and fails closed to `Ambiguous`.
- The CR-1 fix is minimal: `-KeyedOnly` returns before the hash-form match, the default return of `Find-OrchestrationDelegationIssueNumber` is unchanged (M12c and the pinned Codex bare-hash case still pass), and the record lookup receives exactly the value it received before the fix (`$IssueNumber` when keyed, otherwise `$FallbackIssueNumber`), so the D3 and renamed-folder fallbacks behave as before (M6a, M8, M8h, existing suites).
- Edits are symmetric across surfaces; the Claude/Codex diffs differ only in the pre-existing keyed regex and line offsets.

#### API and safety notes

- `-FallbackIssueNumber` is optional on both predicates; `Test-EpicOrchestrationReady` and `Test-ParallelOrchestrationReady` still pass only `-IssueNumber`, which now acts as both tie-break and lookup value. Production callers of the predicates are only the two gate main files (search of `.claude`, `.codex`, `tests`), so the wrappers are test-only consumers.
- All edited functions keep `[CmdletBinding()]`, `[OutputType()]`, and the explicit `AllowNull`/`AllowEmptyString` attributes; analyzer Findings=0.
- No state-changing actions; ShouldProcess not applicable.

#### Error handling and logging

- Ambiguity deny reasons keep each gate's leading token and list the remaining candidates (W5, C5, D5, M5, M10p/M10e).
- Import-failure deny reasons now describe the failed file as a dependency (W9, C7, D7).
- `Get-FeatureFolderIssueContent` returns `$null` on absence or read error, which resolves to the full-feature prerequisite set (fail closed).

---

## Test Quality Audit

The new suites cover every item of the spec Test Strategy matrix per resolver, the #621/#508 regression fixture on three gates, the #568 mode table and near-miss paths, and the #696 read/parse/extract body. Remediation added nine cases per surface: M10p/M10e (bare sibling hash with two cited folders denies as ambiguous, both legs), M11p/M11e (keyed number resolves the pair), M12a-c (unit cases for `-KeyedOnly` and the unchanged default), and M8h/M8m (zero-candidate D3 fallback allow and no-number deny). Fail-before evidence exists for the CR-1 and CR-4 cases. This review re-ran 41 suites (the 12 targeted suites, 18 existing preimplementation-gate suites, 8 existing barrier suites, the prd suites, and both contract suites) with 1386 passing cases and 0 failures.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1` and the Codex twin - CR-1 contexts use the decision-level helper with the surface's native envelope (nested on Claude, flat on Codex), so the gate main edit is exercised end to end.
- `tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1`, `enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1`, `enforce-parallel-drift-gate.FolderResolution.Tests.ps1` - one added assertion each for the CR-4 wording; no assertion removed.
- `evidence/qa-gates/test-scope.rem1-1.2026-10-08T20-48.md` - 146 insertions, 0 deletions under `tests/` in cycle 1.
- `evidence/qa-gates/junit-failing-set.rem1-1.2026-10-08T20-47.md` - failing set identical to baseline; confirmed by this review from `artifacts/pester/pester-junit.xml`.
- Gap (non-blocking, CR-8): no new case asserts the single-unrecorded-folder plus foreign issue number path; the existing renamed-folder case pins the allow outcome for a matching issue number.

### Quality assessment prompts

- **Determinism:** literal JSON fixtures, mocked worktree-resolution seam, synthetic absolute paths.
- **Isolation:** one prompt form per `It`; import-failure flags restored in `finally`.
- **Speed:** the 41-suite run completes in a single invocation.
- **Diagnostics:** assertions match leading tokens, predicate names, and candidate names; `Should -Not -Match 'target-ambiguous'` guards M11.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | PASS | No process launch added; resolver purity search clean. |
| Input validation at boundaries | PASS | Tie-break restricted to the keyed form (CR-1 resolved). Open non-blocking items: CR-2 trim set (fail-closed) and CR-8 pre-existing unrecorded-folder fallback (unchanged from base). |
| Error handling remains explicit | PASS | Guarded dot-sources fail closed; read seam returns `$null` to the stricter set. |
| Configuration / path handling is safe | PASS | Plan-leaf regex anchored; nested `research/plan.md` and `plan.2026-08-23.md` rejected (F4-F6). |

---

## Research Log

No external research was required. Behavior claims for CR-1, CR-8, and CR-10 were verified by running the branch code on both surfaces with `probe565r.ps1` in the session scratchpad, invoked through `sh run565r.sh`. The base-branch behavior for CR-8 was confirmed by reading `991aae0a:.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (hash-form fallback at lines 272-273; record lookup with the same issue value at line 458).

---

## Verdict

The prior blocker is fixed with a small, symmetric change that is covered by new decision-level cases on both surfaces, mirrored byte-for-byte, and verified by an independent probe. The resolver remains pure, fully covered, and length- and order-independent; every changed production file is at or above 91.67% line coverage; the full suite's failing set equals the baseline. No Blocker or Major finding remains. Before the PR is opened, record the gate-main scope deviation (CR-9) and consider clarifying the spec's fallback wording for the pre-existing unrecorded-folder path (CR-8); CR-2 and CR-3 remain recorded follow-ups for C1b (#732).
