# F5 — Reserved Human Decision

Timestamp: 2026-08-26T00-00

Command: not applicable (record, not a command step)

EXIT_CODE: 0

Output Summary: Two open questions are recorded below with their file-and-line evidence. This
change selected neither value, inferred neither value, and narrowed neither option set. No
coverage threshold value and no toolchain stage count was altered anywhere by this change,
verified by `[P4-T5]` at exit code 0 over 37 tracked files. `AGENTS.md` was not written. No
file under `.github/instructions/` was written. The first `spec.md` acceptance criterion under
`### F5 — decision half`, at spec line 644, remains unchecked at delivery.

## Question 1 — which coverage floor is authoritative, and with which denominator

Two statements are in the repository simultaneously.

Statement A — `AGENTS.md` lines 117-118, under `## Coverage Requirements` (heading at line 115):

- Line 117: `- **Repository-wide line coverage must remain >= 80%.**`
- Line 118: `- **Any new module, class, or method must target >= 90% coverage.**`

The denominator attached to Statement A is repository-wide, and it carries a 90% new-module
companion target.

Statement B — `.claude/rules/general-unit-test.md` lines 23-24, under `## Coverage
Requirements`:

- Line 23: `- **Line coverage must remain >= 85% across all tiers (T1-T4).**`
- Line 24: `- **Branch coverage must remain >= 75% across all tiers (T1-T4) for languages whose
  coverage tooling measures branch coverage.**`

Statement B is restated in `.claude/rules/quality-tiers.md` lines 33-34 (`- Line coverage: >=
85%.` and `- Branch coverage: >= 75% ...`) and in that file's rationale paragraph at line 51.
The denominator attached to Statement B is the per-tier full production denominator, governed
by the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`, and it carries a 75%
branch companion.

The open question is which of the two statements is authoritative, together with the
denominator that attaches to it. This change does not answer it.

## Question 2 — which toolchain loop is authoritative

Two statements are in the repository simultaneously.

Statement A — `AGENTS.md` lines 44-51, under `## Mandatory Toolchain Loop` (heading at line
42). Lines 46-49 enumerate four numbered steps (Formatting, Linting, Type checking, Testing),
and line 51 reads `**Restart from step 1** if any step fails or auto-fixes any files. Do not
stop the loop until all four steps complete without errors in a single pass.`

Statement B — `.claude/rules/general-code-change.md` lines 31-43, under `## Mandatory Toolchain
Loop` (heading at line 31). Line 33 reads `Run the full seven-stage toolchain in this exact
order and repeat until all stages pass in a single pass:`, and line 43 reads `**Restart from
step 1** if any stage fails or auto-fixes any files. Do not stop the loop until all seven
stages complete without errors in a single pass.`

The open question is which of the two loops is authoritative. This change does not answer it.

## What this change did and did not do

Did:

- Replaced the four duplicated tone-policy bullets in `CLAUDE.md` with a single-line pointer to
  `.claude/rules/tonality.md` (`[P4-T1]`). That is the mechanical half of F5 and touches no
  threshold and no stage count.
- Ran the invariance guard `[P4-T5]` at exit code 0 over the enumerated set of files known to
  state a coverage threshold or a toolchain stage count, including `AGENTS.md` and every
  tracked file under `.github/instructions/`.
- Recorded the decision as a `human_interaction.requirements[]` entry with `response: "halt"`
  in `artifacts/orchestration/orchestrator-state.json` (`[P4-T7]`). Per the human-interaction
  invariants in `.claude/rules/orchestrator-state.md`, a `halt` requirement carries no
  `runbook_path`.

Did not:

- Select, infer, narrow, or rank either option set.
- Characterize any option as obvious, likely, preferable, safer, or correct.
- Write `AGENTS.md`.
- Write any file under `.github/instructions/`.
- Change any coverage threshold value or any toolchain stage count in any file.

## Note on a prior ruling recorded against issue 559

A maintainer ruling was issued on issue 559 stating a resolution for both questions. That
ruling was written on the belief that the contradicting statements live in `CLAUDE.md`. This
feature's preparation research established that they do not: `CLAUDE.md` is 59 lines before
this change and carries no coverage figure and no toolchain loop. The contradicting statements
are at the `AGENTS.md` and `.claude/rules/` locations cited above, and `AGENTS.md` is outside
this item's declared blast radius. The questions are therefore recorded here as open rather
than treated as resolved, and no value was applied. This note states where the statements are
and what this item's radius covers; it takes no position on either question.

## Disposition of the two `spec.md` criteria under `### F5 — decision half`

- `spec.md` line 644 — the BLOCKED coverage-floor and toolchain-stage-count selection.
  **Remains unchecked at delivery.** That is the expected and correct outcome, not a delivery
  failure.
- `spec.md` line 652 — the `human_interaction` halt-entry criterion. Delivered by `[P4-T7]`.
