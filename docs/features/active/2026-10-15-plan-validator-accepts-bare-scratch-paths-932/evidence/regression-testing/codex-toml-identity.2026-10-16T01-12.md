# Codex TOML Root-to-Bundle Identity — Issue #932

Timestamp: 2026-10-16T01-12
Task: [P4-T5]
Command: git hash-object .codex/agents/<file> extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/<file> (once per pair, twelve pairs)
EXIT_CODE: 0

Output Summary: all twelve pairs print equal object IDs.

| File | Root object ID | Bundle object ID | Equal |
| --- | --- | --- | --- |
| atomic-planner.toml | 067caed7e28b40149e79568d97597a996ab5d696 | 067caed7e28b40149e79568d97597a996ab5d696 | yes |
| atomic-planner-c1.toml | d518ab48d0195319c4b621e761cfc8cbbc5900a3 | d518ab48d0195319c4b621e761cfc8cbbc5900a3 | yes |
| atomic-planner-c2.toml | fddd1d80672b510b437be60e7b0d32d389b41897 | fddd1d80672b510b437be60e7b0d32d389b41897 | yes |
| atomic-planner-c3.toml | 68b0b0cb433a64138e3eb82ce7e96553aa200c87 | 68b0b0cb433a64138e3eb82ce7e96553aa200c87 | yes |
| atomic-planner-c3-elevated.toml | 0ea86cbc0226a393804a969e97316da94b4c0e75 | 0ea86cbc0226a393804a969e97316da94b4c0e75 | yes |
| atomic-planner-c4.toml | 466b7f6e70d5fa028418b8fee1f2762e2f10d109 | 466b7f6e70d5fa028418b8fee1f2762e2f10d109 | yes |
| atomic-executor.toml | 8f11bb00d6df806bf333f05ec693472160439d06 | 8f11bb00d6df806bf333f05ec693472160439d06 | yes |
| atomic-executor-c1.toml | 85bea3afed47ac791206daadc95f4a6f2547e547 | 85bea3afed47ac791206daadc95f4a6f2547e547 | yes |
| atomic-executor-c2.toml | a70a2695bf4e67047056498b49bbd37f5aa92ffd | a70a2695bf4e67047056498b49bbd37f5aa92ffd | yes |
| atomic-executor-c3.toml | c3dc5e2c55a90b57f28546e7e09dae3f15ed2504 | c3dc5e2c55a90b57f28546e7e09dae3f15ed2504 | yes |
| atomic-executor-c3-elevated.toml | 2f36f0c4a0e5fd5fc4cd63e4c5570e71b7d7c37a | 2f36f0c4a0e5fd5fc4cd63e4c5570e71b7d7c37a | yes |
| atomic-executor-c4.toml | a73d3c83f21cc466b98f1d217c8236b10c4b514e | a73d3c83f21cc466b98f1d217c8236b10c4b514e | yes |

Line-ending note: the Edit-tool insertions in [P4-T1]–[P4-T4] left the 24 files with CRLF terminators in the working tree (they were LF before the edit). Before this check, the CR characters were removed from those 24 files (`sed -i 's/\r$//'`), restoring LF throughout; a follow-up count of CR characters returned 0 for every file, and `git diff --stat` for the two directories reports `24 files changed, 252 insertions(+)` with no deletions (12 x 10 planner lines plus 12 x 11 executor lines).
