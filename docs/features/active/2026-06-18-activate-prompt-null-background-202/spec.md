# activate-prompt-null-background (Spec)

- **Issue:** #202
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-18T09-25
- **Status:** Approved
- **Version:** 1.0

## Context
The `global:prompt` installed by `scripts/dev-tools/activate.ps1` throws in any host that does not expose a console background color. `Get-VenvAwarePrompt` declares `-BackgroundColor` as a mandatory, non-nullable `[System.ConsoleColor]`; the shim passes `$Host.UI.RawUI.BackgroundColor`, which is `$null` in non-interactive/redirected hosts such as the VS Code `pspester.pester-test` Test Explorer adapter. Binding `$null` to a non-nullable `[ConsoleColor]` fails at parameter-bind time.

Environment:
- OS/version: Windows, VS Code with `pspester.pester-test` 2023.7.8.
- PowerShell version: PowerShell 7, Pester 5.6.1.
- Command/flags used: Test Explorer "Run Tests" (adapter invokes `PesterInterface.ps1`).
- Data source or fixture: `tests/scripts/dev-tools/activate.Tests.ps1`.

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence
Steps to Reproduce:
1. Run `tests/scripts/dev-tools/activate.Tests.ps1` in a host whose `$Host.UI.RawUI.BackgroundColor` is `$null` (the VS Code Test Explorer adapter host).
2. The test "installs a prompt that delegates to the venv-aware builder" invokes the real `prompt`, which calls `Get-VenvAwarePrompt -BackgroundColor $null`.
3. Binding fails with a `ConsoleColor` cast error.

Expected:
A null/unknown console background renders the prompt uncolored without throwing.

Actual:
`ParameterBindingArgumentTransformationException: Cannot process argument transformation on parameter 'BackgroundColor'. Cannot convert null to type "System.ConsoleColor"` at `scripts/dev-tools/activate.ps1:403`.

Logs / Screenshots:
- [x] Captured the adapter failure and reproduced it deterministically via AST-imported `Get-VenvAwarePrompt -BackgroundColor $null`.

## Scope & Non-Goals
- In scope: make `Get-VenvAwarePrompt -BackgroundColor` null-tolerant; add a deterministic null-background regression test.
- Out of scope: changing the prompt's visual design; refactoring unrelated functions; the third-party adapter.
- Explicitly excluded: any behavior change when a valid background color is supplied.

## Root Cause Analysis
`Get-VenvAwarePrompt`'s `-BackgroundColor` was `[Parameter(Mandatory)] [System.ConsoleColor]`. The host shim supplies `$Host.UI.RawUI.BackgroundColor`, which some hosts report as `$null`. A non-nullable value-type parameter cannot bind `$null`, so the call throws before any logic runs. The failing test masked the defect on CI/terminal because it reads the ambient host background, which is a valid color there (a determinism violation per `.claude/rules/powershell.md`).

## Proposed Fix

### Design summary (what changes where):
1. `scripts/dev-tools/activate.ps1` — `Get-VenvAwarePrompt`: change `-BackgroundColor` to optional, `[AllowNull()]`, `[System.Nullable[System.ConsoleColor]]`. When the value is `$null`, treat the background as not-dark (render uncolored); otherwise call `Test-IsDarkBackground` unchanged.
2. `tests/scripts/dev-tools/activate.Tests.ps1` — add a deterministic test asserting `Get-VenvAwarePrompt -BackgroundColor $null` returns the uncolored prompt. The null value is supplied explicitly (no ambient host dependence).

### Boundaries and invariants to preserve:
- A valid background color yields identical output to before (dark -> green, light -> plain).
- `Test-IsDarkBackground` and `Get-ColorizedPrompt` are unchanged.
- No entrypoint/side-effect behavior changes.

### Files/modules to change:
- `scripts/dev-tools/activate.ps1` (production, 1 file).
- `tests/scripts/dev-tools/activate.Tests.ps1` (test, 1 file).

## Test Strategy
- Add a unit test for the null-background path (uncolored output).
- Retain existing dark/light coverage.
- Toolchain: PoshQC format -> analyze -> test.
- Manual validation: in the VS Code Test Explorer, the `activate.Tests.ps1` items pass after reload.

## Acceptance Criteria
- [ ] AC1: `Get-VenvAwarePrompt -BackgroundColor $null` returns the uncolored prompt and does not throw.
- [ ] AC2: A valid background color is unchanged in behavior (dark -> green-wrapped, light/non-dark -> plain).
- [ ] AC3: A deterministic regression test for the null-background case exists and passes without depending on the ambient host.
- [ ] AC4: `tests/scripts/dev-tools/activate.Tests.ps1` passes in full (no failures).
- [ ] AC5: Full PowerShell toolchain passes (format -> analyze -> test) with zero new findings.
- [ ] AC6: CI required checks are green on the PR head.

## Risks & Mitigations
- Risk: a host reporting a non-null but invalid background (for example integer -1) would still fail. Mitigation: out of scope for the observed defect (null); the guard covers the reported condition. A follow-up can normalize other invalid values if observed.

## Rollout & Follow-up
- Merge via PR after green CI.
- Links: issue #202, PR (to be created), `scripts/dev-tools/activate.ps1`.
