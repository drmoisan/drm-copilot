# AC-20 and AC-23 Scope Boundary ([P6-T10])

Timestamp: 2026-10-12T04-10
Command: git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD ; git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- .claude/agents ; git status --porcelain
EXIT_CODE: 0
Output Summary: OUT_OF_ALLOWLIST_COUNT: 0; FORBIDDEN_PATHS_FOUND: none; AGENTS_DIFF_COUNT: 1 (.claude/agents/prd-feature.md) with AGENT_EDIT_OUTCOME: LANDED; porcelain lists only feature-folder paths.

Output 1, full diff listing: identical to the listing recorded in evidence/qa-gates/line-counts.2026-10-12T04-09.md (same HEAD 149f4a9ea, no commit between). Classification:
- S-PROD-6: the six .claude/hooks/validate-*-output*.ps1 paths (in S-ALLOW).
- S-MIRROR-6: the six extensions/drm-copilot/resources/claude-customizations/.claude/hooks/ paths (in S-ALLOW).
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json (in S-ALLOW).
- S-AGENT-2: .claude/agents/prd-feature.md and extensions/drm-copilot/resources/claude-customizations/.claude/agents/prd-feature.md (in S-ALLOW, Amendment A).
- S-TEST-MOD-11 and S-TEST-NEW-8: the 19 tests/scripts/claude-hooks/ paths (in S-ALLOW).
- docs/features/active/subagentstop-envelope-orchestrator-family-903/ paths (in S-ALLOW).
Classification method: the listing was filtered through an anchored regular expression enumerating every S-ALLOW path; the filter returned no line (grep exit 1).

Output 2, .claude/agents diff (EXIT_CODE 0):
.claude/agents/prd-feature.md

Output 3, git status --porcelain: only the plan file (modified) and untracked evidence files under docs/features/active/subagentstop-envelope-orchestrator-family-903/ (listed in evidence/qa-gates/line-counts.2026-10-12T04-09.md).

Forbidden-path check: the listing was searched for .claude/settings.json, .claude/hooks/subagentstop-envelope.ps1, validate-discovery-artifact-gate.ps1, validate-pr-author-output.ps1, validate-prd-feature-output.ps1, validate-task-researcher-output.ps1, validate-feature-review-coverage.ps1, feature-review-coverage-thresholds.ps1, .claude/hooks/enforce-*.ps1, tests/scripts/codex-hooks/, .codex/, S-DEP-SUITES-2, and S-GUARD-SUITES-2; the search returned no line (grep exit 1).

OUT_OF_ALLOWLIST_COUNT: 0
AGENTS_DIFF_COUNT: 1
AGENT_EDIT_OUTCOME: LANDED (copied from evidence/other/prd-feature-registration.2026-10-12T04-06.md)
FORBIDDEN_PATHS_FOUND: none
