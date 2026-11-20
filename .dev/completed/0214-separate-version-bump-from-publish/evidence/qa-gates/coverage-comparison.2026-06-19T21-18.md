# Coverage Comparison (Issue #214)

Timestamp: 2026-06-19T21-18
Baseline source: evidence/baseline/poshqc-test.baseline.2026-06-19T21-18.md
Post-change source: evidence/qa-gates/poshqc-test.final.2026-06-19T21-18.md
Per-file JaCoCo report: evidence/qa-gates/coverage-214-perfile-jacoco.2026-06-19T21-18.xml
Coverage tool: Pester CodeCoverage (JaCoCo) via Invoke-Pester with the repository
coverage scope from scripts/powershell/PoshQC/settings/pester.runsettings.psd1
Coverage scope config: scripts/powershell/PoshQC/settings/pester.runsettings.psd1
(extended in this remediation to add the four changed/new release scripts; the same
addition was mirrored into the bundled copy at
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1)

## Coverage scope resolution (remediation note)

The prior version of this artifact recorded that per-file changed-line coverage for the
four changed/new scripts could not be produced because CodeCoverage.Path was scoped to
five .claude/hooks/*.ps1 files only. That gap is now resolved: the four production scripts
were added to CodeCoverage.Path (additive; the five hook entries are retained). The
authoritative per-file figures below were produced by running the full PowerShell suite
(tests/powershell + tests/scripts) with the extended coverage scope and writing the JaCoCo
report recorded alongside this artifact.

Note on the live MCP test runner: the bundled MCP server in this session reads an installed
extension copy of the runsettings file located outside the repository
(~/.vscode*/extensions/...drm-copilot.../resources/powershell/PoshQC/settings/pester.runsettings.psd1),
which is regenerated only on extension rebuild/install. The two in-repo source copies of the
runsettings (the module-relative source and the extensions/.../resources bundled source) are
both updated, so a subsequent extension build will produce these per-file figures directly
from the MCP tool. The numbers below are produced deterministically by running Pester against
the in-repo coverage scope.

## Repository-configured coverage scope (numeric)

| Metric | Baseline (hook-only scope) | Post-change (extended scope) | Determination |
|---|---|---|---|
| Line coverage (overall measured scope) | 96.83% (275/284) | 94.85% (552/582) | >= 85% SATISFIED |
| Instruction coverage (branch proxy, overall) | 96.99% (420/433) | 93.78% (784/836) | >= 75% SATISFIED |
| Branch coverage | not emitted | not emitted | n/a (tooling) |
| Tests passed | 630 | 677 (686 total, 9 disabled) | +47 executed |
| Tests failed | 0 | 0 | 0 |

The overall line-coverage value decreased from 96.83% to 94.85% only because the denominator
grew: the four release scripts (582 - 284 = 298 additional analyzed lines, minus hook-file
parse differences) were added to the measured scope. This is denominator growth from including
previously-unmeasured production files, not a regression on any previously-measured line. The
five hook files retain their baseline per-file coverage (see per-file table below).

Line coverage >= 85%: SATISFIED (94.85% overall; every measured file >= 90%).
Branch coverage >= 75%: Branch coverage is not emitted by the Pester coverage engine in this
repository. Instruction coverage (93.78%) is the closest available proxy and exceeds 75%. No
BRANCH counter exists in the JaCoCo report; this is a tooling characteristic, not a regression
introduced by this feature.

## Per-file line coverage (all measured files)

| File | Covered | Missed | Total | Line % | >= 85% |
|---|---|---|---|---|---|
| scripts/powershell/Publish-DrmCopilotExtension.ps1 | 109 | 7 | 116 | 93.97% | YES |
| scripts/dev-tools/Invoke-FullRelease.ps1 | 66 | 6 | 72 | 91.67% | YES |
| scripts/dev-tools/Invoke-MarketplacePublish.ps1 | 56 | 6 | 62 | 90.32% | YES |
| scripts/dev-tools/Invoke-ReleaseTagPush.ps1 | 46 | 2 | 48 | 95.83% | YES |
| .claude/hooks/validate-bash.ps1 | 17 | 0 | 17 | 100.00% | YES |
| .claude/hooks/check-python-test-purity.ps1 | 58 | 0 | 58 | 100.00% | YES |
| .claude/hooks/check-powershell-test-purity.ps1 | 48 | 3 | 51 | 94.12% | YES |
| .claude/hooks/enforce-python-batch-budget.ps1 | 76 | 3 | 79 | 96.20% | YES |
| .claude/hooks/enforce-powershell-batch-budget.ps1 | 76 | 3 | 79 | 96.20% | YES |

