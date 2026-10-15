# Scope Observation: AC-7, AC-24, AC-44, AC-50 (P12-T18)

Timestamp: 2026-10-13T14-02
Command: git diff --name-status origin/main...HEAD; git diff --stat origin/main...HEAD -- .claude/rules .claude/hooks/enforce-pr-author-skill.ps1 .codex/hooks .claude/skills/orchestrate .agents/skills/orchestrate .claude/skills/parallel-orchestrate; git diff -U0 origin/main...HEAD -- .agents/skills/epic-plan/SKILL.md tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py; git status --porcelain
EXIT_CODE: 0
HEAD: 4e8d9f92d63c686f64f9f97e975448dc126c92f1
Loop-Iteration: 2
origin/main fetched at 2026-10-13T14-01 (`git fetch origin main`).

## Name-status listing, code and customization paths (feature-folder `A` entries summarized below)

```
M	.agents/skills/atomic-plan-contract/SKILL.md
M	.agents/skills/epic-plan/SKILL.md
M	.agents/skills/evidence-and-timestamp-conventions/SKILL.md
M	.claude/hooks/enforce-completion-consistency.ps1
M	.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
M	.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
M	.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
M	.claude/hooks/feature-folder-resolution.ps1
M	.claude/lib/blast-radius/BlastRadiusTokenShape.psm1
M	.claude/skills/atomic-plan-contract/SKILL.md
M	.claude/skills/evidence-and-timestamp-conventions/SKILL.md
M	.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
M	.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
M	.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
M	.codex/hooks/feature-folder-resolution.ps1
M	.github/skills/atomic-plan-contract/SKILL.md
M	.github/skills/evidence-and-timestamp-conventions/SKILL.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/other/closure-dispositions-correction.2026-10-13T11-29.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-folder-resolution.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/feature-folder-resolution.ps1
M	extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md
M	extensions/drm-copilot/resources/customizations/.github/skills/evidence-and-timestamp-conventions/SKILL.md
M	extensions/drm-copilot/test/subagent-tree-command-test-support.ts
M	extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts
M	scripts/dev_tools/_blast_radius_token_shapes.py
M	tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1
M	tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
M	tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1
M	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
M	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
M	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
M	tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1
M	tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
M	tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1
M	tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1
M	tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
M	tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
M	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
M	tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
A	tests/scripts/dev_tools/npm_token_guard_test_support.py
M	tests/scripts/dev_tools/test_blast_radius_token_shapes.py
M	tests/scripts/dev_tools/test_check_quality_tiers.py
M	tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py
A	tests/scripts/dev_tools/test_evidence_timestamp_contracts.py
M	tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py
M	tests/scripts/dev_tools/test_workflow_npm_token_guard.py
M	tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
```

The remaining 99 entries are `A` entries under `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/` (issue.md, plan, research, and evidence files). The listing has 159 entries in total (102 `A`, 57 `M`); there is no `R` or `D` entry anywhere. Compared with iteration 1, the four F-1/F-2 files (`EpicStateIsolation.Helpers.ps1` and the three `enforce-gate-suites.EpicStateIsolation*.Tests.ps1` files) no longer appear, because the P12-T27 withhold restored them to PHASE0 content.

## --stat output (protected paths)

```
 ...estration-preimplementation-gate-epic-scope.ps1 |  22 +--
 ...-orchestration-preimplementation-gate-modes.ps1 |   4 +-
 ...rchestration-preimplementation-gate-targets.ps1 | 148 +++++++++++++++++----
 .codex/hooks/feature-folder-resolution.ps1         |   4 +-
 4 files changed, 133 insertions(+), 45 deletions(-)
```

All four entries are under `.codex/hooks/` and are the permitted `-modes.ps1`, `feature-folder-resolution.ps1`, targets, and epic-scope files. Nothing under `.claude/rules`, `.claude/hooks/enforce-pr-author-skill.ps1`, or any orchestration skill path.

## -U0 diff (shared files)

```
diff --git a/.agents/skills/epic-plan/SKILL.md b/.agents/skills/epic-plan/SKILL.md
@@ -74,0 +75 @@ Admitted commit forms, each followed by `--` and the exempt path operands:
+- The one-paragraph multi-message form: the subject in the first `-m` and every trailer in one single-quoted second `-m` value, separated by a literal newline. Each `-m` value becomes its own paragraph and git parses only the last paragraph as the trailer block, so trailers split across separate `-m` values do not form one trailer block.
diff --git a/tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py b/tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py
@@ -90,3 +90,6 @@ TIMESTAMP_SOURCE_BLOCK = (
-    "The `Timestamp` value is local time read from the host system clock when the"
-    " recorded command runs (for example `Get-Date -Format yyyy-MM-ddTHH-mm`);"
-    " the agent never composes or estimates it."
+    "The `Timestamp` value is UTC read from the host system clock when the recorded"
+    " command runs (for example `Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm` in"
+    " PowerShell 7, `(Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH-mm')` in"
+    " Windows PowerShell 5.1, or `date -u +%Y-%m-%dT%H-%M` in a POSIX shell); the"
+    " agent never composes or estimates it. The value is written without a zone"
+    " suffix."
```

Region checks:
- `.agents/skills/epic-plan/SKILL.md`: `## Integration Commit Form` is at line 66 and `## Concurrent Preparation` at line 81; the single hunk adds new line 75, inside that section. No diff line contains `requires_ci_gate` (the only occurrence in the file is the unchanged line 164).
- `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`: `TIMESTAMP_SOURCE_BLOCK = (` is at line 89 and its closing `)` at line 96; the single hunk spans new lines 90-95, inside the assignment.

## Acceptance checks

| Check | Result |
|---|---|
| No path under `.claude/rules/` or `.github/instructions/` (AC-7, AC-44) | PASS (none in listing) |
| AC-24: only the five permitted `.claude/hooks/` paths | PASS (`-modes.ps1`, `feature-folder-resolution.ps1`, `enforce-completion-consistency.ps1`, `-targets.ps1`, `-epic-scope.ps1`) |
| AC-50: epic-plan hunk inside `## Integration Commit Form`; no `requires_ci_gate` diff line | PASS |
| AC-50: test-module hunk inside `TIMESTAMP_SOURCE_BLOCK = (` | PASS |
| No `enforce-pr-author-skill*` file on either surface | PASS |
| No orchestration-skill file | PASS |
| No `R` or `D` entry under any `docs/features/**/evidence/` folder | PASS (no `R` or `D` entry at all) |
| Only permitted `.codex/hooks/` paths | PASS (four permitted files) |
| No concurrent-epic reserved file (`.claude/hooks/validate-*.ps1`, `.claude/lib/hook-payload/HookPayload.psm1`, `validate-orchestrator-output*.Tests.ps1`, `hook-dependency-failure*`, `hook-import-failure-exemptions.FailClosed.Tests.ps1`, `pack-manifests/core.json`) | PASS (none in listing) |
| No path under `tests/fixtures/blast_radius/` (AC-11) | PASS |
| Porcelain lists no path outside `<FEATURE>` | PASS (0 entries outside `<FEATURE>`; 23 entries, all plan, issue, or new evidence files) |

Output Summary: PASS. All scope conditions for AC-7, AC-24, AC-44, and AC-50 hold; the two shared-file hunks are inside their permitted regions; no rename or deletion; working tree changes are confined to `<FEATURE>`.
