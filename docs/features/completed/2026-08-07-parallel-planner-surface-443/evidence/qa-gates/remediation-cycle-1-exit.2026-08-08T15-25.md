# Remediation Cycle 1 — Exit Record

Timestamp: 2026-08-08T15-25

Task: [P8-T14]
Exit criteria source: `docs/features/active/2026-08-07-parallel-planner-surface-443/remediation-inputs.2026-08-08T14-59.md`, section "Exit Criteria for the Remediation Cycle" (lines 214-243)
Plan: `docs/features/active/2026-08-07-parallel-planner-surface-443/remediation-plan.2026-08-08T15-15.md` (9 phases, 73 tasks, all executed in order)

## Exit Criterion Evaluation

### Criterion 1 — Rendered template validates with an empty error list in BOTH runtimes, with and without `## Integrity`

Verdict: **MET**

| Runtime | With `## Integrity` | Without `## Integrity` |
|---|---|---|
| Python (`scripts/dev_tools/parallel_kickoff_contract.py`) | `test_rendered_template_with_integrity_validates_clean` asserts `== []` ([P3-T4]) | `test_rendered_template_without_integrity_validates_clean` asserts `== []` ([P3-T5]) |
| TypeScript (`extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts`) | `validates the rendered template with the ## Integrity section` asserts `toEqual([])` ([P4-T5]) | `validates the rendered template without the ## Integrity section` asserts `toEqual([])` ([P4-T6]) |

Additionally verified end-to-end through the delivered `artifact_type: "parallel-kickoff"` CLI:

- `evidence/regression-testing/kickoff-cli-e2e-with-integrity.2026-08-08T15-25.md` — EXIT_CODE 0, zero error lines.
- `evidence/regression-testing/kickoff-cli-e2e-no-integrity.2026-08-08T15-25.md` — EXIT_CODE 0, zero error lines.

Fail-before/pass-after correlation: `evidence/regression-testing/kickoff-seam-fail-before-pass-after.2026-08-08T15-25.md`. The fail-before run ([P0-T10]) exited 1 with exactly two errors; both are now gone.

### Criterion 2 — The R-3 seam test exists in both runtimes and passes

Verdict: **MET**

| Runtime | Module | Result |
|---|---|---|
| Python | `tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py` (378 lines) | 9 passed, EXIT_CODE 0 — `evidence/regression-testing/kickoff-seam-python.2026-08-08T15-25.md` |
| TypeScript | `extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam.test.ts` (299 lines) | 1 suite / 8 tests passed, EXIT_CODE 0 — `evidence/regression-testing/kickoff-seam-typescript.2026-08-08T15-25.md` |

Both modules extract the fenced template from the REAL canonical `.claude/skills/parallel-plan/SKILL.md`, render it with byte-identical substitution constants, and assert an empty error list. Neither spawns an external process.

### Criterion 3 — `cmp` confirms byte identity for both mirrored surfaces

Verdict: **MET**

| Command | EXIT_CODE |
|---|---|
| `cmp .claude/skills/parallel-plan/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` | 0 |
| `cmp .claude/agents/parallel-planner.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md` | 0 |

Both produced zero output. Corroborated by `diff` at [P2-T4] and [P8-T12], and independently by the repository mirror gate `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (7 passed, EXIT_CODE 0), which includes `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Recorded in `evidence/qa-gates/mirror-byte-identity-final.2026-08-08T15-25.md`.

### Criterion 4 — Both R-4 criteria genuinely satisfied and re-checked with the seam test cited, or left unchecked

Verdict: **MET** — both are genuinely satisfied and re-checked with seam-test evidence cited.

Both criteria were first reverted to `- [ ]` in Phase 0 ([P0-T11] at `spec.md:655`, [P0-T12] at `spec.md:689`), then re-checked in Phase 7 ([P7-T1], [P7-T2]) only after B1, B2, and B4 landed. The supporting evidence recorded per criterion in `evidence/other/ac-checkoff.2026-08-08T15-25.md` is validation evidence, not heading-presence evidence:

