# Feature Audit — issue #554, remediation cycle 2 exit re-audit

- Timestamp: 2026-08-28T02-02
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `2c8f2ffc`
- Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a502f12120e44837d`
- Baseline: `origin/main` at `c62af7a7` for scope; the pinned constant `1e991b86` for changed-line reasoning
- Work mode: **`full-bug`** (`issue.md` line 4) — sole acceptance-criteria source is
  `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md`
- Supersedes: `feature-audit.2026-08-28T00-30.md` (retained) and `feature-audit.2026-08-27T22-47.md` (retained)

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md
- Total AC items: 35
- Checked off (delivered): 35
- Remaining (unchecked): 0
- Items remaining: none
```

**No criterion was unchecked by this re-audit. All 35 evaluate PASS.** `spec.md` was not modified by
this audit; no criterion text was amended, reworded, or added, and no checkbox was changed.

## The Criterion Check-Off — does the cycle-1 reasoning still hold?

The criterion under scrutiny is item **28**, at `spec.md` line 932:

> Line coverage across the PowerShell suite remains at or above 85%, and no changed line in either
> modified hook loses coverage.

The cycle-1 re-audit accepted this on narrower grounds than the executor stated and rejected the
second half of the executor's third argument. **That reasoning still holds, and B5's closure
strengthens it rather than disturbing it.**

### Clause 1 — re-measured

Repository-wide LINE coverage, parsed directly from the report root of
`artifacts/pester/powershell-coverage.xml`: **7211 covered, 403 missed, 7614 total = 94.7071%**,
against a threshold of 85%. Margin +9.71 pp, and +0.03 pp above the cycle-2 baseline of 94.6809%.

The criterion says "across the PowerShell suite", which is the repository-wide figure. The
sub-threshold `.codex/…/gate.ps1` file at 84.5679% therefore does not falsify this clause. This is
the narrower ground on which clause 1 was accepted in cycle 1, and it is unchanged. **Accepted.**

### Clause 2 — the three supporting arguments, re-adjudicated

**Argument 1 — the plan defines groups 1 and 2 as spanning both surfaces. STILL ACCEPTED.**
`coverage-delta.2026-08-28T00-30.md` §2 names `.codex` lines 292-296 and 304-308 inside group 1, and
§3 names `.codex` lines 421-422 inside group 2, each recorded as a named exception. It would be
incoherent for the artifact to require those ten lines to be recorded as accepted exceptions and then
treat the same ten as disqualifying one step later. Nothing in cycle 2 changed this.

**Argument 2 — the remediation inputs projected this end state and called it checkable. STILL
ACCEPTED, and this reviewer remains bound by it.** The cycle-1 inputs projected 27 uncovered of 162
(83.33%) and declared the criterion checkable at that state. Cycle 2's inputs projected the post-B5
state as 137/162 = 84.57% with a missed set of exactly the 25 lines beginning at 292, and stated that
84.57% "is still below the 85% uniform threshold. That is expected and is not a reason to widen the
work." **The measured end state is 137 covered, 25 missed, 162 total, 84.5679%, with the missed set
exactly those 25 members — the cycle-2 projection to the line.** Having pre-committed to that state,
this reviewer accepts it.

**Argument 3 — first half STILL ACCEPTED; second half REMAINS WITHDRAWN, and is now formally
corrected.**

- The **first half** — that the criterion asks whether a changed line *loses* coverage, and that all
  34 uncovered changed lines are added lines with no base coverage to lose — is re-verified by direct
  measurement in this cycle. Intersecting each file's measured missed set with the added-line set of
  `git diff -U0 1e991b86 -- <path>`:

  | File | Uncovered changed | Uncovered pre-existing |
  | --- | --- | --- |
  | `.claude/…/gate.ps1` | 9 (266, 267, 268, 270, 278, 279, 280, 282, 408) | 9 (125, 252, 253, 255, 425, 485, 486, 487, 490) |
  | `.codex/…/gate.ps1` | 25 (the full missed set) | **0** |

  Membership test: **197 is a pre-existing line and 206 is a pre-existing line.** Neither is a changed
  line. On its literal text, clause 2 holds. **This is why the criterion stays checked.**

