# Final QA Gate: Test Purity (issue #491, [P7-T13])

Timestamp: 2026-08-20T11-45

"The purity hook did not fire" is not directly observable after the fact, so this check does not
assert it. Instead the hook's own decision function was replayed over each new and modified test
file, which is the same code path a `Write` of that file would take.

Command: `pwsh -NoProfile -File <scratchpad>/purity.ps1`, which dot-sources
`.claude/hooks/check-powershell-test-purity.ps1` and calls
`Invoke-PowerShellTestPurityDecision -ToolInputRaw <payload>` once per file, with the payload
carrying the file's actual on-disk content.
EXIT_CODE: 0
Output Summary: `PURITY_VIOLATIONS: 0`. Every one of the seven files returned `$null`, which is the
hook's allow outcome.

| File | Purity decision |
| --- | --- |
| `tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1` | PURE (no decision returned) |
| `tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1` | PURE |
| `tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1` | PURE |
| `tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1` | PURE |
| `tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1` | PURE |
| `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1` | PURE |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` | PURE |

## Manual confirmation of each purity requirement

| Requirement | Status | Evidence |
| --- | --- | --- |
| Diagram fixtures are here-strings | Satisfied | Every diagram in the five library suites and the hook suite is a `@'...'@` literal here-string. No `.mmd` or `.mermaid` file exists anywhere in the repository, so no fixture is a committed diagram file and the hook never gates its own fixtures |
| On-disk reads go through mocked wrapper seams | Satisfied | The managed-diagram cases `Mock -CommandName Get-MermaidOnDiskContent`, the hook's named reader wrapper. No test reads a diagram from disk |
| No temporary files | Satisfied | No `New-TemporaryFile`, no `GetTempFileName`, no `GetTempPath`, no `$env:TEMP`, no `$env:TMP`. The purity hook checks all five patterns and reported nothing |
| No `Start-Process` | Satisfied | The hook suite's entry-point context spawns pwsh with the call operator against the current process's own executable path, following the precedent at `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:54-100`. `Start-Process` appears nowhere |
| No sleeps or timing hacks | Satisfied | No `Start-Sleep`, no wall-clock waits, no retries |
| No network access | Satisfied | No `Invoke-WebRequest`, `Invoke-RestMethod`, or `System.Net.*` usage |
| No direct mocking of git, gh, or actionlint | Satisfied | None of the three appears in any of the seven files |
| No mutable global state between tests | Satisfied | The one script-scope variable a test mutates (`$script:MermaidModulePath`, for the missing-module guard) is saved in `BeforeEach` and restored in `AfterEach`, so the suite is order-independent |

Two file reads occur in the suites and neither is a purity violation: `MermaidGrammar.Tests.ps1`
reads the module under test's own source to assert the pinned-version header, and each suite resolves
the module path with `Resolve-Path`. Both target production source files that are guaranteed present
in a checkout; neither reads mutable state.

AC-25 satisfied.
