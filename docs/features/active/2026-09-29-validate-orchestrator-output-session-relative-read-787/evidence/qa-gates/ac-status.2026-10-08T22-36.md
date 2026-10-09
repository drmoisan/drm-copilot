# Acceptance Criteria Status (P6-T21, P6-T22)

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/ac-checkbox-count.ps1 -Path docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/spec.md
EXIT_CODE: 0
Output Summary: AC-CHECKBOXES total=26 checked=25 unchecked=1

### Acceptance Criteria Status
- Source: docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/spec.md (work mode full-bug; `spec.md` is the only AC source)
- Total AC items: 26
- Checked off (delivered): 25
- Remaining (unchecked): 1
- Items remaining: AC-26 "The full PowerShell toolchain loop (format, analyze, test) and the full Python toolchain loop (black, ruff, pyright, pytest with coverage) complete without errors in a single pass. ..." P6-T21 requires P6-T17 to pass, and P6-T17 did not pass because P6-T5 (the PoshQC MCP test call) raised with exit code 2. The JUnit report shows that exit code equals the two KL-HERMETIC baseline failures. Every other loop step passed in the single pass, including the Python loop. The SET-FULL FAILED set equals the P0-T24 baseline set (KL-ADOPT and KL-HERMETIC only), and no FAILED line has a PLAN-TEST-FILES member as its file. The spec's AC-26 residual sentence exempts failures recorded in the Phase 0 SET-FULL baseline, but the plan's P6-T21 gate does not exempt the MCP-call task. A reviewer decision is therefore required. See `evidence/qa-gates/final-ps-mcp-test.2026-10-08T22-36.md` and `evidence/qa-gates/final-loop.2026-10-08T22-36.md`.

| AC | Spec line | Status | Check-off task | Evidence |
|---|---|---|---|---|
| AC-01 | 184 | checked | P6-T18 | P3-T11 (S1 R1-R12), P3-T14, P6-T2 |
| AC-02 | 185 | checked | P3-T19 | P3-T11 rows R1, R9, R12, R13 |
| AC-03 | 186 | checked | P3-T20 | P3-T11 rows R5, R6, R7, R8, R10 |
| AC-04 | 187 | checked | P3-T21 | P3-T11 rows R14, S2-1 to S2-6 |
| AC-05 | 188 | checked | P3-T22 | P3-T11 row S2-12 |
| AC-06 | 189 | checked | P3-T23 | P3-T11, P3-T15 |
| AC-07 | 190 | checked | P3-T24 | P3-T10, P3-T11 rows R1-R12 |
| AC-08 | 191 | checked | P3-T25 | P3-T4 to P3-T6, P3-T11 rows R1, R12 |
| AC-09 | 192 | checked | P2-T11 | P2-T1, P2-T5 |
| AC-10 | 193 | checked | P3-T26 | P3-T11 rows H1, H5, H6, H7 |
| AC-11 | 194 | checked | P3-T27 | P3-T11 (T-MAIN interpreter row), P3-T12 (SET-GUARD, no FAILED line), P3-T14 |
| AC-12 | 195 | checked | P3-T28 | P2-T5 (corpus parity), P3-T11 rows H1, H2 |
| AC-13 | 196 | checked | P3-T29 | P3-T11 rows H8, H9, H10 |
| AC-14 | 197 | checked | P1-T8 | P1-T1, P1-T3, P1-T4 |
| AC-15 | 198 | checked | P2-T12 | P2-T5 (rows P1, P2 of C5) |
| AC-16 | 199 | checked | P1-T9 | P1-T3, P1-T4, P1-T5 |
| AC-17 | 200 | checked | P2-T13 | P2-T3, P2-T5 (D1-D5 of C5, U6 of C4) |
| AC-18 | 201 | checked | P3-T30 | P3-T11 row H3 |
| AC-19 | 202 | checked | P5-T13 | P5-T1, P5-T5, P5-T6 |
| AC-20 | 203 | checked | P5-T14 | P5-T2, P5-T5, P5-T6 |
| AC-21 | 204 | checked | P5-T15 | P0-T13, P5-T3, P5-T4, P5-T5 |
| AC-22 | 205 | checked | P5-T16 | P5-T1 to P5-T3, P5-T6 |
| AC-23 | 206 | checked | P5-T17 | P4-T1, P4-T2, P4-T6, P4-T7, P5-T5, P5-T11, P5-T12 (KL-510: PASSED) |
| AC-24 | 207 | checked | P6-T19 | P6-T10 |
| AC-25 | 208 | checked | P6-T20 | P6-T7, P6-T8 |
| AC-26 | 209 | unchecked | P6-T21 (otherwise branch) | P6-T6, P6-T14 met; P6-T17 not met through P6-T5 |

Pre-existing residuals: KL-ADOPT (docs/features/potential/2026-10-01-issue-adoption-pester-folder-scoped-command-not-found.md): 38 lines in the P6-T6 SET-LIB run and 38 lines in the P6-T6 SET-FULL run. KL-HERMETIC (#737): 2 P6-T6 SET-FULL lines present in the P0-T24 baseline set (`enforce-pr-author-skill.Tests.ps1` "allows gh pr create --body-file artifacts/pr_body_12.md when context exists" and `codex-pretooluse-integration.Tests.ps1` "allows every registered handler for every tool name its own matcher admits"). Lines accepted through the P6-T6 re-run rule (remaining, not pre-existing): none. The same two KL-HERMETIC failures are the entire cause of the P6-T5 exit code.
