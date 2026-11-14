# Code Review: Owner-directive pass-down fails on non-ASCII text (#1187)

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-14-owner-directive-pass-down-fails-on-non-ascii-text-1187`
**Feature Folder Selection Rule:** named by the caller; matches the issue number in `issue.md` and the branch `bug/owner-directive-pass-down-non-ascii`
**Base Branch:** `main` (merge base `1c652e60a61c71382100e584d5a9bccf584aa0e9`)
**Head Branch:** `bug/owner-directive-pass-down-non-ascii` at `aae55c0652c1110385f4220ce2c7672f80320954` (PR #1189)
**Review Type:** Initial review

---

## Executive Summary

The branch changes 38 files: two production PowerShell dispatchers and their two byte-identical bundle copies, seven Pester test files (one new), and 27 feature-folder documents and evidence files. Both dispatchers gain a stdin reader (`Read-PreToolUseDispatchStandardInput`, `Read-CodexPreToolUseDispatchStandardInput`) that wraps `[Console]::OpenStandardInput()` in a `StreamReader` with a non-throwing BOM-less `UTF8Encoding` and disposes it in `finally`. The Claude entry point routes the reader through `Read-ClaudeHookRawPayload -ReadStandardInput`, which keeps the redirect probe and environment fallbacks; the Codex entry point calls its reader directly, as it called `[Console]::In.ReadToEnd()` before. The three JSON writes of each dispatcher gain `-EscapeHandling EscapeNonAscii`.

Evidence reviewed: a reviewer re-run of the Pester gate at the head (`evidence/qa-gates/review-pester-gate.2026-11-14T21-51.md`), the PR context summary (generated at the reviewed head), the full diff, the final QA evidence, `artifacts/pester/powershell-coverage.xml`, and two reviewer real-process probes. The first probe piped the UTF-8 bytes of U+2014, U+201C, U+201D, and U+1F600 into `pwsh` with console input encoding `ibm437`: the old default produced 13 mis-decoded characters, while the new Claude seam composition and the Codex reader both returned the exact code units, and the escaped JSON round-tripped them. The second probe confirmed that the file reads left unchanged by D-4 decode BOM-less UTF-8 correctly. The implementation is small, correctly placed, and fully covered.

**What changed:**
`.claude/hooks/invoke-pretooluse-dispatch.ps1` (+49/-9), `.codex/hooks/invoke-pretooluse-dispatch.ps1` (+44/-7), their bundle copies, and Pester rows in `tests/scripts/claude-hooks/`, `tests/scripts/codex-hooks/`, and `tests/scripts/claude-lib/orchestrator-state/`.

**Top 3 risks:**
1. The fix reaches isolated subagents only after merge, because hooks run from the default branch (documented in the spec rollout section).
2. The `per-process` isolation mode is not covered by the decode; the shipped registry uses `in-process` (D-6, stated in the dispatcher help).
3. CI on the reviewed head was still running at review time (AC-20).

**PR readiness recommendation:** **Go** — no Blocker, Major, or Minor finding; the remaining items are informational and AC-20 awaits CI at S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1` | `Read-PreToolUseDispatchStandardInput` row "opens the process standard input through the default stream seam without reading it" (and the Codex twin) | The row runs the default `OpenStream` script block, which opens the real process stdin handle and disposes it without reading. | No change required. | It touches a process handle rather than a pure in-memory seam, but it does not read, block, or alter shared state; .NET returns a non-owning or duplicated handle, so disposal does not close the runner's stdin. | Diff inspection; final gate passed in 8 parallel workers |
| Info | `.claude/hooks/subagentstop-envelope.ps1` | `Read-SubagentStopEnvelope` | The SubagentStop envelope still reads `[Console]::In.ReadToEnd()` and shares the decode defect class. | No change in this item (spec D-7). | No SubagentStop hook hashes or compares owner-directive text or parses decision lines; the only consumers of decision lines and directive text on hook input are the pass-down hook (PreToolUse, now fixed) and file-decoded stop-hook sources. It is not related to this defect's observable behavior. | Search of `.claude/hooks` and `.claude/lib` for `OWNER-DIRECTIVE-DECISION`, `ConvertFrom-OwnerDirectiveDecisionLine`, and `Read-SubagentStopEnvelope` callers |
| Nit | `docs/features/active/2026-11-14-owner-directive-pass-down-fails-on-non-ascii-text-1187/evidence/` | `regression-testing/fail-before.2026-11-14T19-40.md`, `qa-gates/final-qc-pester.2026-11-14T21-17.md` | The `Timestamp:` field differs from the file-name stamp (19-37 versus 19-40; 21-05 versus 21-17); the body explains the run window. | No edit (evidence is append-only). | Readers may take the file name as the run time; the run window in the body is authoritative. | File inspection |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The executor's coverage report (21:17Z) predated the head merge commit `aae55c065` (21:24Z), and the coverage Stop hook reported it stale. | Resolved in this review: the reviewer re-ran the Pester gate at the head (exit 0, 26830 passed, 0 failed; dispatchers 100%; 96.01% repo-wide). | The merge changed no branch path, so the figures were expected to match, and they do. | `evidence/qa-gates/review-pester-gate.2026-11-14T21-51.md` |

