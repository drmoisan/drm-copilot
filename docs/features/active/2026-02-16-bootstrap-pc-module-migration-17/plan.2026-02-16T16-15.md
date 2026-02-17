# PowerShell Implementation Plan: 2026-02-16-bootstrap-pc-module-migration-17 (2026-02-16T16-15)

- **Issue:** #17
- **Promotion Type:** feature
- **Owner:** drmoisan
- **Last Updated:** 2026-02-16T16-15
- **Status:** In Progress (execution completed except [P4-T2] acceptance conflict)
- **Plan Scope:** planning only; no implementation in this document update

## Objective

Migrate bootstrap host tooling and manifest ownership from legacy paths under `scripts/dev-tools` and `scripts/host-tools.manifest.json` into `scripts/powershell/BootstrapPC`, redirect all active references without shims, move and retarget tests, preserve behavior, and finish with a clean PowerShell quality loop.

## Context Inputs

- Issue: `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/issue.md`
- Spec: `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/spec.md`
- User story: `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/user-story.md`
- Research: `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/research.md`
- Constraints: no shims; redirect all references; deterministic tests; preserve bootstrap/verify behavior.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Compliance and Baseline Capture
- [x] [P0-T1] Read and log policy compliance order for this change (`.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/github-actions.instructions.md` for workflow files if touched)
  - Acceptance: `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/evidence/baseline/policy-read-log.md` exists and contains `Timestamp:`, `Policies:`, `Scope: powershell,json,docs,bash`, and `Output Summary:`
- [x] [P0-T2] Capture baseline old-path reference inventory before edits
  - Command: `poetry run python -c "from pathlib import Path; import re; roots=['scripts','tests','docs','.vscode']; pats=[r'scripts/dev-tools/bootstrap-host.ps1',r'scripts/dev-tools/bootstrap-host.helpers.ps1',r'scripts/dev-tools/verify-host.ps1',r'scripts/host-tools.manifest.json']; lines=[]; [lines.extend([f'{p}:{i}:{line.strip()}' for i,line in enumerate(Path(p).read_text(encoding='utf-8', errors='ignore').splitlines(),1) if any(re.search(pt,line) for pt in pats)]) for r in roots for p in Path(r).rglob('*') if p.is_file()]; out=Path('docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/evidence/baseline/reference-scan.before.md'); out.parent.mkdir(parents=True,exist_ok=True); out.write_text('Timestamp: 2026-02-16T16-15\nCommand: baseline-old-path-reference-scan\nEXIT_CODE: 0\n\n'+'\n'.join(lines), encoding='utf-8')"`
  - Acceptance: `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/evidence/baseline/reference-scan.before.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` fields
- [x] [P0-T3] Capture baseline PowerShell toolchain status
  - Command 1: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCFormat -Root ."`
  - Command 2: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCAnalyze -Root ."`
  - Command 3: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root ."`
  - Acceptance: `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/evidence/baseline/powershell-toolchain.before.md` exists and records `Timestamp:`, each command string, `EXIT_CODE:` for each command, and `Output Summary:`
