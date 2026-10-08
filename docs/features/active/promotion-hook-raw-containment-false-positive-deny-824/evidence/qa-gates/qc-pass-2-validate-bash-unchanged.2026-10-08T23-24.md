# QC Pass 2: validate-bash Rule and Suites Unchanged ([P10-T17])

Timestamp: 2026-10-08T23-24
Command: git diff --quiet 991aae0a180a09d504b59bc9460ec4b00b85d11b -- tests/scripts/claude-hooks/validate-bash.Tests.ps1 tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 .claude/hooks/validate-bash.ps1 .codex/hooks/validate-bash.ps1
EXIT_CODE: 0
Output Summary:
No difference from BASE_SHA in either `validate-bash.ps1` copy or in any of the four validate-bash suites. The `cd ... && <read>` rule (`CdChainedReadCommandPattern`, `Get-CdChainedReadCommandMatch`) and its suites are unmodified. Their pass state is read from [P10-T6] pass 2 (`qc-pass-2-pester-full-coverage.2026-10-08T23-19.md`): no validate-bash test is in the failing set.

Execution note: issued as `git -C <WORKSPACE_ROOT> diff --quiet ...`; arguments otherwise identical.
