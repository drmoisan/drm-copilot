# Claude SHA-256 Invariance

Timestamp: `2026-08-11`

Command: `Get-ChildItem -LiteralPath .claude -Recurse -File | Sort-Object FullName | ForEach-Object { '{0}  {1}' -f (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash,$_.FullName.Substring((Get-Location).Path.Length + 1).Replace('\\','/') }; git diff --exit-code -- .claude`

EXIT_CODE: `0`

Output Summary: The complete current `.claude/` path/SHA-256 manifest is byte-identical to the P0-T7 baseline manifest. No `.claude/` path was added, removed, modified, or left untracked.

## Authority and normalization

- Baseline authority: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/git-and-claude-sha256.2026-08-10T20-25.md`.
- Baseline HEAD: `fe0413d4aca1e76b2d02d05701fba79a887d5405`.
- Entry format: uppercase file SHA-256, two spaces, repository-relative path with forward slashes.
- Ordering: ordinal path order produced by `Sort-Object FullName`.
- Aggregate normalization: UTF-8 encoded manifest entries joined by LF with one trailing LF.

## Manifest comparison

| Measure | Result |
| --- | ---: |
| Baseline manifest entries | `150` |
| Git-tracked `.claude/` files | `150` |
| Current manifest entries | `150` |
| Untracked `.claude/` files | `0` |
| Missing paths | `0` |
| Added paths | `0` |
| SHA-256 mismatches | `0` |
| Git status paths | `0` |

Baseline aggregate manifest SHA-256: `34FE91AA14F9622BF4B9BF10E87BE787B95E992FFD69DFE09728937A779AA07C`.

Current aggregate manifest SHA-256: `34FE91AA14F9622BF4B9BF10E87BE787B95E992FFD69DFE09728937A779AA07C`.

Aggregate equality: `true`.

The comparison also matched every individual path/hash tuple. The complete baseline path/hash listing remains preserved in the authority artifact cited above; the current recomputation produced the same 150 tuples in the same order.

## Git immutability result

- `git diff --exit-code -- .claude`: exit `0`.
- Diff output: empty.
- `git status --short -- .claude`: `0` paths.
- `git ls-files --others --exclude-standard -- .claude`: `0` paths.

## Result

`P6_T20_STATUS: COMPLETE`
