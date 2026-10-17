# Feature Audit (Issue #723, minor-audit)

- AC source: `issue.md` `## Acceptance Criteria` (AC-1..AC-6). No spec.md or user-story.md by design.
- Baseline: origin/main.

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | Workflow: `$maxAttempts = 14`, `[Math]::Min($initialIntervalSeconds * $attempt, $maxIntervalSeconds)`; 630 s verified by hand. Pester test "polls with a bounded backoff schedule..." asserts count, expression, and computed budget >= 600. |
| AC-2 | PASS | Cap `$maxIntervalSeconds = 60`; `if ($attempt -lt $maxAttempts)` guards the single sleep; Pester test "caps the poll interval..." asserts cap, one sleep statement, and guard-before-sleep ordering. |
| AC-3 | PASS | Old text removed; new message has all required tokens; Pester test asserts absence and presence. |
| AC-4 | PASS | `exit 1`, `exit 0`, `$LASTEXITCODE = 0`, exact operand, and ref guard retained; test "keeps the exit-code reset..." asserts them. CI run 36927150048: 6088 passed, 0 failed (baseline 6084 + 4 new). |
| AC-5 | PASS | Runbook section "Red verify step after a green publish step" states all three required points. |
| AC-6 | PASS | actionlint empty output, exit 0; token-guard pytest 17 passed; no `NPM_TOKEN`/`NODE_AUTH_TOKEN` in the workflow. |

Evidence consistency: baseline (6084/0), fail-before (6085 passed/3 failed, the three failures being the new workflow-dependent tests), and pass-after (6088/0) reconcile. Accepted deviations D1-D8 noted.

Out-of-scope check: name-only diff shows only the three listed files plus feature-folder docs.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md`
- Total AC items: 6
- Checked off (delivered): 6 (already `[x]`; no change made by the reviewer)
- Remaining (unchecked): 0
- Items remaining: none

Residual (process, not AC): PowerShell coverage artifact absent in the review worktree; see policy-audit and remediation inputs R1.
