# codex-review-coverage-hook-reads-stale-or-foreign-artifacts (Spec)

- **Issue:** #1114
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07
- **Status:** Approved for planning (owner decisions recorded below)
- **Version:** 1.0
- **Work Mode:** full-bug
- **Branch:** bug/codex-coverage-hook-freshness
- **Research:** `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/research/research.2026-11-07T18-25.md`

## Context
The Codex review coverage hook, `.codex/hooks/validate-feature-review-coverage.ps1`, reads coverage reports with no freshness check, and it selects the newest policy audit across all active feature folders. It can therefore judge a review against stale coverage or against another item's audit. Issue #1105 (PR #1113) fixed the same defect class in the Claude hooks and left this Codex twin out of scope.

Environment:
- OS/version: Windows 11 Pro, PowerShell 7; the Codex hook suites also run on Linux in CI (`poshqc / PowerShell hook suites (Linux)`).
- Python version: 3.13 (Poetry environment), used only by the pytest contract tests; the hook itself uses no Python.
- Command/flags used: Codex runtime review stop with `.codex/hooks/validate-feature-review-coverage.ps1`, registered in `.codex/config.toml` under `[[hooks.SubagentStop]]` with matcher `feature-review|feature-reviewer`.
- Data source or fixture: any checkout with more than one active feature folder, or with a coverage report older than the item's latest commit.

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence
Steps to Reproduce:
1. Have two active feature folders, each with a policy audit, with the other item's audit written more recently.
2. Run a Codex feature review for the first item.
3. Observe the hook select the other item's audit.
4. Separately, leave a coverage report older than the item's newest commit, and observe the hook accept it.

Expected:
The hook reads the policy audit of the item under review, and the coverage report from that item's worktree. It blocks with a clear message when the report is missing or older than the newest item commit that touches the language, matching the Claude behaviour from #1105.

Actual:
The hook picks the newest policy audit across all active feature folders and reads coverage reports without checking their age. A review can pass or fail on another item's audit or on stale coverage.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: reported by the #1105 orchestrator, 2026-11-07, as an out-of-scope finding.

Code-level evidence (verified by reading the item worktree; research sections 1.3 and 1.4):
- `Get-LatestPolicyAudit -RepoRoot` enumerates every `policy-audit.*.md` under `docs/features/active` and returns the one with the greatest `LastWriteTime`. Feature folders are tracked, so every checkout carries every active item's audits; the selection is by recency across items.
- `Get-ChangedLanguageSet -RepoRoot` and `Get-LanguageRepoCoverage -RepoRoot` read beneath the session root only. An absent report returns `$null` and the floor check is skipped silently. No freshness check exists.
- The hook reads only `stop_hook_active`, `hook_event_name`, and `agent_type` from the payload; it never reads `last_assistant_message`, the only stable identity-bearing field in the Codex SubagentStop payload.

## Scope & Non-Goals
- In scope:
  - Selecting the policy audit by item identity from the reviewer's final message (`last_assistant_message`) instead of by recency.
  - Resolving the item root through the existing Codex resolver twin `.codex/hooks/hook-target-worktree.ps1` (`Resolve-HookTargetWorktree`) and reading the PR context summary, root `CLAUDE.md`, and coverage reports beneath that root.
  - A coverage freshness decision for the item worktree, with the same rule as #1105, delivered as a function-text twin `.codex/hooks/validate-feature-review-coverage-freshness.ps1` of `.claude/hooks/validate-feature-review-coverage-freshness.ps1`.
  - A new Codex-only functions file `.codex/hooks/feature-review-coverage-target.ps1` for path extraction, target and audit selection, and the mockable git and worktree-list wrappers.
  - Bundle mirrors, the Codex `core.json` pack manifest entries, and the contract-test name registrations for the new files.
  - The `## Hook Execution Context` bullet of the execution-environment brief, in every byte-identical copy.
  - Pester suites for the new and changed Codex files.
