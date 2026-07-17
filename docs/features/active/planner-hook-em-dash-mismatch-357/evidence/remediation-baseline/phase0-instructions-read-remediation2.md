# Phase 0 Instructions Read — Remediation Cycle 2

**Timestamp:** 2026-07-17T16-05
**Policy Order:**
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`

**Files read (explicit list):**
- `CLAUDE.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/powershell.md`

All four files were read in full in the stated order prior to any code or test change in this remediation cycle. Key policy points reconfirmed relevant to this cycle: PowerShell toolchain order is format -> analyze -> test (`.claude/rules/powershell.md`); line coverage must remain >= 85% and branch coverage >= 75% uniformly across tiers (`.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`); no production source path may be excluded from coverage measurement (`.claude/rules/general-unit-test.md` Coverage Exclusion Policy); creation of temporary files in tests is strictly prohibited (`.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`).
