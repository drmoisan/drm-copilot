# P0-T7 Remediation Per-Module Numeric Baseline

Timestamp: 2026-10-10T09-04
Command: poetry run python -c "<JSON summary reader over artifacts/python/coverage-790-remediation-baseline.json; prints LINE and BRANCH per AC-22 module>"
EXIT_CODE: 0
Output Summary:
```
scripts/dev_tools/push_down_claude_filesystem.py LINE 88.5 BRANCH 64.29
scripts/dev_tools/push_down_claude_gitignore_merge.py LINE 100.0 BRANCH 100.0
scripts/dev_tools/push_down_claude_customizations.py LINE 93.67 BRANCH 87.5
scripts/dev_tools/push_down_claude_pack_selection.py LINE 93.98 BRANCH 83.33
```
The filesystem line equals the expected `LINE 88.5 BRANCH 64.29`; the finding reproduces.
