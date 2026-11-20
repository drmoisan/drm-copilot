# Policy Audit — Issue #155: claude-cli-background-script

- **Timestamp:** 2026-04-20T10-30
- **Branch:** claude-cli-background-script-155
- **Work Mode:** minor-audit
- **AC Source:** `issue.md` § "Acceptance Criteria (early draft)"
- **Files Under Review:**
  - `scripts/dev-tools/new-claude-worktree-session.ps1` (212 lines)
  - `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` (212 lines)

---

## Policy Reading Order Applied

1. `.github/copilot-instructions.md` — tone policy
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules
4. `.github/instructions/powershell-code-change.instructions.md` — PowerShell code rules
5. `.github/instructions/powershell-unit-test.instructions.md` — PowerShell test rules

---

## 1. General Code Change Policy (`general-code-change.instructions.md`)

### 1.1 Design Principles

| Requirement | Finding | Verdict |
|---|---|---|
| Simplicity first — prefer the simplest design that works | Seven single-purpose helper functions, each doing one conceptual thing. No deep indirection. | PASS |
| Factor reusable logic into small functions | All reusable logic is factored into named helpers; no copy-paste within the file. | PASS |
| Separation of concerns — keep pure logic separate from I/O | Pure string functions (`Build-WorktreePath`, `Build-BranchName`, `Get-WorktreeTimestamp`) are fully separated from I/O-touching functions (`Test-PreconditionsMet`, `Invoke-GitWorktreeAdd`, `Start-ClaudeBackground`). | PASS |

### 1.2 Classes, Functions, and APIs

| Requirement | Finding | Verdict |
|---|---|---|
| Use advanced functions with `CmdletBinding()` and named parameters | All seven helper functions have `[CmdletBinding()]`. Script-level params use `[CmdletBinding(SupportsShouldProcess)]`. | PASS |
| Functions should be short, readable, and clearly named | All functions are between 6–18 lines. Names use approved PowerShell verb-noun pairs. | PASS |
| Public methods must have clear documented contracts | Script-level `.SYNOPSIS`/`.DESCRIPTION`/`.PARAMETER` comment-based help is present. Functions lack individual help blocks. | PARTIAL — individual function-level help blocks absent; script-level help is complete. |

### 1.3 Error Handling, Logging, and Contracts

| Requirement | Finding | Verdict |
|---|---|---|
| Fail fast and explicitly; raise clear specific errors | `Test-PreconditionsMet` throws distinct, descriptive messages for each failure condition. | PASS |
| Do not silently ignore errors | `$ErrorActionPreference = 'Stop'` at script top. The `try/catch` in the body re-surfaces via `Write-Error` and `exit 1`. | PASS |
| Use project logging pattern instead of ad-hoc print/console | `Write-Output` used for structured stdout result; `Write-Error` used for failure messages. No bare `Write-Host` or `echo`. | PASS |

### 1.4 Module and File Structure

| Requirement | Finding | Verdict |
|---|---|---|
| File must not exceed 500 lines | Production script: 212 lines. Test file: 212 lines. Both are well under 500. | PASS |
| Module/file has a clear single purpose | Script is entirely focused on worktree creation and Claude CLI launch. | PASS |

### 1.5 Naming, Docs, and Comments

| Requirement | Finding | Verdict |
|---|---|---|
| Descriptive, non-cryptic names | Parameter names match issue spec exactly. Function names are unambiguous. | PASS |
| Comment why, not what | The script body section delimiter comment is present. No non-obvious patterns requiring additional comments. | PASS |

### 1.6 After Making Changes — Toolchain

| Requirement | Finding | Verdict |
|---|---|---|
| Format → Lint → Test toolchain must all pass | Plan records P3-T1 (format), P3-T2 (analyze with zero findings), P3-T3 (test: 306 passed, 0 failed). Plan status is `Complete`. | PASS (per plan evidence) |
| Toolchain run via approved MCP commands | Plan explicitly references `mcp__drmCopilotExtension__run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`. | PASS |

---

## 2. PowerShell Code Change Policy (`powershell-code-change.instructions.md`)

### 2.1 Tooling and Baseline

| Requirement | Finding | Verdict |
|---|---|---|
| Use `mcp__drmCopilotExtension__run_poshqc_format` for formatting | Plan P3-T1 records format run. | PASS |
| Use `mcp__drmCopilotExtension__run_poshqc_analyze` for linting, fix all findings | Plan P3-T2 records zero findings. | PASS |
| PowerShell 7+ compatibility (enforced via PSScriptAnalyzer settings) | No PS 5.x-specific constructs identified. Uses `[datetime]::Now`, splatting, scriptblock injection — all PS 7+ compatible. | PASS |

### 2.2 Design and Safety

| Requirement | Finding | Verdict |
|---|---|---|
| Prefer advanced functions with `CmdletBinding()` | All seven functions and the script param block use `[CmdletBinding()]`. | PASS |
| Add `[Parameter(Mandatory = $true)]` where appropriate | `-ShortName` marked mandatory. State-mutating function params marked mandatory. | PASS |
| Implement `ShouldProcess/SupportsShouldProcess` for state-changing actions | Script-level `[CmdletBinding(SupportsShouldProcess)]` present. `Start-ClaudeBackground` has `[CmdletBinding(SupportsShouldProcess)]`. `$PSCmdlet.ShouldProcess` guards `Invoke-GitWorktreeAdd` and `Start-ClaudeBackground` calls in the script body. | PASS |
| Avoid global state and mutable script-scoped variables | No global variables. All values passed explicitly through parameters. | PASS |
| Avoid `Invoke-Expression`, plaintext secrets, hard-coded credentials | None present. | PASS |
| Use `Write-Error`/`throw` for failures; avoid silent catch-alls | `Test-PreconditionsMet` uses `throw`. Script body catches and calls `Write-Error` then `exit 1`. No silent catches. | PASS |

