# Feature Audit: reject-unfalsifiable-acceptance-gates-in-atomic-plans (Issue #486)

**Audit Date:** 2026-08-20 (artifact timestamp 2026-08-20T14-09, host clock; clock-variance note in the sibling policy audit)

## Scope and Baseline

- **Resolved base branch:** `main` (`origin/main` @ `646504f3`), supplied by the caller and confirmed this session.
- **Merge base:** `71aebdb9a1e4752b191b3c9d4e677b807ea6fdec` (recomputed this session via `git merge-base origin/main HEAD`; matches the caller-supplied value).
- **Head:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` @ `cdf85294e713d08185aecf68f8869bed2975a723`.
- **PR-context artifacts:** regenerated this session (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`) via `scripts.dev_tools.pr_context.collector --base origin/main --head HEAD`, because the artifacts were absent from the worktree at review start.
- **Work mode:** `full-feature` per the persisted `- Work Mode: full-feature` marker in `issue.md`. Acceptance-criteria sources are therefore `spec.md` and `user-story.md`.
- **Scope:** the full branch diff (67 files, +7652/-21). No caller narrowing was present or applied.

## Acceptance Criteria Inventory

Authoritative sources (full-feature mode):

- `spec.md` `## Acceptance Criteria`: AC1–AC12 (12 items; 11 checked `[x]`, AC7 unchecked at review start).
- `user-story.md` acceptance criteria: AC-U1–AC-U6 (6 items; all checked `[x]` at review start).

Supplementary checkbox sections in `spec.md`, evaluated for completeness but tracked separately from the formal AC inventory:

- `## Definition of Done`: 8 items (6 checked; items 1 and 2 unchecked at review start).
- `## Seeded Test Conditions (from potential)`: 3 items (all unchecked at review start; no plan task assigns them).

## Acceptance Criteria Evaluation

| ID | Criterion (abbreviated) | Verdict | Evidence |
|----|--------------------------|---------|----------|
| AC1 | G5 two-condition form: finding for tree-absent + plan-absent literal; exoneration for plan-quoted literal | PASS | `test_g5_reports_literal_absent_from_tree_and_plan`, `test_g5_exonerates_literal_quoted_in_plan` (Python) and TypeScript counterparts in `plan-gate-discrimination-literals.test.ts`; both suites green this session |
| AC2 | G1 Blocking with dotted remedy, no `.py` in remedy clause | PASS | classification-table tests in `test_plan_gate_discrimination_cov.py` / `plan-gate-discrimination-cov.test.ts`; parity fixture `PARITY_G1` |
| AC3 | No-finding byte identity incl. seven structural error strings | PASS | `test_structural_errors_match_recorded_baseline_strings`, `test_clean_plan_returns_empty_without_context`, `test_clean_plan_returns_empty_with_stub_context`; baseline strings recorded in `evidence/baseline/existing-plan-error-strings.2026-08-20T11-40.md` |
| AC4 | Automatic invocation on existing `plan` route; MCP schema property-key set unchanged | PASS | `test_plan_route_reports_g1_without_new_flag`, `test_plan_subparser_option_set_is_path_and_workspace_root`; `mcp-plan-gate-warning-projection.test.ts`, `mcp-repo-automation-tool-definitions.test.ts` |
| AC5 | Task attribution; preamble/phase-preamble/post-heading commands produce no finding | PASS | four named tests per runtime (attribution-window tests in `test_plan_gate_commands.py` / `plan-gate-commands.test.ts`) |
| AC6 | Warnings do not fail the gate (exit 0, unchanged stdout, no MCP throw, stderr/warnings-field surfacing) | PASS | `test_main_emits_warning_prefix_on_stderr_and_exits_zero`; `validate-orchestration-service-call-plan-gates.test.ts`; independently demonstrated by this session's CLI self-validation of the feature's own plan (2 warnings, exit 0) |
| AC7 | G5 severity fixed by measurement; "Blocking if and only if the recorded false-positive count is 0" | **FAIL (as written; assessed as a spec-text defect)** | Measurement artifact `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md` records all required fields (command, exit code, 166 plans, 100 candidates, TP 0, FP 0). Shipped severity is Warning in both runtimes (`plan_gate_discrimination.py:53`, `plan-gate-discrimination.ts:69`), so the literal biconditional fails (FP == 0 but severity != Blocking). The approved plan [P5-T3] pre-declared the two-conjunct rule (finding count > 0 AND FP == 0), predicted this exact vacuous-measurement branch, and terminally disposed it as Warning. The spec's own rationale (line 62) and Constraints (line 147) defer severity to a real measurement; a zero-finding measurement measures nothing, so shipping Blocking would contradict the spec's stated intent. Verdict: the implementation is correct; the AC sentence is defective. Left unchecked; remediation is a spec amendment plus check-offs. |
| AC8 | G6 is a Warning (cross-line join, exit 0) | PASS | `test_g6`-family tests with stub file reader; parity fixture `PARITY_G6`; `G6` routed to the warnings channel |
| AC9 | Cross-runtime parity incl. apostrophe class | PASS | `test_parity_findings_match_expected_strings` + `plan-gate-parity.test.ts` (verbatim-duplicated eight-fixture set incl. `PARITY_G1_APOSTROPHE`, `PARITY_G5_APOSTROPHE`); `test_g5_severity_constant_matches_typescript` |
| AC10 | Graceful degradation (no context; raising/non-zero-exit adapter) | PASS | `test_context_free_call_skips_context_rules`, `test_failing_git_adapter_produces_no_findings` + TypeScript counterparts in `plan-gate-repository.test.ts` |
| AC11 | Reusable extractor seam with exactly `task_id`, `source_line`, `raw_span`, `argv`, `kind` | PASS | record-field-set tests in `test_plan_gate_commands.py` / `plan-gate-commands.test.ts` |
| AC12 | `.claude/hooks/validate-planner-output.ps1` untouched | PASS | `git diff --name-status origin/main...HEAD` re-run this session; the path is absent |
| AC-U1 | Tree-absent + plan-absent literal reported with task and literal; plan-quoted literal not reported | PASS | same tests as AC1 |
| AC-U2 | `.py`-path `--cov` rejected with dotted form in message | PASS | same tests as AC2 |
| AC-U3 | Runs inside the existing mandatory validator call; no new flag/type/schema change | PASS | same tests as AC4 |
| AC-U4 | Every report begins with the task identifier; unattributable commands not reported | PASS | same tests as AC5 |
| AC-U5 | Advisory-only plan accepted; advisory text still surfaced | PASS | same tests as AC6 |
| AC-U6 | No-finding plan behaves exactly as before | PASS | same tests as AC3 |

