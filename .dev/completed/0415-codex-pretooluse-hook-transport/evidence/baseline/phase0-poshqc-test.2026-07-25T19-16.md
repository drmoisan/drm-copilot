# Phase 0 — Baseline PoshQC Test + Coverage (Issue #415)

Timestamp: 2026-07-25T19-16

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53` (no `scan_folders`; resolved from `config/poshqc-scan.json` `test.scanFolders` = `["scripts", "tests/powershell", "tests/scripts"]`)
EXIT_CODE: 0

Raw MCP result:

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53'."}
```

Machine-readable run artifacts produced by this invocation:

- `artifacts/pester/pester-junit.xml`
- `artifacts/pester/powershell-coverage.xml` (JaCoCo)
- `artifacts/pester/powershell-coverage.koverage.xml`

## Output Summary

**Test totals (from `pester-junit.xml` `<testsuites>` root attributes):**

- `tests="1356"`
- `failures="0"`
- `errors="0"`
- `disabled="9"` (skipped)
- `time="64.564"` seconds
- test suites: 86

**Failing tests: NONE. All 1356 executed tests pass.**

**Line coverage (NUMERIC headline), from the JaCoCo `<counter type="LINE">` totals:**

- covered = `2150`
- missed = `233`
- total = `2383`
- **line coverage = 90.22%** (2150 / 2383), which is >= the 85% policy threshold in `.claude/rules/quality-tiers.md`.

Supporting instruction counter: `INSTRUCTION missed="337" covered="2928"`. Method counter: `missed="28" covered="167"`. Class counter: `missed="2" covered="29"`.

**Branch coverage: not separately measurable in this toolchain.** Pester 5 / JaCoCo output from PoshQC emits `mb`/`cb` (missed-branch / covered-branch) attributes that are uniformly `0` at line level and emits no aggregate `BRANCH` counter. This is the documented toolchain limitation recorded at `spec.md:248`. Line coverage is the enforced numeric gate for PowerShell in this repository; branch coverage is carried as a documented limitation rather than a measured value.

## Deviation from the plan's expected baseline (recorded)

Plan task `[P0-T5]` anticipated "expected baseline failures from the known root/bundle `config.toml` divergence ... listed by test name". **No such failures occurred.** The branch was rebased onto `origin/main` (`00980851`) after the earlier Phase 0 session, and that rebase dropped the uncommitted `.codex/config.toml` ordering-swap diff. `git status --porcelain` now reports no modification to `.codex/config.toml`, so root and bundle `config.toml` are already byte-identical and the parity assertions are green at baseline.

Consequence for later phases: plan task `[P1-T2]` step (b) (`git restore .codex/config.toml`) is a confirmed no-op, and steps (c)/(d) are verification only. `[P1-T6]`'s acceptance clause "the baseline parity failures recorded in P0-T5 are now green" is satisfied vacuously — there were no baseline parity failures to turn green. This is recorded here rather than treated as a plan defect.

## Skipped tests (9, all pre-existing and unrelated to issue #415)

| Test file | Test |
|---|---|
| `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` | `Start-ClaudeBackground.Process launch behavior.uses claude as FilePath on non-Windows hosts` |
| `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` | `Start-ClaudeBackground.Process launch behavior.ArgumentList does not contain /c on non-Windows hosts` |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | `Install-PoshQCTool.When PSGallery is not registered.Should register PSGallery when not found` |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | `Install-PoshQCTool.When PSGallery is not trusted.Should attempt to set PSGallery as trusted` |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | `Install-PoshQCTool.When PSGallery is not trusted.Should handle failure to set PSGallery as trusted gracefully` |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | `Install-PoshQCTool.When modules need to be installed.Should install missing modules` |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | `Install-PoshQCTool.When modules need to be installed.Should verify module installation after install` |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | `Install-PoshQCTool.When modules need to be installed.Should throw when module installation fails` |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | `Install-PoshQCTool.When modules are already installed.Should skip installation for already-present modules` |

The first two are host-platform-conditional (non-Windows only). The remaining seven are PSGallery/module-installation cases skipped on this host. None are in the issue #415 change scope.
