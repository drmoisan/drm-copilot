# CI PR-Head Run Metadata (P7-T1)

Timestamp: 2026-10-16T10-54
Command: gh pr view 959 --json number,headRefOid ; gh run list --workflow ci.yml --branch bug/pester-profiler-coverage-953 --json databaseId,headSha,event,status,conclusion --limit 20 ; gh run view 38887178530 --json status,conclusion,jobs
EXIT_CODE: 0
Output Summary: PR #959 head 2004de667b7e6c6930fcc065c0431b8457a60b7f; the ci.yml pull_request run for that head is 38887178530 (completed, conclusion success). Job "poshqc / PowerShell QC" conclusion success; job "poshqc / PowerShell hook suites (Linux)" conclusion success.

PR_NUMBER: 959
PRHEAD_RUN_ID: 38887178530
PRHEAD_SHA: 2004de667b7e6c6930fcc065c0431b8457a60b7f
JOB_CONCLUSION poshqc / PowerShell QC: success
JOB_CONCLUSION poshqc / PowerShell hook suites (Linux): success
