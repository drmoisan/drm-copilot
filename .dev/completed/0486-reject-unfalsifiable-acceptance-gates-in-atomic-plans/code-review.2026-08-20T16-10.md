# Code Review: reject-unfalsifiable-acceptance-gates-in-atomic-plans (Issue #486) — Remediation Cycle 1 Reaudit

- **Review Date:** 2026-08-20 (session timestamp `2026-08-20T16-10`)
- **Reviewer:** feature-review agent (delegated session)
- **Branch:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` @ `9e5c141d863f4255a32656d1d58233ae0a8d3255`
- **Base:** `main` @ merge-base `8092d391f50c44571145c73e161bbd1dafe0f035`
- **Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` (the `code-review-template` selector's backing file; this session's tool set does not include the MCP server tools, so the asset was read directly from the bundled path).
- **Prior cycle:** `code-review.2026-08-20T14-09.md`. This review verifies the cycle-1 remediation (commit `9e5c141d`) and re-examines the full branch diff.

## Executive Summary

The cycle-1 remediation commit is narrow and correct: it adds tests and reconciles documentation, changing zero production-code lines, which matches the cycle-1 expectation for R1 (test-only coverage restoration), R3 (direct-dispatch test), R4 (combined-plan fixtures), and R2 (spec reconciliation with a recorded deviation note). All four cycle-1 findings are verified closed with direct evidence (lcov parse, test presence and execution, spec/plan checkbox state).

This reaudit established one new Blocking finding by probe execution rather than by reading alone: the Python runtime's graceful-degradation guard does not cover the G2/G3 coverage-argument path. `_evaluate_cov_value` calls `context.git.is_tracked_file` and `is_tracked_directory` unguarded, so a repository seam that raises escapes `evaluate_plan_gates` — reproduced this session with a raising stub adapter and a plan carrying `--cov=scripts/dev_tools` (`RuntimeError` propagated to the caller). The TypeScript runtime wraps the equivalent lookups (`evaluateTrackedCovValue`) in try/catch, so the two runtimes diverge behaviorally for this input class. This violates the graceful-degradation invariant recorded in `.claude/rules/plan-acceptance-gates.md` ("No finding is produced and no exception escapes the evaluation entry point") and spec AC10. The production escape path is real: `SubprocessRunner.run` suppresses only non-zero exits; `subprocess.run` raises `FileNotFoundError` when `git` is absent from `PATH`, and nothing between the adapter and the CLI catches it on the coverage path.

One Minor advisory is recorded on non-zero-exit seam semantics (identical in both runtimes; Warning-channel impact only). All toolchain stages pass cleanly this session; code quality of the delivered modules is otherwise high — pure rule functions behind an injected seam, exact message parity discipline, and thorough AAA-structured tests.

