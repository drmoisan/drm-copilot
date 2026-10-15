# P4-T8 Manual Negative Check: Remove One Entry (expect-fail)

Timestamp: 2026-10-02T03-18
Command: poetry run python -m scripts.dev_tools.check_quality_tiers
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: stdout empty. stderr is one line: `QT008: discovered project 'scripts/bash' has no entry`.

Working-copy edit (not staged, not committed): lines 22-24 of quality-tiers.yml deleted. The deleted lines were:

```
  - path: "scripts/bash"
    tier: T4
    rationale: "Shell QC and coverage scripts"
```

After the deletion the file contained no `scripts/bash` text (match count 0). P4-T9 restores the committed content.
