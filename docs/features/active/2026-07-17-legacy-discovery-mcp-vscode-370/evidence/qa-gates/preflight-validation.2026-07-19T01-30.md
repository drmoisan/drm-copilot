# Preflight Validation — plan.2026-07-17T15-08.md (issue #370)

Timestamp: 2026-07-19T01-30
Directive: PREFLIGHT VALIDATION ONLY
Plan: docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/plan.2026-07-17T15-08.md
Work Mode: full-feature (AC sources: spec.md + user-story.md — both present)
Result: PREFLIGHT: ALL CLEAR

## 1. Production files and file-size headroom

| File | Measured lines | Plan claim | Consistent |
|---|---|---|---|
| src/repo-automation-service.ts | 497 | 498 (needs extraction) | Yes (off-by-1, trailing newline; headroom claim valid) |
| src/mcp-repo-automation-tool-definitions.ts | 488 | 489 (spread keeps under cap) | Yes |
| src/mcp-tool-definitions.ts | 435 | under cap | Yes |
| src/mcp-tools.ts | 269 | under cap | Yes |
| src/extension.ts | 488 | 489 (new module for registration) | Yes |
| src/runtime-detection.ts | 211 | RuntimeKind powershell-only | Yes (`export type RuntimeKind = "powershell"`, `findExecutableOnPath` present) |

All referenced existing helper/test files present: runtime-test-helpers.ts, command-runtime.test.ts, mcp-push-down-schema-properties.ts (workspaceRootProperty), extension-command-helpers.ts, repo-automation-command-registration-feature-workflows.ts, extension-test-harness.ts, the four createMockService test files, mcp-repo-automation-tool-definitions.test.ts, src/mcp-handlers/, jest.config.cjs. REPO_AUTOMATION_TOOLS, dispatchRepoAutomationTool (no `default:` arm), and toMcpToolResult present.

## 2. Toolchain runnable

- node_modules installed under extensions/drm-copilot/; node_modules/.bin/jest present; run-jest.cjs present.
- Scripts map: format → prettier --write; lint → eslint; typecheck → tsc -p ./ --noEmit; test:coverage → node run-jest.cjs --coverage --coverageReporters=text-summary. Matches plan.

## 3. Reconciled substrate facts (verified against pyproject.toml [tool.poetry.scripts] and landed Python CLIs)

- validate_discovery_artifacts: 8 per-kind functions (main_profile, main_feature_contract, main_coverage_ledger, main_runtime_scenario, main_parity_matrix, main_unspecified_behavior, main_product_decision, main_evidence_reference) + main for `all` = 9 entries; artifact_type enum of 8 kinds + `all` matches.
- run_discovery_init → scripts.dev_tools.discovery.init_cli:main; positional target_dir (required), --template-root, --force. Verified.
- inventory → analyzer.cli:main (positional profile, --output-dir, --json; written_paths in JSON). dotnet/vsto → analyzer.stack_cli:main_dotnet/main_vsto (present; no bare `main`, consistent with `-c` rationale).
- scenario generation → generate_acceptance_scenarios:main; required --feature-contract, --parity-matrix, --runtime-characterization; optional --output, --check. Verified.
- report: coverage → coverage_report:main (--input required, --output); parity → parity_report:main (--input required, --output); completion → completion_report:main (--coverage-input AND --parity-input both required, --output). Two-input completion report and report_type-aware inputs confirmed.
- Invocation mechanism: interpreter `-c` importing `module:function` — internally consistent with landed entries.
- Evidence paths: all resolve under docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/{baseline,qa-gates}/. No artifacts/ evidence path used.

## 4. Phase 0 and Phase 8 artifact fields

- P0-T1 requires Timestamp/Policy Order/file list; P0-T2..T5 require Timestamp/Command/EXIT_CODE/Output Summary; P0-T5 requires numeric baseline line % and branch % plus test counts.
- P8-T1..T4 require Timestamp/Command/EXIT_CODE/Output Summary; P8-T4 requires numeric post-change line %/branch %; P8-T6 coverage-delta requires numeric baseline, post-change, and per-new-file values.

## Structure

Phase headings `### Phase N — Title`; tasks `- [ ] [P#-T#]` with sequential per-phase IDs (P0-T1..T5, P1..P8). Format and structure valid.
