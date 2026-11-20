# Phase 0 — Policy Instructions Read Evidence

Timestamp: 2026-06-16T20-30

Policy Order: per `.claude/skills/policy-compliance-order` and the plan's Required References, the following policy files were read in the required order before any code or test change.

Files read:
1. `.github/copilot-instructions.md` — repository tone and communication policy
2. `CLAUDE.md` — standing instructions (auto-loaded)
3. `.claude/rules/general-code-change.md` — baseline code change rules (file size limit, toolchain loop, fail-fast)
4. `.claude/rules/general-unit-test.md` — baseline unit test rules (coverage thresholds, no temp files, no external deps)
5. `.claude/rules/powershell.md` — PowerShell toolchain, wrapper-function seams, mocking rules, 500-line limit, dot-source guard pattern
6. `.claude/rules/ci-workflows.md` — pwsh exit-code handling for deliberately-failing nested commands
7. `.github/instructions/github-actions.instructions.md` — GitHub Actions schema/actionlint requirements
8. `.claude/rules/quality-tiers.md` — module rigor tiers and uniform coverage thresholds (line >= 85%, branch >= 75%)
9. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — canonical evidence locations and timestamped-artifact schema

Output Summary: All required policy files read. Key constraints noted: wrapper-function seams for all external calls (git/npm/publish script), parameter names must not be `Args`, mocks must match production named parameters, no temp files / no real git/npm/network in tests, dot-source guard `if ($MyInvocation.InvocationName -ne '.')`, file under 500 lines, coverage line >= 85% / branch >= 75%, all evidence under canonical `<FEATURE>/evidence/<kind>/`.
