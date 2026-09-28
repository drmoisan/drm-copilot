# Remediation Inputs — issue #554

- Timestamp: 2026-08-27T22-47
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `f24bbc7f`
- Base: `origin/main` at `1e991b86`
- Source artifacts:
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/policy-audit.2026-08-27T22-47.md`
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/code-review.2026-08-27T22-47.md`
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/feature-audit.2026-08-27T22-47.md`

## Scope of Remediation

**Test-only.** No production `.ps1` logic change is required by any Blocking finding. R2 offers a
production-side alternative but the recommended option is also test-only.

All four Blocking findings resolve the single unchecked acceptance criterion:

> Line coverage across the PowerShell suite remains at or above 85%, and no changed line in either
> modified hook loses coverage.

The PowerShell change budget applies: `.claude/rules/powershell.md` caps a batch at 3 production and
3 test files. This remediation touches **2 test files and 0 production files**, so it fits in one
batch. The batch-budget counter at `.claude/state/powershell-batch-budget.*.json` may need resetting
before the batch, as it was at each batch boundary during execution.

## R1 — Cover the pure functions in the Codex modes sibling (Blocking, B1)

**File to edit:** `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`

**Current state:** `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` is a NEW
production file at **81.82%** line coverage (24 uncovered of 132), below the 85% uniform threshold in
`.claude/rules/quality-tiers.md`.

**Uncovered lines and what they are:**

| Lines | Function |
| --- | --- |
| 197 | `Get-OrchestrationDelegationCheckpointPath` — the unknown-mode `return ''` |
| 228, 230-232, 234-237, 242-244, 246, 248-250 | `Find-OrchestrationDelegationTargetFolder` (entire body) |
| 268, 270-274 | `Find-OrchestrationDelegationIssueNumber` (entire body) |
| 94, 95 | `Get-OrchestrationModeProperty` `Write-Debug` catch — accepted residual, do not chase |

**Why the recorded justification does not apply.** The executor attributes these to the decision-D5
transport gap. D5 prohibits *"fabricating an `Agent` envelope on the Codex side and asserting a
decision on it."* Every function above takes a `[string]` and returns a `[string]`. Calling one
constructs no envelope and claims no transport. The Codex suite already calls pure functions directly
in its `mode resolution parity`, `epic readiness predicate parity`, and `parallel readiness predicate
parity` contexts; these functions belong in exactly the same category.

**Action.** Add `It` blocks to the existing `Context 'mode resolution parity'`, mirroring the
Claude-side cases that already cover these functions:

- `Get-OrchestrationDelegationCheckpointPath -Mode 'invented-mode' | Should -Be ''`
  (Claude suite line 187).
- The four `Find-OrchestrationDelegationTargetFolder` cases at Claude suite lines 221-231: no token,
  a `.md` token resolving to its parent, a bare directory token, and (recommended addition) a token
  followed by sentence punctuation.
- The three `Find-OrchestrationDelegationIssueNumber` cases at Claude suite lines 233-242: no number,
  keyed form, bare-hash form.

Use literal string fixtures only. No new fixture factory is needed.

**Acceptance:** re-run the self-hosted coverage invocation and confirm
`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` reports **2 uncovered of 132
(98.48%)**, matching its Claude counterpart. Record the figure in a new
`evidence/qa-gates/coverage-delta.<timestamp>.md`.

## R2 — Close the ten-line regression from the orphaned `Test-PreparationModeDelegation` (Blocking, B2)

**Current state:** `Test-PreparationModeDelegation` in
`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (lines 153-186) has **no remaining
production call site**. Its only caller was the pre-change `Test-ImplementationDelegation`, which
this branch replaced. On the Claude surface it also has no test caller, so lines 170-185 — ten
measurable lines that were covered at the merge base — are now uncovered.

