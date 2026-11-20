# subagentstop-envelope-feature-review-coverage (Spec)

- **Issue:** #896 (Refs #884 Codex half only; Refs #897 feature-review coverage validator only)
- **Parent (optional):** epic subagentstop-envelope (epic issue #904), child E4, integration branch `epic/subagentstop-envelope-integration`
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T08-40
- **Status:** Ready for planning
- **Version:** 1.1 (reconciled with the E1 helper contract and consumer policy; see Proposed Fix item 1)
- **Work Mode:** full-bug (this file is the only acceptance-criteria source; no `user-story.md`)
- **Feature branch:** `bug/subagentstop-envelope-feature-review-coverage-896`
- **Upstream dependency:** E1 (#897, branch `bug/subagentstop-envelope-core-897`, folder `subagentstop-envelope-core-897`)
- **Research:** `docs/features/active/subagentstop-envelope-feature-review-coverage-896/research/research.2026-10-11T08-10.md` (authoritative findings; its `## Recommendations` list is adopted with the decisions recorded in this spec)

## Context
- Summary of the bug and its impact:
  - The Claude feature-review SubagentStop completion gate `.claude/hooks/validate-feature-review-coverage.ps1` does not block at runtime. It reads `$env:CLAUDE_HOOK_INPUT` (line 471), which SubagentStop does not set, parses `.output` (366-367), which the envelope does not carry, and ends a block path with `Write-Error` under `$ErrorActionPreference = 'Stop'` followed by `exit 1` (473-474). The effective process exit is 1, and exit 1 does not block SubagentStop (E1 live differential; PR #881 / #786). Any unhandled exception inside the decision function also ends as exit 1 and is therefore fail-open (research finding 3).
  - Open review findings from #824 / PR #879 remain: CR-4 (unreadable `CLAUDE.md` behavior disagrees with `#824 spec.md:122`), CR-8 (the hook is 477 lines, 23 under the 500-line cap), CR-9 (figure-before-comparator statements such as `line coverage: 70% minimum` silently resolve to the defaults), CR-6 (the `Get-ArtifactFileContent` mock switch is repeated in F824-1..F824-8).
  - The Codex hook `.codex/hooks/validate-feature-review-coverage.ps1` enforces a fixed 80% line floor (lines 23, 24, 196, 201, 284) instead of the root `CLAUDE.md` floor used by the Claude hook, so the same review can pass on one surface and fail on the other. Fixed 80/90 figures also remain in the feature-review-workflow skill copies and `.codex/agents/feature-review.toml` and their mirrors.
- Observed environment(s): PowerShell 7; Claude Code SubagentStop hook (Claude Code 2.1.296 per the E1 live differential); Codex SubagentStop hook registered at `.codex/config.toml:245-252`.
- Customer impact and severity: Medium. The Claude feature-review gate does not enforce its rules at runtime; the Claude and Codex gates enforce different floors; a consumer floor stated in the trailing form, or an unreadable `CLAUDE.md`, can lead to under-enforcement.
- First observed date and version(s) impacted: transport defect present since the hook was introduced; CR findings recorded 2026-10-10 (`code-review.2026-10-10T00-44.md:33-41`, `code-review.2026-10-10T14-25.md:46-54` in the #824 folder). Baseline: `origin/epic/subagentstop-envelope-integration` at `ac525c4ef`.
- Coverage premise correction: the 7.30% Codex hook figure cited in #884 and in the epic is superseded. Recorded measurements are 99.29% (140/141) for the Codex hook, 98.62% (215/218) for the Claude hook, and 100.00% (21/21) for the thresholds file (`docs/features/active/epic-852-main-sync/evidence/qa-gates/final-pester-coverage.md:20-23`). This feature re-measures the baseline before changes rather than planning a coverage campaign.

## Repro & Evidence
- Steps to reproduce:
  1. Invoke `.claude/hooks/validate-feature-review-coverage.ps1` with a SubagentStop envelope on stdin whose `last_assistant_message` lacks the `review-artifact` tokens. Observed: the hook reports a missing-payload error derived from the unset `CLAUDE_HOOK_INPUT` and the process exits 1 (pinned today by `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:292`). Exit 1 does not block.
  2. Simulate a read failure for an existing repository-root `CLAUDE.md` (mock `Get-Content` to throw for that path). Observed: the exception propagates out of `Invoke-FeatureReviewCoverageValidation` (call at line 444 is unwrapped) and the process exits 1.
  3. Resolve thresholds for `line coverage: 70% minimum` with `Get-FeatureReviewCoverageThreshold`. Observed: `Line = 85`, `LineSource = default`.
  4. Read `.codex/hooks/validate-feature-review-coverage.ps1` lines 23, 24, 196, 201, 284 and `.codex/agents/feature-review.toml` lines 121-123, 133-135. Observed: fixed 80/90 figures.
- Expected vs actual behavior: see the Acceptance Criteria; expected behavior is that both hooks resolve the same floor from root `CLAUDE.md`, the Claude hook reads stdin through the E1 helper and blocks with exit 2 on every block path, and unreadable or trailing-form statements cannot silently under-enforce.
- Logs/screenshots/error snippets: E1 differential evidence `docs/features/active/subagentstop-envelope-core-897/evidence/other/subagentstop-live-differential.2026-10-11T12-01.md` lines 7-11, 28-32, 59-65 (payload on stdin; `CLAUDE_HOOK_INPUT` unset in 4 of 4 invocations; no `output` key; `last_assistant_message` present; exit 1 does not block; exit 2 blocks and re-invokes with `stop_hook_active: true`). Commit status of that file is to be confirmed by the upstream-merge check (AC-1).
- Frequency / determinism: deterministic on every invocation.

## Scope & Non-Goals
- In scope:
  - Claude hook transport change to the E1 helper and exit 2 on every block path (#897, this validator only).
  - CR-4, CR-6, CR-8, CR-9 for the Claude hook, its thresholds file, and its test suites.
  - Codex hook floor source (#884 Codex half): root `CLAUDE.md` line floor via a byte-identical thresholds copy; CR-4 rule applied within Codex semantics.
  - Feature-review-workflow skill copies (`.claude`, `.agents`, `.github`) and `.codex/agents/feature-review.toml`, with their bundled mirrors.
  - Claude and Codex `core.json` pack manifests, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` registration, and `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
- Out of scope / non-goals:
  - E2 validators (`validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1`) and E3 validators (`validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-task-researcher-output.ps1`).
  - `.claude/settings.json` (the hook registration at lines 226-231 is unchanged).
  - The E1 helper `.claude/hooks/subagentstop-envelope.ps1` and its bundled mirror.
  - The bash half of #884 (`.claude/lib/bash/compute-concurrency-batches.sh`).
  - A branch-coverage floor in the Codex hook (the Codex hook enforces the line floor only).
  - Consuming the E1 helper from the Codex hook.
  - Any new validation rule beyond the transport, exit-code, and floor-source changes and the listed review notes (no assistant-text rule in the Codex hook).
  - Non-feature-review texts that retain 80/90 figures (`.agents/skills/python/SKILL.md`, `typescript`, `powershell`, `csharp`, `*-qa-gate` skills, `.claude/skills/csharp-qa-gate/SKILL.md:61`).
- Explicitly excluded systems, integrations, or datasets:
  - `.github/instructions/` and `.claude/rules/` are not modified.
  - The #824 feature folder `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/` is not edited.
  - `.codex/config.toml` and its bundle copy are not modified (no new Codex hook registration).

## Root Cause Analysis
- Confirmed root causes:
  - Transport: the Claude hook was written against `CLAUDE_HOOK_INPUT` and an `output` field, neither of which SubagentStop provides, and blocks through `Write-Error`/`exit 1`, which SubagentStop treats as non-blocking.
  - Exception path: no try/catch around the decision call, so every thrown error (unreadable `CLAUDE.md`, unreadable artifact, malformed JaCoCo XML at the `[xml]` casts on lines 203 and 238) ends as exit 1.
  - CR-4: `Get-ArtifactFileContent` (51-73) returns `Exists = $false` only when `Test-Path` fails; an existing but unreadable file throws from `Get-Content -ErrorAction Stop` (63-64). The behavior is fail-open under measured SubagentStop semantics, contrary to both `#824 spec.md:122` and the review's assumption.
  - CR-9: the resolver regex at `.claude/hooks/feature-review-coverage-thresholds.ps1:57` requires the comparator before the figure.
  - Codex floor: the Codex hook was never connected to the shared resolver and carries literal 80 values.
- Signals/evidence supporting it: research Q1, Q3, Q4, Q5, Q7 and Numeric Derivation Evidence N1-N3.
- Affected components/modules: `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`, the feature-review-workflow skill copies, `.codex/agents/feature-review.toml`, their mirrors under `extensions/drm-copilot/resources/`, and the test suites listed in the Test Strategy.

## Proposed Fix

### Design summary (what changes where):
1. Upstream-merge check (Phase 0; first implementation step). E1's spec (`docs/features/active/subagentstop-envelope-core-897/spec.md`) as it stands when E1 merges into `origin/epic/subagentstop-envelope-integration` governs the helper contract and the consumer policy. Where it differs from the epic Shared Design (`docs/features/epics/subagentstop-envelope/epic.md:75-90`), E1's spec takes precedence. This spec was reconciled on 2026-10-11 against E1 branch `bug/subagentstop-envelope-core-897` at head `cc3285559`. The delegating agent reported that commit and supplied the contract text below. The spec author had no shell access, so the commit was not read directly; Phase 0 closes that gap by comparing the spec text itself. The recorded E1 contract is:
   - `Read-SubagentStopEnvelope [-InputText <string>]` never throws and returns an object with `IsValid`, `Anomaly`, `Envelope`, `AssistantText`, `StopHookActive`, `AgentType`, and `HookEventName`. When `-InputText` is not supplied, the helper reads stdin (epic Shared Design line 82).
   - `Get-SubagentStopEnvelopeAnomalyReason` returns the clause that describes the `Anomaly` of an invalid envelope.
   - `Exit-SubagentStopBlock` writes the reason to stderr and exits 2 (`-Message <text>`, epic Shared Design line 85).
   - Consumer rule 1: when `IsValid` is false, the consumer blocks through `Exit-SubagentStopBlock` with `<PREFIX> payload anomaly - <clause>`, where the clause comes from `Get-SubagentStopEnvelopeAnomalyReason`.
   - Consumer rule 2: the `StopHookActive` re-entry policy is set per validator. A condition the subagent can repair (for example a missing path token or file) may block again. A condition the subagent cannot repair uses report-and-halt wording and blocks once.
   - Consumer rule 3: validator pure entry points take `-InputText`, passed through to `Read-SubagentStopEnvelope`, instead of `-RawPayload`.
   - Consumer rule 4: the helper dot-source is guarded in its own single-statement try whose catch calls `Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_`.
   - Consumer rule 5: the existing S1 dependency tail stays inline; `Exit-SubagentStopBlock` replaces only the final validation-failure exit.
   - Consumer rule 6: no `CLAUDE_HOOK_INPUT`.

   Phase 0 confirms that E1 is merged into `origin/epic/subagentstop-envelope-integration`, that `.claude/hooks/subagentstop-envelope.ps1` exists there and defines `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, and `Exit-SubagentStopBlock`, and then compares the merged E1 spec against each recorded item above (AC-1). On any divergence Phase 0 stops and reports. No production change is made until this spec is reconciled again.
2. Claude hook transport (research Recommendation 2; E1 consumer rules 1, 3, 5, 6). Dot-source the E1 helper as described in item 2b. Replace `Invoke-FeatureReviewCoverageValidation -RawPayload` with `Invoke-FeatureReviewCoverageValidation -InputText <string>`, the pure entry point and test seam. `-InputText` is passed through to `Read-SubagentStopEnvelope -InputText`. When the parameter is not bound, the helper is called without it and reads stdin. The function does no stdin, environment, or JSON work of its own. The decision function runs in this order:
   1. The two dependency statements of item 2b.
   2. `Read-SubagentStopEnvelope`.
   3. When `IsValid` is false, return `Ok = $false` with `Message` set to `validate-feature-review-coverage: payload anomaly - ` followed by the clause from `Get-SubagentStopEnvelopeAnomalyReason` for the returned `Anomaly` (rule 1). `StopHookActive` is not consulted for an invalid envelope.
   4. The validation over `AssistantText`, wrapped in try/catch. An unhandled exception becomes the non-repairable result `validate-feature-review-coverage: validator error: <message>; the gate fails closed.` followed by the report-and-halt clause of item 2a.
   5. The re-entry policy of item 2a.

   Every `Message` begins with `validate-feature-review-coverage:`. The entry point keeps the inline S1 dependency tail (item 2b) and calls the decision function without `-InputText`. It exits 0 when `Ok` is true and otherwise calls `Exit-SubagentStopBlock -Message $result.Message`. As a last resort, it also wraps the call in try/catch; the catch calls `Exit-SubagentStopBlock` with the validator-error text. Remove `Write-Error`, `exit 1`, every `CLAUDE_HOOK_INPUT` reference (rule 6), and the JSON/`.output` parsing.
2a. Re-entry policy (E1 consumer rule 2). Each block condition of the Claude hook has one of the following classes:

   | Block condition | Class | Behavior when `StopHookActive` is true |
   |---|---|---|
   | Missing `policy-audit-path`, `code-review-path`, or `feature-audit-path` token; path outside the required `docs/features/active/.../<stem>.<timestamp>.md` location; advertised artifact file absent; folder or timestamp mismatch between artifacts; invalid or absent `remediation-inputs-path` target; empty `AssistantText` | repairable | blocks again |
   | Changed language not mentioned in the policy-audit; no coverage-scoped row; scope-narrowing coverage row; coverage rows with neither PASS nor FAIL | repairable | blocks again |
   | Line coverage below the line floor with no FAIL verdict on a coverage row | repairable | blocks again |
   | Branch coverage below the branch floor | not repairable | does not block |
   | Root `CLAUDE.md` exists but cannot be read (CR-4) | not repairable | does not block |
   | Unhandled exception inside the validation (`validator error`) | not repairable | does not block |
   | Invalid envelope (`IsValid` false) | consumer rule 1 | blocks; `StopHookActive` is not consulted |
   | Guard-bootstrap failure or recorded dependency failure | S1 dependency tail (item 2b) | blocks; unchanged and outside the decision function |

   - Non-repairable messages end with the report-and-halt clause `The subagent cannot repair this condition; report it in the final response and stop.` Repairable messages do not contain `cannot repair this condition`. If E1's merged spec defines a standard report-and-halt phrase, Phase 0 records it and this clause is replaced by that phrase.
   - When `StopHookActive` is true and every collected condition is non-repairable, the decision function returns `Ok = $true` with `Message = $null`, and the entry point exits 0. When any repairable condition is present, the function returns `Ok = $false` with all collected reasons, and the hook blocks again.
   - Rationale for the below-floor classification (research Q1; hook lines 325-340 and 446-459): the hook does not block because coverage is low. It blocks because the policy-audit does not reflect the measured figure.
     - In the line case, the hook blocks only when the audit records no FAIL verdict on a coverage row (325-333). The feature-review subagent can repair this by recording FAIL, so the condition is repairable.
     - In the branch case, the hook blocks whatever verdict the audit records (335-340). The percentage comes from coverage artifacts produced by the toolchain, not from the review text, so a second block cannot lead to a different outcome. The condition is therefore non-repairable.
     - Aligning the branch check with the line check (accepting a recorded FAIL) would change a validation rule. That is outside this feature's scope and is recorded as a follow-up candidate.
2b. Dependency handling (E1 consumer rules 4 and 5).
   - The E1 helper is dot-sourced in its own single-statement try whose catch calls `Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_`, next to the existing guarded dot-sources.
   - The S1 dependency tail of the entry point stays inline and is not routed through `Exit-SubagentStopBlock`. It consists of the guard-bootstrap failure exit and the recorded-dependency-failure exit, which are lines 467-469 in the current tree. `Exit-SubagentStopBlock` replaces only the final validation-failure exit (`Write-Error`/`exit 1` at lines 473-474).
   - The first statement of `Invoke-FeatureReviewCoverageValidation` stays `$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-feature-review-coverage:'`. The second stays exactly `if ($null -ne $dependencyDecision) { return $dependencyDecision }`. Guard-completeness rule S6 requires both (`tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1:114-116`, run by `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`).
   - The dependency-failure return therefore keeps the guard's `ExitCode`/`Reason` shape (`.claude/hooks/hook-dependency-guard.ps1:104-105`), and the earlier plan to normalize it to `Ok`/`Message` is withdrawn. The entry point exits on the same decision first, so this return is not reachable through the entry point.
3. CR-8 three-file split (research Recommendation 3):
   - `.claude/hooks/validate-feature-review-coverage.ps1` (registered entry): help, guard bootstrap, guarded dot-sources (thresholds, metrics, rules, E1 helper), `Invoke-FeatureReviewCoverageValidation`, entry point.
   - `.claude/hooks/validate-feature-review-coverage-metrics.ps1` (new): `Get-ArtifactFileContent`, the CR-4 reader (for example `Get-FeatureReviewClaudeMdText`), `Get-LcovRepoCoverage`, `Get-LcovBranchCoverage`, `Get-JacocoBranchCoverage`, `Get-LanguageBranchCoverage`, `Get-JacocoRepoCoverage`, `Get-LanguageRepoCoverage`.
   - `.claude/hooks/validate-feature-review-coverage-rules.ps1` (new): `Get-ReviewArtifactPathFromOutput`, `Get-ReviewArtifactInfo`, `Get-ChangedLanguageSet`, `Test-LanguageCoverageRow`.
   - Function names are unchanged so existing mocks keep binding. Target <= 300 lines per file; hard limit strictly < 500.
4. CR-4 fail closed (research Recommendation 4). Absent root `CLAUDE.md`: defaults 85 line / 75 branch, source `default`. Present but unreadable: `Ok = $false` with a message naming `root CLAUDE.md`, stating it exists but could not be read, the first exception line, and that the gate fails closed, followed by the report-and-halt clause; the entry point exits 2 through `Exit-SubagentStopBlock`. Under item 2a the condition is non-repairable, so when `StopHookActive` is true the hook does not block a second time. This contract supersedes `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md:122` ("A missing or unreadable root `CLAUDE.md` is treated as "no figures" (defaults apply)"); the #824 folder is not edited. Rationale: falling back to defaults under-enforces whenever the consumer states a stricter floor; the repository completion-gate convention is fail-closed on unresolved input (`.claude/hooks/hook-dependency-guard.ps1:8-10`).
5. CR-9 (research Recommendation 5). Add a second resolver alternative per metric for a trailing floor phrase on the same line, `\b<M>\s+coverage\b[^\r\n%]*?(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%\s*(?:minimum|at\s+least|or\s+(?:more|higher|above|greater))\b`, keeping the combined-metric lookbehind and the 0..100 range check; the first valid match across both alternatives in text order wins. Include the threshold source in floor messages produced by `Test-LanguageCoverageRow` (`(root CLAUDE.md)` or `(default)`). List the accepted forms in the resolver comment-based help.
6. CR-6 (research Recommendation 6). In `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`, define `Get-ArtifactFileResult` and `Set-ReviewArtifactMap -Override <hashtable>` in `BeforeAll`; declare one literal-scriptblock `Get-ArtifactFileContent` mock per Context (in `BeforeEach`) reading `$script:ReviewArtifactMap`; each F824 case calls `Set-ReviewArtifactMap`. Do not use `[scriptblock]::Create`. Make `ConvertTo-FeatureReviewPayload` (or its successor) return SubagentStop envelope JSON text carrying `last_assistant_message` and `stop_hook_active`, for use as `-InputText`.
7. Codex hook (#884 Codex half; research Recommendation 7). Add `.codex/hooks/feature-review-coverage-thresholds.ps1`, byte-identical to `.claude/hooks/feature-review-coverage-thresholds.ps1`, dot-sourced from `$PSScriptRoot` with the guarded pattern. Read `Join-Path (Get-RepoRoot) 'CLAUDE.md'`; absent: defaults; unreadable: fail closed through the existing catch (exit 2 with stderr when `stop_hook_active` is false; `continue:false` on stdout with exit 0 when true). Pass the resolved line floor into `Test-LanguageCoverageRow -LineFloor` (default 85.0); replace the fixed 80 literals and wording at lines 23-24, 196, 201, 284. Enforce the line floor only. Keep the stdin transport and continuation semantics. Do not dot-source `.claude/` files or the E1 helper (Codex exit 2 semantics differ; the Codex bundle does not ship `.claude/hooks/`; research Q7).
8. Skill and agent texts (research Recommendation 8 and Q9). Replace the fixed 80/90 coverage figures (22 lines; research N1) in `.agents/skills/feature-review-workflow/SKILL.md` (112, 113, 114, 148), `.github/skills/feature-review-workflow/SKILL.md` (126), `.codex/agents/feature-review.toml` (121, 122, 123, 133, 134, 135), and their mirrors with wording that names root `CLAUDE.md` as the floor source, states the defaults (line 85%, branch 75% for branch-capable languages), and uses the phrase `governing thresholds`. Extend `STEP_EIGHT_COPIES` in `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` with the `.agents` and `.github` copies and their bundle mirrors, and update `EXPECTED_LISTED_COPY_COUNT` to match.
9. Mirrors. Copy every changed or new file to its bundled mirror under `extensions/drm-copilot/resources/` and register new hook files in the Claude and Codex `core.json` pack manifests.

### Boundaries and invariants to preserve:
- The reason prefix `validate-feature-review-coverage:` is kept so the data-driven dependency-failure suites need no table edit.
- The comment-based help of the Claude hook keeps the phrase `falls back independently` (required by `test_push_down_issue_824_follow_ups.py` `FALLBACK_COPIES`).
- Existing resolver behaviors pinned by T824-3..T824-11 are unchanged (combined-metric statements and out-of-range figures stay `default`; a `%` between the metric and the comparator is not read).
- Codex hook: stdin JSON input, `stop_hook_active` loop control, `decision:block` continuation output, and the 21-hook registration count in `codex-bundle-hook-probe.Tests.ps1` are unchanged.
- No file under `.codex/hooks/` dot-sources a `.claude/` path.
- No Python is added to any hook.

### Dependencies or blocked work:
- E1 (#897) must be merged into `origin/epic/subagentstop-envelope-integration`. E1's spec as it stands at its merge governs the helper contract and the consumer policy (rules 1-6), and takes precedence over the epic Shared Design (`docs/features/epics/subagentstop-envelope/epic.md:75-90`). This spec records that contract as read from E1 branch `bug/subagentstop-envelope-core-897` at head `cc3285559` (Proposed Fix item 1). The E4 Phase 0 upstream-merge check (AC-1) compares the merged E1 spec against those recorded rules and stops on any divergence, or if E1 is not merged.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- Production: `.claude/hooks/validate-feature-review-coverage.ps1`; new `.claude/hooks/validate-feature-review-coverage-metrics.ps1`; new `.claude/hooks/validate-feature-review-coverage-rules.ps1`; `.claude/hooks/feature-review-coverage-thresholds.ps1`; `.codex/hooks/validate-feature-review-coverage.ps1`; new `.codex/hooks/feature-review-coverage-thresholds.ps1`.
- Texts: `.agents/skills/feature-review-workflow/SKILL.md`; `.github/skills/feature-review-workflow/SKILL.md`; `.codex/agents/feature-review.toml`; `.claude/skills/feature-review-workflow/SKILL.md` only if wording alignment is required (it has no fixed figures today).
- Manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- Mirrors: the corresponding paths under `extensions/drm-copilot/resources/claude-customizations/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/`, and `extensions/drm-copilot/resources/customizations/`.
- Tests: `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`, `validate-feature-review-coverage.Coverage.Tests.ps1`, `validate-feature-review-coverage.Issue824.Tests.ps1`, `validate-feature-review-coverage.ThresholdsGuard.Tests.ps1`, `feature-review-coverage-thresholds.Tests.ps1`; `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`; new `tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1`; new `tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1`; `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (`$script:SharedModuleNames` only; the file is at 497 lines and must not exceed 500); `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.

#### Functions/classes/CLI commands impacted:
- `Invoke-FeatureReviewCoverageValidation` (parameter `-RawPayload` replaced by `-InputText`, passed through to `Read-SubagentStopEnvelope`; `Ok`/`Message` result shape on every path after the dependency check; the dependency-failure return keeps the guard's `ExitCode`/`Reason` shape per item 2b; applies the item 2a re-entry policy).
- `Get-FeatureReviewCoverageThreshold` (second alternative; help lists accepted forms).
- `Test-LanguageCoverageRow` in both hooks (Claude: source in floor messages; Codex: `-LineFloor` parameter replaces the literal 80).
- New CR-4 reader in the metrics file returning `Text` and `ReadError` without throwing.
- Consumed from E1: `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, `Exit-SubagentStopBlock`.

#### Data flow and validation changes:
- Claude: stdin envelope text -> `Invoke-FeatureReviewCoverageValidation [-InputText]` -> `Read-SubagentStopEnvelope [-InputText]` -> `IsValid`/`Anomaly`, `AssistantText` (from `last_assistant_message`), `StopHookActive` -> validation and the re-entry policy (item 2a) -> `Ok`/`Message` -> exit 0 or `Exit-SubagentStopBlock` (exit 2).
- Floor resolution (both hooks): root `CLAUDE.md` text -> `Get-FeatureReviewCoverageThreshold` -> `Line`, `Branch`, `LineSource`, `BranchSource`.

#### Error handling and logging updates:
- Claude: every block path, including invalid envelopes, unhandled exceptions, and dependency failures, writes a reason prefixed `validate-feature-review-coverage:` to stderr and exits 2. Dependency failures exit through the inline S1 tail; all other block paths exit through `Exit-SubagentStopBlock`. No `Write-Error` block path and no exit 1. Non-repairable conditions carry the report-and-halt clause and do not block when `StopHookActive` is true (item 2a).
- Codex: unreadable `CLAUDE.md` is handled by the existing catch (exit 2 or `continue:false` according to `stop_hook_active`).

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is a revert of the E4 merge on the integration branch; the E1 helper is unaffected.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Claude hook input: SubagentStop JSON envelope on stdin as defined by E1. Output: exit 0 (allow) or stderr reason with exit 2 (block).
- Codex hook input: one JSON object on stdin (unchanged). Output: unchanged contract (no stdout at exit 0 to allow; `{"decision":"block","reason":...}` at exit 0; `{"continue":false,...}` when `stop_hook_active` is true; stderr with exit 2 for malformed or wrong-event input).
- Floor message format (Claude): includes the floor figure and `(root CLAUDE.md)` or `(default)`.

#### Required configuration keys and defaults:
- Line floor default 85.0; branch floor default 75.0 (Claude only). Accepted `CLAUDE.md` forms: comparator-before-figure (`>=`, `≥`, `at least`, `minimum`, `minimum of`, `no less than`) and trailing-floor (`<figure>% minimum|at least|or more|or higher|or above|or greater`), each on the same line as `<metric> coverage`.

#### Backward-compatibility expectations:
- `-RawPayload` is removed from `Invoke-FeatureReviewCoverageValidation` and replaced by `-InputText` (raw envelope text); all in-repo callers (tests) are updated. No external caller exists.
- Statements accepted before this change resolve to the same figures.

#### Performance constraints (latency/throughput/memory):
- Codex hook timeout is 30 seconds (`.codex/config.toml`); the added `CLAUDE.md` read is a single file read. No other constraint.

## Assumptions, Constraints, Dependencies
- Assumptions: E1's merged spec matches the contract and consumer rules 1-6 recorded in Proposed Fix item 1 (verified by AC-1 before implementation). The Codex SubagentStop envelope shape matches the public documentation fetched 2026-10-11 (research Q7).
- Constraints: no Python in hooks; no production file at or above 500 lines; no temporary files in tests (stdin through `[Console]::SetIn` restored in `finally`; file content through mocks of `Get-ArtifactFileContent`, `Test-Path`, `Get-Content`); regression tests for the transport, CR-4, CR-9, and Codex floor behaviors must fail on the base before the fix.
- External dependencies: E1 helper `.claude/hooks/subagentstop-envelope.ps1`; Pester 5; PoshQC in-repo module.

## Data / API / Config Impact
- User-facing or API changes: the Claude feature-review gate now blocks at runtime; floor messages name the floor source; the Codex gate enforces the root `CLAUDE.md` line floor (85% default) instead of 80%.
- Data or migration considerations: none.
- Logging/telemetry updates: stderr reason text on Claude block paths; no telemetry.
- Compatibility notes: consumers whose `CLAUDE.md` states a floor in the trailing form now have it enforced.

## Test Strategy
- Regression tests to add or update (must fail on base `ac525c4ef` or the post-E1 integration head before the fix):
  - E4-TR1 (Claude transport): entry point driven through a stdin-redirected call with an envelope whose `last_assistant_message` lacks the artifact tokens exits 2.
  - E4-TR4 (CR-4): an existing but unreadable `CLAUDE.md` yields a structured block message.
  - E4-TR5 (CR-9): resolver rows for trailing-floor forms.
  - E4-TR7 (Codex floor): Codex failing-row message cites the 85% line floor when `CLAUDE.md` has no figures.
- Unit tests (Pester; this feature has no pytest unit tests other than the push-down contract tests): see the Acceptance Criteria for the named tests and files.
- Edge cases and negative scenarios: absent vs unreadable `CLAUDE.md`; malformed JaCoCo XML; invalid envelope (`EmptyPayload`, `UnparseableJson`; E4-TR3b); `stop_hook_active` true and false for repairable and non-repairable Claude block conditions (E4-TR10); E1 helper load failure (E4-TG4); combined-metric and prose trailing figures; out-of-range trailing figure; `stop_hook_active` true and false on the Codex unreadable path.
- Error handling and logging verification: stderr reason prefix and exit code asserted for every Claude block path.
- Coverage impact and targets: baseline re-measured before changes; >= 85% line coverage per file for each changed or new PowerShell production file, measured by the full-population PoshQC run.
- Toolchain commands:
  - `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` then PoshQC format, analyze, and `Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (per-file line rates read from `artifacts/pester/powershell-coverage.xml`).
  - `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py`.
- Manual validation steps: none required.

## Acceptance Criteria

Evidence paths below are relative to `docs/features/active/subagentstop-envelope-feature-review-coverage-896/`. `<base>` is the commit of `origin/epic/subagentstop-envelope-integration` recorded by AC-1.

### Upstream dependency
- [x] AC-1: Before any production or test file is changed, `evidence/other/upstream-merge-check.<timestamp>.md` records: the `origin/epic/subagentstop-envelope-integration` commit used as `<base>`; proof that E1 (#897, branch `bug/subagentstop-envelope-core-897`) is merged into it (merge commit SHA or `gh pr view` merged state with merge commit reachable from `<base>`); that `.claude/hooks/subagentstop-envelope.ps1` exists at `<base>` and defines functions named exactly `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, and `Exit-SubagentStopBlock` (recorded `git grep` output); and an item-by-item comparison of E1's merged spec (`docs/features/active/subagentstop-envelope-core-897/spec.md` at `<base>`) against the E1 contract recorded in Proposed Fix item 1. The comparison covers the `Read-SubagentStopEnvelope [-InputText <string>]` signature, its never-throws behavior, and its returned properties `IsValid`, `Anomaly`, `Envelope`, `AssistantText`, `StopHookActive`, `AgentType`, `HookEventName`; `Get-SubagentStopEnvelopeAnomalyReason`; `Exit-SubagentStopBlock -Message`; consumer rules 1-6; and any standard report-and-halt phrase. Each item is marked `match` or `diverges`. The record also includes `git diff cc3285559 <base> -- docs/features/active/subagentstop-envelope-core-897/spec.md` output, or a statement that `cc3285559` is unreachable. If any check fails or any item diverges, the record states `STOP` and no production change is committed on the branch.

### Claude hook transport (#897, this validator)
- [x] AC-2: `.claude/hooks/validate-feature-review-coverage.ps1` and its bundled mirror dot-source `subagentstop-envelope.ps1` through the guarded single-statement pattern (AC-31), and none of the three Claude hook files (entry, `-metrics`, `-rules`) or their mirrors contains the text `CLAUDE_HOOK_INPUT`, a `Write-Error` call, or an `exit 1` statement. Verified by a static Pester test named with `E4-ST1` in `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`, run against the repository copies and the bundle mirrors.
- [x] AC-3: Regression test `E4-TR1` in `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` invokes the Claude hook entry point with a SubagentStop envelope on redirected stdin whose `last_assistant_message` lacks the `review-artifact` tokens, and asserts process exit code 2 and a stderr reason beginning with `validate-feature-review-coverage:`. The test passes on the branch head and its failure on `<base>` is recorded per AC-24.
- [x] AC-4: Every Claude block path exits 2. The following tests in `validate-feature-review-coverage.Coverage.Tests.ps1` pass:
  - `E4-TR2`: the decision returns `Ok = $false` for a valid envelope whose advertised artifact file does not exist.
  - `E4-TR3`: an unhandled exception inside the decision function, for example malformed JaCoCo XML, with `stop_hook_active` false, produces a stderr reason containing `validator error` and exit 2.
  - `E4-TR3b` (E1 consumer rule 1): for at least the `EmptyPayload` and `UnparseableJson` anomalies, the entry point on redirected stdin exits 2 with stderr containing `validate-feature-review-coverage: payload anomaly - ` followed by the clause that `Get-SubagentStopEnvelopeAnomalyReason` returns for that anomaly. For the same inputs, `Invoke-FeatureReviewCoverageValidation -InputText` returns `Ok = $false` with that message.

  The previous assertion of exit 1 at line 292 of that file is removed.
- [x] AC-5: `Invoke-FeatureReviewCoverageValidation` declares an `-InputText` parameter, which it passes through to `Read-SubagentStopEnvelope -InputText`, and declares neither a `-RawPayload` nor an `-AssistantText` parameter (asserted by a test named with `E4-ST2` using `Get-Command ... .Parameters`). It returns an object with `Ok` and `Message` on every path after the dependency check. On a recorded dependency failure it returns the `Get-HookDependencyFailureDecision` object unchanged (`ExitCode = 2` and `Reason`), as AC-31 requires. `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` TG3 continues to assert `ExitCode = 2` and a `Reason` naming `feature-review-coverage-thresholds.ps1`, and TG1-TG3 pass for the repository copy and the bundle mirror.
- [x] AC-6: The four Claude hook suites (`validate-feature-review-coverage.Tests.ps1`, `.Coverage.Tests.ps1`, `.Issue824.Tests.ps1`, `.ThresholdsGuard.Tests.ps1`) contain no `CLAUDE_HOOK_INPUT` text and no `-RawPayload` argument (recorded `git grep` with empty output in `evidence/qa-gates/`), and all four pass.

### CR-4 (unreadable root CLAUDE.md)
- [x] AC-7: A test named with `E4-TR4a` shows that when root `CLAUDE.md` is absent the Claude hook applies line 85 and branch 75 with source `default`; regression test `E4-TR4` shows that when `CLAUDE.md` exists but its read throws, `Invoke-FeatureReviewCoverageValidation` returns `Ok = $false` with a message containing `root CLAUDE.md` and `could not be read`, and the entry point exits 2. Both are in `validate-feature-review-coverage.Coverage.Tests.ps1` or `.Issue824.Tests.ps1`; the failure of `E4-TR4` on `<base>` is recorded per AC-24.
- [x] AC-8: The comment-based help of the Claude hook entry file and of the Codex hook states that an absent root `CLAUDE.md` uses the defaults and an unreadable one fails closed, and the Claude hook help still contains `falls back independently`; verified by a static test named with `E4-ST3` in `validate-feature-review-coverage.Tests.ps1` and by `test_push_down_issue_824_follow_ups.py` passing. This spec's Proposed Fix item 4 records that the contract supersedes `#824 spec.md:122`.

### CR-8 (file split)
- [x] AC-9: `.claude/hooks/validate-feature-review-coverage-metrics.ps1` and `.claude/hooks/validate-feature-review-coverage-rules.ps1` exist, each dot-sourced by the entry file through the guarded pattern, and contain the functions assigned in Proposed Fix item 3 (asserted by a test named with `E4-ST4` that parses each file's AST and compares the defined function names to the assigned lists); both are listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and `test_push_down_claude_pack_manifest_completeness.py` passes.
- [x] AC-10: Every changed or new production file in this feature (the three Claude hook files, both thresholds copies, the Codex hook) is strictly under 500 lines, and the line count of each, together with the 300-line design target, is recorded in `evidence/qa-gates/file-size.<timestamp>.md` from `(Get-Content <path>).Count`.

### CR-9 (statement forms)
- [x] AC-11: Regression rows named with `E4-TR5` in `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` resolve `line coverage: 70% minimum` to 70, and `line coverage 80% at least`, `line coverage of 80% or more`, `branch coverage: 60% or higher`, `line coverage 81% or above`, `branch coverage 62% or greater` to their figures, each with source `claude-md`; negative rows resolve `Line coverage was 62% last release`, `Line and branch coverage: 70% minimum`, and `line coverage: 150% minimum` to the defaults with source `default`; the existing T824-3..T824-11 rows pass unchanged. The failure of the positive rows on `<base>` is recorded per AC-24.
- [x] AC-12: Failing-row messages from the Claude `Test-LanguageCoverageRow` include the floor figure and `(root CLAUDE.md)` when the floor came from `CLAUDE.md` and `(default)` otherwise, asserted for both sources by tests named with `E4-TR6`; the comment-based help of `Get-FeatureReviewCoverageThreshold` names each accepted comparator form from the Technical specifications, asserted by a static test named with `E4-ST5` in `feature-review-coverage-thresholds.Tests.ps1`.

### CR-6 (shared mock helper)
- [x] AC-13: In `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`, `Get-ArtifactFileResult` and `Set-ReviewArtifactMap` are defined in a `BeforeAll` block, no `It` block in F824-1..F824-8 declares its own `Get-ArtifactFileContent` mock, no mock is built with `[scriptblock]::Create`, and F824-1..F824-8 pass. Verified by an AST check named with `E4-ST6` (in `validate-feature-review-coverage.Tests.ps1`) that finds no `Mock` command for `Get-ArtifactFileContent` inside any `It` script block of the Issue824 file.

### Codex hook (#884 Codex half)
- [x] AC-14: `.codex/hooks/feature-review-coverage-thresholds.ps1` exists, and a test named with `E4-PX2` in new `tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1` asserts equal SHA256 hashes for `.claude/hooks/feature-review-coverage-thresholds.ps1`, `.codex/hooks/feature-review-coverage-thresholds.ps1`, and both bundle mirrors (`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/feature-review-coverage-thresholds.ps1`); the same file runs the resolver rows (including the AC-11 rows) against the `.codex/hooks/` copy and they pass.
- [x] AC-15: The Codex hook dot-sources `feature-review-coverage-thresholds.ps1` from `$PSScriptRoot` through the guarded pattern, contains no dot-source of a `.claude/` path, contains no reference to `subagentstop-envelope.ps1` or `Exit-SubagentStopBlock`, and contains no fixed 80 floor (no `80.0`, `80%`, or `80 percent` text); verified by a static test named with `E4-ST7` in `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`.
- [x] AC-16: Tests in `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` show: regression `E4-TR7`, with no coverage figure in `CLAUDE.md`, a 80.5% line row fails with a message citing the 85% line floor; `E4-TR8`, with `CLAUDE.md` stating `Line coverage >= 70%`, a 72% line row passes; `E4-TR9`, with an unreadable `CLAUDE.md`, the entry point exits 2 with a stderr reason when `stop_hook_active` is false, and emits `"continue":false` on stdout with exit 0 when `stop_hook_active` is true. The failure of `E4-TR7` on `<base>` is recorded per AC-24.
- [x] AC-17: The Codex hook's existing transport and continuation contract is preserved: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (including the continuation contract cases), `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`, and `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` pass with the registered-hook counts unchanged, and `git diff --name-only <base>...HEAD -- .codex/config.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` is empty.
- [x] AC-18: `.codex/hooks/feature-review-coverage-thresholds.ps1` is listed in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` and in `$script:SharedModuleNames` of `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`; `test_push_down_codex_and_agents_pack_manifest_completeness.py` and `legacy-codex-hook-contracts.Tests.ps1` pass, and `legacy-codex-hook-contracts.Tests.ps1` remains under 500 lines.
- [x] AC-19: New `tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1` loads each hook in its own isolated scope and, for each `CLAUDE.md` fixture (no figure; `Line coverage >= 70%`; `line coverage: 92% minimum`), asserts that the line floor reported in the Claude and Codex failing-row messages is the same figure (85, 70, 92 respectively); tests named with `E4-PX1` pass.

### Skill and agent texts
- [x] AC-20: A new parametrized test `test_feature_review_texts_name_claude_md_floor_source` in `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`, over the six `feature-review-workflow/SKILL.md` copies (`.claude`, `.agents`, `.github`, and their bundle mirrors) and both `.codex/agents/feature-review.toml` copies (repository and bundle), asserts that each file contains neither `80%` nor `90%`, contains `CLAUDE.md`, and states the defaults `85%` and `75%`; it passes.
- [x] AC-21: `STEP_EIGHT_COPIES` in `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` includes `.agents/skills/feature-review-workflow/SKILL.md`, `.github/skills/feature-review-workflow/SKILL.md`, and their bundle mirrors under `codex-and-agents-customizations/` and `customizations/`; `EXPECTED_LISTED_COPY_COUNT` matches the listed tuples; `test_every_follow_up_copy_exists` and `test_review_workflow_step_eight_uses_governing_thresholds` pass for every listed copy.
- [x] AC-22: `git diff --name-only <base>...HEAD -- .github/instructions .claude/rules` is empty (recorded in `evidence/qa-gates/`).

### Mirrors
- [x] AC-23: Every changed or new file under `.claude/`, `.codex/`, `.agents/`, and `.github/skills/` in this feature has a byte-identical mirror under `extensions/drm-copilot/resources/`: `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` pass, and `evidence/other/mirror-log.<timestamp>.md` records source and mirror SHA256 for every mirrored file, including `.github/skills/feature-review-workflow/SKILL.md`, which has no automated parity test.

### Verification discipline
- [x] AC-24: `evidence/regression-testing/fail-first.<timestamp>.md` records, for `E4-TR1`, `E4-TR4`, the positive `E4-TR5` rows, and `E4-TR7`, a run against `<base>` production files showing each test failing and a run on the branch head showing each passing, with the commands used.
- [x] AC-25: `evidence/baseline/pester-coverage.<timestamp>.md` records per-file line coverage measured on `<base>` before any change for `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1`, and `.codex/hooks/validate-feature-review-coverage.ps1`; `evidence/qa-gates/final-pester-coverage.<timestamp>.md` records the full-population PoshQC run on the branch head showing line coverage >= 85%, measured per file, for each of `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.claude/hooks/validate-feature-review-coverage-rules.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`, and `.codex/hooks/feature-review-coverage-thresholds.ps1`.
- [x] AC-26: Constraint checks recorded in `evidence/qa-gates/constraints.<timestamp>.md` show: (a) no `.py` file is added under `.claude/hooks/` or `.codex/hooks/`, verified from `git diff --name-status origin/epic/subagentstop-envelope-integration -- .claude/hooks/ .codex/hooks/` and `git status --porcelain -- .claude/hooks/ .codex/hooks/` output showing no added or untracked `.py` path; (b) no changed hook file invokes a Python interpreter, verified by `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passing on the branch head (Pester output); (c) the case-insensitive count of the `python` token in the changed files of each hook family (`.claude/hooks/` and `.codex/hooks/`) does not increase relative to `origin/epic/subagentstop-envelope-integration`, verified from `git grep -i -c python` output for both revisions (the token occurs legitimately as data, such as the Python language label and the `artifacts/python/lcov.info` path); no changed or new test file contains `New-TemporaryFile`, `GetTempFileName`, `TestDrive`, or `$env:TEMP` (`git grep` output).
- [x] AC-27: `git diff --name-only <base>...HEAD` contains none of: the E2 and E3 validator files listed in Scope & Non-Goals and their mirrors, `.claude/settings.json`, `.claude/hooks/subagentstop-envelope.ps1` and its mirror, `.claude/lib/bash/compute-concurrency-batches.sh`, or any path under `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/` (recorded in `evidence/qa-gates/`).
- [x] AC-28: The full toolchain passes in a single pass and is recorded in `evidence/qa-gates/`: PoshQC format (no changes), PoshQC analyze (0 errors), the full Pester suite including `hook-dependency-failure.Claude.Tests.ps1` and `hook-dependency-failure.SpecialCases.Tests.ps1`, and the pytest command listed in the Test Strategy.

### Issue closure
- [x] AC-29: The pull request body for this child contains `Refs #884` and `Refs #897`, contains no closing keyword (`close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, `resolved`) adjacent to `#884` or `#897`, and may use a closing keyword for `#896` only; verified from `gh pr view <number> --json body` output recorded in `evidence/issue-updates/`.

### E1 consumer policy (reconciliation with E1)
- [x] AC-30: Re-entry policy (E1 consumer rule 2; Proposed Fix item 2a). Tests named with `E4-TR10` in `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` pass. They drive `Invoke-FeatureReviewCoverageValidation -InputText` with valid envelopes and show the following:
  - (a) Repairable conditions return `Ok = $false` both with `stop_hook_active` false and with it true, and the message does not contain `cannot repair this condition`. The conditions are: a missing `policy-audit-path` token; an advertised artifact file that does not exist; a changed language with no coverage-scoped row; and line coverage below the line floor with no FAIL verdict.
  - (b) Non-repairable conditions return `Ok = $false` with a message containing `cannot repair this condition` when `stop_hook_active` is false, and `Ok = $true` when `stop_hook_active` is true. The conditions are: an existing but unreadable root `CLAUDE.md`; branch coverage below the branch floor; and an unhandled exception inside the validation.
  - (c) When a repairable and a non-repairable coverage condition are both present and `stop_hook_active` is true, the result is `Ok = $false`.
  - (d) Through the entry point on redirected stdin, an unreadable root `CLAUDE.md` exits 2 when `stop_hook_active` is false and exits 0 when it is true.
- [x] AC-31: Dependency handling (E1 consumer rules 4 and 5; Proposed Fix item 2b). In `.claude/hooks/validate-feature-review-coverage.ps1` and its bundle mirror:
  - The dot-source of `subagentstop-envelope.ps1` is in its own single-statement try whose catch calls `Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_`.
  - The entry point's guard-bootstrap and recorded-dependency-failure exits remain inline statements ahead of the decision call and do not call `Exit-SubagentStopBlock`.
  - The first statement of `Invoke-FeatureReviewCoverageValidation` is `$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-feature-review-coverage:'`, and the second is exactly `if ($null -ne $dependencyDecision) { return $dependencyDecision }`.

  Verification:
  - `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` passes with this hook in scope (rules S2 and S6, `tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1:101-116`).
  - A test named with `E4-TG4` in `validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` shows that when `subagentstop-envelope.ps1` fails to load, the entry point exits 2 with a stderr reason beginning with `validate-feature-review-coverage:` and naming `subagentstop-envelope.ps1`. It runs for the repository copy and the bundle mirror.

## Risks & Mitigations
- Technical or operational risks:
  - E1's merged spec may differ from the contract recorded at `cc3285559` (signatures, returned properties, consumer rules 1-6, report-and-halt wording). Mitigation: AC-1 stops implementation until this spec is reconciled again.
  - The re-entry policy allows the second stop for non-repairable conditions, so the gate blocks those conditions once only. Mitigation: the first block carries report-and-halt wording that tells the subagent to surface the condition in its final response (AC-30).
  - Shared manifest `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` may also be edited by E2 (planned split of `validate-orchestrator-output.ps1`). Mitigation: additive, non-adjacent entries; resolve textual conflicts at integration.
  - `legacy-codex-hook-contracts.Tests.ps1` is at 497 lines. Mitigation: add the module name to the existing line 30 list without adding lines (AC-18).
  - Pester mock binding across dot-sourced siblings. Mitigation: sibling `.ps1` dot-sources (not a `.psm1`), so functions land in the caller scope and existing mocks bind.
- Mitigations and rollbacks: revert the E4 merge on the integration branch.

## Rollout & Follow-up
- Release/rollout steps: merge into `epic/subagentstop-envelope-integration`; the integration-to-main PR (epic issue #904) closes #896 and #897 and references #903 and #884.
- Post-fix monitoring or clean-up tasks: optional follow-up for a branch floor in the Codex hook; optional follow-up for the 80/90 figures in non-feature-review Codex skills (research Q9, out of scope); optional follow-up to let a recorded FAIL verdict satisfy the Claude branch-floor check, as the line-floor check already allows (Proposed Fix item 2a).
- Links: issue #896; related #884, #897; epic #904; research `research/research.2026-10-11T08-10.md`; E1 spec `docs/features/active/subagentstop-envelope-core-897/spec.md` (governs at its merge; reconciled against branch head `cc3285559`).
