Timestamp: 2026-07-04T02-25

Chosen path: `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`

Rationale: `.claude/rules/powershell.md` "Testing Standards" requires organizing tests to mirror code structure (e.g., `tests/scripts/dev-tools/ScriptName.Tests.ps1`) and naming test files `*.Tests.ps1`. The chosen filename places the new sibling test file in the same directory as the production script's existing test file (`tests/scripts/dev-tools/`), mirrors the production script's location (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1`), retains the `Invoke-FullReleaseFlow` base name so the relationship to the production script is unambiguous, and ends with the required `.Tests.ps1` suffix.