- Out of scope / non-goals:
  - Any change to a Claude production file (`.claude/hooks/`, `.claude/lib/`) or its mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` or `.../.claude/lib/`. The brief copy under `.claude/skills/execution-environment/` and its bundle mirror are the only `.claude`-tree edits.
  - A freshness probe when the resolved item root equals the session root (decision D1).
  - A recency fallback when no audit is identifiable (decision D2).
  - Enforcing a branch-coverage floor on Codex (only the line floor is enforced today; unchanged).
  - Reading the Codex delegation prompt or any transcript content (`transcript_path`, `agent_transcript_path`).
  - Changes to `.codex/config.toml` or its bundle copy (the hook name and registration are unchanged).
  - Changes to `.codex/hooks/hook-target-worktree.ps1` (used as is; no second resolver).
- Explicitly excluded systems, integrations, or datasets:
  - The Claude review coverage hook and its helpers (already fixed by #1105).
  - The Codex discovery hooks' `.claude` self-hosting fallback mechanism (not extended to this hook).
  - Python in any hook file (prohibited; see Constraints).

## Root Cause Analysis
The Claude fix for #1105 added `.claude/hooks/subagentstop-target-worktree.ps1`, which reuses `Resolve-HookTargetWorktree`, plus a freshness check in `.claude/hooks/validate-feature-review-coverage-freshness.ps1`. The Codex hook predates that fix and was left out of its scope. It has three independent defects:

1. Identity: it resolves the audit by recency (`Get-LatestPolicyAudit`) rather than by the item under review, because it never reads `last_assistant_message`.
2. Location: it reads the PR summary and coverage reports beneath the session root, never beneath the reviewed item's worktree.
3. Freshness: it applies no age check to a coverage report, and an absent report silently skips the floor check.

The Claude helpers cannot be dot-sourced from the Codex hook: `E4-ST7` in `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` forbids a `.claude` dot-source, Codex consumer installs do not ship `.claude/`, and the Claude identity path reads the Claude transcript JSONL shape, which the Codex documentation states is not a stable hook interface.

## Proposed Fix

### Design summary (what changes where):
Research approach A, as decided by the owner.

- The Codex hook reads `last_assistant_message` and extracts policy-audit paths from it (new logic in `.codex/hooks/feature-review-coverage-target.ps1`).
- When an extracted path is absolute, the item root is resolved with `Resolve-HookTargetWorktree -SessionRoot <session root> -FilePath <absolute paths>` from the dot-sourced `.codex/hooks/hook-target-worktree.ps1`, and the path is made repository-relative with `Get-HookTargetWorktreeRelativePath`. A relative path resolves to the session root, which is the resolver's own rule.
- The audit is selected from the extracted paths (rules under Data flow below). `Get-LatestPolicyAudit` and every recency enumeration of `docs/features/active` are removed.
- The item root is passed to the existing `Get-ChangedLanguageSet -RepoRoot`, `Get-LanguageRepoCoverage -RepoRoot`, and the root `CLAUDE.md` read.
- Before the floor check, the hook calls `Get-FeatureReviewCoverageFreshnessDecision -WorktreeRoot <item root> -SessionRoot <session root> -Source <resolver source> -ChangedLanguage <set> -GitInvoker <wrapper>` from the new twin `.codex/hooks/validate-feature-review-coverage-freshness.ps1`. A non-null result is emitted through the existing continuation contract.

### Boundaries and invariants to preserve:
- The Codex hook contains no dot-source whose text contains `.claude`, and contains neither `subagentstop-envelope.ps1` nor `Exit-SubagentStopBlock` (`E4-ST7`).
- The hook help keeps the two sentences "an absent root CLAUDE.md uses the defaults" and "an unreadable root CLAUDE.md fails closed" in its first comment token (`E4-ST3` in `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`).
- `Test-LanguageCoverageRow`, `Get-CoverageNarrowingLine`, and the thresholds dot-source keep their text, so the narrowing and floor parity suites are unaffected.
- The Codex output contract is unchanged: a finding emits `Get-FeatureReviewCoverageContinuation` JSON with `decision = block` once, and `continue = false` when `stop_hook_active` is true, with exit 0; malformed payloads exit 2 with the reason on stderr.
- The freshness twin's four function definitions are text-identical to the Claude file; the twin has no statement outside function definitions; it carries its own Codex header.
- No second resolver: the hook uses `Resolve-HookTargetWorktree` from `.codex/hooks/hook-target-worktree.ps1` only.
- Each `.codex/hooks` file stays at or below 500 lines (`legacy-codex-hook-contracts.Tests.ps1`).
- No Claude production file changes; no Python in hooks.

### Dependencies or blocked work:
- Depends on the #1105 Claude freshness file `.claude/hooks/validate-feature-review-coverage-freshness.ps1` as merged on `main` (PR #1113). The orchestrator confirms at Phase 0 that `main` has not changed that file or the Codex hook since the research.
- No blocked work.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
Production:
- `.codex/hooks/validate-feature-review-coverage.ps1` (modify).
- `.codex/hooks/validate-feature-review-coverage-freshness.ps1` (new).
- `.codex/hooks/feature-review-coverage-target.ps1` (new).
- Bundle mirrors of the three files above under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` (byte-identical).
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (entries for the two new hook files).
- Execution-environment brief, every copy enumerated by `_BRIEF_COPIES` in `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.

Tests:
- `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` (update and add rows).
- `tests/scripts/codex-hooks/validate-feature-review-coverage-freshness.Tests.ps1` (new).
- `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1` (new).
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (add the two new file names to `$script:SharedModuleNames`).

#### Functions/classes/CLI commands impacted:
- Removed: `Get-LatestPolicyAudit` (Codex hook).
- Changed: the Codex hook entry point (reads `last_assistant_message`; new ordering below); call sites of `Get-ChangedLanguageSet`, `Get-LanguageRepoCoverage`, and the `CLAUDE.md` read receive the item root.
- New, in `.codex/hooks/feature-review-coverage-target.ps1` (names are indicative; the plan fixes them): a policy-audit path extractor over the reviewer message; an audit selector over the extracted paths; a target resolver that calls `Resolve-HookTargetWorktree`; `Invoke-CodexReviewCoverageGitLog` (git wrapper passed as `-GitInvoker`); a worktree-list wrapper passed as `-WorktreeListInvoker`.
- New twin, in `.codex/hooks/validate-feature-review-coverage-freshness.ps1`: `Get-FeatureReviewCoverageReportPath`, `Get-FeatureReviewCoveragePathspec`, `Get-FeatureReviewReportLastWriteUtc`, `Get-FeatureReviewCoverageFreshnessDecision`.
- Used unchanged: `Resolve-HookTargetWorktree`, `Get-HookTargetWorktreeRelativePath` (`.codex/hooks/hook-target-worktree.ps1`); `Get-FeatureReviewCoverageThreshold` (`.codex/hooks/feature-review-coverage-thresholds.ps1`); `Test-LanguageCoverageRow`; `Get-CoverageNarrowingLine`; `Get-FeatureReviewCoverageContinuation`.

#### Data flow and validation changes:
Ordering: payload validation -> audit path extraction -> item root resolution -> audit selection and existence -> changed-language read -> freshness decision -> thresholds -> row rule.

- Extraction: policy-audit paths in `last_assistant_message` matching `docs/features/active/<folder>/[<version>/]policy-audit.<timestamp>.md` or `docs/features/active/<folder>/audit/<timestamp>/policy-audit.md`; relative or absolute; `/` or `\` separators; with or without a `policy-audit-path:` label. A `null` or non-string message yields no paths. A path containing a `..` segment is rejected.
- Item root: absolute paths go to `Resolve-HookTargetWorktree`; a `TARGET_WORKTREE_AMBIGUOUS` result (paths in several worktrees) blocks. An absolute path outside every registered worktree falls back to the session root per the resolver; the existence probe then decides. Relative paths resolve to the session root.
- Audit selection: one distinct `(folder, timestamp)` -> that audit; several audits in one folder -> the lexicographically greatest timestamp; audits in different folders -> block (ambiguous); none -> block (D2). The selected audit must exist beneath the item root, otherwise block.
- Freshness (D1): runs only when the resolved item root differs from the session root. It reports an absent PR context summary, an absent report for a changed language, a report whose last-write time is earlier than the committer time of the newest commit in the item root that touches the language's pathspecs, and a git failure.
- Session-root case: same reads as today except that the audit is the one the reviewer named; no freshness probe.

#### Error handling and logging updates:
- Every new condition uses the existing continuation contract (`decision = block` once; `continue = false` when `stop_hook_active` is true). The Codex contract has no repairable or non-repairable distinction and none is added; a git failure in the freshness decision is reported in the same continuation.
- Continuation reasons name the condition and its subject: the D2 message asks the reviewer to state the policy-audit path; an ambiguous message names the conflicting folders or worktrees; a missing audit names the path and the item root; freshness reasons carry the twin's text (language, expected report path, item root, and both times for a stale report).
- Each new guarded dot-source keeps the existing failure prefix: a failed dependency exits 2 with a `validate-feature-review-coverage:` message naming it.
- No new logging channel.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is a revert of the change; the Claude hooks are untouched, and the Codex registration is unchanged, so a revert restores the prior Codex behaviour exactly.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: Codex SubagentStop payload on stdin. Read fields: `stop_hook_active` (boolean, required), `hook_event_name` (`SubagentStop`), `agent_type` (`feature-review` or `feature-reviewer`), `last_assistant_message` (nullable string).
- Output: unchanged continuation JSON on stdout with exit 0 for findings; exit 0 with no output for a pass; exit 2 with stderr for malformed input or a failed dependency load.
- Function contract of the freshness twin: identical to the Claude file (`-WorktreeRoot -SessionRoot -Source -ChangedLanguage -GitInvoker`; returns `$null` or a decision object).

#### Required configuration keys and defaults:
- None added. Thresholds continue to come from root `CLAUDE.md` via `Get-FeatureReviewCoverageThreshold` (absent -> defaults; unreadable -> fails closed), read beneath the item root.

#### Backward-compatibility expectations:
- A single-item checkout whose reviewer names its audit and whose reports are fresh behaves as today.
- A reviewer message that names no audit now blocks once (previously the hook used the newest audit in the checkout). This is the intended D2 change.
- The existing entry-point rows keep their asserted outcomes once their payloads name the audit path; `exits 0 when no policy audit exists` changes outcome per D2.

#### Performance constraints (latency/throughput/memory):
- The hook must complete within the registered `timeout = 30` seconds. The added work is one regex pass over the reviewer message, at most one `git worktree list` call (only for absolute paths), and, for an item root other than the session root, one `git log -1` per changed language. No constraint beyond the registered timeout is set.

## Owner Decisions
- Design: research approach A. Codex-local audit-path extraction from `last_assistant_message`; item root through the existing Codex resolver twin `.codex/hooks/hook-target-worktree.ps1` (`Resolve-HookTargetWorktree`; no second resolver); a function-text twin `.codex/hooks/validate-feature-review-coverage-freshness.ps1` of `.claude/hooks/validate-feature-review-coverage-freshness.ps1` pinned by a parity test. New Codex-only logic in `.codex/hooks/feature-review-coverage-target.ps1`. No `.claude` dot-source from the Codex hook (`E4-ST7`). No Claude production file changes. No Python in hooks.
- D1 (freshness scope): identical to #1105. The probe runs only when the resolved item root differs from the session root. A Codex session started inside the item worktree keeps today's no-freshness behaviour there, as Claude does.
- D2 (no identifiable audit): block once with a repairable message asking for the policy-audit path; `continue = false` when `stop_hook_active` is true. No recency fallback.
- Keep behaviour unchanged for a single-item checkout whose reviewer names its audit and whose reports are fresh.
- Update the execution-environment brief `## Hook Execution Context` bullet in every byte-identical copy to cover the Codex hook.

