# Task Check P2-T1

Timestamp: 2026-11-18T09-15
Command: node SCRATCH/issue-1029-p2t1-verify.cjs <worktree> SCRATCH/issue-1029-s-list.txt; git diff --stat <integration merge base> -- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down; env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (P1 gate run)
EXIT_CODE: 0
Output Summary: Every manifest parses with name equal to its stem. shared.json: name shared, label Shared layer, no source_prefix, 143 paths equal to the P0-T1 record of S, including AGENTS.md and the three config paths, and no .ps1, .psm1 or .sh path. Codex core.json has no diff against the integration merge base, so the D16 entries are unchanged. The five Copilot manifests (core 129, python 8, powershell 8, typescript 4, csharp 8) cover exactly the 157 bundle files. X13 passed unmodified in the pytest run (17122 passed).

## Changed files

- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/shared.json`
- `extensions/drm-copilot/resources/customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/customizations/pack-manifests/python.json`
- `extensions/drm-copilot/resources/customizations/pack-manifests/powershell.json`
- `extensions/drm-copilot/resources/customizations/pack-manifests/typescript.json`
- `extensions/drm-copilot/resources/customizations/pack-manifests/csharp.json`

## Test selection

- Selection: test/lib/push-down (the shared-layer real-tree cases read shared.json); the Python contract tests that read the Codex pack-manifests folder (test_push_down_pack_manifest_dependency_closure.py, X13) ran in the P1 gate pytest run over this tree
- Rule: contract tests that read the changed configuration paths

## Commands

| Command | Exit code |
| --- | --- |
| `node SCRATCH/issue-1029-p2t1-verify.cjs <worktree> SCRATCH/issue-1029-s-list.txt` | 0 |
| `git diff --stat <integration merge base> -- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | 0 |
| `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down` | 0 |
| `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (P1 gate run)` | 0 |
