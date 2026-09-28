# Repo-Wide PowerShell JUnit Run Counts, Failing-Test Set, and LINE Coverage (R1, cycle 1)

- Timestamp: 2026-09-17T14:02:03Z
- Command: read of `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/repo-wide-pester-junit.r1.2026-09-17T09-10.xml` and `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/repo-wide-powershell-coverage.r1.2026-09-17T09-10.xml` as XML
- EXIT_CODE: 0

## Output Summary — [P1-T3] JUnit run counts and failing-test set

Root `testsuites` element attributes:

- `tests="4653"`
- `failures="2"`
- `errors="0"`
- `disabled="9"`

Failing tests (`testcase` elements with `status="Failed"`), one line per test in the form
`<classname> | <name>`:

1. `...\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1 | enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `...\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 | Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

Baseline-name match check (last path segment of `classname`):

1. `enforce-pr-author-skill.Tests.ps1` — matches the baseline name `enforce-pr-author-skill.Tests.ps1`.
2. `codex-pretooluse-integration.Tests.ps1` — matches the baseline name `codex-pretooluse-integration.Tests.ps1`.

No failing test outside the two-name baseline set is present.

## Output Summary — [P1-T4] Report-level and per-file LINE coverage

Report-level `counter[@type='LINE']` (the `<counter type="LINE" .../>` element that is a direct child of
`<report>`, immediately before `</report>`):

- `covered="9155"`
- `missed="424"`
- Percentage: `100 * 9155 / (9155 + 424)` = `100 * 9155 / 9579` = `95.57%` (rounded to two decimals)

`package` element whose `name` ends with `worktree-resolution`
(`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c/.claude/lib/worktree-resolution`),
per-file `sourcefile[@name]` LINE rows:

### `WorktreeResolution.psm1`

- `covered="140"`
- `missed="2"`
- Percentage: `100 * 140 / (140 + 2)` = `100 * 140 / 142` = `98.59%` (rounded to two decimals)

### `WorktreeTargetResolution.psm1`

- `covered="101"`
- `missed="0"`
- Percentage: `100 * 101 / (101 + 0)` = `100 * 101 / 101` = `100.00%`
