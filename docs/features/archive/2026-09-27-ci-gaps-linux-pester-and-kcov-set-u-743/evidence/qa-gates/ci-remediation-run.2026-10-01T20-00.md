# CI Verification Run Dispatch (P4-T2)

Timestamp: 2026-10-01T20-00

Command: date -u +%Y-%m-%dT%H:%M:%SZ
EXIT_CODE: 0
Output Summary: dispatch time 2026-10-01T19:59:50Z

Command: gh workflow run ci.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743
EXIT_CODE: 0
Output Summary: https://github.com/drmoisan/drm-copilot/actions/runs/36918378249

Command: gh run list --workflow=ci.yml --branch bug/ci-gaps-linux-pester-and-kcov-set-u-743 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt
EXIT_CODE: 0
Output Summary: `{"conclusion":"","createdAt":"2026-10-01T20:00:06Z","databaseId":36918378249,"headSha":"42db4491a6a7af4d0a876bf4022f7153e66f5c88","status":"queued"}` (created after the dispatch time).

RUN_ID: 36918378249

Acceptance: headSha equals CI_SHA (42db4491a6a7af4d0a876bf4022f7153e66f5c88). Met.
