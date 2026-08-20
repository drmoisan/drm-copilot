# Feature Audit: reject-unfalsifiable-acceptance-gates-in-atomic-plans (Issue #486) — Remediation Cycle 3 Reaudit

**Audit Date:** 2026-08-20
**Auditor:** feature-review agent (delegated session, cycle-3 reaudit)
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` (read directly from the bundled path; this delegated session's tool set does not include the MCP server tools).

## Scope and Baseline

- **Branch:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` @ `afdbe62673a9b6686e84419f7d085f4b77258074` (re-resolved this session with `git rev-parse HEAD`).
- **Base branch:** `main` (caller-supplied; merge-base `8092d391f50c44571145c73e161bbd1dafe0f035` confirmed this session with `git merge-base main HEAD`).
- **Diff range:** `8092d391..afdbe626` — 6 commits, 145 files, +11981/-21.
- **PR context:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were stale (recorded prior head `450a8f47`) and were regenerated this session with `poetry run dev.pr-context --base main --repo-root .` before evaluation.
- **Work mode:** `full-feature` (persisted `- Work Mode: full-feature` marker, `issue.md` line 10). AC sources per the work-mode contract: `spec.md` **and** `user-story.md`.
- **Cycle context:** re-audit following remediation cycle 3, which closed the cycle-2 Blocking finding R6 (500-line ceiling) and the folded Minor N1 via commit `afdbe626` (extraction of `scripts/dev_tools/plan_gate_coverage.py`). The extraction is behavior-preserving, so the AC evaluation below re-verifies each criterion at the new head rather than assuming carry-over; every named test was re-run green this session (4059 Python / 2645 TypeScript).

## Acceptance Criteria Inventory

Source 1 — `spec.md` (`## Acceptance Criteria`): AC1–AC12, all currently checked `[x]`.
Source 2 — `user-story.md` (`## Acceptance Criteria`): AC-U1–AC-U6, all currently checked `[x]`.

