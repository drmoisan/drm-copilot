# Remediation Cycle 1 — Completion Summary

Timestamp: 2026-08-09T09-20

Task: [P7-T13]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442 (issue #442)
Branch: `feature/parallel-mutation-protocol-442`
Plan: `<FEATURE>/remediation-plan.2026-08-09T00-19.md`, 80 tasks across Phases 0-7, all executed in order
Diff bases: `a9e2463c` (what this cycle changed) and `c939b5b8` (whole-branch confinement)

## 1. Per-Finding Disposition (from [P6-T8])

| Finding | Class | Disposition |
| --- | --- | --- |
| R1 / B1 / D1 — admission ignored not-yet-launched current-cohort members | **Blocking** | **RESOLVED IN CODE** |
| C2 (preflight-identified, adjudicated) — recolor dropped the pinned CONSTRAINT with the pinned VERTICES | **Blocking (adjudicated)** | **RESOLVED IN CODE** |
| R2 / P1 — F3 op-classification tuples copied without a binding assertion | Partial | **RESOLVED** (imports + 4 binding tests, guard verified to fire) |
| R3 / P2 — FR9 invariant 3 narrower than its spec/AC wording | Partial | **RESOLVED** (documentation only; S9 now PASS) |
| R4 / P3 — Python/TypeScript parity gap | Partial | **DEFERRED** with recorded, verified rationale; no `extensions/drm-copilot/src/` file modified |
| R5 / P4 — unauthorized `# noqa: S311` | Partial | **RESOLVED** (per-file authorization; suppressions deleted) |
| R6 / P5 — `# noqa: S603` rationale on an inert line | Partial | **RESOLVED** (measured 95-char arithmetic recorded) |

## 2. Fail-Before and Pass-After Exit Codes

| Demonstration | Fail-before | Pass-after |
| --- | --- | --- |
| **C1** (admission cohort independence) | **EXIT_CODE: 1**, observed `AdmissionOutcome.ADMIT_CURRENT_COHORT`, `AssertionError` | **EXIT_CODE: 0** (43 passed) |
| **C2** (recolor pinned-barrier offset) | **EXIT_CODE: 1**, observed `cohort_assignments == {200: 0, 300: 0}` so `[300] == 0`, `AssertionError` | **EXIT_CODE: 0** (43 passed) |
| Whole-suite isolation with both red | **EXIT_CODE: 1**, exactly two failing ids, `2 failed, 3386 passed` | n/a |

Both failures were `AssertionError` rather than `TypeError`, so both are behavioral demonstrations
against the shipped implementation. Property P4 additionally **rejects all three reversions** by
execution: in-flight-only rule (`9 failed`), removed offset (`6 failed`), unconditional offset
(`3 failed`), with the engine restored and no mutation residue.

## 3. Numeric Coverage and Threshold Verdicts (from [P7-T8])

| Language | Metric | Baseline | Post-change | Delta | Floor | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| Python | Line | 92.04855624191926% | **92.04912734324499%** | **+0.00057 pp** | >= 85% | **PASS** |
| Python | Branch | 84.18586489652479% | **84.19203747072599%** | **+0.00617 pp** | >= 75% | **PASS** |
| Python | Changed/new code | n/a | **100% line, 100% branch** on all 7 F6 modules | n/a | no regression | **PASS** |
| PowerShell | Line (aggregate) | 94.3362% | **94.3362%** | 0.0000 pp | >= 85% | **PASS** |
| PowerShell | Feature hook line | 86.96% | **86.96%** | 0.0000 pp | >= 85% | **PASS** |
| PowerShell | Branch | not produced by Pester | not produced | n/a | n/a | **N/A** (toolchain emits no branch counter) |

**Both Python coverage axes increased. No coverage regression on either language.**

## 4. Per-File Line Counts and Budgets (from [P7-T9])

Every touched and new file is **`<= 500` lines**; the cap is not relaxed anywhere. Highest values:
`test_parallel_mutation_protocol_properties.py` **500**, `test_parallel_mutation_protocol_ops.py`
**500** (byte-unchanged), `parallel_mutation_protocol.py` **499**,
`test_parallel_mutation_contention_properties.py` **493**. Nine of twelve budgeted files are within
their planning budget; three exceeded it and a fifth test module was added, each recorded with
justification in [P7-T9] and the scenario inventory.

## 5. Confinement Verdicts A-K (from [P7-T10])

| Check | Base | Verdict |
| --- | --- | --- |
| A — no epic or `.claude/rules/**` contention | `c939b5b8` | **PASS** |
| B — orchestrate SKILL in-section confinement (all 7 hunks inside F6) | `c939b5b8` / `a9e2463c` | **PASS** |
| C — validator: `2 0`, F7 seam byte-identical | `c939b5b8` | **PASS** |
| D — settings: `4 0` | `c939b5b8` | **PASS** |
| E — no schema or enum growth (empty diff) | `a9e2463c` | **PASS** |
| F — config confined, `poetry.lock` empty | `c939b5b8` | **PASS** (4 lines, not 3 — deviation recorded) |
| G — base plan **byte-identical** (empty diff) | `a9e2463c` | **PASS** |
| H — bundle parity, all three mirrors identical | none | **PASS** |
| I — ops test module byte-unchanged (empty diff) | `a9e2463c` | **PASS** |
| J — F2 untouched (empty diff) | `c939b5b8` | **PASS** |
| K — `POPULATED_RESERVED_HEADINGS` one declaration, single-element tuple | `a9e2463c` | **PASS** |

## 6. AC Verdicts (from [P7-T11])

Counts preserved at exactly **15** (`spec.md` S1-S15) and **9** (`user-story.md` U1-U9), with no
addition, removal, reordering, or renumbering. The only criteria whose TEXT changed are **S2, S5, S9,
U1, U5** — exactly the five the plan authorizes. All five evaluate **PASS** against their amended text
with cited executed evidence, and every `[x]` marker is honest; no marker required correction. The
previously PARTIAL **S9 now evaluates PASS** because the spec text was amended to describe the delivered
two-signal formalization. Executor re-evaluation: **24 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED.**

## 7. Closure Statement (from [P7-T12])

The guarantee **"no two items assigned to the same cohort share a conflict edge, including edges to
pinned items"** now holds after any admission decision and any recolor, for the inputs the engine is
given. It rests on 17 cited executed results across four legs: the admit branch, the defer branch,
F2-guaranteed independence preserved by the uniform injective offset, and the consumer merge obligation
proven both sufficient and necessary against the landed F3 validator. The only residual is the
pre-existing caller-side cache-doctrine obligation, already documented in `spec.md` § Constraints & Risks
item 4 and enforced by `.claude/skills/parallel-add/SKILL.md`; no potential entry was created for it.

## 8. Toolchain Status — All Stages Green in a Single Pass

| Stage | Command | Result |
| --- | --- | --- |
| Python format | `poetry run black .` | **0** — `393 files left unchanged` |
| Python lint | `poetry run ruff check .` | **0** — `All checks passed!` |
| Python type-check | `poetry run pyright` | **0** — `0 errors, 0 warnings, 0 informations` |
| Python test + coverage | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | **0** — **3407 passed, 0 failed** |
| PowerShell format | `mcp__drm-copilot__run_poshqc_format` | **0** — no PowerShell file changed |
| PowerShell analyze | `mcp__drm-copilot__run_poshqc_analyze` | **0** — zero findings |
| PowerShell test | `mcp__drm-copilot__run_poshqc_test` | **1** — 2043 passed / **1 pre-existing** / 9 skipped |
| Contract / schema | landed contract suites ([P5-T8]) | **0** — 45 passed |
| Architecture boundary | n/a — zero changed TypeScript or C# files | N/A |

No stage failed and no stage changed a file on its final pass, so **no toolchain-loop restart was
required**.

## 9. Pre-Existing Pester Failure — Unchanged and Unedited

`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, case "allows gh pr create --body-file
artifacts/pr_body_12.md when context exists" (`:142`), `Expected: 'allow' But was: 'deny'`. The hook
reads the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam
while an orchestrated run is live. **Byte-identical in identity, assertion site, and message to the
Phase 0 baseline. It remains the ONLY PowerShell failure. It was not fixed and not edited.** No other
Pester failure occurred, so nothing is attributable to this cycle.

## 10. Recorded Deviations

1. **[P3-T8] documentation status** — recorded `PENDING-PHASE-5` for the four stale documented call
   shapes rather than the required `MIGRATED`, because the tasks that migrate them are Phase 5 tasks and
   phase ordering is binding. Discharged by [P5-T7].
2. **A fifth test module** — `test_parallel_mutation_pin_stability_properties.py` (286 lines) created to
   hold the relocated P3 property, because the contention module carrying P4, the admission property,
   the generator, AND P3 measured 584 lines, 84 over the absolute 500-line cap. Applies the plan's own
   self-contained-generator principle. No test dropped or weakened.
3. **Three planning budgets exceeded** — admission module 220 vs 200, contention module 493 vs 400,
   binding module 326 vs 260. All under the absolute 500-line cap.
4. **[P6-T4] added four lines, not three** — a third `= ["S311"]` entry for the fifth property module,
   confined to the same `[tool.ruff.lint.per-file-ignores]` table.
5. **[P4-T12] fourth disposition** — `test_admission_defers_exactly_when_a_pinned_neighbour_exists` is
   recorded as `corrected (renamed)` rather than one of the three authorized `replaced` entries, because
   [P4-T7] explicitly directs that it be moved AND corrected, and the corrected predicate makes the old
   name false.

Each deviation preserves every absolute policy constraint and every plan-mandated test; none weakens an
assertion or drops a scenario.

## Exit Gate Statement

**Blocking count: 0.**

- Both design corrections are **remediated in code**, each with genuine behavioral fail-before evidence
  (`EXIT_CODE: 1`, `AssertionError`) and pass-after evidence (`EXIT_CODE: 0`), plus property P4 which
  provably rejects the in-flight-only rule, a removed offset, and an unconditional offset.
- Every Partial finding is either resolved by a named task (R2, R3, R5, R6) or deferred with a recorded,
  verified rationale (R4).
- All executed toolchain stages are green in a single pass for both languages.
- Coverage is at or above both the no-regression figures and the policy thresholds, and **increased** on
  both Python axes.
- `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` is **byte-unchanged** at exactly 500
  lines.
- The fully-executed base plan `<FEATURE>/plan.md` is **byte-identical** to `a9e2463c`.
- The single pre-existing Pester failure is **unchanged and unedited** and remains the only PowerShell
  failure.
- All 80 plan tasks are executed and checked off in order.

**The remediation cycle's exit condition is satisfied.**