- The **second half** — the claim that no line covered at the merge base is uncovered now — was false
  when written, was withdrawn in cycle 1's re-audit, and is now corrected at all three sites it
  propagated to. Cycle 2 did more than withdraw it: **it made the claim true.** The Codex file's
  uncovered pre-existing count is now 0.

### Verdict

**The check-off is WARRANTED and stands, on the same narrower grounds cycle 1 accepted, now with the
withdrawn argument both corrected in the record and made true in fact.** B5's closure removes the only
lost-coverage set that argument 3 mis-stated. No criterion has become false.

## Verification that B5 Unseated Nothing

B5 concerned two **unchanged** lines and was raised on the no-regression policy, not on any acceptance
criterion. Its closure:

- does not alter the 9 and 25 uncovered-changed-line counts, so criterion 28's clause 2 is unmoved;
- raises the repository-wide figure by +0.03 pp, so criterion 28's clause 1 is unmoved in direction;
- touched only two test files, both created by this branch, so criteria 21, 22, 23, 24, and 29 are
  unmoved;
- touched no production byte, so criteria 25, 26, 27, and 34 are unmoved;
- required no `spec.md` amendment, so criterion 31 is unmoved — statement `(e)` of the
  `## DECLARED BLAST RADIUS` section already forward-declares any later cycle's root-level artifact
  set, and the three artifacts written by this re-audit resolve to it without amendment.

## Disposition of `[P6-T6]`

`[P6-T6]` in the original plan `plan.2026-08-26T08-40.md` line 312 remains unchecked. It is the only
unchecked task in that plan (`grep -c '^- \[ \] \[P'` returns 1).

**Verdict: leaving it unchecked remains the correct disposition. Confirmed after B5's closure.**

Its acceptance clause, at line 313, reads: "all three values are numeric, the post-change percentage
is at or above 85, and **no changed line in either modified hook is reported as uncovered**". The
third conjunct is measurably false and will remain so: `.claude/…/gate.ps1` reports 9 uncovered
changed lines and `.codex/…/gate.ps1` reports 25. Every one of the 34 belongs to a named, accepted
exception, but the clause admits no exceptions.

**B5's closure could not have changed this.** B5 concerned lines 197 and 206, both of which the
membership test above shows to be **pre-existing**, not changed. Closing them moved the uncovered
*changed* counts by zero. The clause is exactly as false now as it was at cycle-1 exit.

The three alternatives remain worse. Checking it would assert a condition that measurably does not
hold. Rewording the clause would amend an acceptance gate after seeing the result it produced, which
is the defect class `.claude/rules/plan-acceptance-gates.md` exists to prevent. Deleting it would
erase the record. Leaving it unchecked, with the deliverable itself superseded by
`evidence/qa-gates/coverage-delta.2026-08-28T00-30.md`, records honestly that the plan's own gate was
written stricter than the feature could satisfy and that the shortfall is accounted for elsewhere.

`[P6-T6]` is a plan task, not a `spec.md` acceptance criterion, so it does not gate the AC set.
`git diff --name-only 3140652d..HEAD -- <plan>` is empty: cycle 2 did not touch the plan file.

## Acceptance Criteria Evaluation — all 35

Verification method is recorded per group. Where an evidence artifact is cited, its claim was
corroborated by independent measurement rather than accepted on its face.

### Behavioural criteria — amendments 1-4 and the test matrix (criteria 1-20)

