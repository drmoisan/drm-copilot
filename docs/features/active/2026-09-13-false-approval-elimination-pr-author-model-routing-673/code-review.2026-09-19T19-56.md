# Code Review — Issue #673 (also closes #672)

Timestamp: 2026-09-19T19-56
Reviewer: feature-review
Branch: `bug/false-approval-elimination-673`
Base: `main`, merge base `b7c11616`; head `4b45ca7f`
Scope: full branch diff — 147 files, 11837 insertions, 598 deletions. Six production hook files, one
new library module, three skill documents, two settings files, one pack manifest, one Python
expectation file, and their bundled mirrors; the remainder is feature documentation, fixtures and
evidence.

## Executive Summary

Three enforcement gates previously composed the orchestrator checkpoint path from a fixed
repository-relative literal resolved against the invoking process's directory. In a parallel or epic
topology the session root holds a different item's checkpoint, so a gate could validate one item's
action against a sibling item's state and return allow — a false approval whose green carries no
information about the item actually gated. The change removes all three bindings, replaces them with
resolution by portable identity in a new library module, migrates a fourth gate to the same mechanism
(which closes issue #672), and states the contracts the mechanism depends on in three orchestration
skills.

**Verdict: PASS.** The design is correct, the reasoning behind it is recorded at the point of use, the
fail-closed direction is applied consistently, and the test evidence is stronger than the repository's
norm — particularly the per-binding fail-before pairing and the byte-identity discipline on protected
regression rows.

Findings: **0 Blocking, 2 Important, 8 Advisory.** No finding blocks merge.

The two Important findings are: a documentation-propagation gap, where the new fail-closed identity
requirement is stated in one orchestration skill while two other surfaces that issue receipt-gated
delegations do not state it; and a coverage gap on the one function whose parameter contract this
change altered, which the already-planned follow-up should be scoped to close.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| Important | `.claude/skills/cleanup-merged-worktrees/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md` | Step 4 of the first; the coordinator-spawn paragraph near line 166 of the second | Both issue delegations to the `pr-author` agent, which is receipt-gated, without stating the canonical-issue-line and branch-label requirement the gate now enforces. The first explicitly contemplates a run with no GitHub issue number. | Add one sentence to each requiring the canonical issue line where an issue number exists and a branch label in every case, cross-referencing the owning section rather than restating it. Extend the drift-coupled contract test to enforce it. | The gate denies any gated delegation it cannot identify. The requirement is stated only in `.claude/skills/orchestrate/SKILL.md`, so these two flows can be blocked. Direction is safe — it denies rather than approving from foreign state — and the deny reason names what to add. | `Get-ModelRoutingGatedAgent` at `.claude/hooks/enforce-model-routing-receipt.ps1` lines 91-98 returns six types including `pr-author`; the identity deny is at lines 241-250; the contract appears only under `## Issue Number Consistency` in the orchestrate skill. |
| Important | `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | Gate lines 173, 174, 177, 180, 181, 183; helpers lines 132 and 144 | The read, parse and field-extract body of the checkpoint-folder reader has zero direct coverage — only its absent-file early return at line 168 is exercised. This change made that function's checkpoint-path parameter mandatory and changed its input from a process-relative literal to an absolute resolved path. The helpers' two uncovered lines are in the folder-token normaliser, which the renamed selector now calls with the checkpoint value. | Scope the planned follow-up to these arms specifically: drive the reader against the three committed fixture checkpoints that already exist for the valid-with-field, invalid-JSON and valid-without-field shapes, and call the normaliser directly for its two arms. Place the rows in a new suite. | In both regressed files the uncovered lines sit on code paths this change re-pointed, so the follow-up closes a verification gap on the altered contract rather than repairing a ratio. | Recomputed from `artifacts/pester/powershell-coverage.xml`: 9 lines not covered in the gate, 2 in the helpers, at the line numbers given. |
| Advisory | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` (consumed, not modified) | Pattern defined at line 61; reader at lines 164-185 | The branch-signal pattern accepts a short-word-plus-colon label anywhere in free text, case-insensitively, and the reader returns the first match, so a prose phrase naming a base branch is a valid match. This change promotes that pattern to a primary worktree selector on two gates that read prose prompts. | Follow-up against the owning module: require line-start or list-item position for the label form, and add a row asserting that a prose base-branch mention is not read as a signal. | Mitigated twice already: the orchestrate contract requires the item's label to be the first such occurrence, and a branch-versus-issue disagreement denies with the ambiguity code. Residual exposure is a prompt with a false branch signal earlier than the intended label and no issue number. | The pattern and the first-match return were read directly; the disagreement deny is at `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` lines 280-301. |
| Advisory | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | The probe-anchoring block | The document probe stays process-directory-relative for a session-root target, so a hook process whose directory is a subdirectory of the item worktree resolves session-root and then probes relative to the subdirectory. | Optional: join the probe to the resolved root unconditionally, which is a no-op in the session-root case now that the resolved root is always populated for both resolved states. | Explicitly sanctioned by the spec's resolution step 7 and by the diff comment; pre-existing; fails toward a false denial, never a false approval. The checkpoint read, which is the binding this feature removes, is anchored absolutely and unaffected. | Read from the delivered control flow and from the resolved-result construction at `WorktreeItemResolution.psm1` lines 230-238. |
| Advisory | `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | Declaration at hook line 51; assignment at helpers line 338; read at helpers line 353 | A script-scope constant became mutable script-scope state assigned inside a function and read by a later block, where the equivalent local was already in scope. `.claude/rules/powershell.md` asks to pass data explicitly. | Pass the resolution result's checkpoint path directly to receipt verification and drop the script-scope assignment. Keep the null initialisation at hook line 51, which AC-4 requires. | No defect follows: both blocks are guarded by the identical condition, so the assignment always precedes the read and the unassigned value is unreachable. | Both blocks read in full; a content search enumerated every reader of the variable. |
| Advisory | `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | Lines 120-126 | The in-scope list for the row forbidding the checkpoint filename in a string expression names five files; the prd helpers sibling is absent, so a reintroduced default there would not be caught. | Add the sixth path — the one-line widening the file's own comment anticipates. | The file is currently clean, so nothing is wrong today; the gap is in the guard that exists to catch exactly this. | Content search for the literal across all six in-scope hooks returns zero; the list was read directly. |
| Advisory | `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md` | The test-hygiene, seam-signature and library-consumption criteria | Three criteria are checked off under narrowings their text does not permit: the target-resolution suite derives four absolute paths from the script file location to load its subject; one seam's parameter became mandatory; and the gate now contains one `Get-Location`, inside the resolution seam, where it had none at the merge base. | Amend the three criteria to forbid the behaviour rather than the token: no absolute path for use as a synthetic root or probe target; no worktree discovery in the gate or its sibling; seam names and payload shapes unchanged. | Issue #673's AC-37 authorises every delivered form, and the supporting evidence artifact is explicit about the classified count and the narrowed reading. The literal wording of the hygiene criterion is unsatisfiable by any suite that loads its subject. | Suite lines 99, 100, 109, 110; gate line 253; the base version of the gate was extracted and confirmed to contain no `Get-Location`. |
| Advisory | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/spec.md` | AC-9, AC-10, AC-13, AC-14, AC-17 | Five criteria say "the ambiguity reason code" where the delivered rows assert the no-target code, following the two-code split in issue #687. | Amend the five criteria in place to name the code each delivered row asserts, keeping the restated-conditions entries as the record of why the wording moved. | The spec reconciles every instance in its restated-conditions table, but the AC preamble promises each criterion is checkable without re-deriving the document's reasoning, and a third party reading AC-9 alone sees a mismatch with the test it names. | Restated-conditions entries RS-1, RS-2, RS-3 and RS-6 were read; the delivered row names were read from the suites and from the JUnit report. |
| Advisory | `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | Lines 146-148 and 168-176 | Two readers return null for both an absent and an unreadable-or-unparseable checkpoint through a broad catch, without a distinguishing diagnostic. | Distinguish the unreadable case in the detail clause so an operator is pointed at the right cause. Fold the related payload-shape guard note into the coverage follow-up. | Fail-closed, so no failure becomes an allow; the cost is diagnostic only. An operator sees a detail saying the issue is recorded in no live worktree when the real cause may be a permission error or a partial write. | Both functions read in full; the deny detail strings were read from lines 325-334. |
| Advisory | `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | The probe-anchoring guard; lines 199 and 235 | Two redundancies: a dead null-check conjunct in the probe-anchoring guard, unreachable because the earlier unresolved-identity block already returned; and the worktree ascent called twice on the same session path per resolved call. | No action. Recorded for completeness. | The first reads as a live guard when it cannot be false; the second is already deferred behind an equality test, so the cost is one extra disk-reaching ascent on the other-worktree path only. | Both read directly from the delivered files. |

## What the Change Does, as Read from the Diff

1. A new module, `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` (392 lines), selects the
   worktree a call pertains to from the canonical issue number in the call text matched against the
   recorded issue number of each live worktree's checkpoint, with a branch signal as the only
   tie-breaker. Four outcomes: two resolved states, a no-target state, and an ambiguous state.
2. The pr-author gate's relative default becomes a null initialisation assigned from the resolution
   result; the epic base-branch sibling's checkpoint-path parameter becomes mandatory and is passed the
   resolved path; the model-routing gate gains a resolution step placed after its scope filter.
3. The prd-feature gate is migrated to the same mechanism. Its path-derived call-target machinery, its
   envelope directory read, its session-root conditional guard and its positional tie-break are all
   removed; the multi-candidate disambiguator becomes the resolved worktree's own checkpoint.
4. Three orchestration skills gain a checkpoint-hygiene rule, and one gains the delegation-identity
   contract the two prompt-reading gates now depend on.

## Design Assessment

**The central design decision is correct and well argued.** A feature-folder path cannot select a
worktree, because a merged feature folder exists in every checkout branched from main and therefore
places a call in many worktrees at once. The module header states exactly this, and the prd gate's
resolution-order comment restates it at the point of use. Choosing the issue number — unique to an item
— and the branch — checked out in at most one worktree — as the only selectors follows from that
observation rather than being asserted alongside it.

**The fail-closed direction is applied consistently.** Every unresolved state denies. The module
imports are unguarded with stop-on-error semantics, and a comment at each site states that a resolver
which cannot load is itself the unresolvable state and must not degrade to the permissive path it
replaces. This is the right call for a security-relevant gate, and it is stated rather than left to be
inferred.

**The scope-filter ordering in the model-routing gate is right.** Identity resolution sits after the
gated-agent filter (lines 231 to 241), so a delegation outside the gated set is allowed however
unresolvable its target is. Placing it before the filter would have converted an unrelated delegation
into a deny. The comment at line 235 gives the reason.

**Collapsing the two resolved states into one switch arm is a genuine simplification, not a shortcut.**
Before, a session-root result used the bare relative path and an other-worktree result composed an
absolute one. After, both compose the same way, and the doc-comment explains why no special case is
lost: a session-root result is the case where identity happened to select the worktree the process is
already running in.

**Removing the session-root conditional guard in the prd gate is sound.** The guard existed because the
checkpoint might have belonged to a different session. Once identity selects the worktree and the
checkpoint is read beneath that root, the checkpoint is the item's own by construction, so the guard
became unreachable. The diff comment says so, and the coverage-delta artifact correctly identifies this
deletion as one of the two causes of the whole-file ratio movement.

**Reason codes are consumed, never restated.** Independently verified: a content search for both code
spellings across the hooks and library trees matches only the two definitions and two doc-comment
mentions in the owning module.

**The remedy sentences were updated rather than left stale.** The prd gate previously told the caller
to cite the target feature folder as an absolute path. After this change that action selects nothing,
so leaving it would have instructed the caller to do something inert. The new remedy names the two
identity lines, and the diff comment records the reasoning.

## Test Quality Assessment

**Strong.** Specific things done well:

- **Fail-before evidence is real and per-binding.** The matrix suites were authored against the
  unmodified hooks and run there first, producing 27 failures with all 27 inside the two new suites and
  zero in any pre-existing suite. Four rows are paired Failed-then-Passed with nothing changed between
  the runs but the production code, and the pairing artifact identifies which binding each row proves.
  Where a genuine failing run was structurally impossible — because issue #687 had already delivered
  the pr-author no-target deny — an exception dossier names the substitute evidence instead of quietly
  asserting the row as proof. That is the right handling.
- **Committed fixtures, not temporary files.** Nineteen fixture files model session-root, own-ready,
  own-not-ready, epic-mode, stale-receipt, empty and invalid-JSON conditions. The two rows needing a
  real readable file point at already-committed repository files, with a comment saying so.
- **Anti-vacuity assertions.** Both new structural guards assert their collection is non-empty before
  asserting the filtered collection is empty, so a rename cannot turn a row into a pass over zero
  items. The hygiene guard reads the gated-agent list from the dot-sourced gate itself rather than
  restating it, so the skill document cannot fall behind the gate without the row failing. One row
  deliberately uses string containment rather than wildcard matching, with a comment noting that a
  backtick is an escape character in a wildcard pattern and would silently never match — a real trap,
  correctly avoided.
- **Byte-identity discipline on protected rows.** Independently verified: filtering the combined diff
  of the three files holding the seven protected regression rows to lines carrying a test name or an
  assertion returns **zero** changed lines. One file's diff is empty; the other two changed only a
  nine-line insertion and seven call lines that each gained one appended argument.
- **A deliberate determinism fix in a pre-existing suite.** The new `BeforeEach` in the pre-existing
  model-routing suite pins the resolution seam to the session root specifically so those rows stay
  independent of whichever worktrees exist on the running machine, and every presence-gating row in
  that file mocks the checkpoint reader, so no live checkpoint is read.
- **Suppressions are narrow.** Eleven suppression attributes, all in test files, each naming one rule
  on one function with a justification. Zero in production code.

Weaknesses, both stated in the findings table: the coverage hole on the checkpoint-folder reader, and
the incomplete in-scope list in one structural guard.

One observation on the fixture directory wrapper: it mutates process-wide state, both the PowerShell
location and the .NET current directory. Order-independence is preserved by the `finally`, and the
comment explains why both must be set. It would not be safe under concurrent Pester containers in one
process, which is not how this suite runs. No action recommended; recorded so a future move to parallel
execution does not rediscover it.

## Assessment of the Accepted [P11-T5] Deviation

The orchestrator's reasoning was reviewed and the underlying figures were recomputed independently from
`artifacts/pester/powershell-coverage.xml` rather than read from the executor's evidence.

**Confirmed by recomputation:** the prd gate moved 90.72% to 90.32% and its helpers 96.77% to 96.61%;
post-change counts of lines not covered are 9 and 2; changed-line coverage is 100% on both files and on
all four other hooks, and 99.06% on the new module with its single uncovered line at 206; repo-wide
PowerShell line coverage is 95.77%, up from 95.72%; the lowest per-file figure in scope is 90.32%. The
baseline percentages and baseline uncovered counts are taken from the committed baseline artifact and
were not re-derived, since that would require running the suite against the base tree.

**I agree with the conclusion.** `.claude/rules/general-unit-test.md` states the no-regression rule over
the lines that were changed, and that rule is satisfied at 100%. The uniform 85% floor holds everywhere.
No repository policy is breached. The condition that failed is the plan's own stricter whole-file
sub-condition, and the arithmetic explanation is correct: deleting covered code lowers a
covered-over-total ratio while leaving the count of untested lines where it was. Recording it as not met
and escalating, rather than arguing it into compliance, is the correct handling, and the coverage-delta
artifact does that explicitly.

**One qualification, which raises rather than lowers the priority of the follow-up.** The framing "no
line that was tested before is untested now" is true, but it invites the reading that the residue is
incidental. It is not. In **both** regressed files the uncovered lines sit on code paths this change
re-pointed: six of the gate's nine are the read, parse and field-extract body of the checkpoint-folder
reader, the function whose parameter contract this change made mandatory and whose input changed from a
process-relative literal to an absolute resolved path; and both of the helpers' two are inside the
folder-token normaliser, which the renamed selector now calls with the checkpoint value instead of a
target signal value. So the follow-up is not cosmetic ratio repair — it closes a verification gap on the
altered contract itself. I would scope it to those specific arms and treat it as genuine rather than
tidy-up.

**I do not disagree with anything else in the stated reasoning**, and I agree with the decision not to
add rows to either pinned prd suite, for the reason the artifact gives: both are pinned to an exact
changed-line set by acceptance conditions already recorded as met, and the identity suite's own hygiene
condition forbids the script-location-derived path a committed fixture would require. A new suite is the
right home.

## Security Assessment

The change reduces attack surface rather than enlarging it.

- The class of defect removed is a false approval: a gate answering about one item from another item's
  state. Every replacement path either resolves the correct item or denies. No path was added that
  converts a former deny into an allow.
- The model-routing gate's new deny sits after the scope filter, so it cannot be used to block
  unrelated delegations.
- No new input is trusted. The identity read is a pattern scan of text the gate already received, and
  the checkpoint read is confined to the canonical path beneath a resolved root, so an archived or
  handed-off checkpoint is never matched.
- Path composition throws rather than guessing when the root is not absolute, which prevents a relative
  root from reintroducing the process-directory binding through the join.
- No secret, credential, token or environment file is introduced or read.
- The one residual relative path is a document probe that fails toward denial.

## Maintainability Assessment

Above the repository's norm. Every non-obvious decision in the diff carries a comment stating the
reason, not merely the effect — the unguarded imports, the assign-before-wrap idiom forced by a seam
that returns its array as one object, the choice of verb on the private result builder, why both sibling
modules must be imported rather than one, and why a conjunct on one guard is load-bearing. The three
superseded plan revisions and four preflight remediation-input artifacts are retained, so the decision
history is reconstructible. All ten mirrored pairs in this change set were verified byte-identical by
digest comparison performed by this reviewer, and the new module is registered once in the pack manifest
and in both PoshQC settings files, each verified by an executing test.

## Overall Code Review Verdict

**PASS.** Two Important findings are recorded and neither blocks merge; eight Advisory findings are
recorded for disposition. Remediation inputs are in `remediation-inputs.2026-09-19T19-56.md`.
