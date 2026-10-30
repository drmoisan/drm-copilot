# P3-T8 repaired candidate freeze

Timestamp: 2026-10-19T01-26
Command: Scoped Black --check, Ruff, Pyright, Pytest with branch coverage; AST coverage audit
EXIT_CODE: 0
Output Summary: 127 focused cases pass; all 409 statements and 176 branches are covered. All measured class/callable ranges meet the 90% gate. Exact hashes, source sizes and raw evidence are bound in the paired JSON.

The shared configured-root/exclusion check now governs snapshot header and integrity-member reads before payload capture. The two new negative cases prove excluded bytes and requested payload bytes remain unread on these failures; the exact selected member still does not grant sibling output access.

The approved test_source_read_snapshot_scope.py contains the relocated snapshot cases and the two regressions. All original 125 cases and assertions are retained. The two nested fake-reader docstrings and ReadSelection label are corrected. Earlier failed diagnostics and review probes remain preserved.

This is checked work in progress. Bounded executor confirmation, parent commit/push, and the clean final seven-stage gate remain pending. No source writers or test processes remain active.
