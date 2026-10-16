# Coverage root check (P0-T3)

Timestamp: 2026-10-16T00-17

Command: grep -n -F -e '"scripts"' config/poshqc-coverage.json

EXIT_CODE: 0

Output Summary: grep printed exactly one line, `8:    "scripts"`. The `"scripts"` roots entry is declared at line 8, so `scripts/dev-tools/HostBootstrap.psm1` lies under a declared coverage root.
