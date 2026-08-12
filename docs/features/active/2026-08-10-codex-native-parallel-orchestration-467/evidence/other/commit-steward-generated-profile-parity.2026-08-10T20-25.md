# P6-T28 Commit-Steward Generated Profile Parity

Timestamp: `2026-08-10T20-25`

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` followed by `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`

EXIT_CODE: `0` and `0`

Output Summary: The generator created the missing root/bundle C1, C2, C3, C3-elevated, and C4 profiles, refreshed both backward-compatible base aliases, and added the base plus five profiles to core exactly once. Final changed-output membership is exactly the 13 authorized paths. Five language manifests received transient line-ending rewrites from the prescribed generator command and were restored byte-for-byte to their pre-task index state; the subsequent generator `--check` exits `0` and final out-of-allowlist delta is `0`.

## Exact Output Inventory

- Root: `.codex/agents/commit-steward.toml`, `commit-steward-c1.toml`, `commit-steward-c2.toml`, `commit-steward-c3.toml`, `commit-steward-c3-elevated.toml`, `commit-steward-c4.toml`.
- Bundle: the same six paths beneath `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`.
- Manifest: `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- Authorized paths changed relative to the pre-task byte inventory: `13/13`.
- Final generator-related paths outside the allowlist: `0`.

## Model and Pair Matrix

| Profile | Model | Reasoning | Root/bundle SHA-256 | Lines each |
|---|---|---|---|---:|
| base C3 alias | `gpt-5.6-terra` | `high` | `E209F61D55E3EC283017321E332DA4BA88680A98CA5DD74F24C298B5691ADA3E` | 22 |
| C1 | `gpt-5.6-luna` | `low` | `6DF81A59F85C46ED57F0A57AB87A64C9E2E93DF871760BBF31BFF8881398B5E0` | 22 |
| C2 | `gpt-5.6-terra` | `medium` | `40F57A42959CE82262A62FC01EC2EAA16BBC434C7706AD947D82C0F5887D9233` | 22 |
| C3 | `gpt-5.6-terra` | `high` | `53EF0B396A7DFA96F631A096FB308F47712148C0BCF32CF6FAD1F84E5DF8FB22` | 22 |
| C3 elevated | `gpt-5.6-sol` | `high` | `1378C01A8AD4DD94BC7A0A1E164E859C793C7227A8886150C6CA8402D4FF2807` | 22 |
| C4 | `gpt-5.6-sol` | `max` | `DCB21EB9D87A38B02F773BFC48A19854B45C46DA20FEF2162D05EF24CB9E83C4` | 22 |

## Validation

- TOML parse: `6/6` root documents; byte-identical bundle pairs establish the other six.
- Persona bodies: `6/6` equal after removing only generated name, description, model, and reasoning fields.
- Core manifest membership: `6/6`, each exactly once; manifest `139` lines.
- `git diff --check -- <13-path allowlist>`: exit `0`.
- `.claude/` status: `0`.
- Duplicate entries, collisions, existing-family/profile changes, and final out-of-allowlist changes: `0`.

Result: `PASS`.