Rejected alternatives (research section 6): dot-sourcing the Claude helpers; publishing through a `.codex/lib` virtual root with a `.claude` fallback; a byte-identical whole-file copy of the Claude freshness file; reading the delegation prompt from the transcript; a session checkpoint `feature-folder` fallback.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - A compliant Codex feature reviewer names the policy-audit path in its final message (`.codex/agents/feature-reviewer.toml`, `Final response contract`: "Report every artifact path created or updated").
  - The Codex SubagentStop payload carries `last_assistant_message` as documented externally and as already read by `.codex/hooks/validate-discovery-agent-output.ps1`.
  - `git` is on PATH in the hook process.
- Constraints (budget, performance, compatibility):
  - Codex hook files are capped at 500 lines.
  - No `.claude` path in the Codex hook; no Python in hooks; no Claude production file changes.
  - Tests use in-memory seams only: no temporary files, no real git, no reads of gitignored `artifacts/` state.
  - Fixture roots are `/`-rooted forward-slash literals in exact case joined with `Join-Path`, with no drive letters, so the suites pass on the case-sensitive Linux CI runner.
  - The production PowerShell write set exceeds the direct-mode batch cap; the run holds a non-terminal `large`, `remediation`, or `preparation` route in the item worktree checkpoint before the fourth production PowerShell write.
