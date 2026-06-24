# Phase 4 — Failure Branch Confirmation

Timestamp: 2026-06-24T17-55

Command: ./scripts/orchestration/Invoke-CiGateParser.ps1 -ChecksJson '[{"name":"build","bucket":"pass"},{"name":"test","bucket":"fail"}]' -HeadSha 'sha-failure' -PrPipelineRunId '101' -PrPipelineRunUrl 'https://x/101' -NowProvider { '2026-06-24T17:55:00Z' }

EXIT_CODE: 0

Output Summary:
- Emitted ci_gate object: head_sha=sha-failure, pr_pipeline_run_id=101, pr_pipeline_run_url=https://x/101, conclusion=failure, verified_at=2026-06-24T17:55:00Z
- conclusion == "failure" confirmed when any required check is in the 'fail' bucket.
