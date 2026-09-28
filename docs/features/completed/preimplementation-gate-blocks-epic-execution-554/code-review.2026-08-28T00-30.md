# Code Review — issue #554, remediation cycle 1 exit re-audit

- Timestamp: 2026-08-28T00-30
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `3140652d`
- Base: merge base `1e991b86`
- Supersedes: `code-review.2026-08-27T22-47.md` (retained)

## Scope of This Review

The production surface is **unchanged** since the cycle-1 review: all eight production `.ps1` files
(four self-hosted, four mirrors) hash-compare `UNCHANGED` between `f24bbc7f` and `HEAD`. The cycle-1
code review of the production change therefore stands and is not restated. This review covers the
remediation delta — two test files and the `spec.md` blast-radius amendment — and re-examines the
production design only where a finding requires it.

## Remediation Delta

| File | Change | Lines |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` | added | 154 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | modified, additive | 302 |
| `docs/features/active/…/spec.md` | modified, additive | — |

## Scope Decision 1 — new sibling suite rather than growing the named target

**Verdict: ACCEPTED.**

The remediation directive named
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
as the edit target. That file stands at **494 of 500 lines**, against the hard cap in
`.claude/rules/general-code-change.md` ("No production code, test code, or reusable script file may
exceed 500 lines"), whose exception list — throwaway scripts, raw text fixtures, Markdown — does not
cover a Pester suite. Six lines of headroom cannot absorb the four preparation-predicate cases, the
marker-parity case, and the two classifier cases that findings R2, R4, and the R2 secondary concern
require; the delivered suite is 154 lines including its documentation block.

The alternative — trimming 494 lines of passing, pre-existing assertions to make room — would have
modified a suite the acceptance criteria require to remain intact, and would have been a worse
outcome than a sibling file.

The precedent is real and was checked, not taken on assertion: `spec.md` lines 648-649 record that
this suite's own cases were placed outside `enforce-orchestration-preimplementation-gate.Tests.ps1`
for the same reason when that file stood at 461 of 500. The new file follows the established pattern.

Placement is correct under `.claude/rules/general-unit-test.md`: it lives in the `tests/` tree
mirroring the production path (`.claude/hooks/…` → `tests/scripts/claude-hooks/…`), not colocated
with production source. The name is descriptive of its subject rather than of its origin.

## Scope Decision 2 — additive amendment of the declared blast radius

**Verdict: ACCEPTED. This is not an illegitimate amendment.**

The concern worth taking seriously is that amending a declared radius can be a way to make a
conformance check pass by moving the target. That is not what happened here, and the distinction is
drawn explicitly in `.claude/rules/parallel-orchestration.md`: what that rule prohibits is
**narrowing** a radius to suppress a conflict edge. It simultaneously **obliges** the planner to
enumerate a genuine write explicitly — "When an item's plan will actually write an excluded path, the
planner appends that exact path to the declared radius after normalization." Widening to declare six
genuine writes discharges that obligation; it does not evade anything. Widening also cannot suppress
a conflict edge, only create one, so the amendment moves in the conservative direction.

Verified against `git diff f24bbc7f..HEAD -- spec.md`:

- **Nothing removed, narrowed, or reworded.** Every changed line is an addition except two, each of
  which changes a single word: `five` → `six` (the count of `evidence/` directory prefixes) and
  `Four` → `Five` (the count of lettered statements). Both are consequences the additions forced.
- **Six genuine writes added:** the new classifier suite, and the five root-level cycle-1 review and
  remediation artifacts (`policy-audit`, `code-review`, `feature-audit`, `remediation-inputs`,
  `remediation-plan`).
- **One directory prefix added:** `evidence/remediation-baseline/`.
- **One lettered statement added,** `(e)`, which generalises the five concrete root-level artifacts to
  "any later cycle's set, which differs from the cycle-1 set only in its timestamp." This
  forward-declaration means the artifacts written by *this* re-audit are already covered.
- **No acceptance-criterion text changed.** The only text change inside the Acceptance Criteria
  section is one checkbox character, `- [ ]` → `- [x]`, on the coverage criterion. The criterion's
  prose is byte-identical.
- **No other checkbox changed** anywhere in the file.

**Completeness verified independently.** Resolving all 15 exact declared file entries plus the eight
root-level entries plus the seven directory prefixes against `git diff --name-only origin/main...HEAD`:
**99 changed files, 0 undeclared.**

The amendment is also self-documenting: an `**Amendment, 2026-08-27.**` note states what was added,
why, and that the change is additive. That is the right way to make this edit.

## Review of the New Claude Classifier Suite

**Quality: high.** It does more than the directive required, and the additions are the right ones.

Strengths:

- **All four conjuncts of `Test-PreparationModeDelegation` are covered** (null, non-`orchestrator`,
  single marker, both markers), closing R2 rather than merely raising the number.
- **The vacuity trap is closed explicitly.** The decision-level case at line 139 binds
  `-CheckpointRaw` to a literal unready checkpoint, and the comment states the reason: an unbound
  value falls through to the on-disk `orchestrator-state.json`, which is genuinely ready during an
  orchestrated run, so an `allow` assertion would pass whatever the classifier did. This is the single
  most important property of the suite and it is handled deliberately rather than by luck. The fixture
  factory `ConvertTo-ClassifierUnreadyCheckpointJson` carries the same warning at its definition.
- **The R2 secondary concern is addressed, not just noted.** The `Context` at line 111 asserts
  `$script:PreparationModeMarkers` equals the `preparation` row of
  `$script:OrchestrationDelegationModeTable` via `Compare-Object`. Retaining the orphaned function
  leaves the preparation-marker rule with two independent implementations in one file; this is the
  assertion that keeps them in step, and its comment states the security consequence of divergence.
- **Determinism is stated and holds.** Every fixture is a literal string or an in-body
  `[pscustomobject]`. No temporary file, no filesystem write, no wall-clock read, no network, no
  external process, no `Mock`. This satisfies `.claude/rules/general-unit-test.md`, including its
  absolute prohibition on temporary files in tests.
- **Arrange–Act–Assert structure** is clear, `It` names describe behaviour rather than mechanism, and
  every non-obvious case carries a comment explaining *why* the case exists and which finding it
  closes.
- The double dot-source at lines 34-42 is defended in a comment: the modes sibling is loaded
  explicitly as well as transitively, so a later change to the hook's dot-source line cannot silently
  leave the cases asserting against constants sourced from elsewhere. The file is pure, so redefining
  is idempotent. This is sound.

One defect:

- **N8.** The comment at line 82 states that the Codex copy "kept coverage from
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`". It kept only *partial* coverage;
  Codex lines 197 and 206 are uncovered. The comment reproduces this reviewer's own cycle-1 error. See
  B5 in the policy audit.

