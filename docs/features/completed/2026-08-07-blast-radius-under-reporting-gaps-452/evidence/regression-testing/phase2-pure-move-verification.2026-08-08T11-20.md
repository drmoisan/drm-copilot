# Phase 2 — PowerShell Pure-Move Verification (full toolchain)

Timestamp: 2026-08-08T11-20
Task: [P2-T5]

Command: `mcp__drm-copilot__run_poshqc_format` then `mcp__drm-copilot__run_poshqc_analyze` then
`mcp__drm-copilot__run_poshqc_test`, each with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5c761b8f1a691079`
and no `scan_folders` override, so the test stage resolves
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

EXIT_CODE: 0 (format), 0 (analyze), 2 (test — see the exit-code section below)

## Stage results

| Stage | Command | EXIT_CODE | Result |
| --- | --- | ---: | --- |
| 1 Format | `run_poshqc_format` | 0 | 0 files modified |
| 2 Lint | `run_poshqc_analyze` | 0 | 0 PSScriptAnalyzer findings at every severity |
| 3 Test | `run_poshqc_test` | 2 | 1984 passed, 2 failed, 0 errors, 9 skipped of 1995 |

The formatter modified no file. Verified by re-hashing both edited modules after the format stage:
`BlastRadiusExtraction.psm1` is 17499 bytes with SHA-256 `da8194d03e0bedd2...` and
`BlastRadiusGlob.psm1` is 13234 bytes with SHA-256 `a0241d6c1fcd6db6...`, byte-identical to their
pre-format state. No loop restart was required.

## Pure-move proof: counts equal the P0-T9 baseline exactly

| Metric | P0-T9 baseline | P2-T5 post-move | Delta |
| --- | ---: | ---: | ---: |
| Total | 1995 | 1995 | 0 |
| Passed | 1984 | 1984 | 0 |
| Failed | 2 | 2 | 0 |
| Errors | 0 | 0 | 0 |
| Skipped | 9 | 9 | 0 |

Every count is identical to the baseline, and the two failures are the same two tests, with the
same messages, as the baseline:

1. `enforce-pr-author-skill.Tests.ps1` -
   `allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `codex-pretooluse-integration.Tests.ps1` -
   `allows every registered handler for every tool name its own matcher admits`

Both are the pre-existing environmental failures analysed in the P0-T9 baseline artifact: two hook
suites read the real, gitignored `artifacts/orchestration/orchestrator-state.json`
(`epic_mode: true`, `epic_context.integration_branch = epic/parallel-orchestration-integration`)
instead of a mocked seam. Neither test touches `.claude/lib/blast-radius/`. The delta introduced
by Phase 2 is zero failures.

## Exit-code attribution

The test stage exits 2 solely because of those two pre-existing environmental failures. The
[P2-T5] acceptance clause "all three commands exit 0" is therefore not literally satisfied at the
test stage, and this artifact records that plainly rather than reporting a pass. The substantive
acceptance clause — "the Pester passed/failed counts equal the P0-T9 baseline counts, proving the
move is behaviour-preserving" — is fully satisfied, with a delta of exactly zero on every count.
No test was modified, skipped, or weakened to reach this result.

## Blast-radius suites specifically: 284 passed, 0 failed

| Suite | Passed | Failed | Skipped |
| --- | ---: | ---: | ---: |
| `BlastRadius.Conflict.Tests.ps1` | 27 | 0 | 0 |
| `BlastRadius.Manifest.Tests.ps1` | 4 | 0 | 0 |
| `BlastRadius.Parity.Tests.ps1` | 52 | 0 | 0 |
| `BlastRadius.Tests.ps1` | 35 | 0 | 0 |
| `BlastRadius.Validation.Tests.ps1` | 31 | 0 | 0 |
| `BlastRadiusConfig.Tests.ps1` | 42 | 0 | 0 |
| `BlastRadiusExtraction.Path.Tests.ps1` | 37 | 0 | 0 |
| `BlastRadiusExtraction.Tests.ps1` | 21 | 0 | 0 |
| `BlastRadiusGlob.Tests.ps1` | 35 | 0 | 0 |
| **Total** | **284** | **0** | **0** |

`BlastRadius.Manifest.Tests.ps1` passes at 4/4, which is the [P2-T9] evidence that no new `.psm1`
module was created. Every pre-existing caller and test of `Get-OrdinalSortedEntry` compiles and
passes without modification: no test file was edited in Phase 2.

Output Summary: Format modified 0 files and PSScriptAnalyzer reported 0 findings, both exiting 0.
Pester reported 1984 passed / 2 failed / 0 errors / 9 skipped of 1995 — every count identical to
the P0-T9 baseline, with the same two pre-existing environmental failures and zero new failures.
The nine blast-radius suites are green at 284 passed / 0 failed. The Phase 2 move of
`Get-OrdinalSortedEntry` from `BlastRadiusExtraction.psm1` to `BlastRadiusGlob.psm1` is therefore
behaviour-preserving. The test stage's exit code 2 is attributable entirely to the two
pre-existing environmental failures recorded at baseline, not to this change set.
