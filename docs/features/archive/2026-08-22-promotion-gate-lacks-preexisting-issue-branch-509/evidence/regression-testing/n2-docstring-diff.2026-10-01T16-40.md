# N2 Invariant-Text Edit Confinement (Remediation Cycle 1)

Timestamp: 2026-10-01T16-40
Task: [P3-T4] (also records [P3-T3])
Location: worktree root

## P3-T3 bundle copy

Command: `cp .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`
EXIT_CODE: 0
Output Summary: empty output.

## 1. Diff against HEAD

Command: `git diff -U0 HEAD -- scripts/dev_tools/_orchestrator_state_issue_adoption.py .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`
EXIT_CODE: 0
Output Summary (verbatim):

```text
diff --git a/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 b/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
index c44ca53d..ad49ad26 100644
--- a/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
+++ b/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
@@ -19 +19 @@
-      - Messages interpolate only validated tool names and the route id.
+      - Messages interpolate only non-blank `waived_tools` entries and the route id.
diff --git a/extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 b/extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
index c44ca53d..ad49ad26 100644
--- a/extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
+++ b/extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
@@ -19 +19 @@
-      - Messages interpolate only validated tool names and the route id.
+      - Messages interpolate only non-blank `waived_tools` entries and the route id.
diff --git a/scripts/dev_tools/_orchestrator_state_issue_adoption.py b/scripts/dev_tools/_orchestrator_state_issue_adoption.py
index c7aa9f79..e7be0639 100644
--- a/scripts/dev_tools/_orchestrator_state_issue_adoption.py
+++ b/scripts/dev_tools/_orchestrator_state_issue_adoption.py
@@ -24 +24 @@ Invariants / Constraints:
-    - Messages interpolate only validated tool names and the route id.
+    - Messages interpolate only non-blank ``waived_tools`` entries and the route id.
```

Exactly three hunks: `@@ -24 +24 @@` for the Python file (function-context text `Invariants / Constraints:` ignored) and `@@ -19 +19 @@` for each PowerShell copy. Each removes the old invariant line and adds the replacement line.

## 2. Porcelain status of the three locations

Command: `git status --porcelain -- scripts/dev_tools .claude/lib extensions/drm-copilot/resources/claude-customizations/.claude/lib`
EXIT_CODE: 0
Output Summary (verbatim):

```text
 M .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
 M extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
 M scripts/dev_tools/_orchestrator_state_issue_adoption.py
```

Exactly the three files, each with status ` M`.

## 3. Bundle pair hashes

Command: `sha256sum .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`
EXIT_CODE: 0
Output Summary (verbatim):

```text
993acecd1afaad381a63477e7ddd61508b84e9b9c8d1adfff9b6e198de77f322 *.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
993acecd1afaad381a63477e7ddd61508b84e9b9c8d1adfff9b6e198de77f322 *extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
```

The two hashes are equal to each other and differ from `RB_PS_HASH` (`26e43cf56becee5b84ba65be57a10e08fa8a1f7ba4b264908f3161155e691c7e`).

## 4. Asserted token

Command: `grep -c -F -e "only non-blank" scripts/dev_tools/_orchestrator_state_issue_adoption.py .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`
EXIT_CODE: 0
Output Summary (verbatim):

```text
scripts/dev_tools/_orchestrator_state_issue_adoption.py:1
.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1:1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1:1
```

`:1` for each of the three files.
