# Regression: quality-tiers CLI on the committed tree ([P3-T6])

Timestamp: 2026-10-09T21-15
Command: poetry run python -m scripts.dev_tools.check_quality_tiers
EXIT_CODE: 0
Output Summary: exactly one stdout line, no stderr output:

```
quality-tiers: OK (24 entries, 24 discovered projects)
```

Acceptance (AC-7): exit 0; stdout is exactly one line beginning `quality-tiers: OK (`. PASS.
