# P6-T30 Commit-Steward Python Publisher and Pack Coverage

Timestamp: `2026-08-10T20-25`

Command: `poetry run black <three owners>` -> `poetry run ruff check <three owners>` -> `poetry run pyright <three owners>` -> `poetry run pytest -q tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_pack_selection.py`

EXIT_CODE: `0`, `0`, `0`, `0`

Output Summary: The clean restarted ordered pass completed with `33 passed, 0 failed in 0.21s`; Ruff reported all checks passed and Pyright reported `0 errors, 0 warnings, 0 informations`. The first focused run had `32` passing tests and one infrastructure-only failure because the active, verified P6-T30 batch receipt appeared under `.codex/state`; the receipt named exactly the three test owners, was removed, and the complete loop was restarted.

## Contract Results

- Full-tree and selected-core modes carry exactly six commit-steward profiles: base, C1, C2, C3, C3-elevated, and C4.
- Every profile occurs exactly once in `core.json`; every selected language manifest contains zero direct commit-steward entries and therefore inherits the family only through core.
- All six root/resource profile pairs are byte-identical. Their SHA-256 values are `E209F61D55E3EC283017321E332DA4BA88680A98CA5DD74F24C298B5691ADA3E`, `6DF81A59F85C46ED57F0A57AB87A64C9E2E93DF871760BBF31BFF8881398B5E0`, `40F57A42959CE82262A62FC01EC2EAA16BBC434C7706AD947D82C0F5887D9233`, `53EF0B396A7DFA96F631A096FB308F47712148C0BCF32CF6FAD1F84E5DF8FB22`, `1378C01A8AD4DD94BC7A0A1E164E859C793C7227A8886150C6CA8402D4FF2807`, and `DCB21EB9D87A38B02F773BFC48A19854B45C46DA20FEF2162D05EF24CB9E83C4` in profile order.
- The obsolete base-profile manifest exception was removed. Duplicate/collision, route-merge, issue-462 allowlist, portable-asset, and exact approved `.claude/` membership assertions remain in the same focused suites.

## Owner and Repository Invariants

- Test owner sizes: `317`, `385`, and `416` lines.
- Temporary-file API/pattern findings: `0`.
- `git diff --check -- <three owners>`: exit `0`.
- `.claude/` status entries: `0`.
- `.codex/state` exists: `false`.
- Production publisher changes in P6-T30: `0`.

Result: `PASS`.
