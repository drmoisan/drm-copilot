# Baseline — TypeScript Test and Coverage (F2)

Timestamp: 2026-06-25T23-14
Command: node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"
EXIT_CODE: 0
Output Summary:
- Test Suites: 41 passed, 41 total
- Tests: 492 passed, 492 total
- Coverage for `src/lib/**` (current F1 set; `src/lib/validate/**` does not yet exist):
  - All files: 97.3% Stmts, 88.13% Branch, 100% Funcs, 97.3% Lines
  - file-system.ts: 96.47% Lines, 86.2% Branch
  - json-config.ts: 96.19% Lines, 83.33% Branch
  - markdown-label-formatter.ts: 95.85% Lines, 87.87% Branch
  - prompt-mode-contract.ts: 100% Lines, 96.29% Branch
  - subprocess-runner.ts: 98.59% Lines, 82.35% Branch
- Baseline `src/lib/**` line coverage: 97.3%
- Baseline `src/lib/**` branch coverage: 88.13%
- `src/lib/validate/**` contributes nothing to this baseline (directory absent).

P0-T2 source-read confirmation (all read, none modified):
- scripts/dev_tools/validate_orchestration_artifacts.py
- scripts/dev_tools/validate_orchestrator_state.py
- scripts/dev_tools/_orchestrator_state_human_interaction.py
- scripts/dev_tools/_orchestrator_state_routing.py
- scripts/dev_tools/validate_orchestration_review_artifacts.py
- scripts/dev_tools/validate_policy_audit_artifact.py
- scripts/dev_tools/validate_evidence_locations.py
- scripts/dev_tools/validate_json.py
- extensions/drm-copilot/src/lib/file-system.ts (F1 reuse)
- extensions/drm-copilot/src/lib/json-config.ts (F1 reuse)
