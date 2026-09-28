# Phase 0 — Policy Instructions Read (issue #516)

Timestamp: 2026-08-24T15-10
Command: Read (file inspection; no shell command)
EXIT_CODE: 0

Policy Order: The reading order defined by `.claude/skills/policy-compliance-order/SKILL.md` — standing instructions first (`CLAUDE.md`), then the cross-language code-change policy, then the cross-language unit-test policy, then the language-specific rules for the files in scope (PowerShell), then the tier/coverage rule that the QA gates read.

## Files Read (five, in order)

1. `CLAUDE.md` — [P0-T1]
2. `.claude/rules/general-code-change.md` — [P0-T2]
3. `.claude/rules/general-unit-test.md` — [P0-T3]
4. `.claude/rules/powershell.md` — [P0-T4]
5. `.claude/rules/quality-tiers.md` — [P0-T5]

## Recorded Points

- `CLAUDE.md` [P0-T1]: strictly professional, factual, neutral tone; no humor, hyperbole, or emojis. Policy-compliance reading order is declared there and mirrored by `.claude/rules/`. Policy documents under `.github/instructions/` must not be modified.
- `.claude/rules/general-code-change.md` [P0-T2]: no production, test, or reusable script file may exceed **500 lines**. The mandatory toolchain loop is seven stages in this exact order — formatting, linting, type checking (skipped for PowerShell), architecture-boundary tests, unit tests, contract/schema checks, integration tests — and **restarts from step 1** whenever any stage fails or auto-fixes a file.
- `.claude/rules/general-unit-test.md` [P0-T3]: Coverage Exclusion Policy — **no production file may be excluded from coverage measurement**; every production source file stays in the denominator, and the PowerShell branch-coverage exemption is a threshold exemption only, never a licence to exclude a file. Test File Location — test files must live in a `tests/` tree mirroring the production source structure; colocation in the production tree is prohibited. Creation and use of temporary files in tests is strictly prohibited.
- `.claude/rules/powershell.md` [P0-T4]: toolchain order is **format → analyze → test**, run through the MCP server functions, restarting from step 1 if any step fails or changes files; type checking is not applicable to PowerShell. Per-batch change budget in all modes is **at most 3 production files and 3 test files**; a batch that would exceed the cap must be split. Deterministic test requirements: tests must not depend on network access, mutable machine PATH or profile state, **implicit working-directory assumptions**, or external services/live executables, and must produce identical results in Terminal and Test Explorer.
- `.claude/rules/quality-tiers.md` [P0-T5]: uniform across all tiers T1–T4, **line coverage >= 85%** and no regression on changed lines. **PowerShell (Pester) is exempt from the >= 75% branch-coverage threshold** because Pester does not measure branch coverage; the exemption removes an unevaluable threshold and does not remove any PowerShell production file from the coverage denominator.

## Additional Constraint Confirmed

`config/orchestration-routing.json` narrows the PowerShell per-batch production cap below the rule-file value; the plan's Standing Constraints section fixes the operative budget for this item at **2 production files and 3 test files per batch**, which is the value this execution obeys.

Output Summary: All five policy files required by [P0-T1] through [P0-T5] were read in full, in the order prescribed by `policy-compliance-order`. The 500-line file cap, the seven-stage restart-on-change toolchain loop, the coverage-exclusion prohibition, the `tests/` mirror-tree location rule, the PowerShell format-analyze-test order, the per-batch production/test file budget, the deterministic-test prohibitions, the uniform 85% line-coverage threshold, and the PowerShell branch-coverage exemption are all recorded above. No policy file was modified.
