# Code Review — issue #554, remediation cycle 2 exit re-audit

- Timestamp: 2026-08-28T02-02
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `2c8f2ffc`
- Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a502f12120e44837d`
- Scope base: `git diff origin/main...HEAD` (133 files); changed-line anchor `1e991b86`
- Supersedes: `code-review.2026-08-28T00-30.md` (retained) and `code-review.2026-08-27T22-47.md` (retained)

## Review Scope

This is a re-audit at the exit of remediation cycle 2. The full branch diff was re-examined for scope
and constraint purposes; the substantive code review of the production change was completed in cycles
0 and 1 and is not re-derived. What follows reviews **what cycle 2 changed** — two test files and two
appended evidence documents — plus a re-verification that nothing else moved.

Cycle 2 changed **zero production files**. Every production byte on this branch is identical to its
state at cycle-1 exit (`3140652d`), proven by blob-id equality on all eight mirrored hook files.

## Findings

**Blocking: 0. Non-blocking: 1 (advisory, carried in the policy audit as N10).**

## What Cycle 2 Changed

| File | Change | Lines before → after |
| --- | --- | --- |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | one new `Context` with two `It` blocks | 302 → 332 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` | one comment block rewritten in place, 5 lines → 10 | 154 → 159 |
| `docs/.../policy-audit.2026-08-27T22-47.md` | 1903 bytes appended | — |
| `docs/.../evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md` | 2069 bytes appended | — |

Plus 21 evidence artifacts under `evidence/remediation-baseline/` and `evidence/qa-gates/`, and
checkbox updates to `remediation-plan.2026-08-28T00-30.md`.

## Review of the New Test Code

The new `Context` sits at
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
lines 270-298, placed between the `classifier parity` context and the `recorded Agent-transport gap`
context, exactly where `remediation-plan.2026-08-28T00-30.md` specified.

### Assessment against `.claude/rules/general-unit-test.md`

| Property | Assessment |
| --- | --- |
| **Independence** | Each case constructs its own `[pscustomobject]` in the case body. No shared mutable state, no ordering dependency. **PASS** |
| **Isolation** | Each case calls exactly one predicate, `Test-PreparationModeDelegation`, and asserts one boolean. A failure identifies the faulty conjunct unambiguously. **PASS** |
| **Fast execution** | Two in-process predicate calls, no I/O. **PASS** |
| **Determinism** | Literal string fixtures only. No clock, no RNG, no filesystem, no network, no external process, no `Mock`. **PASS** |
| **Readability** | Case names state the input condition and the expected result: `returns false for a non-orchestrator subagent type carrying both preparation markers on the Codex surface`. Each carries a comment naming the conjunct it exercises and the production line it closes. **PASS** |

### Arrange–Act–Assert

Both cases follow the pattern compactly and legibly. Arrange is the single `$toolInput` assignment;
Act and Assert are fused in the idiomatic Pester pipeline form
`Test-PreparationModeDelegation -ToolInput $toolInput | Should -BeFalse`. Fusing act and assert is
appropriate for a pure predicate with a boolean result and is consistent with the surrounding suite.

### Fixture design — the point worth commending

The line-197 case supplies `subagent_type = 'task-researcher'` **together with both preparation
markers**. That is a deliberate and correct choice: it makes the subagent-type check the **only**
predicate that can produce `$false`. Had the fixture omitted a marker, the case would have passed for
the wrong reason — through the marker loop rather than through line 197 — and the coverage gap would
have persisted while the test appeared to close it. This is precisely the vacuous-assertion failure
mode that `.claude/rules/plan-acceptance-gates.md` exists to prevent, and the plan anticipated it and
required the stronger fixture. The comment at line 285-286 records the reasoning inline, so a later
reader cannot weaken the fixture by accident.

The line-206 case is the symmetric all-conjuncts-hold positive, with both markers carrying their
trailing periods, matching `$script:PreparationModeMarkers`.

The per-line coverage probe confirms both cases reach their intended lines: 197 and 206 each read
`ci="1"`.

### No duplication with the legacy-contract suite

