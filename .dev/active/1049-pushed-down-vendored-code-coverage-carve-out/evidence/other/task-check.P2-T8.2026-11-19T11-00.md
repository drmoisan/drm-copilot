# Task Check [P2-T8]

Timestamp: 2026-11-19T11-00
Command: grep of the README for tested upstream, owned and tested, recreated duplicate tests and exempt_unchanged_push_down_files (2 matching lines, all four literals present); grep -rl PoshQC/README.md over tests/
EXIT_CODE: 0
Output Summary: Changed files: scripts/powershell/PoshQC/README.md. Selection rule: a changed Markdown path selects the contract tests that read it: tests/scripts/dev_tools/test_poshqc_bundled_parity.py compares it with the bundle copy that [P2-T9] writes, so it runs in the [P2-T10] task check; the README literals are asserted by README states the ownership policy in [P3-T5]. No formatter, linter or type checker applies to Markdown.
