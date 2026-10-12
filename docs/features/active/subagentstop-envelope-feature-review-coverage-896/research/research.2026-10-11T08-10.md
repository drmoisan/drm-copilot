# Research: feature-review coverage hook follow-ups and SubagentStop envelope (issue #896, epic child E4)

- Issue: #896 (Refs #884 Codex half, Refs #897 feature-review validator only)
- Epic: subagentstop-envelope (#904), child E4
- Branch: `bug/subagentstop-envelope-feature-review-coverage-896`, base `origin/epic/subagentstop-envelope-integration` at `ac525c4ef`
- Research timestamp: 2026-10-11T08-10
- Mode: preparation (research only; no production or test file modified)

All line numbers below were verified against the current worktree tree with the Read and Grep tools. Paths are repository-relative.

## Summary of findings that change the issue's premises

1. The Codex hook coverage figure in the issue (7.30%, 10/137, CI 38022356096) is stale. Two later QA artifacts measure `.codex/hooks/validate-feature-review-coverage.ps1` at 99.29% (140/141): `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-final-pester-coverage.md:228` (2026-10-10T21-21) and `docs/features/active/epic-852-main-sync/evidence/qa-gates/final-pester-coverage.md:22` (2026-10-11T00-40). The suite responsible, `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` (199 lines, 29 test cases per r2 JUnit line 67), is present in this tree. The >= 85% requirement for the Codex hook is therefore expected to hold at baseline; the plan must re-measure it rather than plan a 7%-to-85% coverage campaign.
2. The current Claude block path does not block at runtime for two independent reasons: it reads `$env:CLAUDE_HOOK_INPUT` (line 471), which is not set for SubagentStop, and it ends with `Write-Error` under `$ErrorActionPreference = 'Stop'` (lines 49, 473), which terminates the script with process exit 1 before `exit 1` (line 474) is reached (pinned by `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:292`). Exit 1 does not block SubagentStop (E1 live differential, see Q3).
3. Any unhandled exception inside the decision function (unreadable `CLAUDE.md`, unreadable policy audit, malformed JaCoCo XML at lines 203 and 238) also ends as process exit 1, which is fail-open for SubagentStop. CR-4 is one instance of this broader defect.
4. Repository root `CLAUDE.md` contains no coverage statement (Grep for `coverage` in `CLAUDE.md` returns no match), so in this repository both hooks would resolve the defaults 85 line / 75 branch.

## Q1. Claude hook structure

### `.claude/hooks/validate-feature-review-coverage.ps1` (477 lines)

| Lines | Element | Callers (file:line) |
|---|---|---|
| 1-43 | Comment-based help. Line 41 states "Reads the hook payload from CLAUDE_HOOK_INPUT"; line 42 states "exits 1 ... to block". Lines 29-35 carry the precedence text including "falls back independently". | n/a |
| 44-45 | `[CmdletBinding()] param()` | n/a |
| 46 | Guard bootstrap: dot-source `hook-dependency-guard.ps1` in try; catch sets `$script:HookDependencyGuardLoadFailed`. | n/a |
| 47 | Guarded dot-source of `feature-review-coverage-thresholds.ps1`; catch calls `Add-HookDependencyFailure`. | n/a |
| 49 | `$ErrorActionPreference = 'Stop'` | n/a |
| 51-73 | `Get-ArtifactFileContent` (the only file I/O seam; `Test-Path` then `Get-Content -ErrorAction Stop` twice at 63-64) | 154, 179, 200, 235, 395, 426, 437, 444 |
| 75-104 | `Get-ReviewArtifactPathFromOutput` (token regex at 87) | 383, 417 |
| 106-129 | `Get-ReviewArtifactInfo` (active-folder/timestamp regex at 118) | 389, 419 |
| 131-148 | `Get-ChangedLanguageSet` | 438 |
| 150-169 | `Get-LcovRepoCoverage` | 260, 261 |
| 171-194 | `Get-LcovBranchCoverage` | 223, 224 |
| 196-216 | `Get-JacocoBranchCoverage` (`[xml]` cast at 203) | 225, 226 |
| 218-229 | `Get-LanguageBranchCoverage` | 449 |
| 231-251 | `Get-JacocoRepoCoverage` (`[xml]` cast at 238) | 262, 263 |
| 253-266 | `Get-LanguageRepoCoverage` | 448 |
| 268-343 | `Test-LanguageCoverageRow` (`-LineFloor 85.0`, `-BranchFloor 75.0` defaults at 275-276) | 450 |
| 345-462 | `Invoke-FeatureReviewCoverageValidation -RawPayload` (decision function) | 471 |
| 464-466 | Dot-source guard: `if ($MyInvocation.InvocationName -eq '.') { return }` | n/a |
| 467-477 | Entry point | n/a |

Decision function detail (345-462):

- 351-352: returns `Get-HookDependencyFailureDecision` output when a dependency failed. That object has `ExitCode` and `Reason` (`.claude/hooks/hook-dependency-guard.ps1:104-105`), not `Ok` and `Message`; the shape is pinned by `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1:118-119` (TG3). The entry point checks the same decision first (468-469), so the mismatched shape is unreachable through the entry point.
- 354-363: empty and malformed-JSON checks; messages name `CLAUDE_HOOK_INPUT` (355, 362).
- 365-371: `.output` read: property check at 366, read at 367, empty-output block at 369-371.
- 373-435: required artifact validation (three tokens; folder/timestamp agreement; optional `remediation-inputs-path`).
- 437-441: changed-language detection from `artifacts/pr_context.summary.txt`; no tracked language returns Ok at 440.
- 443-445: `CLAUDE.md` read at 444 and `Get-FeatureReviewCoverageThreshold -ClaudeMdText $claudeMd.Text` at 445.
- 446-459: per-language floor evaluation with `-LineFloor $thresholds.Line -BranchFloor $thresholds.Branch` (450).

Entry point and exits:

| Line | Statement | Code |
|---|---|---|
| 465 | `return` when dot-sourced | none |
| 467 | guard bootstrap failed: stderr reason, `exit 2` | 2 |
| 469 | recorded dependency failure: stderr reason, `exit $dependencyDecision.ExitCode` | 2 (guard returns 2 for SubagentStop) |
| 471 | `Invoke-FeatureReviewCoverageValidation -RawPayload $env:CLAUDE_HOOK_INPUT` | only `CLAUDE_HOOK_INPUT` read |
| 473-474 | `Write-Error $result.Message; exit 1` | effective process exit 1 (Write-Error terminates under EAP Stop before 474) |
| 477 | `exit 0` | 0 |

`$env:CLAUDE_HOOK_INPUT` is read once (471). The literal text `CLAUDE_HOOK_INPUT` also appears at 41, 355, 362. `.output` is read at 366-367 only.

The CR-4 location cited by the review (`lines 50-71 ... used at line 441`, `code-review.2026-10-10T00-44.md:38`) refers to the 471-line version reviewed then; in the current tree the reader is 51-73, the `CLAUDE.md` read is 444, and the threshold call is 445.

### `.claude/hooks/feature-review-coverage-thresholds.ps1` (77 lines)

| Lines | Element |
|---|---|
| 1-16 | File help; states pure string logic and that the hook dot-sources it as `. (Join-Path $PSScriptRoot 'feature-review-coverage-thresholds.ps1')` (15). |
| 18-77 | `Get-FeatureReviewCoverageThreshold -ClaudeMdText` (only function). Caller: `.claude/hooks/validate-feature-review-coverage.ps1:445`. |
| 48 | Defaults `line = 85.0`, `branch = 75.0`. |
| 53-69 | Per-metric loop; empty or `$null` text keeps the default (56). |
| 57 | Regex (below). |
| 58-66 | First match whose figure parses (invariant culture, `NumberStyles.Float`) to 0..100 wins; otherwise the next match is tried; none leaves the default. |
| 71-76 | Returns `Line`, `Branch`, `LineSource`, `BranchSource` (`claude-md` or `default`). |

Line 57 pattern, with `<M>` = `line` or `branch`:

```text
(?im)(?<!\b(?:line|branch)\s*(?:and|or|&|/)\s*)\b<M>\s+coverage\b[^\r\n%]*?(?:>=|U+2265|\bat\s+least\b|\bminimum(?:\s+of)?\b|\bno\s+less\s+than\b)\s*:?\s*(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%
```

Grammar, in order: the metric word, whitespace, the word `coverage`; then any characters on the same line except `%` (lazy); then a comparator from the closed set `>=`, `≥`, `at least`, `minimum`, `minimum of`, `no less than`; optional whitespace and an optional colon; a figure of 1-3 digits with optional decimals, not preceded by a digit or dot; optional whitespace; `%`. Case-insensitive, multiline. The negative lookbehind rejects the metric when it is joined to the other metric by `and`, `or`, `&`, or `/`.

Link between the files: the hook dot-sources the thresholds file at line 47 inside a single-statement try whose catch records `Add-HookDependencyFailure -Name 'feature-review-coverage-thresholds.ps1'`. The guard behavior is pinned by `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` (TG1-TG3, repository copy and bundle mirror).

## Q2. Proposed split (CR-8)

### Repository convention for dot-sourced hook helpers

- Sibling files under `.claude/hooks/`, named after the owning hook with a suffix: `validate-orchestrator-output-resolution.ps1` (dot-sourced at `.claude/hooks/validate-orchestrator-output.ps1:53`), `enforce-epic-merge-gate-resolution.ps1` and `enforce-epic-merge-gate-authorization.ps1` (`enforce-epic-merge-gate.ps1:70,72`), `enforce-parallel-drift-gate-helpers.ps1` (`enforce-parallel-drift-gate.ps1:91`), `enforce-prd-feature-before-planner-helpers.ps1` (`enforce-prd-feature-before-planner.ps1:114`).
- Mechanism: one statement per sibling, `try { . (Join-Path $PSScriptRoot '<file>') } catch { Add-HookDependencyFailure -Name '<file>' -ErrorRecord $_ }`, placed after the guard bootstrap (examples above; current hook line 47). A dot-source inside a dot-sourced script defines functions in the caller's scope, so tests that dot-source the hook still see and can `Mock` every helper function.
- `hook-dependency-guard.ps1` does not keep a list of files (it is a recorder; `.claude/hooks/hook-dependency-guard.ps1:22-46`), so it needs no edit. The dependency-failure suites discover direct edges from the AST of each registered hook (`tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1:18-33`), so each new guarded dot-source automatically gains a B1 row; no list edit is required. The reason-prefix table (`hook-dependency-failure.Claude.Tests.ps1:97`) is keyed by the registered hook and is unchanged if the prefix `validate-feature-review-coverage:` is kept.
- Each new hook file must be added to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (enforced by `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py:139-159`) and mirrored (Q10).

### Proposed files

| File | Functions (current line ranges) | Expected lines |
|---|---|---|
| `.claude/hooks/validate-feature-review-coverage.ps1` (entry, registered) | help (revised; must keep the phrase "falls back independently", required by `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py:91-92`), guard bootstrap, guarded dot-sources of the thresholds file, the two new siblings, and the E1 helper; `Invoke-FeatureReviewCoverageValidation` (345-462, revised to take assistant text; JSON parsing removed; CR-4 handling added); entry point | about 185-200 |
| `.claude/hooks/validate-feature-review-coverage-metrics.ps1` (new) | `Get-ArtifactFileContent` (51-73), `Get-LcovRepoCoverage` (150-169), `Get-LcovBranchCoverage` (171-194), `Get-JacocoBranchCoverage` (196-216), `Get-LanguageBranchCoverage` (218-229), `Get-JacocoRepoCoverage` (231-251), `Get-LanguageRepoCoverage` (253-266) | about 160-170 |
| `.claude/hooks/validate-feature-review-coverage-rules.ps1` (new) | `Get-ReviewArtifactPathFromOutput` (75-104), `Get-ReviewArtifactInfo` (106-129), `Get-ChangedLanguageSet` (131-148), `Test-LanguageCoverageRow` (268-343) | about 170-180 |
| `.claude/hooks/feature-review-coverage-thresholds.ps1` (existing) | `Get-FeatureReviewCoverageThreshold` (+ CR-9 alternative) | about 85-95 |

The split keeps every file at or below about 200 lines, under the 300-line target. A two-file split (entry plus one helper of about 290 lines) also fits but leaves little margin; the three-file split separates I/O-backed metric readers from pure rule logic, matching the separation-of-concerns rule. Function names are unchanged, so existing `Mock Get-ArtifactFileContent`, `Get-ChangedLanguageSet`, `Get-LcovRepoCoverage`, `Get-JacocoRepoCoverage` arrangements in the four Claude suites keep working.

Rejected alternative: moving the readers into a `.psm1` module under `.claude/lib/`. Module scope changes how Pester mocks bind (mocks would need `-ModuleName`), and the hook family uses sibling `.ps1` dot-sources for hook-local helpers.

## Q3. E1 contract consumption

### Contract (epic Shared Design, `docs/features/epics/subagentstop-envelope/epic.md:75-90`)

- Helper `.claude/hooks/subagentstop-envelope.ps1`, dot-sourced by each validator, with a bundled mirror (80-81).
- `Read-SubagentStopEnvelope` reads stdin, parses JSON, returns the envelope with the assistant text from `last_assistant_message`; empty, absent, or malformed stdin behavior is defined by E1 (82-84).
- `Exit-SubagentStopBlock -Message <text>` writes to stderr and exits 2 (85).
- No `CLAUDE_HOOK_INPUT` reads; test seams are parameters on the validator's pure entry point (86-87).
- If E1's measured evidence differs, E1's spec governs and wave-2 plans stop at an upstream-merge check (89-90).

### E1 publication status

- The `git fetch` / `git log` commands requested could not be executed in this research session (no shell tool is available to this agent). Evidence gathered instead, read-only:
  - The local remote-tracking ref `origin/bug/subagentstop-envelope-core-897` resolves to `811a35584855396da45cfa9983e8055cc04258ea`, while `origin/epic/subagentstop-envelope-integration` resolves to `ac525c4efafd7aebaa6cf6bfd658e16a8c2af395` (read from the repository's `refs/remotes/origin/...` files). As of the last local fetch, E1 had therefore published at least one commit beyond `ac525c4ef`; its content could not be listed.
  - The E1 working tree (another agent worktree on `bug/subagentstop-envelope-core-897`) has `docs/features/active/subagentstop-envelope-core-897/spec.md` at template state (Status Draft, Version 0.1, Last Updated 2026-10-11T07-59). E1 has not recorded an authoritative contract.
  - The same working tree contains `docs/features/active/subagentstop-envelope-core-897/evidence/other/subagentstop-live-differential.2026-10-11T12-01.md` (commit status not verified). It records, for Claude Code 2.1.296: payload on stdin; `CLAUDE_HOOK_INPUT` not set in 4 of 4 invocations; no `output` key; `last_assistant_message` present; exit 1 does not block; exit 2 blocks and re-invokes with `stop_hook_active: true` (lines 7-11, 28-32, 59-65). It confirms the epic premise; it also notes that the helper should surface `stop_hook_active` (line 65).
- Conclusion: E1's spec, once merged into `epic/subagentstop-envelope-integration`, governs. The E4 plan must begin with an upstream-merge check that (a) confirms E1 is merged into the integration branch, (b) reads E1's merged spec for the helper file name, function names, returned property names, and empty/malformed-stdin behavior, and (c) stops if any of these differ from the Shared Design.

### Consumption design for the Claude hook

- Add a guarded dot-source: `try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ }`.
- Pure entry point (test seam): `Invoke-FeatureReviewCoverageValidation -AssistantText <string>` replacing `-RawPayload`. It performs no stdin, environment, or JSON work; the empty-text check (current 369-371) remains. Messages that name `CLAUDE_HOOK_INPUT` (355, 362) are removed. The dependency-decision branch (351-352) should return `@{ Ok = $false; Message = $dependencyDecision.Reason }` so the function has a single result shape (TG3 at `ThresholdsGuard.Tests.ps1:101-120` then asserts `Ok`/`Message`).
- Entry point, after the existing guard checks (467-469):

```powershell
try {
    $envelope = Read-SubagentStopEnvelope
    $result = Invoke-FeatureReviewCoverageValidation -AssistantText <assistant-text property defined by E1>
}
catch {
    Exit-SubagentStopBlock -Message "validate-feature-review-coverage: validator error: $($_.Exception.Message); the gate fails closed."
}
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```

  The catch converts every unhandled exception (finding 3 above) into exit 2. If E1's `Read-SubagentStopEnvelope` itself blocks on empty or malformed stdin, the catch remains for decision-function errors.
- Remove `Write-Error` / `exit 1` (473-474) and update help lines 40-42.

## Q4. CR-4 (unreadable root `CLAUDE.md`)

- Spec statement: `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md:122`: "A missing or unreadable root `CLAUDE.md` is treated as "no figures" (defaults apply); the hook does not fail open."
- Review: `code-review.2026-10-10T00-44.md:38` (Minor, "fails closed instead of applying the defaults"; recommends either catching the read or amending the spec) and `code-review.2026-10-10T14-25.md:49` (CR-4 open, deferred).
- Code: `Get-ArtifactFileContent` (51-73) returns `Exists = $false` only when `Test-Path` fails (59-61); an existing but unreadable file makes `Get-Content -ErrorAction Stop` (63-64) throw. The call at 444 is not wrapped, so the exception propagates out of `Invoke-FeatureReviewCoverageValidation` and the process ends with exit 1. Under the measured SubagentStop semantics (Q3), exit 1 does not block, so the current behavior is fail-open in practice, not fail-closed as the review assumed.

Recommendation: change the spec to fail closed, and make the behavior an explicit block.

- Behavior: absent `CLAUDE.md` keeps the defaults (unchanged). An existing `CLAUDE.md` whose read throws returns `@{ Ok = $false; Message = 'feature-review hook: root CLAUDE.md exists but could not be read (<first exception line>); coverage floors cannot be resolved, so the gate fails closed.' }`, which the entry point turns into exit 2 through `Exit-SubagentStopBlock`. Implement with a small reader (for example `Get-FeatureReviewClaudeMdText` in the metrics file) that returns `Text` and `ReadError` instead of throwing. The Codex hook applies the same rule (Q7).
- Rationale:
  - Falling back to defaults is fail-open whenever the consumer's `CLAUDE.md` states a floor stricter than the default (for example 95% line): the gate would silently enforce 85%. Fail-closed is the only choice that never under-enforces.
  - The completion-gate convention in this repository is fail-closed on any unresolved input: the dependency guard exists so "a missing or broken dependency blocks instead of failing open" (`.claude/hooks/hook-dependency-guard.ps1:8-10`), and the general rule requires failing fast with specific errors and not silently ignoring errors (`.claude/rules/general-code-change.md`, Error Handling and Logging).
  - A read failure is rare and actionable; a specific message lets the reviewer fix permissions and re-run.
- Spec alignment: the E4 spec records this contract and states that it supersedes `#824 spec.md:122`. Whether to annotate the #824 spec itself is a decision for the spec author; the #824 folder is another feature's record and E4 can satisfy the issue's expected behavior ("spec and behavior aligned on one choice") through its own spec plus the hook help text.

## Q5. CR-9 (statement forms)

Accepted (figure read; source `claude-md`), from the line 57 grammar and the resolver rows in `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1:28-38`:

- `Line coverage must remain >= 70%.` (T824-3); `Line coverage: >= 70%` (T824-4); `Branch coverage >= 65%` (T824-5)
- `line coverage of at least 82.5%` (T824-6); `Branch coverage minimum: 60%` (T824-10); `Line coverage no less than 72% and branch coverage no less than 61%.` (T824-11)
- by grammar: `line coverage ≥ 80 %`, `line coverage minimum of 80%`, `Line coverage (Pester) >= 80%`

Silently replaced by the default (source `default`, no report):

- comparator after the figure: `line coverage: 70% minimum`, `line coverage of 80% or more`, `line coverage 80% at least`
- figure before the metric: `70% line coverage`
- comparators outside the closed set: `line coverage > 80%`, `line coverage => 80%`, `line coverage must be 80%`
- combined metrics: `Line and branch coverage >= 70%.` (T824-9, documented limitation)
- a `%` between the metric and the comparator: `Line coverage was 62% last release` (T824-8, intended), also `line coverage (currently 60%) >= 80%`
- hyphenated metric: `line-coverage >= 80%`
- out-of-range figure: `Line coverage >= 150%` (T824-7, intended)

Recommendation: accept the figure-before-comparator form, and report the resolved source in every floor message.

- Add a second alternative per metric for a trailing floor phrase on the same line: `\b<M>\s+coverage\b[^\r\n%]*?(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%\s*(?:minimum|at\s+least|or\s+(?:more|higher|above|greater))\b`, keeping the combined-metric lookbehind. The first valid match over both alternatives wins, in text order.
- Include the source in the floor wording of `Test-LanguageCoverageRow` messages, for example `below the 70% line coverage floor (root CLAUDE.md)` or `(default)`, so a reviewer who sees an unexpected default can identify a misread statement.
- Update the resolver help (lines 23-36) to list the accepted forms.
- Rationale: the silent default is fail-open when the consumer states a stricter figure in the trailing form (`line coverage: 95% minimum` resolves to 85%). Reporting unrecognized statements was rejected: it needs a heuristic for "looks like a threshold" with its own false positives, and on the allow path (exit 0) SubagentStop stderr is not shown to the agent, so a report would only be visible on block paths. Documentation alone was rejected because the consumer-facing rule text lives in `.claude/rules/quality-tiers.md`, which must not be modified, and documentation does not remove the fail-open case.
- Tests: new resolver rows for each accepted trailing form, a trailing prose figure that must not be read (`line coverage was 62% last release`), and a combined trailing form that stays default.

## Q6. CR-6 (repeated mock switch)

- `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` (289 lines). F824-1..F824-8 (`It` blocks at 56, 79, 103, 130, 153, 176, 198, 220) each declare `Mock -CommandName Get-ArtifactFileContent -MockWith { param([string]$Path) switch ($Path) { ... } }` with the same three review-artifact entries (policy audit, code review, feature audit), a `default` absent entry, and only one to three differing entries (policy-audit text, `pr_context.summary.txt`, coverage report, `CLAUDE.md`). Payloads come from `ConvertTo-FeatureReviewPayload` (39-52), which builds `{ output = ... }` JSON and must change with the transport anyway.
- Repository precedent for in-file helpers: `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:25-29` defines `Get-ArtifactFileResult` in `BeforeAll`; the Issue824 file itself defines `ConvertTo-FeatureReviewPayload` in `Describe/BeforeAll`.
- Proposed helper (in-file `BeforeAll`, no new module):
  - `Get-ArtifactFileResult -Lines` (as in the Coverage suite) and `Set-ReviewArtifactMap -Override <hashtable>` that sets `$script:ReviewArtifactMap` to the three default review artifacts merged with the overrides (path to text).
  - One mock per Context, in `BeforeEach`: `Mock Get-ArtifactFileContent { param([string] $Path) if ($script:ReviewArtifactMap.ContainsKey($Path)) { Get-ArtifactFileResult -Lines @($script:ReviewArtifactMap[$Path] -split "`n") } else { @{ Exists = $false; Text = $null; Lines = @() } } }`.
  - Each F824 case calls `Set-ReviewArtifactMap -Override @{ 'artifacts/pr_context.summary.txt' = '- src/foo.py (+1/-0)'; 'CLAUDE.md' = '...' }`.
  - Use a literal mock scriptblock reading `$script:` state, not `[scriptblock]::Create`, which stops the coverage tracer (`hook-dependency-failure.Claude.Tests.ps1:137-138`).
  - Replace `ConvertTo-FeatureReviewPayload` with a helper that returns assistant text for `-AssistantText`.
- Existing test files for the Claude hook and thresholds file:
  - `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` (135 lines)
  - `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` (296 lines; entry-point test at 282-295 uses `CLAUDE_HOOK_INPUT`)
  - `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` (289 lines)
  - `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` (121 lines; sets `CLAUDE_HOOK_INPUT` at 36-47 and calls `-RawPayload` at 113)
  - `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` (51 lines)
  - Shared, data-driven: `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1:97`, `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1:54`
  - Contract: `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py:70-92` (step-8 wording of the Claude skill; fallback phrase in hook and skills)

All four hook suites pass JSON with an `output` key into `-RawPayload`, or set `CLAUDE_HOOK_INPUT`; each needs conversion to `-AssistantText` or to a stdin-redirected entry-point call (the stdin pattern is at `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:26-43`).

## Q7. Codex hook transport and floor

### Structure of `.codex/hooks/validate-feature-review-coverage.ps1` (304 lines)

| Lines | Element |
|---|---|
| 1-40 | Help; 22-25 state the 80 percent floor; 33-36 state the transport and continuation semantics. |
| 43 | Guard bootstrap (`hook-dependency-guard.ps1`, byte-identical copy at `.codex/hooks/`). |
| 47-49 | `Get-RepoRoot` (two levels above the hooks folder) |
| 51-61 | `Get-LatestPolicyAudit` (newest `policy-audit.*.md` under `docs/features/active` by `LastWriteTime`) |
| 63-83 | `Get-ChangedLanguageSet -RepoRoot` |
| 85-103 | `Get-LcovRepoCoverage` |
| 105-124 | `Get-JacocoRepoCoverage` |
| 126-140 | `Get-LanguageRepoCoverage -RepoRoot` |
| 142-207 | `Test-LanguageCoverageRow` (fixed floor `80.0` at 196, message at 201) |
| 209-228 | `Get-FeatureReviewCoverageContinuation` (`decision = 'block'` or, when `stop_hook_active`, `continue = $false`) |
| 230-235 | dot-source return; guard exits 2 |
| 237-304 | Inline entry: `[Console]::In.ReadToEnd()` (238); empty and malformed JSON throw (239-246); requires boolean `stop_hook_active` (247-250); requires `hook_event_name == 'SubagentStop'` and `agent_type` in `feature-review`, `feature-reviewer` (251-254); no audit exits 0 (259-262); no changed language exits 0 (267-269); failures emit the continuation JSON on stdout and exit 0 (281-290); catch: when `stop_hook_active` is true emit `continue:false` and exit 0, otherwise stderr reason and exit 2 (294-304). Footer text repeats "below 80%" at 284. |

- Input: one JSON object on stdin (238). It does not read any environment variable or argument, and it does not read `last_assistant_message`; it locates the audit from the filesystem.
- Registration: `.codex/config.toml:245-252` (`[[hooks.SubagentStop]]`, matcher `feature-review|feature-reviewer`, command `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/validate-feature-review-coverage.ps1"`, timeout 30). The general SubagentStop routing hook is at 236-243. Bundle copy: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`.
- Exit semantics: exit 0 with no stdout allows; exit 0 with `{"decision":"block","reason":...}` requests one continuation; exit 0 with `{"continue":false,...}` stops when `stop_hook_active` is already true; exit 2 with stderr for malformed or wrong-event input.
- Fixed floor: lines 23-24 (help), 196 (`-lt 80.0`), 201 (message), 284 (footer).

### Codex hook input contract (public documentation)

`https://developers.openai.com/codex/hooks` redirects (308) to `https://learn.chatgpt.com/docs/hooks`. Fetched 2026-10-11: SubagentStop and Stop receive one JSON object on stdin; SubagentStop fields include `turn_id`, `agent_id`, `agent_type`, `agent_transcript_path`, `stop_hook_active`, `last_assistant_message` (string or null), plus `session_id`, `transcript_path`, `cwd`, `hook_event_name`, `model`, `permission_mode`. Output: JSON on stdout at exit 0; `"decision": "block"` with `"reason"`, or exit 2 with the reason on stderr, continues processing; `continue: false` takes precedence over continuation requests. No in-repo Codex hook documentation describes the SubagentStop envelope beyond the hook help text and `AGENTS.md:313`.

Conclusion: the Codex runtime delivers the same envelope shape (stdin JSON carrying `last_assistant_message` and `stop_hook_active`). The blocking semantics differ: in Codex both `decision:block` and exit 2 request a continuation, and loop control relies on `continue:false` when `stop_hook_active` is true.

### Recommendation: E1 helper and the Codex hook

Do not consume the E1 helper in the Codex hook in this child.

- `Exit-SubagentStopBlock` exits 2 unconditionally (Shared Design line 85). In Codex that is a continuation request without the `stop_hook_active` loop guard the hook already implements (209-228, 294-301).
- The E1 helper lives under `.claude/hooks/`; the Codex bundle publishes only `.codex/` and `.agents/` (`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:35`), so a Codex-only consumer would not have it.
- The Codex hook does not use the assistant text, and adding an assistant-text rule is a new validation rule, which the epic excludes (`epic.md:72-73`).
- The Codex transport is already correct (stdin JSON); #897's transport defect is Claude-only.

### Recommendation: shared floor source for the Codex hook

Add a byte-identical copy `.codex/hooks/feature-review-coverage-thresholds.ps1` of the Claude thresholds file, and have the Codex hook dot-source it from `$PSScriptRoot` with the guarded single-statement pattern.

- Precedent: `feature-folder-resolution.ps1` ("byte-identical in .claude/hooks/ and .codex/hooks/", `.codex/hooks/feature-folder-resolution.ps1:20-21`) with a hash-parity test (`tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1:266-272`), and `hook-dependency-guard.ps1` ("Byte-identical at .claude/hooks, .codex/hooks, and both bundle mirrors", `.codex/hooks/hook-dependency-guard.ps1:19`) with a four-copy hash test (`tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1:133-138`).
- Constraint: no file under `.codex/hooks/` dot-sources a `.claude/` file; the only `.claude/` references are comments or messages (`.codex/hooks/enforce-epic-merge-gate.ps1:359`, `enforce-orchestration-preimplementation-gate.ps1:56`, `feature-folder-resolution.ps1:20`, `hook-dependency-guard.ps1:19`). A cross-surface dot-source would fail in a Codex-only install for the bundle reason above. A shared module path outside both surfaces would need a new virtual resource pair (`scripts/dev_tools/push_down_codex_and_agents_customizations.py:72-90`) and a Claude-side equivalent; that is heavier than one copy plus a parity test.
- Codex hook changes: read `Join-Path (Get-RepoRoot) 'CLAUDE.md'` (absent: defaults; unreadable: fail closed per Q4, through the existing catch: exit 2 or `continue:false`); call `Get-FeatureReviewCoverageThreshold`; pass the line floor into `Test-LanguageCoverageRow` as `-LineFloor` (default 85.0); replace the 80 literals and wording at 23-24, 196, 201, 284. The Codex hook enforces line coverage only; adding a branch check is a new rule and is recorded as an open decision below. Reading `CLAUDE.md` (not `AGENTS.md`) follows the epic indicator "report the same floor for the same CLAUDE.md" (`epic.md:12`).
- Required registrations for the new Codex file: `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (every bundled `.codex/hooks/*` must be listed; `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS` is empty at `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py:90-92`); `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30` (static checks, root/bundle hash identity at 115-118, manifest presence at 139-141). The closure guard `tests/scripts/dev_tools/test_codex_core_manifest_closure.py:53` only recognizes a dot-source on its own line (`^\s*\.\s+\(Join-Path ...\)\s*$`), so it does not follow the guarded `try { . (...) }` form; the manifest entry must be added explicitly and is enforced by the completeness test, not by the closure test.

## Q8. Codex hook test plan

- Existing tests:
  - `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` (199 lines): readers, parsers, dispatcher, `Test-LanguageCoverageRow` (row "below the 80% floor" at 135), continuation shape, and the entry point through a stdin-redirected `&` call (26-43, 158-197).
  - `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:285-296` (continuation contract), plus static checks over `$script:AllHookNames` (22).
  - `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:86` (reason prefix; edges are data-driven).
  - `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1:22-27,158-166` (expects 21 registered hooks and 4 non-PreToolUse exclusions including this hook; no new registration is proposed, so the counts are unaffected).
- Layout: Codex hook tests live in `tests/scripts/codex-hooks/` (mirror of `.codex/hooks/`); precedent for a Codex-copy test of a shared file is `tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1`.
- Coverage population: `config/poshqc-coverage.json:3-9` lists roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`; `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27` derives the population from that file (no `Path` list). The Codex hook is in the set; a new `.codex/hooks/feature-review-coverage-thresholds.ps1` is a separate file in the denominator and is only covered by tests that dot-source that path, so it needs its own test file (`tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1`, a copy of the resolver rows plus a four-copy hash case).
- Seams to keep >= 85%: new `Coverage.Tests.ps1` cases for (a) a `CLAUDE.md` stating a lower line floor that turns a would-be failure into Ok, (b) no figures: default 85 (row message changes from 80 to 85), (c) unreadable `CLAUDE.md` with `stop_hook_active` false (exit 2) and true (`continue:false`), (d) thresholds load failure (covered by the data-driven B1 row). All reads use the existing `Mock Test-Path` / `Get-Content` pattern. The hook grows by roughly 15 lines; extraction into a pure function plus thin entry point is not required (99.29% today with the inline entry), and is optional for consistency with `validate-codex-subagent-routing.ps1:66` (`Invoke-CodexSubagentStopDecision`).
- Running Pester coverage directly (the MCP PoshQC runner may read installed-extension settings, so invoke the in-repo module). Full-population run, as used by the epic-852 evidence (`docs/features/active/epic-852-main-sync/evidence/qa-gates/final-pester-coverage.md:5`):

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1
# Per-file line rates: read <sourcefile> counters for each in-scope file from artifacts/pester/powershell-coverage.xml
```

  Targeted run over the in-scope suites (faster; command coverage per file from the result object):

```powershell
Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop
$c = New-PesterConfiguration
$c.Run.Path = @('tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1','tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1','tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1','tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1','tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1','tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1')
$c.Run.PassThru = $true
$c.CodeCoverage.Enabled = $true
$c.CodeCoverage.Path = @('.claude/hooks/validate-feature-review-coverage.ps1','.claude/hooks/validate-feature-review-coverage-metrics.ps1','.claude/hooks/validate-feature-review-coverage-rules.ps1','.claude/hooks/feature-review-coverage-thresholds.ps1','.codex/hooks/validate-feature-review-coverage.ps1','.codex/hooks/feature-review-coverage-thresholds.ps1')
$c.CodeCoverage.OutputFormat = 'CoverageGutters'
$c.CodeCoverage.OutputPath = '<session scratchpad>/e4-coverage.xml'
$r = Invoke-Pester -Configuration $c
```

  Record the summarized per-file figures under `<FEATURE>/evidence/qa-gates/`; the acceptance figure is the full-population run.

## Q9. Skill and agent texts

Copies of the feature-review-workflow skill: `.claude/skills/feature-review-workflow/SKILL.md` (181 lines), `.agents/skills/feature-review-workflow/SKILL.md` (189), `.github/skills/feature-review-workflow/SKILL.md` (162), and mirrors `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`. No copy exists under `.codex/`. Agent TOML: `.codex/agents/feature-review.toml` (149 lines) and mirror `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml`; `.codex/agents/feature-reviewer*.toml` contain no coverage text (Grep for `coverage` returns no match).

Lines stating a fixed 80 or 90 figure (each mirror carries the same line numbers):

| File | Lines |
|---|---|
| `.claude/skills/feature-review-workflow/SKILL.md` | none (already uses governing thresholds, 111-114, 149) |
| `.agents/skills/feature-review-workflow/SKILL.md` and mirror | 112, 113, 114, 148 |
| `.github/skills/feature-review-workflow/SKILL.md` and mirror | 126 |
| `.codex/agents/feature-review.toml` and mirror | 121, 122, 123, 133, 134, 135 |
| `.codex/hooks/validate-feature-review-coverage.ps1` and mirror | 23, 24, 196, 201, 284 |

Proposed replacement wording (adapt the skill path to the surface: `.agents/skills/quality-tiers/SKILL.md` and `.agents/skills/general-unit-test/SKILL.md` on the Codex surface, `.github/instructions/...` by reference only on the Copilot surface):

- Thresholds block (`.agents` 111-114; TOML 119-123): "Coverage thresholds: when the repository's root `CLAUDE.md` states a line or branch coverage threshold, that threshold governs; otherwise the defaults govern (line 85%, branch 75% for branch-capable languages). Each metric falls back independently. New files and modified files must meet the governing line threshold (and the branch threshold where measured); modified files must also show no regression on changed lines. Repo-wide coverage per language must meet the governing thresholds. Flag as FAIL otherwise."
- Remediation trigger (`.agents` 148; `.github` 126): "coverage below the governing thresholds (repo-wide per language, modified files including any regression on changed lines, or new files)", matching `.claude/skills/feature-review-workflow/SKILL.md:149`.
- TOML verification procedure (133-135): "below the governing line threshold" in place of the 80/90 figures.
- `.github/instructions/` and `.claude/rules/` are not modified. The `.claude` skill already passes `test_push_down_issue_824_follow_ups.py:241-257`; consider extending `STEP_EIGHT_COPIES` (70-73) to the `.agents` and `.github` copies, which then changes `EXPECTED_LISTED_COPY_COUNT` (94) from 36 to 40.

Out of scope, observed: other Codex skills retain 80/90 figures (`.agents/skills/python/SKILL.md:15,87-88`, `typescript/SKILL.md:41-42`, `powershell/SKILL.md:59-60`, `csharp/SKILL.md:37-38`, `*-qa-gate/SKILL.md`, `.claude/skills/csharp-qa-gate/SKILL.md:61`). They are not feature-review texts.

## Q10. Bundled mirrors and parity

| Source | Mirror | Parity enforcement |
|---|---|---|
| `.claude/hooks/validate-feature-review-coverage.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` (text equality over every distributable `.claude` file); ThresholdsGuard TG1-TG3 run the bundle copy |
| new `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `-rules.ps1` | same relative path under `claude-customizations/` | same test; plus Claude `core.json` entries (`test_push_down_claude_pack_manifest_completeness.py:139-159`) |
| `.claude/hooks/feature-review-coverage-thresholds.ps1` | `claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1` | same test; add a four-copy SHA256 case modeled on `hook-dependency-guard.Tests.ps1:133-138` |
| new `.codex/hooks/feature-review-coverage-thresholds.ps1` | `codex-and-agents-customizations/.codex/hooks/feature-review-coverage-thresholds.ps1` | `test_push_down_codex_and_agents_resource_contracts.py:215-228`; `legacy-codex-hook-contracts.Tests.ps1:115-118` (hash) once listed in `SharedModuleNames`; Codex `core.json` entry |
| `.codex/hooks/validate-feature-review-coverage.ps1` | `codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1` | `test_push_down_codex_and_agents_resource_contracts.py:215-228`; `legacy-codex-hook-contracts.Tests.ps1:115-118` |
| `.claude/skills/feature-review-workflow/SKILL.md` | `claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` | `test_push_down_claude_resource_contracts.py:89-110`; `test_push_down_issue_824_follow_ups.py` |
| `.agents/skills/feature-review-workflow/SKILL.md` | `codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md` | `test_push_down_codex_and_agents_resource_contracts.py:215-228` |
| `.codex/agents/feature-review.toml` | `codex-and-agents-customizations/.codex/agents/feature-review.toml` | same |
| `.github/skills/feature-review-workflow/SKILL.md` | `customizations/.github/skills/feature-review-workflow/SKILL.md` | no automated parity test was found for the Copilot bundle; mirror by copy and record SHA256 equality in evidence |

- The Python parity tests compare decoded UTF-8 text (`read_text`), so they confirm content equality; the Pester tests (`legacy-codex-hook-contracts.Tests.ps1:116-117`, `hook-dependency-guard.Tests.ps1:136`) compare SHA256 hashes, which confirms byte identity.
- New files are added to the bundle by copying them to the mirror path (precedent: `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/mirror-log.md:4-6`, `Copy-Item` with source and destination SHA256 recorded) and by adding the repository-relative path to the pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (hook entries at 59, 71) and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (hook entry at 68). `.agents/skills/feature-review-workflow/SKILL.md` and `.codex/agents/feature-review.toml` are listed exceptions in `test_push_down_codex_and_agents_pack_manifest_completeness.py:73,105` and need no manifest change.
- The E1 helper mirror is owned by E1.

## Q11. Baselines

Line counts (Grep line-count query over each file):

| File | Lines |
|---|---|
| `.claude/hooks/validate-feature-review-coverage.ps1` | 477 |
| `.claude/hooks/feature-review-coverage-thresholds.ps1` | 77 |
| `.codex/hooks/validate-feature-review-coverage.ps1` | 304 |
| `.claude/skills/feature-review-workflow/SKILL.md` | 181 |
| `.agents/skills/feature-review-workflow/SKILL.md` | 189 |
| `.github/skills/feature-review-workflow/SKILL.md` | 162 |
| `.codex/agents/feature-review.toml` | 149 |
| `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` | 135 |
| `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` | 296 |
| `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` | 289 |
| `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` | 121 |
| `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` | 51 |
| `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` | 199 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 497 (near the 500-line cap; adding one name to line 30 does not add a line) |

Latest known per-file Pester line coverage:

| File | Coverage | Source |
|---|---|---|
| `.claude/hooks/validate-feature-review-coverage.ps1` | 98.62% (215/218) | `docs/features/active/epic-852-main-sync/evidence/qa-gates/final-pester-coverage.md:20` (2026-10-11T00-40, local full run) |
| `.claude/hooks/feature-review-coverage-thresholds.ps1` | 100.00% (21/21) | same file, line 23 |
| `.codex/hooks/validate-feature-review-coverage.ps1` | 99.29% (140/141) | same file, line 22; also `.../2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-final-pester-coverage.md:228` |

Older figures (superseded): Codex hook 7.30% (10/137) and Claude hook 49.52% (104/210) in `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/issue.md:54-55`; Codex 7.30% in CI 38022356096 per `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/policy-audit.2026-10-10T14-25.md:297`. The E4 plan's baseline task must re-measure on `ac525c4ef` (or on the integration head after the E1 merge) and record the result under `<FEATURE>/evidence/baseline/`.

## Q12. Conflict boundary

- E2 files (`epic.md:54-56,102`): `validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1`. E3 files (`epic.md:57-59,103`): `validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-task-researcher-output.ps1`. E1: `.claude/hooks/subagentstop-envelope.ps1`, `.claude/settings.json`, mirrors.
- E4 in-scope files: the Claude hook and its two new siblings, the Claude and Codex thresholds copies, the Codex hook, the three feature-review-workflow skills, `.codex/agents/feature-review.toml`, their mirrors, both `core.json` manifests, and the E4 test files listed in Q6 and Q8. None overlaps E2, E3, or E1 files. E4 does not edit `.claude/settings.json` (the hook registration at `.claude/settings.json:226-231` is unchanged).
- Shared files E2/E3 may also edit:
  - `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (E2 is planning a split of `validate-orchestrator-output.ps1`, `epic.md:116-117`, which would add an entry). Additions are separate lines; a textual merge conflict is possible if entries are adjacent.
  - `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1:53-58` (`StopPrefix` table includes E2, E3 and E4 hooks) and `hook-dependency-failure.Claude.Tests.ps1:71-102`; E4 needs no edit if it keeps its reason prefix.
  - `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` and `tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1` (shared test support; E4 needs no edit).
  - `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` only if E4 extends `STEP_EIGHT_COPIES`.

## Numeric Derivation Evidence

### N1. Lines stating a fixed 80 or 90 coverage figure in the feature-review skill and agent texts (including mirrors)

- Complete Family: every copy of `feature-review-workflow/SKILL.md` (repository and bundle, all surfaces) and every `.codex/agents/feature-review*.toml` (repository and bundle).
- Exhaustive Search Scope: glob `**/feature-review-workflow/SKILL.md` (6 files) and `**/.codex/agents/feature-review*.toml` (14 files).
- Inclusion Rules: a line that states 80 or 90 as a coverage percentage.
- Exclusion Rules: lines stating 85 or 75; non-coverage numbers.
- Primary Search Strategy or Query Expression: two queries; `\b(80|90|85|75)\b` over the SKILL.md glob (then keep 80/90 lines), and `(>=|<|below|at least)\s*(80|90)\s*%|\b(80|90)%\s*(floor|repo|line)` over agent, skill and prompt globs.
- Primary Member Set: `.agents` SKILL 112, 113, 114, 148 and mirror (8); `.github` SKILL 126 and mirror (2); `feature-review.toml` 121, 122, 123, 133, 134, 135 and mirror (12).
- Primary Count: 22.
- Cross-check Search Strategy or Query Expression: one query `(?:80|90)%` over the combined glob `{**/feature-review-workflow/SKILL.md,**/.codex/agents/feature-review*.toml}`.
- Cross-check Member Set: the same 22 file:line pairs.
- Cross-check Count: 22.
- Member-set Comparison: identical after normalizing to repository-relative path plus line number.

### N2. Fixed-floor lines in `.codex/hooks/validate-feature-review-coverage.ps1`

- Complete Family: lines of the Codex hook that express the 80 floor in prose, message, or comparison.
- Exhaustive Search Scope: the one file (304 lines).
- Inclusion Rules: a line containing the floor value 80 in help, message, or comparison.
- Exclusion Rules: none applicable.
- Primary Search Strategy or Query Expression: `80`.
- Primary Member Set: 23, 24, 196, 201, 284.
- Primary Count: 5.
- Cross-check Search Strategy or Query Expression: union of `percent|floor|%` (prose and messages) and `-(lt|le|gt|ge)\s+[\d.]+` (numeric comparisons, keeping those whose operand is a floor value).
- Cross-check Member Set: {23, 24, 201, 284} union {196} (the other comparison hits 101, 122, 180, 281 compare against 0).
- Cross-check Count: 5.
- Member-set Comparison: identical.

### N3. Functions in `.claude/hooks/validate-feature-review-coverage.ps1`

- Complete Family: function definitions in the file.
- Exhaustive Search Scope: the one file (477 lines).
- Inclusion Rules: a `function <Name>` definition.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: full read of lines 1-477 with manual enumeration.
- Primary Member Set: lines 51, 75, 106, 131, 150, 171, 196, 218, 231, 253, 268, 345.
- Primary Count: 12.
- Cross-check Search Strategy or Query Expression: Grep `^function\s+[\w-]+`.
- Cross-check Member Set: the same 12 lines.
- Cross-check Count: 12.
- Member-set Comparison: identical.

No other numeric acceptance claim is proposed. Line counts in Q11 are single-query measurements recorded as baselines, not acceptance figures; any acceptance criterion should state a cap (for example "<= 300 lines per file") rather than an exact count.

## Testing Implications

- Regression tests first (must fail on the base): (a) the Claude hook, driven through the entry point with a stdin envelope whose `last_assistant_message` lacks the artifact tokens, exits 2 (fails today: reads `CLAUDE_HOOK_INPUT`, exits 1); (b) an unreadable `CLAUDE.md` (mock `Get-Content` to throw for `CLAUDE.md`) yields a structured block message (fails today: unhandled throw); (c) resolver rows for the trailing-floor form (fail today: default); (d) Codex hook row "below the 85% line coverage floor" with no `CLAUDE.md` figures (fails today: 80).
- Convert the four Claude suites from `-RawPayload`/`CLAUDE_HOOK_INPUT` to `-AssistantText` and stdin-redirected entry calls; apply the CR-6 helper in the Issue824 suite.
- Add parity cases: four-copy hash for `feature-review-coverage-thresholds.ps1`; Codex thresholds test file.
- No temporary files: all file content via mocks of `Get-ArtifactFileContent`, `Test-Path`, `Get-Content`; stdin via `[Console]::SetIn` with restore in `finally`.
- Toolchain: PoshQC format, analyze, test (Q8 commands); Python contract tests `tests/scripts/dev_tools/test_push_down_*` for mirrors and manifests; full-population coverage for the acceptance figures.

## Automation Feasibility

Fully automatable. No human interaction is required: the runtime transport has already been measured by E1, all behavior is testable with mocks and stdin redirection, and mirrors and manifests are file copies verified by existing tests. The only gating dependency is sequencing: E1 must be merged into `epic/subagentstop-envelope-integration` before E4 implements the envelope change, which the plan's upstream-merge check enforces. The E4 plan can execute the CR-4, CR-6, CR-8, CR-9, Codex floor, and skill-text work before that check only if the spec author accepts a two-stage plan; otherwise the whole plan waits on E1.

## Open Decisions for the Spec Author

1. Whether the Codex hook also enforces the branch floor (parity with the Claude hook) or only the line floor (current scope; recommended for this child).
2. Whether to annotate the #824 spec (`spec.md:122`) or let the E4 spec supersede it silently.
3. Whether to extend `STEP_EIGHT_COPIES` in `test_push_down_issue_824_follow_ups.py` to the `.agents` and `.github` copies (changes `EXPECTED_LISTED_COPY_COUNT` from 36 to 40).

## Recommendations

1. Begin the plan with an upstream-merge check: E1 merged into the integration branch; read E1's merged spec for helper path, function names, envelope property names, and empty/malformed-stdin behavior; stop on any divergence from the Shared Design.
2. Claude hook transport: dot-source `subagentstop-envelope.ps1` with the guarded pattern; replace `-RawPayload` with `Invoke-FeatureReviewCoverageValidation -AssistantText`; wrap the envelope read and decision call in try/catch that calls `Exit-SubagentStopBlock`; call `Exit-SubagentStopBlock -Message` on every block path; remove `Write-Error`/`exit 1` and all `CLAUDE_HOOK_INPUT` text; normalize the dependency-decision return to `Ok`/`Message`.
3. CR-8: split into `validate-feature-review-coverage.ps1` (entry and decision, about 190 lines), `validate-feature-review-coverage-metrics.ps1` (artifact reader and coverage parsers, about 165), and `validate-feature-review-coverage-rules.ps1` (artifact-path rules, language detection, coverage-row rule, about 175); guarded sibling dot-sources; no guard-file edit; add both new files to the Claude `core.json` and mirror them.
4. CR-4: fail closed. Absent `CLAUDE.md` keeps defaults; an unreadable one returns a specific block message (exit 2). Record the contract in the E4 spec as superseding `#824 spec.md:122`. Apply the same rule in the Codex hook.
5. CR-9: accept the trailing-floor form (`<figure>% minimum|at least|or more|or higher|or above|or greater`) as a second alternative in the resolver, include the threshold source (`root CLAUDE.md` or `default`) in floor messages, and document the accepted forms in the resolver help.
6. CR-6: add `Get-ArtifactFileResult` and `Set-ReviewArtifactMap` in the Issue824 suite's `BeforeAll`, with one literal-scriptblock mock per Context reading `$script:ReviewArtifactMap`.
7. Codex floor: add a byte-identical `.codex/hooks/feature-review-coverage-thresholds.ps1`, dot-source it (guarded), read root `CLAUDE.md`, replace the 80 literals at 23-24, 196, 201, 284 with the governing line floor; keep the Codex stdin and continuation semantics; do not consume the E1 helper. Register the file in the Codex `core.json` and in `legacy-codex-hook-contracts.Tests.ps1:30`; add a four-copy hash test and a Codex-side resolver test file.
8. Skill and agent texts: replace the 22 fixed-figure lines (N1) with governing-threshold wording that names root `CLAUDE.md` and the 85/75 defaults; leave `.github/instructions/` and `.claude/rules/` untouched; mirror each change.
9. Baselines: re-measure per-file coverage before changes (expected about 98.6% Claude hook, 100% thresholds, 99.3% Codex hook) and treat the 7.30% figure as superseded; acceptance remains >= 85% line coverage for every changed or new PowerShell file and <= 500 lines (target <= 300) per production file.
