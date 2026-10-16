# Final Scope Check AC-13 (issue #953, P6-T14)

Timestamp: 2026-10-16T08-56
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; git diff --name-only origin/main...HEAD; git status --porcelain; $mb = git merge-base origin/main HEAD; foreach ($w in Get-ChildItem .github/workflows -Filter *.yml) { compare the on: block (line matching ^on: through the line before the next line matching ^\S) of the worktree file with git show "${mb}:.github/workflows/<name>" }; compare lines 1-5 of .github/workflows/_poshqc.yml with git show "${mb}:.github/workflows/_poshqc.yml"' (script SCRATCH/issue-953-p6-t14.sh, run with sh)
EXIT_CODE: 0
Output Summary: Both git listings exited 0. .github/workflows/ci.yml appears in neither the 48-entry git diff --name-only origin/main...HEAD listing nor the 14-entry git status --porcelain listing (CIYML_IN_DIFF 0, CIYML_IN_STATUS 0). Merge base 5bc97774b8322e57abb94dfac3cd0a000a136c5b. The on: block of all 14 workflow files is identical to the merge-base text. Lines 1-5 of .github/workflows/_poshqc.yml are identical to the merge-base lines 1-5.

CIYML_IN_DIFF: 0
CIYML_IN_STATUS: 0
ALL_ON_BLOCKS_IDENTICAL: YES
POSHQC_LINES_1_5_IDENTICAL: YES

## on: block comparison

| Workflow | on: block lines | identical to merge base |
|---|---|---|
| _build-check.yml | 4 | YES |
| _docs-validation.yml | 4 | YES |
| _drm-copilot-extension-tests.yml | 4 | YES |
| _npm-audit-gate.yml | 20 | YES |
| _poshqc.yml | 4 | YES |
| _quality-checks.yml | 4 | YES |
| _root-typescript-tests.yml | 4 | YES |
| _security-scan.yml | 4 | YES |
| _shell-coverage.yml | 4 | YES |
| ci.yml | 7 | YES |
| npm-audit-gate.yml | 14 | YES |
| publish-extension.yml | 14 | YES |
| publish-mcp-npm.yml | 14 | YES |
| verify-published-releases.yml | 18 | YES |

## git diff --name-only origin/main...HEAD (non-evidence entries)

.devcontainer/post-create.sh; .github/codex/codex-web-setup.sh; .github/workflows/_poshqc.yml; docs/features/active/2026-10-16-pester-profiler-coverage-953/{issue.md, plan.2026-10-16T00-16.md, research/research.2026-10-16T04-28.md, spec.md}; docs/features/potential/promoted/2026-10-16-pester-profiler-coverage.md; extensions/drm-copilot/CHANGELOG.md; extensions/drm-copilot/resources/powershell/PoshQC/{PoshQC.Testing.psm1, PoshQC.psm1, README.md, settings/pester.runsettings.psd1}; scripts/host-tools.manifest.json; scripts/powershell/PoshQC/{PoshQC.Testing.psm1, PoshQC.psm1, README.md, settings/pester.runsettings.psd1}; tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1; tests/scripts/host-tools.manifest.Tests.ps1; tests/scripts/powershell/PoshQC/{PoshQC.EntryPoints.Tests.ps1, PoshQC.ModuleCoverage.Tests.ps1, PoshQC.RunSettings.Tests.ps1, PoshQC.Tests.ps1}; plus 25 evidence files under the feature folder.

## git status --porcelain

The plan checkbox file (modified) and 13 untracked Phase 6 evidence files under docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/.
