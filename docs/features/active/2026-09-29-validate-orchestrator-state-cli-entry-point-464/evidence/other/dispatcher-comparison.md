# Dispatcher Comparison (Issue #464)

Timestamp: 2026-09-30T09-22
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/evidence/other/valid-checkpoint.json
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/evidence/other/invalid-checkpoint.json
EXIT_CODE: 0 (valid file), 1 (invalid file)
Output Summary:
- Valid file: dispatcher exit code 0 and stdout `orchestrator-state validation passed: <path>`, identical to the bare-module CLI result in `repro-after-valid.md` (exit code 0, same stdout line).
- Invalid file: dispatcher exit code 1 with the same 22 `Checkpoint missing required key: ...` stderr lines, in the same order, as the bare-module CLI result in `repro-after-invalid.md` (exit code 1).
- The dispatcher exit codes (0 and 1) equal the codes recorded for the bare-module CLI in P8-T3 and P8-T4.
