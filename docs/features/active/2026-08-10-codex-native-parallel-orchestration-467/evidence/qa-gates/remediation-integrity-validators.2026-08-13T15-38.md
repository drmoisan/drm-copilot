# Remediation Integrity Validators

Timestamp: `2026-08-13T15-38`

Plan task: `[P6-T2]`

Overall result: `PASS`

## Validator results

| Validator | Exact command | Result |
|---|---|---|
| Bundled PoshQC parity | `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | exit `0`; `1/1` passed |
| Python root/bundle, registration, selected/full-pack, publisher, routing, and portable-asset contracts | `poetry run pytest -q tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_pack_selection.py tests/scripts/dev_tools/test_push_down_codex_portable_assets.py tests/scripts/dev_tools/test_push_down_codex_routing_merge.py` | exit `0`; `51/51` passed |
| TypeScript registration, selected/full-pack, publisher, routing, portable-asset, and Claude-carriage contracts | `npm --prefix extensions/drm-copilot run test -- --runInBand test/lib/push-down/codex-agents-customizations.test.ts test/lib/push-down/codex-pack-selection.test.ts test/lib/push-down/codex-portable-assets.test.ts test/lib/push-down/codex-routing-merge.test.ts test/lib/push-down/claude-config-carriage.test.ts test/repo-automation-service.push-down-codex.test.ts` | exit `0`; `6/6` suites and `56/56` tests passed; `0` snapshots |
| Payload-only destination contracts | `wsl.exe -d Ubuntu --cd 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25' -- bash -lc "bats tests/shell/parallel_payload_only.bats"` | exit `0`; `12/12` passed |
| `.claude/**` tracked feature diff | `$mergeBase = (git merge-base HEAD main).Trim(); git diff --name-status $mergeBase -- .claude` | exit `0`; merge base `8087c7f133e4c2570c39959b67629280d156f583`; `0` paths |
| `.claude/**` worktree status | `git status --short -- .claude` | exit `0`; `0` paths |

## Direct root/bundle byte-parity enumeration

The parity enumerator compared every file below root `.codex/` and `.agents/` with the corresponding file below `extensions/drm-copilot/resources/codex-and-agents-customizations/`. It excluded `.codex/state/**`, which is runtime state and is not a distributable customization source.

```powershell
$ErrorActionPreference = 'Stop'
$repoRoot = (Get-Location).Path
$bundleRoot = Join-Path $repoRoot 'extensions/drm-copilot/resources/codex-and-agents-customizations'
$sourceFiles = @{}
foreach ($relativeRoot in @('.codex', '.agents')) {
    $absoluteRoot = Join-Path $repoRoot $relativeRoot
    Get-ChildItem -LiteralPath $absoluteRoot -Recurse -File | ForEach-Object {
        $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $_.FullName).Replace('\', '/')
        if ($relativePath -notlike '.codex/state/*') {
            $sourceFiles[$relativePath] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }
    }
}
$bundleFiles = @{}
foreach ($relativeRoot in @('.codex', '.agents')) {
    $absoluteRoot = Join-Path $bundleRoot $relativeRoot
    Get-ChildItem -LiteralPath $absoluteRoot -Recurse -File | ForEach-Object {
        $relativePath = [System.IO.Path]::GetRelativePath($bundleRoot, $_.FullName).Replace('\', '/')
        $bundleFiles[$relativePath] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
}
$missing = @($sourceFiles.Keys | Where-Object { -not $bundleFiles.ContainsKey($_) } | Sort-Object)
$extra = @($bundleFiles.Keys | Where-Object { -not $sourceFiles.ContainsKey($_) } | Sort-Object)
$mismatched = @($sourceFiles.Keys | Where-Object {
    $bundleFiles.ContainsKey($_) -and $sourceFiles[$_] -ne $bundleFiles[$_]
} | Sort-Object)
$matched = @($sourceFiles.Keys | Where-Object {
    $bundleFiles.ContainsKey($_) -and $sourceFiles[$_] -eq $bundleFiles[$_]
})
if ($missing.Count -or $extra.Count -or $mismatched.Count) { exit 1 }
```

- Exit code: `0`.
- Source files: `237`.
- Bundle files: `237`.
- Byte-identical matches: `237`.
- Missing: `0`.
- Extra: `0`.
- Mismatched: `0`.

A preliminary invocation used an incorrect two-backslash normalization literal. It exited `1` after reporting `239` root paths, `237` matches, and only the two `.codex/state/*.json` runtime ledgers as missing. The corrected command above used single-backslash normalization and produced the authoritative passing result.

## Acceptance summary

- All repository integrity validator groups passed.
- Direct root/bundle parity is `237/237` with equal bytes.
- `.claude/**` has no tracked or untracked feature change.

`P6_T2_STATUS: COMPLETE`
