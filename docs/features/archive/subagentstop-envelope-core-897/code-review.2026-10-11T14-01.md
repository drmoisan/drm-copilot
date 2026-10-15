# Code Review: subagentstop-envelope-core, E1 of epic subagentstop-envelope (#897)

---

**Review Date:** 2026-10-11
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/subagentstop-envelope-core-897`
**Feature Folder Selection Rule:** Supplied by the caller; suffix matches the issue number in the branch name and it is the only active folder whose scoping doc (`spec.md`) changed materially in the diff.
**Base Branch:** `origin/epic/subagentstop-envelope-integration` (`64642312b5aa83b66d5d9cc0ce131d1308a4182a`)
**Head Branch:** `bug/subagentstop-envelope-core-exec-897` (`806cf067aa28840cf1438a0ff50420cbee0a57d4`, detached review checkout equal to `origin/bug/subagentstop-envelope-core-897`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds one new dot-sourced PowerShell helper, `.claude/hooks/subagentstop-envelope.ps1` (191 lines), exposing `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, and `Exit-SubagentStopBlock`; a byte-identical bundled mirror; a `core.json` manifest entry; a 78-case Pester suite with a 22-line test-only fixture; four regression assertions in `claude-settings.Tests.ps1`; and the removal of the inert inline SubagentStop command from both `settings.json` copies. Forty Markdown files under the feature folder carry the plan, spec, and evidence. The diff is 48 files, +2191/-107, of which 8 are code or configuration.

Evidence reviewed: the full diff against the merge base, `artifacts/pr_context.summary.txt` and `.appendix.txt`, every file under `evidence/`, the live differential that measured the real SubagentStop envelope, the plan (61/61 tasks), and an independent re-parse of the executor's `artifacts/pester/powershell-coverage.xml` (located by its recorded write time; the five changed PowerShell/JSON files in that worktree are byte-identical to the review head). The implementation matches the spec's Authoritative Helper Contract row for row; the suite encodes each row as a test case; the toolchain closed in one pass; new-code line coverage is 100%.

**What changed:**
- `.claude/hooks/subagentstop-envelope.ps1` (new) and its mirror: contract-conformant reader (stdin default, `-InputText` override, BOM strip, `ConvertFrom-Json -NoEnumerate -DateKind String`, six anomaly codes, seven-property result), reason map with `ArgumentException` on unknown codes, and an exit-2 block function writing to stderr only.
- `.claude/settings.json` and the bundled copy: the four-line inline command object (`$env:CLAUDE_HOOK_INPUT` / `.output` / `exit 1`) removed from the fifteen-agent SubagentStop group; the matcher and `validate-discovery-artifact-gate.ps1` entry retained.
- `pack-manifests/core.json`: one `paths` entry so the push-down delivers the helper with the core pack.
- Tests: new suite (surface, AST source constraints, 22 input rows x 2 templates, derived fields, BOM/CRLF, stdin default, anomaly reasons, `&`-route exit) and four settings regressions.

**Top 3 risks:**
1. The helper requires PowerShell 7.5+ (`-DateKind`), with no `#Requires -Version 7.5` guard; on an older `pwsh` every payload would classify as `UnparseableJson`, which is fail-closed but would block every matched SubagentStop with a misleading reason (CR-1, Minor).
2. The repo-wide command-coverage total moved down 0.49 points between the baseline and final full runs, and the retained evidence cannot identify the originating files; the arithmetic places the movement outside the diff (CR-2, Info).
3. The helper has no consumer until E2-E4 land, so the runtime block path (`exit 2` from a dot-sourced function inside a `pwsh -File` hook) is proven by the in-process `&`-route test and the live differential, not by a registered hook on this branch. This is by design for E1 (CR-3, Info).

