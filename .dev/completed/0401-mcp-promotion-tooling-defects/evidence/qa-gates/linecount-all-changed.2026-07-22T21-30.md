# Line-Count — Every Changed/New Production and Test File (Cycle 1, Issue #401)

Timestamp: 2026-07-22T21-30

Command:
- git diff --name-only a0b251d330525b8307467f4cf529c5cc3e947445..HEAD -- '*.ts' '*.py' (plus the two new untracked files added on this branch)
- wc -l <every remaining production and test file after excluding docs/**>

EXIT_CODE: 0

Output Summary (numeric line count per file; limit is 500):

Production (TypeScript):
- extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts = 443 (<= 500)
- extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts = 214 (<= 500)
- extensions/drm-copilot/src/mcp-push-down-schema-properties.ts = 59 (<= 500)
- extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts = 402 (<= 500)  [R1 original, was 504]
- extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-poshqc.ts = 123 (<= 500)  [R1 new sibling]
- extensions/drm-copilot/src/mcp-tool-definitions.ts = 451 (<= 500)
- extensions/drm-copilot/src/mcp-tool-inputs-potential-to-issue.ts = 60 (<= 500)
- extensions/drm-copilot/src/mcp-tool-inputs.ts = 477 (<= 500)
- extensions/drm-copilot/src/workflow-command-arguments.ts = 410 (<= 500)

Tests (TypeScript):
- extensions/drm-copilot/test/extension.list-mcp-tools.test.ts = 70 (<= 500)
- extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts = 237 (<= 500)
- extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts = 171 (<= 500)
- extensions/drm-copilot/test/lib/potential-to-issue/promotion.matrix.test.ts = 128 (<= 500)
- extensions/drm-copilot/test/lib/potential-to-issue/promotion.test.ts = 468 (<= 500)
- extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts = 332 (<= 500)
- extensions/drm-copilot/test/mcp-server.test.ts = 487 (<= 500)
- extensions/drm-copilot/test/mcp-tool-inputs-discovery.test.ts = 296 (<= 500)
- extensions/drm-copilot/test/mcp-tool-inputs.test.ts = 496 (<= 500)
- extensions/drm-copilot/test/mcp-tool-inputs.workspace-root.test.ts = 60 (<= 500)
- extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts = 209 (<= 500)
- extensions/drm-copilot/test/mcp-tools.workspace-root.test.ts = 70 (<= 500)
- extensions/drm-copilot/test/repo-automation-render-subagent-tree.test.ts = 223 (<= 500)
- extensions/drm-copilot/test/workflow-command-arguments.test.ts = 223 (<= 500)

Production (Python):
- scripts/dev_tools/potential_to_issue.py = 639  DEFERRED (R3) — pre-existing over-500 file (634 at merge-base); not in scope this cycle.

Tests (Python):
- tests/scripts/dev_tools/test_potential_to_issue.py = 1076  DEFERRED (R3) — pre-existing over-500 file (1017 at merge-base); not in scope this cycle.
- tests/scripts/dev_tools/test_potential_to_issue_branches.py = 408 (<= 500)  [R2 new file]

Verdict: Every changed/new production and test file is <= 500 lines EXCEPT exactly the two pre-existing R3-deferred files (potential_to_issue.py 639, test_potential_to_issue.py 1076). The R1 blocking finding is resolved: mcp-repo-automation-tool-definitions.ts is now 402 (<= 500) and the new sibling is 123 (<= 500).
