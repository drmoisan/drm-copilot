# R1 Failing-Test Set Subset Verification (cycle 1)

- Timestamp: 2026-09-17T14:02:53Z
- Command: `Get-Content -LiteralPath 'evidence/qa-gates/repo-wide-powershell-coverage.2026-09-17T09-10.md'`
- EXIT_CODE: 0

## Output Summary

Failing tests recorded by `[P1-T3]`:

1. `enforce-pr-author-skill.Tests.ps1 | enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `codex-pretooluse-integration.Tests.ps1 | Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

Baseline failure names (`enforce-pr-author-skill.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`)
from `remediation-inputs.2026-09-17T08-59.md`.

Result: **PASS**. Every failing test recorded by `[P1-T3]` matches one of the two baseline names, and no
failing test outside that set is present.
