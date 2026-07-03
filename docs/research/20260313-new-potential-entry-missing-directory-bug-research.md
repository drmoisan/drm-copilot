<!-- markdownlint-disable-file -->

# Task Research Notes: newPotentialEntry command failure – missing parent directory bug

## Research Executed

### File Analysis

- `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`
  - Line 145: `$target = Join-Path $workspace "docs/features/potential/$today-$ShortName.md"` — constructs target path under `docs/features/potential/`
  - Line 158: `Copy-Item $template $target -Force` — **no parent-directory guard**; fails if `docs/features/potential/` does not exist
  - Line 159: `Write-Output "Created: $target"` — runs unconditionally even after `Copy-Item` failure (misleading output)
  - Lines 168–170: `Get-Content` / `Convert-TemplateContent` / `Set-Content` all cascade-fail because the file was never created
  - `$workspace` is set via `(Get-Location).Path` — the CWD at invocation time (the workspace root the user opened)

- `scripts/dev-tools/new-potential-entry.ps1`
  - **Identical bug** at line 149: same `Copy-Item $template $target -Force` without parent-directory guard
  - `$workspace` resolved differently (`Split-Path -Parent (Split-Path -Parent $PSScriptRoot)`) but same missing-directory issue applies

### Code Search Results

- `Copy-Item $template $target` in `extensions/drm-copilot/resources/templates/*.ps1`
  - 1 match: `new-potential-entry.ps1` line 158
- `Copy-Item $template $target` in `scripts/dev-tools/new-potential-entry.ps1`
  - 1 match: line 149
- `New-Item.*Directory.*target` across both files
  - **0 matches** — confirms no parent-directory creation code exists anywhere near the `Copy-Item` call in either file

### Test Analysis

- `tests/scripts/dev-tools/new-potential-entry.Tests.ps1`
  - Tests cover individual helper functions (`Test-ValidShortName`, `Get-AuthorName`, `Convert-TemplateContent`, `Invoke-VSCodeOpen`) and structural validation
  - **No test exercises the main script execution path** (the `Copy-Item` call and downstream steps); the missing-directory case is untested

## Key Discoveries

### Root Cause

`Copy-Item -Force` overwrites an existing file but **does not create missing intermediate directories**. When a user runs `drmCopilotExtension.newPotentialEntry` against a workspace that does not yet contain a `docs/features/potential/` folder, the `Copy-Item` call at line 158 of the extension script fails with:

```
Could not find a part of the path 'C:\...\docs\features\potential\2026-03-13-<name>.md'
```

This is distinct from the `drm-copilot` repo itself (which has the `potential/` folder), which is why the bug was not caught earlier — the dev-tools script and extension were always tested against a workspace that already had the directory.

### Cascade Failures

Because `Copy-Item` fails silently (no `$ErrorActionPreference = 'Stop'`), execution continues:

1. `Write-Output "Created: $target"` — prints misleading success message (line 159)
2. `Get-Content -Raw -Path $target` — fails: file does not exist (line 168)
3. `Convert-TemplateContent` — fails: `$content` is empty/null (line 169)
4. `Set-Content` — fails: parent directory still absent (line 170)

### Affected Files

Both scripts share the same defect:

| File | Defective Line |
|------|---------------|
| `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` | 158 |
| `scripts/dev-tools/new-potential-entry.ps1` | 149 |

### Fix

Insert a parent-directory guard immediately before the `Copy-Item` call in **both** files:

```powershell
$targetDir = Split-Path -Parent $target
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}
Copy-Item $template $target -Force
```

`New-Item -ItemType Directory -Force` is safe to call even if the directory already exists on modern PowerShell; it creates the full path recursively.

### Test Coverage Gap

A regression test should be added to `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` covering the main execution path where the `potential` directory does not pre-exist. The test should:
- Create a temp workspace with no `docs/features/potential/` folder
- Invoke the script
- Assert the target file was created and contains replaced content
- Clean up (no temp files after test per policy — use `TestDrive:` or in-memory mocking)

Per project policy, use of temporary files in tests is **prohibited**; this scenario should be covered by mocking `Copy-Item` / `New-Item` powershell calls or by verifying the guard logic is present in the script content (matching the integration validation pattern already used in the test file).

## Recommended Approach

Add the `New-Item -ItemType Directory -Force` parent-directory guard before `Copy-Item` in both affected files, along with a regression test asserting the guard code is present (following the existing structural validation test pattern).

Per the bugfix workflow policy: add the **failing test first**, then implement the fix, then run the toolchain.

## Implementation Guidance

- **Objectives**: Ensure `new-potential-entry.ps1` creates the `docs/features/potential/` directory when it does not exist before copying the template
- **Dependencies**: None — pure PowerShell change, no new dependencies
- **Success Criteria**: Running the command against a workspace with no pre-existing `docs/features/potential/` directory creates the file successfully

---

### Step 1 — Regression test (add to `tests/scripts/dev-tools/new-potential-entry.Tests.ps1`, append before final closing line)

This test will **fail** before the fix (guard code absent) and **pass** after:

```powershell
Describe "new-potential-entry.ps1 - directory creation guard" {
    Context "Script structure validation" {
        It "contains parent directory creation guard before Copy-Item" {
            $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-potential-entry.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw

            $scriptContent | Should -Match "New-Item -ItemType Directory"
        }
    }
}
```

---

### Step 2 — Fix `scripts/dev-tools/new-potential-entry.ps1`

**Replace** (exact literal, line 149 area):

```powershell
$backlog = Join-Path $workspace 'docs/features/backlog.md'

Copy-Item $template $target -Force
```

**With:**

```powershell
$backlog = Join-Path $workspace 'docs/features/backlog.md'

# Copy-Item -Force does not create missing intermediate directories; ensure the parent exists.
$targetDir = Split-Path -Parent $target
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}
Copy-Item $template $target -Force
```

---

### Step 3 — Fix `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`

**Replace** (exact literal, line 156 area):

```powershell
$backlog = Join-Path $workspace 'docs/features/backlog.md'

Copy-Item $template $target -Force
```

**With:**

```powershell
$backlog = Join-Path $workspace 'docs/features/backlog.md'

# Copy-Item -Force does not create missing intermediate directories; ensure the parent exists.
$targetDir = Split-Path -Parent $target
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}
Copy-Item $template $target -Force
```

---

### Step 4 — Toolchain (run in order from repo root)

```powershell
# 1. Format
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."
# 2. Lint
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."
# 3. Test (no type-check for PowerShell)
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
```

### Step 5 — Rebuild and republish VSIX

After the toolchain passes, rebuild the extension and run the VSIX side-load publish script so the fix is deployed to the local VS Code Insiders installation.