## Changed/new scripts — changed-line coverage

The four changed/new scripts are now measured with real per-file figures (table above). The
uncovered lines in each of the four scripts are limited to:

1. The external-executable wrapper-seam bodies (for example `Invoke-GitExe`, `Invoke-NpmExe`,
   `Invoke-GhExe`, `Invoke-VsceExe`, `Get-VsceListing`). These single-line splat-and-return
   wrappers cannot be exercised without mocking the underlying `git`/`npm`/`gh`/`vsce`
   executables, which `.claude/rules/powershell.md` prohibits ("never mock `git`, `gh`,
   `actionlint`, or other executables directly"), and the determinism rule forbids invoking
   live executables in unit tests. The wrappers are the intended seam boundary that the
   guarded-logic tests mock.
2. A small number of host-bound entry-point statements in Publish-DrmCopilotExtension.ps1
   (the `New-Item` for the artifacts/vsix directory and the `Write-Error` vsce-not-on-PATH
   branch) that depend on the real host filesystem and PATH.

These residual uncovered lines are the irreducible host-bound wiring described by
`.claude/rules/general-unit-test.md` (keep host-bound entry points thin; their uncovered lines
are a visible, real cost). Every one of the four scripts nonetheless exceeds the 85% line
threshold.

Behavioral coverage evidence (Pester, all passing) for the four suites:
- Publish-DrmCopilotExtension.Tests.ps1: dry-run/package modes, manifest validation (missing,
  empty-required-fields, missing-README), build path (install + compile, install-skip,
  install-failure, compile-failure), forbidden-file warning, vsce-package-failure, and the
  entry-point dry-run path.
- Invoke-FullRelease.Tests.ps1: confirmation-token guard (case-sensitive), both-manifest bump
  + `gh pr create`, dirty-tree block, missing-manifest reporting, status/branch/bump/add/
  commit/PR seam failures, real Get-NpmVersion and Write-StderrLine, and the entry-point path.
- Invoke-MarketplacePublish.Tests.ps1: confirmation-token guard, single-manifest bump +
  `gh pr create`, dirty-tree block, missing-manifest reporting, seam failures, real
  Get-NpmVersion / Get-ReleaseBranchName / Write-StderrLine, and the entry-point path.
- Invoke-ReleaseTagPush.Tests.ps1: confirmation-token guard (case-sensitive), both-tag
  derivation/push, missing-manifest reporting (extension and mcp-server), pull/tag-create/
  tag-push seam failures, real Get-NpmVersion / Write-StderrLine, tag-name builders, and the
  entry-point path.

## Determination

- Line coverage threshold (>= 85%): SATISFIED. Overall measured scope 94.85%; each of the four
  changed/new scripts is >= 90% (lowest is Invoke-MarketplacePublish.ps1 at 90.32%).
- Branch coverage threshold (>= 75%): Branch coverage is not measured by repository tooling;
  instruction coverage (93.78%) is recorded as the proxy and exceeds 75%.
- No-regression-on-changed-lines: SATISFIED. The changed lines are wholly contained in the four
  new/rewritten scripts, which are now measured at >= 90% line coverage each; there are no
  previously-measured lines that lost coverage. The five hook files retain their baseline
  per-file coverage. The overall percentage moved from 96.83% to 94.85% solely because the
  measured-file set expanded to include the four production scripts (denominator growth), not
  because any previously-covered line became uncovered.

Verdict: PASS. Per-file numeric changed-line coverage is now available for all four scripts,
the line threshold (>= 85%) and the instruction proxy for branch (>= 75%) are satisfied, and
there is no regression on changed lines. The prior REMEDIATION-REQUIRED condition is resolved.