This is a genuine coverage regression on pre-existing lines, prohibited by
`.claude/rules/general-unit-test.md` ("Code changes or refactors must not reduce coverage for the
lines that were changed"), and it is not disclosed in `evidence/qa-gates/coverage-delta.2026-08-27T22-36.md`.
It is the population that artifact refers to as "up to 9 [unattributed] misses".

The Codex copy of the same function retains coverage only because
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` lines 249-250 call it directly.
That asymmetry confirms the diagnosis.

**Recommended action (test-only).** Add a `Context` to
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
calling `Test-PreparationModeDelegation` directly, mirroring the Codex legacy-contract cases and
covering all three conjuncts:

- `-ToolInput $null` returns false (the null-tolerance contract `spec.md` §D2 pins).
- A non-`orchestrator` `subagent_type` returns false.
- An `orchestrator` with only one preparation marker returns false.
- An `orchestrator` with both preparation markers returns true.

**Alternative (production-side, not recommended for this branch).** Remove the orphaned function and
`$script:PreparationModeMarkers` from all four hook copies. This is larger, touches a function
`spec.md` §"Files and functions impacted" lists under **Not modified**, and would break the passing
Codex legacy-contract test. If preferred, file it as a follow-up refactor rather than folding it into
this bug fix.

**Secondary concern to record either way.** Leaving the function in place means the preparation-marker
rule now has two independent implementations in the same file —
`$script:PreparationModeMarkers` and `$script:OrchestrationDelegationModeTable`'s preparation row —
with nothing enforcing that they stay in step. If R2 is resolved by the recommended test-only option,
add a one-line assertion that the two marker sets are equal, or record the duplication as a known
condition.

**Acceptance:** lines 170-185 of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
report as covered, and the file's line coverage rises from 80.67% toward 88%.

## R3 — Cover `Get-OrchestrationModeDenyReason` on the Codex surface (Blocking, B3)

**File to edit:** `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`

Lines 352-353 of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` are uncovered. The
function is a pure string builder with two mandatory string parameters; no envelope and no transport
are involved, so D5 does not apply.

This function is the implementation of acceptance criterion 3 ("A denied delegation's reason names
the checkpoint actually consulted and the failed predicate"). Its Codex copy is currently entirely
unverified.

**Action.** Add one `It` asserting that
`Get-OrchestrationModeDenyReason -Mode 'epic' -Failure 'target-record'` returns a string that begins
with `PREIMPLEMENTATION_GATE_BLOCKED:`, contains
`artifacts/orchestration/epic-orchestrator-state.json`, and contains `'target-record'`. Add a
companion case for `-Mode 'parallel'`.

**Acceptance:** lines 352-353 report as covered.

## R4 — Cover the classifier's non-orchestrator allow branch on the Claude surface (Blocking, B4)

**File to edit:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`

Line 210 of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`:

```powershell
    if ($subagentType -ne 'orchestrator') {
        return $false
    }
```

This is the one uncovered added line the executor's four-group characterization does not account for.
It is an **allow** branch — `$false` means "not an implementation delegation", so the gate permits the
operation — inside the newly written classifier, on the only surface where the `Agent` transport is
reachable. The equivalent branch is covered on the Codex copy (`task-researcher` ⇒ `$false`), so the
behaviour is verified on a byte-identical algorithm but not on the shipped, reachable path.

**Action.** Add an `It` passing a tool input whose `subagent_type` is a non-allow-listed,
non-orchestrator agent (for example `task-researcher`) with a prompt containing both legacy free-text
tokens, and assert `Test-ImplementationDelegation` returns `$false`. Including the legacy tokens in
the prompt also documents the Fault-1 fix in the widening direction.

Recommended companion (Non-blocking, closes finding N4's gap): add a decision-level case asserting
that the same payload receives an **allow** decision against an unready single-feature checkpoint, so
the spec-sanctioned permissive widening is asserted explicitly rather than left implicit.

**Acceptance:** line 210 reports as covered.

## Accepted Residuals — record, do not remediate

These must be **recorded as named exceptions** in the re-issued coverage-delta artifact rather than
left implicit in a table.

| Lines | Location | Reason accepted |
| --- | --- | --- |
| 16 | `Get-EpicCheckpointContent` / `Get-ParallelCheckpointContent` bodies, both surfaces | Real filesystem I/O. The injection seam exists so the decision logic is testable without touching the filesystem, as `.claude/rules/general-unit-test.md` requires. Covering these would require reading the live checkpoint, which would also make several allow assertions pass vacuously |
| 3 | The non-injected `else` arm, both surfaces | Same seam, same reason |
| 4 | `Get-OrchestrationModeProperty` `Write-Debug` catch, both surfaces | Fires only when `PSObject.Properties` itself throws; no JSON-derived object produces it |
| 15 | `.codex/…/gate.ps1` lines 426-443, the epic/parallel decision branch | **Genuinely D5-constrained.** Driving it requires constructing a delegation payload for the Codex decision function, which decision D5 prohibits. Record as an explicit exception tied to **issue #555** |

After R1-R4, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` will sit at
approximately **83.3%** (27 uncovered of 162) because of the 15-line D5 residual. That shortfall
against the 85% file-level threshold is the one coverage exception this feature should ship with, and
it should be stated in the artifact by name, with its line range, its reason, and its #555 linkage —
not absorbed into an aggregate.

## Projected Post-Remediation Coverage

| File | Now | Projected | Threshold |
| --- | --- | --- | --- |
| `.claude/…/gate.ps1` | 80.67% | ≈ 88.0% | PASS |
| `.claude/…/gate-modes.ps1` | 98.48% | 98.48% | PASS |
| `.codex/…/gate.ps1` | 82.10% | ≈ 83.3% | Named #555 exception |
| `.codex/…/gate-modes.ps1` | 81.82% | ≈ 98.48% | PASS |
| Repo-wide PowerShell | 94.22% | ≥ 94.22% | PASS |

## Acceptance Criterion to Re-evaluate

After R1-R4, re-evaluate `spec.md` acceptance criterion:

> Line coverage across the PowerShell suite remains at or above 85%, and no changed line in either
> modified hook loses coverage.

The criterion is checkable once the `.claude` modified hook carries no uncovered changed line outside
the accepted read-seam residual, and the `.codex` modified hook's remaining uncovered changed lines
are confined to the named #555 exception. If the reviewer judges the residuals acceptable at that
point, the criterion may be checked; otherwise it stays unchecked and the residual is escalated as a
shipping exception. **Do not amend the criterion text.**

## Non-Blocking Items — optional, no gate depends on them

| ID | Item | Suggested disposition |
| --- | --- | --- |
| N1 | Per-group uncovered-line counts in `coverage-delta.2026-08-27T22-36.md` are inaccurate (16/3/39/4, not 18/3/40/2; total 63 correct) | Correct in the re-issued artifact |
| N3 | `Find-OrchestrationDelegationIssueNumber` returns the **first** bare-hash match, so two hash numbers in one prompt make the resolved target order-dependent | Follow-up issue: prefer the keyed form only, or require a unique bare-hash match |
| N5 | Codex pack manifest omits `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (pre-existing at `origin/main`) | Separate follow-up issue |
| N6 | The known #510 failure did not reproduce in this worktree | Note in the evidence record so the annotation is not read as an unverified claim |
| N7 | `.codex/…/gate.ps1` is at 495 of 500 lines | Note for the next change to that file |
| — | Trailing-punctuation stripping in `Find-OrchestrationDelegationTargetFolder` is untested for `...` and `.md.` forms | Optional additional cases, folded into R1 if convenient |
