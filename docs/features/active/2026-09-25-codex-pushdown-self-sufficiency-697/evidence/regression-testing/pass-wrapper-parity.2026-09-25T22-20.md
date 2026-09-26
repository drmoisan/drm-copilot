# Pass: Wrapper Parity over the Corpus (Issue #697, AC-4.7, AC-4.8, AC-4.9)

Timestamp: 2026-09-25T22-20
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 53, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0` -- 14 topology and 9 deployment cases through `pwsh -NoProfile -File` (process level), the same 23 in process, 6 entry-block cases in process, and `resolves modules through the .claude/lib fallback inside drm-copilot`.
- Argument delivery: every process-level case passed, including the empty-string token (`topo-empty-language`) and the non-ASCII token (`topo-non-ascii-language`), so the section 2 item 9 contingency did not trigger and no `wrapper-argument-delivery` artifact was required.
- Remediation before this run: the first run reported `Failed: 3`, all for `topo-empty-language`, because `[string[]]` mandatory parameters rejected the empty-string token (`ConvertFrom-CodexRoutingArgument -Arguments` in `.codex/scripts/codex-routing-cli-common.ps1`, and the test helpers' `-Argv`). `[AllowEmptyString()]` was added to each; the helper mirror was re-copied (hash `B9E2952A70F9E7B18DC424BB41CC84B16A0677E4732CE55110B12928842FD04D` for both copies). `codex-routing-cli-common.Tests.ps1` was re-run afterwards: `Tests Passed: 31, Failed: 0`.
