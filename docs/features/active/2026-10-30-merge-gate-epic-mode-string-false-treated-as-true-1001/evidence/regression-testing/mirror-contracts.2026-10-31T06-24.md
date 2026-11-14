# Bundled Mirror Parity and Contracts (issue #1001)

Timestamp: 2026-10-31T06-24
Command: sh SCRATCH/issue-1001-mirror.sh (cp each .claude/hooks source to extensions/drm-copilot/resources/claude-customizations/.claude/hooks/, then sha256sum both)
EXIT_CODE: 0

## [P3-T1] SHA-256 pairs (source = mirror)

| File | Source SHA-256 | Mirror SHA-256 | Result |
|---|---|---|---|
| `enforce-epic-merge-gate.ps1` | 2a5f2d3dba4613b3dcac5c1a15eb09a022d37827b8e61a09bcf8a66525b842e9 | 2a5f2d3dba4613b3dcac5c1a15eb09a022d37827b8e61a09bcf8a66525b842e9 | equal |
| `enforce-pr-author-skill.epic-base-branch.ps1` | 27042c9c3d1c7a0b19853e2a1c8dfa6f91f683a239ad9974cbf1da0e5a9ecfe6 | 27042c9c3d1c7a0b19853e2a1c8dfa6f91f683a239ad9974cbf1da0e5a9ecfe6 | equal |
| `enforce-model-routing-receipt.ps1` | 8f8c009e58e441dd6767c33b55a4cdc1e7c993d80c469ad894db9a8d8d39a87c | 8f8c009e58e441dd6767c33b55a4cdc1e7c993d80c469ad894db9a8d8d39a87c | equal |

## [P3-T2] Contract tests

Command: poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -v -p no:cacheprovider
EXIT_CODE: 0

Output Summary: three equal SHA-256 pairs; 34 passed, 0 failed; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` PASSED.
