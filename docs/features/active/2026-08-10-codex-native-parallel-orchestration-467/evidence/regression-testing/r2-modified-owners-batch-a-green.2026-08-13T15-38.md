# R2 Modified PowerShell Owners Batch A Green

- Tasks: `P2-T1`, `P2-T2`
- Result: `PASS`
- Production owners: `3`
- Test owners: `3`
- Batch cap: `3 production + 3 test`
- Batch-cap result: `PASS`
- Runtime-source changes: `0`

## Final Uninterrupted Toolchain Pass

### Format

```text
mcp__drm_copilot__run_poshqc_format({
  "workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25",
  "scan_folders":[
    "tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1",
    "tests/scripts/codex-hooks/parallel-provenance.Tests.ps1",
    "tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1"
  ]
})
```

- Result: `PASS`
- Provider result: `ok=true`

### Analyze

```text
mcp__drm_copilot__run_poshqc_analyze({
  "workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25",
  "scan_folders":[
    "tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1",
    "tests/scripts/codex-hooks/parallel-provenance.Tests.ps1",
    "tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1"
  ]
})
```

- Result: `PASS`
- Provider result: `ok=true`

### Focused Pester with Coverage

```powershell
Import-Module './scripts/powershell/PoshQC/PoshQC.psd1' -Force
Invoke-PoshQCTest -Root (Get-Location).Path `
    -ScanFolders @(
        'tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1',
        'tests/scripts/codex-hooks/parallel-provenance.Tests.ps1',
        'tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1'
    ) `
    -SettingsPath './scripts/powershell/PoshQC/settings/pester.runsettings.psd1' `
    -DisableKoverageCopy
```

- Exit code: `0`
- Tests: `54`
- Passed: `54`
- Failed: `0`
- Skipped: `0`
- Inconclusive: `0`
- Not run: `0`
- Duration: `1.60` seconds
- Coverage XML SHA-256: `DB024F238BAB95532BE33CEAD059D3AE0BC5FBDF42E72DB1DCAD2C624AFF0AF8`
- JUnit SHA-256: `E6A4A7CD3E4CCFA2ACA77C4FCAA37AE1FEAF3292053F612FD28EF063C92C254E`

## Exact Per-Owner Line Coverage

| Production owner | Covered | Total | Percentage | Threshold |
|---|---:|---:|---:|---|
| `.codex/hooks/codex-authority-store.ps1` | 48 | 58 | 82.758621% | PASS >=80% |
| `.codex/hooks/enforce-codex-model-routing.ps1` | 68 | 79 | 86.075949% | PASS >=80% |
| `.codex/hooks/record-subagent-routing-attestation.ps1` | 184 | 229 | 80.349345% | PASS >=80% |

## Owner Inventory and Line Caps

| Kind | Owner | File lines |
|---|---|---:|
| Production | `.codex/hooks/codex-authority-store.ps1` | 188 |
| Production | `.codex/hooks/enforce-codex-model-routing.ps1` | 224 |
| Production | `.codex/hooks/record-subagent-routing-attestation.ps1` | 497 |
| Test | `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1` | 332 |
| Test | `tests/scripts/codex-hooks/parallel-provenance.Tests.ps1` | 384 |
| Test | `tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1` | 332 |

All six files are below the 500-line limit. The test additions cover authority
path boundaries, malformed JSON and profile states, epic and parallel receipt
boundaries, native transport outcomes, and persistence through the Windows null
device. No temporary file, external process, public transport change, or
production source change was introduced.

## Production No-Diff Verification

```powershell
git diff --exit-code HEAD -- .codex/hooks/codex-authority-store.ps1 .codex/hooks/enforce-codex-model-routing.ps1 .codex/hooks/record-subagent-routing-attestation.ps1
```

- Exit code: `0`
- Result: no production diff.
