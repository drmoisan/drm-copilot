Timestamp: 2026-08-25T22-27
Command: `Get-FileHash`/`Get-Item` for the listed TypeScript, package, routing, and generated-profile surfaces; `git diff --no-index -- <path> <path>` for each listed TypeScript/package path; `git status --porcelain=v1 --untracked-files=all`; package JSON version read.
EXIT_CODE: 0
Output Summary: Package version is 1.1.2. The TypeScript source/test/package baseline hashes were captured before this source-only revision. The no-index self-comparisons all exited 0. Root and bundled routing JSON and every root/bundled commit-steward profile are byte-identical. No TypeScript source mirror requires publication, and no publication was invoked.

TypeScript and package baseline:
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts` | SHA-256 `F474ED91EE4A52030D4DF5BBDE32C8C7506C3B648E0434A5B3C89247987F2789` | 14285 bytes | `git diff --no-index` self comparison exit 0
- `extensions/drm-copilot/test/lib/validate/codex-deployment.test.ts` | SHA-256 `3FEF4C8D16B69354B267901B642859D82B96E7ED98EDE63CED9B8664732BA403` | 5146 bytes | `git diff --no-index` self comparison exit 0
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-model-routing.test.ts` | SHA-256 `903B8B9A0E48402A9351631C79E7303FDD8E5B08B6951C20835723A9F21F1E9A` | 10970 bytes | `git diff --no-index` self comparison exit 0
- `extensions/drm-copilot/package.json` | SHA-256 `DC58E44591EE0E72C27C0DAD090CD0633B81B9FA1F708EEAB3DAD8BBD782A573` | 8770 bytes | `git diff --no-index` self comparison exit 0 | version `1.1.2`

Routing parity:
- `config/orchestration-routing.json` | SHA-256 `967778EC8ABB0B0C538953AFFAD41BDAB0EC134646675199652BEBE8E97FFCC1` | 11330 bytes
- `extensions/drm-copilot/resources/config/orchestration-routing.json` | SHA-256 `967778EC8ABB0B0C538953AFFAD41BDAB0EC134646675199652BEBE8E97FFCC1` | 11330 bytes
- Result: byte-identical.

Commit-steward profile inventory:
- `commit-steward-c1.toml` | SHA-256 `6DF81A59F85C46ED57F0A57AB87A64C9E2E93DF871760BBF31BFF8881398B5E0` | 1008 bytes | root and bundled byte-identical
- `commit-steward-c2.toml` | SHA-256 `40F57A42959CE82262A62FC01EC2EAA16BBC434C7706AD947D82C0F5887D9233` | 1012 bytes | root and bundled byte-identical
- `commit-steward-c3-elevated.toml` | SHA-256 `1378C01A8AD4DD94BC7A0A1E164E859C793C7227A8886150C6CA8402D4FF2807` | 1017 bytes | root and bundled byte-identical
- `commit-steward-c3.toml` | SHA-256 `53EF0B396A7DFA96F631A096FB308F47712148C0BCF32CF6FAD1F84E5DF8FB22` | 1010 bytes | root and bundled byte-identical
- `commit-steward-c4.toml` | SHA-256 `DCB21EB9D87A38B02F773BFC48A19854B45C46DA20FEF2162D05EF24CB9E83C4` | 1007 bytes | root and bundled byte-identical
- `commit-steward.toml` | SHA-256 `E209F61D55E3EC283017321E332DA4BA88680A98CA5DD74F24C298B5691ADA3E` | 1007 bytes | root and bundled byte-identical

Worktree-status baseline: the existing staged P0-P5 remediation delta is present, including root/bundled generated profiles, routing support, PoshQC sync, tests, plan, inputs, and existing evidence. This phase has added only `evidence/remediation-baseline/mcp-validator-parity-instructions-read.2026-08-25T22-26.md` before this artifact. No TypeScript production, test, package, or bundled-customization path was modified by baseline capture.