Verdict: **remediation required** — 1 Blocking finding (R5). See `remediation-inputs.2026-08-20T16-10.md`.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Blocking | `scripts/dev_tools/plan_gate_discrimination.py` | `_evaluate_cov_value`, lines 283-297 (G2/G3 lookups); call site `evaluate_plan_gates` lines 476-484 | The G2/G3 tracked-tree lookups run outside any graceful-degradation guard; a raising git seam escapes `evaluate_plan_gates`, crashing the validation run. Diverges from the TypeScript runtime, which guards the same path. | Extract the G2/G3 lookup block into a helper invoked inside a broad `try`/`except` that returns without findings, mirroring `evaluateTrackedCovValue` in `plan-gate-rules.ts:236-241`; add a named Python test driving a raising adapter through a path-separator `--cov` value; assert both runtimes stay aligned. | The landed rule file mandates "No finding is produced and no exception escapes the evaluation entry point" for a raising seam, and spec AC10 asserts the same; the escape is reachable in production (`subprocess.run` raises `FileNotFoundError` for an absent `git` binary regardless of `allow_error=True`). | Probe run this session: `PlanGateContext` with a raising git adapter + plan text containing `--cov=scripts/dev_tools` → `RuntimeError` propagated out of `evaluate_plan_gates`. Contrast: `_evaluate_literal_rules` (same file, lines 427-455) correctly guards the G5/G6 group; `test_failing_git_adapter_produces_no_findings` passes only because its fixture exercises the guarded literal path. |
| Minor | `scripts/dev_tools/plan_gate_discrimination.py`; `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` | `GitPlanGateRepository.is_tracked_file` / `is_tracked_directory` / `files_containing` and the TypeScript twin | A non-zero `git` exit is translated into a negative answer rather than a skip, so a fatal `git` failure (for example exit 128 outside a work tree) can produce a spurious G3 or G5 Warning instead of the rule file's specified "skipped, no finding" outcome. Both runtimes behave identically. | Either distinguish fatal exits in the adapters (code > 1 for `git grep`, any non-zero for `ls-files`/`show`) and skip the rules, or amend the rule-file prose to match the shipped semantics in a later cycle. | For `git grep`, exit 1 is the ordinary no-match answer, so exit-code-blind translation is partially correct by design; the conflation affects only fatal exits, stays on the Warning channel, and preserves the never-fail intent — advisory, not blocking. | Adapter code paths `plan_gate_discrimination.py:117-149`; `.claude/rules/plan-acceptance-gates.md` § Graceful degradation ("A repository seam ... that reports a non-zero exit, causes G2, G3, G5, and G6 to be skipped"). |
| Info | `docs/features/active/.../spec.md` | AC10, line 197 | AC10 remains checked `[x]` in `spec.md` while this reaudit evaluates it PARTIAL (the "no exception escapes" clause is falsified for the Python G2/G3 path). | Reconcile the checkbox as part of the R5 remediation: once the guard lands and the named test passes, the checked state becomes accurate without a documentation edit. | The acceptance-criteria-tracking protocol forbids reviewers from checking off non-passing items; the existing check-off predates this finding, so the discrepancy is documented here and routed through remediation rather than edited by the reviewer. | `feature-audit.2026-08-20T16-10.md` § Acceptance Criteria Evaluation. |

## Implementation Audit

### Python implementation audit

- `scripts/dev_tools/plan_gate_commands.py` (new, 306 lines): clean single-pass extractor. Attribution window (task line, heading close, fence toggling) matches the rule-file prose exactly; drop rules (unbalanced quoting via `shlex.split` `ValueError`, argv shorter than two words) are applied at a single record-creation point; `grep_executable_index` bounds the wrapper scan window and handles the `git grep` two-word verb. Fully typed, frozen dataclass record with exactly the AC11 field set. 100%/100% coverage.
- `scripts/dev_tools/plan_gate_discrimination.py` (new, 490 lines): rules G1-G6 implemented per the rule table; the G1-G4 cascade decides each `--cov` value once; G6 is evaluated before G5; the placeholder guard matches the documented marker set; messages render offending values between backticks with no `repr`/`!r` (test-enforced). **The one defect is the R5 guard asymmetry documented in the Findings Table.**
- `scripts/dev_tools/validate_orchestration_artifacts.py` (modified, 495 lines): the two-channel threading is well-factored (`validate_plan_text` preserved as the single-channel wrapper; `_plan_channels` builds the seam; `main` derives the exit code from the error channel alone and prints warnings with the fixed prefix after errors). The seven structural error strings are asserted byte-identical by a named test. The `plan` subparser gains only `--workspace-root`, mirroring `epic-planner-state`; the artifact-type surface is unchanged.

### TypeScript implementation audit