- External dependencies (services, libraries, releases):
  - Pester and PoshQC (existing). No new dependency.

## Data / API / Config Impact
- User-facing or API changes: a Codex feature review now blocks when the reviewer message names no policy audit, names audits of different items, or names an audit that does not exist beneath the item root; and, in an item worktree, when a coverage report is absent or stale.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none beyond the continuation reason text.
- Compatibility notes (CLI flags, config schemas, versioning): `.codex/config.toml` is unchanged. The Codex core pack gains the two new hook files, so a push-down publishes them alongside `hook-target-worktree.ps1`, which already ships in core.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: audit selection by item identity; coverage freshness against the newest item commit per language; a missing report; another item's newer audit present.
- [ ] Integration scenario to retest: a Codex review stop with two active items and a stale report.
- [ ] Manual verification notes: reuse the #1105 design and helpers where the Codex runtime allows, and keep behaviour unchanged for a single-item checkout with a fresh report.

- Regression tests to add or update:
  - `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`: replace `returns no audit when the active folder is absent` and `returns the most recently written audit` (they test the removed recency selection); update the entry-point rows `exits 0 when the branch changes no tracked language`, `requests a continuation when a changed language lacks a verdict`, `stops the continuation loop when a validator error occurs with the stop hook active`, `E4-TR7`, `E4-TR8`, and both `E4-TR9` rows so that their payloads name the audit path in `last_assistant_message`, with unchanged asserted outcomes; replace `exits 0 when no policy audit exists` with the D2 block row; add entry rows for the two-item foreign-audit case, a stale report in an item worktree, an absent report in an item worktree, and the two-item stale-report integration scenario. The foreign-audit and stale-report rows are recorded failing against the unfixed hook before the fix.
  - `tests/scripts/codex-hooks/validate-feature-review-coverage-freshness.Tests.ps1` (new): function-name set and per-function extent-text parity with the Claude file; no statement outside function definitions; the freshness scenarios of `tests/scripts/claude-hooks/validate-feature-review-coverage-freshness.Tests.ps1` run against the dot-sourced Codex twin.
  - `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1` (new): extraction shapes, labels, separators, relative and absolute paths, resolver ambiguity, greatest-timestamp selection, cross-folder ambiguity, `..` rejection, null and non-string message, missing audit beneath the item root, and the git and worktree-list wrappers.
  - `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`: register the two new names in `$script:SharedModuleNames`.
