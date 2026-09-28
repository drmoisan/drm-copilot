# Regression Testing — Bundle-Parity Suites (P3-T6)

- **Issue:** #441
- **Feature:** 2026-08-07-parallel-orchestrator-surface-441
- **Task:** [P3-T6]
- **Branch:** `feature/parallel-orchestrator-surface-441`

Timestamp: 2026-08-08T18-05

## Command (a) — Python bundle-parity suites

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -v
```

EXIT_CODE: 0

## Command (b) — TypeScript bundle-parity suites

Working directory: `extensions/drm-copilot`

```
node run-jest.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts test/lib/push-down/claude-customizations.test.ts
```

EXIT_CODE: 0

## Output Summary

Both commands exited 0 with zero failures. No test was modified; the bundle payload and the
`core.json` pack manifest were brought into parity, which is what the suites assert.

| # | Command | Exit code | Passed | Failed | Skipped |
| --- | --- | --- | --- | --- | --- |
| (a) | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -v` | 0 | 9 | 0 | 0 |
| (b) | `node run-jest.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts test/lib/push-down/claude-customizations.test.ts` | 0 | 17 | 0 | 0 |

Both commands were run twice. The first run followed the initial P3-T4 mirror copy. A subsequent
wording alignment in `.claude/skills/parallel-run/SKILL.md` (to carry the exact phrase
`rather than re-running promotion, research, or planning`) invalidated that file's mirror, so P3-T4
was re-run to re-sync the mirror and both suites were re-executed. The values recorded here are
from the final clean pass after re-sync: command (a) `9 passed in 0.14s`, command (b)
`Tests: 17 passed, 17 total` in 0.387 s. Both runs were green; the second is authoritative.

Command (a) headline: `9 passed` — 9 collected, 9 passed, 0 failed. All seven tests in
`test_push_down_claude_resource_contracts.py` passed, including
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which asserts that every repo
`.claude/**` file (excluding `.claude/settings.local.json` and `.claude/agent-memory/**`) exists in
the bundled payload with identical content. Both tests in
`test_push_down_claude_pack_manifest_completeness.py` passed, including
`test_bundled_claude_files_are_listed_in_some_pack_manifest`.

Command (b) headline: `Test Suites: 2 passed, 2 total` / `Tests: 17 passed, 17 total`, 0 snapshots,
1.344 s. The TypeScript twin of the pack-manifest completeness check remains green.

Exit codes were captured from the process directly (not through a pipeline), so the recorded values
are the test runners' own exit codes rather than a downstream filter's.

## Inputs verified by these runs

Three bundled mirrors added by P3-T4, each byte-identical to its repo counterpart (SHA-256):

| Repo path | Bundled path | SHA-256 | Match |
| --- | --- | --- | --- |
| `.claude/agents/parallel-orchestrator.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md` | `94f5f08bd318f72aed0971c1aefdb7b68ca5b8c694c229a682d68fc43a3318f4` | PASS |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | `592d0054f078da98aa4e65f357720d6c251e26f7e7b14f4ff39f278964c3d137` | PASS |
| `.claude/skills/parallel-run/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-run/SKILL.md` | `9fc7fe3ad95df22d16081c0b2dae65956699a6001eddf10a9d66977166f56a90` | PASS |

The `parallel-run` pair hash above is the post-re-sync value. Its pre-alignment value was
`124953b2f3a99533db2dabb3410f1c1f141b8f28300e3975c7a0bce7e18de1d8` (also matching on both sides at
that point); the wording alignment described above changed the content of both sides identically.

Three pack-manifest entries added by P3-T5 to
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (valid JSON,
102 paths total, each new entry appearing exactly once, no duplicates, diff is three pure
insertions with no removal or reordering): `.claude/agents/parallel-orchestrator.md`,
`.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/parallel-run/SKILL.md`.