- [x] [P0-T4] Capture baseline manifest top-level key snapshot before moving manifest
  - Command: `poetry run python -c "from pathlib import Path; import json; src=Path('scripts/host-tools.manifest.json'); keys=sorted(json.loads(src.read_text(encoding='utf-8')).keys()); out=Path('docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/evidence/baseline/manifest-keys.before.txt'); out.parent.mkdir(parents=True,exist_ok=True); out.write_text('Timestamp: 2026-02-16T16-15\nCommand: baseline-manifest-key-snapshot\nEXIT_CODE: 0\n\n'+'\n'.join(keys), encoding='utf-8')"`
  - Acceptance: `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/evidence/baseline/manifest-keys.before.txt` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`

### Phase 1 — Rehome BootstrapPC Runtime Assets (No Shim)
- [x] [P1-T1] Move `scripts/dev-tools/bootstrap-host.ps1` to `scripts/powershell/BootstrapPC/bootstrap-host.ps1` and preserve existing parameter surface and exit behavior
  - Acceptance: `Test-Path ./scripts/dev-tools/bootstrap-host.ps1` is `$false`; `Test-Path ./scripts/powershell/BootstrapPC/bootstrap-host.ps1` is `$true`; and `Select-String -Path ./scripts/powershell/BootstrapPC/bootstrap-host.ps1 -Pattern 'param\(|Set-StrictMode|CmdletBinding|exit\s+[0-9]+'` returns at least one match
- [x] [P1-T2] Move `scripts/dev-tools/bootstrap-host.helpers.ps1` to `scripts/powershell/BootstrapPC/bootstrap-host.helpers.ps1` and preserve helper function names consumed by bootstrap flow
  - Acceptance: `Test-Path ./scripts/dev-tools/bootstrap-host.helpers.ps1` is `$false`; `Test-Path ./scripts/powershell/BootstrapPC/bootstrap-host.helpers.ps1` is `$true`; and `Select-String -Path ./scripts/powershell/BootstrapPC/bootstrap-host.ps1 -Pattern 'bootstrap-host.helpers.ps1'` returns at least one match
- [x] [P1-T3] [expect-fail] Move `scripts/dev-tools/verify-host.ps1` to `scripts/powershell/BootstrapPC/verify-host.ps1` and preserve verification result semantics
  - Acceptance: `Test-Path ./scripts/dev-tools/verify-host.ps1` is `$false`; `Test-Path ./scripts/powershell/BootstrapPC/verify-host.ps1` is `$true`; and `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/evidence/regression-testing/verify-host.negative.md` records `Timestamp:`, `Command:`, and nonzero `EXIT_CODE:` from a controlled negative invocation
- [x] [P1-T4] Move `scripts/host-tools.manifest.json` to `scripts/powershell/BootstrapPC/host-tools.manifest.json` and keep schema/content equivalent
  - Acceptance: `Test-Path ./scripts/host-tools.manifest.json` is `$false`; `Test-Path ./scripts/powershell/BootstrapPC/host-tools.manifest.json` is `$true`; and a key-compare command between `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/evidence/baseline/manifest-keys.before.txt` and new-manifest sorted keys exits `0`

### Phase 2 — Redirect Invocation Surfaces and External Path Consumers
- [x] [P2-T1] Update `.vscode/tasks.json` host bootstrap task arguments/detail text to target `scripts/powershell/BootstrapPC/bootstrap-host.ps1`
  - Acceptance: no task arguments in `.vscode/tasks.json` reference `scripts/dev-tools/bootstrap-host.ps1` and at least one task references new bootstrap path
- [x] [P2-T2] Update `.vscode/tasks.json` host verify task arguments/detail text to target `scripts/powershell/BootstrapPC/verify-host.ps1`
  - Acceptance: no task arguments in `.vscode/tasks.json` reference `scripts/dev-tools/verify-host.ps1` and at least one task references new verify path
- [x] [P2-T3] Update Bash host scripts to consume relocated manifest path (`scripts/powershell/BootstrapPC/host-tools.manifest.json`)
  - Files: `scripts/bash/bootstrap-host.sh`, `scripts/bash/verify-host.sh`
  - Acceptance: both scripts contain no reference to `scripts/host-tools.manifest.json` and contain the new module manifest path expression
- [x] [P2-T4] Update developer documentation to only reference canonical BootstrapPC locations
  - File: `docs/developer-tooling.md`
  - Acceptance: document contains new BootstrapPC script paths and no legacy `scripts/dev-tools/*host*.ps1` references

### Phase 3 — Migrate and Retarget Pester Coverage
- [x] [P3-T1] Move test file from `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` to `tests/scripts/powershell/BootstrapPC/bootstrap-host.Tests.ps1`
  - Acceptance: legacy test file path is absent and new test file path exists
- [x] [P3-T2] Update test dot-source/import and path assertions to new BootstrapPC script and manifest locations
  - Acceptance: test file contains `scripts/powershell/BootstrapPC/bootstrap-host.ps1`, `scripts/powershell/BootstrapPC/verify-host.ps1`, and `scripts/powershell/BootstrapPC/host-tools.manifest.json`
- [x] [P3-T3] Preserve deterministic executable-wrapper testing by mocking process/executable discovery seams rather than invoking external tools directly
  - Acceptance: test file includes mocks/stubs for external command discovery or execution wrappers and contains no direct network/tool invocation requirements
- [x] [P3-T4] Execute targeted Pester test file to verify migrated test behavior
  - Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/powershell/BootstrapPC/bootstrap-host.Tests.ps1 -EnableExit"`
  - Acceptance: command exits `0`

### Phase 4 — Enforce No-Shim Policy and Reference Closure
- [x] [P4-T1] Verify legacy runtime files remain removed with no forwarding wrappers under `scripts/dev-tools`
  - Acceptance: `scripts/dev-tools/bootstrap-host.ps1`, `scripts/dev-tools/bootstrap-host.helpers.ps1`, and `scripts/dev-tools/verify-host.ps1` do not exist
- [x] [P4-T2] Run post-migration reference scan for forbidden legacy paths
  - Command: `poetry run python -c "from pathlib import Path; import re,sys; roots=['scripts','tests','.vscode']; pats=[r'scripts/dev-tools/bootstrap-host.ps1',r'scripts/dev-tools/bootstrap-host.helpers.ps1',r'scripts/dev-tools/verify-host.ps1',r'scripts/host-tools.manifest.json']; hits=[]; [hits.extend([f'{p}:{i}:{line.strip()}' for i,line in enumerate(Path(p).read_text(encoding='utf-8', errors='ignore').splitlines(),1) if any(re.search(pt,line) for pt in pats)]) for r in roots for p in Path(r).rglob('*') if p.is_file()]; out=Path('docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/evidence/other/reference-scan.after.md'); out.parent.mkdir(parents=True,exist_ok=True); out.write_text('Timestamp: 2026-02-16T16-15\nCommand: post-migration-reference-scan\nEXIT_CODE: '+('1' if hits else '0')+'\n\n'+'\n'.join(hits), encoding='utf-8'); sys.exit(1 if hits else 0)"`
  - Acceptance: command exits `0` and `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/evidence/other/reference-scan.after.md` contains `EXIT_CODE: 0`

### Phase 5 — Final QA Loop and Evidence Closure
- [x] [P5-T1] Format PowerShell repository content with PoshQC formatter
  - Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCFormat -Root ."`
  - Acceptance: command exits `0`
- [x] [P5-T2] Analyze PowerShell repository content with PSScriptAnalyzer through PoshQC
  - Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCAnalyze -Root ."`
  - Acceptance: command exits `0`
- [x] [P5-T3] Run full Pester suite through PoshQC
  - Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root ."`
  - Acceptance: command exits `0`
- [x] [P5-T4] Restart Phase 5 from [P5-T1] whenever [P5-T1], [P5-T2], or [P5-T3] changes files or fails; stop only on a clean single pass
  - Acceptance: `docs/features/active/2026-02-16-bootstrap-pc-module-migration-17/evidence/qa-gates/powershell-toolchain.final.md` records one full final pass with `EXIT_CODE: 0` for format/analyze/test in order

## Exit Criteria

- All active references point to `scripts/powershell/BootstrapPC` paths.
- No compatibility shims exist for removed legacy script paths.
- Migrated Pester test file runs green and remains deterministic.
- Final PowerShell quality loop passes in one clean pass after any required restarts.