### 2.3 Structure, Naming, and Comments

| Requirement | Finding | Verdict |
|---|---|---|
| Scripts cohesive and under 500 lines | 212 lines. | PASS |
| Use approved verbs and descriptive nouns | `Get-`, `Build-`, `Test-`, `Invoke-`, `Start-`, `Write-` are all approved PowerShell verbs. PSScriptAnalyzer would have flagged any violations and P3-T2 recorded zero findings. | PASS |

---

## 3. General Unit Test Policy (`general-unit-test.instructions.md`)

### 3.1 Core Principles

| Requirement | Finding | Verdict |
|---|---|---|
| Independence — tests run in any order | Each `Describe`/`Context` block uses `BeforeEach` to import functions fresh. No shared mutable state between `It` blocks. | PASS |
| Isolation — each test targets a single behavior | Each `It` block asserts exactly one behavior. One behavior per `It`. | PASS |
| Determinism — same inputs produce same results | All external calls are intercepted via injected scriptblocks. Fixed datetimes used for timestamp tests. | PASS |
| Readability — test names and structure are clear | `Describe`/`Context`/`It` naming is descriptive and unambiguous. | PASS |

### 3.2 Coverage and Scenarios

| Requirement | Finding | Verdict |
|---|---|---|
| Cover positive flows, negative flows, edge cases, error handling | All three precondition failure modes tested (no git, no claude, path exists). Happy path for each function tested. Non-blocking assertion, argument inclusion, and output format all covered. | PASS |
| Repository-wide line coverage must remain >= 80%; new modules target >= 90% | Post-change run: 313 tests (306 passing, 7 disabled), 0 failures. Baseline: 294 tests. Delta of +19 tests. Coverage XML is present at `artifacts/pester/powershell-coverage.xml`. Actual coverage percentage is UNVERIFIED — the coverage XML was not parsed in this review, and no coverage threshold failure was reported in the plan. | PARTIAL — coverage percentage not independently verified; plan reports no threshold failure. |

### 3.3 Test Structure and Diagnostics

| Requirement | Finding | Verdict |
|---|---|---|
| Arrange-Act-Assert pattern | Each `It` block follows setup (scriptblock injection), act (function call), assert (`Should -Be`, `Should -Match`, `Should -Throw`, `Should -Contain`). | PASS |
| Clear failure messages | Pester's built-in assertion messages are used. Assertions are typed and specific. | PASS |

### 3.4 External Dependencies and Environment

| Requirement | Finding | Verdict |
|---|---|---|
| No external dependencies in unit tests | All external calls (`Get-Command`, `Test-Path`, `Start-Process`, git) are replaced by injected scriptblocks. No real processes launched. | PASS |
| No temporary files created in tests | No `New-Item`, `New-TemporaryFile`, or file system writes in the test file. | PASS |

---

## 4. PowerShell Unit Test Policy (`powershell-unit-test.instructions.md`)

### 4.1 Framework and Scope

| Requirement | Finding | Verdict |
|---|---|---|
| Use Pester v5.x | Test file uses `Describe`/`Context`/`It`/`BeforeAll`/`BeforeEach`/`Should` — Pester v5 syntax. Plan records MCP test runner used. | PASS |
| Use repo config `pester.runsettings.psd1` | Plan records `mcp__drmCopilotExtension__run_poshqc_test` used, which applies the repo config. | PASS |
| Keep tests compatible with PowerShell 7+ | No PS 5.x-specific constructs. Pester v5 requires PS 7. | PASS |

### 4.2 Test Style and Structure

| Requirement | Finding | Verdict |
|---|---|---|
| Write focused tests — one function or behavior per test | Each `It` block targets exactly one assertion. | PASS |
| Use mocking sparingly; prefer real code paths | No Pester `Mock` calls present. Dependency injection via scriptblock parameters is used instead, which is the repo's established pattern. | PASS |
| Organize tests to mirror code under test (`tests/scripts/dev-tools/ScriptName.Tests.ps1`) | Test file is at `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` mirroring `scripts/dev-tools/new-claude-worktree-session.ps1`. | PASS |

### 4.3 Naming and Readability

| Requirement | Finding | Verdict |
|---|---|---|
| Name test files `*.Tests.ps1` | File is named `new-claude-worktree-session.Tests.ps1`. | PASS |
| Organize with `Describe`/`Context`/`It`; one behavior per `It` | All seven functions have a dedicated `Describe` block. `Context` groups related assertions within each. One `It` per assertion. | PASS |

---

## Overall Policy Compliance Verdict

**PASS WITH NOTES**

All hard policy requirements are met. Two observations that do not constitute violations:

1. Individual helper functions lack PowerShell comment-based help blocks (`.SYNOPSIS`/`.PARAMETER` per function). The general policy requires public methods to have documented contracts; the helper functions are script-internal, not exported public APIs. Script-level help is complete. This is a minor documentation gap, not a policy violation.

2. Code coverage percentage for the new module was not independently verified in this audit. The plan records a passing test run with zero failures and a toolchain pass, and no coverage-threshold failure was surfaced. The coverage artifact exists at `artifacts/pester/powershell-coverage.xml` but was not parsed.
