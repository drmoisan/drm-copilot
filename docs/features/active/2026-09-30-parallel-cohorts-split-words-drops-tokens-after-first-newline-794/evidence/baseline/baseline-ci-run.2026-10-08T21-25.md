# Baseline CI run on main (P0-T5)

Timestamp: 2026-10-09T06-51 (T0 = 2026-10-09T06:51:17Z)
Command: gh workflow run _shell-coverage.yml --ref main ; gh run list --workflow=_shell-coverage.yml --branch=main --limit=5 --json databaseId,headSha,url,createdAt,event ; gh run watch 37895732802 ; gh run view 37895732802 --json status,conclusion,headSha,url
EXIT_CODE: 0
Output Summary: run completed, conclusion success on main head e7d3779b398604af919678c16c877c8539a86cc0.

BASE_RUN_ID: 37895732802
URL: https://github.com/drmoisan/drm-copilot/actions/runs/37895732802
Head SHA: e7d3779b398604af919678c16c877c8539a86cc0
status: completed
conclusion: success
event: workflow_dispatch (createdAt 2026-10-09T06:51:21Z)
