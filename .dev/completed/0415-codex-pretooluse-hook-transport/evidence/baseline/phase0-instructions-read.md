# Phase 0 — Policy Instructions Read (Issue #415)

Timestamp: 2026-07-25T19-05

Policy Order: `CLAUDE.md` → `.claude/rules/general-code-change.md` → `.claude/rules/general-unit-test.md` → `.claude/rules/powershell.md` → `.claude/rules/python.md` → `.claude/rules/python-suppressions.md` → `.claude/rules/self-explanatory-code-commenting.md` → `.claude/rules/quality-tiers.md`

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/python.md`
6. `.claude/rules/python-suppressions.md`
7. `.claude/rules/self-explanatory-code-commenting.md`
8. `.claude/rules/quality-tiers.md`

Output Summary: All eight policy files read prior to any code or test change. Binding constraints extracted for this plan: PowerShell toolchain order is format (`run_poshqc_format`) → analyze (`run_poshqc_analyze`) → test (`run_poshqc_test`) with restart-from-format on any failure or file change and no type-check stage; Python toolchain order is black → ruff → pyright → pytest; PowerShell per-batch cap is 3 production plus 3 test files; 500-line cap applies to production, test, and reusable script files; line coverage must remain >= 85% and branch coverage >= 75% where the toolchain measures it; temporary files in tests are prohibited; tests must mirror production structure under `tests/`; no file under `.claude/` may be created, modified, or deleted by this work.
