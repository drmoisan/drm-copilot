# Final QA: PowerShell Format (Issue #847)

Timestamp: 2026-10-10T01-18
Task: [P7-T1] (loop iteration 1)
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "P0-T3 / P7-T1 format"), the local `Invoke-PoshQCFormat` run is replaced by `mcp__drm-copilot__run_poshqc_format` plus the CI `Format PowerShell` step, with the before/after tree observation taken through `git hash-object` of the CPFS files and `git status --porcelain`. The acceptance conditions (19 `Already formatted:` lines, zero `Formatted:` lines, `UNCHANGED_HASHES=19`) are unchanged.
Command: (1) `git hash-object <the 19 CPFS paths in plan order>`; (2) `mcp__drm-copilot__run_poshqc_format` with `workspace_root` = the agent worktree and `scan_folders` = `["scripts/dev-tools", "tests/scripts/dev-tools"]`; (3) `git hash-object <the 19 CPFS paths in plan order>`; (4) `git status --porcelain=v1 --untracked-files=all`; (5) CI `Format PowerShell` step of run 38011932558 (`Invoke-PoshQCFormat -Root "${{ github.workspace }}"` followed by `git status --porcelain` and `Write-Error` when any file changed; `.github/workflows/_poshqc.yml` lines 22-30), read from `artifacts/ci/run-38011932558/poshqc-job.log`.
EXIT_CODE: 0
Output Summary:
- MCP call disposition: `ok: true` (EXIT_CODE 0 records the call disposition; the MCP tool returns no captured output).
- UNCHANGED_HASHES=19: all 19 CPFS `git hash-object` values are identical before and after the MCP format call, and each equals the blob recorded for that path in `git ls-tree HEAD` (HEAD `1c3d1a4c6d0cc741081f45511c3ab6c5adf2d184`).
- `git status --porcelain=v1 --untracked-files=all` after the call lists only the three feature-folder Markdown files edited by this session (P4-T4 and P5-T8 artifacts and the plan); no `.ps1` or `.psm1` path.
- CI Format step (run 38011932558, job `PowerShell QC` 114093650487, head `1c3d1a4c6`): 19 log lines begin with `Already formatted: ` for the CPFS files (one per file; counted by basename over the step's `Already formatted:` lines under `dev-tools`), 0 log lines begin with `Formatted: `, no `##[error]` line; the step succeeded and the job concluded success.
- Result: PASS. The formatter rewrote no CPFS file; the loop proceeds to P7-T2.

## Hash record (plan order; before = after = HEAD blob)

| File | git hash-object |
|---|---|
| scripts/dev-tools/HostTooling.psm1 | aea70a19afdc88a03da2a5b0df4f42c6a5fc8554 |
| scripts/dev-tools/HostBootstrapWorkspace.psm1 | 12ccfeca905cbc1549e84972d165d43bf2d31c09 |
| scripts/dev-tools/HostBootstrap.psm1 | f5925cecf15778bc508710f321b8a614ba989232 |
| scripts/dev-tools/HostVerification.psm1 | fb7643d824f3a2a34b399d06528b133c790b6aa1 |
| scripts/dev-tools/SideloadedExtensionPublish.psm1 | 80fa1ee52b8f64191d9971184068aacbcbd4e757 |
| scripts/dev-tools/bootstrap-host.ps1 | 2a6d98e52514b52b4fc7a5984c0426a13783fcdb |
| scripts/dev-tools/verify-host.ps1 | 0449280a12e25423c330b4dadcf5cf1dd333b58f |
| scripts/dev-tools/publish-sideloaded-extension.ps1 | ac8def3e56c72b1b34379af9470b2c623cf2e3f1 |
| tests/scripts/dev-tools/HostTooling.Tests.ps1 | 0787af7b4c4c973b8629e9764ba6b7aba4cc459a |
| tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 | 70bda70068b046ead70e6ddeaa24a0987584c0d8 |
| tests/scripts/dev-tools/HostBootstrap.Tests.ps1 | 8e09af72af31cd4bb81c9b145e84cf9c047f5609 |
| tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | fdcf00097da6963ca040962a9256d3c6228132ff |
| tests/scripts/dev-tools/HostVerification.Tests.ps1 | dc69766e52c78dbdb62200da5e1b25b163f9ceee |
| tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1 | ea0d65f903f07871e375524898e7146ebef3467b |
| tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 | dbf01ba50ab982681afa2604d11c49541aa6d989 |
| tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 | bb19b47f97986542862cb28f085e328f46dd6dc1 |
| tests/scripts/dev-tools/bootstrap-host.Tests.ps1 | fce14b43d468c3dcf581a73be0d9c76d07e0326a |
| tests/scripts/dev-tools/verify-host.Tests.ps1 | 270eb7e0c4da7b58cc320cdf6786ade298293da6 |
| tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | 53b1665a64059bb74dd0dad0149dfed99ae4364c |
