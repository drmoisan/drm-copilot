# Task Check P1-T5

Timestamp: 2026-11-19T08-38
Plan: plan.2026-10-30T18-39.md
Changed files (under `tests/scripts/claude-runtime/`): `documentation-workflow.CommitStage.Tests.ps1` (`$script:WorkflowCopyRows` and `$script:BriefCopyRows` drop the Copilot and Copilot-bundle rows; synopsis "all four copies"); `less-evidence-contract.Tests.ps1` (`CONTRACT-GITHUB*` rows, the `WORKFLOW-GITHUB*` row set and its unused `$githubBundle` variable removed); `light-remediation-skill-contract.Tests.ps1` (both Copilot rows); `owner-directives-skill-contract.Tests.ps1` (`$script:SkillCopy` Copilot rows; description "four byte-identical copies"); `NestingDepthContract.Tests.ps1` (`$script:BriefFiles` Copilot rows); `parallel-gate-wording.Tests.ps1` (`PLAN-GITHUB*`, `REVIEW-GITHUB*`, the retired sweep root, and also the `BRIEF-GITHUB*` rows and the `test-execution-policy` `GITHUB*` rows of `PGW-SCOPED`, which name files P1-T9 deletes); `planning-contract-wording.Tests.ps1` (the `GITHUB` rows of `$script:ContractCopy` and `$briefCopy`, and `HANDOFF-GITHUB`); `test-cadence-wording.Tests.ps1` (the contract and brief `GITHUB` base rows, whose bundle rows are derived from them, and the retired sweep root). Agent rows unchanged.
LEDGER-STEP (REGION-MAP): `docs/engineering/process-reductions/patches/0009-less-evidence.patch` create hunk of `less-evidence-contract.Tests.ps1` regenerated from the live file (`@@ -0,0 +1,246 @@`); `patches/0001-parallel-only-test-gates.patch` create hunk of `parallel-gate-wording.Tests.ps1` and `patches/0006-test-suite-baseline-restored.patch` hunks on the same file regenerated so both images drop the retired rows and sweep root. `patches/0008-g13-guideline-cutoff.patch` hunks on `planning-contract-wording.Tests.ps1` hold no removed row and are unchanged.
Selection rule: the eight changed suites; LEDGER-STEP adds `LEDGER-CHAIN-TESTS`, `ProcessReductionLedger.Replay.Tests.ps1` and `ProcessReductionLedger.Index.Tests.ps1`.

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the 8 suites (SCRATCH helper) | 0 | 0 findings |
| `Invoke-Formatter` comparison over the 8 suites (SCRATCH helper) | 0 | 0 files differ |
| `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <8 suites> <4 ledger suites>` | 0 | Invoke-PoshQCParallelTest exit code 0 (workers 8, 157.05s) |
| Grep for RETIRED-PATH over the 8 suites | 0 | 0 matches |

Earlier attempts in this task (not gates): a first run failed `PRC-LEDGER-CHAIN-HOLDS` because the scratch patch helper replaced apostrophes in hunk lines; the patches were restored from scratch copies of the committed files and regenerated. A second run failed on two 0006 hunks because the drop list omitted the `-BUNDLE` row identifiers; the list was completed and the hunks regenerated from the committed copies again. The third run is the one recorded above.

Also recorded: the P0-T6 PowerShell static baseline was re-run over all 14 files at MB (`static-baseline-powershell-pssa.2026-11-19T08-38.md`, `static-baseline-powershell-formatter.2026-11-19T08-38.md`), because the first run bound only one file; both still report 0 findings.
