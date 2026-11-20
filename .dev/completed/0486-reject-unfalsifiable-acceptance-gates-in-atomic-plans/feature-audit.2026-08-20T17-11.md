# Feature Audit: reject-unfalsifiable-acceptance-gates-in-atomic-plans (#486) — Remediation Cycle 2 Reaudit

**Audit Date:** 2026-08-20
**Feature Folder:** `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486`
**Base Branch:** `main`
**Head Branch:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` @ `450a8f472edff4fa340de3d8d230a407fb8c3e0b`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification (cycle 2)
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` (the backing file of the `feature-audit-template` MCP selector; this session's tool set does not include the MCP server tools, so the asset was read directly from the bundled path). Instruction block removed.

## Scope and Baseline

- **Base branch:** `main` (merge-base `8092d391f50c44571145c73e161bbd1dafe0f035`)
- **Head branch/commit:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` (commit `450a8f472edff4fa340de3d8d230a407fb8c3e0b`)
- **Merge base:** `8092d391f50c44571145c73e161bbd1dafe0f035`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated this session at head `450a8f47`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (regenerated this session)
  - Feature evidence: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/**`
  - Additional evidence: live toolchain, test, coverage, and probe runs by this reviewer this session (see `policy-audit.2026-08-20T17-11.md` Appendix B)
- **Feature folder used:** `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` (single active folder matching the issue number in the branch name)
- **Requirements source:** `spec.md` and `user-story.md` (multiple files)
- **Work mode resolution note:** explicit persisted marker `- Work Mode: full-feature` at `issue.md` line 10; per the work-mode contract, the AC sources are `spec.md` and `user-story.md`.
- **Scope note:** the on-disk PR-context artifacts recorded the prior head `9e5c141d` at session start and were regenerated against `main` before evaluation. Scope is the full branch diff, not the cycle-2 delta alone; cycle-2 changes were additionally inspected commit-wise (`git show 450a8f47`).

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — primary source (12 criteria, AC1-AC12, checkbox format, all currently `[x]`)
- `user-story.md` — co-equal source under `full-feature` (6 criteria, AC-U1-AC-U6, checkbox format, all currently `[x]`)

### Acceptance criteria

Spec (`spec.md` lines 188-199), abbreviated titles; full text preserved in the source file:

1. AC1 (G5, two-condition form) — G5 finding on tree-absent + plan-absent literal; exoneration when plan-quoted.
2. AC2 (G1) — `--cov=scripts/dev_tools/foo.py` produces a Blocking finding with the dotted remedy, no `.py` in the remedy clause.
3. AC3 (no-finding byte identity) — clean-plan outputs and the seven structural error strings unchanged, with and without a context.
4. AC4 (automatic invocation, no surface growth) — existing `plan` route, no new flag/artifact type, MCP input-schema key set unchanged.
5. AC5 (task attribution) — every finding prefixed `[P#-T#]`; preamble/phase-preamble/post-heading commands produce no finding.
6. AC6 (Warnings do not fail the gate) — warning-only plan: exit 0, success line, no MCP throw, warnings surfaced.
7. AC7 (G5 severity fixed by measurement, two-conjunct form) — measurement artifact recorded; `G5_SEVERITY` is Warning per the pre-declared rule.
8. AC8 (G6 is a Warning) — cross-line-only literal produces a Warning and exit 0.
9. AC9 (parity, including the quote-selection class) — identical finding strings across runtimes, including apostrophe-bearing fixtures.
10. AC10 (graceful degradation) — no-context: G2/G3/G5/G6 silent; raising/non-zero seam: rules skipped, no finding, no exception escapes. Cycle-2 addendum names `test_failing_git_adapter_skips_g2_g3_without_raising` (Python) and the TypeScript case `skips the tracked-tree cov rules when the adapter throws`.
11. AC11 (reusable extractor seam) — extractor importable independently; records carry exactly `task_id`, `source_line`, `raw_span`, `argv`, `kind`.
12. AC12 (PowerShell hook untouched) — `.claude/hooks/validate-planner-output.ps1` absent from the branch diff.

User story (`user-story.md` lines 65-70):

1. AC-U1 — unfalsifiable-literal report names task and literal; plan-quoted literal not reported (delegates to spec AC1).
2. AC-U2 — `.py` coverage path rejected with dotted remedy (delegates to spec AC2).
3. AC-U3 — runs inside the existing mandatory validator call, no surface growth (delegates to spec AC4).
4. AC-U4 — every report task-prefixed; unattributable commands unreported (delegates to spec AC5).
5. AC-U5 — advisory-only plan accepted, advisory surfaced (delegates to spec AC6).
6. AC-U6 — no-finding plan behaves exactly as before (delegates to spec AC3).

## Acceptance Criteria Evaluation

| Criterion | Verdict | Evidence |
|---|---|---|
| AC1 | PASS | Named tests per runtime (finding + exoneration, stub git adapter) pass in this session's full-suite runs (`test_plan_gate_discrimination_literals.py`; `plan-gate-discrimination-literals.test.ts`). Unchanged since the cycle-1 reaudit; re-verified by suite execution at head `450a8f47`. |
| AC2 | PASS | G1 named tests pass in both runtimes; the live CLI run this session reproduced a G1-class message shape on the feature plan's quoted fixture (dotted-remedy text, no `.py` in the remedy clause). |
| AC3 | PASS | Byte-identity tests (seven structural error strings, clean-plan empty list with and without context) pass in both runtimes this session. |
| AC4 | PASS | Dispatch and schema property-key tests pass; live CLI validation this session used the existing `plan` artifact type with no new flag. |
| AC5 | PASS | The four attribution tests per runtime pass; every finding observed this session (CLI warnings, probe outputs, test assertions) is `[P#-T#]`-prefixed. |
| AC6 | PASS | Warning-channel tests pass; live CLI run on `plan.2026-08-17T15-00.md` this session: exit 0, success line on stdout, two `PLAN GATE WARNING:` lines on stderr. |
| AC7 | PASS | `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md` records the corpus run (166 plans, 100 candidates, 0 findings); `G5_SEVERITY` is `"warning"` in both runtimes (grep this session); spec AC7 states the two-conjunct rule and the deviation note stands at spec line 68. |
| AC8 | PASS | G6 sliding-window Warning tests pass in both runtimes with stub file readers. |
| AC9 | PASS | Parity suites pass, including apostrophe-bearing `--cov` and literal fixtures; cycle-2 cross-runtime degradation parity recorded in `evidence/qa-gates/parity-r5.2026-08-20T16-57.md` and corroborated by both suites passing this session. |
| AC10 | PASS (upgraded from PARTIAL) | The cycle-1 gap (Python G2/G3 lookups unguarded) is closed by `450a8f47`: guard verified by source inspection (`plan_gate_discrimination.py:283-288`), by the two new named tests, and by an independent reviewer probe (raising adapter + `--cov=scripts/dev_tools` → empty channels, no escape). Fail-before evidence proves the test discriminates (`r5-fail-before.2026-08-20T16-44.md`, exit 1 with RuntimeError propagation at the pre-fix head). The no-context leg re-verified by the byte-identity tests. |
| AC11 | PASS | Extractor record-shape tests pass in both runtimes; `plan_gate_commands.py` importable independently (exercised directly by its test module). |
| AC12 | PASS | `git diff --name-only 8092d391...450a8f47` contains no `validate-planner-output` path (grep exit 1, this session). |
| AC-U1 | PASS | Delegates to AC1. |
| AC-U2 | PASS | Delegates to AC2. |
| AC-U3 | PASS | Delegates to AC4. |
| AC-U4 | PASS | Delegates to AC5. |
| AC-U5 | PASS | Delegates to AC6. |
| AC-U6 | PASS | Delegates to AC3. |

## Summary

All 18 acceptance criteria (12 spec, 6 user-story) evaluate PASS at head `450a8f47`. The single cycle-2 finding (R5) that held AC10 at PARTIAL is closed and verified behaviorally. No acceptance criterion is affected by the one new policy finding from this reaudit (R6, the 505-line file-size violation in `policy-audit.2026-08-20T17-11.md`): R6 is a code-change-policy violation, not an acceptance-criterion failure, and its remedy (a behavior-preserving module split) must not change any AC-verified behavior — the remediation inputs constrain the split to preserve finding strings, severities, and the public surface, with the parity and byte-identity suites as the guard.

**Overall acceptance verdict: PASS on acceptance criteria; feature not PR-ready due to the policy-audit Blocking finding R6.** See `remediation-inputs.2026-08-20T17-11.md`.

## Acceptance Criteria Check-off

All 12 spec criteria and all 6 user-story criteria were already checked `[x]` in their source files before this audit (checked during cycle-1/cycle-2 execution per `acceptance-criteria-tracking`). This audit verified each against evidence and confirms every check-off is accurate, including AC10, whose checked state became accurate when commit `450a8f47` landed the guard and the addendum-named tests. No check-off edits were required this session; no criterion was unchecked; no phantom criteria were added.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md`, `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/user-story.md`
- Total AC items: 18 (12 spec + 6 user-story)
- Checked off (delivered): 18
- Remaining (unchecked): 0
- Items remaining: none