**PR readiness recommendation:** **Go** — no Blocker or Major findings; the contract, tests, parity, and toolchain evidence are complete and were spot-verified independently.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/subagentstop-envelope.ps1` | line 112; file header (no `#Requires`) | `ConvertFrom-Json -DateKind String` requires PowerShell 7.5+. The file documents this in `.NOTES` but carries no `#Requires -Version 7.5`. On `pwsh` 7.4 or earlier the parameter-binding error is caught at line 114 and every payload maps to `UnparseableJson`, so consumers would block every matched stop with the reason "payload is not valid JSON". | Non-blocking for E1. When E2-E4 wire consumers, consider adding `#Requires -Version 7.5` to the helper so an unsupported runtime fails at dot-source time and is reported through the consumers' `Add-HookDependencyFailure` guard (spec consumer policy item 4), which names the real cause. Verify the GitHub-hosted runner `pwsh` version in the first E2 CI run. | Fail-closed either way, but a dependency failure names the cause; an `UnparseableJson` block sends the subagent a repair instruction it cannot act on. | `spec.md` Authoritative Helper Contract ("PowerShell 7.5 or later; hooks run under `pwsh`"); local runtime 7.6.5 (`issue.md` Environment); `_poshqc.yml` uses `shell: pwsh` on `windows-latest`/`ubuntu-latest` without a pinned version. CI for this branch is not available before PR creation. |
| Info | `docs/features/active/subagentstop-envelope-core-897/evidence/qa-gates/final-pester-coverage.md` | "Comparison with the baseline run" | Repo-wide command coverage 89.16% -> 88.67% (covered commands about 23,072 -> 23,011 while analyzed commands rose 25,877 -> 25,950). The 73 added commands are all covered, so about 134 commands outside the diff were covered at baseline and uncovered in the final run. The `.claude/hooks` package counters (5226/207 -> 5286/207) exclude the hooks package as the origin. | No action on this branch. Suggested process follow-up outside E1: copy the Phase 0 `powershell-coverage.xml` to a distinct name so a later run can be diffed per file. | Both totals are above the 85% threshold and no changed line regressed; however the retained evidence cannot localize the movement, so it is recorded rather than explained. | Review re-parse of the final XML: `REPORT_COUNTER INSTRUCTION (88.67, 23011, 2939)`, `LINE (89.84, 16064, 1817)`; `PKG .claude/hooks LINE (96.23, 5286, 207)`; baseline figures from `evidence/baseline/p0-pester-coverage.md`. |
| Info | `.claude/hooks/subagentstop-envelope.ps1` | lines 171-191 | `Exit-SubagentStopBlock` is exercised through the in-process `&` route (fixture) and the exit-2 semantics were measured by the live differential with a probe hook, but no registered hook on this branch calls the helper. The runtime block path through `pwsh -NoProfile -File <validator>` is therefore proven by E2-E4, not E1. | None for E1; this matches the spec's scope ("the nine validators are converted by E2, E3 and E4"). E2 should include at least one validator-level test that dot-sources the helper and asserts `$LASTEXITCODE` 2 through the validator's own entry point. | Keeps the contract-vs-runtime boundary explicit for the epic. | `spec.md` Scope & Non-Goals; `evidence/other/subagentstop-live-differential.2026-10-11T12-01.md` (exit-2 run resumed the subagent with `stop_hook_active: true`); `evidence/other/p1-exit-route-probe.md` (`RUNNER_CONTINUED: yes`). |
| Info | `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` | lines 232-236, 249-251 | The `null` row of `throws ArgumentException for <Name>` binds `$null` to a `[string]` parameter, which PowerShell converts to `''` under `[AllowNull()]`; the row therefore exercises the same path as the empty-string row. | None required; the row documents the contract's stated `$null` case and passes. If a distinct null path is ever desired, the parameter type would have to change, which the contract does not call for. | Avoids a false belief that a separate null branch exists in the function. | Helper lines 36-41 (`[AllowNull()][AllowEmptyString()][string] $Anomaly`); test passes (78/78). |
| Nit | `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` | lines 260, 266 | The `&`-route test writes `$global:LASTEXITCODE` before and after the act. This is the standard way to make `$LASTEXITCODE` deterministic for an in-process `exit`, and it is restored in `finally`. | None; noted because `.claude/rules/powershell.md` discourages global state and this is a justified, scoped exception. | Transparency on the one global written by the suite. | Test file lines 256-267. |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The reader implements the contract's input-to-result table exactly, including the two non-obvious parser flags: `-NoEnumerate` so a single-element array is classified `NonObjectEnvelope` rather than unwrapped (test row `single-element array`), and `-DateKind String` so an ISO-8601-shaped message stays a `[string]` (test row `ISO-date string message`). The root-type check compares against the full `System.Management.Automation.PSCustomObject` type name with an inline comment explaining why the `[pscustomobject]` accelerator would be wrong (line 122).
- `$PSBoundParameters.ContainsKey('InputText')` distinguishes an unbound parameter from a bound empty/null one (lines 81-91), which is what lets the `prefers a bound empty InputText over non-empty stdin` test hold and keeps validator pure entry points testable without stdin.
- Property lookups use `-ceq` over `PSObject.Properties` (lines 128, 143, 148, 153) rather than `$parsed.last_assistant_message`, so case-variant keys are not silently accepted; combined with `ConvertFrom-Json` raising on case-duplicate keys, the classification is deterministic.
- Derived fields (`StopHookActive`, `AgentType`, `HookEventName`) are populated from any object root regardless of validity, which is what E2-E4 need to apply re-entry policy on an invalid envelope.
- The result is a single `[pscustomobject][ordered]` literal (lines 160-168) so the seven-property shape and order are fixed in one place; the shape test asserts the exact name list.
- The inline settings command was deleted rather than converted, with a fifteen-row per-agent justification in `spec.md` and a retained matcher so existing matcher assertions in `claude-settings.Tests.ps1` and `test_claude_planning_integrity_contracts.py` stay green. The four new settings tests lock the removal in both copies.