- Unit tests (Pester) for the fixed behavior and boundaries: as above. Pytest is used only for the existing contract tests named in the acceptance criteria.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): null or non-string `last_assistant_message`; audit path with `..`; audits of two folders; absolute paths in two worktrees; absolute path outside every worktree; several audits of one folder; named audit absent beneath the item root; absent PR summary in an item worktree; report written at exactly the reference commit time (passes); git non-zero exit, empty output, non-integer output, and a throwing invoker (fail closed).
- Error handling and logging verification: assertions on the continuation JSON `decision`, `continue`, and `reason` substrings naming the audit path, the item root, and the stale or absent language; `hook-dependency-failure.Codex.Tests.ps1` gains a `B1` row for each new guarded dot-source automatically and must pass.
- Coverage impact and targets for changed lines/modules: each of `.codex/hooks/validate-feature-review-coverage.ps1`, `.codex/hooks/validate-feature-review-coverage-freshness.ps1`, and `.codex/hooks/feature-review-coverage-target.ps1` reaches at least 85% line coverage, measured from `artifacts/pester/powershell-coverage.xml` of a direct `Invoke-PoshQCParallelTest` run (PoshQC MCP results carry no output). Pester measures no branch coverage, so no branch gate applies.
- Toolchain commands to run (format -> lint -> type-check -> test): PoshQC format, PoshQC analyze, (type check not applicable to PowerShell), architecture-boundary tests where configured, `Invoke-PoshQCParallelTest`, the pytest contract tests named below, and `scripts/dev_tools/generate_codex_agent_variants.py --check`. Phase 0 baseline under `<FEATURE>/evidence/baseline/`; fail-before and pass-after results under `<FEATURE>/evidence/regression-testing/`; final QA under `<FEATURE>/evidence/qa-gates/`.
- Manual validation steps (if required): none. Branch hooks are not exercised by isolated subagents until merge, so acceptance rests on the Pester rows and contract tests.