| ID | Criterion (abbreviated) | Source |
|---|---|---|
| AC1 | G5 two-condition form: finding for tree-absent + plan-absent literal; exoneration for plan-quoted literal | spec.md |
| AC2 | G1 Blocking with dotted remedy, no `.py` in remedy clause | spec.md |
| AC3 | No-finding byte identity: unchanged error list, CLI stdout/stderr/exit, seven structural error strings | spec.md |
| AC4 | Automatic invocation via existing `plan` route; MCP input-schema property-key set unchanged | spec.md |
| AC5 | Task attribution: every finding starts with `[P#-T#]`; preamble/phase/heading-separated commands produce no finding | spec.md |
| AC6 | Warnings do not fail the gate: exit 0, warning on stderr / warnings field | spec.md |
| AC7 | G5 severity fixed by corpus measurement; `G5_SEVERITY` constant per runtime | spec.md |
| AC8 | G6 is a Warning (window-join literal), exit 0 | spec.md |
| AC9 | Cross-runtime parity, including single-quote-bearing values | spec.md |
| AC10 | Graceful degradation: no context → G2/G3/G5/G6 silent; raising/non-zero seam → skipped, no escape | spec.md |
| AC11 | Reusable extractor seam: records with `task_id`, `source_line`, `raw_span`, `argv`, `kind` | spec.md |
| AC12 | `.claude/hooks/validate-planner-output.ps1` untouched on the branch | spec.md |
| AC-U1 | Report names task + unmatched literal; quoted literal not reported | user-story.md |
| AC-U2 | `.py` `--cov` path rejected with dotted-form message | user-story.md |
| AC-U3 | Runs in existing mandatory validator call; no new flag/artifact type/schema change | user-story.md |
| AC-U4 | Every report begins with the task identifier; unattributable commands not reported | user-story.md |
| AC-U5 | Advisory-only plan accepted (exit 0, no MCP throw, advisory surfaced) | user-story.md |
| AC-U6 | No-finding plan behaves exactly as before the change | user-story.md |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence (re-verified this session at head `afdbe626`) |
|---|---|---|
| AC1 | PASS | Named finding/exoneration test pairs in `tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py` and `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts`, stub git adapters returning empty file lists; both suites green this session. G5/G6 logic remained in `plan_gate_discrimination.py` through the cycle-3 split. |
| AC2 | PASS | Named context-free G1 test per runtime (`test_plan_gate_discrimination_cov.py`, `plan-gate-discrimination-cov.test.ts`); the G1 message with `_dotted_remedy` moved byte-identically into `plan_gate_coverage.py` (diff inspection this session); suites green. |
| AC3 | PASS | `test_validate_orchestration_artifacts_plan_gates.py` asserts the seven exact structural error strings and clean-plan empty-list behavior with and without context; TypeScript counterpart likewise; both green this session. Reviewer self-gate run on the committed plan reproduces exit 0 with byte-identical output. |
| AC4 | PASS | Dispatch tests per runtime plus the MCP schema property-key test (`mcp-plan-gate-warning-projection.test.ts`, `orchestration-artifacts-plan-gates.test.ts`) green this session; no new flag or artifact type in the `afdbe626` diff. |
| AC5 | PASS | Four named attribution tests per runtime (preamble, phase preamble, intervening heading, task line) green this session; every finding string in both post-split modules renders the `[{task}]` prefix (source inspection). |
| AC6 | PASS | Warning-only exit-0 test per runtime green this session; reviewer self-gate run demonstrates the live behavior (2 warnings on stderr, exit 0, unchanged success line). |
| AC7 | PASS | Measurement artifact `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md` (166 plans, 100 candidates, 0 findings, 0 false positives → Warning). `G5_SEVERITY` re-verified this session: `plan_gate_discrimination.py:58` (`WARNING_CHANNEL` = `"warning"`), `plan-gate-discrimination.ts:69` (`"warning"`); the parity test asserting agreement passed this session. |
| AC8 | PASS | Named G6 window-join Warning test per runtime with stub file reader; green this session; window logic untouched by cycle 3. |
| AC9 | PASS | Paired parity fixtures including apostrophe-bearing `--cov` value and literal, asserted identically in both runtimes (`test_plan_gate_parity.py`, `plan-gate-parity.test.ts`); green this session. The cycle-3 change strengthened the companion no-`repr` guard over the Python module set, with committed mutation fail/revert evidence proving discrimination. |
| AC10 | PASS | No-context and raising/non-zero-seam tests per runtime green this session, including `test_failing_git_adapter_skips_g2_g3_without_raising` (Python) and "skips the tracked-tree cov rules when the adapter throws" (TypeScript). The graceful-degradation guard moved intact into `plan_gate_coverage.evaluate_cov_value` (diff inspection). |
| AC11 | PASS | Extractor record-field test per runtime (`test_plan_gate_commands.py`, `plan-gate-commands.test.ts`) green this session; `plan_gate_commands.py` untouched by cycle 3. |
| AC12 | PASS | `git diff --name-only main...HEAD` contains no `validate-planner-output.ps1` entry (grep count 0, this session). |
| AC-U1 | PASS | Same evidence as AC1. |
| AC-U2 | PASS | Same evidence as AC2. |
| AC-U3 | PASS | Same evidence as AC4. |
| AC-U4 | PASS | Same evidence as AC5. |
| AC-U5 | PASS | Same evidence as AC6. |
| AC-U6 | PASS | Same evidence as AC3. |

## Summary

All 18 acceptance criteria (12 spec, 6 user-story) evaluate PASS at head `afdbe626`. The cycle-3 remediation was structural (module split for the 500-line ceiling) and behavior-preserving; every criterion's named tests were re-run green this session, and the finding strings, severities, cascade order, channel routing, and public surface were verified unchanged through the split. The one recorded deviation (public naming of three boundary-crossing helpers) does not touch any acceptance criterion's subject matter; all four stated Phase 1 acceptance commands of the remediation plan pass verbatim per `evidence/other/helper-visibility-deviation.2026-08-20T21-39.md`, corroborated by this session's pyright and pytest runs.

Companion artifacts: `policy-audit.2026-08-20T18-21.md` (FULLY COMPLIANT, zero Blocking findings), `code-review.2026-08-20T18-21.md` (0 blockers, 1 Minor advisory, 1 Info note). No remediation cycle is required. Recommendation: **go** for PR authoring.

## Acceptance Criteria Check-off

All AC checkboxes in both source files were already checked `[x]` by the executor and verified justified by this audit; per the check-off protocol no source-file edit was required this cycle, and no item was un-checked.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md`, `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/user-story.md`
- Total AC items: 18 (12 spec + 6 user-story)
- Checked off (delivered): 18
- Remaining (unchecked): 0
- Items remaining: none
