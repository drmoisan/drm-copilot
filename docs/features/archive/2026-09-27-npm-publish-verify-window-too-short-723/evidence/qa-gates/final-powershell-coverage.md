# Final QA Gate: PowerShell Coverage (CI poshqc)

Timestamp: 2026-10-01T18-30

Command: gh run download 36927150048 --repo drmoisan/drm-copilot -n poshqc-test-results

EXIT_CODE: 0

Output Summary:

- Artifact name: `poshqc-test-results`; file: `powershell-coverage.xml` (JaCoCo-style report-level LINE counter), extracted by the orchestrator.
- Run: https://github.com/drmoisan/drm-copilot/actions/runs/36927150048
- Job: "poshqc / PowerShell QC", job id 110587188174, head 9a6e0aa7.
- LINE counter: missed 430, covered 11353.
- Line coverage: 11353 / (430 + 11353) = 11353 / 11783 = 96.35 percent against the 85 percent threshold. Result: meets threshold.
- Branch coverage: no branch metric exists for PowerShell (Pester exempt per `.claude/rules/general-unit-test.md`); no branch gate applies.
- No production `.ps1` file changed on this branch. The only changed `.ps1` is the Pester test file `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`; see `evidence/qa-gates/final-no-source-change-check.md`.
