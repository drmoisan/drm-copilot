# Push-Down Codex Pack-Manifest Completeness — issue #539 [P5-T6]

Timestamp: 2026-08-24T20-05

Command:

```
poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q
```

EXIT_CODE: 0

## Raw result

```
..                                                                       [100%]
2 passed in 0.07s
```

## What this run gates

The test reads the real bundled `.codex`/`.agents` tree and the real `pack-manifests/*.json` files
from disk and asserts that every bundled asset is registered in some manifest, apart from a frozen
set of documented, pre-existing, out-of-scope exceptions inherited from issue #372.

The newly bundled Codex asset in scope is
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`,
created by [P5-T2]. It is registered by [P5-T3] as
`.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` in
`extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, placed
in the manifest's existing alphabetical `.codex/hooks/` ordering between
`enforce-epic-worktree-removal-gate.ps1` and `record-subagent-routing-attestation.ps1`. No path was
added to the pre-existing exception set, so the new asset passes on a real manifest entry rather
than on a suppression.

Output Summary: PASS. 2 passed, 0 failed, 0 errors, in 0.07s. Exit code 0. The Codex pack manifest
is complete over the bundled `.codex` files including the new helper.
