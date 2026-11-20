# Code Review: Claude Planning Integrity (#593)

**Review Date:** 2026-08-29
**Feature Folder:** `docs/features/active/2026-08-29-claude-planning-integrity-593`
**Base Branch:** `main` at `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b`
**Head Branch:** `feature/claude-planning-integrity-593` at `56c2611245dfde879f44ca7cb72762e7fb0bf035`
**Review Type:** Post-remediation re-review, pass 1

## Executive Summary

The full feature-to-base diff was re-reviewed using the fresh PR-context pair generated at 2026-08-29 17:50:57 UTC. The prior coverage blocker is resolved: the independent focused test rerun passes, recorded coverage satisfies the relevant thresholds, and canonical Claude runtime files match their bundle mirrors. One blocker remains: the new PRD feature-output validation hook is not referenced by the runtime's `SubagentStop` configuration.

**PR readiness recommendation:** **Needs Revision** — register the validator in the canonical settings and published settings mirror, with a focused registration test.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/settings.json` and `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` | `hooks.SubagentStop` | Neither settings file registers `pwsh -NoProfile -File .claude/hooks/validate-prd-feature-output.ps1` for `matcher: "prd-feature"`. | Add byte-identical canonical and bundle registrations; add a focused test that asserts both registrations. | The validator exists and is covered in isolation but is never invoked at `prd-feature` termination, so malformed numeric acceptance criteria can pass the runtime lifecycle. | Full settings inspection; `rg` found only planner validator registration; 72 Pester and 29 Python tests pass without proving hook wiring. |

## Implementation Audit

### PowerShell implementation audit

The named-section counter stops at an equal-or-shallower heading and its fixture includes unrelated checkboxes before and after the target section. Numeric provenance validators check required evidence fields, distinct search text, counts, and normalized member-set agreement. Planner and parallel-intake changes preserve the existing executor preflight path and scope boundary.

The missing `SubagentStop` registration is the remaining integration failure. No unsafe subprocess construction, secret handling, or broad error swallowing was found in the changed runtime code.

### Python implementation audit

Python changes are focused contract tests. The tests confirm required wording and bundle coverage, but no test asserts that the newly added validator is wired into settings.

## Test Quality Audit

- Pester rerun over four focused suites: 72 passed, 0 failed.
- Python contract rerun over three focused suites: 29 passed.
- Prior exact-head evidence records the repaired coverage: 90.00% task-researcher, 93.75% PRD hook, and 100.00% eligible new PRD-hook lines.
- `git diff --check` against the resolved merge base returned no whitespace errors.

The test gap is configuration-level rather than unit-level: direct dot-sourcing validates the hook function but cannot prove the Claude runtime executes it.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Full changed-file review found no credentials or secret-file references. |
| No unsafe subprocess construction | PASS | New code uses PowerShell file operations and regular expressions only. |
| Input validation at boundaries | PARTIAL | Validator input checks are present, but the PRD validator is not registered at its lifecycle boundary. |
| Error handling remains explicit | PASS | Hook validation returns actionable failure messages. |
| Configuration / path handling is safe | FAIL | The required settings integration is absent. |

## Research Log

No external research was required. The feature is governed by repository-local Claude runtime contracts, settings, hooks, tests, and the fresh PR-context artifact pair.

## Verdict

The feature is not ready for PR flow. Remediation must wire `validate-prd-feature-output.ps1` into `prd-feature` `SubagentStop` handling in both canonical and published settings, add a focused integration-contract test, and rerun the applicable PowerShell and Python validation paths.
