# [P0-T2] Existing tests of the changed behavior

Timestamp: 2026-11-07T01-21
Command: `git grep -n -e New-DocsCommandContext -e Invoke-DocsProcess -e InvokeProcess -e Invoke-DocsContextProcess -e WorkingDirectory -- tests extensions/drm-copilot/test`, and `git grep -l Invoke-DocsCommand.ps1 -- tests extensions/drm-copilot/test`
EXIT_CODE: 0
Output Summary: every docs match has a disposition from `### Existing tests of the changed behavior`. One test asserts the changed behavior (the member parameter pin), and it is the planned [P1-T2] update. No match is an unplanned existing-test change. `Invoke-DocsContextProcess` has no match before the fix.

## Matches by file

| File | Terms matched (count of lines) | Disposition |
|---|---|---|
| `extensions/drm-copilot/test/repo-automation-execute-docs.test.ts` | 1 | Unchanged: names the script path as an argument and does not read the script |
| `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1` | 5 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsAnalyzerPythonNative.Tests.ps1` | 5 | Unchanged: test-local InvokeProcess scriptblocks, no real context |
| `tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1` | 1 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsInventory.PythonNative.Tests.ps1` | 6 | Unchanged: test-local InvokeProcess scriptblocks, no real context |
| `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1` | 3 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsInventoryProperties.Tests.ps1` | 1 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1` | 5 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsLedger.TestSupport.Tests.ps1` | 2 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` | 3 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.UpdateLedger.Tests.ps1` | 1 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Validate.Tests.ps1` | 1 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1` | 2 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsReference.TestSupport.psm1` | 4 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsReferenceBoundary.Tests.ps1` | 8 | Unchanged: scans the DocsReference modules and in-memory text |
| `tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1` | 3 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsReferenceWriter.Errors.Tests.ps1` | 5 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsReferenceWriter.Tests.ps1` | 4 | Unchanged: fake context or dispatch text only; the dispatch table does not move, and no real InvokeProcess member is built or asserted |
| `tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` | 5 | Unchanged: the new function holds no write primitive |
| `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` | 19 | Pin test updated in [P1-T2]; the forward test, the fake-call test and the anchor cases are unchanged |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 5 | Unchanged: `Operation` is a `[scriptblock]` parameter and the call target `$root` is no interpreter constant, so no finding and no allowlist change arise |
| `tests/scripts/dev-tools/run-actionlint.Tests.ps1` | 3 | Unrelated: its own InvokeProcess seam of `run-actionlint`, not the docs command context |

## WorkingDirectory matches

`git grep -l WorkingDirectory` over `TESTS` and `extensions/drm-copilot/test/repo-automation-execute-docs.test.ts` returns no file. Matches outside `TESTS` are unrelated, because none is a docs test:

- `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1`
- `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`
- `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1`
- `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`
- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`
- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`
- `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1`
- `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`
- `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1`
- `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1`
- `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1`
- `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1`
