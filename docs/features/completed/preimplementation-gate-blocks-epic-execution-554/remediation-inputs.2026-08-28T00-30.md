# Remediation Inputs — issue #554, cycle 2

- Timestamp: 2026-08-28T00-30
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `3140652d`
- Base: merge base `1e991b86`
- Source artifacts:
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/policy-audit.2026-08-28T00-30.md`
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/code-review.2026-08-28T00-30.md`
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/feature-audit.2026-08-28T00-30.md`

## Scope of Remediation

**Test-only and documentation-only.** No production `.ps1` change is required. One blocking finding,
**B5**, with two components: a two-line coverage gap and three incorrect statements of fact.

Cycle-1 findings **B1, B2, B3, and B4 are all closed** and require no further work. The four
acceptance-criteria and scope constraints all hold. **No acceptance criterion is unchecked**, and
none should be changed by this remediation.

Change budget: `.claude/rules/powershell.md` caps a batch at 3 production and 3 test files. This
remediation touches **1 test file and 0 production files**, so it fits in one batch. The batch-budget
counter at `.claude/state/powershell-batch-budget.*.json` may need resetting first, as it did at each
batch boundary during prior cycles.

## B5 — the Codex twin of B2 is open, and three artifacts state a false fact about it (Blocking)

### The gap

Two lines of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` are uncovered and belong
to no named exception:

| Line | Text | Role in `Test-PreparationModeDelegation` |
| --- | --- | --- |
| 197 | `return $false` | the non-`orchestrator` subagent-type branch |
| 206 | `return $true` | the all-conjuncts-hold return |

Both were **covered at the merge base** and lost coverage as a direct consequence of this change,
which orphaned `Test-PreparationModeDelegation`. The merge-base call chain, verified from
`git show 1e991b86:…`:

- Merge-base `Test-ImplementationDelegation` line 213 called `Test-PreparationModeDelegation`; that
  call site no longer exists on either surface.
- Merge-base `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 367
  (`subagent_type = 'atomic-executor'`) and line 373 (`'task-researcher'`) reached the
  non-`orchestrator` return through it.
- The same file's line 242 passed `subagent_type = 'orchestrator'` with a prompt carrying both
  members of `$script:PreparationModeMarkers` through the decision function, reaching the
  all-conjuncts return.

The two surviving direct callers at current lines 249-250 supply `$null` and an `orchestrator`
payload with one marker, reaching only the null branch and the marker-loop `return $false`.

This is the same defect class as cycle-1 finding B2, on the other surface, at 2 lines instead of 10.
Decision D5 does not shield it: the function takes a `[pscustomobject]` and returns a `[bool]`,
constructs no `Agent` envelope, claims no transport, and is already called directly by the Codex
legacy-contract suite.

### R5 — cover Codex lines 197 and 206 (test-only)

**File to edit:** `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
(currently 302 of 500 lines; ample headroom, no new file needed).

