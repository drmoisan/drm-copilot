# subagentstop-envelope-artifact-gates (Spec)

- **Issue:** #905 (https://github.com/drmoisan/drm-copilot/issues/905), the artifact-gate validators' slice of parent issue #897
- **Parent issue:** #897 (https://github.com/drmoisan/drm-copilot/issues/897), shared with sibling child E1 (`subagentstop-envelope-core-897`)
- **Parent (epic):** epic subagentstop-envelope (epic issue #904), child E3
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T21-00
- **Status:** Draft
- **Version:** 0.5 (adds rule change R4, the empty-token guard in `Find-DiscoveryArtifactReference`, and requires the discovery corpus run to report no `EXCEPTION:` block reason after the change, following executor preflight round 2; 0.4 adds rule change R3 to the `Exhaustive Search Scope` check and mechanical false-positive classification rules for the corpus runs, following executor preflight round 1; 0.3 re-keyed from #897 to #905 and added R1, R2 and the corpus-run gate)
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; `user-story.md` is intentionally absent)
- **Complexity:** C3
- **Branch:** `bug/subagentstop-envelope-artifact-gates-905` (based on `origin/epic/subagentstop-envelope-integration`)
- **Authoritative research:** `docs/features/active/subagentstop-envelope-artifact-gates-905/research/2026-10-11T12-05-subagentstop-envelope-artifact-gates-research.md` (cited below as "research §N") and its addendum `docs/features/active/subagentstop-envelope-artifact-gates-905/research/2026-10-11T10-26-subagentstop-envelope-artifact-gates-addendum-research.md` (cited below as "addendum §N")
- **Helper contract:** `docs/features/active/subagentstop-envelope-core-897/spec.md`, section "Authoritative Helper Contract" (cited below as "E1 contract")

## Context
- Summary of the bug and its impact: the SubagentStop validators `validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1` and `validate-task-researcher-output.ps1` under `.claude/hooks/` read `$env:CLAUDE_HOOK_INPUT`, take an `output` property off the parsed root, and block with exit code 1 (`issue.md:18-23`, `:48-51`; line citations re-derived and confirmed in research §2 and addendum §7). The documented SubagentStop envelope arrives as JSON on stdin and carries `last_assistant_message`, not `output`; `CLAUDE_HOOK_INPUT` is not set; and for SubagentStop only exit code 2 blocks. The validators therefore fail open: they receive no input and their block exit code is ignored by the runtime.
- Two validation rules in these hooks would refuse legitimate work once the hooks block (`issue.md:27`, `:49-50`): the task-researcher research-filename rule (`validate-task-researcher-output.ps1:95-98`) and the prd-feature numeric-criterion rule (`validate-prd-feature-output.ps1:68`). Both are corrected in this change (see Rule Changes). Executor preflight round 1 found a third: the `Exhaustive Search Scope` check in `Test-NumericDerivationEvidence` (`validate-prd-feature-output.ps1:42`, `validate-task-researcher-output.ps1:195-197`) rejects whole-worktree scopes declared by existing research artifacts; it is corrected as R3. Executor preflight round 2 found a fourth: `Find-DiscoveryArtifactReference` (`validate-discovery-artifact-gate.ps1:184`) passes a token that is empty after trimming to `Get-DiscoveryArtifactType`, whose mandatory `-Path` parameter rejects the empty string, so ordinary text containing a token such as `""` or a lone backtick raises an exception that the discovery corpus harness records as a block; it is corrected as R4. Each validator is run against existing artifacts on main with zero false positives before it is switched to exit-2 blocking.
- Observed environment(s): Windows 11 Pro, PowerShell 7.x, Claude Code 2.1.296 (E1 live differential, research §1.2).
- Customer impact and severity: High. These are completion gates for the pr-author, prd-feature, task-researcher and discovery agents. While inert, an agent can report completion without the artifact that proves it (PR reference, `spec-path`, `research-path`, or a valid `discovery/<type>` artifact).
- First observed date and version(s) impacted: recorded in the potential entry `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md` (2026-08-21); re-confirmed against main at `2ef8d361` in the issue #897 update dated 2026-10-11 and carried into issue #905. All versions of these four hooks to date are affected.

## Repro & Evidence
- Steps to reproduce (`issue.md:36-40`):
  1. Pick one of the four E3 validators.
  2. Invoke it with the documented SubagentStop envelope on stdin, whose root carries `hook_event_name` set to the SubagentStop event and `last_assistant_message` set to text lacking the required completion artifact.
  3. Invoke it again with `CLAUDE_HOOK_INPUT` set to a root object carrying `output`.
  4. Compare the two decisions and exit codes.
  5. Run `validate-task-researcher-output.ps1` against existing research files named `research.<timestamp>.md`, and `validate-prd-feature-output.ps1` against existing specs whose acceptance criteria contain thresholds, exit codes or issue numbers.
- Expected vs actual behavior:
  - Expected: step 2 blocks with exit code 2 and writes the block reason to stderr. After the fix only the documented stdin envelope is read; step 3 input is ignored. Step 5 accepts artifacts produced under the repository's documented or established conventions.
  - Actual: each validator ignores stdin, reads `.output` from `CLAUDE_HOOK_INPUT`, and blocks with `exit 1` (or, under `$ErrorActionPreference = 'Stop'`, through a terminating `Write-Error` that also yields exit 1). Exit 1 does not block a SubagentStop event. Step 5 rejects research files not in the `<timestamp>-<short-name>-research.md` form and treats any digit in an acceptance-criterion line as a numeric criterion that requires derivation evidence.
- Logs/screenshots/error snippets (E1 live differential, `docs/features/active/subagentstop-envelope-core-897/evidence/other/subagentstop-live-differential.2026-10-11T12-01.md`, summarized in research §1.2 and restated in the E1 contract):
  - Payload arrived as JSON on stdin; `CLAUDE_HOOK_INPUT` was not set in any invocation.
  - Root carried `last_assistant_message`; no `output` key.
  - Exit 1 did not block; exit 2 blocked and the subagent was re-invoked with `stop_hook_active: true`.
- Current per-file sites (research §2, re-derived in addendum §7):

  | File | Reads `.output` | Passes `$env:CLAUDE_HOOK_INPUT` | Validation block tail |
  |---|---|---|---|
  | `validate-discovery-artifact-gate.ps1` | `:223-224` | `:258` | `Write-Error` `:260`, `exit 1` `:261` |
  | `validate-pr-author-output.ps1` | `:109` | `:135` | `Write-Error` `:138`, `exit 1` `:139` |
  | `validate-prd-feature-output.ps1` | `:80` | `:95` | `Write-Error; exit 1` `:96` (terminating under `:11`) |
  | `validate-task-researcher-output.ps1` | `:245-246` | `:288` | `Write-Error` `:290` (terminating under `:24`), `exit 1` `:291` |

- Frequency / determinism: always. The transport and exit-code defect is not data-dependent; the two rule defects are deterministic for the artifact forms described in Rule Changes.

## Scope & Non-Goals
- In scope:
  - Convert `.claude/hooks/validate-discovery-artifact-gate.ps1`, `.claude/hooks/validate-pr-author-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1` and `.claude/hooks/validate-task-researcher-output.ps1` to the E1 helper: read the envelope via `Read-SubagentStopEnvelope`, inspect `AssistantText` (the root `last_assistant_message`) instead of `.output`, and block via `Exit-SubagentStopBlock` (stderr plus exit 2) on every validation block path.
  - Rule change R1: replace the task-researcher accepted-filename rule (`validate-task-researcher-output.ps1:95-98`) as specified in Rule Changes.
  - Rule change R2: replace the prd-feature numeric-criterion rule (`validate-prd-feature-output.ps1:68`) as specified in Rule Changes.
  - Rule change R3: widen the `Exhaustive Search Scope` pattern in `Test-NumericDerivationEvidence` in both `validate-prd-feature-output.ps1` (`:42`) and `validate-task-researcher-output.ps1` (`:195`) as specified in Rule Changes.
  - Rule change R4: skip a token that is empty after trimming in `Find-DiscoveryArtifactReference` (`validate-discovery-artifact-gate.ps1:184`) as specified in Rule Changes.
  - A false-positive corpus run of each of the four validators against existing artifacts on main (or the substitute corpus where no tracked corpus exists), recorded before and after the change, with zero false positives required before that validator is switched to exit-2 blocking.
  - Remove every `CLAUDE_HOOK_INPUT` read and literal (code, help text, messages) from these four files.
  - Move test seams to parameters on each validator's pure entry function (`-InputText`, per E1 contract consumer policy item 3); no environment-variable seams.
  - Add the #786 dependency-guard pattern (bootstrap, guarded edge, three-statement tail, leading dependency-decision statement) to `validate-task-researcher-output.ps1`, which lacks it (research §2.4, §6.2 item 4), so that a helper load failure blocks with exit 2.
  - Update every Pester suite for these four hooks: `validate-discovery-artifact-gate.Tests.ps1`, `validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1`, `validate-pr-author-output.Tests.ps1`, `validate-pr-author-output.Coverage.Tests.ps1`, `validate-prd-feature-output.Tests.ps1`, `validate-prd-feature-output.Coverage.Tests.ps1`, `validate-task-researcher-output.Tests.ps1`, all under `tests/scripts/claude-hooks/`; and add `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` for the task-researcher entry point (research §3, §6.3). Rule-change tests are placed in whichever suite keeps every file at or under 500 lines.
  - Copy each changed hook byte-for-byte into its bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. No test mirrors exist under `extensions/drm-copilot/resources/` (research §3), so none are created.
  - Check the agent frontmatter registrations in `.claude/agents/pr-author.md:23-27` and `.claude/agents/task-researcher.md:14-19`. No change is expected because `pwsh -NoProfile -File <path>` passes stdin to the script (research §4.1).
- Out of scope / non-goals:
  - E1 files: `.claude/hooks/subagentstop-envelope.ps1`, its mirror and tests; `.claude/settings.json` and its bundled copy; pack manifests (research §7).
  - E2 files: `validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, any orchestrator routing helper, `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1`, their suites and their mirrors; and the `.claude/agents/prd-feature.md` registration fix (including its bundled copy). The prd-feature hook is registered at `.claude/agents/prd-feature.md:20`; E3 changes the hook script, not that registration.
  - E4 files: `validate-feature-review-coverage.ps1`, `feature-review-coverage-thresholds.ps1`, the feature-review skills, `.codex/agents/feature-review.toml`, and their mirrors.
  - Any validation rule change other than R1, R2, R3 and R4. In particular, `Test-NumericDerivationEvidence` changes only by R3 (the `Exhaustive Search Scope` pattern, in both hooks); its numeric-claim trigger, section heading match, required labels, narrow-strategy, repeated-strategy, family-coverage, numeric-count, count-versus-member-set, member-set agreement and member-set comparison checks, and all of its message strings, are unchanged. `Find-DiscoveryArtifactReference` changes only by R4 (the empty-after-trim guard on line 184); its tokenization, trim character set, de-duplication and return type are unchanged. `Test-AutomationFeasibilitySection`, `Test-IsUnderResearchRoot`, `Get-DiscoveryArtifactType`, the PR detection patterns and the discovery artifact validation are unchanged.
  - Policy files: `.claude/rules/**`, `.github/instructions/**`, `.github/copilot-instructions.md` are not edited (see Rule Changes, "Policy-file impact"). The writer-facing agent definitions `.claude/agents/prd-feature.md` and `.claude/agents/task-researcher.md` are not edited for any rule change.
  - Renaming existing research files or editing existing specs to fit either rule.
  - PreToolUse hooks (converted by #501).
  - Shared test infrastructure owned by E1: `tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1`, `HookDependencyGraph.Helpers.ps1`, `HookImportFailureExemptions.Helpers.ps1`; any SubagentStop source-scanning guard analogous to #501's (research §7).
  - Deduplicating the double registration of pr-author and prd-feature (settings plus frontmatter); E1 owns settings (research §4.1, §9 item 8).
- Explicitly excluded systems, integrations, or datasets: Codex runtime (`.codex/` holds no equivalents of these four hooks, research §4.1); Python hooks or Python legs in any enforcement hook.

## Root Cause Analysis
- Confirmed root cause (transport): the validators were written against an undocumented envelope. They read `$env:CLAUDE_HOOK_INPUT` (not provided for SubagentStop), parse an `output` field (the documented field is `last_assistant_message`), and block with exit 1 (only exit 2 blocks SubagentStop).
- Confirmed root cause (rules): R1's current regex accepts only the documented form, while the repository has produced research files under several other stamped forms (addendum §2). R2's current pattern `\b\d+\b` treats any standalone digit run in an acceptance-criterion checkbox line as a numeric criterion, which is broader than the documented intent "a numeric count, enumeration, or population" (`.claude/agents/prd-feature.md:32`; addendum §4). R3's current pattern `(?i)\b(entire|all|complete)\b.*\b(repository|repo|source tree|tree)\b` is narrower than the documented requirement that the scope be exhaustive (`.claude/agents/prd-feature.md:32`, `.claude/agents/task-researcher.md:67`): `\btree\b` does not match inside `worktree`, and `whole` is not in the quantifier alternation.
- Signals/evidence supporting it:
  - E1 live differential (research §1.2; E1 contract): stdin JSON, no `CLAUDE_HOOK_INPUT`, `last_assistant_message` present, `output` absent, exit 1 non-blocking, exit 2 blocking.
  - PR #881 (#786) established exit 2 as the SubagentStop block code and left the exit-1 validation paths unchanged (research §5.2).
  - Pester suites pin the defective behavior: `validate-discovery-artifact-gate.Tests.ps1:165` and `validate-pr-author-output.Tests.ps1:110`, `:121` assert `$LASTEXITCODE | Should -Be 1`; `validate-pr-author-output.Coverage.Tests.ps1:43` asserts `ExitCode | Should -Be 1`; `validate-prd-feature-output.Coverage.Tests.ps1:43-44` asserts a thrown `CLAUDE_HOOK_INPUT is empty` error (research §3).
  - The pre-revision version 0.2 of this spec triggered the current R2 pattern through exit codes and thresholds alone (its lines 190 and 206; addendum §4), with no population count.
- Affected components/modules: the four hook files and their mirrors; the Pester suites listed in Scope; registration-driven suites B1 (`hook-dependency-failure.Claude.Tests.ps1`), C8 (`hook-dependency-failure.SpecialCases.Tests.ps1`) and S1/S2/S3/S6 (`hook-dependency-guard-completeness.Tests.ps1`), which pick up the new helper edge automatically (research §3).
- Contributing latent defects (research §2.3-§2.5):
  - In `validate-prd-feature-output.ps1` and `validate-task-researcher-output.ps1`, `$ErrorActionPreference = 'Stop'` makes `Write-Error` terminating, so the `exit 1` line is unreachable and any `Get-Content` exception exits non-blocking.
  - The decision functions of the three guarded hooks return the guard's `{ ExitCode; Reason }` object where callers expect `Ok`/`allowed` and `Message`/`reason`; unreachable today because the script tail checks the dependency decision first.

## Proposed Fix

### Design summary (what changes where):
Research §6.1 candidate A, aligned to the E1 contract. Each of the four hooks dot-sources the E1 helper `.claude/hooks/subagentstop-envelope.ps1` as a guarded dependency edge (E1 contract consumer policy item 4). Each pure entry function keeps its name and its leading dependency-decision statements and takes `-InputText` (passed through to `Read-SubagentStopEnvelope -InputText`) instead of raw JSON from `CLAUDE_HOOK_INPUT`. Each script tail becomes: guard bootstrap check (unchanged), dependency tail (unchanged), pure call without `-InputText` so the helper reads stdin, then `Exit-SubagentStopBlock -Message <reason>` on block or `exit 0` on allow. Rule changes R1 and R2 replace one regex each; R3 replaces the same regex in both copies of `Test-NumericDerivationEvidence`; R4 adds an empty-token guard to one condition in `Find-DiscoveryArtifactReference` (see Rule Changes). Candidates B (inline stdin parsing) and C (reuse `Read-ClaudeHookRawPayload`, which falls back to `CLAUDE_HOOK_INPUT`) are rejected (research §6.1).

### Boundaries and invariants to preserve:
- The #786 guard shape: the bootstrap flag check writes via `[Console]::Error.WriteLine(` and contains a literal `exit 2`; each edge is in its own single-statement `try` whose catch calls `Add-HookDependencyFailure -Name '<leaf>'`; the SubagentStop tail contains `exit $dependencyDecision.ExitCode`; the decision function begins with the dependency-decision assignment and return (S1, S2, S6; research §3; E1 contract consumer policy item 5).
- Existing reason tokens and prefixes: `PR_AUTHOR_OUTPUT_MISSING`, `PR_AUTHOR_OUTPUT_MALFORMED`, `PR_AUTHOR_OUTPUT_EMPTY`, `PR_AUTHOR_OUTPUT_NO_PR`, `DISCOVERY_ARTIFACT_GATE_BLOCKED:`, and the `validate-<name>:` dependency prefixes in the B1/C8 prefix tables (research §6.2).
- Message strings pinned by `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:60-93`: "narrow named-pattern", "repeats the primary search strategy or query expression", "count does not match its independently enumerated member set", "numeric acceptance criterion requires an existing research-path" (research §3).
- Discovery gate allow semantics for a valid envelope: blank assistant text, no `discovery/<type>` references, or an absent required-artifact declaration all allow, because the hook runs for every agent under the broad matcher (`.claude/settings.json:214`; research §6.2 item 1, §9 item 7).
- Validation rules other than R1, R2, R3 and R4 (PR detection patterns, discovery reference tokenization other than the R4 empty-token guard, `spec-path`/`research-path` extraction, research root check, every numeric derivation evidence check other than the `Exhaustive Search Scope` pattern, Automation Feasibility check, discovery artifact validation) are unchanged.
- Block reasons go to stderr only; hooks write nothing to success or warning streams (#792 guard; research §8).
- No `Write-Error` on any block path (it terminates under `$ErrorActionPreference = 'Stop'` before an exit code is set).

### Dependencies or blocked work:
- **Upstream dependency (E1).** E1 (branch `bug/subagentstop-envelope-core-897`, folder `subagentstop-envelope-core-897`) must be merged into `origin/epic/subagentstop-envelope-integration` before execution begins. The E1 contract is authoritative for the helper: file `.claude/hooks/subagentstop-envelope.ps1`; `Read-SubagentStopEnvelope [-InputText <string>]` returning a seven-property object (`IsValid`, `Anomaly`, `Envelope`, `AssistantText`, `StopHookActive`, `AgentType`, `HookEventName`); `Get-SubagentStopEnvelopeAnomalyReason -Anomaly <string>`; `Exit-SubagentStopBlock -Message <string>`.
- **Upstream-merge check (first execution step).** Confirm the E1 merge on the integration branch and compare the merged helper with the E1 contract as cited here. If the merged helper differs (path, function names, parameters, return shape, anomaly handling, or `StopHookActive` exposure), the merged E1 spec governs and E3 execution stops at the upstream-merge check until this spec and the plan are reconciled.
- **Resolved question: in-process stdin feeding** (formerly research §9 item 2). The E1 contract states that `Read-SubagentStopEnvelope` has no `[Console]::IsInputRedirected` probe, reads `[Console]::In.ReadToEnd()` when `-InputText` is not bound, and parses `-InputText` without reading stdin when it is bound. In-process tests therefore use `-InputText`; script-tail tests may use `[Console]::SetIn`. The upstream-merge check confirms this against the merged helper.
- **Resolved question: `stop_hook_active` re-entry** (formerly research §9 item 3). The E1 contract surfaces `StopHookActive` and leaves the re-entry policy to each validator. E3 policy: every E3 block condition (missing or invalid artifact token, missing file, missing section) is repairable by the subagent, so each validator keeps validating on re-entry.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `.claude/hooks/validate-discovery-artifact-gate.ps1` and mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1` (transport change and R4)
- `.claude/hooks/validate-pr-author-output.ps1` and mirror
- `.claude/hooks/validate-prd-feature-output.ps1` and mirror (transport change, R2 and R3)
- `.claude/hooks/validate-task-researcher-output.ps1` and mirror (transport change, guard pattern, R1 and R3)
- `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`
- `tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1` (only if the dispatch seam signature changes; otherwise verified unchanged and passing)
- `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1`
- `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1`
- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` (new)
- Corpus-run evidence files under `docs/features/active/subagentstop-envelope-artifact-gates-905/evidence/qa-gates/`.
- Agent frontmatter (`.claude/agents/pr-author.md`, `.claude/agents/task-researcher.md`) and their bundled copies: checked only; edited only if the command form must change, which research §4.1 indicates it does not.

#### Functions/classes/CLI commands impacted:
- `Invoke-DiscoveryArtifactGateValidation`: `-RawPayload` replaced by `-InputText`; `-RequiredArtifactReader` kept. An injectable reader at the script entry point is permitted as a parameter seam so the end-to-end block case is reachable (research §6.3).
- `Get-PrAuthorOutputDecision`: `-HookInputRaw` replaced by `-InputText`; help text (`:6-17`) updated to document stdin and exit 2.
- `Invoke-PrdFeatureOutputValidation`: `-RawPayload` replaced by `-InputText`; `Get-Content` reads at `:84` and `:88` wrapped so a read exception becomes a block result.
- `Test-SpecNumericCriterion` (`validate-prd-feature-output.ps1:62-69`): R2. Signature unchanged (`-SpecContent`).
- `Invoke-TaskResearcherOutputValidation`: `-RawPayload` replaced by `-InputText`; gains a leading dependency-decision statement; the `Test-Path`/`Get-Content` re-check at `:274-275` wrapped so a read exception becomes a block result.
- `Test-IsValidResearchFileName` (`validate-task-researcher-output.ps1:85-99`): R1. Signature unchanged (`-Path`).
- `Test-NumericDerivationEvidence` (`validate-prd-feature-output.ps1:42`, `validate-task-researcher-output.ps1:195`): R3 only. Signature (`-Content`) and every other check unchanged.
- `Find-DiscoveryArtifactReference` (`validate-discovery-artifact-gate.ps1:156-192`): R4 only, at line 184. Signature (`-OutputText`) and every other statement unchanged.
- Helper functions with no signature or rule change: `Invoke-DiscoveryValidatorExe`, `Get-DiscoveryArtifactType`, `Get-RequiredDiscoveryArtifactDeclaration`, `Test-PrAuthorOutputReportsPr`, `Get-ArtifactPathFromOutput`, `Test-ResearchFile`, `Get-ResearchPathFromOutput`, `Test-IsUnderResearchRoot`, `Test-AutomationFeasibilitySection`.
- Consumed from E1: `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, `Exit-SubagentStopBlock -Message <text>`.

#### Data flow and validation changes:
- Before: `$env:CLAUDE_HOOK_INPUT` -> `ConvertFrom-Json` -> `.output` -> rules -> `Write-Error` + `exit 1`.
- After: stdin (or `-InputText` in tests and corpus runs) -> `Read-SubagentStopEnvelope` -> `AssistantText` -> rules (with R1, R2, R3 and R4) -> `Exit-SubagentStopBlock -Message` (stderr, exit 2) or `exit 0`.
- Invalid envelope (`IsValid` is `$false`, which includes empty or whitespace stdin, unparseable JSON, a non-object root, and an absent, null or non-string `last_assistant_message`): every one of the four hooks blocks through `Exit-SubagentStopBlock` with `<PREFIX> payload anomaly - <clause>`, the clause from `Get-SubagentStopEnvelopeAnomalyReason` (E1 contract consumer policy item 1).
- Valid envelope with `last_assistant_message` equal to `""`: discovery allows; pr-author blocks with `PR_AUTHOR_OUTPUT_EMPTY`; prd-feature blocks with its empty-output reason, worded to refer to the last assistant message; task-researcher blocks with its existing empty-output reason (research §6.2).
- An envelope carrying only `output`, or input supplied only through `CLAUDE_HOOK_INPUT`, does not satisfy any gate.

#### Error handling and logging updates:
- Every validation block path in the four files ends in `Exit-SubagentStopBlock -Message <reason>`; the dependency-guard paths keep their existing `[Console]::Error.WriteLine(...)` plus `exit 2` / `exit $dependencyDecision.ExitCode` form required by S1.
- No `exit 1` and no `Write-Error` on any block path in the four files.
- `validate-task-researcher-output.ps1` gains the guard bootstrap after `param()`, the guarded helper edge before `Set-StrictMode`, and the dependency tail, so a helper load failure exits 2 with the `validate-task-researcher-output:` prefix.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is a revert of the E3 merge commit on the integration branch; mirrors revert with their sources because both are in the same commit set.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: SubagentStop envelope as JSON on stdin, parsed by `Read-SubagentStopEnvelope` per the E1 contract.
- Output on allow: no stdout or stderr content; exit 0.
- Output on block: reason on stderr; exit 2.

#### Required configuration keys and defaults:
- None added. Registrations remain `pwsh -NoProfile -File .claude/hooks/<hook>.ps1` (pinned by `claude-settings.Tests.ps1:107-154`, `test_claude_planning_integrity_contracts.py:169-262` and `enforce-pr-author-command-allowlist.Tests.ps1:97-120`).

#### Backward-compatibility expectations:
- `CLAUDE_HOOK_INPUT` is no longer read; any caller that relied on it receives no input. This is intended; the runtime never set it for SubagentStop.
- Pure entry functions change parameter names; the only in-repo callers are the hook tails and the Pester suites, all updated in this change.
- R1 accepts a superset of the names accepted today; every name accepted before the change is still accepted.
- R2 flags a subset-by-design of acceptance-criterion lines: lines whose only numerals are of the non-derived kinds listed in R2 no longer require a research path.
- R3 accepts a superset of the scope values accepted today; every scope value accepted before the change is still accepted.
- R4 returns the same references as today for every input that does not raise today; inputs that raise today because a token is empty after trimming now return the references found in their remaining tokens.

#### Performance constraints (latency/throughput/memory):
- No new constraint. Reading stdin once replaces reading one environment variable; each rule change replaces one regex evaluation (R3 in each of its two sites).

## Rule Changes

Each rule change is scoped to one function and keeps the function signature; R3 applies the same change to the two copies of that function. No rule change alters the wording of any message string pinned by `test_claude_planning_integrity_contracts.py` or of any rejection message in the changed functions.

### Policy-file impact

No rule change requires a policy-file edit. None of `.claude/rules/**`, `.github/instructions/**` or `.github/copilot-instructions.md` mentions the research-filename rule, the numeric-derivation rule or the exhaustive-scope check (addendum §6; re-checked for revision 0.3 by a case-insensitive search for `research\.md`, `research\.<`, `numeric derivation`, `numeric-derivation`, `Numeric Derivation` and `research-path` over those three locations, with no match; for revision 0.4 the search for `Exhaustive Search Scope` and `exhaustive` outside `docs/` matched only the two hook copies and their mirrors, `validate-prd-feature-output.ps1:42` and `validate-task-researcher-output.ps1:195-196`). The writer-facing documentation (`.claude/agents/task-researcher.md:30-33`, `:67`, `.claude/skills/research-issue/SKILL.md:27-29`, `.claude/agents/prd-feature.md:32`, `.claude/skills/fill-feature-docs/SKILL.md:15`, `.claude/skills/research-issue/SKILL.md:58`) remains correct after all three changes and is not edited. R4 alters only the internal token handling of the discovery gate; for revision 0.5 a search for `Find-DiscoveryArtifactReference` over `.claude/rules/**`, `.github/instructions/**` and `.github/copilot-instructions.md` returned no match, so R4 also requires no policy-file edit.

### R1: task-researcher accepted-filename rule

- **Site:** `Test-IsValidResearchFileName`, `.claude/hooks/validate-task-researcher-output.ps1:95-98`. Current regex: `^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$`.
- **Documented convention:** `<timestamp>-<short-name>-research.md`, with `<timestamp>` in `yyyy-MM-ddTHH-mm` form (`.claude/agents/task-researcher.md:30-33`; repeated in `.claude/skills/research-issue/SKILL.md:27-29`; timestamp format from `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:46`).
- **Established practice on main:** the orchestrator's recorded inventory of `origin/main` at `2ef8d361e` (command and verbatim result in addendum §2) reports, out of 235 files directly under a `research/` directory: 99 in the documented form; 65 `research.<TS>.md`; 17 `<DATE>-<short-name>-research.md`; about 15 compact-date `YYYYMMDD-<short-name>-research.md`; 2 `research.<DATE>.md`; 1 `research-addendum.<TS>.md`; and a long tail of free-form names. The worktree cross-check in addendum §2 also found compact-time `<DATE>THHmm-<name>-research.md` and `<TS>-<name>.research.md` names. These figures are a single recorded derivation used as rationale only; they are not acceptance-criteria values.
- **New rule (normative).** Applied to the file name (the last path segment after `\` is normalized to `/`), anchored, case-sensitive, evaluated with `[regex]::IsMatch` as today:

  ```
  ^(?:(?:\d{4}-\d{2}-\d{2}(?:T\d{2}-?\d{2})?|\d{8})-[A-Za-z0-9][A-Za-z0-9-]*[-.]research|research(?:-addendum)?\.\d{4}-\d{2}-\d{2}(?:T\d{2}-\d{2})?)\.md$
  ```

- **Accepts exactly these forms:**
  - `<yyyy-MM-ddTHH-mm>-<short-name>-research.md` (documented form, for example `2026-10-11T10-26-subagentstop-envelope-artifact-gates-addendum-research.md`);
  - `<yyyy-MM-dd>-<short-name>-research.md` (date only);
  - `<yyyyMMdd>-<short-name>-research.md` (compact date; also the Copilot-surface form at `.github/prompts/research-issue.prompt.md:38-39` and `.github/agents/task-researcher.agent.md:87-88`);
  - `<yyyy-MM-ddTHHmm>-<short-name>-research.md` (compact time);
  - any of the four stamp forms above followed by `-<short-name>.research.md`;
  - `research.<yyyy-MM-ddTHH-mm>.md` and `research.<yyyy-MM-dd>.md`;
  - `research-addendum.<yyyy-MM-ddTHH-mm>.md` and `research-addendum.<yyyy-MM-dd>.md`;
  - where `<short-name>` starts with an ASCII letter or digit and contains only ASCII letters, digits and hyphens.
- **Rejects every other name, including:**
  - names with no date stamp: `research-input.md`, `research-findings.md`, `orchestration-mechanics.research.md`, `claude-ecosystem.md`, and the test names `foo.md` and `bad-name.md` (`tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1:94`, `:184`, `:207`);
  - a free-form name with the stamp only as a suffix: `hook-surface-inventory.2026-06-27.md`, `parallel-planner-surface.2026-08-07T12-30.md`;
  - a leading stamp without a `-research.md` or `.research.md` ending: `2026-07-22-npm-audit-fix-strategy.md`, `2026-10-09T05-40-root-prettier-fixture-exclusion.md`;
  - a short name that is empty, starts with a hyphen, or contains a character other than an ASCII letter, digit or hyphen (for example an underscore, a space or an extra dot);
  - any extension other than lower-case `.md` (for example `.MD`, `.markdown`, `.txt`);
  - a stamp in any other shape (for example `2026-10-11T12:05`, `2026-1-11`, a compact time after `research.` such as `research.2026-10-11T1205.md`, or a stamp after `research.` that carries a short name).
- **Invariants kept:** every accepted name carries a date stamp and the word `research`; every name accepted by the current regex is accepted by the new one; no current test changes meaning (addendum §3).
- **Rejected-name accounting:** the number of corpus files the new rule still rejects is not fixed in this spec. It is whatever the recorded corpus run reports. Each rejection is listed in the evidence file with its path and classified (see the corpus acceptance criteria); a rejected file that is a legitimate artifact under a current documented or established convention counts as a false positive.
- **Rejection message:** `validate-task-researcher-output.ps1:262` continues to name the documented form as the form to write; it is not required to list every accepted form.
- **Rationale:** the gate's purpose is to prove that a research artifact was written under a research root with a stamped, research-identifying name. The repository has produced research files under the additional stamped forms above for months, orchestrator delegation prompts supply `research.<TS>.md` names, and refusing them would block legitimate completions. Accepting any `*.md` was rejected because it removes the naming convention that `task-researcher.md:33` states is unchanged (addendum §3).

### R2: prd-feature numeric-criterion rule

- **Site:** `Test-SpecNumericCriterion`, `.claude/hooks/validate-prd-feature-output.ps1:62-69`. Current line 68 returns true when any checkbox line in the `## Acceptance Criteria` section matches `\b\d+\b`.
- **Coordinator decision:** the numeric-derivation requirement applies only to computed or derived numbers (a count, enumeration or population whose value depends on enumerating repository content), not to every number in an acceptance criterion. Thresholds, exit codes, issue and PR numbers, line numbers, AC and task identifiers, versions, dates and timestamps, and counts quoted from policy are not derived.
- **Unchanged scoping:** the section is still `## Acceptance Criteria` up to the next `## ` heading (`:67`), only checkbox lines `^\s*[-*]\s*\[.\]` are evaluated, and only `spec.md` is read.
- **New rule (normative).** A checkbox line in that section is a *derived numeric criterion* if and only if both conditions hold:
  1. The line matches, case-insensitively:

     ```
     \b(?:all|exactly|the|these|those)\s+(?:[1-9]\d*|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty)\s+(?:(?!(?:U)\b)[\w`./-]+\s+){0,3}?(?!(?:U)\b)[a-z][\w-]*s\b
     ```

     where `U` is the alternation `seconds|minutes|hours|days|weeks|milliseconds|lines|bytes|characters|percent|is|as|us|has|was|does|this|its|thus|plus|less|unless|across|always|yes`. In words: a determiner (`all`, `exactly`, `the`, `these`, `those`; `the` also covers "each of the" and "none of the"), whitespace, a cardinal (a digit run without a leading zero, or an English cardinal from two to twenty), whitespace, up to three intervening tokens, and a token ending in `s` at a word boundary, where neither the intervening tokens nor the final token is a unit of duration or size or one of the listed non-noun words.
  2. The line, after `\` is normalized to `/`, contains none of the substrings `.claude/rules/`, `.github/instructions/` or `.github/copilot-instructions.md` (policy-citation exclusion: a count on a line that cites a policy source is treated as quoted from policy, not derived).
- `Test-SpecNumericCriterion` returns true when at least one checkbox line is a derived numeric criterion.
- **Examples that are derived (must trigger):**
  - `docs/features/completed/2026-04-25-canonical-evidence-locations-non-overridable-158/spec.md:178` ("All 12 agent files contain ...");
  - `docs/features/completed/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/spec.md:200` ("Each of the 24 PreToolUse hooks has ...");
  - `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md:206` ("the managed block lists exactly 2 entries");
  - `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md:214` ("Each of the 8 edited repo-local files ...");
  - `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/spec.md:315` ("None of the nine Python files", word numeral; addendum §4);
  - `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md:173` ("The three affected test files pass"; an enumeration with inline members, a true positive under `prd-feature.md:32`).
- **Examples that are not derived (must not trigger):**
  - Threshold: `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/spec.md:143` ("Repository-wide PowerShell line coverage is >= 85% ..."); this spec's AC-25 ("at or above 85%") and AC-26 ("over 500 lines").
  - Exit code: this spec's AC-12 ("exits 2 with a `DISCOVERY_ARTIFACT_GATE_BLOCKED:` reason"), which the current rule flags (pre-revision line 190).
  - Issue/PR number: this spec's AC-30 (`Refs #905`, `Refs #897`).
  - AC or task identifier: `AC-01`, `AC-5.4`, `P1-T2`, `E4-ST3` (addendum §4 table).
  - Line number or `file:line`: `typescript.md:57`, `Pester.psm1:8567-8588` (addendum §4 table).
  - Version: `>=18.0.0` (`docs/features/completed/2026-05-06-publish-mcp-server-to-npm-173/spec.md:188`, per addendum §4).
  - Date or timestamp, including in a path: `2026-10-11`, `2026-10-11T17-00`.
  - Section reference: `§12`.
  - Zero or a unit of size or duration: "zero findings", "0 errors", "the 500 lines limit", "the 30 seconds timeout".
  - Count quoted from policy: `docs/features/completed/2026-08-22-fix-all-json-cancel-thread-race-505/spec.md:274` ("The four toolchain stages above complete in a single consecutive pass ..., per the mandatory toolchain loop in `.claude/rules/general-code-change.md`"); condition 1 matches but condition 2 excludes it.
- **Known breadth, recorded rather than treated as defects:** the policy-citation exclusion also exempts lines that edit or list policy files by path (for example `docs/features/completed/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md:301`, which enumerates the files inline). Lines that list their members inline still trigger condition 1 (for example `docs/features/active/subagentstop-envelope-feature-review-coverage-896/spec.md:222`, per addendum §4); these are enumerations under the documented intent.
- **Changes from addendum §4:** the determiner `only` is dropped because it most often precedes an exit code ("only exit 2 blocks"); the redundant `each of the` and `of the` alternatives are covered by `the`; the unit list gains `weeks` and `milliseconds`; the listed non-noun words ending in `s` are excluded so that phrases such as "exactly 2 as documented" do not trigger; the exclusions also apply to the intervening tokens so that "the 500 lines of code changes" does not trigger; and the policy-citation exclusion is added per the coordinator decision.
- **Rationale:** the documented requirement covers "a numeric count, enumeration, or population" (`.claude/agents/prd-feature.md:32`). The determiner + cardinal + plural-noun shape is the textual form of such a count, and each excluded numeral kind fails that shape (for example `85%` and `500-line` have no whitespace after the number; `#897`, `AC-01`, `2026-10-11` and `18.0.0` do not consist of a cardinal followed by whitespace). The rule is a pure function of the line text and therefore decidable without judgment.
- **Classification after the change (mechanical):** R2 is the definition of a derived numeric criterion. A checkbox line that R2 triggers on after the change is therefore DERIVED by definition and is not a false positive. The corpus evidence still records every triggered line with `path:line` so that unanticipated phrasings (Risks item 5) remain visible.
- **Governance:** if review of the recorded triggered lines identifies a phrasing that R2 should not cover, the rule is not adjusted ad hoc. The proposed narrowing is recorded in this section through a spec revision before the rule is changed.

### R3: exhaustive-search-scope check in Test-NumericDerivationEvidence

- **Sites:** `Test-NumericDerivationEvidence` in `.claude/hooks/validate-prd-feature-output.ps1:42` and in `.claude/hooks/validate-task-researcher-output.ps1:195-197` (and their mirrors). Current pattern at both sites, applied with `-notmatch` to the trimmed `Exhaustive Search Scope` value:

  ```
  (?i)\b(entire|all|complete)\b.*\b(repository|repo|source tree|tree)\b
  ```

- **Documented requirement:** the exhaustive scope must cover the complete family (`.claude/agents/prd-feature.md:32`; `.claude/agents/task-researcher.md:67`). The documentation requires the scope to be exhaustive; it does not prescribe the words `repository` or `tree`.
- **Observed defect:** existing research artifacts on main declare whole-worktree scopes, which are exhaustive, and fail only because `\btree\b` does not match inside `worktree` (no word boundary between `work` and `tree`) and `whole` is not in the quantifier alternation. Examples (paths and lines re-derived for this revision by a case-insensitive content search of `docs/` for `Exhaustive Search Scope` lines containing `worktree` or `whole`):
  - `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/research/research.2026-10-09T02-25.md:215` ("entire worktree.");
  - `docs/features/completed/enforcement-gates-lack-epic-level-checkpoint-seam-663/research/research.2026-09-25T08-35.md:178` ("entire worktree root.");
  - `docs/features/completed/preimplementation-helpers-backslash-chain-operator-710/research/research.2026-09-26T23-05.md:228` ("the whole worktree, all directories.");
  - `docs/features/completed/preimplementation-gate-blocks-attribution-trailers-713/research/research.2026-09-27T00-30.md:286` ("the whole worktree, all directories.");
  - `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/research/research.2026-10-08T14-00.md:319` ("the whole worktree (all directories, including `extensions/`).");
  - `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/research/research.2026-10-03.md:211` ("entire worktree excluding ...");
  - `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/research/research.2026-10-08T14-00.md:323` ("the whole worktree with ripgrep, restricted to code by excluding `docs/` ...");
  - `docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/research/2026-09-29T17-50-remediation-loop-verdict-research.md:337` ("the whole worktree excluding `docs/**`, ...").
  These are illustrative and are not acceptance-criteria values; the corpus run (AC-08, and AC-07 for research files the task-researcher hook evaluates) enumerates the population.
- **New rule (normative).** At both sites, the pattern becomes:

  ```
  (?i)\b(entire|whole|all|complete)\b.*\b(repository|repo|worktree|source tree|tree)\b
  ```

  The quantifier alternation gains `whole`; the noun alternation gains `worktree`. The `-notmatch` operator, the trimmed input value, the position of the check within `Test-NumericDerivationEvidence`, and the rejection message (`... does not declare an exhaustive repository search scope.`) are unchanged at both sites.
- **Unchanged:** every other check in `Test-NumericDerivationEvidence` in both files: the numeric-claim trigger, the `## Numeric Derivation Evidence` heading match, the required labels and their line pattern, the narrow-strategy check, the repeated-strategy check, the family-coverage check, the numeric-count check, the count-versus-member-set check, the member-set agreement check and the member-set comparison check.
- **Accepts (examples):** "entire worktree.", "entire worktree root.", "the whole worktree, all directories.", "the whole repository excluding `docs/`", and every value accepted by the current pattern.
- **Still rejects (examples):** "the hooks folder", "those four files on the current worktree" (no quantifier from the alternation), "the whole file, lines 1-335" (no noun from the alternation), "`.claude/hooks/`".
- **Mirror and parity:** both hook copies carry the identical pattern after the change, and each bundled mirror is byte-identical to its source.
- **Policy-file impact:** none (see "Policy-file impact" above).
- **Rationale:** the gate's purpose is to refuse a derivation whose scope is narrower than the complete family. A whole-worktree scope is the widest scope available to a worktree-isolated researcher and satisfies the documented requirement. Rejecting it is a checker defect, not an artifact defect, and once the hooks block it would refuse legitimate research and prd-feature completions. The change is the smallest edit that admits these scopes while leaving non-exhaustive scopes rejected; replacing the check with free-form judgment was rejected because it would not be decidable from the text.

### R4: empty-token guard in Find-DiscoveryArtifactReference

- **Site:** `Find-DiscoveryArtifactReference`, `.claude/hooks/validate-discovery-artifact-gate.ps1:156-192` (and its bundled mirror, where the same statement is also at line 184). Current line 184:

  ```
  if (Get-DiscoveryArtifactType -Path $trimmed) {
  ```

- **Observed defect:** the function splits the text on `\s+`, then trims each token with `$token.Trim('`', '"', "'", ',', ';', '(', ')', '[', ']')` (line 183). A token consisting only of trim characters (for example `""`, `()` or a lone backtick) becomes the empty string. `Get-DiscoveryArtifactType` declares `[Parameter(Mandatory = $true)] [string] $Path` (lines 97-100) without `[AllowEmptyString()]`, so binding the empty string raises `Cannot bind argument to parameter 'Path' because it is an empty string.` Executor preflight round 2 ran the discovery corpus (AC-09) at `origin/main` `2ef8d361e` and recorded every block reason as `EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.` raised at line 184; a scratchpad copy carrying the R4 line recorded no block and no false positive on the same corpus. Those preflight figures are rationale only and are not acceptance-criteria values.
- **New rule (normative).** Line 184 becomes:

  ```
  if ($trimmed -and (Get-DiscoveryArtifactType -Path $trimmed)) {
  ```

  A token that is empty after trimming is skipped before `Get-DiscoveryArtifactType` is called. Nothing else in `Find-DiscoveryArtifactReference` changes: the `[string]::IsNullOrWhiteSpace` early return, the `-split '\s+'` tokenization and `Where-Object { $_ }` filter, the trim character set, the de-duplication through `$foundReferences.Contains`, and the `[string[]]` return are unchanged. `Get-DiscoveryArtifactType` is unchanged, including its mandatory `-Path` parameter.
- **Accepts (examples):** text containing `""` and `discovery/profile/a.json` returns `discovery/profile/a.json` without an error; text containing a lone backtick token and no discovery path returns an empty array without an error.
- **Unchanged results:** for every input that does not raise today, the returned references are identical before and after R4, because a non-empty `$trimmed` evaluates as true and the original call is made.
- **Mirror and parity:** the bundled mirror is byte-identical to its source after the change.
- **Policy-file impact:** none (see "Policy-file impact" above).
- **Rationale:** the gate inspects every agent's final message under the broad matcher (`.claude/settings.json:214`), and ordinary prose regularly contains quoted empty strings or isolated backticks. Once the gate blocks with exit 2, an exception on such a token would refuse completions that contain no discovery reference at all. Skipping the empty token is the smallest change that removes the exception; making `-Path` accept the empty string was not chosen because it would widen the contract of `Get-DiscoveryArtifactType` for every caller.

### Corpus false-positive classification (mechanical)

These rules govern how every block or failure recorded by the corpus runs in AC-07 and AC-08 is classified. A CHECKER-DEFECT classification counts as a false positive; an ARTIFACT-DEFECT (true rejection) does not.

- **Heading deviation is an artifact defect.** A research artifact whose numeric-derivation heading deviates from the documented exact heading `## Numeric Derivation Evidence` (`.claude/agents/task-researcher.md:67`) is a true rejection. Example: `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/research/2026-10-09T02-25-issue-823-tier-rule-adoption-follow-ups-research.md:268` (`## 11. Numeric Derivation Evidence`).
- **Missing documented content is an artifact defect.** An artifact that lacks a documented required label, or lacks the `## Automation Feasibility` section content that the hook names, is a true rejection.
- **Per failure message from `Test-NumericDerivationEvidence`:**
  - "missing <label>": ARTIFACT-DEFECT when no line in the `## Numeric Derivation Evidence` section matches the hook's label pattern for that label; otherwise CHECKER-DEFECT.
  - "does not declare an exhaustive repository search scope": CHECKER-DEFECT when the declared scope value matches `(?i)\b(entire|whole|all)\b.*\b(repository|repo|worktree|source tree|tree)\b`; otherwise ARTIFACT-DEFECT. Every scope value matching this classification pattern also matches the R3 pattern, so every such case must pass after R3.
  - Every other message: ARTIFACT-DEFECT, unless the plan states an explicit mechanical rule for that message, in which case the plan's rule applies.
- **R2 triggered lines after the change:** DERIVED by definition (see R2, "Classification after the change").
- **R1 filename rejections:** classified as stated in R1, "Rejected-name accounting" and AC-07.
- **Discovery corpus blocks (AC-09):** every block of a corpus message is a false positive, including a block whose reason is an exception caught by the corpus harness (recorded with the prefix `EXCEPTION:`); an exception is never classified as a true rejection. After R4, no recorded block reason begins with `EXCEPTION:`.
- **Rationale:** each rule is a pure function of the artifact text and the failure message, so the classification is reproducible and does not depend on reviewer judgment. Deviations from documented exact headings and labels are artifact defects because the documentation specifies them exactly; the scope check is the only check whose pattern is narrower than its documented requirement, and R3 corrects it.

## Assumptions, Constraints, Dependencies
- Assumptions:
  - Frontmatter-registered hooks receive the same stdin envelope as settings-registered hooks (from documentation; not observed by E1, research §9 item 6).
  - Relative `spec-path`/`research-path` checks resolve against the hook process working directory; not verified for worktree-isolated subagents (research §9 item 5).
- Constraints:
  - No Python in enforcement hooks (`epic.md:14`; `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`).
  - No production or test file over 500 lines. Current maximum among E3 files is the task-researcher suite at 423 lines (research §8); new entry-point and rule tests for that hook go in the new Coverage suite.
  - Line coverage >= 85% for each changed PowerShell file; Pester measures line coverage only and no exclusions are permitted. Recorded baselines (research §4.3): `validate-discovery-artifact-gate.ps1` 92.65% (63/68), `validate-pr-author-output.ps1` 100.00% (39/39), `validate-prd-feature-output.ps1` 98.15% (53/54), all from the #786 evidence dated 2026-10-10; `validate-task-researcher-output.ps1` 90.00% (90/100) from the #593 evidence dated 2026-08-29 (stale; refresh at Phase 0).
  - Bundled mirrors byte-identical to their sources (`epic.md:17`; `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110`). Mirrors are synced by file copy; no sync script exists (research §4.2).
  - No temporary files in tests. In-process tests pass envelope JSON through `-InputText`; script-tail tests feed stdin with `[Console]::SetIn([System.IO.StringReader]::new($json))` and capture stderr with `[Console]::SetError(...)`, restored in `finally` (precedent `hook-dependency-failure.Claude.Tests.ps1:104-124`).
  - Corpus runs read tracked repository files from the repo-root working directory and call pure entry points with `-InputText` or the rule function directly; they do not read stdin and write only their evidence file.
  - Commit and push at every phase boundary; never force-push.
  - `validate-pr-author-output.ps1` and `agents/pr-author.md` stay out of the pack manifests (pinned exception, research §4.2).
- External dependencies: E1 merged into `origin/epic/subagentstop-envelope-integration`; Claude Code SubagentStop runtime behavior as measured by E1.

## Data / API / Config Impact
- User-facing or API changes: the four completion gates begin blocking. Agents whose final message lacks the required artifact are refused with exit 2 and re-invoked by the runtime. Research files under the R1 accepted forms are accepted; specs whose acceptance criteria contain only non-derived numerals no longer require a research path.
- Data or migration considerations: none. Existing research files and specs are not renamed or edited.
- Logging/telemetry updates: block reasons are written to stderr by `Exit-SubagentStopBlock`; no other logging.
- Compatibility notes: registration commands unchanged; no settings, schema or CLI flag changes.

## Test Strategy
- Regression tests to add or update (research §6.3):
  - Pure-function tests: replace `@{ output = ... } | ConvertTo-Json` raw-payload fixtures with `-InputText` envelope JSON carrying `last_assistant_message`; envelope anomaly classification itself belongs to E1's helper suite, while each hook keeps one case asserting that an invalid envelope blocks with its prefix and `payload anomaly`.
  - Entry-point tests via stdin envelope, inverted from exit 1 to exit 2 following the #501 pattern:
    - `validate-discovery-artifact-gate.Tests.ps1:160-169`: stdin envelope whose `last_assistant_message` references an artifact that fails validation under an injected present declaration, asserting exit 2.
    - `validate-pr-author-output.Tests.ps1:105-125`: `Should -Be 2` for an envelope without a PR reference.
    - `validate-pr-author-output.Coverage.Tests.ps1:38-44`: `Should -Be 2`.
    - `validate-prd-feature-output.Coverage.Tests.ps1:38-45`: assert exit code 2 and a stderr reason instead of a thrown error.
    - New `validate-task-researcher-output.Coverage.Tests.ps1`: allow, block, `output`-only negative, and helper-load-failure cases.
  - Each changed suite keeps an exit-0 allow case and adds a negative case in which an envelope carrying only `output` (and no `last_assistant_message`) does not satisfy the gate.
  - Message assertions that pin `CLAUDE_HOOK_INPUT` text are updated: `validate-discovery-artifact-gate.Tests.ps1:80`, `:87`; `validate-prd-feature-output.Coverage.Tests.ps1:44`; `validate-task-researcher-output.Tests.ps1:48`, `:66`.
  - R1 tests (`Test-IsValidResearchFileName`): one accepted case per accepted form listed in R1, and one rejected case per rejected category listed in R1, including the existing `foo.md` and `bad-name.md` cases.
  - R3 tests (`Test-NumericDerivationEvidence`, in each of the prd-feature and task-researcher suites): accepted scope values "entire worktree." and "the whole worktree, all directories." pass the scope check; a non-exhaustive scope value such as "the hooks folder" is still rejected with the unchanged message; a value accepted before R3 (for example "entire repository") is still accepted.
  - R4 test (`Find-DiscoveryArtifactReference`, in `validate-discovery-artifact-gate.Tests.ps1`): text containing an empty-after-trim token (for example `""` or a lone backtick) together with a `discovery/<type>` reference returns that reference without an error.
  - R2 tests (`Test-SpecNumericCriterion`): triggering cases for a digit cardinal and a word cardinal under each determiner; non-triggering cases for each non-derived kind listed in R2 (threshold, comparator, exit code, issue or PR number, line number or `file:line`, AC or task identifier, version, date or timestamp, section reference, zero, unit of size or duration, policy-cited count); a case showing that a checkbox line outside the `## Acceptance Criteria` section does not trigger; and an end-to-end prd-feature case in which a spec whose acceptance criteria contain only non-derived numerals allows without a `research-path`.
- Corpus runs (addendum §3-§5): one script-free procedure per validator, run in process through the pure entry point, recorded in an evidence file under `evidence/qa-gates/`. "Before" uses the validator logic on the integration-branch base (legacy entry signature with the message wrapped as `{ "output": <message> }`); "after" uses the changed validator with `-InputText` envelope JSON. Each run records the `origin/main` commit used, the enumeration command, every block with path and reason, its classification under Rule Changes "Corpus false-positive classification (mechanical)", and the false-positive counts before and after.
- Unit tests (Pester, not pytest; these are PowerShell hooks) for the fixed behavior and boundaries: as above. At most one subprocess case per hook (`$json | & $PwshExe -NoProfile -File $hook`) as the end-to-end exit-code check; all other entry-point cases run in process for coverage.
- Edge cases and negative scenarios: blank `last_assistant_message`; absent `last_assistant_message`; envelope carrying only `output`; `CLAUDE_HOOK_INPUT` set with stdin lacking the artifact (must still block); `stop_hook_active: true` re-entry keeps validating; `Get-Content` read exceptions in prd-feature and task-researcher map to a block result.
- Error handling and logging verification: each block test asserts exit 2 and a non-empty stderr reason containing the hook's existing token or prefix; no test sets or relies on `CLAUDE_HOOK_INPUT` except to prove it is ignored.
- Coverage impact and targets: >= 85% line coverage per changed hook file, measured from the self-hosted PoshQC module (`Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest ...`), parsing `artifacts/pester/powershell-coverage.xml` per file; the MCP runner is called for route compliance but returns no figures (research §4.3, §9 item 9). Evidence is written under `docs/features/active/subagentstop-envelope-artifact-gates-905/evidence/<kind>/`.
- Toolchain commands to run (format -> lint -> type-check -> test): PowerShell toolchain via the PoshQC route: `Invoke-Formatter` (format), PSScriptAnalyzer (lint), type check skipped for PowerShell, Pester (tests with coverage). Also run the registration-driven suites (`hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, `claude-settings.Tests.ps1`, `enforce-pr-author-command-allowlist.Tests.ps1`) and the content and parity pytest checks (`test_claude_planning_integrity_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`).
- Manual validation steps: after E1 merges, one live smoke run per agent type (pr-author, prd-feature, task-researcher, one discovery agent) is recommended to confirm stdin delivery to frontmatter hooks and the working-directory assumption (research §9 items 5-6). This is recorded as follow-up evidence and is not a merge gate for E3.

## Acceptance Criteria
- [x] AC-01: Upstream-merge check passes: E1 is merged into `origin/epic/subagentstop-envelope-integration`; `.claude/hooks/subagentstop-envelope.ps1` defines `Read-SubagentStopEnvelope` (with `-InputText`), `Get-SubagentStopEnvelopeAnomalyReason` and `Exit-SubagentStopBlock`; and the merged helper matches the E1 contract cited in this spec, or this spec and the plan are reconciled to the merged E1 spec before any hook is edited. The result is recorded in the plan.
- [x] AC-02: R1 is implemented: `Test-IsValidResearchFileName` in `.claude/hooks/validate-task-researcher-output.ps1` applies the normative regex in Rule Changes R1, anchored and case-sensitive (code review against the R1 section).
- [x] AC-03: R1 is covered by Pester tests on both sides: one passing accepted-name case for each accepted form listed in R1, and one passing rejected-name case for each rejected category listed in R1, including `foo.md` and `bad-name.md`.
- [x] AC-04: R2 is implemented: `Test-SpecNumericCriterion` in `.claude/hooks/validate-prd-feature-output.ps1` returns true only when a checkbox line in the `## Acceptance Criteria` section satisfies both conditions of the normative rule in Rule Changes R2 (code review against the R2 section).
- [x] AC-05: R2 is covered by Pester tests on both sides: derived-count lines with a digit cardinal and with a word cardinal trigger; non-derived lines do not trigger, with one named case for each excluded kind (threshold, comparator, exit code, issue or PR number, line number or `file:line`, AC or task identifier, version, date or timestamp, section reference, zero, unit of size or duration, and a count on a line citing `.claude/rules/`, `.github/instructions/` or `.github/copilot-instructions.md`); and a prd-feature entry-point case allows a spec whose acceptance criteria contain only non-derived numerals without a `research-path`.
- [x] AC-06: No rule change (R1, R2, R3 or R4) edits a policy file: `git diff --name-only origin/epic/subagentstop-envelope-integration` lists no path under `.claude/rules/`, `.github/instructions/`, or `.github/copilot-instructions.md`.
- [x] AC-07: Task-researcher corpus run: every path matching `/research/[^/]+$` in `git ls-tree -r --name-only <origin/main commit> -- docs` is wrapped in a synthetic final message `research-path: <repo-relative path>` and passed through the pure entry point (`-InputText` envelope, no stdin) from the repo-root working directory, before and after the change. The evidence file under `evidence/qa-gates/` records the commit, the command, every block with path and reason, and the false-positive count before and after. Every block is classified in the evidence under Rule Changes "Corpus false-positive classification (mechanical)": a filename-rule block is a false positive when the file name is one of the forms R1 accepts, and otherwise a true rejection naming the R1 rejected category; a block from `Test-NumericDerivationEvidence` is CHECKER-DEFECT (a false positive) or ARTIFACT-DEFECT (a true rejection) by the per-message rules in that section, so a deviating heading such as `## 11. Numeric Derivation Evidence`, a missing documented required label, or missing `## Automation Feasibility` content that the hook names is a true rejection, and a whole-worktree or entire-worktree scope rejection is a false positive before R3 and must not occur after R3; any other block is a true rejection unless the plan states an explicit mechanical rule for its message.
- [x] AC-08: Prd-feature corpus run: every `docs/features/**/spec.md` in `git ls-tree -r --name-only <origin/main commit> -- docs/features` is passed through `Test-SpecNumericCriterion` before and after R2, and every triggered checkbox line is recorded with `path:line`. Before R2, a false positive is a triggered line whose numerals are all of the non-derived kinds listed in R2; after R2, a triggered line is DERIVED by definition and is not a false positive. In addition, every research file on that commit that contains `## Numeric Derivation Evidence` is passed through `Test-NumericDerivationEvidence` before and after R3, and every failure is recorded with its message and classified mechanically per Rule Changes "Corpus false-positive classification (mechanical)": "missing <label>" is ARTIFACT-DEFECT when no line in the section matches the label pattern and CHECKER-DEFECT otherwise; "does not declare an exhaustive repository search scope" is CHECKER-DEFECT when the declared scope value matches `(?i)\b(entire|whole|all)\b.*\b(repository|repo|worktree|source tree|tree)\b` and ARTIFACT-DEFECT otherwise; every other message is ARTIFACT-DEFECT unless the plan states an explicit mechanical rule. CHECKER-DEFECT counts as a false positive. Specs that trigger correctly but have no research evidence are reported and are not false positives. The evidence file under `evidence/qa-gates/` records the commit, the commands, the classifications, and the false-positive count before and after.
- [x] AC-09: Discovery corpus run (no tracked discovery artifact corpus exists, addendum §5): synthetic final messages built from the text of every tracked file on the recorded `origin/main` commit that mentions a `discovery/<type>` path, plus one message containing `scripts/dev_tools/discovery/profile_cli.py`, are passed through `Find-DiscoveryArtifactReference` (classified tokens recorded) and through the pure entry point with the default declaration reader, before and after the change. A false positive is any block of such a message, including a block recorded because the corpus harness caught an exception (reason prefixed `EXCEPTION:`). The evidence file under `evidence/qa-gates/` records the source-file list, the classified tokens, every block with its reason, and the false-positive count before and after; the after-change run records no block reason beginning with `EXCEPTION:`.
- [x] AC-10: Pr-author corpus run (no tracked final-message corpus exists, addendum §5): synthetic final messages in each form the persona is told to report (a PR URL, `PR #<n>`, and a `gh pr create` or `gh pr edit` line with `#<n>`, per `.claude/agents/pr-author.md:65`, `:87-88`), using PR numbers taken from tracked evidence, are passed through the pure entry point before and after the change; a message carrying only `Refs #<n>` is included as a block control. A false positive is a block of any reporting-form message. The evidence file under `evidence/qa-gates/` records the messages, decisions, and the false-positive count before and after.
- [x] AC-11: Zero-false-positive gate ordering: for each of the discovery, pr-author, prd-feature and task-researcher validators, the corpus evidence file records an after-change false-positive count of zero, and the commit adding that evidence file precedes the commit that replaces that validator's final block exit with `Exit-SubagentStopBlock` (verified with `git log --format=%H --reverse -- <evidence file> <hook file>` and recorded in the plan). For the prd-feature and task-researcher validators, the evidence also records that every scope value classified CHECKER-DEFECT before R3 passes the scope check after R3. If a non-zero count remains, execution stops before that validator's switch and the finding is reported; no rule other than R1, R2, R3 and R4 is changed without a spec revision.
  Post-review clarification (2026-10-15, issue #929): ordering is evaluated against the commit that first records the after-change zero count in the evidence file, which is the first commit returned by `git log --format=%H --reverse -S 'AFTER-FALSE-POSITIVES: 0' -- <evidence file>`; that commit must be an ancestor of the switch commit (`git merge-base --is-ancestor <that commit> <switch commit>` exits 0). The plan's `AC11:` lines record this property; the AC-11 checkbox state is unchanged.
- [x] AC-12: `validate-discovery-artifact-gate.ps1` exits 2 with a `DISCOVERY_ARTIFACT_GATE_BLOCKED:` reason on stderr when the stdin envelope's `last_assistant_message` references a discovery artifact that fails validation under a present declaration (Pester: `validate-discovery-artifact-gate.Tests.ps1`, stdin-envelope block case).
- [x] AC-13: `validate-discovery-artifact-gate.ps1` exits 0 when `last_assistant_message` carries valid artifact references, carries no references, is an empty string, or the declaration is absent (Pester: `validate-discovery-artifact-gate.Tests.ps1`, stdin-envelope allow cases).
- [x] AC-14: `validate-pr-author-output.ps1` exits 2 with `PR_AUTHOR_OUTPUT_NO_PR` on stderr when `last_assistant_message` lacks a PR reference, and exits 0 when it carries one (Pester: `validate-pr-author-output.Tests.ps1` and `validate-pr-author-output.Coverage.Tests.ps1`).
- [x] AC-15: `validate-prd-feature-output.ps1` exits 2 with a stderr reason when `last_assistant_message` lacks an existing `spec-path`, and exits 0 when it carries an existing `spec-path` whose spec has no derived numeric criterion under R2 (Pester: `validate-prd-feature-output.Tests.ps1` and `validate-prd-feature-output.Coverage.Tests.ps1`).
- [x] AC-16: `validate-task-researcher-output.ps1` exits 2 with a stderr reason when `last_assistant_message` lacks a valid `research-path`, and exits 0 when it carries a valid one (Pester: `validate-task-researcher-output.Coverage.Tests.ps1`).
- [x] AC-17: For each of the discovery, pr-author, prd-feature and task-researcher hooks, an envelope carrying the required artifact only in an `output` field, or input supplied only through `CLAUDE_HOOK_INPUT`, does not satisfy the gate (Pester: the `output`-only negative case in each hook's entry-point suite).
- [x] AC-18: Envelope anomalies follow the E1 contract: for each of the discovery, pr-author, prd-feature and task-researcher hooks, an invalid envelope (empty stdin, unparseable JSON, or absent `last_assistant_message`) exits 2 with the hook's prefix and `payload anomaly` on stderr; and a valid envelope whose `last_assistant_message` is an empty string allows for discovery and blocks with the existing empty-output reason for pr-author, prd-feature and task-researcher (a named Pester case per hook and outcome).
- [x] AC-19: `validate-task-researcher-output.ps1` carries the #786 guard bootstrap, guarded `subagentstop-envelope.ps1` edge, dependency tail and leading dependency-decision statement, and a helper load failure exits 2 with the `validate-task-researcher-output:` prefix (Pester: `validate-task-researcher-output.Coverage.Tests.ps1`, helper-load-failure case).
- [x] AC-20: No `CLAUDE_HOOK_INPUT` literal and no `.output` property read remain in the discovery, pr-author, prd-feature or task-researcher hook files or their mirrors (command: `Select-String -Path .claude/hooks/validate-discovery-artifact-gate.ps1,.claude/hooks/validate-pr-author-output.ps1,.claude/hooks/validate-prd-feature-output.ps1,.claude/hooks/validate-task-researcher-output.ps1 -Pattern 'CLAUDE_HOOK_INPUT','\.output\b'` returns no match; same command against the mirror paths).
  Post-review clarification (2026-10-15, issue #929): the AC-20 pattern `\.output\b` is intended to detect reads of the envelope payload's `output` field. The discovery validator's result object exposes an `Output` key that is read through the hashtable indexer (`$validatorResult['Output']`) per plan RS-2 (`plan.2026-10-11T07-59.md`); that read is not an envelope read. No code change; the AC-20 checkbox state is unchanged.
- [x] AC-21: No `exit 1` and no `Write-Error` remain on any block path in the discovery, pr-author, prd-feature and task-researcher hook files or their mirrors (command: `Select-String -Pattern '\bexit 1\b','Write-Error'` over the same paths returns no match).
- [x] AC-22: Exit-code assertions are inverted: `validate-discovery-artifact-gate.Tests.ps1`, `validate-pr-author-output.Tests.ps1` and `validate-pr-author-output.Coverage.Tests.ps1` contain no `Should -Be 1` exit-code assertion and assert exit 2 on their block cases, and `validate-prd-feature-output.Coverage.Tests.ps1` asserts exit 2 with a stderr reason instead of a thrown error (command: `Select-String -Path tests/scripts/claude-hooks/validate-*.Tests.ps1 -Pattern '(LASTEXITCODE|ExitCode)\s*\|\s*Should\s+-Be\s+1\b'` returns no match for the E3 suites; the suites pass).
- [x] AC-23: No E3 test sets `CLAUDE_HOOK_INPUT` except to prove it is ignored, and no E3 test creates a temporary file (code review of the changed suites; `Select-String -Pattern 'New-TemporaryFile','GetTempFileName','TestDrive'` over the changed suites returns no match).
- [x] AC-24: Message strings pinned by `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` are preserved (command: `poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` passes).
- [x] AC-25: Line coverage is at or above 85% for each changed PowerShell file, measured per file from the self-hosted PoshQC coverage XML and recorded under `evidence/qa-gates/`.
- [x] AC-26: No changed or new production or test file is over 500 lines (command: `(Get-Content <file>).Count` for each changed file, recorded in evidence).
- [x] AC-27: Bundled hook mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` are byte-identical to their sources for every changed hook (command: `Get-FileHash` of each source and mirror pair matches, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes).
- [x] AC-28: No Python is invoked by any changed hook and no Python hook is added (Pester: `enforcement-hooks-no-python-invocation.Tests.ps1` passes; `git diff --name-only origin/epic/subagentstop-envelope-integration -- .claude/hooks extensions/drm-copilot/resources/claude-customizations/.claude/hooks` lists no `.py` file); and the registration-driven guard suites pass with the new helper edge (Pester: `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`).
- [x] AC-29: Full PowerShell toolchain pass completed in a single pass: format (`Invoke-Formatter`), lint (PSScriptAnalyzer, zero findings), and Pester tests (all passing), recorded under `evidence/qa-gates/`; agent frontmatter registrations in `.claude/agents/pr-author.md` and `.claude/agents/task-researcher.md` are verified unchanged, or changed in both source and bundled copy if the command form must change (`enforce-pr-author-command-allowlist.Tests.ps1` and `claude-settings.Tests.ps1` pass).
- [x] AC-30: Out-of-scope files are untouched and the child pull request is non-closing: `git diff --name-only origin/epic/subagentstop-envelope-integration` lists no E1 file (`.claude/settings.json`, its bundled copy, `.claude/hooks/subagentstop-envelope.ps1`, its mirror or tests, pack manifests), no E2 file (`validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, orchestrator routing helpers, `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1`, their suites and mirrors, `.claude/agents/prd-feature.md` or its bundled copy), no E4 file (`validate-feature-review-coverage.ps1`, `feature-review-coverage-thresholds.ps1`, feature-review skills, `.codex/agents/feature-review.toml` or their mirrors), and no shared helper under `tests/scripts/claude-runtime/`; and the child pull request body contains `Refs #905` and `Refs #897` and no closing keyword (`Closes`, `Fixes`, `Resolves`, or their variants) for either issue (command: `gh pr view <number> --json body`).
- [x] AC-31: R3 is implemented: in both `.claude/hooks/validate-prd-feature-output.ps1` and `.claude/hooks/validate-task-researcher-output.ps1`, the `Exhaustive Search Scope` check in `Test-NumericDerivationEvidence` uses `(?i)\b(entire|whole|all|complete)\b.*\b(repository|repo|worktree|source tree|tree)\b`, and every other check and message in that function is unchanged (code review against the R3 section and `git diff origin/epic/subagentstop-envelope-integration` of both functions).
- [x] AC-32: R3 is covered by Pester tests on both sides in each of the prd-feature and task-researcher suites: "entire worktree." and "the whole worktree, all directories." pass the scope check; "the hooks folder" is still rejected with the unchanged exhaustive-scope message; a value accepted before R3 is still accepted. The bundled mirrors of both hooks are byte-identical to their sources after R3 (`Get-FileHash` of each source and mirror pair matches).
- [x] AC-33: R4 is implemented: in `.claude/hooks/validate-discovery-artifact-gate.ps1`, `Find-DiscoveryArtifactReference` evaluates `if ($trimmed -and (Get-DiscoveryArtifactType -Path $trimmed)) {` in place of `if (Get-DiscoveryArtifactType -Path $trimmed) {`, and no other statement in that function changes (code review against the R4 section and `git diff origin/epic/subagentstop-envelope-integration` of the function); the bundled mirror is byte-identical to its source (`Get-FileHash` of the source and mirror pair matches); and a Pester case in `validate-discovery-artifact-gate.Tests.ps1` passes text containing an empty-after-trim token (such as `""` or a lone backtick) together with a `discovery/<type>` reference to `Find-DiscoveryArtifactReference` and asserts that the reference is returned and no error is raised.

## Risks & Mitigations
- Technical or operational risks:
  1. **E1 merged helper differs from the cited contract.** The E1 contract is published but E1 is not yet merged.
  2. **In-process stdin injection.** Resolved by the E1 contract (no `[Console]::IsInputRedirected` probe; `-InputText` seam); residual risk only if the merged helper differs.
  3. **`stop_hook_active` re-entry.** A blocked agent is re-invoked; repeated refusals are the enforcement but may repeat if the agent cannot produce the artifact.
  4. **Research filename rule.** R1 accepts the stamped forms in established use; some long-tail names remain rejected. If any of them is a legitimate current-convention artifact, it is a false positive and blocks the task-researcher switch.
  5. **Numeric rule breadth.** R2 may still flag a non-derived line in an unanticipated phrasing, or the policy-citation exclusion may exempt a derived count on a line that also cites a policy file.
  5a. **Scope check breadth (R3).** R3 admits any scope value with a whole-worktree or entire-worktree phrase, including values that add exclusions (for example "the whole worktree excluding `docs/**`"). Whether an exclusion narrows the scope below the complete family is not decidable from the pattern; this is unchanged from the current pattern, which already admits "entire repository excluding ..." values.
  6. **Corpus inventory is single-derivation.** The research-form counts in R1 come from one recorded command; they are rationale only.
  7. **Working-directory dependence** of relative `spec-path`/`research-path` checks for worktree-isolated subagents (research §9 item 5).
  8. **Frontmatter hooks not measured** by E1's probe (research §9 item 6).
  9. **Discovery gate blast radius** under the broad matcher (research §9 item 7); invalid envelopes now block for every agent under that matcher.
  10. **Double registration** of pr-author and prd-feature may produce duplicate refusals (research §9 item 8).
  11. **Coverage tooling** may not report new rows through the MCP runner (research §9 item 9); task-researcher baseline is stale (research §9 item 10).
- Mitigations and rollbacks:
  1. Upstream-merge check as the first execution step (AC-01); stop on mismatch until reconciled.
  2. Use `-InputText` for in-process tests and keep one subprocess case per hook for the true exit code.
  3. Every E3 block condition is repairable by the subagent, so validators keep validating on re-entry per E1 contract consumer policy item 2.
  4. AC-07 requires every rejection to be listed and classified, and AC-11 requires zero false positives before the switch.
  5. AC-08 records every triggered line; the R2 governance clause requires a spec revision rather than an ad hoc change.
  5a. AC-32 pins a non-exhaustive scope as still rejected; AC-07 and AC-08 record every scope failure with its value.
  6. AC-07 records the corpus from its own enumeration at a recorded commit; no AC depends on the inventory counts.
  7-8. Recommend one live smoke run per agent type after E1 merges; record as follow-up evidence.
  9. Preserve the discovery gate's nothing-to-inspect allow paths for valid envelopes (AC-13); follow the E1 fail-closed policy for invalid envelopes (AC-18).
  10. Leave to E1, which owns settings; record in the epic-level report.
  11. Measure coverage with the self-hosted module and per-file XML parsing; capture a fresh task-researcher baseline at Phase 0.
  - Rollback: revert the E3 merge commit on the integration branch (sources and mirrors revert together).

## Rollout & Follow-up
- Release/rollout steps:
  - Execute only after the upstream-merge check passes. Order the work so that, for each validator, the rule changes that apply to it (R1 and R3 for task-researcher; R2 and R3 for prd-feature; R4 for discovery) and the corpus run precede the task that switches it to exit-2 blocking (AC-11). Commit and push at every phase boundary; never force-push.
  - Open the child pull request against `epic/subagentstop-envelope-integration`. The child PR body uses `Refs #905` and `Refs #897` and no closing keyword for either issue. Closing happens at the epic integration PR (epic issue #904).
  - CI on epic-child PRs may need a manual `ci.yml` dispatch because the workflow triggers on PRs into `main`/`development` only.
- Post-fix monitoring or clean-up tasks (epic-level report follow-ups, not E3 work):
  - Live smoke run per agent type for frontmatter-registered hooks and working-directory resolution.
  - Double registration of pr-author and prd-feature (E1 decision).
  - A SubagentStop source-scanning guard against `CLAUDE_HOOK_INPUT`, covering agent-frontmatter registrations, owned by a single child (preferably E1).
  - The latent `{ ExitCode; Reason }` versus `Ok`/`Message` shape mismatch in the decision functions remains unreachable while the tail checks the dependency decision first (research §2.5).
  - Specs reported by AC-08 as carrying a derived numeric criterion without research evidence (pre-dating the evidence requirement) are listed for the epic-level report; they are not edited by E3.
  - Latent discovery prefix match on `scripts/dev_tools/discovery/profile_cli.py` (addendum §5) is unreachable with the default declaration reader; recorded for the epic-level report.
- Links:
  - Issue: https://github.com/drmoisan/drm-copilot/issues/905
  - Parent issue: https://github.com/drmoisan/drm-copilot/issues/897
  - Epic: `docs/features/epics/subagentstop-envelope/epic.md` (epic issue #904)
  - Research: `docs/features/active/subagentstop-envelope-artifact-gates-905/research/2026-10-11T12-05-subagentstop-envelope-artifact-gates-research.md`
  - Research addendum: `docs/features/active/subagentstop-envelope-artifact-gates-905/research/2026-10-11T10-26-subagentstop-envelope-artifact-gates-addendum-research.md`
  - Upstream: E1 `docs/features/active/subagentstop-envelope-core-897/spec.md`, section "Authoritative Helper Contract" (branch `bug/subagentstop-envelope-core-897`)
  - Precedents: #501 (`docs/features/completed/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/spec.md`), #786 / PR #881 (`docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md`)