Supplementary items:

| Item | Verdict | Evidence |
|------|---------|----------|
| DoD 1 — every AC checked off | FAIL (blocked by AC7) | AC7 unchecked |
| DoD 2 — G5 severity matches recorded FP count | FAIL as written (same spec-text defect as AC7; the shipped severity matches the plan's pre-declared rule) | measurement artifact + severity constants |
| DoD 3–8 (parity ship, hook untouched, rule file + cross-reference, classification-table coverage, new-module coverage thresholds, full toolchain pass) | PASS (all `[x]`) | verified this session: mirrors byte-identical (`cmp`), toolchain green, coverage figures in the policy audit |
| Seeded 1 — unit coverage areas | PASS | pattern-absence tests with controlled tracked-file stubs; `--cov` classification table; per-finding task identifiers; empty-result path — all covered by named passing tests. Checked off by this review. |
| Seeded 2 — single synthetic plan with all three failure modes, three findings at specified severities in one run | PARTIAL | each failure mode individually verified at its specified severity (G1 Blocking, G5 Warning, G6 Warning); no single-plan combined end-to-end run exists (parity fixtures are one-command-per-plan). Left unchecked; remediation adds one integration test per runtime. |
| Seeded 3 — CLI/API exit-code and message-format contract incl. zero-violation and warning-only cases | PASS | `test_main_emits_warning_prefix_on_stderr_and_exits_zero`, `test_main_emits_blocking_error_on_stderr_and_exits_one`, clean-plan tests; MCP warning-projection tests. Checked off by this review. |

## Summary

- Formal acceptance criteria: **17 of 18 PASS** (12 spec AC + 6 user-story AC, minus AC7). AC7 FAILS as literally written; this audit locates the defect in the spec sentence, not the implementation — the shipped Warning severity is the outcome the approved plan pre-declared for the vacuous-measurement branch that preflight predicted and the measurement confirmed.
- Supplementary: DoD items 1–2 fail as a direct consequence of AC7; seeded condition 2 is PARTIAL (one missing combined integration scenario); seeded conditions 1 and 3 PASS and were checked off by this review.
- Plan execution: 138 of 140 tasks checked; the two unchecked tasks ([P12-T13], [P12-T14]) are the check-off tasks blocked by AC7. [P12-T11]'s orchestrator-session closure is documented with full provenance and was independently corroborated by a CLI plan validation this session (exit 0).
- Remediation required: yes — see `remediation-inputs.2026-08-20T14-09.md` (2 Blocking findings: the TypeScript changed-line coverage regression recorded in the policy audit, and the AC7/DoD spec reconciliation; 2 Minor items).
- Go/no-go: **NO-GO for PR** until the remediation cycle closes both Blocking findings. Both are small and bounded (one test file addition; one spec-text amendment plus check-offs).

## Acceptance Criteria Check-off

- AC1–AC6, AC8–AC12 in `spec.md` and AC-U1–AC-U6 in `user-story.md` were already checked `[x]` by the executor; this review verified each against named passing tests and left them checked.
- AC7 evaluated FAIL as written: left unchecked per the check-off protocol (no evidence-backed PASS). The criterion text was not modified; reconciliation is routed through remediation because reviewers do not amend criterion text.
- Newly checked off by this review in `spec.md` (evidence-backed PASS):
  - `## Seeded Test Conditions` item 1 ("Unit coverage areas: ...") — `- [ ]` → `- [x]`
  - `## Seeded Test Conditions` item 3 ("CLI/API examples: ...") — `- [ ]` → `- [x]`
- Left unchecked: AC7, DoD items 1–2, Seeded item 2, plan tasks [P12-T13] and [P12-T14].

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md`, `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/user-story.md`
- Total AC items: 18 (12 spec + 6 user-story)
- Checked off (delivered): 17
- Remaining (unchecked): 1
- Items remaining: AC7 (G5 severity fixed by measurement) — blocked on the spec-text amendment described in the remediation inputs.
