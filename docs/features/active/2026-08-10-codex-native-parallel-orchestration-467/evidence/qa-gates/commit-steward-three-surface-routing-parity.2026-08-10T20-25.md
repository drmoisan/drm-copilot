# P6-T34 Commit-Steward Three-Surface Routing Parity

Timestamp: `2026-08-10T20-25`

Command: resolve and containment-check the canonical root, Codex bundle, and Claude customization routing paths -> parse all three with `ConvertFrom-Json -Depth 100` -> raw-byte/byte-count/SHA-256 comparison -> generated-family ordinal and full JSON comparison -> verify P6-T33 correction-owner receipt -> `git diff --exit-code -- .claude`

EXIT_CODE: `0`

Output Summary: All three routing documents are contained, distinct regular files, parse successfully, and are byte-identical at `12,072` bytes with SHA-256 `7A30F003994AE274F6B9BF7A2FCC1FF598F0CCE743CC8663060EB3DF50742231`. Each generated-family array contains exactly one `commit-steward` at zero-based ordinal `11`; every pre-existing family and all other JSON content are equal. The P6-T33 Claude-mirror correction receipt exists with SHA-256 `D40789D7BD70E8BE31B3ACECF1049BA904D3B7BCB7CFC4626FD928259E21C555`. `.claude/` has no diff.

| Surface | Repository-relative path | Bytes | SHA-256 | JSON parse | `commit-steward` count/ordinal |
| --- | --- | ---: | --- | --- | --- |
| Canonical | `config/orchestration-routing.json` | 12,072 | `7A30F003994AE274F6B9BF7A2FCC1FF598F0CCE743CC8663060EB3DF50742231` | PASS | `1 / 11` |
| Codex bundle | `extensions/drm-copilot/resources/config/orchestration-routing.json` | 12,072 | `7A30F003994AE274F6B9BF7A2FCC1FF598F0CCE743CC8663060EB3DF50742231` | PASS | `1 / 11` |
| Claude customization | `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` | 12,072 | `7A30F003994AE274F6B9BF7A2FCC1FF598F0CCE743CC8663060EB3DF50742231` | PASS | `1 / 11` |

## Assertions

- Workspace containment and named relative-path identity: `3/3`.
- Missing files, directories, reparse-point escapes, or aliases: `0`.
- Raw-byte equality: `3/3`.
- Parsed full-object equality: `3/3`.
- Pre-existing generated-family ordering/content equality: `PASS`.
- Duplicate `commit-steward` entries: `0`.
- Additional config writes during this independent check: `0`.
- Explicit P6-T33 correction owners: `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` and `evidence/qa-gates/commit-steward-claude-routing-mirror-sync.2026-08-10T20-25.md`.
- `git diff --exit-code -- .claude`: exit `0`.

Result: `PASS`.
