# Fail-Before / Pass-After Correlation — Kickoff Producer/Consumer Seam

Timestamp: 2026-08-08T15-25

Task: [P5-T4]

This record links the [P0-T10] fail-before reproduction to the [P5-T1] and [P5-T2] pass-after runs and names which correction removed each error. All three runs use the same command shape, the same substitution values, and the same producer file; only the producer's and consumer's corrected state differ.

## Fail-Before

- Artifact: `docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/regression-testing/kickoff-seam-fail-before.2026-08-08T15-25.md`
- Task: [P0-T10] `[expect-fail]`
- Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-kickoff artifacts/orchestration/parallel-kickoff-remediation-verification.md`
- EXIT_CODE: 1
- Error 1 (verbatim): `Parallel kickoff invocation must structurally name the manifest, plan-home branch, and atomic-execution resume boundary.`
- Error 2 (verbatim): `Parallel kickoff integrity line is invalid: parallel/bugfix-batch-plan head commit: 4a7f1c9e2b8d3a6f0c5e91b47d28a3f6c0e5b91d`

## Pass-After

| Artifact | Task | Command target | EXIT_CODE | Error lines |
|---|---|---|---|---|
| `.../evidence/regression-testing/kickoff-cli-e2e-with-integrity.2026-08-08T15-25.md` | [P5-T1] | `artifacts/orchestration/parallel-kickoff-remediation-verification.md` | 0 | 0 |
| `.../evidence/regression-testing/kickoff-cli-e2e-no-integrity.2026-08-08T15-25.md` | [P5-T2] | `artifacts/orchestration/parallel-kickoff-remediation-verification-no-integrity.md` | 0 | 0 |

## Which Correction Removed Each Error

| Fail-before error | Finding | Removed by | Correction direction |
|---|---|---|---|
| `Parallel kickoff invocation must structurally name the manifest, plan-home branch, and atomic-execution resume boundary.` | B1 | [P1-T1] (Python `RESUME_RE`) and [P1-T2] (TypeScript `RESUME_RE`) | The MATCHER was corrected. `spec.md:451` states the R5 requirement as "each item", so the template's `Each item` was spec-conformant and the narrower alternation was the deviation. The alternation widened from `(?:Every item\|items)` to `(?:Every item\|Each item\|items)` in both runtimes. |
| `Parallel kickoff integrity line is invalid: parallel/bugfix-batch-plan head commit: <hex>` | B2 | [P2-T1] (`.claude/skills/parallel-plan/SKILL.md` template line), mirrored by [P2-T3] | The TEMPLATE was corrected. `spec.md:459` fixes the field NAME as `planning_commit`; only its semantics generalize to the head commit of `parallel/<slug>-plan`. `INTEGRITY_COMMIT_RE` was NOT widened. The landed test at `extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact-tables.test.ts:248`, which already asserts `planning_commit` is accepted, independently confirms the template was the side in error. |

The two corrections deliberately pull in opposite directions. Each follows the governing spec text for its own element; neither was moved to the other side for the sake of a uniform fix.

## Isolation Provided by the Two Pass-After Runs

- [P5-T1] retains the `## Integrity` section, so it exercises both corrections together and proves both errors are gone.
- [P5-T2] removes the `## Integrity` section, so the B2 defect cannot fire at all. A clean exit there isolates the B1 correction, proving the resume-boundary error was removed by the matcher change rather than masked by any integrity-side effect.

## Regression Locks

- B1 is regression-locked by the three-alternant parametrized tests plus the `Each entry` negative case in `tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py` ([P3-T7]) and `extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam.test.ts` ([P4-T8]).
- B2 is regression-locked by the provenance-capture tests `test_rendered_template_captures_planning_commit` ([P3-T6]) and `captures planningCommit from the rendered integrity section` ([P4-T7]), which assert the concrete 40-hex value rather than mere non-nullness.
- Both are regression-locked end to end by the with- and without-`## Integrity` seam tests in each runtime, which validate the real producer text rather than a fixture copy.