## Acceptance Criteria
- [x] Foreign-audit selection is fixed: in `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`, the entry-point row `1114: judges the audit named by the reviewer when another item's audit is newer` passes, and evidence under `<FEATURE>/evidence/regression-testing/` shows the same row failing against the unfixed hook.
- [x] Recency selection is removed: `Get-LatestPolicyAudit` no longer exists in `.codex/hooks/validate-feature-review-coverage.ps1`, the hook contains no enumeration of `docs/features/active`, and the rows `returns no audit when the active folder is absent` and `returns the most recently written audit` in `validate-feature-review-coverage.Coverage.Tests.ps1` are replaced by target-selection rows.
- [x] A stale report in an item worktree blocks: the entry-point row `1114: blocks a report older than the newest item commit for the language in an item worktree` passes, its continuation reason names the language and the item root, and evidence shows the row failing against the unfixed hook.
- [x] An absent report in an item worktree blocks: the entry-point row `1114: blocks an absent coverage report for a changed language in an item worktree` passes, and its continuation reason names the language, the expected report path, and the item root.
- [x] The integration scenario holds: the entry-point row `1114: with two active items and a stale report the review of the named item is blocked on freshness` passes.
- [x] Missing audit path (D2): the entry-point row `1114: blocks once asking for the policy-audit path when the reviewer names none` passes, and the companion row `1114: stops the continuation when no audit is named and the stop hook is active` asserts `continue = false`; no recency fallback exists.
- [x] Ambiguous or invalid audit paths block: `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1` passes rows covering audits named in different feature folders, a `TARGET_WORKTREE_AMBIGUOUS` resolver result, a path with a `..` segment, a named audit that does not exist beneath the item root, and a null or non-string `last_assistant_message`; each blocking case yields one continuation that names the condition.
- [x] Audit extraction and selection follow the specified rules: `feature-review-coverage-target.Tests.ps1` passes rows for both audit path shapes, both separators, labelled and unlabelled paths, relative paths (session root), absolute paths (resolved through `Resolve-HookTargetWorktree` and made relative with `Get-HookTargetWorktreeRelativePath`), and greatest-timestamp selection among several audits of one folder.
- [x] Freshness scope matches #1105 (D1): `tests/scripts/codex-hooks/validate-feature-review-coverage-freshness.Tests.ps1` passes the no-probe rows for a `SessionRoot` source, a root equal to the session root, and a blank root, against the dot-sourced Codex twin.
- [x] Freshness twin parity: `validate-feature-review-coverage-freshness.Tests.ps1` passes rows asserting that the Codex twin's function-name set and each function's extent text equal those of `.claude/hooks/validate-feature-review-coverage-freshness.ps1`, and that the twin has no statement outside function definitions.
- [x] Single-item fresh behaviour is unchanged: the updated rows `exits 0 when the branch changes no tracked language`, `requests a continuation when a changed language lacks a verdict`, `stops the continuation loop when a validator error occurs with the stop hook active`, `E4-TR7`, `E4-TR8`, both `E4-TR9` rows, `requests one continuation, then stops when the stop hook is already active`, and every `exits 2 for <Case>` row pass with their prior asserted outcomes, and `feature-review-coverage-narrowing-parity.Tests.ps1` and `feature-review-coverage-floor-parity.Tests.ps1` pass unchanged.
- [x] Runtime isolation is preserved: `E4-ST7: the Codex hook reads the floor from its own thresholds copy` passes, and `E4-ST3` in `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` passes with both `CLAUDE.md` help sentences present in the Codex hook.
- [x] Dependency-load failures are handled: `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` passes, including a `B1` row for each new guarded dot-source, each exiting 2 with the `validate-feature-review-coverage:` prefix naming the failed dependency.
- [x] No Claude production behaviour changes and no Python enters a hook: no file under `.claude/hooks/`, `.claude/lib/`, or their mirrors under `extensions/drm-copilot/resources/claude-customizations/` differs from the merge base; no `.py` file is added under `.codex/hooks/`; and the Claude suites `validate-feature-review-coverage-freshness.Tests.ps1`, `validate-feature-review-coverage.Tests.ps1`, `validate-feature-review-coverage.TargetWorktree.Tests.ps1`, and `validate-feature-review-coverage.Coverage.Tests.ps1` under `tests/scripts/claude-hooks/` pass.
- [x] Mirror and manifest parity: with `validate-feature-review-coverage-freshness.ps1` and `feature-review-coverage-target.ps1` added to `$script:SharedModuleNames`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes (parse, at most 500 lines, byte-identical bundle copy, no `$env:CLAUDE_`, listed in the Codex `core.json`) for each of those new files and for the modified hook.
- [x] Bundle contract tests pass: `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`), `test_bundled_codex_files_are_listed_in_some_pack_manifest` (`tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`), `test_codex_manifest_powershell_dependency_closure` (`tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`), and `scripts/dev_tools/generate_codex_agent_variants.py --check` exits 0.
- [x] Brief parity: the `## Hook Execution Context` bullet of the execution-environment brief names `.codex/hooks/validate-feature-review-coverage.ps1`, its audit selection from the reviewer message, its item root through `.codex/hooks/hook-target-worktree.ps1`, and its freshness twin, in every copy enumerated by `_BRIEF_COPIES`; `test_brief_copies_are_byte_identical`, `test_brief_has_required_headings`, `test_brief_has_no_consuming_names`, and `test_brief_has_no_g11_or_g12_findings` in `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` pass.
- [x] Coverage: `.codex/hooks/validate-feature-review-coverage.ps1`, `.codex/hooks/validate-feature-review-coverage-freshness.ps1`, and `.codex/hooks/feature-review-coverage-target.ps1` each reach at least 85% line coverage in `artifacts/pester/powershell-coverage.xml` from a direct `Invoke-PoshQCParallelTest` run, recorded under `<FEATURE>/evidence/qa-gates/`.
- [x] Full toolchain pass: format, lint, architecture-boundary tests, Pester (`Invoke-PoshQCParallelTest`), and the pytest contract tests named above complete in a single pass with no new failures compared with the Phase 0 baseline recorded under `<FEATURE>/evidence/baseline/`.
- [x] CI-dependent: the `poshqc / PowerShell hook suites (Linux)` job passes on the PR head, including `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`, `validate-feature-review-coverage-freshness.Tests.ps1`, and `feature-review-coverage-target.Tests.ps1`. This criterion is checked off by the item's orchestrator run at S9 after the CI green gate.

