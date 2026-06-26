# Phase 0 — F9 Source and Wiring Read (ts-pr-context)

Timestamp: 2026-06-26T10-02

Python source modules read (parity targets — bundled copies):
- extensions/drm-copilot/resources/scripts/dev_tools/pr_context/models.py
- extensions/drm-copilot/resources/scripts/dev_tools/pr_context/git.py
- extensions/drm-copilot/resources/scripts/dev_tools/pr_context/github.py
- extensions/drm-copilot/resources/scripts/dev_tools/pr_context/feature_docs.py
- extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render.py
- extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render_feature_excerpts.py
- extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render_pr_helpers.py
- extensions/drm-copilot/resources/scripts/dev_tools/pr_context/summary_helpers.py
- extensions/drm-copilot/resources/scripts/dev_tools/pr_context/verification_evidence.py
- extensions/drm-copilot/resources/scripts/dev_tools/pr_context/collector.py
- extensions/drm-copilot/resources/scripts/dev_tools/pr_context/__init__.py (empty)
- extensions/drm-copilot/resources/templates/collect_pr_context.py (thin wrapper)

TypeScript wiring targets read:
- extensions/drm-copilot/src/repo-automation-service.ts (collectPrContext at lines 215-244; 499 lines total)
- extensions/drm-copilot/src/pr-context-branches.ts (branch discovery; uses cp.spawnSync git)
- extensions/drm-copilot/src/mcp-handlers/collect-context-handlers.ts (not to be modified)
- extensions/drm-copilot/src/mcp-tool-inputs.ts (not to be modified)
- extensions/drm-copilot/src/repo-automation-service-support.ts (normalizeGeneratedPath at line 70)
- extensions/drm-copilot/src/lib/file-system.ts (F1 FileSystem; glob/isFile/readTextFile/writeTextFile/ensureDir)
- extensions/drm-copilot/src/lib/subprocess-runner.ts (F1 CommandRunner/CommandResult; rstrip + parity error message)
- extensions/drm-copilot/src/lib/new-potential-bug-entry-service-call.ts (service-call precedent)

Python test files (ports per Phase 2-8; read phase-by-phase during execution):
- tests/scripts/dev_tools/test_git.py
- tests/scripts/dev_tools/test_github.py
- tests/scripts/dev_tools/test_github_part2.py
- tests/scripts/dev_tools/test_github_part3.py
- tests/scripts/dev_tools/test_feature_docs.py
- tests/scripts/dev_tools/test_render.py
- tests/scripts/dev_tools/test_render_helpers.py
- tests/scripts/dev_tools/test_collect_pr_context.py
- tests/scripts/dev_tools/test_collect_pr_context_part2.py
- tests/scripts/dev_tools/test_collect_pr_context_part3.py
- tests/scripts/dev_tools/test_collect_pr_context_part4.py
- tests/scripts/dev_tools/test_pr_context_integration.py

Existing extension test to rework (Phase 8):
- extensions/drm-copilot/test/extension.collect-pr-context.test.ts (417 lines)
