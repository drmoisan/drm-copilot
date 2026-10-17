# CI security-scan result (P7-T3, AC-36, PD-18)

Timestamp: 2026-10-17T01-18
Command: gh run view 38988542731 --repo drmoisan/drm-copilot --json jobs; gh run view --repo drmoisan/drm-copilot --job 117265576360 --log
EXIT_CODE: 0
Output Summary: security-scan / Security Scanning concluded failure on head 0f0d95c2d; the export plugin installed and the export succeeded; safety scanned the exported requirements and reported 101 vulnerabilities in 14 packages.

Run: 38988542731 (event workflow_dispatch, head 0f0d95c2d99f74f4d98994315dd7f4a7f73a512a). The run was dispatched before the PR existed so that feature review could observe a full run; the decision rule of PD-18 depends only on the safety result, which is a property of poetry.lock and not of the event.
Job: 117265576360 security-scan / Security Scanning, conclusion failure.

Quoted log lines (ANSI codes removed):

    ##[group]Run poetry self add poetry-plugin-export
    poetry self add poetry-plugin-export
    Using version ^1.10.1 for poetry-plugin-export
      - Installing poetry-plugin-export (1.10.1)
    poetry export -f requirements.txt --without-hashes | poetry run safety check --stdin
      Safety v3.8.1 is scanning for Vulnerabilities...
      Using open-source vulnerability database
      101 vulnerabilities reported
      0 vulnerabilities ignored
    ##[error]Process completed with exit code 64.

SAFETY-RESULT: findings
REMEDIATION-CYCLE: opened