No Blockers or Major findings. No covered file is at or above 700 logical lines (largest changed file: 423 lines).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fix point is the single place every in-process PreToolUse hook depends on: the dispatcher decodes once and the runner replays the decoded string through `[Console]::SetIn`, so the pass-down hook and every other hook receive correct text without changes (D-1).
- `Read-ClaudeHookRawPayload` is reused with an injected `-ReadStandardInput`, so the redirect probe (no blocking on a non-redirected console) and the `CLAUDE_HOOK_INPUT` and `CLAUDE_TOOL_INPUT` fallbacks are preserved, and `HookPayload.psm1` is unchanged.
- The nested script block `{ Read-PreToolUseDispatchStandardInput }` is created in the dispatcher's script scope and resolves the reader when invoked from inside the module function; the reviewer's real-process probe confirmed this.
- `-EscapeHandling EscapeNonAscii` makes stdout bytes independent of `[Console]::OutputEncoding` without a process-wide encoding change (D-5); ASCII-only decisions are unchanged.
- Rule S1 is respected: the script tail only gains a parameter on the existing emit.

#### API and safety notes

- Both readers are advanced functions with `[CmdletBinding()]`, `[OutputType([string])]`, comment-based help, and an approved verb. They change no state, so `ShouldProcess` does not apply.
- The `OpenStream` seam is typed `[scriptblock]` with a one-expression default.
- PSScriptAnalyzer reported 0 findings and the formatter 0 differences over all 11 changed `.ps1` files.

#### Error handling and logging

- `UTF8Encoding($false, $false)` maps invalid sequences to U+FFFD instead of throwing; an affected entry then fails rule B5, so the outcome fails closed.
- The reader is disposed in `finally`; `leaveOpen` is not set, so the stream is disposed with it, which the "disposes the stream it reads" row asserts.
- No logging is added; the per-hook trace stays ASCII-escaped.

---

## Test Quality Audit

The tests pin each read, hash, and compare path for three character classes (BMP punctuation, paired quotes, and a non-BMP character), with positive and negative rows. The fail-before evidence records 26 rows failing against the unchanged dispatchers with the expected messages, so the new reader and output rows discriminate. The AC-12 contrast row shows a Latin1 decode of the same bytes being denied while the UTF-8 reader output is allowed. The existing script-tail row moved from `[Console]::SetIn` to a mock of `Read-ClaudeHookRawPayload` with a `-ParameterFilter` that requires the reader name, which removes a console mutation and keeps the original assertions.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1` and `tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1` — byte-level reader rows, ASCII-output rows for the decision, trace, and dependency-failure writes, and AST pins of the `ReadPayload` defaults.
- `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1` — ordinal equality of the two reader bodies.
- `tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1` — relay, ledger, decision-file, and decode-contrast rows through `Get-OwnerDirectivePassDownDecision` with in-memory seams.
- `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1` — stop-hook relay-missing and ledger-validation rows with non-ASCII entries.
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1` and `OrchestratorStateOwnerDirectiveDecision.Tests.ps1` — B5 digest rows and decision-line rows.
- `evidence/regression-testing/fail-before.2026-11-14T19-40.md` — 26 expected failures before the production change.
- `evidence/qa-gates/final-qc-pester.2026-11-14T21-17.md`, `final-qc-pytest.2026-11-14T21-18.md`, `final-qc-static-powershell.2026-11-14T21-05.md` — final gates, all exit 0.

### Quality assessment prompts

- **Determinism:** fixed clock, in-memory file maps, characters built from code points, test sources ASCII-only (verified: 0 non-ASCII lines in all 11 changed `.ps1` files).
- **Isolation:** each row targets one decode property, write site, or decision path.
- **Speed:** in-memory rows; the reviewer's full parallel gate at the head ran in 689.56 s for 26848 tests.
- **Diagnostics:** `Should -BeExactly` on decoded text and full reason prefixes; `-Because` clauses on the ASCII and parity assertions.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; the leak scan reported 0 failures. |
| No unsafe subprocess or command construction | ✅ PASS | No process start added. |
| Input validation at boundaries | ✅ PASS | Invalid UTF-8 becomes U+FFFD and fails B5 closed; no allow path is added; deny codes are unchanged. |
| Error handling remains explicit | ✅ PASS | Reader disposal in `finally`; no catch added. |
| Configuration / path handling is safe | ✅ PASS | No configuration, registry, or settings change; bundle copies byte-identical (`cmp`). |
| No hook invokes Python | ✅ PASS | No Python call added; `enforcement-hooks-no-python-invocation.Tests.ps1` passed in the final gate. |

---

## Research Log

No external research was required. .NET behavior of `UTF8Encoding`, `StreamReader` BOM detection, and `ConvertTo-Json -EscapeHandling` was confirmed by the reviewer's real-process probe on this host rather than by documentation.

---

## Verdict

The change is ready for the normal PR flow. It fixes the root cause at the dispatcher boundary for both runtimes, preserves the payload reader's contract, keeps ASCII output byte-identical, and is covered at 100% of the changed dispatcher lines with tests that were shown to fail before the fix. The findings are informational. AC-20 depends on CI on the reviewed head, which was in progress at review time, and is checked at S9.
