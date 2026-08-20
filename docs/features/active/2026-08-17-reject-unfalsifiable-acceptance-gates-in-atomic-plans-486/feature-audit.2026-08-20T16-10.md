# Feature Audit: reject-unfalsifiable-acceptance-gates-in-atomic-plans (Issue #486) — Remediation Cycle 1 Reaudit

- **Audit Date:** 2026-08-20 (session timestamp `2026-08-20T16-10`)
- **Auditor:** feature-review agent (delegated session)
- **Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` (the `feature-audit-template` selector's backing file; this session's tool set does not include the MCP server tools, so the asset was read directly from the bundled path).

## Scope and Baseline

- **Branch:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` @ `9e5c141d863f4255a32656d1d58233ae0a8d3255`
- **Resolved base branch:** `main` (supplied by the caller; merge-base `8092d391f50c44571145c73e161bbd1dafe0f035`, confirmed by regenerating the PR-context artifacts this session)
- **Diff scope:** full branch diff `8092d391..9e5c141d` — 89 files, +8695/-21, 4 commits
- **Work mode:** `full-feature` (persisted `- Work Mode: full-feature` marker in `issue.md`), so the authoritative acceptance-criteria sources are `spec.md` **and** `user-story.md`
- **Prior cycle:** cycle-1 audit `feature-audit.2026-08-20T14-09.md`; remediation delivered by commit `9e5c141d` against `remediation-plan.2026-08-20T14-09.md` (findings R1-R4)
- **Evidence sources:** regenerated `artifacts/pr_context.summary.txt` / `artifacts/pr_context.appendix.txt`; the committed `<FEATURE>/evidence/` tree; independent toolchain, coverage, and probe runs this session (recorded in `policy-audit.2026-08-20T16-10.md` Appendix B)

## Acceptance Criteria Inventory

### Acceptance criteria (spec.md, 12 items)

AC1 (G5 two-condition form), AC2 (G1 dotted remedy), AC3 (no-finding byte identity), AC4 (automatic invocation, no surface growth), AC5 (task attribution), AC6 (Warnings do not fail the gate), AC7 (G5 severity fixed by measurement, two-conjunct form), AC8 (G6 is a Warning), AC9 (parity including the quote-selection class), AC10 (graceful degradation), AC11 (reusable extractor seam), AC12 (PowerShell hook untouched). All twelve are checked `[x]` in `spec.md` at head.

### Acceptance criteria (user-story.md, 6 items)

AC-U1 (absent-literal reporting and plan-quotation exoneration), AC-U2 (`.py` path `--cov` rejection with dotted remedy), AC-U3 (existing mandatory validator call, no schema change), AC-U4 (task-identifier prefix; unattributable commands unreported), AC-U5 (advisory findings accepted, surfaced), AC-U6 (no-finding byte identity). All six are checked `[x]` in `user-story.md` at head.

### Supporting checklists

`spec.md` Definition of Done (8 items) and Seeded Test Conditions (3 items) are all checked at head. The cycle-1 remediation-required items among them (DoD 1-2, seeded item 2) were checked by the remediation commit with test/evidence names recorded.

## Acceptance Criteria Evaluation

| Criterion | Verdict | Evidence |
|---|---|---|
| AC1 (G5 two-condition form) | PASS | Named finding and exoneration tests per runtime (`test_plan_gate_discrimination_literals.py`; `plan-gate-discrimination-literals.test.ts`) with stub git adapters; suites pass this session. |
| AC2 (G1 dotted remedy) | PASS | Named context-free test per runtime; message carries `scripts.dev_tools.foo`-form remedy without `.py`; verified in suites this session. |
| AC3 (no-finding byte identity) | PASS | `test_structural_errors_match_recorded_baseline_strings` plus clean-plan tests without and with a stub context, per runtime; the seven structural error strings asserted byte-identical against `evidence/baseline/existing-plan-error-strings.2026-08-20T11-40.md`. |
| AC4 (automatic invocation, no surface growth) | PASS | Dispatch tests per runtime (`test_plan_route_reports_g1_without_new_flag`; TS equivalents) plus MCP input-schema property-key-set assertions; CLI subparser gains only `--workspace-root`. |
| AC5 (task attribution) | PASS | Four attribution-boundary tests per runtime (preamble, phase preamble, intervening heading, prefix presence); every finding string this session begins with `[P#-T#]`. |
| AC6 (Warnings do not fail the gate) | PASS | CLI test asserting exit 0 + unchanged success line + stderr prefix; MCP service-call tests asserting no throw and the `warnings` field; live CLI run this session on `plan.2026-08-17T15-00.md` produced 2 warnings and exit 0. |
| AC7 (G5 severity, two-conjunct form) | PASS | Two-conjunct wording present in AC7 and the pre-declared rule paragraph; deviation note at spec line 68 citing `[P5-T3]` and the measurement artifact; `G5_SEVERITY == "warning"` in both runtimes (verified by grep this session); measurement artifact `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md` records 166 plans / 100 candidates / 0 findings. Closes cycle-1 R2. |
| AC8 (G6 is a Warning) | PASS | Named stub-file-reader tests per runtime; combined-plan test additionally asserts G6 on the warnings channel with exit 0. |
| AC9 (parity, quote-selection class) | PASS | Paired parity tests assert identical expected strings, including apostrophe-bearing `--cov` value and search literal; no-`repr`/`!r`/`pythonRepr` assertions pass; `G5_SEVERITY` constants cross-checked. Note: parity is defined over finding strings and holds; the R5 behavioral divergence below is outside the fixture set's input class. |
| AC10 (graceful degradation) | **PARTIAL** | The two named tests per runtime exist and pass, but the criterion's claim "no exception escapes" is falsified for the Python G2/G3 path: a raising git adapter plus a path-separator `--cov` value propagates the exception out of `evaluate_plan_gates` (probe-reproduced this session). The Python guard covers only the G5/G6 literal group; TypeScript guards both paths. Blocking finding R5; remediation enumerated in `remediation-inputs.2026-08-20T16-10.md`. AC10 remains checked `[x]` in `spec.md` from the executor pass; per the acceptance-criteria-tracking protocol this reviewer does not check off non-passing items and records the discrepancy here for reconciliation by the remediation cycle. |
| AC11 (reusable extractor seam) | PASS | Named record-shape tests per runtime assert exactly the field set `task_id`, `source_line`, `raw_span`, `argv`, `kind` and the three `kind` values; extractor importable independently of the rules. |
| AC12 (PowerShell hook untouched) | PASS | `git diff --name-only 8092d391...9e5c141d` contains no `.claude/hooks/validate-planner-output.ps1` (re-verified this session at the current merge-base). |
| AC-U1 | PASS | Maps to spec AC1 (PASS). |
| AC-U2 | PASS | Maps to spec AC2 (PASS). |
| AC-U3 | PASS | Maps to spec AC4 (PASS). |
| AC-U4 | PASS | Maps to spec AC5 (PASS). |
| AC-U5 | PASS | Maps to spec AC6 (PASS). |
| AC-U6 | PASS | Maps to spec AC3 (PASS). |