| # | Criterion | Verification | Verdict |
| --- | --- | --- | --- |
| 1 | Amendment 1 — epic-child `Agent(orchestrator)` allowed iff the epic checkpoint proves the epic prepared and the target is a real, not-yet-merged record | Implemented by the mode-resolution and readiness machinery; asserted by matrix cases 1-4 and the merge-status cases below | PASS |
| 2 | Amendment 2 — reordering or rewording a prompt cannot change the decision either way | Structural classifier over named fields replaces the serialized-payload substring scan; matrix case 5 asserts a marker in a non-prompt field does not resolve the mode; case 6b asserts a reworded prompt does not flip to allow | PASS |
| 3 | Amendment 3 — a denied delegation's reason names the checkpoint consulted and the failed predicate | `Get-OrchestrationModeDenyReason`; asserted by matrix cases 2, 4, and the parallel negative and canonical-path cases | PASS |
| 4 | Amendment 4 — standalone orchestration, planner-surface writes, and the #539 staging exemption behaviourally unchanged | The four `-helpers.ps1` copies byte-untouched (4/4, one shared SHA-256); the four pre-existing suites unmodified and passing | PASS |
| 5 | Matrix case 1 — epic-mode allow with a ready injected epic checkpoint | `claude-hooks/…-gate-mode-resolution.Tests.ps1`, 83 cases, 0 failures in `pester-junit.xml` | PASS |
| 6 | Matrix case 2 — deny on empty injected epic-checkpoint content, reason names the file | same suite | PASS |
| 7 | Matrix case 3 — deny when the features array lacks the target record | same suite | PASS |
| 8 | Matrix case 4 — deny on a non-canonical declared epic checkpoint path | same suite | PASS |
| 9 | Matrix case 5 — epic marker in a non-prompt field resolves to default single-feature mode | same suite | PASS |
| 10 | Matrix case 6a — allow-listed implementation agent, no legacy tokens, unready checkpoint → deny | same suite | PASS |
| 11 | Matrix case 6b — the new allow-to-deny behaviour change, asserted explicitly | same suite; regression evidence on both sides at `evidence/regression-testing/fail-before-case-6b.2026-08-26T10-18.md` and `pass-after-case-6b.2026-08-26T11-36.md` | PASS |
| 12 | Matrix case 7 — both preparation markers → allow | same suite | PASS |
| 13 | Matrix case 8 — standalone orchestrator allow on ready, deny on unready | same suite, two cases | PASS |
| 14 | Parallel readiness, positive | same suite | PASS |
| 15 | Parallel readiness, negative — deny naming the parallel checkpoint file | same suite | PASS |
| 16 | Parallel canonical-path cross-check → deny | same suite | PASS |
| 17 | Epic target unresolvable → deny | same suite | PASS |
| 18 | Merge-status hardening (D8) — terminal-merged → deny, failure status → allow | same suite, two cases | PASS |
| 19 | Codex logic parity (D5 deliverable i) | `codex-hooks/…-gate-mode-resolution.Tests.ps1`, **55 cases, 0 failures** — the 53 of cycle-1 exit plus the two B5 cases | PASS |
| 20 | Codex transport gap recorded (D5 deliverable ii) — a test reads `.codex/config.toml` and asserts no `PreToolUse` matcher admits `Agent` or `Task`, cross-referencing #555 | same suite, `Context 'the recorded Agent-transport gap (decision D5, deliverable ii)'` at line 300 | PASS |

### Test-integrity criteria (21-23)

| # | Criterion | Verification | Verdict |
| --- | --- | --- | --- |
| 21 | All four pre-existing suites pass **unmodified**, verified by absence from the branch diff | All four absent from `git diff --name-only origin/main...HEAD`; `pester-junit.xml` reports 35 / 58 / 33 / 58 cases, **0 failures each** | PASS |
| 22 | `PreToolUseSchema.Contract.Tests.ps1` passes unmodified | Absent from the branch diff; 15 cases, 0 failures | PASS |
| 23 | Four `-helpers.ps1` copies byte-identical to the branch point | Absent from `git diff --name-only origin/main...HEAD` and from `1e991b86..HEAD`; all four measure SHA-256 `45c339fd4b4b1702230518b6fcdeb863a08bcb7a7540f46c5f7851c730765c0b` | PASS |

`legacy-codex-hook-contracts.Tests.ps1`, the sixth pre-existing suite named in the remediation
prohibitions, is likewise absent from the branch diff and reports 43 cases, 0 failures.

### Structural and packaging criteria (24-27)

