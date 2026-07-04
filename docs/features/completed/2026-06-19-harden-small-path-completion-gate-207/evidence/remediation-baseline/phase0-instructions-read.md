# Phase 0 — Policy Read Evidence (Issue #207, Remediation Pass 1)

Timestamp: 2026-06-19T19-15

Policy Order:
1. CLAUDE.md (standing instructions, tone, policy-compliance order, architecture)
2. .claude/rules/general-code-change.md (cross-language code change policy, 500-line file limit, toolchain loop)
3. .claude/rules/general-unit-test.md (cross-language unit test policy, coverage thresholds)
4. .claude/rules/powershell.md (PowerShell toolchain and coding standards — bundled hook is a .ps1 file)
5. .claude/rules/python.md and .claude/rules/python-suppressions.md (verification commands use the Python toolchain: black, ruff, pyright, pytest)

Files Read (in order):
- c:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-17-19-54\CLAUDE.md
- c:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-17-19-54\.claude\rules\general-code-change.md
- c:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-17-19-54\.claude\rules\general-unit-test.md
- c:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-17-19-54\.claude\rules\powershell.md
- c:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-17-19-54\.claude\rules\python.md
- c:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-17-19-54\.claude\rules\python-suppressions.md

Change Classification Note:
This remediation is a cross-cutting bundle-mirror sync, NOT new logic. The repository
enforces a byte-identical mirror contract: every non-memory `.claude/**` file must exist,
byte-identical, in the bundled extension payload at
`extensions/drm-copilot/resources/claude-customizations/.claude/`. No `.ps1` logic,
`.py` logic, or test logic is modified. The two source files
(`.claude/hooks/enforce-completion-consistency.ps1` and `.claude/settings.json`) already
comply with policy and the 500-line limit; this remediation copies their current content
into the bundled payload so the bundle matches the repo.
