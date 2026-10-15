# Back-Compat Corpus and Test Hashes (P1-T13)

Timestamp: 2026-10-01T21-35
Task: P1-T13
Route: sh-wrapped pwsh -NoProfile -Command

Command: Get-ChildItem -LiteralPath tests/fixtures/orchestrator_state_remediation_loop_backcompat -File | ForEach-Object FullName | Get-FileHash -Algorithm SHA256; Get-FileHash -Algorithm SHA256 -LiteralPath tests/fixtures/orchestrator_state_remediation_loop_backcompat_expected.json,tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_backcompat.py,extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-backcompat.test.ts,tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1
(executed with a trailing projection that renders each path relative to the worktree root with forward slashes, so no absolute path is recorded)
EXIT_CODE: 0

| SHA256 | Path |
|---|---|
| DA0B665A41C198303C2771356A640A21841B3821055647AF56484A5F64C180F3 | tests/fixtures/orchestrator_state_remediation_loop_backcompat/codex_remediation_pass_key.json |
| 6527474003A133E2F27DB6C05C5324E9A49F334FAACBC1BE17AE5173B609F0C0 | tests/fixtures/orchestrator_state_remediation_loop_backcompat/cycle_non_object.json |
| B52696D956900EFCF85734912FCAB0877926F31D5D0E6AC9301DE28C5F90FF4E | tests/fixtures/orchestrator_state_remediation_loop_backcompat/cycles_object.json |
| FBA173830C1071807A74573E46B62F194EE9489CA51BAD3491C3AF8A21C0D32E | tests/fixtures/orchestrator_state_remediation_loop_backcompat/cycles_string.json |
| FBC4821E1C0CC57E2E7E4F8AFD60B74DFE1D74CCA3873C365DABEEE668E85269 | tests/fixtures/orchestrator_state_remediation_loop_backcompat/legacy_current_cycle.json |
| A87D983C6226FFECADDF34EC4030EE337469B4144091EB8C691A56ED3F81FC12 | tests/fixtures/orchestrator_state_remediation_loop_backcompat/no_remediation_loop.json |
| EDCE7DC24AEC5786EB10752D3F8EC08A0A506479488C000E33386B8986280CC9 | tests/fixtures/orchestrator_state_remediation_loop_backcompat/remediation_loop_non_object.json |
| 587E15A735613EA710F6AFE5A59E6455640BB043E3BDA89A5ED5683AD3291BC1 | tests/fixtures/orchestrator_state_remediation_loop_backcompat/valid_legacy_cycle.json |
| 67BA97D6EE821D0C4D51B99C470D94A2DEB1EF62B31A695CF9DEEFEDC2CBA6FB | tests/fixtures/orchestrator_state_remediation_loop_backcompat/violation_execution_before_clear_preflight.json |
| D919D3C3EB4BBB1D9E72F46D809B4ECD6ED3F6CCBDFEB6B795856B454F76CD7F | tests/fixtures/orchestrator_state_remediation_loop_backcompat/violation_exit_with_blocking_findings.json |
| EF06A99CF2808944ABEACF0CDCCB6E102923C92D74E71E037BA588BF2D79F6FA | tests/fixtures/orchestrator_state_remediation_loop_backcompat/violation_plan_path_empty.json |
| 0E8CAEF885A27EA4EFB29DA3E2398A17E983A34F42DA6AAB32C2D1E0F9D54678 | tests/fixtures/orchestrator_state_remediation_loop_backcompat_expected.json |
| 395D08C36431727B05BB0E3FA018FEE1B4E8BB8FEA1D8A3127909582F1B86986 | tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_backcompat.py |
| 0584309DCA34C829E1FE51DF72931D133D33038F38EBBD127E48E5E650506411 | extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-backcompat.test.ts |
| 69155297A70385F81214553C76BA2B590AA454C069C0CB9136C2D2AFB43B9544 | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 |

Output Summary: Fifteen SHA256 hashes recorded (eleven fixtures, the expected file, three test files), computed over the working-tree bytes at HEAD a2ac3c18.
