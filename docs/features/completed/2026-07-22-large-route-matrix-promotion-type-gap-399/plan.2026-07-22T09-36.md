# large-route-matrix-promotion-type-gap (Plan)

- **Issue:** #399
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-22T09-36
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** minor-audit (per `- Work Mode: minor-audit` marker in issue.md)
- **Route:** small
- **Language in scope:** Python only (config JSON + Python validator + Python unit tests). No PowerShell, TypeScript, or C# toolchain applies.

## Requirements Source

Sole requirements source: `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/issue.md`. Only its explicit `## Acceptance Criteria` section (5 checkbox items) is the acceptance-criteria source. `spec.md`, `user-story.md`, and `research.md` are intentionally absent for minor-audit and are not required. Execution must fail closed if `spec.md` or `user-story.md` unexpectedly appears in the active folder or if the `## Acceptance Criteria` section is missing from `issue.md`.

## Evidence Location (Non-Overridable)

All evidence artifacts MUST resolve to `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Non-canonical locations such as `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/` are rejected. Timestamps use the ISO-8601 format `yyyy-MM-ddTHH-mm`.

**Fail-closed evidence rule:** If any required baseline artifact, final-QC artifact, or coverage-comparison artifact is missing or has incomplete schema fields (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`), the corresponding plan task must remain unchecked and the outcome is remediation-required, never PASS.

**No-SKIPPED rule:** Every command-bearing task in this plan is unconditional. `EXIT_CODE: SKIPPED` is not a valid outcome for any task below; no task text authorizes a skip branch.

## Defect Summary (Context for Preflight)

`config/orchestration-routing.json` `routes.large` (1) lists two `required_skills` names — `orchestrator-workflow` and `repo-automation-adapter` — that have no skill file under `.claude/skills/`, and (2) both `routes.small` and `routes.large` hardcode `new_potential_entry` in `required_mcp_tools` regardless of promotion type, so `validate_routing_contract` in `scripts/dev_tools/_orchestrator_state_routing.py` can never pass `--require-complete` for a bug-type promotion (the correct bug-type tool is `new_potential_bug_entry`).

## Fix Scope (Carried by the Phase 1 Placeholder)

The following four implementation requirements define the constrained small-path scope. The executor implements them; this plan records them so preflight can validate preconditions.

1. **Config edit — remove dead skill names.** Edit `config/orchestration-routing.json`: remove `orchestrator-workflow` and `repo-automation-adapter` from `routes.large.required_skills` (removal, not skill creation — neither name exists under `.claude/skills/` and there is no evidence the skills are planned). The remaining large-route skills become the same set already used by `routes.small`, all of which exist: `orchestrate`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `acceptance-criteria-tracking`, `pr-context-artifacts`, `pr-base-branch-merge-base`.
2. **Parity constraint (CRITICAL).** A byte-identical bundled mirror of the config exists at `extensions/drm-copilot/resources/config/orchestration-routing.json`, guarded by `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`. The identical edit MUST be applied to BOTH files or the parity test fails.
3. **Promotion-type-aware validator.** In `scripts/dev_tools/_orchestrator_state_routing.py`, make `validate_routing_contract` resolve the promotion-entry MCP tool from the checkpoint's `promotion-type` key: when `promotion-type == "bug"`, the expected `required_mcp_tools` list substitutes `new_potential_bug_entry` in place of `new_potential_entry`; for `feature` (and default/absent), the list is unchanged (`new_potential_entry`). Apply the resolved list to BOTH the exact-match check against the checkpoint's recorded `required_mcp_tools` (currently via `_state_list`, lines 503-507) AND the MCP-receipt presence loop (lines 519-522), so the resolution is consistent. The resolution is generic (it applies to any route whose `required_mcp_tools` contains the promotion-entry tool, including `small`), backward-compatible (feature/absent promotion-type behavior is byte-identical to today), and preserves exact-match semantics. Feature-type is not weakened: feature promotions still require `new_potential_entry`.
4. **Unit tests.** Add Python unit tests in `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` covering: (a) a synthetic large-route bug-type checkpoint recording a truthful `new_potential_bug_entry` MCP receipt (and no `orchestrator-workflow`/`repo-automation-adapter` skill receipts) passes `validate_routing_contract` with zero errors; (b) the large-route feature-type case still passes with `new_potential_entry` (no regression); (c) removal of the dead skill names from `routes.large.required_skills` is asserted; optionally (d) a bug-type checkpoint that records only `new_potential_entry` is rejected. Tests follow `.claude/rules/general-unit-test.md` and `.claude/rules/python.md`: no temp files, deterministic, Arrange–Act–Assert structure, mirrored test layout.

## Acceptance-Criteria Mapping (issue.md `## Acceptance Criteria`, 5 items)

