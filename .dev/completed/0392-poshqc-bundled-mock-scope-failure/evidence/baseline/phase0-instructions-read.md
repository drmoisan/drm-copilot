# Phase 0 Instructions Read (Issue #392)

Timestamp: 2026-07-21T18-01

Policy Order: policy-compliance-order sequence for PowerShell-in-scope work.

Files read (in order):
1. `CLAUDE.md` — standing repository tone, policy-compliance order, architecture.
2. `.claude/rules/general-code-change.md` — cross-language code change policy (design principles, toolchain loop, file size limit, error handling).
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy (five properties, coverage requirements, AAA structure, determinism).
4. `.claude/rules/powershell.md` — PowerShell toolchain (format -> analyze -> test via MCP), change budget (per-batch cap 3 production/3 test), design seams, mocking rules, coverage floors.
5. `.claude/rules/quality-tiers.md` — T1-T4 tier system; uniform coverage floors (>= 85% line, >= 75% branch).
6. `.claude/rules/tonality.md` — professional tone requirements.

Additional in-scope policies consulted: `.claude/rules/self-explanatory-code-commenting.md` (comment/docstring policy), `.claude/rules/python.md` (targeted Python parity gate context only; no `.py` production change in scope).

Acceptance: artifact contains Timestamp, Policy Order, and the explicit list of files read.