## Review of the Codex Suite Additions

**Quality: high.** Additive only; no pre-existing case altered.

- The `target folder resolution parity` `Context` covers `Find-OrchestrationDelegationTargetFolder`
  (no token, `.md` token resolving to parent, bare directory token, trailing sentence punctuation) and
  `Find-OrchestrationDelegationIssueNumber` (no number, keyed form, bare-hash form). The
  trailing-punctuation case was an optional recommendation and was taken; its comment correctly notes
  that the strip must not fire on a `.md` suffix.
- The unknown-mode case asserts `Get-OrchestrationDelegationCheckpointPath -Mode 'invented-mode'`
  returns the empty string, with the security rationale stated: no caller may manufacture a readiness
  source by inventing a mode name.
- The `mode deny-reason builder` `Context` closes R3 with two cases that assert the three properties
  the acceptance criterion actually requires — the `PREIMPLEMENTATION_GATE_BLOCKED:` prefix, the
  canonical checkpoint path for the mode, and the quoted failure token — rather than a single
  string-equality snapshot. This is the better assertion shape.
- **The D5 boundary is argued correctly in-file.** Both new contexts carry comments explaining that
  the functions under test take a `[string]` and return a `[string]`, construct no `Agent` envelope,
  and claim no transport, so decision D5 is not engaged. That is the correct reading of D5, and it is
  the reading this reviewer applied when rejecting the D5 justification in cycle 1.

One gap, which is the substance of the blocking finding:

- **The suite does not cover `Test-PreparationModeDelegation` on the Codex surface.** The file has
  198 lines of headroom and already establishes the pattern of calling pure predicates directly. Two
  `It` blocks would close B5. See the remediation inputs.

## Production Design Observations Carried Forward

These are unchanged from cycle 1 and are recorded so they are not lost at PR time.

- **`Test-PreparationModeDelegation` is now dead code on both surfaces.** `grep` across both current
  production copies returns only the function definitions; the sole production call site was the
  pre-change `Test-ImplementationDelegation`. The function is retained deliberately — `spec.md` lists
  it under "Not modified", and removing it would break a passing Codex legacy-contract test — but the
  branch ships a function no production path reaches, whose coverage is now maintained by tests alone.
  Removing it and `$script:PreparationModeMarkers` from all four copies is the correct follow-up
  refactor and should be filed rather than folded into this bug fix.
- **N3.** `Find-OrchestrationDelegationIssueNumber` returns the first bare-hash match, so a prompt
  containing two hash numbers resolves the target order-dependently. Follow-up.
- **N7.** `.codex/…/gate.ps1` at 495 of 500 and `codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
  at 494 of 500 both have minimal headroom. The next change to either will need a sibling file.

## Toolchain

`.claude/rules/powershell.md` requires format, then analyze, then Pester with coverage, passing in a
single pass. Evidence: `evidence/qa-gates/r1-final-poshqc-format.2026-08-27T22-47.md`,
`r1-final-poshqc-analyze.2026-08-27T22-47.md`, `r1-final-poshqc-test-coverage.2026-08-27T22-47.md`,
and `r1-final-single-pass-confirmation.2026-08-27T22-47.md`. Independently corroborated: the JUnit
artifact records 3825 cases with 0 failures and 0 errors, and the coverage XML is from the same run.
Type checking does not apply to PowerShell.

## Tone

The remediation artifacts and test comments are factual, literal, and free of humour, hyperbole, and
decorative metaphor. Evidence claims are matched to evidence strength — notably,
`r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md` explicitly labels its merge-base point as
resting on the cycle-1 audit "rather than on a fresh merge-base measurement", which is exactly the
disclosure that let this re-audit locate B5. PASS.
