# Phase 1 — Duplicate-Key Check ([tool.poetry.scripts]) (Issue #369, Remediation Cycle 1)

Timestamp: 2026-07-18T22-27

Command: awk (extract every assignment key between the `[tool.poetry.scripts]` heading and the next `[tool.` heading) | sort | uniq -d

EXIT_CODE: 0

Output Summary:
- Total assignment keys in the resolved `[tool.poetry.scripts]` block: 38.
- Duplicate keys (sort | uniq -d output): none (empty). Every key in the block appears exactly once.
- The three retained console-script entries each appear exactly once: `"dev.discovery.dotnet"`, `"dev.discovery.parity-report"`, `"dev.discovery.vsto"`.
- Result: zero duplicate keys anywhere in the `[tool.poetry.scripts]` block.
