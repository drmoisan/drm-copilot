# PowerShell Batch-1 Test (P2-T9)

- Timestamp: 2026-07-02T20-30
- Command: `mcp__drm-copilot__run_poshqc_test` (scan folder: `tests/scripts/claude-hooks`)
- EXIT_CODE: 0

## Output Summary

Full suite: 421 tests, 0 failures, 0 errors (`artifacts/pester/pester-junit.xml`).
Batch-1-relevant files: `enforce-epic-merge-gate.Tests.ps1` 30 passed;
`enforce-pr-author-skill.Tests.ps1` 46 passed; `enforce-pr-author-skill.epic-base-branch.Tests.ps1`
9 passed; `validate-orchestrator-output.Tests.ps1` 30 passed.

**Coverage scope note:** the bundled MCP toolchain's shared `pester.runsettings.psd1`
`CodeCoverage.Path` is a curated allowlist that does not include the three batch-1
production files (`validate-orchestrator-output.ps1`, `enforce-pr-author-skill.ps1`,
`enforce-epic-merge-gate.ps1`); editing that shared config was reverted after discovery
that the MCP tool resolves a bundled copy independent of this repo's checked-in file
(`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`,
which already diverges from the repo copy pre-existing this plan). Per the established
repository precedent (e.g. `docs/features/archive/.../evidence/baseline/typescript-test...`
pattern and prior Pester-coverage baselines in this repo), a supplemental targeted
`Invoke-Pester` run was executed for numeric per-file measurement only; the MCP gate above
(`ok: true`, 0 failures) remains the authoritative pass/fail signal.

Supplemental targeted coverage (`artifacts/pester/batch1-coverage.xml`, JaCoCo):

| File | LINE | INSTRUCTION (branch proxy) |
|---|---|---|
| `enforce-epic-merge-gate.ps1` | 93.42% (71/76) | 92.47% (86/93) |
| `enforce-pr-author-skill.ps1` | 91.60% (109/119) | 91.55% (130/142) |
| `validate-orchestrator-output.ps1` | 86.96% (80/92) | 88.96% (145/163) |
| **TOTAL (batch-1)** | **90.59% (260/287)** | **90.70% (361/398)** |

Both the 85% line-coverage floor and 75% branch-coverage floor are met for every batch-1
file individually and in aggregate.
