# Phase gate P2

Timestamp: 2026-11-18T05-25
Command: (1) Invoke-PoshQCFormat then Invoke-PoshQCAnalyze over the scan folders `scripts` and `tests/scripts` (SCRATCH helper); (2) actionlint .github/workflows/_npm-audit-gate.yml (see actionlint.2026-11-18T05-06.md); (3) sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one launcher gate run, repository-wide)
EXIT_CODE: 0
Output Summary:
- Stage 1 format: `FORMAT_FORMATTED_COUNT=0`, 937 files already formatted (no file rewritten). Prettier on the changed JSON and YAML files passes; the two changed Markdown ledger files do not pass Prettier, and the already committed ledger entries 0011 and 0012 fail it the same way, so Markdown ledger style is not a formatter-gated surface.
- Stage 2 lint: Invoke-PoshQCAnalyze `PSScriptAnalyzer passed: no findings` (count 0); actionlint 1.7.12 exit 0 with empty output. Type check: not applicable (no Python or TypeScript file changed). Architecture-boundary and contract-check stages: the ledger contract tests (chain, index, ledger, replay) are part of the Pester run.
- Stage 5 unit tests, clean pass with no restart: `Invoke-PoshQCParallelTest: workers=8; wall-clock=738.9s; exit code=0`; `pester-junit.xml`: 27604 tests, 0 failures, 0 errors, 18 skipped. The run includes NpmAuditGateWorkflow.Tests.ps1, NpmAuditGate.Tests.ps1, Invoke-NpmAuditGate.Tests.ps1, and the ledger suites with entry 0013.
- Coverage of this run (informational at a phase gate): repo-wide 45073/46925 = 96.05%; scripts/ci/NpmAuditGate.psm1 100%; scripts/ci/Invoke-NpmAuditGate.ps1 90.91%.
