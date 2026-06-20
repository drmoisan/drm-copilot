# Policy Compliance Audit — harden-small-path-completion-gate (Issue #207)

- Timestamp: 2026-06-19T19-02
- Reviewer: feature-review agent
- Work Mode: minor-audit (from issue.md)
- Base branch: main
- Merge-base SHA: db3d528ea9c8fb87e9ec21a4d96e4c263d347651
- Branch HEAD: 2b923604b083e0df20b24939694064dc87d184ae
- Branch: refactor/harden-small-path-completion-gate-207

## Scope

Full branch diff against the resolved base branch (feature-vs-base). Changed files:

| File | Status | Lines (+) |
|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | Added | 273 |
| `.claude/settings.json` | Modified | 4 |
| `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` | Added | 180 |
| `docs/features/active/.../issue.md` | Added | 68 |
| `docs/features/active/.../plan.2026-06-19T18-43.md` | Added | 198 |
| `docs/features/active/.../evidence/**` (10 files) | Added | docs/evidence |

Languages with changed files in the branch diff: **PowerShell** (production + test), **JSON** (settings). No TypeScript, Python, or C# files are changed in the branch diff.

## Rejected Scope Narrowing

No caller attempt to narrow scope below the full branch diff was detected. The caller instruction explicitly directed full-branch scope determination. No narrowing recorded.

## Evidence Location Compliance

The branch diff writes evidence only under the canonical `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/<kind>/` path (`evidence/baseline/`, `evidence/qa-gates/`). No files are written to non-canonical `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/` paths.

Verdict: **PASS**.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md` (PowerShell is the in-scope language)

## Toolchain Verification (PowerShell)

PowerShell toolchain order per `.claude/rules/powershell.md`: format -> analyze -> test (no type-check stage for PowerShell).

| Stage | Command | Result | Verdict |
|---|---|---|---|
| Formatting | `Invoke-Formatter` on both new PS1 files | No diff; both files already formatted | PASS |
| Linting | `Invoke-ScriptAnalyzer -Severity Warning,Error` on both new PS1 files | No warnings or errors | PASS |
| Type check | N/A for PowerShell (policy: skip) | — | N/A |
| Tests | `Invoke-Pester` on `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` | 16 passed, 0 failed, 0 skipped | PASS |

Executor evidence (`evidence/qa-gates/final-pester.md`) records the repo-wide MCP Pester run: 248 tests total, 0 failures, EXIT_CODE 0. This audit independently re-ran the new file's 16-test suite (all pass) and re-ran format and analyze stages locally with clean results.

## Coverage Verification (PowerShell)

Coverage artifact: `artifacts/pester/powershell-coverage.xml` exists (pre-existing executor run; inspected, not regenerated).

Repo-level (report-scope) coverage from `evidence/qa-gates/coverage-delta.md`:

| Metric | Value | Threshold | Verdict |
|---|---|---|---|
| Line coverage (measured scope) | 96.83% (covered=275, missed=9) | >= 85% | PASS |
| Branch/instruction proxy | 96.99% (covered=420, missed=13) | >= 75% | PASS |
| Regression on changed lines | 0.00% delta vs baseline | no regression | PASS |

PowerShell coverage verdict: **PASS** (repo-wide measured scope meets thresholds; no regression).

### Coverage-Denominator Gap (PARTIAL finding)

The coverage measurement denominator is defined in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path`, which enumerates only five hook files. The new production file `.claude/hooks/enforce-completion-consistency.ps1` is NOT in that denominator. Consequences:

- The reported 96.83% line / 96.99% branch figures do not include the new file's lines.
- Per `.claude/rules/general-unit-test.md` ("Coverage Exclusion Policy: No production file may be excluded from coverage measurement"), excluding a production source file from the denominator is a policy deviation.

Mitigating facts:
- `pester.runsettings.psd1` is NOT modified by this branch (confirmed: `git diff` against merge-base is empty for that file). The exclusion is a pre-existing repository configuration, not introduced by this feature.
- The sibling completion-gate hooks `enforce-checkpoint-monotonic.ps1` and `validate-orchestrator-output.ps1` are likewise absent from the denominator, so the new file follows the established repository pattern for this hook family.
- The new file's decision logic is fully exercised by its 16-test suite covering every branch (empty input, missing file_path, non-checkpoint path, Edit payload, malformed top-level JSON throw, invalid content JSON allow, non-asserting allow, full-evidence allow, variables.* fallbacks, and the four block paths). Untested-critical-behavior risk is low.

Verdict: **PARTIAL**. The behavior is well-tested, but the new production file is not counted in the coverage denominator, which deviates from the no-exclusion policy. This is a pre-existing structural pattern that the branch extends rather than introduces. Recommendation (non-blocking): add `.claude/hooks/enforce-completion-consistency.ps1` (and ideally the sibling completion-gate hooks) to `CodeCoverage.Path` so the new file's coverage is measured and counted. This is a configuration change to a file outside the current change set and is recorded as a remediation candidate, not a merge blocker, because the change does not regress any measured coverage and the new logic is fully test-exercised.

## General Code-Change Policy