| # | Criterion | Verification | Verdict |
| --- | --- | --- | --- |
| 24 | Four mirrored pairs SHA-256 byte-identical per surface; pair hashes recorded under `evidence/qa-gates/` | `Get-FileHash -Algorithm SHA256` on all eight: **4/4 EQUAL**, and all four equal their pre-remediation values; recorded in `r2-mirror-pair-hashes.2026-08-28T00-30.md` | PASS |
| 25 | Both `pester.runsettings.psd1` copies list both new production hook files in `CodeCoverage.Path`; the PoshQC bundled-parity Python test passes | Direct inspection: both copies carry the `-modes.ps1` entry for both surfaces at lines 139 and 214, byte-parallel; `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py …` re-run at this audit: **24 passed, 0 failed** | PASS |
| 26 | Both pack manifests list the new modes hook for their surface; push-down completeness Python tests pass | Direct inspection: Claude `core.json` line 37, Codex `core.json` line 41; the same pytest run passes both completeness suites | PASS |
| 27 | The new production hook files appear in the Pester coverage report from the self-hosted `Invoke-PoshQCTest` | Both `-modes.ps1` files appear as `sourcefile` elements in `powershell-coverage.xml` with 132 measured lines each and 130 covered; the registration takes effect | PASS |

Criterion 26 is satisfied as written: both manifests list the **modes** hook. The Codex manifest's
omission of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is a separate,
pre-existing condition carried as non-blocking N5.

**New measurement this cycle.** The Python verification suites were re-run after the `origin/main`
merge and now report **24 passed, 0 failed**. The single failure recorded at cycle-1 exit —
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, attributable to open issue #510 —
does not reproduce. Criteria 25 and 26 therefore rest on a clean run rather than on an annotated
expected failure.

### Coverage criterion (28)

| # | Criterion | Verification | Verdict |
| --- | --- | --- | --- |
| 28 | Line coverage ≥ 85% across the suite; no changed line in either modified hook loses coverage | Repository-wide **94.7071%** measured. No changed line lost coverage: all 34 uncovered changed lines are added lines. Uncovered pre-existing lines on the Codex hook: **0**, down from 2 | PASS |

Adjudicated in full above. Remains checked.

### Constraint criteria (29-35)

| # | Criterion | Verification | Verdict |
| --- | --- | --- | --- |
| 29 | No `.claude/rules/`, `.claude/skills/`, or `.github/` file in the branch diff | Path filter over all 133 changed files of `git diff --name-only origin/main...HEAD`: **NONE**. The two policy-tree files a two-dot diff shows arrived from the `origin/main` merge of PR #571 and are not this branch's writes | PASS |
| 30 | Deny-by-default preserved, no new permissive path | Cases for an unparseable payload, an absent tool-input key, and empty injected checkpoint content are present and passing; matrix case 6b asserts a former allow is now a deny, never the reverse | PASS |
| 31 | Every file written by the branch appears in `## DECLARED BLAST RADIUS` | `r2-blast-radius-conformance.2026-08-28T00-30.md` resolves the four-way union with **0 UNDECLARED**. Independently re-checked for this cycle's own artifacts: statement `(e)` covers the timestamp-bearing root-level `policy-audit`, `code-review`, and `feature-audit` files for "any later cycle's set", so no amendment is required and none was made | PASS |
| 32 | Full PowerShell toolchain passes in a single pass: format, then analyze with zero findings, then Pester with coverage | Iteration 1, stages captured at 01-56, 01-58, 01-59, 02-02; format reformatted 0 files with an empty post-run porcelain listing; analyze reported 0 findings; corroborated independently by `pester-junit.xml` at **3827 cases, 0 failures, 0 errors** and a coverage XML from the same run at 01:42:29 | PASS |
| 33 | The plan records the D6 batch sequencing and the mechanical-byte-copy statement for each `extensions/drm-copilot/resources/` file | `plan.2026-08-26T08-40.md` change-budget section; `evidence/qa-gates/plan-budget-statement.2026-08-26T11-36.md` | PASS |
| 34 | Every production `.ps1` written by this change is at or under 500 lines | 489, 477, 495, 477 self-hosted; the four mirrors are byte-identical and carry the same counts | PASS |
| 35 | A D3 follow-up record is written under `evidence/other/`, stating the gap, the recommended contract amendment, and the out-of-scope reason | `followup-epic-kickoff-contract-gap.2026-08-26T11-36.md` states all three; the deferral of the GitHub filing is recorded separately in `followup-issue-filing-deferred.2026-08-26T11-36.md` | PASS |

## Scope Constraints Requested by the Caller — verified independently

