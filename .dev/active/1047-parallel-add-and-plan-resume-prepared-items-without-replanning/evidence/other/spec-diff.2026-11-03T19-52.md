# Spec Diff for the reuse-edges Row

Timestamp: 2026-11-03T19-52
Task: [P4-T3]
Command: git diff --no-renames 5000b6455e2a76d10b7468313f3566efbeb4142b -- <FEATURE>/spec.md (the branch head recorded in remediation-baseline/scope-baseline.2026-11-03T19-22.md)
EXIT_CODE: 0
Output Summary: one added line (the reuse-edges row of the ## API / CLI Surface table) and no removed line; no line under ## Acceptance Criteria changed.

```diff
@@ -80,6 +80,7 @@ Entry point: `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admissi
 | `order-cohorts` | `-Cohorts <json> -Edges "<a>:<b> ..." -Precedence "<before>:<after> ..." [-Pinned ...] [-Floor <c>]` | Lifted cohort table; rejects `precedence_cycle` or `precedence_unknown_item`. |
 | `test-cohorts` | `-CheckpointPath <p>` | Rejects `precedence_violated` when the current-generation cohort table violates an active precedence entry. |
 | `record` | `-RunFolder docs/features/parallel/<slug> -Entry <json>` | Durable scheduling-record content; the caller writes and commits it; the helper performs no git write. |
+| `reuse-edges` | `-Slug <slug> -IssueNum <n> -PlanHash <hex> [-Ref origin/parallel/<slug>-plan]` | `{action, edges, reason}` with `action` `reuse` (reason `plan_hash_matches`, `edges` the item's recorded edges) or `recompute` (reason `record_missing`, `unknown_item`, or `plan_hash_changed`); reads the committed record by ref, runs no fetch, and performs no git write. |
 
 - Example: `... Invoke-ParallelAdmission.ps1 guard-run -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ManifestMode closed` exits 1 with `PARALLEL_ADMISSION_REJECTED: run_closed: <detail>`.
 - Contracts and validation rules:
```