- AC1 (dead skill names removed or skills created) → Fix step 1 (removal in both config files).
- AC2 (`required_mcp_tools` reflects correct promotion tool per promotion type) → Fix steps 1 + 3.
- AC3 (bug-type synthetic checkpoint passes with zero errors) → Fix step 3, verified by test (a).
- AC4 (feature-type case still passes, no regression) → Test (b).
- AC5 (unit test coverage added for both fixed behaviors) → Fix step 4.

## Coverage Policy

Python coverage policy applies: >= 85% line, >= 75% branch, no regression on changed lines. Baseline capture (P0-T5), final-QC capture (P2-T4), and delta/threshold verification (P2-T5) are mandatory and must record numeric values, not placeholders.

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read policy files in the required order — (1) `CLAUDE.md`, (2) `.claude/rules/general-code-change.md`, (3) `.claude/rules/general-unit-test.md`, (4) `.claude/rules/python.md`, (5) `.claude/rules/python-suppressions.md` — and write `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of files read. Acceptance: artifact exists at that path with all three fields populated and lists all five policy files.
- [x] [P0-T2] Run baseline formatting check `poetry run black --check .` from repo root and write `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/baseline/baseline-black.<timestamp>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact exists with all four fields and a concrete pass/fail signal in `Output Summary:`.
- [x] [P0-T3] Run baseline lint `poetry run ruff check .` from repo root and write `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/baseline/baseline-ruff.<timestamp>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact exists with all four fields and the ruff finding count (or "all checks passed") in `Output Summary:`.
- [x] [P0-T4] Run baseline type check `poetry run pyright` from repo root and write `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/baseline/baseline-pyright.<timestamp>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact exists with all four fields and the pyright error/warning counts in `Output Summary:`.
- [x] [P0-T5] Run baseline tests with coverage `poetry run pytest --cov --cov-branch --cov-report=term-missing` from repo root and write `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/baseline/baseline-pytest.<timestamp>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with the numeric baseline coverage headline (total line coverage percent, branch coverage percent when reported) and pass/fail test counts. Acceptance: artifact exists with all four fields and numeric coverage values (no placeholders such as `UNVERIFIED`).

### Phase 1 — Constrained Small-Path Implementation

- [x] [P1-T1] Delegate to the small-path implementation engineer (`python-typed-engineer`) to implement fix steps 1–4 exactly as defined in `## Fix Scope` above, touching only: `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` (byte-identical mirror edit — mandatory), `scripts/dev_tools/_orchestrator_state_routing.py` (`validate_routing_contract` promotion-type resolution applied to both the `_state_list` exact-match check and the MCP-receipt loop), and `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` (tests a, b, c, and optionally d). Acceptance: all four fix steps are complete; both config files remain byte-identical; `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` passes; the new tests in `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` pass; feature-type and absent-promotion-type validator behavior is unchanged; no files outside the four listed paths are modified.

### Phase 2 — Final QC Loop

Rerun behavior: run P2-T1 through P2-T4 in order. If any step fails or changes files, fix the cause and restart the loop from P2-T1 until all four steps pass cleanly in a single pass. Each task below is unconditional; no SKIPPED completion path exists.

- [x] [P2-T1] Run final formatting `poetry run black .` from repo root and write `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/qa-gates/final-black.<timestamp>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (files reformatted count or "no changes"). Acceptance: artifact exists with all four fields and `EXIT_CODE: 0` in the final clean pass.
- [x] [P2-T2] Run final lint `poetry run ruff check .` from repo root and write `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/qa-gates/final-ruff.<timestamp>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact exists with all four fields and `EXIT_CODE: 0` in the final clean pass.
- [x] [P2-T3] Run final type check `poetry run pyright` from repo root and write `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/qa-gates/final-pyright.<timestamp>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (error/warning counts). Acceptance: artifact exists with all four fields and `EXIT_CODE: 0` in the final clean pass.
- [x] [P2-T4] Run final tests with coverage `poetry run pytest --cov --cov-branch --cov-report=term-missing` from repo root and write `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/qa-gates/final-pytest.<timestamp>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with numeric post-change coverage values (total line percent, branch percent when reported) and pass/fail test counts. Acceptance: artifact exists with all four fields, `EXIT_CODE: 0` in the final clean pass, and numeric coverage values (no placeholders).
- [x] [P2-T5] Write the coverage delta/threshold verification artifact `docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/evidence/qa-gates/coverage-comparison.<timestamp>.md` containing `Timestamp:`, the baseline coverage values from P0-T5, the post-change coverage values from P2-T4, the changed-code coverage for the modified lines in `scripts/dev_tools/_orchestrator_state_routing.py`, and an explicit verdict that (a) line coverage >= 85%, (b) branch coverage >= 75%, and (c) coverage on changed lines did not regress. Acceptance: artifact exists with numeric baseline, post-change, and changed-code values and an explicit pass verdict for all three thresholds; if any threshold fails, the outcome is remediation-required, not PASS.
