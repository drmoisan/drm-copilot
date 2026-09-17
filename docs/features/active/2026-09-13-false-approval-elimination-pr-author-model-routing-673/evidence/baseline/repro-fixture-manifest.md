# Reproduction Fixture Manifest — Issue #673 ([P1-T2])

Timestamp: 2026-09-17T10-40

Command: sh "C:/Users/DanMoisan/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-09-13T08-30/edea1a9d-6671-4ea6-8e13-6405d6284a83/scratchpad/f673-exec/p1t2.sh"
(route a-prime; the script launches `"/c/Program Files/PowerShell/7/pwsh.exe" -NoProfile -File .../f673-exec/p1t2.ps1`)

EXIT_CODE: 0

Output Summary: Both fixture roots were created in the session scratchpad, not in the repository. The
session-root checkpoint passed `Invoke-OrchestratorStatePreflight` with `HasErrors: False` and empty error
text, so the sibling checkpoint is genuinely PR-creation ready. The item-worktree `artifacts/orchestration`
directory is empty (entry count 0).

## Fixture roots (absolute paths)

- Session root: `C:\Users\DanMoisan\AppData\Local\Temp\claude\C--Users-DanMoisan-repos-drm-copilot-wt-2026-09-13T08-30\edea1a9d-6671-4ea6-8e13-6405d6284a83\scratchpad\f673-exec\repro\session-root`
- Item worktree: `C:\Users\DanMoisan\AppData\Local\Temp\claude\C--Users-DanMoisan-repos-drm-copilot-wt-2026-09-13T08-30\edea1a9d-6671-4ea6-8e13-6405d6284a83\scratchpad\f673-exec\repro\item-worktree`

## Layout

```
session-root/
  artifacts/orchestration/orchestrator-state.json   sibling item A, PR-creation ready, epic_mode absent
  artifacts/pr_context.summary.txt                  last write 2026-09-17T12:40:47.7290186Z (UTC)
  artifacts/pr_body_1.md                            "Sibling item A pull request body.\n"
  artifacts/pr_body_1.receipt.json                  number 1, sha256 of the body bytes, created_at newer
item-worktree/
  artifacts/orchestration/                          empty; item B has no checkpoint
```

- Body SHA-256: `8ec387387dff3f847368741d1e8ea393c1e8b70b7f8d7e8e00bcffc2dc1432bb`
- Receipt `created_at`: `2026-09-17T13:40:47Z`, strictly newer than the context file's last write.

## Readiness satisfaction

The checkpoint carries all 22 `REQUIRED_STATE_KEYS`; `step5_status` through `step8_status` are
`completed`/`completed`/`completed`/`in_progress`, none of them in `{pending, blocked,
blocked_remediation_loop_limit}`; `blocked_reason` is `none`; and `local_execution_overrides` and
`delegation_bypasses` are empty lists. The `model_routing_receipts` entry uses the shape the repository's
own live checkpoint uses and passes the U6.M model-resolution check, so the same checkpoint serves both the
defect 3.2 and the defect 3.4 pairs.

Verified by the fixture sanity check in the same run:
```
FixturePreflightHasErrors: False
FixturePreflightErrorText:
```

## Fixture checkpoint, full text

```json
{
  "objective": "Sibling item A: unrelated single-feature run left at the session root.",
  "change_budget_estimate": {
    "production_files": 1,
    "test_files": 1,
    "rationale": "Sibling item A fixture."
  },
  "path_selected": "small",
  "route_id": "small",
  "promotion-type": "bug",
  "short-name": "sibling-item-a",
  "relativeFile": "docs/features/potential/promoted/sibling-item-a.md",
  "long-name": "sibling-item-a",
  "issue-num": "838",
  "feature-folder": "docs/features/active/sibling-item-a-838",
  "work-mode": "full-bug",
  "plan-path": "docs/features/active/sibling-item-a-838/plan.md",
  "completed_steps": [
    "S1_scope",
    "S2_research",
    "S3_promotion",
    "S4_atomic_planning",
    "S5_atomic_execution"
  ],
  "next_step": "S8_create_pr",
  "last_updated": "2026-09-17T12:00:00Z",
  "step5_status": "completed",
  "step6_status": "completed",
  "step7_status": "completed",
  "step8_status": "in_progress",
  "step9_status": "not_started",
  "step10_status": "not_started",
  "delegation_receipts": [],
  "model_routing_receipts": [
    {
      "agent": "atomic-planner",
      "phase": "S4_atomic_planning",
      "complexity_band": "C3",
      "fable_policy": "disabled",
      "table_model": "opus",
      "clamped_from": null,
      "model": "opus"
    }
  ],
  "local_execution_overrides": [],
  "delegation_bypasses": [],
  "blocked_reason": "none"
}
```

## Receipt file, full text

```json
{
  "number": 1,
  "sha256": "8ec387387dff3f847368741d1e8ea393c1e8b70b7f8d7e8e00bcffc2dc1432bb",
  "created_at": "2026-09-17T13:40:47Z"
}
```
