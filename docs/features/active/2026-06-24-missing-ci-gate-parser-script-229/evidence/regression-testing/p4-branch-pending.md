# Phase 4 — Pending Branch Confirmation

Timestamp: 2026-06-24T17-55

Command: ./scripts/orchestration/Invoke-CiGateParser.ps1 -ChecksJson '[{"name":"build","bucket":"pass"},{"name":"test","bucket":"pending"}]' -HeadSha 'sha-pending' -PrPipelineRunId '102' -PrPipelineRunUrl 'https://x/102' -NowProvider { '2026-06-24T17:55:00Z' }

EXIT_CODE: 0

Output Summary:
- Emitted ci_gate object: head_sha=sha-pending, pr_pipeline_run_id=102, pr_pipeline_run_url=https://x/102, conclusion=pending, verified_at=2026-06-24T17:55:00Z
- conclusion == "pending" confirmed when a required check is 'pending' and none failed.