## Risks & Mitigations
- Technical or operational risks:
  - A non-compliant reviewer that omits the audit path is blocked once (D2). Mitigation: the continuation message states exactly what to add; the agent contract already requires reporting every artifact path.
  - Function-text drift between the Claude freshness file and the Codex twin after a future Claude change. Mitigation: the parity rows in `validate-feature-review-coverage-freshness.Tests.ps1` fail on any drift.
  - The 500-line cap on Codex hook files. Mitigation: new logic lives in `feature-review-coverage-target.ps1`; `legacy-codex-hook-contracts.Tests.ps1` checks every file.
  - Linux-only failures from path case or separators. Mitigation: `/`-rooted exact-case fixtures with `Join-Path`; extraction accepts both separators without Windows path semantics; the Linux CI job is an acceptance criterion.
  - Test isolation: the existing suite mocks `Test-Path`, `Get-ChildItem`, and `Get-Content` at script scope. Mitigation: git and worktree-list calls go through named wrappers that tests mock; no default git invoker runs in tests; stdin and stderr are restored in `finally`.
  - The twin's `GitInvoker` default cannot run in tests. Mitigation: the hook always passes the mockable wrapper; the twin suite passes in-memory invokers.
  - A Codex session started inside the item worktree has no freshness probe (D1). This is an accepted consequence of parity with #1105, not an omission.
- Mitigations and rollbacks: revert the change; no data or configuration migration is involved.

## Rollout & Follow-up
- Release/rollout steps: merge to `main`; Codex consumers receive the change through the next extension release and push-down, which publishes the updated hook and the two new core-pack files.
- Post-fix monitoring or clean-up tasks: none planned. A future change to `.claude/hooks/validate-feature-review-coverage-freshness.ps1` must update the Codex twin in the same change, enforced by the parity rows.
- Links: issue #1114 (https://github.com/drmoisan/drm-copilot/issues/1114); related issue #1105 and PR #1113; research `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/research/research.2026-11-07T18-25.md`; promoted record `docs/features/potential/promoted/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts.md`.