#### API and safety notes

- All three functions are advanced functions with `[CmdletBinding()]`; `Read-*` and `Get-*` declare `[OutputType()]`.
- `Exit-SubagentStopBlock -Message` is `[Parameter(Mandatory)][ValidateNotNullOrEmpty()]`, so a null/empty reason fails binding before any exit (asserted). `-InputText` and `-Anomaly` deliberately allow null/empty so those inputs reach classification.
- No `ShouldProcess`: the only state change is the process exit that is the function's purpose.
- No script- or global-scope variables; no `Invoke-Expression`; no hard-coded paths; no environment reads (AST-asserted).
- Approved verbs throughout; PSScriptAnalyzer reported zero findings on all five files including the fixture, which lies outside the configured scan roots and was passed explicitly.
- See CR-1 on the absent `#Requires -Version 7.5`.

#### Error handling and logging

- The stdin read and the JSON parse are each wrapped in a narrow `try`/`catch` whose outcome is an anomaly code, by contract; the helper never throws from `Read-SubagentStopEnvelope`. This is not a silent swallow: the anomaly is returned and consumer policy item 1 blocks on it (fail closed). `-ErrorAction Stop` is set on `ConvertFrom-Json` so non-terminating parse errors still enter the `catch`.
- `Get-SubagentStopEnvelopeAnomalyReason` throws `System.ArgumentException` with the rejected value and parameter name for any unknown code (programming error, surfaced fail-fast); `switch -CaseSensitive` makes case variants unknown by design.
- `Exit-SubagentStopBlock` writes only to `[Console]::Error` and exits 2, which the live differential confirmed is the only blocking exit code and is delivered to the subagent as its next instruction.
- No logging is performed; the helper writes to no stream other than stderr from the exit function, which is required so a `pwsh -File` hook's decision is not preceded by stray output.

---

## Test Quality Audit