`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` still calls the predicate directly
with a `$null` payload and with an `orchestrator` payload carrying one marker, reaching the null
branch and the marker-loop return. The two new cases reach the two branches those callers cannot.
The plan explicitly declined to add the two symmetry cases that would have duplicated the existing
coverage, and recorded the omission as a decision rather than leaving it silent. That is the correct
disposition: an added case that closes no line and duplicates an existing assertion is test debt.

### Comment quality

The `Context`-level comment (lines 271-282) states the defect, its cause (the removed call site at
merge-base line 213), why the two surviving callers are insufficient, and why decision D5 is not
engaged. It is accurate against the evidence, factual in tone, and does the job a comment should do:
explain the non-obvious *why*, not restate the *what*.

## Review of the In-Place Comment Correction

The classifier suite's comment block at lines 79-90 was rewritten from five lines to ten. The prior
text asserted, without qualification, that "the Codex copy kept coverage from
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`". The replacement states that the
Codex copy kept only **PARTIAL** coverage, names which two branches the surviving callers reach and
which two they do not, records that both missing branches were covered at the merge base through the
removed call site, and names cycle-2 finding B5 and the file that closes it.

The correction is accurate. `grep 'kept coverage from'` over the file returns no match; `PARTIAL`
appears at line 81. `git show a9db81d0` shows a single hunk at `@@ -78,11 +78,16 @@`, so no line
outside the comment block was disturbed, and the suite's case count is unchanged at 7 with 0 failures.

**The method choice is correct and worth recording.** Live source is not an audit artifact. A comment's
only obligation is to be true for a reader of the current file, and appending a correction notice
beneath a false comment would leave the false statement standing in the file a developer actually
reads. Git history preserves the superseded text, so nothing is lost. The complementary choice for the
two evidence artifacts — append, never rewrite — is equally correct for the opposite reason: a
superseded review record exists to preserve what was believed and when, and rewriting it destroys the
information the record is for. The plan stated both choices with their reasons rather than leaving
them to executor discretion, which is the right level of specification for a correction task.

## Review of the Two Appended Correction Notices

Both notices are dated, clearly headed, and mark their host artifact as superseded. Both quote the
incorrect text before correcting it, so a reader can see exactly what changed without diffing. Both
name the evidence for the correction (merge-base line 213, the two legacy-contract call sites at lines
367/373 and 242, the marker set) rather than asserting it.

The `r1-acceptance-criterion-reevaluation` notice does one thing especially well: it **scopes its own
withdrawal precisely**. It withdraws the second half of the third supporting argument, states that
arguments 1 and 2 are accepted in full and untouched, and states explicitly that the verdict on the
acceptance criterion is unchanged and the checkbox stays checked. A correction that withdrew more than
the error required would have destabilised a criterion the error did not actually bear on.

Byte-untouchedness was verified independently by count-free prefix comparison against the blob at
`093315b2`: 20856-byte and 7915-byte prefixes, both `cmp`-identical, with remainders of 1903 and 2069
bytes that are solely the specified blocks. See `policy-audit.2026-08-28T02-02.md`.

## Re-Verification of the Unchanged Surfaces

| Check | Method | Result |
| --- | --- | --- |
| Production `.ps1` unchanged since cycle-1 exit | blob-id equality on all eight mirrored files, `3140652d` vs `HEAD` | 8/8 SAME |
| Mirror pairs byte-identical per surface | SHA-256 on all eight | 4/4 EQUAL, and equal to the pre-remediation values |
| `-helpers.ps1` untouched | absent from the branch diff; four copies share one SHA-256 | 4/4 UNTOUCHED |
| Six pre-existing suites unmodified | absent from `git diff --name-only origin/main...HEAD` | NONE PRESENT |
| Six pre-existing suites passing | `pester-junit.xml` per-suite counters | 0 failures each |
| `spec.md` and `plan.2026-08-26T08-40.md` untouched by cycle 2 | `git diff --name-only 3140652d..HEAD -- <both>` | empty |
| Policy paths untouched | path filter over the branch diff | NONE |
| `extensions/drm-copilot/resources/` file count | count over `origin/main...HEAD` | 7 |

## Design-Principle Assessment of the Landed Change

Re-affirmed, not re-derived. The production design reviewed in cycles 0 and 1 stands:

- **Simplicity.** The seven-token substring scan over a serialized payload is replaced by a structural
  classifier over named fields. The replacement is smaller in concept even though it is larger in
  lines, and it removes an entire class of false positive that three prior point patches (#535, #539,
  and this issue) failed to close by extending exemption lists.
- **Separation of concerns.** The new `-modes.ps1` sibling holds the pure mode table, checkpoint-path
  resolution, target-folder and issue-number extraction, and the two readiness predicates. The gate
  hook retains the I/O and the wiring. Checkpoint reads enter through injection seams
  (`-EpicCheckpointRaw`, `-ParallelCheckpointRaw`), so the decision logic is testable without a
  filesystem. This is the correct boundary and it is what makes the 98.48% coverage of the modes
  siblings achievable.
- **Extensibility.** The mode table is data, so a further orchestration mode is a table entry plus a
  readiness predicate, not a new branch in the classifier.
- **Error handling.** Deny is the default. Deny reasons name the checkpoint actually consulted and the
  failed predicate, which is the substance of amendment 3.
- **File size.** All four production files are under the 500-line cap, with the Codex gate hook
  closest at 495. Non-blocking N7 flags that the next change to it will need a sibling.

## Known Residuals, Reviewed Not Remediated

| Residual | Lines | Judgement |
| --- | --- | --- |
| Injected read seams — `Get-EpicCheckpointContent` / `Get-ParallelCheckpointContent` bodies, both surfaces | 16 | Correctly accepted. These are the I/O the seam exists to isolate. Covering them would additionally make several allow assertions pass vacuously against the live checkpoint, which is worse than leaving them uncovered |
| Claude 408, the non-injected `else` arm; Codex 421-422, the declared-checkpoint-path deny return | 3 | Correctly accepted. Same seam for the Claude line; decision-D5 transport for the Codex pair |
| `Write-Debug` catch at lines 94-95 of both `-modes.ps1` copies | 4 | Correctly accepted. Fires only when `PSObject.Properties` itself throws, which no JSON-derived object produces |
| Codex 426-443, the epic/parallel decision branch | 15 | The named **issue #555** shipping exception. Genuinely D5-constrained; covering it requires fabricating an `Agent` envelope for a transport the Codex runtime never registers |
| `Test-PreparationModeDelegation` is dead code on both surfaces (N9) | — | Real technical debt, correctly deferred. `spec.md` lists the function under "Not modified", and removing it would break the passing Codex legacy-contract suite. The follow-up refactor should remove the function and `$script:PreparationModeMarkers` from all four copies together, which also resolves the duplicated marker rule |

The N9 residual deserves one sentence of emphasis: cycle 2 closed B5 by adding tests for a function
that has no production caller. That is the right call for this bug fix — it restores the coverage the
change cost, at two `It` blocks, without touching production or contradicting the spec — but it does
leave a function whose only justification is a test that exercises it. The follow-up refactor is the
correct place to resolve that, not this branch.

## Tone

All cycle-2 artifacts and code comments use professional, factual, neutral language. No humor,
hyperbole, decorative metaphor, or celebratory phrasing was found. Evidence-first wording is used
consistently: the `r1` correction notice's "Stated limitation" paragraph in the original text, and the
notice's precise scoping of what it withdraws, are both good examples. **PASS** against
`.claude/rules/tonality.md`.

## Non-Blocking Observation

**N10 (advisory).** Ten cycle-2 evidence artifacts carry internal `Timestamp:` values later than the
commit that introduced them — `2c8f2ffc` was authored at 01:54:35 while artifact stamps run from 02-02
to 02-32, increasing monotonically in task order at a near-constant interval. This is the signature of
a synthetic sequence rather than a clock read. It does not affect any measurement; every load-bearing
number in those artifacts was independently reproduced during this re-audit and is correct. Recommend
reading the clock per artifact in future cycles. Detail in `policy-audit.2026-08-28T02-02.md`.

## Output Summary

Cycle 2 is a clean, minimal, correctly-scoped remediation: two `It` blocks and one comment rewrite,
zero production bytes changed, closing a two-line coverage regression and a three-site factual error.
The fixture design for line 197 is the notable quality point — it forces the assertion through the
intended predicate rather than passing for the wrong reason. The split between in-place rewrite for
live source and appended notice for evidence artifacts is correct in both directions and was specified
with its reasoning rather than left to discretion. **Zero blocking findings. One advisory
non-blocking observation (N10).**
