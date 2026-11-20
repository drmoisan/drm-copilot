# Acceptance Criteria Status (spec.md)

Timestamp: 2026-10-08T19-15
Command: grep -c -e '- \[x\] ' docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/spec.md ; grep -c -e '- \[ \] ' docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/spec.md
EXIT_CODE: 0
Output Summary: 34 checked, 1 unchecked. The only unchecked item is AC item 30 (spec.md line 302), which requires the bundle-contract, manifest, and Codex contract suites to pass in CI on the pull request. Those suites pass locally (qa-gates/pytest-bundle-contracts.3.2026-10-08T19-14.md, 32 passed; other/targeted-codex-contracts.2026-10-08T19-25.md, 53 passed), but the CI run on the epic-child pull request has not happened yet.

### Acceptance Criteria Status
- Source: docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/spec.md
- Total AC items: 35
- Checked off (delivered): 34
- Remaining (unchecked): 1
- Items remaining: AC item 30, "`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_codex_core_manifest_closure.py`, `codex-epic-runtime-contracts.Tests.ps1`, and `legacy-codex-hook-contracts.Tests.ps1` pass in CI on the pull request." This item is pending the PR CI run on the epic-child pull request. An epic-child PR may need a manual `workflow_dispatch` of `ci.yml` to obtain CI results.
