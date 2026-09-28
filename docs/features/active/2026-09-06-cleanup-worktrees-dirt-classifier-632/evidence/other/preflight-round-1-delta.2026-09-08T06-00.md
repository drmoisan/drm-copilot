# Remediation cycle 1 — preflight round 1 delta

Timestamp: 2026-09-08T06-00
Plan under review: `remediation-plan.2026-09-08T05-00.md`
Reviewer: `atomic-executor` under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
Signal: **PREFLIGHT: REVISIONS REQUIRED**
Convergence: **NO FURTHER ROUNDS EXPECTED**

No task was executed and no file was modified during the review.

Structure validated as correct: nine phases with conforming headings, sequential
phase-matched task IDs (P0-T1..T9, P1-T1..T10, P2-T1..T6, P3-T1..T6, P4-T1..T7,
P5-T1..T6, P6-T1..T8, P7-T1..T8, P8-T1..T12), all evidence paths under
`<FEATURE>/evidence/<kind>/`, `[expect-fail]` tags with `ExpectedExitCode: 1` on
P2-T3, P3-T3 and P4-T4, and every absence assertion paired with a positive control.

The MCP plan validator returns `ok: true` with one warning, which is D6 below.

---

## D1 — [P2-T4] acceptance is unsatisfiable (blocking)

The condition requires zero occurrences of the literal `!= "!" ]]; then`. That
literal occurs **twice**:

```
231:	if [[ $x != " " && $x != "?" && $x != "!" ]]; then      <- rung 1, edited by P2-T4
351:		if [[ $x != " " && $x != "?" && $x != "!" ]]; then    <- any_staged pre-scan
```

Line 351 is the "is anything staged at all" pre-scan that decides whether to
issue the once-per-worktree probe. P2-T4 does not touch it and nothing instructs
the executor to. After the fix one occurrence remains, so the condition can never
pass.

**Delta.** Replace the third clause of the P2-T4 acceptance with:

> `grep -c -F '!= "!" ]]; then' scripts/bash/cleanup_worktrees_dirt_lib.sh` reports
> exactly `1`, down from `2` before this task. The surviving occurrence is the
> `any_staged` pre-scan inside `classify_worktree_dirt`, which decides only whether
> to issue the probe and is deliberately not gated on the Y column: a worktree
> carrying only `MM` entries must still issue the probe, because the probe's result
> is what rung 1 consumes for the entries that do have a space Y column.

## D2 — [P3-T1] mandates the wrong stub-key filename, and the pin cannot fail in the stated direction (blocking)

The task requires a fixture named `hash-object.notes_-_draft.md.out`. The stub's
sanitize rule (`tests/fixtures/cleanup_worktrees/stub-bin/git:89-93`) is
`${s//[^A-Za-z0-9._-]/_}`, so `notes -> draft.md` sanitizes to
**`notes_-__draft.md`** — space to `_`, retained `-`, `>` to `_`, space to `_`.
The plan's value is one underscore short.

The consequence is not a missing-file error. `respond` (`stub-bin/git:95-109`)
falls through to exit 0 with no stdout for an unmatched key, so under the fixed
code `blob` is empty, `classify_dirt_entry` takes the `hash-object`-empty
fail-closed branch at lines 282-285, and prints `UNIQUE`. The P3-T2 assertion
passes for the wrong reason, and the pass-after run becomes indistinguishable
from a hash-object read failure — exactly what P3-T1's own prose claims to prevent.

**Delta.** In P3-T1 replace every `notes_-_draft.md` with `notes_-__draft.md`, and
state the four keys explicitly:

> Under the unfixed split the entry's payload truncates to `draft.md`, so the
> reads are `hash-object.draft.md` and `rev-parse.main_draft.md`; supply both, with
> the `rev-parse` response equal to the `hash-object` response, which resolves the
> entry `CONTENT_ON_MAIN`. Under the fixed split the payload is the full
> `notes -> draft.md`, so the reads are `hash-object.notes_-__draft.md` and
> `rev-parse.main_notes_-__draft.md`; supply only the first, carrying a blob
> different from `hash-object.draft.md`. The `rev-parse` and `log.find-object`
> responses for the full path are deliberately absent, so the stub's default
> (exit 0, no stdout) makes rung 4's untracked half miss and rung 5 find nothing,
> and the entry reaches rung 6 as `UNIQUE`. Acceptance: the directory contains
> `hash-object.draft.md.out` and `hash-object.notes_-__draft.md.out` whose contents
> differ, contains `rev-parse.main_draft.md.out` byte-identical to
> `hash-object.draft.md.out`, and contains no file whose name begins
> `rev-parse.main_notes_`.

## D3 — Decision B's coverage consequence is factually wrong, and P1-T2 and P1-T10 write it into spec.md (blocking)

The plan states lines 74-77 "are the only members of the current uncovered set
this decision does not close", attributing them to the
`DISPOSABLE_SESSION_ARTIFACT` reachability decision. That does not hold:

