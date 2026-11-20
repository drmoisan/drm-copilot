# Pester Documentation-Contract Suites (Static Record)

Timestamp: 2026-10-02T01-22
Timestamp-Correction: original value 2026-10-02T01-17 was a Phase 0 start reading reused through Phase 4; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T02-02.md), an upper bound on the command run time.
Command: git ls-files -- tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1 tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
EXIT_CODE: 0
Output Summary:
- Five output lines, one per named path (all five suites are tracked):
  - tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
  - tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1
  - tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1
  - tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1
  - tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
- These suites are verified by CI check `poshqc / PowerShell QC` (`.github/workflows/_poshqc.yml`, scanning `tests/scripts` per `config/poshqc-scan.json`) in Post-CI step 1, because the worktree-isolated executor has no PowerShell tool and the isolation guard refuses pwsh text.