- Criterion 11 — cites [P3-T4], [P3-T5], [P4-T5], [P4-T6] seam tests and the [P5-T1], [P5-T2] CLI runs.
- Criterion 20 — cites the widened `RESUME_RE`, the three-alternant tests [P3-T7] and [P4-T8] with the `Each entry` negative case, the 49-test contract suite, and the 386-line file-size measurement.

Text preservation verified independently: `evidence/other/ac-text-preservation.2026-08-08T15-25.md` shows the `spec.md` cycle diff nets to zero and the only `user-story.md` change is the [P6-T4] Non-Goals prose line.

### Criterion 5 — Full toolchain passes in a single pass for both languages

Verdict: **MET**

| Stage | Command | EXIT_CODE | Artifact |
|---|---|---|---|
| Black | `poetry run black .` | 0 | `evidence/qa-gates/black-final.2026-08-08T15-25.md` |
| Ruff | `poetry run ruff check .` | 0 | `evidence/qa-gates/ruff-final.2026-08-08T15-25.md` |
| Pyright | `poetry run pyright` | 0 | `evidence/qa-gates/pyright-final.2026-08-08T15-25.md` |
| pytest | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 0 | `evidence/qa-gates/pytest-coverage-final.2026-08-08T15-25.md` |
| Prettier | `npm --prefix extensions/drm-copilot run format` | 0 | `evidence/qa-gates/prettier-final.2026-08-08T15-25.md` |
| ESLint | `npm --prefix extensions/drm-copilot run lint` | 0 | `evidence/qa-gates/eslint-final.2026-08-08T15-25.md` |
| tsc | `npm --prefix extensions/drm-copilot run typecheck` | 0 | `evidence/qa-gates/tsc-final.2026-08-08T15-25.md` |
| Jest | `npm run test:unit:coverage` | 0 | `evidence/qa-gates/jest-coverage-final.2026-08-08T15-25.md` |

All eight stages passed in a single pass. Neither formatter rewrote a file, so the Phase 8 restart condition never fired and no phase restart was required. `package-lock.json` was not modified.

### Criterion 6 — Coverage does not regress below the recorded values; every changed production file at or above 85% line and 75% branch

Verdict: **MET**

| Language | Recorded reference | Post-change | Verdict |
|---|---|---|---|
| Python line | 91.82% | 91.8236% | at reference, no regression |
| Python branch | 83.80% | 83.8000% | at reference, no regression |
| TypeScript line | 97.16% | 97.1663% | above reference |
| TypeScript branch | 89.54% | 89.5560% | above reference |

Changed production files:

| File | Line | Branch | >= 85% / >= 75% |
|---|---|---|---|
| `scripts/dev_tools/parallel_kickoff_contract.py` | 100.00% | 100.00% | PASS |
| `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` | 100.00% | 88.79% | PASS |

The Phase 0 measurement recorded Python branch at 83.8200% rather than 83.8000%. `evidence/qa-gates/coverage-delta.2026-08-08T15-25.md` establishes that the one-branch difference is a timing-dependent loop edge in `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py`, a module outside this cycle's change set, and demonstrates it flipping across five identical repeated runs of unchanged code. The post-change value equals the recorded reference of 83.80% exactly, so criterion 6 is met on its own stated terms.

### Criterion 7 — No protected surface appears in the diff

Verdict: **MET**

`evidence/qa-gates/protected-surface-check.2026-08-08T15-25.md` enumerates all 51 changed paths and confirms zero protected-surface violations and zero name-only matches. Each of the eight paths named in criterion 7, plus `.claude/rules/**`, is absent from the change set.