- Lines 74-77 are the body of the multi-line `CLEANUP_WT_SESSION_ARTIFACT_PATHS=(`
  array literal, which executes at source time in every suite. Line 78, its closing
  paren, is not in the uncovered set. This is the kcov multi-line-statement
  attribution property, not a reachability property.
- Rung 2 **is** exercised today. The `dirt_session_artifact` scenario exists, the
  matcher at 126-129 is covered, and the emission site at 244-245 is covered.
  Retaining the rung costs no coverage at all.

**Delta.** In the Decision B block, P1-T2 and P1-T10, replace the
coverage-consequence clause with:

> Retaining the rung costs no coverage. `dirt_is_session_artifact` and its emission
> site are already exercised by the `dirt_session_artifact` scenario. Lines 74-77
> are reported uncovered because they are the interior of a multi-line array
> assignment whose statement kcov attributes to its closing line, the same
> instrumentation property that reports lines 95, 148, 151 and 305 uncovered while
> the statements they open do execute. That is unrelated to this decision.

## D4 — the 29-line partition in the Phase 6 preamble contains three errors (blocking)

**(a) The continued-command claim is inverted.** Lines 95, 148, 151 and 305 are the
**first** physical lines of their commands, not the second. Lines 96, 149, 152 and
306 are the ones kcov records as executed and none appears in the uncovered list.
The conclusion (gate on file percentage) is right; the stated mechanism is backwards.

**(b) Line 190 is not closable** and must move to the unclosable group. It is
`*.csproj | packages.config | */packages.config | app.config | */app.config) ;;`,
an empty `case` arm — the same construct as line 160, which the plan already
declares unclosable. It is taken today by `dirt_build_artifact` and still reported
uncovered. Phase 6 closes **twelve** lines, not thirteen.

**(c) Lines 269, 270 and 191 are first reached in Phase 3**, not Phase 6. P3-T1's
`R  old.md -> new.md` entry resolves `new.md` through rung 3's `*)` fallthrough
(191) and rung 4's tracked half (268-270).

Corrected arithmetic: 138 + 6 (Phase 5) + 12 (Phase 6) + 1 (line 343, Phase 7) =
**157/167 = 94.0%**. The stated figure survives only because (b) and the omission of
343 cancel. The 85% floor needs 142/167 and is cleared by Phase 5 alone, so the
margin is real; the derivation is not.

**Delta.** Rewrite the Phase 6 preamble's two paragraphs:

> This phase closes lines 155, 191, 258, 259, 273, 274, 308, 309, 415 and 416.
> Lines 269 and 270, the second `CONTENT_ON_MAIN` emission site, and line 191's
> first reach are closed earlier by [P3-T1]'s tracked `R` entry. Lines 98, 113, 114,
> 117, 233 and 234 are closed by Phase 5; line 343 by Phase 7's report-mode exit test.
>
> Five entries are not closable by any scenario and no task targets them. Lines 95,
> 148, 151 and 305 are the **first** physical lines of backslash-continued commands
> (`rev-list`, the cached `diff`, the worktree `diff`, and `log --find-object`);
> kcov attributes each statement to its continuation line — 96, 149, 152 and 306,
> none of which is uncovered — so the opening line can never be marked executed.
> Lines 160 (`"+"* | "-"*) ;;`) and 190 (the `*.csproj | ...` arm) are empty `case`
> arms carrying no statement to instrument; both are already taken by every
> build-artifact fixture and are reported uncovered regardless. Lines 74-77 are the
> interior of a multi-line array assignment, the same property. The gate for this
> finding is therefore the file percentage recorded in P8-T7, not a per-line list.
> Phase 5 closes six lines and Phase 6 ten, taking the file from 138/167 to 154/167;
> Phase 3 adds two and Phase 7 one, for 157/167, against a floor requiring 142/167.

## D5 — [P5-T2] and [P5-T3] under-specify their fixtures, making [P5-T5] unsatisfiable (blocking)

P5-T1 requires "the lower-rung responses that resolve `src/a.cs` to `UNIQUE`".
P5-T2 and P5-T3 specify only `status._repo-wt_dirt.out` and one `.rc` each. With no
`diff-quiet..src_a.cs.rc`, the stub's default is exit 0, so rung 4's tracked half
emits `CONTENT_ON_MAIN` and the P5-T4 assertions fail.

**Delta.** Append to both P5-T2 and P5-T3, before the acceptance sentence:

> Supply the same lower-rung responses P5-T1 supplies, so `src/a.cs` resolves
> `UNIQUE` once rung 1 declines; without them the stub's default exit 0 on
> `diff --quiet main -- src/a.cs` resolves the entry `CONTENT_ON_MAIN` and the
> P5-T4 assertion cannot pass.

## D6 — [P5-T6] carries the unanchored git diff span (validator G8 warning)

The sentence "an anchored `git diff` against the base branch is non-empty here"
contains a `git diff` invocation with no ref operand and no `--cached`, and the task
carries no companion span to exonerate it. The reasoning and the sha256 triple are
correct; only the token needs changing.

