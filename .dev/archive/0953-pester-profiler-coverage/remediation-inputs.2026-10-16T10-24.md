# Remediation Inputs - Cycle 1 (issue #953)

- Timestamp: 2026-10-16T10-24
- Issue: #953
- Branch: bug/pester-profiler-coverage-953
- Source review: docs/features/active/2026-10-16-pester-profiler-coverage-953/code-review.2026-10-16T10-17.md (findings CR-1, CR-2, CR-3)
- Opened by: orchestrator decision D11. The round-1 review verdict is AWAITING_CI (three `awaiting_ci` findings, PA-1 to PA-3, carried forward unchanged and resolved by CI on the PR head). The three findings below are non-blocking in the review but are related to this item: they are in files this item changes and arise from its decision D8 change. The coordinator rule requires related findings to be fixed inside the item before DONE, so this cycle fixes them.
- Plan path for this cycle: docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-plan.2026-10-16T10-24.md

## Findings in scope

### CR-1 - EnsureModule presence check ignores the Pester ceiling

- Severity: Minor (fixed in this cycle per decision D11)
- Remediability: autonomous
- File: `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (default `EnsureModule` seam, lines 163-170) and its bundled copy `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`
- Problem: `Get-Module -ListAvailable -Name $Name` accepts any installed version. When only Pester 6.x is installed, the presence check passes and the bounded `Import-Module` then fails with the generic module-not-found error instead of the seam's actionable message (`Run Install-PoshQCTool ...`).
- Expected: the presence check considers only versions inside the supported range (>= 5.9.0 and < 6.0.0 for Pester), so the seam throws its actionable `$ErrorMessage` when no supported version is installed. A Pester test covers the Pester-6-only case and creates no temporary files.

### CR-2 - EnsureModule import sets only an upper bound

- Severity: Minor (treated as a defect introduced by this item, decision D11)
- Remediability: autonomous
- File: same seam, line 169, both copies
- Problem: the import passes `-MaximumVersion 5.99.99` only. On a host with only the inbox Pester 3.4.0, the import loads 3.4.0 and the run fails later in `New-PesterConfiguration`.
- Expected: the import passes `-MinimumVersion 5.9.0` together with `-MaximumVersion 5.99.99`, matching `.github/workflows/_poshqc.yml:73` and the installer floor. A test (seam default-text test or seam-driven test) fails if either bound is absent.

### CR-3 - Duplicated version-range predicate in Install-PoshQCTool

- Severity: Minor (fixed in this cycle per decision D11)
- Remediability: autonomous
- File: `scripts/powershell/PoshQC/PoshQC.psm1` lines 62 and 75 and its bundled copy
- Problem: the version predicate is written twice (present check and post-install check).
- Expected: one scriptblock defined once in `Install-PoshQCTool` and used by both `Where-Object` calls; behavior unchanged (existing RS03, RS05, MC01-MC05, and PoshQC installer tests continue to pass). The two shell scripts keep their own copies (separate languages and files; not in scope).

## Carried forward unchanged (not remediated in this cycle)

- PA-1, PA-2, PA-3: `Remediability: awaiting_ci`; resolved by CI on the PR head and the post-CI re-audit.

## Constraints

- Bundled copies are mirrored with `Copy-Item` through the plan Tool route; bundled-parity pytest must pass.
- Batch budget: production PowerShell files written with Write/Edit in this cycle are `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and `scripts/powershell/PoshQC/PoshQC.psm1` only.
- Full PoshQC toolchain loop (format, analyze, full test run with coverage) must pass in one pass after the change; coverage figures recorded under the feature folder evidence tree; no file over 500 lines; no temporary files in tests.
- Do not edit `.github/workflows/ci.yml`, any workflow `on:` block, `.claude/rules/**`, or `.github/instructions/**`.
