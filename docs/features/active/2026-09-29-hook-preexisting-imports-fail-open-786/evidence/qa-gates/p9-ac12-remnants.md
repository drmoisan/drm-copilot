# AC-12 Remnant Search ([P9-T5])

Timestamp: 2026-10-10T00-40
Command: fresh pwsh process running <SCRATCHPAD>/p9t5.ps1: `Select-String -Pattern '\$script:(\w+ImportFailure)'` over every .ps1 file under .claude/hooks and extensions/drm-copilot/resources/claude-customizations/.claude/hooks (118 files), classified against the W-EXEMPT-VARIABLES of exemption-decisions.md; `Select-String -SimpleMatch -Pattern 'Import guard (issue #690)'`; `Select-String -SimpleMatch -Pattern 'ImportFailureDecision'`; C3 status read from p6-special-cases.md
EXIT_CODE: 0
Output Summary: NON_EXEMPT_MATCHES: 0; IMPORT_GUARD_690_MATCHES: 0; IMPORT_FAILURE_DECISION_MATCHES: 0; each of the six W-EXEMPT variables has at least one match (6 to 10, across the hook and mirror copies); C3 is PASSED in p6-special-cases.md.

```text
FILES: 118
NON_EXEMPT_MATCHES: 0
EXEMPT_MATCHES: FeatureFolderOrderResolutionImportFailure | 8
EXEMPT_MATCHES: OrchestrationFeatureFolderResolutionImportFailure | 10
EXEMPT_MATCHES: PrdFeatureFolderResolutionImportFailure | 6
EXEMPT_MATCHES: EpicWaveBarrierResolutionImportFailure | 10
EXEMPT_MATCHES: ParallelDriftGateResolutionImportFailure | 10
EXEMPT_MATCHES: ParallelCohortBarrierResolutionImportFailure | 10
IMPORT_GUARD_690_MATCHES: 0
IMPORT_FAILURE_DECISION_MATCHES: 0
C3: PASSED (p6-special-cases.md)
```
