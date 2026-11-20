# Decision-Case Map — pr-author validator ([P1-T2])

Timestamp: 2026-11-18T08-46
Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/codex-hooks/codex-validate-pr-author-output.Tests.ps1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
EXIT_CODE: 0
Output Summary: one row per Claude `It` of the two Claude suites, each naming its Codex `It`; no unmapped row. The Codex suite adds the twin-rule row, the `Get-CodexPrAuthorStopDecision` rows (dependency-first, validator-error, one continuation) and the child-process rows.

## Claude `validate-pr-author-output.Tests.ps1`

| Claude `It` | Codex `It` (`codex-validate-pr-author-output.Tests.ps1`) |
| --- | --- |
| `allows when output contains a GitHub PR URL` | `allows when the Codex message contains <Name>` (row `a GitHub PR URL`) |
| `allows when output contains a PR #<n> reference` | `allows when the Codex message contains <Name>` (row `a PR #<n> reference`) |
| `allows when output contains a gh pr create confirmation with a PR number` | `allows when the Codex message contains <Name>` (row `a gh pr create confirmation with a PR number`) |
| `allows when output contains a gh pr edit confirmation with a PR number` | `allows when the Codex message contains <Name>` (row `a gh pr edit confirmation with a PR number`) |
| `blocks with PR_AUTHOR_OUTPUT_EMPTY when the assistant message is blank` | `blocks with <Expected> when <Name>` (row `the assistant message is blank`) |
| `blocks when output has no PR URL or number` | `blocks with <Expected> when <Name>` (row `the message has no PR URL or number`) |
| `blocks with a payload anomaly when the input text is empty` | `blocks with <Expected> when <Name>` (row `the payload is empty`) |
| `blocks with a payload anomaly when the input text is malformed JSON` | `blocks with <Expected> when <Name>` (row `the payload is malformed JSON`) |
| `blocks when the output mentions gh pr create but has no PR number` | `blocks with <Expected> when <Name>` (row `the message mentions gh pr create without a PR number`) |
| `returns false for null/empty/whitespace output` | `returns false for null, empty and whitespace output` |
| `returns true for a PR URL` | `returns true for a PR URL` |
| `returns false for prose with no PR reference` | `returns false for prose with no PR reference` |
| `exits 2 in a separate process when the stdin envelope lacks a PR reference` | `exits 2 with PR_AUTHOR_OUTPUT_NO_PR when stop_hook_active is false` (child process) |

## Claude `validate-pr-author-output.Coverage.Tests.ps1`

| Claude `It` | Codex `It` (`codex-validate-pr-author-output.Tests.ps1`) |
| --- | --- |
| `exits 2 with PR_AUTHOR_OUTPUT_NO_PR on stderr when last_assistant_message lacks a PR reference` | `exits <ExitCode> for <Name>` (row `a message without a PR reference`) |
| `exits 0 when last_assistant_message reports a pull request URL` | `exits <ExitCode> for <Name>` (row `a message with a pull request URL`) |
| `blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT` | `blocks when the PR reference is supplied only in an output field`. The `CLAUDE_HOOK_INPUT` half is CLAUDE-ONLY: Codex hooks read no `$env:CLAUDE_` variable (`legacy-codex-hook-contracts.Tests.ps1`), so there is no Codex environment input to test. |
| `exits 2 with PR_AUTHOR_OUTPUT_EMPTY when last_assistant_message is an empty string` | `exits <ExitCode> for <Name>` (row `an empty message`) |
| `exits 2 with a payload anomaly reason for empty stdin` | `exits 2 with a payload anomaly reason for <Name>` (row `empty stdin`) |
| `exits 2 with a payload anomaly reason for malformed stdin` | `exits 2 with a payload anomaly reason for <Name>` (row `malformed stdin`) |
| `exits 2 with a payload anomaly reason when last_assistant_message is absent` | `exits 2 with a payload anomaly reason for <Name>` (row `a payload without last_assistant_message`) |
| `keeps validating when stop_hook_active is true` | `exits <ExitCode> for <Name>` (row `a re-entered stop without a PR reference`) and `allows the one continuation when stop_hook_active is true`. The expected exit differs by design: the Codex hook allows one continuation (spec `## Behavior`), and the matrix records the divergence as `one-continuation`. |

Unmapped rows: none.
