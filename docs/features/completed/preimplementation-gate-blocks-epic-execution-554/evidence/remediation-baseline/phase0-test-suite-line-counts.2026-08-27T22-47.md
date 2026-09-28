# Phase 0 — Test-Suite Line Counts and 500-Line Headroom (remediation cycle 1)

Timestamp: 2026-08-27T23-57
Cycle Timestamp: 2026-08-27T22-47
Task: [P0-T8]
Command: `pwsh -NoProfile -Command "foreach ($f in @('tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1','tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1')) { $c = (@(Get-Content -LiteralPath $f)).Count; Write-Host ('{0} = {1} lines, headroom {2}' -f $f, $c, (500 - $c)) }"`
EXIT_CODE: 0

## Measured counts

| Suite | Lines | Headroom against the 500-line cap |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | **494** | **6** |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | **235** | **265** |

The cap is `.claude/rules/general-code-change.md` line 49: "No production code, test code, or
reusable script file may exceed **500 lines**." The exception list in the following line covers
temporary throwaway scripts, raw text fixtures, and Markdown; a committed Pester suite is none of
those, so the cap binds.

## Does the Claude suite have room for the R2 and R4 cases?

**No.**

R2 requires a `Context` holding four `It` blocks that call `Test-PreparationModeDelegation` plus a
marker-set parity assertion, and R4 requires two `It` blocks (the classifier case plus the
decision-level companion that closes non-blocking gap N4). Written to the same density as the
existing cases in these suites — each case carrying an Arrange block building a literal
`[pscustomobject]` or string fixture, an Act line, an Assert line, and the explanatory comment this
repository's PowerShell documentation policy expects — that is approximately **fifty lines**.

Against **6 lines** of headroom, the shortfall is roughly forty-four lines. Even R4's single
smallest case, the two-line classifier assertion with its fixture and comment, does not fit in six
lines together with its enclosing `Context` declaration and closing brace.

The Codex suite at 235 lines has 265 lines of headroom and comfortably absorbs the ten Phase 1
cases; that is why R1 and R3 are placed there by edit while R2 and R4 go to a new sibling.

## Consequence — the Scope Note is evidenced, not assumed

This measurement is the evidence for the plan's Scope Note. The remediation directive named
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
as the Claude-side edit target for R2 and R4; that file cannot take them without breaching the cap.
The R2 and R4 cases therefore go into a new sibling suite,
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`,
following the precedent `spec.md` §Test Strategy itself set when
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` stood at 461 of
500 lines and "must not grow".

The count of test files written stays at two, so the PowerShell per-batch budget of 3 production and
3 test files is unaffected, and the named mode-resolution suite is left byte-untouched — a stronger
outcome than the directive required.

Output Summary: Claude mode-resolution suite is **494** lines with **6** lines of headroom; Codex
mode-resolution suite is **235** lines with **265** lines of headroom. The Claude suite does **not**
have room for the approximately fifty lines R2 and R4 require, which is the measured basis for
placing those cases in a new sibling suite. Exit code 0.