**Action.** Add a `Context` calling `Test-PreparationModeDelegation` directly, mirroring the four
cases the Claude classifier suite already carries at
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`
lines 87-108. Two cases are strictly required — the other two are already covered on this surface by
the legacy-contract suite, but including all four keeps the two surfaces symmetrical and is
recommended:

- **Required.** A non-`orchestrator` `subagent_type` carrying *both* preparation markers returns
  `$false`, so that only the subagent-type check can produce the result. Closes line 197.
- **Required.** An `orchestrator` carrying both preparation markers returns `$true`. Closes line 206.
- Recommended for symmetry: `-ToolInput $null` returns `$false`.
- Recommended for symmetry: an `orchestrator` with only one marker returns `$false`.

Use literal string fixtures only, consistent with the rest of the suite. The marker set is
`@('Preparation mode: true.', 'route_id: preparation.')`; both markers include their trailing period.

Consider also mirroring the marker-parity assertion the Claude classifier suite carries at its
lines 111-124 (`Compare-Object $script:PreparationModeMarkers $preparationRow.Markers`), so the
duplicated preparation-marker rule is pinned on both surfaces rather than one.

**Acceptance:** `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` reports lines 197 and
206 as covered, and its measured missed set becomes exactly the 25 lines already attributed to named
exceptions: `292, 293, 294, 296, 304, 305, 306, 308, 421, 422, 426, 427, 428, 429, 430, 432, 433,
434, 435, 436, 437, 439, 441, 442, 443`. File line coverage rises from **83.33% (135/162)** to
**84.57% (137/162)**.

Note that 84.57% is still below the 85% uniform threshold. That is expected and is not a reason to
widen the work: the shortfall is wholly owned by the 15-line issue #555 exception at lines 426-443,
which remains accepted. **Do not attempt to cover 426-443**; doing so requires fabricating an `Agent`
envelope for the Codex decision function, which decision D5 prohibits.

### R6 — correct three false statements (documentation-only)

All three assert that Codex lines 197 and 206 were uncovered at the merge base. All three are wrong.

1. **`evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md`, lines 100-102.**
   Correct the sentences "its two uncovered pre-existing lines, 197 and 206, were uncovered at the
   merge base as well" and "On that basis no line that was covered at the merge base is uncovered
   now." Record instead that both lines were covered at the merge base through the production call
   chain, that the loss is finding B5, and that it is closed by R5. **Do not weaken the artifact's
   verdict on the acceptance criterion**: the criterion's check-off is upheld by
   `feature-audit.2026-08-28T00-30.md` on the criterion's literal text (neither line is a *changed*
   line) plus the artifact's arguments 1 and 2, both of which are accepted. Only the third argument's
   second half is withdrawn.

2. **`evidence/qa-gates/coverage-delta.2026-08-27T22-47.md`.** Its statement that "zero uncovered
   added lines are unattributed" is true as worded and should stand. Add a short subsection disclosing
   the two uncovered **pre-existing** lines, their merge-base coverage, the orphaning that caused the
   loss, and their closure by R5, so the file's full missed set of 27 is reconciled rather than only
   its 25 changed lines. Re-issue with the post-R5 figures.

3. **`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`,
   comment at line 82.** It states the Codex copy "kept coverage from
   `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`". It kept only partial coverage.
   Correct the comment. This is a comment-only edit inside a file this remediation is not otherwise
   editing; if the batch budget makes a second test-file edit inconvenient, fold it into the same
   batch as R5 rather than deferring it.

**Origin of the error, recorded for the audit trail.** The executor did not invent this claim. It
faithfully reproduced `policy-audit.2026-08-27T22-47.md` line 173 and that document's derived Codex
baseline at line 181 (`≈ 98.3% (118/120)`), which assumed the two lines uncovered at base without
verifying it. That cycle-1 statement is corrected in `policy-audit.2026-08-28T00-30.md`; the corrected
derived Codex baseline is 120 of 120 pre-existing measurable lines covered. No remediation action is
required against the cycle-1 artifact itself, which is retained as-superseded.

**Acceptance:** none of the three locations asserts that Codex 197 and 206 were uncovered at the merge
base; each records the correction and the closure.

## Do Not Change

Recorded explicitly, because each was verified to hold and a well-meant edit would break it.

| Item | Reason |
| --- | --- |
| Any production `.ps1` file, self-hosted or mirrored | All eight hash-compare `UNCHANGED` since `f24bbc7f`; the four pairs are byte-identical per surface. B5 is test-only |
| The four `-helpers.ps1` copies | Byte-untouched since the merge base; acceptance criterion 23 depends on it |
| The six pre-existing suites | Their absence from the branch diff is what acceptance criteria 21 and 22 assert |
| Any acceptance-criterion text or checkbox in `spec.md` | All 35 are checked and all 35 evaluate PASS. B5 unseats none of them |
| The `## DECLARED BLAST RADIUS` section | Complete: all 99 branch files resolve to a declared entry. Statement `(e)` already forward-declares later cycles' root-level artifacts, so cycle-2 artifacts need no further amendment |
| `[P6-T6]` in `plan.2026-08-26T08-40.md` | Leaving it unchecked is the correct disposition; its acceptance clause admits no exceptions and is measurably false. Do not check it, reword it, or delete it |
| Codex `.ps1` lines 426-443 | The accepted issue #555 shipping exception. Covering it requires the D5-prohibited fabricated envelope |

## Accepted Residuals — record, do not remediate

Unchanged from cycle 1 and re-verified by measurement.

| Lines | Location | Reason accepted |
| --- | --- | --- |
| 16 | `Get-EpicCheckpointContent` / `Get-ParallelCheckpointContent` bodies, both surfaces (Claude 266-282, Codex 292-308) | Real filesystem I/O. The injection seam exists so decision logic is testable without touching the filesystem. Covering these would also make several allow assertions pass vacuously against the live, genuinely-ready checkpoint |
| 3 | Claude 408, the non-injected `else` arm; Codex 421-422, the `declared-checkpoint-path` deny return | Same seam and same reason for the Claude line; D5 transport reason for the Codex pair |
| 4 | `Get-OrchestrationModeProperty` `Write-Debug` catch, lines 94-95 of both `-modes.ps1` copies | Fires only when `PSObject.Properties` itself throws; no JSON-derived object produces it |
| 15 | Codex `gate.ps1` 426-443, the epic/parallel decision branch | Genuinely D5-constrained. The named **issue #555** shipping exception |

## Projected Post-Remediation Coverage

| File | Now | Projected | Threshold |
| --- | --- | --- | --- |
| `.claude/…/gate.ps1` | 88.00% | 88.00% | PASS |
| `.claude/…/gate-modes.ps1` | 98.48% | 98.48% | PASS |
| `.codex/…/gate.ps1` | 83.33% | **84.57%** | Named #555 exception |
| `.codex/…/gate-modes.ps1` | 98.48% | 98.48% | PASS |
| Repo-wide PowerShell | 94.6809% | ≥ 94.6809% | PASS |

## Non-Blocking Items — optional, no gate depends on them

| ID | Item | Suggested disposition |
| --- | --- | --- |
| N3 | `Find-OrchestrationDelegationIssueNumber` returns the *first* bare-hash match, so two hash numbers in one prompt make the resolved target order-dependent | Follow-up issue: prefer the keyed form, or require a unique bare-hash match |
| N5 | Codex pack manifest omits `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`; verified pre-existing at the merge base | Separate follow-up issue |
| N7 | `.codex/…/gate.ps1` at 495/500 and `codex-hooks/legacy-codex-hook-contracts.Tests.ps1` at 494/500 | Note for the next change to either file; a sibling will be required |
| N9 | `Test-PreparationModeDelegation` is now dead code on both surfaces, with its coverage maintained by tests alone, and the preparation-marker rule has two independent implementations in one file | Follow-up refactor: remove the function and `$script:PreparationModeMarkers` from all four copies, updating the Codex legacy-contract test. Out of scope for this bug fix; `spec.md` lists the function under "Not modified" |
