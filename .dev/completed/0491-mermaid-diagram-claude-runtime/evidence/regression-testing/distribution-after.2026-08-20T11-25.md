# Distribution Suites After the Mirror and Manifest Edits (issue #491, [P5-T11])

Timestamp: 2026-08-20T11-25

Precondition: `.claude/state/` absent, verified immediately before the runs. The [P5-T3] and
[P5-T5] mirror writes are the reason this precondition is repeated here: the resource-contracts
suite enumerates repo `.claude/**` with `rglob` and does not read `.gitignore`, so a session-scoped
budget state file would fail the suite for a reason unrelated to this change.

## 1. Bundled-resource parity

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
EXIT_CODE: 0
Output Summary: `10 passed in 0.19s`. Pairs with the [P5-T1] failing run, where the same suite
reported `1 failed, 9 passed` naming `.claude/hooks/enforce-mermaid-validation.ps1` as missing from
the bundle.

## 2. Python manifest completeness

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q`
EXIT_CODE: 0
Output Summary: `2 passed in 0.04s`. Pairs with the [P5-T8] failing run, which named the hook and
SKILL.md.

## 3. TypeScript manifest completeness

Command: `cd extensions/drm-copilot && npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts`
EXIT_CODE: 0
Output Summary: `Test Suites: 1 passed, 1 total; Tests: 15 passed, 15 total`. Pairs with the
[P5-T8] failing run, which named seven paths.

## Negative-control pairing

| Gate | Before (expect-fail) | After |
| --- | --- | --- |
| Bundled-resource parity | EXIT 1, `1 failed, 9 passed`, names an unmirrored repo `.claude` file | EXIT 0, `10 passed` |
| Python manifest completeness | EXIT 1, names 2 unlisted paths | EXIT 0, `2 passed` |
| TypeScript manifest completeness | EXIT 1, names 7 unlisted paths | EXIT 0, `15 passed` |

Each gate was observed failing for this change and then passing after the mirror and manifest edits,
so none of the three green results is vacuous. AC-19 and AC-21 satisfied.

Mirror inventory verified byte-identical by `cmp` at creation time: 4 `.psm1` modules, 1 hook `.ps1`,
`rules/mermaid.md`, `skills/mermaid-diagram/SKILL.md`, 9 `references/*.md`, and `settings.json` —
16 files, zero mismatches.