**Delta.** Replace "an anchored `git diff` against the base branch is non-empty here"
with "a diff against the base branch is non-empty here". Supplying a concrete
anchored invocation instead would require a `git status --porcelain` companion to
satisfy G8b and would state a command the task does not run.

## D7 — the branch head is stale by one commit, making [P8-T5]'s SHA assertion vacuous (blocking)

The plan header and P8-T5 anchor on `ad6bc946`. The branch is at
`388e1a78bfd1aaf73853e58f31d963b1aaee5d48`. `ad6bc946..388e1a78` touches only
`docs/`, so every code citation remains accurate, but:

- P8-T5's "records a head SHA different from `ad6bc946...`" is already true of the
  pre-work HEAD, so it passes even if the executor commits nothing.
- P8-T5's instruction to stage "the previously untracked
  `evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md`" is stale; it was
  committed in `388e1a78`.

**Delta.** Set the header branch line to `at 388e1a78bfd1aaf73853e58f31d963b1aaee5d48`,
note that `ad6bc946` is the commit the CI coverage run measured and remains the
anchor for the P0-T7 baseline only, change P8-T5's SHA acceptance to
`different from 388e1a78bfd1aaf73853e58f31d963b1aaee5d48`, and delete the
"previously untracked" clause.

## D8 — [P8-T12] cites spec.md:772-776, which this plan's own Phase 1 invalidates (blocking, sibling-invalidation)

`spec.md` has `## Proposed Fix` at 159, `## Acceptance Criteria` at 614, and the
extraction contingency at 772-776. Phase 1 appends seven criteria (P1-T6, at 614)
and two `### Proposed Fix` subsections (P1-T9, P1-T10, at 159-449) — all ahead of
772. By the time P8-T12 runs the paragraph will have moved.

This is the only surviving instance of the class; every other line citation was
checked and is either in an unmodified file, read before the shifting task, or
above an append-only edit.

**Delta.** In P8-T12 replace ``recorded at `spec.md:772-776` `` with a
quoted-content anchor naming the `## Risks & Mitigations` bullet that contains the
extraction literal. In the Decision B block replace `` `spec.md:839-840` `` with a
quoted-content anchor naming the `## Rollout & Follow-up` step.

## D9 — [P4-T5] parenthetical states the shift in the wrong direction (minor)

It says line 159 is content-anchored "because Phase 2 has already shifted the
numbers below its insertion point". Phase 2 inserts at 217 and 231, both **below**
159, so 159 is unshifted. Content-anchoring remains correct; the reason is not.

**Delta.** Replace with: `(line 159 at 388e1a78; Phase 2's insertions are below this
line and do not shift it, but the line content is used as the anchor for consistency
with the other two library edits)`.

## D10 — the R4 direction count disagrees with itself in three places (minor)

The findings table says "one of four material directions"; AC-42 says "four" then
enumerates five; the Phase 5 heading says "three"; `remediation-inputs` says three.
The plan adds five pinning tests (two in P2-T2, three in P5-T4). AC-42 is checked
off permanently by P8-T10, so the wording outlives this cycle.

**Delta.** Standardise on five, counting the two hard-failure sites separately.

---

## Advisory, not blocking

- **[P3-T4]** asserts `${xy:0:1} == R`, absent from the tree today so the assertion
  is sound, but a `case` form or a quoted `== "R"` would satisfy the intent and fail
  the acceptance, and `shfmt` will not normalise between them. State the required form.
- **[P0-T5]** asserts the local suite total is `390`, a figure from the CI run at
  `ad6bc946`. If the local total differs, P0-T5 fails and P8-T3's "delta is exactly
  14" becomes unsatisfiable. Record the observed total and assert the delta against it.
- **[P1-T3]** exclusion note omits `test_cleanup_worktrees_cli.bats`, which also shows
  zero in the `cleanup_worktrees_lib.sh` column. P7-T8 is unaffected.

## Verified correct, for the record

- P6-T6's 25-scenario / 30-record figures: 15 `dirt_*` directories today carrying 17
  entries, matching the `-eq 17` guard at `:237` and the 15 names at `:216-220`; the
  plan adds ten directories and thirteen records. `-eq 17` occurs exactly once.
- P7-T8's "exactly 11": ten suites reference `cleanup_worktrees_lib.sh` today plus the
  new fail-closed suite.
- P1-T4 / P1-T6 checkbox arithmetic: 38 criteria, 36 checked, AC-31 and AC-32 the only
  unchecked pair. 36-3=33; 38+7=45; 33+12=45.
- P1-T8's whole-file assertion is satisfiable: `wsl -d Ubuntu` at `spec.md:454`,
  `:599-602`, `:714`, `:716`; `agent-a3944b95a7d58e712` only at `:599-602`.
- The P0-T3 / P8-T1 digest roots are byte-exact against the formatter's discovery roots.
- Line budget holds: only `cleanup_worktrees_dirt_lib.sh` (425) changes among
  production shell files; `cleanup_worktrees_lib.sh` stays at 496 untouched.
- P4-T1 and P4-T2 pin both directions of the header-filter change.
- P7-T7's mutation probe works against `dirty_worktree_status_error`.
