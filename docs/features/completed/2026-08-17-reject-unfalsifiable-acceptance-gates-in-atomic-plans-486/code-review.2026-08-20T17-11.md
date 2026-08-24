# Code Review: reject-unfalsifiable-acceptance-gates-in-atomic-plans (#486) — Remediation Cycle 2 Re-review

**Review Date:** 2026-08-20
**Reviewer:** feature-review agent (delegated session, cycle-2 reaudit)
**Feature Folder:** `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486`
**Base Branch:** `main` (merge-base `8092d391f50c44571145c73e161bbd1dafe0f035`)
**Head Branch:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` @ `450a8f472edff4fa340de3d8d230a407fb8c3e0b`
**Review Type:** Post-remediation re-review (cycle 2)
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` (the backing file of the `code-review-template` MCP selector; this session's tool set does not include the MCP server tools, so the asset was read directly from the bundled path). Instruction block removed.

## Executive Summary

Cycle 2 delivered exactly the scoped R5 fix and nothing else on the production surface: commit `450a8f47` modifies one Python production file (`scripts/dev_tools/plan_gate_discrimination.py`, +15 lines), one Python test file (`tests/scripts/dev_tools/test_plan_gate_discrimination_context.py`, +72 lines, 2 tests), the spec (one-line AC10 verification addendum), one new potential entry (the M1 deferral), and cycle-2 audit/evidence documents. No TypeScript file, rule file, skill file, mirror, config, or dependency changed, matching every "Do Not Do" constraint in `remediation-inputs.2026-08-20T16-10.md`.

**What changed:** `_evaluate_cov_value` no longer performs the G2/G3 tracked-tree lookups inline. The block is extracted into `_evaluate_tracked_cov_value` and invoked inside a broad `try`/`except Exception: return` guard carrying the same contract comment used by `_evaluate_literal_rules` ("Broad by contract: a validation run must never fail because the repository could not be queried (spec AC10, graceful degradation)."). G1 and G4 remain outside the guard because they are context-free. No finding string, severity constant, cascade order, or channel routing changed — verified by diff inspection and by the byte-identity/parity test suites passing unchanged.

I verified the fix behaviorally, not only by reading it: an independent probe (a `PlanGateContext` whose git adapter raises `RuntimeError`, evaluated against a plan carrying `` `poetry run pytest --cov=scripts/dev_tools -q` ``) returned empty blocking and warning channels with no escaping exception. This is the exact input class that propagated `RuntimeError` out of `evaluate_plan_gates` at `9e5c141d`, per the committed fail-before evidence (`evidence/regression-testing/r5-fail-before.2026-08-20T16-44.md`). Both full suites pass (Python 4059, TypeScript 2645), and the module's coverage did not regress (98.28% lines / 90.54% branches against the 98.21%/90.54% floor).

One new defect was introduced by the fix itself: the 15 added lines pushed the module from 490 to 505 lines, over the 500-line production-file ceiling in `.claude/rules/general-code-change.md` § File Size Limit. This is a Blocker by policy (R6 in the policy audit), though it is mechanical to remedy with a behavior-preserving module split.

**Top 3 risks:**
1. The 505-line module (R6) must be split; the split must keep the parity tests accurate — `test_plan_gate_parity.py` asserts the absence of `repr(`/`!r` by reading the Python gate module source, so an extraction must ensure the moved finding-string code remains inside the asserted target set.
2. A future edit could reintroduce the guard asymmetry; mitigated by the discriminating fail-before/pass-after test pair now in the suite.
3. The M1 seam-semantics divergence (fatal non-zero git exits translated to negative answers) remains in both runtimes identically; it is Warning-channel-only and now tracked as a potential entry rather than on this branch.

**PR readiness recommendation:** **Needs Revision** — R5 is closed and verified, but the fix crossed the file-size ceiling (R6), which is a Blocking policy finding requiring one more bounded remediation cycle.

## Scope of Review

- Full branch diff `8092d391..450a8f47` (114 files, +10146/-21), with line-by-line inspection of the cycle-2 delta (`git show 450a8f47`) and re-verification of the cycle-1/cycle-2 constraint set against the whole branch.
- Evidence reviewed: refreshed PR-context artifacts (regenerated this session at head `450a8f47`), the cycle-2 qa-gates/regression evidence set (timestamps `16-34` through `17-22`), committed coverage artifacts regenerated this session, and live toolchain runs (black, ruff, pyright, pytest with coverage; prettier, eslint, tsc, jest with coverage).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `scripts/dev_tools/plan_gate_discrimination.py` | whole file (505 lines) | The cycle-2 guard extraction (+15 lines) pushed the module over the 500-line production-file ceiling (490 at `9e5c141d`, 505 at `450a8f47`). | Extract a cohesive rule group (the G5/G6 literal-rule functions or the G1-G4 coverage cascade) into a sibling module under `scripts/dev_tools/`, preserving every finding string, `G5_SEVERITY`, the public `evaluate_plan_gates` surface, and the no-`repr` parity-test target set; re-run both suites and the parity tests. | `.claude/rules/general-code-change.md` § File Size Limit is unconditional for production files; no listed exception applies. | `wc -l` = 505 this session; `git show 9e5c141d:...| wc -l` = 490. Policy audit R6, section 8. |
| Minor | `scripts/dev_tools/plan_gate_discrimination.py` | `_evaluate_tracked_cov_value` (line 296) | The helper recomputes `truncated = value.split(PYTEST_NODE_SEPARATOR, 1)[0]`, duplicating the computation already performed in `_evaluate_cov_value` (line 264); the TypeScript twin `evaluateTrackedCovValue` instead receives `truncated` as a parameter. | When performing the R6 split, pass `truncated` into the helper to match the TypeScript signature and remove the duplicate computation. | Behaviorally identical (the split is deterministic on the same input), but the asymmetry invites drift between the runtimes the parity suite is meant to keep aligned. | Diff inspection of `450a8f47` vs `plan-gate-rules.ts:214-259`. |
| Info | `scripts/dev_tools/plan_gate_discrimination.py` | lines 283-288 | R5 verified closed: the G2/G3 lookups now degrade gracefully behind the specified broad guard; G1/G4 still report under a raising seam. | None — confirmed working. | Matches the remediation-inputs fix specification and the TypeScript structure; the two named tests plus an independent reviewer probe confirm the contract. | Probe this session (empty channels, no escape); `test_failing_git_adapter_skips_g2_g3_without_raising` and `test_raising_adapter_reports_only_context_free_findings` pass; `r5-fail-before.2026-08-20T16-44.md` / `r5-pass-after.2026-08-20T16-48.md`. |
| Info | `docs/features/potential/2026-08-20-plan-gate-nonzero-exit-seam-semantics.md` | new file | M1 (non-zero-exit seam semantics) dispositioned as a potential entry per the authorized deferral path; no production change made. | Schedule the entry normally; when consumed, update both adapters and the rule prose together with parity tests. | Warning-channel-only impact, identical in both runtimes; deferral was explicitly permitted by the cycle-2 inputs. | File present in the `450a8f47` diff; both adapters unchanged. |
| Info | `docs/features/active/.../spec.md` | line 197 (AC10) | The AC10 verification addendum names the Python test and the pre-existing TypeScript case without altering the criterion's meaning — the exact reconciliation form the cycle-2 inputs permitted. | None. | The checked `[x]` state of AC10 is now accurate. | Spec diff in `450a8f47`; both named tests pass this session. |

## Typed-Python Review (changed Python in cycle 2)

- `_evaluate_tracked_cov_value` is fully annotated (`report: PlanGateReport, task: str, value: str, context: PlanGateContext -> None`) and documented; Pyright passes with 0 errors and no new suppressions.
- The broad `except Exception` is the rule-mandated exception to the fail-fast default and carries the required contract comment; it wraps only the seam-dependent block, so context-free rules cannot be silently swallowed.
- The new test class `_RaisingGitRepository` subclasses the existing `StubGitRepository`, overriding both lookup methods to raise — modeling the production `FileNotFoundError` path (`subprocess.run` raising with `git` absent from `PATH`) without touching a real process boundary.

## Test and Coverage Verification

- Python: 4059 passed / 5 pre-existing skips (+2 tests vs cycle 1). Module coverage `plan_gate_discrimination.py`: 98.28% lines (171/174), 90.54% branches (67/74) — no regression; the three uncovered lines are the relocated pre-existing miss set (326, 365, 394), and the new guard lines are covered. Repo-wide `scripts/`: 92.59% lines / 85.16% branches.
- TypeScript: 193 suites / 2645 tests pass; repo-wide 96.65% lines / 90.01% branches; per-file figures identical to cycle 1 (no TypeScript change).
- Toolchain: black, ruff, pyright, prettier, eslint, tsc all clean in a single pass this session.

## Readiness Recommendation

**Needs Revision.** One Blocker (R6, file-size ceiling) with a bounded, behavior-preserving remedy. No other open findings: R5 is closed and verified, M1 is dispositioned, all acceptance criteria pass (see `feature-audit.2026-08-20T17-11.md`), and both languages' coverage verdicts are PASS.