### Cycle-1 finding closure verification

| Cycle-1 finding | Status | Evidence |
|---|---|---|
| R1 (Blocking) TS changed-line coverage regression | CLOSED | `validate-orchestration-service-call.ts` at 100.00% lines / 89.47% branches (lcov parsed this session; baseline 100.00/84.61); new named combined error-and-warning test present and passing. |
| R2 (Blocking) spec AC7 text defect / reconciliation | CLOSED | Two-conjunct wording in AC7 and rule paragraph; deviation note at spec line 68; AC7, DoD 1-2, plan `[P12-T13]`/`[P12-T14]` checked; constrained files (`G5_SEVERITY`, rule file, measurement artifact) unmodified. |
| R3 (Minor) uncovered added Python line | CLOSED | `test_validate_from_args_returns_blocking_channel_only_for_plan` present; the line no longer appears in the module's uncovered set (remaining misses 72, 406, 408, 410 are the relocated baseline miss set). |
| R4 (Minor) combined three-failure-mode scenario | CLOSED | `test_combined_plan_produces_g1_g5_g6_findings_in_one_evaluation` (Python) and `produces one G1 Blocking finding and two Warnings (G5, G6) in a single combined-plan evaluation` (TypeScript) present and passing; spec seeded-condition item 2 checked with those names. |

## Summary

- 17 of 18 acceptance criteria across the two authoritative sources evaluate PASS; 1 (spec AC10) evaluates PARTIAL on a probe-established defect: the Python graceful-degradation guard omits the G2/G3 coverage path, so a raising repository seam crashes the validation run instead of degrading, and the two runtimes diverge for that input class (TypeScript guards the path). This is new Blocking finding R5.
- All four cycle-1 findings (R1, R2, R3, R4) are verified closed by commit `9e5c141d`.
- Toolchain: all applicable stages green in both runtimes in a single pass this session. Coverage: PASS in both changed languages, repo-wide and per changed file, with the cycle-1 regression resolved.
- Recommendation: **NO-GO** for PR until R5 is remediated (one small production edit mirroring the existing TypeScript guard structure, plus named tests). One Minor advisory (M1, non-zero-exit seam semantics) is recorded in the policy audit and does not block.

## Acceptance Criteria Check-off

Per `acceptance-criteria-tracking`, this reviewer checks off PASS criteria in the authoritative source files and leaves non-passing items unchecked:

- All 12 `spec.md` criteria and all 6 `user-story.md` criteria were already checked `[x]` by the executor and the cycle-1 remediation; no new check-offs were needed for the PASS items.
- **AC10 discrepancy:** AC10 is checked `[x]` in `spec.md` but evaluates PARTIAL in this reaudit. The check-off protocol does not authorize a reviewer to add check marks for non-passing items; it also predates this finding, so the existing mark is left in place and the discrepancy is documented here and in `remediation-inputs.2026-08-20T16-10.md`. Once the R5 guard lands and its named test passes, the checked state becomes accurate without further edits.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md`, `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/user-story.md`
- Total AC items: 18 (12 spec + 6 user-story)
- Checked off (delivered): 18 (all checked in source files; 17 verified PASS by this audit, 1 — spec AC10 — evaluated PARTIAL pending R5 remediation)
- Remaining (unchecked): 0
- Items remaining: none unchecked; outstanding verification gap: spec AC10 (PARTIAL, Blocking finding R5)
