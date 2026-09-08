# Deferred findings — disposition of F7 through F14

Timestamp: 2026-09-08T08-18

Task: [P8-T12] of `remediation-plan.2026-09-08T05-00.md`

Source: `code-review.2026-09-08T05-00.md`, findings F7 through F14. None of the eight blocks
merge on its own. Each is recorded here with its title, why it does not block this
remediation cycle, and the reason for deferral, so none is left undispositioned.

## Dispositions

**F7 — `cleanup_worktrees_lib.sh` hard-depends on an unsourced function.** Deferred. It does
not block because the wrapper sources the dirt library correctly and every in-repo consumer
is covered; the hazard is for a future consumer that sources the report libraries without the
dirt library and receives rc 127 swallowed by the `|| rc=$?`. Deferred because the remedy —
a `declare -F` guard or a header dependency note — lands in
`scripts/bash/cleanup_worktrees_lib.sh`, which this plan does not modify.

**F8 — apply mode with the flag emits no per-file audit record.** Deferred. It does not
block because AC-17 requires no `DIRTFILE|` in apply mode without the flag and says nothing
about with it, so this is not an acceptance-criteria violation. Deferred because emitting the
captured classification changes apply-mode stdout, which several byte-identity pins compare,
and re-capturing those references is a larger change than this cycle's scope.

**F9 — `rc=$?` departs from the documented max-rc contract.** Deferred. It does not block
because the observable effect is a lower return code being reported in place of a higher one,
never a zero in place of a non-zero, so no failure is hidden. Deferred because the remedy
lands in `scripts/bash/cleanup_worktrees_lib.sh`, which this plan does not modify.

**F10 — aggregate extraction assumes no pipe in the worktree path.** Deferred. It does not
block because the extraction reads field 3 of the `DIRTSUM|` record, which is correct
whenever the worktree path contains no `|`, and a worktree path containing that character is
not observed in any checkout this tool has run against. Deferred as a hardening item.

**F11 — the clear hook fires on any removal failure.** Deferred. It does not block because
the blast radius is bounded: `clear_disposable_dirt` still refuses unless every entry is
disposable, and a worktree with no dirt produces no aggregate and refuses. The finding widens
*when* the clear may run, not *what* it may destroy. Deferred because the remedy is a comment
recording that the hook keys on the return code rather than on a `BLOCKED-DIRTY`
determination.

**F12 — the clear is unscoped and TOCTOU-exposed.** Deferred. It does not block because the
window is short in a single-pass run and the exposure is inherent to using `reset` and
`clean` rather than per-path operations. Deferred because the remedy is one sentence in the
`SKILL.md` `--clear-disposable` description, and this cycle's `SKILL.md` edits were scoped to
the two recorded decisions.

**F13 — three doc/code mismatches.** Deferred. It does not block because all three are
documentation understatements rather than behaviour defects: `SKILL.md` names only `*.csproj`
where the code also accepts `packages.config` and `app.config` and their `*/` forms;
`SKILL.md` omits that detached, `main`, and `bare` registrations are never classified; and
the library header renders two four-field contracts as though they had a fifth field.
Deferred as a documentation-correction batch.

**F14 — detached-HEAD registrations are never classified.** **Split, not wholly deferred.**

Its acceptance-criteria half is **closed by [P1-T11]**, which narrows AC-15 so the criterion
no longer asserts dirt records for registrations `run_report` never classifies. The narrowed
text scopes AC-15 to the non-detached candidate registrations the report classifies and
appends an exclusion clause naming detached, `main`, and `bare` registrations, citing the
`is_detached_candidate` guard that precedes the classification call. This was necessary
because `remediation-inputs.2026-09-08T05-00.md:164` records AC-15 as contradicted by both R2
and F14, so deferring F14 whole would have left half of a recorded contradiction open while
[P8-T10] checked AC-15 off — which rules 1 and 4 of
`.claude/skills/acceptance-criteria-tracking/SKILL.md` prohibit. The other branch of the
remedy, extending classification to detached registrations, was not taken because it would
modify `scripts/bash/cleanup_worktrees_lib.sh`.

Only F14's documentation half remains deferred: the `SKILL.md` omission that detached,
`main`, and `bare` registrations are never classified. That is the same gap F13's second
clause records, and it is deferred alongside F13 for that reason.

## The `cleanup_worktrees_lib.sh` constraint

F7 and F9 both target `scripts/bash/cleanup_worktrees_lib.sh`. That file is at **496** of 500
lines and this plan does not modify it; the figure was measured at [P0-T8] and re-measured
unchanged at [P8-T4]. Acting on either finding therefore requires the extraction contingency
recorded in the `## Risks & Mitigations` bullet of `spec.md` that begins
``Fan-in on `cleanup_worktrees_lib.sh` is mitigated by``: extract `run_report` into a new
`cleanup_worktrees_report_lib.sh` as a separate, behaviour-preserving move commit, then apply
the change's hunks to the new file.

F14's deferred documentation half also touches that area conceptually but lands in `SKILL.md`
rather than in the library, so it carries no line-budget cost.

## Recommended follow-up

A single follow-up issue covering F7 through F13 and F14's documentation half. The
`cleanup_worktrees_report_lib.sh` extraction should be the first task in that issue, because
F7 and F9 cannot be actioned before it.

Output Summary: All eight advisory findings F7 through F14 carry a disposition. Seven are
deferred whole; F14 is split, with its acceptance-criteria half closed by [P1-T11] in this
cycle and only its documentation half deferred. F7 and F9 are blocked on the extraction
contingency because their target file is at 496 of 500 lines.
