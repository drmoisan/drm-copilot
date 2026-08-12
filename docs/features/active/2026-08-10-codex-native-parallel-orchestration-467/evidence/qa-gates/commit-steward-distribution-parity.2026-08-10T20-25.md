# P6-T34 Commit-Steward Distribution Parity

Timestamp: `2026-08-11T22-39-04:00`

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`; focused P6-T29 and P6-T30 Pytest commands; focused P6-T31 Jest command; Python publisher selector; read-only root/bundle, registration, routing, manifest, publisher, collision, and payload-closure comparators

EXIT_CODE: `0`

Output Summary: The generated-family distribution passed generator, validator, publisher, routing-merge, pack, registration, and root/bundle parity checks. Focused Python results were `30/30`, `33/33`, and `61/61`; focused TypeScript results were `5/5` suites and `81/81` tests. All `42/42` root/bundle pairs, including the six commit-steward profiles, are byte-identical, and all `28/28` registered command targets exist at both surfaces.

## Results

- Generator check: exit `0`; unexpected generated deltas `0`.
- Strict Python checkpoint/runtime inventory: `30` passed, `0` failed.
- Python publisher and exact-pack owners: `33` passed, `0` failed.
- Python publisher/pack/parity selector: `61` passed, `3,790` deselected, `0` failed.
- TypeScript validator/publisher/routing owners: `5/5` suites, `81/81` tests, `0` failed.
- Original root/bundle set: `36/36`; generated commit-steward additions: `6/6`; combined set: `42/42`.
- Registered command targets: `28/28` at root and `28/28` in the Codex resource bundle.
- Core manifest: `133` unique members; commit-steward base plus five generated profiles: `6/6`, each exactly once.
- Selected language manifests: `5/5`; the six profiles are inherited through core and have no unrelated language-pack duplicate membership.
- Three routing surfaces: `3/3` byte-identical at `12,072` bytes and SHA-256 `7A30F003994AE274F6B9BF7A2FCC1FF598F0CCE743CC8663060EB3DF50742231`; `commit-steward` appears exactly once at ordinal `11`.
- Python and TypeScript selected-core publisher tests emit the same sorted six-profile closure. Destination retention, equal-entry skip, deterministic `ROUTING_MERGE_SUBSTANTIVE_COLLISION` ordering, issue-462 allowlisting, and unrelated-Claude exclusion remain enforced.
- Previously validated restricted-PATH payload closure remains source-identical: Python/TypeScript output `126/126` paths and hashes and `42/42` payload assertions; correction-owned paths do not alter the portable Bash payload.

## Six-profile SHA-256 matrix

| Profile | Bytes | Root/bundle SHA-256 |
| --- | ---: | --- |
| `commit-steward` | `1,007` | `E209F61D55E3EC283017321E332DA4BA88680A98CA5DD74F24C298B5691ADA3E` |
| `commit-steward-c1` | `1,008` | `6DF81A59F85C46ED57F0A57AB87A64C9E2E93DF871760BBF31BFF8881398B5E0` |
| `commit-steward-c2` | `1,012` | `40F57A42959CE82262A62FC01EC2EAA16BBC434C7706AD947D82C0F5887D9233` |
| `commit-steward-c3` | `1,010` | `53EF0B396A7DFA96F631A096FB308F47712148C0BCF32CF6FAD1F84E5DF8FB22` |
| `commit-steward-c3-elevated` | `1,017` | `1378C01A8AD4DD94BC7A0A1E164E859C793C7227A8886150C6CA8402D4FF2807` |
| `commit-steward-c4` | `1,007` | `DCB21EB9D87A38B02F773BFC48A19854B45C46DA20FEF2162D05EF24CB9E83C4` |

Result: `PASS`.
