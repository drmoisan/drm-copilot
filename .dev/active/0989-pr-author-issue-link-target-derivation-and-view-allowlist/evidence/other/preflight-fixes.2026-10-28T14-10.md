# Preflight Fixes: remediation cycle 1

Timestamp: 2026-10-28T14-10
Plan: docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/remediation-plan.2026-10-28T13-58.md

## Fix 1

- Task: P2-T1
- Defect class: parameter name not stated (trivial)
- Change: "with the worktree root" now reads "with `-Root` set to the worktree root". `Invoke-PoshQCTest` in `scripts/powershell/PoshQC/PoshQC.Testing.psm1` declares `-Root` and `-ScanFolders`; `-SettingsPath` defaults to `settings/pester.runsettings.psd1`, which enables coverage.

## Checked, no change

- Plan validator (plan artifact type): ok.
- All other tasks, thresholds, and Pre-Mortem bullets read against the tree: no further defect.