- `plan-gate-commands.ts` / `plan-gate-discrimination.ts` / `plan-gate-rules.ts` (new): faithful port; the three-module split keeps every file under the 500-line ceiling with per-file jest thresholds added additively. `evaluateTrackedCovValue` is correctly guarded (the structure the Python side must mirror for R5). No `any`; exported constants for the warning prefix and G5 severity.
- `validate-orchestration-service-call.ts` (modified): the combined error-plus-warning throw path is now covered by the R1 test; the `warnings` field is conditionally projected so a warning-free result is byte-identical to the pre-change shape.
- `mcp-tools.ts` / `repo-automation-service-contract.ts` (modified): additive optional `warnings` projection; the MCP input-schema property-key set is asserted unchanged by named tests.

### PowerShell implementation audit

N/A — zero PowerShell files changed on this branch; `.claude/hooks/validate-planner-output.ps1` verified untouched (AC12).

### C# implementation audit

N/A — zero C# files changed on this branch.

## Test Quality Audit

### Reviewed test and QA artifacts

- Python: the six feature test modules plus the remediation additions (`test_validate_from_args_returns_blocking_channel_only_for_plan`, `test_combined_plan_produces_g1_g5_g6_findings_in_one_evaluation`). All 4057 tests pass this session.
- TypeScript: the eight feature test modules plus the remediation additions (`throws the combined error-and-warning message when both channels are non-empty`; `produces one G1 Blocking finding and two Warnings (G5, G6) in a single combined-plan evaluation`). All 2645 tests pass this session.
- Executor QA evidence: `evidence/qa-gates/*-final.2026-08-20T19-5x/20-0x.md`, `coverage-delta-remediation.2026-08-20T20-05.md`, `coverage-restore-r1/-r3`, `plan-self-validation.2026-08-20T20-10.md`, `self-gate-run-remediation.2026-08-20T20-12.md` — internally consistent and corroborated by this session's independent re-runs.

### Quality assessment

- Tests are deterministic (in-memory fixtures, stub seams, no timers or wall-clock), independent, and AAA-structured with docstrings.
- Parity discipline is strong: shared fixture set asserted string-identical across runtimes, including apostrophe-bearing values; severity constants cross-checked; `repr`-family formatting prohibited by test.
- Gap: the Python degradation suite exercises the raising seam only through the guarded literal path. The unguarded coverage path (R5) is exactly the scenario the suite does not reach — a targeted test would have caught the asymmetry.

## Security / Correctness Checks

- No command injection surface: the git adapter constructs argv lists from fixed verbs plus extracted operands and passes them as lists (no shell string interpolation); `--` separators precede pattern/path operands where applicable.
- No new dependencies in either runtime; no manifest changes.
- Error-message content renders plan-supplied values between backticks without evaluation.
- Graceful-degradation correctness: TypeScript compliant; Python non-compliant on one path (R5, Blocking).
- No temporary files in tests; the corpus-measurement driver was throwaway and is confirmed deleted (absent from the tracked tree).

## Research Log

- Regenerated PR-context artifacts (`--base main --head HEAD`) after finding them absent at session start; confirmed merge-base `8092d391` and head `9e5c141d`.
- Verified R1-R4 closure by direct evidence (lcov parse, grep for named tests, spec/plan checkbox state, deviation note at spec line 68).
- Re-ran the full toolchain in both runtimes (all green, single pass).
- Probe-executed the raising-seam scenario against both the literal and coverage paths; the coverage-path escape (R5) reproduced deterministically; probe deleted after use.
- Verified mirror byte-identity (`cmp`), evidence locations (validator exit 0), jest threshold integrity, file-size ceilings (`wc -l`), and the absence of workflow-trigger paths in the diff.

## Verdict

**Remediation required.** One Blocking finding (R5: Python G2/G3 graceful-degradation escape and the associated runtime divergence). One Minor advisory (M1: non-zero-exit seam semantics) and one Info note (AC10 checkbox reconciliation) accompany it. Everything else delivered by this branch — including all four cycle-1 remediation items — is verified in good order. The fix is small: one guarded-helper extraction in `plan_gate_discrimination.py` mirroring the existing TypeScript structure, plus named tests.