| Constraint | Result |
| --- | --- |
| Zero production `.ps1` changed by cycle 2 | **CONFIRMED.** Per-commit `git show --name-only` over all eight post-cycle-1 commits: the only `.ps1` paths touched are the two branch-created test suites |
| Four mirrored pairs SHA-256 byte-identical per surface and equal to pre-remediation values | **CONFIRMED.** 4/4 equal per surface; all four match the values recorded at cycle-1 exit; blob-id equality on all eight files between `3140652d` and `HEAD` is 8/8 SAME |
| Four `-helpers.ps1` copies byte-untouched | **CONFIRMED.** Absent from the branch diff and from `1e991b86..HEAD`; all four share one SHA-256 |
| Six pre-existing suites unmodified and passing | **CONFIRMED.** All six absent from the branch diff; 0 failures each in `pester-junit.xml` |
| No file under `.claude/rules/`, `.claude/skills/`, `.github/instructions/`, or `.github/copilot-instructions.md` | **CONFIRMED.** Path filter over the branch diff returns none |
| Exactly seven files under `extensions/drm-copilot/resources/` | **CONFIRMED.** Count over `git diff --name-only origin/main...HEAD` is 7 |

## The `origin/main` Merge

`13d68f8a` merged `origin/main` at `c62af7a7` (PR #571, plan-acceptance gates). `git diff --name-only
13d68f8a^1 13d68f8a` restricted to every surface this feature owns returns **empty output**: the merge
changed nothing in the feature folder, either hook directory, either test directory,
`scripts/powershell/`, or the bundled PoshQC settings.

The six pre-existing suites and the four mirror pairs are therefore undisturbed by it, confirmed by
direct measurement rather than by inference. PR #571's gates G1-G6 run only against an artifact a
caller points them at — `.claude/rules/plan-acceptance-gates.md` states that no sweep of the committed
plan corpus exists and none is added — so this feature's plan documents are not retroactively
evaluated. **No regression.**

## Baseline Comparison

Relative to the pinned anchor `1e991b86`, the branch delivers:

- A structural delegation classifier replacing the seven-token free-text scan over a serialized
  payload, on both the Claude and Codex surfaces.
- A new pure `-modes.ps1` sibling per surface carrying the mode table, checkpoint-path resolution,
  target-folder and issue-number extraction, and the epic and parallel readiness predicates.
- Epic and parallel checkpoint consultation through injected read seams, so decision logic is testable
  without filesystem access.
- Deny reasons that name the checkpoint consulted and the failed predicate.
- Coverage registration for both new production files in both `pester.runsettings.psd1` copies, and
  pack-manifest registration in both `core.json` copies.
- Three test suites: two new, one extended.

Behaviourally unchanged and verified so: the Edit/Write and Bash legs, the issue #539 staging
exemption, `Test-ImplementationPath`, `Test-ImplementationCommand`, and
`Test-ExemptOrchestrationStagingCommand`.

## Outstanding

**Zero blocking findings.** `remediation-inputs.2026-08-28T02-02.md` is deliberately not written.

**One accepted shipping exception, which must be disclosed in the pull-request description.** The
exact wording to carry into the PR body:

> **Coverage exception (issue #555).** `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
> ships at 84.57% line coverage (137 of 162 lines), below the repository's 85% uniform threshold. The
> entire shortfall is owned by a single named exception: the Codex epic/parallel decision branch at
> lines 426-443, 15 measurable lines. Driving that branch requires constructing an `Agent` delegation
> payload for the Codex decision function, which decision D5 of this feature's spec prohibits because
> `.codex/config.toml` registers no `PreToolUse` matcher admitting an `Agent` or `Task` tool name.
> Fabricating such an envelope would assert a transport the Codex runtime never exercises. Issue #555
> owns that transport gap and is explicitly out of scope here; covering those 15 lines alone would
> take the file to 93.83%. The other three production files ship at 88.00%, 98.48%, and 98.48%, and
> repository-wide PowerShell line coverage is 94.71%.

Five non-blocking items remain open (N3, N5, N7, N9, and the new advisory N10); one, N8, is closed.
They are enumerated in `policy-audit.2026-08-28T02-02.md` and none gates this pull request.