| Rule | Evidence | Verdict |
|---|---|---|
| 500-line file limit (production) | `enforce-completion-consistency.ps1` = 273 lines | PASS |
| 500-line file limit (test) | `enforce-completion-consistency.Tests.ps1` = 180 lines | PASS |
| Simplicity / separation of concerns | Pure decision function `Invoke-CompletionConsistencyDecision` separated from env/stdout I/O at the entrypoint; helper functions are small and single-purpose | PASS |
| Fail-fast / explicit errors | Malformed top-level `CLAUDE_TOOL_INPUT` JSON throws with context; entrypoint catches, `Write-Error`, `exit 1` | PASS |
| No silent error suppression | Invalid content JSON path intentionally allows and defers to downstream tools, documented in code comment; not a silent swallow | PASS |
| I/O boundary isolation | Env read and stdout write only in the entrypoint; core logic is pure and unit-testable | PASS |
| No new dependencies | Uses only built-in cmdlets | PASS |

## PowerShell Language Policy (`.claude/rules/powershell.md`)

| Rule | Evidence | Verdict |
|---|---|---|
| PowerShell 7+ compatibility | `#Requires -Version 7.0` in test; `[CmdletBinding()]` advanced functions; no v5-only constructs | PASS |
| Advanced functions with `CmdletBinding()` | All functions declare `[CmdletBinding()]`; typed `[OutputType]` where applicable | PASS |
| Mandatory parameters / validation | `[Parameter(Mandatory)]` and `[AllowNull()]` used appropriately | PASS |
| Approved verbs | `ConvertFrom-`, `Test-`, `Get-`, `Invoke-` are all approved verbs | PASS |
| Mockable IO seam | `ConvertFrom-CheckpointJson` wrapper is mockable; test verifies the mock path | PASS |
| Dot-source guard | `if ($MyInvocation.InvocationName -eq '.') { return }` matches sibling hook pattern | PASS |
| No `Invoke-Expression` / plaintext secrets / hard-coded creds | None present | PASS |
| Change budget (<= 2 production PS files) | 1 production PS file | PASS |
| Structural parity with sibling hook | Output contract (`decision`/`reason` ordered dict, `ConvertTo-Json -Compress`, `exit 0`) matches `enforce-checkpoint-monotonic.ps1` | PASS |

## Unit Test Policy (`.claude/rules/general-unit-test.md`)

| Rule | Evidence | Verdict |
|---|---|---|
| Independence / isolation | Each `It` targets one behavior; no shared mutable state across tests | PASS |
| Determinism | No network, no wall-clock, no real executables; env var saved/restored in entrypoint tests | PASS |
| No temporary files | Tests construct JSON in-memory; no temp files created | PASS |
| Test file location mirrors source | `tests/scripts/claude-hooks/...Tests.ps1` mirrors `.claude/hooks/...ps1` hook tree (consistent with sibling hook test placement) | PASS |
| `*.Tests.ps1` naming | Filename ends `.Tests.ps1` | PASS |
| Scenario completeness | Positive (allow), negative (4 block paths), edge (empty input, Edit payload, fallbacks), error (malformed JSON throw, invalid content allow) | PASS |
| Mock signature parity | Mock of `ConvertFrom-CheckpointJson` matches production seam | PASS |
| Coverage exclusion of production file | New production file not in coverage denominator (see Coverage section) | PARTIAL |

## settings.json Integrity

| Check | Evidence | Verdict |
|---|---|---|
| Valid JSON after edit | `json.load` succeeds | PASS |
| Registered event | `PreToolUse` | PASS |
| Registered matcher | `Write|Edit` | PASS |
| Command form parity | `pwsh -NoProfile -File .claude/hooks/enforce-completion-consistency.ps1` matches sibling-hook registration style | PASS |
| Additive change | Appended after `enforce-checkpoint-monotonic.ps1`; no existing entries altered | PASS |

## modified-workflow-needs-green-run

The branch diff does not modify any path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. Rule does not fire. Verdict: **PASS (not triggered)**.

## Overall Verdict

**PASS with one non-blocking PARTIAL** (coverage-denominator gap for the new production file).

- Zero blocking findings.
- All toolchain stages (format, analyze, test) pass with independent re-verification.
- The single PARTIAL is a pre-existing repository coverage-configuration pattern that the new file follows; the new logic is fully exercised by passing tests with no measured-coverage regression. Recommended remediation (add the new hook to `CodeCoverage.Path`) is non-blocking.

## Appendix B — Command Reference

- `git diff --name-status db3d528ea9c8fb87e9ec21a4d96e4c263d347651..HEAD`
- `git diff db3d528ea9c8fb87e9ec21a4d96e4c263d347651..HEAD -- .claude/settings.json`
- `python -c "import json; json.load(open('.claude/settings.json'))"`
- `Invoke-ScriptAnalyzer -Path <file> -Severity Warning,Error`
- `Invoke-Formatter -ScriptDefinition <content>` (compared to original)
- `Invoke-Pester -Configuration <cfg over tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1>`
- Inspected coverage artifact: `artifacts/pester/powershell-coverage.xml` (existing); coverage denominator: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
