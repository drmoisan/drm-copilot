# PowerShell Format QA

Timestamp: 2026-09-03T03-13
Command: `git status --porcelain=v1 --untracked-files=all -- '*.ps1' '*.psm1' '*.psd1'` (before formatting)
EXIT_CODE: 0

Output Summary: No tracked, staged, or untracked PowerShell path was present in the pre-format working-tree delta.

```text
(no output)
```

Command: `$ErrorActionPreference='Stop';$module=(Resolve-Path -LiteralPath 'extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1').Path;Import-Module $module -Force -ErrorAction Stop;$files=@(Get-PoshQCFileList -Root (Resolve-Path '.').Path);$rows=@($files|ForEach-Object{('{0}:{1}' -f $_.FullName,(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash)});$bytes=[Text.Encoding]::UTF8.GetBytes(($rows -join "`n"));$sha=[Security.Cryptography.SHA256]::Create();[pscustomobject]@{FileCount=$files.Count;TreeDigest=[Convert]::ToHexString($sha.ComputeHash($bytes)).ToLowerInvariant()}|ConvertTo-Json -Compress` (before formatting)
EXIT_CODE: 0

Output Summary: The same bundled PoshQC file-discovery function selected 429 PowerShell files; their ordered SHA-256 tree digest was `c883adaacef14b852f848070f20d81d7aa9be9be7b36ab41f81b68b7bb2d1a19`.

```json
{"FileCount":429,"TreeDigest":"c883adaacef14b852f848070f20d81d7aa9be9be7b36ab41f81b68b7bb2d1a19"}
```

Command: `mcp__drm_copilot__run_poshqc_format({"workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-31T07-29"})`
EXIT_CODE: 0

Output Summary: The named bundled PoshQC formatter returned `ok:true` for the complete workspace.

Command: `git status --porcelain=v1 --untracked-files=all -- '*.ps1' '*.psm1' '*.psd1'` (after formatting)
EXIT_CODE: 0

Output Summary: No tracked, staged, or untracked PowerShell path was present in the post-format working-tree delta.

```text
(no output)
```

Command: `$ErrorActionPreference='Stop';$module=(Resolve-Path -LiteralPath 'extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1').Path;Import-Module $module -Force -ErrorAction Stop;$files=@(Get-PoshQCFileList -Root (Resolve-Path '.').Path);$rows=@($files|ForEach-Object{('{0}:{1}' -f $_.FullName,(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash)});$bytes=[Text.Encoding]::UTF8.GetBytes(($rows -join "`n"));$sha=[Security.Cryptography.SHA256]::Create();[pscustomobject]@{FileCount=$files.Count;TreeDigest=[Convert]::ToHexString($sha.ComputeHash($bytes)).ToLowerInvariant()}|ConvertTo-Json -Compress` (after formatting)
EXIT_CODE: 0

Output Summary: The post-format selection remained 429 files and the ordered tree digest remained `c883adaacef14b852f848070f20d81d7aa9be9be7b36ab41f81b68b7bb2d1a19`. All 429 files remained unchanged; formatted-file count was 0. No Phase 2 restart is required.

```json
{"FileCount":429,"TreeDigest":"c883adaacef14b852f848070f20d81d7aa9be9be7b36ab41f81b68b7bb2d1a19"}
```
