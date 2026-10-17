# subagentstop-artifact-gates-review-notes-929 (Spec)

- **Issue:** #929
- **Parent (optional):** none (follow-up to epic #904 child E3, issue #905, PR #908)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15
- **Status:** Draft
- **Version:** 0.2

## Context
- Summary of the bug and its impact: the E3 code review (`code-review.2026-10-12T04-58.md` in the E3 feature folder `subagentstop-envelope-artifact-gates-905`, under `docs/features/active/` or `docs/features/archive/`) recorded eleven non-blocking notes on the four artifact-gate SubagentStop validators. This item resolves or explicitly closes NB-1 to NB-5 and NB-7 to NB-11. NB-6 is issue #928. The notes are test gaps (NB-1, NB-3, NB-4, NB-9), two behavioral questions that are closed as by-design or documented-breadth with pinning tests (NB-2, NB-11), and hygiene items (NB-5, NB-7, NB-8, NB-10). Authoritative findings: `docs/features/active/subagentstop-artifact-gates-review-notes-929/research/research.2026-10-15T19-52.md`.
- Observed environment(s): any OS; PowerShell 7 hooks under `.claude/hooks/`; Pester suites under `tests/scripts/claude-hooks/`; observed on `main` at `f6915d42`.
- Customer impact and severity: Low. No runtime gate decision changes. The impact is reduced regression protection for rules R3 and R4 and for validator dispatch, duplicated test support code, one redundant variable in a production hook, and two E3 acceptance criteria whose literal wording does not match their intent.
- First observed date and version(s) impacted: 2026-10-12 (E3 review), on the E3 merge of PR #908.

## Repro & Evidence
- Steps to reproduce: read rows NB-1 to NB-5 and NB-7 to NB-11 of the E3 review file named above. The research file re-verified every cited `file:line` location on 2026-10-15 against the current tree.
- Expected vs actual behavior:
  - NB-1. Expected: every R3 rejection class and every alternation member is pinned by a test. Actual: each suite rejects only `the hooks folder` in the R3 table (`tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1:211-221`, `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:309-319`).
  - NB-2. Expected: the R3 scope check either narrows correctly or its documented breadth is pinned. Actual: the pattern `(?i)\b(entire|whole|all|complete)\b.*\b(repository|repo|worktree|source tree|tree)\b` (`.claude/hooks/validate-prd-feature-output.ps1:51`, `.claude/hooks/validate-task-researcher-output.ps1:202-204`) admits any value in which a quantifier word precedes a noun word, including values that later list a narrower covered set; no test pins this breadth.
  - NB-3. Expected: R4 trim-only tokens are tested. Actual: one unit case (`tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1:344-357`); the E3 spec's lone-backtick example is untested.
  - NB-4. Expected: one shared envelope builder. Actual: `New-SubagentStopEnvelopeJson` is defined in seven suites, each with a `PSUseShouldProcessForStateChangingFunctions` suppression.
  - NB-5. Expected: no redundant locals. Actual: `$agentOutput = $assistantMessage` at `.claude/hooks/validate-task-researcher-output.ps1:244`.
  - NB-7. Expected: E3 AC-20 wording targets envelope `output` reads only. Actual: its case-insensitive `\.output\b` pattern also matches the validator-result `Output` key, which forced the `validatorResult` indexer rename at `.claude/hooks/validate-discovery-artifact-gate.ps1:231-238`.
  - NB-8. Expected: E3 AC-11 wording proves the after-change zero count was recorded before the switch. Actual: the literal wording is satisfied by the commit that added the Before sections.
  - NB-9. Expected: validator dispatch is exercised. Actual: the default declaration reader returns `Present = $false`, so the gate allows before the dispatch loop.
  - NB-10. Expected: per-file coverage counters are reviewable without the gitignored XML. Actual: `artifacts/pester/powershell-coverage.xml` was absent in the review worktree.
  - NB-11. Expected: the in-process dependency-decision return shape is documented and pinned. Actual: `.claude/hooks/validate-task-researcher-output.ps1:239-240` returns the guard's `{ExitCode; Reason}` object while callers read `Ok`/`Message`; no test reaches line 240 in process.
- Logs/screenshots/error snippets: E3 review rows NB-1 to NB-11; research sections 2.1 to 2.11.
- Frequency / determinism: deterministic. All observations are static properties of the tracked source and tests.

## Scope & Non-Goals
- In scope:
  - Test additions for NB-1, NB-2 (characterization), NB-3, NB-9 and NB-11.
  - Extraction of a shared envelope test helper (NB-4) and conversion of the seven suites to it.
  - Removal of the `$agentOutput` alias (NB-5) in `.claude/hooks/validate-task-researcher-output.ps1` and its bundle mirror. This is the only production edit.
  - Dated post-review clarifications under E3 spec AC-20 (NB-7) and AC-11 (NB-8), without changing their checked state.
  - Recording the NB-2, NB-10 and NB-11 decisions in this spec.
- Out of scope / non-goals:
  - NB-6 (unhandled errors exit 1 instead of 2); owned by issue #928.
  - Any change to the R3 regular expression or to R4 trimming.
  - Any change to the return shape of the dependency-decision statement or of `.claude/hooks/hook-dependency-guard.ps1`.
  - The latent `scripts/dev_tools/discovery/profile_cli.py` prefix match in `Get-DiscoveryArtifactType`; it remains the existing E3 out-of-scope follow-up owned by `TODO(#9002)`.
  - Folding `ConvertTo-DiscoveryEnvelopeJson` into the shared helper (optional in research; not adopted).
  - A CI corpus run against the real discovery validator.
  - Skill or agent wording changes for future specs (NB-8 guidance); these would add bundle-mirror and `.github` parity edits.
- Explicitly excluded systems, integrations, or datasets: `.claude/hooks/subagentstop-envelope.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, `.claude/hooks/validate-discovery-artifact-gate.ps1`, `.claude/hooks/validate-pr-author-output.ps1`, `.claude/hooks/hook-dependency-guard.ps1` and their mirrors; `tests/scripts/claude-runtime/` (E1-owned).

## Root Cause Analysis
- Current hypothesis or confirmed root cause (confirmed by the research re-verification):
  - NB-1, NB-3, NB-9: E3 test tables covered one representative value per rule; the corpus run used the default declaration reader, which never reaches dispatch.
  - NB-2: the R3 scope value is a free-text field and the covered family is declared in a different field, so whether an exclusion or a `covers` list narrows the scope below the family is not decidable from the scope value alone (E3 spec Risk 5a).
  - NB-4: each E3 suite received its own copy of the builder with a `New-` verb, which requires the PSScriptAnalyzer suppression.
  - NB-5: a leftover alias from the E3 envelope migration.
  - NB-7, NB-8: E3 AC wording was literal and did not match its intent.
  - NB-10: `/artifacts` is gitignored (`.gitignore:6`), so the XML does not travel with the branch.
  - NB-11: guard-completeness rule S6 (`tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1:109-117`) fixes the decision function's second statement as `if ($null -ne $dependencyDecision) { return $dependencyDecision }`, so the guard object is returned unchanged.
- Signals/evidence supporting it: research sections 2 and 6, including the NB-2 candidate-rule table built from eight tracked research scope values.
- Affected components/modules: `.claude/hooks/validate-task-researcher-output.ps1` and its bundle mirror; the seven E3 Pester suites under `tests/scripts/claude-hooks/`; the E3 `spec.md`.

## Proposed Fix

### Design summary (what changes where):

A test-centric change set with one behavior-preserving production edit.

Recorded decisions (made by the orchestrator; not reopened here):

1. **NB-2: no R3 production rule change.** Every candidate narrowing rule misclassifies a tracked exhaustive scope or leaves the NB-2 example accepted:

   | Candidate rule | Effect on tracked research scope values |
   |---|---|
   | Reject when a whole/entire phrase is followed by `restricted to` or `limited to` | Rejects only the NB-2 example (565); equivalent "whole worktree excluding `docs/`" values (902, 659) stay accepted. The verdict depends on wording, not scope. |
   | Reject when `only` or `covers` follows | Also rejects exhaustive scopes (846:448, 790:357, 902:214). |
   | Require the quantifier to modify the noun directly (adjacency) | Rejects single-file scopes (846:463, 846:478) but still admits the NB-2 example. |
   | Reject `excluding` | Contradicts E3 R3 "Accepts" (``the whole repository excluding `docs/` ``) and pre-R3 behavior. |

   Resolution: the breadth documented in E3 spec Risk 5a is pinned by characterization accept rows in both R3 suites. "Fix NB-2 with tests" in the issue is satisfied by those rows plus this decision.
2. **NB-11: no production change.** The `{ExitCode; Reason}` return is by design under guard-completeness rule S6, following the #896 precedent (`docs/features/active/subagentstop-envelope-feature-review-coverage-896/spec.md:110-111`). The statement is unreachable under `pwsh -File` because the script tail exits first (`.claude/hooks/validate-task-researcher-output.ps1:286-287`); it is reachable only in process. "Fix NB-11 with tests" is satisfied by an in-process test that pins the return.
3. **NB-1:** extend the existing R3 `-ForEach` reject and accept tables in both suites with the research class table values.
4. **NB-3:** add `Find-DiscoveryArtifactReference` unit cases for the lone backtick, the empty-after-trim token, a lone backtick before a reference, and other trim-only tokens before a reference, plus one gate-level case.
5. **NB-4:** create `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` defining `ConvertTo-SubagentStopEnvelopeJson` (adds `-AgentType`, no PSUseShouldProcess suppression); all seven suites dot-source it and drop their local `New-SubagentStopEnvelopeJson`. This is the last implementation phase, to limit conflict with concurrent #928.
6. **NB-5:** remove the `$agentOutput` alias in `.claude/hooks/validate-task-researcher-output.ps1` and in its bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`. This is the only production edit.
7. **NB-7 / NB-8:** append dated post-review clarifications under E3 spec AC-20 and AC-11 (cross-folder documentation edit; checked state unchanged). This spec records the same resolutions (see "Data flow and validation changes") so they survive if the E3 folder is archived.
8. **NB-9:** add deterministic dispatch Pester cases (present-declaration reader, mocked `Invoke-DiscoveryValidatorExe`, distinct-reference dispatch, first-failure short-circuit). The `profile_cli.py` prefix match is excluded from the assertion set.
9. **NB-10:** process only, no code change. The #929 plan records per-file coverage counters verbatim in `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/`.
10. **NB-6** is out of scope (#928).
11. **No regression test can fail first.** Every new test is a characterization test against unchanged behavior, and NB-5 preserves behavior. The plan must not contain an `[expect-fail]` task and must state this instead of inventing a failing test.

### Boundaries and invariants to preserve:
- The R3 regular expression and every validator message string are unchanged. Strings pinned by `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:53-93` stay identical.
- The dependency-decision statements and the S1 tail in all four validators are unchanged (S1 and S6 guard-shape rules).
- `.claude/hooks/validate-task-researcher-output.ps1` remains text-identical to its bundle mirror.
- `.claude/hooks/hook-dependency-guard.ps1` and `.claude/hooks/subagentstop-envelope.ps1` are not edited.
- The envelope JSON produced by the shared helper is identical to the current builders for the same inputs: keys `session_id` (`e3-905`), `hook_event_name` (`SubagentStop`), `agent_type`, `stop_hook_active`, optional `last_assistant_message`, optional `output`; `ConvertTo-Json -Compress`.
- The checked state of E3 AC-11 and AC-20 is unchanged.
- No new or edited file exceeds 500 lines.

### Dependencies or blocked work:
- Issue #928 runs concurrently and edits the SubagentStop validators and `.claude/hooks/subagentstop-envelope.ps1`. The only production overlap candidate is the NB-5 hunk, which conflicts only if #928 wraps the body of `Invoke-TaskResearcherOutputValidation`. Test-side overlap: #928's per-validator exit-2 tests are likely to call `New-SubagentStopEnvelopeJson`. The NB-4 phase runs last, after a rebase on `main`; any call site added by #928 is converted at that point. If #929 merges first, #928 must use the shared helper. The planner must run `git log origin/main --oneline -5 -- .claude/hooks` and `git ls-remote --heads origin '*928*'` before finalizing the plan and record the result.
- The E3 folder may be under `docs/features/active/` or `docs/features/archive/`; the executor resolves the location at execution time.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Created:
- `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` (NB-4)
- `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1` (NB-9) — conditional: created only if adding the NB-9 cases to `validate-discovery-artifact-gate.Tests.ps1` would take that suite above 470 lines; otherwise the NB-9 cases go in `validate-discovery-artifact-gate.Tests.ps1` and this file is not created.

Edited (production; NB-5):
- `.claude/hooks/validate-task-researcher-output.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`

Edited (tests):
- `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` (NB-1, NB-2, NB-4)
- `tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1` (NB-4)
- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` (NB-4)
- `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` (NB-1, NB-2, NB-11, NB-4)
- `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1` (NB-4)
- `tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1` (NB-4)
- `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` (NB-3, NB-4, and NB-9 unless the conditional sibling is created)

Edited (documentation, cross-folder; NB-7, NB-8):
- `docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md` (or `docs/features/archive/subagentstop-envelope-artifact-gates-905/spec.md` if the E3 folder has been archived)

Edited (this feature folder):
- `docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md`
- `docs/features/active/subagentstop-artifact-gates-review-notes-929/plan.<timestamp>.md` (planner output)
- `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/` (new evidence files; NB-10)

#### Functions/classes/CLI commands impacted:
- `Invoke-TaskResearcherOutputValidation` (`.claude/hooks/validate-task-researcher-output.ps1` and mirror): local `$agentOutput` removed; `$assistantMessage` used at the former alias read sites. No signature or message change.
- New test function `ConvertTo-SubagentStopEnvelopeJson` in `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1`.
- Removed test function `New-SubagentStopEnvelopeJson` from each of the seven suites.
- Exercised but unchanged: `Test-NumericDerivationEvidence` (both validators), `Find-DiscoveryArtifactReference`, `Invoke-DiscoveryArtifactGateValidation`, `Invoke-DiscoveryValidatorExe` (mocked), `Add-HookDependencyFailure`, `Get-HookDependencyFailureDecision`.

#### Data flow and validation changes:
- None at runtime. Gate decisions, exit codes and messages are unchanged.
- NB-7 resolution (recorded here and appended under E3 AC-20): the AC-20 pattern `\.output\b` is intended to detect reads of the envelope payload's `output` field. The discovery validator's result object exposes an `Output` key that is read through the hashtable indexer (`$validatorResult['Output']`) per E3 plan RS-2 (`plan.2026-10-11T07-59.md:79`); that read is not an envelope read. No code change.
- NB-8 resolution (recorded here and appended under E3 AC-11): ordering is evaluated against the commit that first records the after-change zero count in the evidence file (the first commit returned by `git log --format=%H --reverse -S 'AFTER-FALSE-POSITIVES: 0' -- <evidence file>`), which must be an ancestor of the switch commit (`git merge-base --is-ancestor <that commit> <switch commit>` exits 0). The E3 plan's `AC11:` lines record this property.
- NB-10 resolution: per-file `sourcefile` LINE counters from the self-hosted PoshQC module's coverage XML are copied verbatim into a #929 `evidence/qa-gates/` artifact for the baseline and the final run.

#### Error handling and logging updates:
- None. NB-11 is closed as by-design; the in-process `{ExitCode; Reason}` return is pinned by a test.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is a revert of the PR. The only production edit preserves behavior.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `ConvertTo-SubagentStopEnvelopeJson` parameters: `[AllowEmptyString()] [string] $AssistantMessage = ''`, `[switch] $OmitAssistantMessage`, `[string] $OutputField`, `[switch] $StopHookActive`, `[string] $AgentType = 'general-purpose'`. Output: compressed JSON string with the key set listed under "Boundaries and invariants". `output` is emitted only when `-OutputField` is bound; `last_assistant_message` is omitted only when `-OmitAssistantMessage` is set. No `SuppressMessageAttribute`. Suites that previously used `prd-feature`, `task-researcher` or `pr-author` pass `-AgentType` with that value.
- Suites load the helper with `. (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')` in the same `BeforeAll` that held the local definition. The file name case must match exactly (Linux CI job).
- NB-1/NB-2 rows use the existing table shape and message assertion of each R3 Context. Values:
  - Reject rows: `those four files on the current worktree.`; `the whole file, lines 1-335.`; `` `.claude/hooks/` ``; `the allocated repository subset`; `the entire subtree`; `the whole worktrees folder`.
  - Accept rows (alternation and E3 examples): `the complete source tree`; `the whole repo`; `ENTIRE WORKTREE`; `entire worktree root.`; ``the whole repository excluding `docs/` ``.
  - Accept rows (NB-2 characterization, commented as the breadth documented in E3 spec Risk 5a): the NB-2 example value from `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/research/research.2026-10-08T14-00.md:323` (quoted verbatim or abridged without removing the `whole worktree` phrase or the `restricted to` / `covers` clauses), and `entire repository excluding docs/**`.

#### Required configuration keys and defaults:
- None. `config/poshqc-coverage.json` and `config/poshqc-scan.json` are unchanged. The new helper is under `tests/`, outside the coverage roots, and is formatted and analyzed by PoshQC but not executed as a test container.

#### Backward-compatibility expectations:
- No public interface changes. `New-SubagentStopEnvelopeJson` was test-local and is not referenced outside the seven suites.

#### Performance constraints (latency/throughput/memory):
- None beyond existing suite runtimes. New tests are in-process and use mocks; no new child processes.

## Assumptions, Constraints, Dependencies
- Assumptions: the research citations remain accurate at execution time; the executor re-checks the NB-5 line numbers and the E3 folder location before editing.
- Constraints: 500-line limit per file (research section 6 projects the largest touched suite, `validate-discovery-artifact-gate.Tests.ps1`, at about 435 lines with NB-9 included); no temporary files in tests; test purity rules in `.claude/hooks/check-powershell-test-purity.ps1` apply to the new helper; enforcement hooks must not invoke Python.
- External dependencies: Pester and PSScriptAnalyzer through PoshQC; GitHub Actions jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`; pytest for the Python contract tests.
- Verification policy: Option A. Local verification uses the PoshQC MCP tools (`Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCTest`) plus CI evidence. MCP results may not carry per-test output, counts or percentages, so no acceptance criterion asserts a count or percentage read from an MCP result. Per-file coverage counters come from the self-hosted module's XML, recorded verbatim.

## Data / API / Config Impact
- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: the production hook remains text-identical to its bundle mirror, enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.

## Test Strategy
- Regression tests to add or update (all characterization; none can fail first):
  - NB-1 and NB-2: new rows in `It 'R3 rejects the exhaustive scope <Name>'` and `It 'R3 accepts the exhaustive scope <Name>'` in Context `Test-NumericDerivationEvidence rule R3 (issue #905)` of `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`, and in Describe `Test-NumericDerivationEvidence rule R3 (issue #905)` of `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1`.
  - NB-3: in Context `Find-DiscoveryArtifactReference rule R4 (issue #905)` of `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`:
    - `It 'R4 returns no reference for a lone backtick token'`
    - `It 'R4 returns no reference for an empty-after-trim token'`
    - `It 'R4 skips a lone backtick token and returns the following discovery reference'`
    - `It 'R4 skips the trim-only token <Name> and returns the discovery reference'` (`-ForEach` over `()`, `[]`, `''`, `,`, `;`)
    - `It 'R4 gate allows a message containing only a lone backtick without invoking the validator'` (present-declaration reader; `Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly`)
  - NB-9: Context `validator dispatch with a present declaration (issue #929)` in `validate-discovery-artifact-gate.Tests.ps1` or, under the 470-line rule, in `validate-discovery-artifact-gate.Dispatch.Tests.ps1`:
    - `It 'dispatches each distinct discovery reference exactly once'` — message with several discovery types, a duplicated reference, backtick-wrapped and trailing-comma references and empty-after-trim tokens; one `Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq '<type>' -and $ValidatorArgs[1] -eq '<path>' }` per distinct reference plus a total-invocation assertion; no `profile_cli.py` reference in the message.
    - `It 'stops at the first failing reference and returns DISCOVERY_ARTIFACT_GATE_BLOCKED'` — mock fails the second distinct reference; asserts `Ok = $false`, a message starting with `DISCOVERY_ARTIFACT_GATE_BLOCKED:`, and no invocation for references after the failing one.
  - NB-11: in `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1`, `It 'returns the guard ExitCode and Reason object in process when a dependency failure is recorded (S6 by design)'` — dot-source the hook, `Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1'`, call `Invoke-TaskResearcherOutputValidation -InputText <envelope>`, assert `ExitCode` equals 2 and `Reason` starts with `validate-task-researcher-output:` and contains `subagentstop-envelope.ps1`; reset `$script:HookDependencyFailures` in `finally`.
  - NB-4 and NB-5: no new tests; existing suites pass after conversion and after the alias removal.
- Unit tests (Pester, not pytest) for the fixed behavior and boundaries: as listed above. Empty-array assertions wrap the call in `@( )` and use `Should -HaveCount 0`. Each NB-3 case asserts `$thrown | Should -BeNullOrEmpty`.
- Edge cases and negative scenarios: word-boundary rejections (`allocated`, `subtree`, `worktrees`), upper-case acceptance, trim-only tokens, duplicated references, first-failure short-circuit, in-process dependency failure.
- Error handling and logging verification: the NB-9 short-circuit case asserts the `DISCOVERY_ARTIFACT_GATE_BLOCKED:` prefix; the NB-11 case asserts the dependency `Reason` prefix.
- Coverage impact and targets: line coverage of `.claude/hooks/validate-task-researcher-output.ps1` must not regress against the baseline (NB-11 adds in-process coverage of line 240; NB-5 removes one line). The repository line threshold (85% default) applies; PowerShell has no branch-coverage gate. Baseline and final `sourcefile` LINE counters are recorded verbatim from the self-hosted module XML.
- Toolchain commands to run (format → lint → type-check → test): `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, (type checking not applicable to PowerShell), `Invoke-PoshQCTest`; then `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`. Registration-driven suites that must stay green: `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`.
- Manual validation steps: none beyond the token checks in the acceptance criteria.

## Acceptance Criteria

NB-1 (R3 rejection and acceptance tables):
- [x] AC-01: `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` `It 'R3 rejects the exhaustive scope <Name>'` includes rows for `those four files on the current worktree.`, `the whole file, lines 1-335.`, `` `.claude/hooks/` ``, `the allocated repository subset`, `the entire subtree` and `the whole worktrees folder`, each asserting `Ok = $false` and the unchanged R3 message; and `It 'R3 accepts the exhaustive scope <Name>'` includes rows for `the complete source tree`, `the whole repo`, `ENTIRE WORKTREE`, `entire worktree root.` and ``the whole repository excluding `docs/` ``; all rows pass.
- [x] AC-02: `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` Describe `Test-NumericDerivationEvidence rule R3 (issue #905)` contains the same reject and accept rows as AC-01 with the task-researcher message prefix; all rows pass.

NB-2 (R3 breadth, no rule change):
- [x] AC-03: both R3 accept tables (the files in AC-01 and AC-02) contain a characterization row for the NB-2 example value and a row for `entire repository excluding docs/**`, each with a comment citing E3 spec Risk 5a; both rows pass.
- [x] AC-04: the R3 pattern string `(?i)\b(entire|whole|all|complete)\b.*\b(repository|repo|worktree|source tree|tree)\b` is present unchanged in `.claude/hooks/validate-prd-feature-output.ps1` and `.claude/hooks/validate-task-researcher-output.ps1` (`git diff main -- .claude/hooks/validate-prd-feature-output.ps1` is empty), and this spec records the NB-2 no-change decision with the candidate-rule table.

NB-3 (R4 trim-only tokens):
- [x] AC-05: Context `Find-DiscoveryArtifactReference rule R4 (issue #905)` in `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` contains passing tests `R4 returns no reference for a lone backtick token`, `R4 returns no reference for an empty-after-trim token`, `R4 skips a lone backtick token and returns the following discovery reference`, and `R4 skips the trim-only token <Name> and returns the discovery reference` with rows for `()`, `[]`, `''`, `,` and `;`.
- [x] AC-06: the same Context contains a passing test `R4 gate allows a message containing only a lone backtick without invoking the validator` that uses a present-declaration reader and asserts `Ok = $true` and `Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly`.

NB-4 (shared envelope helper):
- [x] AC-07: `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` exists, defines `function ConvertTo-SubagentStopEnvelopeJson` with an `AgentType` parameter defaulting to `general-purpose`, and contains no `SuppressMessageAttribute` (`Select-String -Path tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1 -Pattern 'SuppressMessageAttribute'` returns no match).
- [x] AC-08: each of the seven suites `validate-prd-feature-output.Tests.ps1`, `validate-prd-feature-output.Coverage.Tests.ps1`, `validate-task-researcher-output.Tests.ps1`, `validate-task-researcher-output.Coverage.Tests.ps1`, `validate-pr-author-output.Tests.ps1`, `validate-pr-author-output.Coverage.Tests.ps1` and `validate-discovery-artifact-gate.Tests.ps1` under `tests/scripts/claude-hooks/` contains the line fragment `Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1'`, and each suite passes.
- [x] AC-09: `git grep -n "New-SubagentStopEnvelopeJson" -- tests` and `git grep -n "Builds and returns envelope JSON text only" -- tests` each return no match after the final rebase on `main`, including any call site introduced by #928.
- [x] AC-10: the NB-4 conversion is committed after every other implementation commit of this item (verified from `git log --reverse main..HEAD`), and the plan records the #928 sequencing check result.

NB-5 (alias removal; only production edit):
- [x] AC-11: `Select-String -CaseSensitive -Pattern '\$agentOutput\b'` against `.claude/hooks/validate-task-researcher-output.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1` returns no match, and `Invoke-TaskResearcherOutputValidation` reads `$assistantMessage` at the former alias sites.
- [x] AC-12: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` passes.
- [x] AC-13: no other production file changes (`git diff --name-only main...HEAD -- .claude .codex extensions scripts` lists only the two NB-5 paths).

NB-7 and NB-8 (E3 AC wording):
- [x] AC-14: the E3 spec (`subagentstop-envelope-artifact-gates-905/spec.md` under `docs/features/active/` or `docs/features/archive/`) contains, directly beneath AC-20, a line beginning `Post-review clarification (2026-10-15, issue #929):` stating that `\.output\b` targets envelope-payload reads and that the discovery validator result's `Output` key is read through the hashtable indexer per plan RS-2; the AC-20 checkbox state is unchanged.
- [x] AC-15: the same E3 spec contains, directly beneath AC-11, a line beginning `Post-review clarification (2026-10-15, issue #929):` stating the `git log -S 'AFTER-FALSE-POSITIVES: 0'` first-commit and `git merge-base --is-ancestor` ordering rule; the AC-11 checkbox state is unchanged; and this spec records both resolutions under "Data flow and validation changes".

NB-9 (validator dispatch):
- [x] AC-16: Context `validator dispatch with a present declaration (issue #929)` (in `validate-discovery-artifact-gate.Tests.ps1`, or in `validate-discovery-artifact-gate.Dispatch.Tests.ps1` if the 470-line rule applies) contains a passing test `dispatches each distinct discovery reference exactly once` that asserts one `-ParameterFilter` invocation per distinct reference plus the total invocation count, with no `profile_cli.py` reference in the input.
- [x] AC-17: the same Context contains a passing test `stops at the first failing reference and returns DISCOVERY_ARTIFACT_GATE_BLOCKED` that asserts `Ok = $false`, a message starting with `DISCOVERY_ARTIFACT_GATE_BLOCKED:`, and no validator invocation for references after the failing one.

NB-10 (coverage evidence):
- [x] AC-18: an artifact under `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/` records, verbatim from the self-hosted PoshQC module coverage XML, the baseline and final `sourcefile` LINE counter elements for `.claude/hooks/validate-task-researcher-output.ps1`.

NB-11 (dependency-decision shape, by design):
- [x] AC-19: `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` contains a passing test `returns the guard ExitCode and Reason object in process when a dependency failure is recorded (S6 by design)` that calls `Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1'` and `Invoke-TaskResearcherOutputValidation`, asserts `ExitCode` 2 and a `Reason` starting with `validate-task-researcher-output:` that contains `subagentstop-envelope.ps1`, and resets `$script:HookDependencyFailures` in a `finally` block.
- [x] AC-20: the statements `$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-task-researcher-output:'` and `if ($null -ne $dependencyDecision) { return $dependencyDecision }` remain the first two statements of `Invoke-TaskResearcherOutputValidation`, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` passes.

Toolchain and CI:
- [x] AC-21: `Invoke-PoshQCFormat` reports no file reformatted and `Invoke-PoshQCAnalyze` reports no finding for the files in "Files/modules to change" (PoshQC MCP result recorded under `evidence/qa-gates/`).
- [x] AC-22: `Invoke-PoshQCTest` completes with no failed test (PoshQC MCP result recorded under `evidence/qa-gates/`), including `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1`.
- [x] AC-23: line coverage of `.claude/hooks/validate-task-researcher-output.ps1` does not regress: in the counters recorded under AC-18, the final `missed` LINE value is not greater than the baseline `missed` LINE value.
- [x] AC-24: no file created or edited by this item exceeds 500 lines (`(Get-Content <file>).Count` recorded for each PowerShell file in "Files/modules to change").
- [x] AC-25: the plan contains no `[expect-fail]` task and states that every new test is a characterization test against unchanged behavior and that NB-5 preserves behavior.
- [x] AC-26 (CI-dependent): CI job `poshqc / PowerShell QC` concludes `success` on the PR head SHA.
- [x] AC-27 (CI-dependent): CI job `poshqc / PowerShell hook suites (Linux)` concludes `success` on the PR head SHA.

## Risks & Mitigations
- Technical or operational risks:
  - Merge conflict with #928 in the seven suites (NB-4) and, if #928 wraps the function body, in the NB-5 hunk.
  - The conversion could alter envelope JSON for a suite whose `agent_type` differs from the helper default if `-AgentType` is omitted.
  - `validate-discovery-artifact-gate.Tests.ps1` approaches the 500-line limit.
  - The Linux job fails if the dot-source file name case differs from the helper file name.
  - The E3 folder may have moved to `archive/` before execution.
  - NB-2 breadth remains: a research scope value that narrows below the family after a whole-worktree phrase is still accepted. This is documented, not resolved, consistent with E3 Risk 5a.
- Mitigations and rollbacks:
  - NB-4 is the last implementation phase after a rebase on `main`; AC-09 catches unconverted #928 call sites.
  - Pass `-AgentType` explicitly in the prd-feature, task-researcher and pr-author suites; the existing suites verify behavior.
  - Apply the 470-line rule for NB-9 placement; AC-24 checks every touched file.
  - Use the exact case `SubagentStopEnvelope.Helpers.ps1`; AC-27 confirms on Linux.
  - Resolve the E3 folder at execution time; AC-14 and AC-15 accept either location.
  - Rollback is a PR revert; no runtime behavior changes.

## Rollout & Follow-up
- Release/rollout steps: standard PR to `main`; no extension release is required, because the only bundle change (NB-5) preserves behavior. The bundle mirror ships with the next scheduled extension release.
- Post-fix monitoring or clean-up tasks:
  - If a future change revisits NB-2, use the adjacency rule as the least-impact option, gated by a corpus false-positive run using the E3 AC-08 classification method.
  - The `profile_cli.py` prefix match in `Get-DiscoveryArtifactType` remains with `TODO(#9002)`.
  - NB-8 phrasing guidance for future specs may be added to skills or agents in a separate item if requested.
- Links: issue https://github.com/drmoisan/drm-copilot/issues/929; related issue #928 (NB-6); E3 issue #905 and PR #908; epic #904; E4 precedent #896; research `docs/features/active/subagentstop-artifact-gates-review-notes-929/research/research.2026-10-15T19-52.md`; E3 review `code-review.2026-10-12T04-58.md` in `subagentstop-envelope-artifact-gates-905` under `docs/features/active/` or `docs/features/archive/`.
