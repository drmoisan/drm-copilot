# Phase 0 — PowerShell Test and Coverage Baseline (Pester via PoshQC)

Timestamp: 2026-08-08T10-42
Task: [P0-T9]

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5c761b8f1a691079`
and no `scan_folders` override, so the run resolves the repository configuration
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` over the scan set
`scripts`, `tests/powershell`, `tests/scripts` from `config/poshqc-scan.json`.

EXIT_CODE: 2

Result artifacts parsed for the numbers below:
`artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`.

## Test counts

| Metric | Value |
| --- | --- |
| Total | 1995 |
| Passed | 1984 |
| Failed | 2 |
| Errors | 0 |
| Skipped (`disabled`) | 9 |
| Wall time | 99.849 s |

## The two baseline failures are environmental and pre-existing

Both failures are outside the blast-radius scope and are caused by a local, gitignored file that
exists only because this execution runs inside an active orchestration session. Neither is
attributable to this change set, and neither touches `.claude/lib/blast-radius/`.

1. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` -
   `allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
   expected `allow` but got `deny`. Cause: `Test-EpicBaseBranchOverride`
   (`.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:71`) reads the real on-disk
   `artifacts/orchestration/orchestrator-state.json` through `Get-PrAuthorCheckpointContent`, and
   that `Context` block does not mock the seam. The local checkpoint records
   `epic_mode: true` with
   `epic_context.integration_branch = "epic/parallel-orchestration-integration"`, so the check
   returns `EPIC_BASE_BRANCH_MISMATCH` for a test command that carries no `--base`. The sibling
   `gh pr edit` case passes because the check is scoped to `gh pr create` only.
2. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` -
   `allows every registered handler for every tool name its own matcher admits` reported
   `enforce-epic-wave-barrier.ps1` returning
   `EPIC_WAVE_BARRIER_BLOCKED: '452' ...`. Same cause class: the handler reads real orchestration
   state from disk rather than a mocked seam.

`artifacts/` is gitignored (`git ls-files artifacts/` is empty), so on a clean checkout neither
file exists and both tests pass. The condition is a test-isolation weakness in two hook suites,
recorded here as the baseline against which every later PowerShell run in this plan is compared.
The delta that matters for this plan is the change in failure count relative to this baseline of
2, and whether any blast-radius test fails.

## Numeric baseline coverage

Repository-wide, over the `CodeCoverage.Path` list in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`:

| Counter | Covered | Missed | Total | Percent |
| --- | --- | --- | --- | --- |
| LINE | 3148 | 189 | 3337 | 94.34% |
| INSTRUCTION | 4316 | 278 | 4594 | 93.95% |
| METHOD | 240 | 26 | 266 | 90.23% |
| CLASS | 39 | 2 | 41 | 95.12% |

### Per-module baseline for the five `.claude/lib/blast-radius/*.psm1` modules

| Module | Baseline measured coverage |
| --- | --- |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | UNMEASURED — no `sourcefile` entry emitted |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | UNMEASURED — no `sourcefile` entry emitted |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | UNMEASURED — no `sourcefile` entry emitted |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | UNMEASURED — no `sourcefile` entry emitted |
| `.claude/lib/blast-radius/BlastRadius.psm1` | UNMEASURED — no `sourcefile` entry emitted |

All five modules ARE declared in the `CodeCoverage.Path` list of the runsettings (added by issue
#447), but Pester emits no `sourcefile` element for any of them in
`artifacts/pester/powershell-coverage.xml`. The coverage breakpoints do not bind to these modules
because the suites consume them through `Import-Module`, which loads the module into its own
module scope. This is a pre-existing measurement condition of the F1 delivery, present before any
edit in this plan.

The modules are nonetheless behaviourally exercised. A scoped confirmation run
(`mcp__drm-copilot__run_poshqc_test` with `scan_folders: ["tests/scripts/claude-lib/blast-radius"]`)
reported 284 tests, 0 failures, 0 errors, 0 skipped, and still emitted no blast-radius
`sourcefile` element — which isolates the cause to coverage instrumentation rather than to test
absence.

Output Summary: 1984 passed, 2 failed, 0 errors, 9 skipped, of 1995 total; EXIT_CODE 2. Both
failures are pre-existing and environmental, caused by two hook suites reading the real,
gitignored `artifacts/orchestration/orchestrator-state.json` (`epic_mode: true`) instead of a
mocked seam; neither is in the blast-radius scope. Baseline overall PowerShell coverage is 94.34%
line (3148/3337) and 93.95% instruction. The five `.claude/lib/blast-radius/*.psm1` modules are
declared in `CodeCoverage.Path` but emit no coverage `sourcefile` entry, so their baseline
per-module coverage is UNMEASURED; the blast-radius suites themselves are green at 284 tests, 0
failures.