Automated evidence is complete for E1's scope: a fail-before run (helper suite: every `It` failing with `CommandNotFoundException` before the helper existed; settings suite failing on the inline command) and pass-after runs are recorded; the full self-hosted Pester run passed 9867/9867 with the helper at 100% line coverage; pytest parity (22/22) and the Jest manifest test (16/16) passed after the mirror and manifest changes. The guard suites named by AC-23 passed unchanged (775 cases). No end-to-end hook registration exercises the helper on this branch (CR-3), which is consistent with the spec.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` — 78 cases: surface, AST source constraints (environment reads, imports/dot-source, success/host/information/warning writes), one case per contract row with a parallel shape case, derived fields, BOM/CRLF, stdin default (including a disposed reader and bound-empty precedence), anomaly reasons (six codes, distinctness, four invalid inputs), and the `&`-route exit with stderr capture. No gap against the spec's Test Strategy bullets.
- `tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1` — two-statement entry point that dot-sources the helper by `$PSScriptRoot`-relative path and calls `Exit-SubagentStopBlock`; lets the exit test run in-process without a child `pwsh`.
- `tests/scripts/claude-runtime/claude-settings.Tests.ps1` (diff) — four regressions over both parsed settings copies with `-Because` messages; asserts the fifteen-agent group retains exactly the discovery-gate command.
- `evidence/regression-testing/p2-helper-suite-fail-before.md`, `p3-helper-suite-pass-after.md`, `p2-claude-settings-fail-before.md`, `p4-claude-settings-pass-after.md` — fail-before/pass-after pairs with exit codes (1 expected, then 0).
- `evidence/qa-gates/final-poshqc-format.md`, `final-poshqc-analyze.md`, `final-pester-targeted.md`, `final-pester-coverage.md`, `final-helper-coverage.md`, `coverage-comparison.md`, `final-qc-loop.md` — one clean pass; helper 60/60 lines; `FINAL_PASS: 1`.
- `evidence/qa-gates/final-pytest-parity.md`, `final-jest-manifest.md`, `final-mirror-parity.md`, `final-line-counts.md`, `final-scope.md`, `final-no-python.md` — parity, manifest, line-cap, and scope evidence for AC-2/3/22/26/27/28.
- `evidence/other/subagentstop-live-differential.2026-10-11T12-01.md` and `p1-exit-route-probe.md` — the measured runtime premise (stdin JSON, `last_assistant_message`, no `CLAUDE_HOOK_INPUT`, exit 2 blocks) and the in-process `exit` behavior under `&`.
- Review-side re-parse of `artifacts/pester/powershell-coverage.xml` (executor worktree, written 2026-10-11 13:12:33): `SF subagentstop-envelope.ps1 LINE (100.0, 60, 0)`, `SF_MISSED_LINES []`, report `LINE (89.84, 16064, 1817)`.

### Quality assessment prompts

- **Determinism:** No randomness, clock, network, child process, or file creation. stdin/stderr are replaced by in-memory readers/writers and restored in `finally`; `$global:LASTEXITCODE` is reset. Inputs are inline strings.
- **Isolation:** One behavior per `It`; `-TestCases` rows expand into separately reported cases; contexts map one-to-one to spec bullets.
- **Speed:** The added suite is in-process with no I/O; the full repository run (9867 tests) completed in 556 s, within baseline range (558 s).
- **Diagnostics:** Exact-match assertions report expected vs actual; `-Because` clauses on the settings regressions name the copy and the rule; the fail-before record shows failures identify the missing function by name.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspected; no tokens, credentials, or paths outside the repository. Evidence files contain no absolute host paths other than the executor's redacted outputs (`R-REDACT`). |
| No unsafe subprocess or command construction | PASS | The helper spawns nothing. The removed settings entry was itself an inline `pwsh -Command` string; its deletion reduces command construction in configuration. |
| Input validation at boundaries | PASS | Every stdin/`-InputText` shape is classified (null, empty, whitespace, BOM, non-JSON, non-object root, missing/null/non-string message); unknown anomaly codes throw; empty block reasons fail binding. |
| Error handling remains explicit | PASS | Narrow `try`/`catch` with anomaly outcomes; `-ErrorAction Stop`; `ArgumentException` with value; no `-ErrorAction SilentlyContinue` in production. |
| Configuration / path handling is safe | PASS | Fixture and suite resolve paths from `$PSScriptRoot`; `core.json` entry is repository-relative; both `settings.json` copies remain byte-identical and parse as strict JSON. |

---

## Research Log

No external research was required for this review. The vendor hook semantics relied on by the spec were measured locally by the executor's live differential (`evidence/other/subagentstop-live-differential.2026-10-11T12-01.md`, Claude Code 2.1.296) and quoted in `research/research.2026-10-11T12-15.md`; the review used those recorded results. The PowerShell 7.5 origin of `ConvertFrom-Json -DateKind` is stated in the spec and the helper's `.NOTES` and was not re-verified against vendor documentation from this environment.

---

## Verdict

The change is ready for normal PR flow into `epic/subagentstop-envelope-integration`. The helper implements the Authoritative Helper Contract exactly, the suite encodes every contract row, mirrors and manifests are in parity, the inline command removal is locked by regression tests in both settings copies, and the toolchain closed in a single clean pass with 100% line coverage on the new file and 89.84% repo-wide PowerShell line coverage. One Minor finding (CR-1, missing `#Requires -Version 7.5`) and three informational notes are recorded; none requires a change before merge, and CR-1 is best addressed when E2-E4 wire the consumers. This conclusion matches the Findings Table (no Blocker or Major) and the **Go** recommendation above.
