# Remediation Cycle 1 — Consolidated Finding Disposition

Timestamp: 2026-08-09T08-50

Task: [P6-T8]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Remediation cycle: 1

## Disposition Table

| Finding | Class | Disposition | Resolving tasks / rationale |
| --- | --- | --- | --- |
| **R1 / B1 / D1** — admission into the current cohort ignores not-yet-launched cohort members | **Blocking** | **RESOLVED IN CODE** | Spec and AC amendment (P1-T1, P1-T3, P1-T4, P1-T6, P1-T8, P1-T11, P1-T13); `decide_admission` signature and logic change adding required keyword-only `current_cohort_members` (P3-T1); docstring corrections (P3-T2, P3-T10); consumer updates (P5-T1, P5-T3); fail-before / pass-after regression evidence (P2-T1, P2-T2, P4-T1, P4-T13); composed contention property P4 (P4-T8); AC re-verification (P7-T11) |
| **C2** (preflight-identified, adjudicated in scope) — `recolor_unstarted` drops the pinned CONSTRAINT with the pinned VERTICES | **Blocking (adjudicated)** | **RESOLVED IN CODE** | Spec and AC amendment (P1-T2, P1-T3, P1-T5, P1-T7, P1-T9, P1-T12, P1-T13); `recolor_unstarted` signature, pinned-barrier offset, and negative-`current_cohort` guard (P3-T3); comment and docstring corrections (P3-T4, P3-T5, P3-T6, P3-T7); consumer updates (P5-T1, P5-T2, P5-T3); fail-before / pass-after regression evidence (P2-T3, P2-T4, P4-T3, P4-T13); offset scenarios (P4-T5); property P4 (P4-T8); F3-invariant binding module (P4-T11); closure statement (P7-T12) |
| **R2 / P1** — F3 op-classification tuples copied without a binding assertion | Partial | **RESOLVED** | Local `ITEM_SCOPED_OPS`, `OPS_WITH_NULL_PRIOR_STATE`, and `OPS_WITH_NULL_NEW_STATE` deleted from both F6 modules and replaced by imports of F3's `OPS_REQUIRING_ITEM_KEY`, `OPS_REQUIRING_NULL_PRIOR_STATE`, and `OPS_REQUIRING_NULL_NEW_STATE` (P6-T1, P6-T2); four binding tests added, three asserting object IDENTITY (`is`) rather than equality and one parametrized guard asserting the three local names are ABSENT from both modules (P6-T3). The guard was verified to fire: reintroducing `ITEM_SCOPED_OPS` produced `1 failed`. |
| **R3 / P2** — FR9 invariant 3 narrower than its spec/AC wording (AC S9 PARTIAL) | Partial | **RESOLVED** (documentation only, no code change) | `spec.md` FR9 invariant 3 and AC S9 amended to describe the delivered two-signal formalization, citing the module docstring at `_parallel_orchestrator_state_mode_completion.py:16-43` and recording that F3's own invariant 20 under `require_complete` guards closed-mode completion and is deliberately not duplicated (P1-T10); S9 re-verified against the amended text (P7-T11) |
| **R4 / P3** — Python/TypeScript parity gap for the three FR9 invariants | Partial | **DEFERRED with recorded rationale** | `docs/features/potential/2026-08-09-parallel-f6-typescript-parity-gap.md` created, plus evidence artifact `remediation1-typescript-parity-deferral.md` (P6-T7). Three verified reasons: no AC required a port; F6 has no TypeScript seam of its own (the only comment-delimited seam is F7's, which F6 must not touch); the rule file's parity claim is scoped to F3's invariants 1-21 and F6 may not amend `.claude/rules/**`. **No file under `extensions/drm-copilot/src/` is modified**, verified by an empty `git status --porcelain` for that path. No TypeScript task exists in this plan. |
| **R5 / P4** — unauthorized `# noqa: S311` suppression | Partial | **RESOLVED** | S311 authorized through a confined `[tool.ruff.lint.per-file-ignores]` addition in `pyproject.toml`, with a comment citing `.claude/rules/general-unit-test.md` § Determinism Infrastructure and `spec.md` § Constraints & Risks item 2 (P6-T4); the `# noqa: S311` comment deleted and replaced by a plain non-directive comment (P6-T5). `grep -rn "noqa: S311" --include=*.py .` now exits 1 with no match; `poetry run ruff check .` exits 0. `git diff c939b5b8 -- poetry.lock` is empty, so no dependency changed. |
| **R6 / P5** — `# noqa: S603` rationale on an inert line | Partial | **RESOLVED** | The inert directive-shaped comment deleted; a non-directive rationale placed on the two lines immediately above the effective single-line suppression, which is retained verbatim (P6-T6). The format deviation is recorded with measured arithmetic: the composed verbatim line is **95 characters**, above the 88-character limit, and the two replacement lines measure **74** and **72**; shortening further would require renaming the `subprocess` import path that the CLI test monkeypatches as `cli.subprocess.run`. Exactly one `# noqa` token remains, on the violating line. |

## Resulting Blocking Count

**Blocking count: 0.**

Both Blocking items — R1/B1/D1 and the adjudicated C2 — are **resolved in code**, each with a
genuine behavioral fail-before demonstration (`EXIT_CODE: 1`, `AssertionError` rather than
`TypeError`) and a pass-after demonstration (`EXIT_CODE: 0`), plus a property that provably rejects
every reversion. All four remaining Partial findings that called for action (R2, R3, R5, R6) are
resolved; R4 is deferred with a recorded, verified rationale and is not a merge gate.

## No `docs/features/potential/` Entry Was Created for the C2 Gap

Revision 1 of the remediation plan had planned a `docs/features/potential/` entry
(`2026-08-09-parallel-recolor-pinned-edge-visibility.md`) for the C2 observation. That entry was
**NOT created**, and the task that would have created it was deleted from the plan, because the gap
was **closed in code** in this cycle as correction C2 rather than deferred. Deferring a defect that
has been fixed would misrepresent the branch state.

The **only** `docs/features/potential/` entry this cycle creates is the R4 TypeScript-parity
deferral at `docs/features/potential/2026-08-09-parallel-f6-typescript-parity-gap.md`.

## Residual Gap Assessment

Restated in substance from the remediation plan's `## Residual Gap Assessment`:

After C1 and C2, **no residual gap remains that is distinct from the pre-existing, already-recorded
caller-side obligation.** The engine's guarantee is complete for the inputs it is given, on four
legs:

- the admit branch cannot place a candidate in a cohort with a conflicting member, pinned or
  unstarted (C1);
- the defer branch cannot place any unstarted item in the pinned items' cohort when a
  candidate-to-pinned edge exists (C2);
- within the unstarted set, independence is F2's guarantee, preserved exactly by the uniform offset,
  whose injectivity keeps F2's distinct color classes on distinct indices;
- the consumer write path cannot produce a duplicate current-generation cohort index when the offset
  is not applied, because the single-entry-per-index merge obligation is stated in the consumer
  instructions ([P5-T1], [P5-T2], [P5-T3]) and [P4-T11] proves that obligation both SUFFICIENT (four
  positive cases validate with zero errors) and NECESSARY (the negative case, writing two entries at
  `current_cohort`, produces a duplicate-index error).

The **only** remaining way to co-schedule conflicting work is for a CALLER to supply an untrue
`current_cohort_members`, `in_flight`, or `current_cohort` value — for example by reading a stale
checkpoint instead of re-deriving durable state. That is **not a new residual and not a gap in the
engine**: a pure function cannot verify the truth of its own arguments. It is the cache-doctrine
obligation already recorded in `<FEATURE>/spec.md` § Constraints & Risks item 4 and already enforced
by the mandatory re-derivation step in `.claude/skills/parallel-add/SKILL.md`
§ Re-Derive Durable State Before Applying Anything. [P5-T1], [P5-T2], and [P5-T3] additionally add
the explicit caller obligation to write the returned indices verbatim and to derive both new
arguments from re-verified durable state.

## Advisory Items — Not Remediated, Not Merge Gates

A1 (zero commits at audit time; since resolved by commit `a9e2463c`), A2, A3, A4, A5, A6, A7, A8, A9
are recorded in `<FEATURE>/remediation-inputs.2026-08-09T00-19.md` and are not remediated by this
cycle.

## Explicitly Out of Scope

`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, case "allows gh pr create
--body-file artifacts/pr_body_12.md when context exists" (`:142`). Pre-existing, environment-driven,
not in the branch diff, fails identically at baseline. Not fixed, not edited, and must remain the
only PowerShell failure.