Per the note at lines 238-243 of the remediation inputs: R-1 was taken via the preferred regex-widening route, touching `scripts/dev_tools/parallel_kickoff_contract.py` and `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts`. Both are F4-owned modules delivered by this feature and neither is a protected surface. `.claude/rules/parallel-orchestration.md` was NOT modified; A-1's suggested addition to it was deferred rather than taken, as recorded in `evidence/other/advisory-disposition.2026-08-08T15-25.md`.

## Overall Verdict

All seven exit criteria are MET. No criterion is NOT MET. The cycle is reported as complete rather than remediation-required.

## Finding Dispositions by Task ID

| Finding | Severity | Disposition | Task IDs |
|---|---|---|---|
| B1 — skill kickoff template fails the resume-boundary check | Blocking | RESOLVED — matcher widened to `(?:Every item\|Each item\|items)` in both runtimes, per `spec.md:451` | [P1-T1], [P1-T2], [P1-T3], [P1-T4], [P1-T5], [P1-T6]; proven by [P0-T10] fail-before and [P5-T1]/[P5-T2] pass-after; regression-locked by [P3-T7], [P4-T8] |
| B2 — `## Integrity` commit field name rejected | Blocking | RESOLVED — template corrected to `planning_commit: <hex>` per `spec.md:459`; `INTEGRITY_COMMIT_RE` deliberately not widened | [P2-T1], [P2-T2], [P2-T3], [P2-T4], [P2-T5], [P2-T6]; proven by [P0-T10] fail-before and [P5-T1] pass-after; regression-locked by [P3-T6], [P4-T7] |
| B3 — unsupported acceptance-criteria check-off | Blocking | RESOLVED — reverted immediately, re-checked only against seam-test and CLI evidence | [P0-T11], [P0-T12] (revert); [P7-T1], [P7-T2], [P7-T3], [P7-T4], [P7-T5] (evidence-supported re-check and reconciliation) |
| B4 — no test binds template to contract | Blocking | RESOLVED — a producer/consumer seam module added in each runtime, reading the real canonical skill file | [P3-T1] through [P3-T10] (Python, 9 tests); [P4-T1] through [P4-T10] (TypeScript, 8 tests) |
| N1 — measurement artifact missing command-step fields | Non-blocking | CORRECTED — `Command:`, `EXIT_CODE:`, `Output Summary:` added against a fresh measurement; original timestamp retained | [P6-T1] |
| N2 — evidence filename lacks the ISO timestamp | Non-blocking | CORRECTED — renamed to `phase0-instructions-read.2026-08-08T13-49.md` using the timestamp already inside the file; rename recorded for traceability | [P6-T2], [P6-T3] |
| N3 — stale two-argument `conflicts(a, b)` reference | Non-blocking | CORRECTED in Non-Goals prose; the second occurrence at `spec.md:645` deliberately left untouched because it sits inside an acceptance criterion | [P6-T4], recorded in [P6-T3] |
| A1 — parity divergences outside the verified scope | Advisory | DEFERRED and recorded — target rule file is protected; the prototype-lookup change is deferred to avoid a new asymmetry with the unchanged epic analogue | [P6-T6] |
| A2 — TypeScript port carries no decision-logic comments | Advisory | TAKEN in comment-only form — a doc-comment note directs readers to the Python modules; zero executable-statement changes | [P6-T5], recorded in [P6-T6] |
| A3 — epic surface supplies no `## Integrity` template precedent | Advisory | DEFERRED and recorded — `epic-plan/SKILL.md` is protected; [P2-T1] establishes the precedent for a later feature to follow | [P6-T6] |

All four Blocking findings are resolved, all three Non-blocking findings are corrected, and all three Advisory findings have an explicit recorded disposition.

## Plan Completion

All 73 tasks across all 9 phases were executed in the order written and are checked off in `docs/features/active/2026-08-07-parallel-planner-surface-443/remediation-plan.2026-08-08T15-15.md`. The base plan `plan.2026-08-07T11-11.md` was not modified.
