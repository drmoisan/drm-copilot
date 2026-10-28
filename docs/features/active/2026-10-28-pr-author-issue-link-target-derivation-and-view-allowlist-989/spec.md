# 2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist (Spec)

- **Issue:** #989
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-28T12-30
- **Status:** Draft
- **Version:** 0.2

## Context
Three defects in orchestration and PR-authoring tooling: (1) orchestrated runs do not pass their own issue to the pr-author delegation as author-asserted, so the PR body falls back to `- None` and the issue stays open after merge; (2) the `TARGET_WORKTREE_NOT_DERIVABLE` PreToolUse gate rejects `gh pr edit <N> --body-file <path>` because the command has no branch or issue signal and `gh pr edit` has no `--head` flag; (3) the pr-author agent cannot run `gh pr view`, so it cannot perform the `closingIssuesReferences` verification that the pr-author contract should require after every create or edit.

Environment:
- OS/version: Windows 11 and Linux CI
- Python version: not applicable
- Command/flags used: `gh pr create --body-file`, `gh pr edit <N> --body-file`, `gh pr view <N> --json closingIssuesReferences,body`
- Data source or fixture: `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-command-allowlist.ps1`, `.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Source documents: `issue.md` (this folder) and `research/research.2026-10-28T12-10.md`. The research note records findings from file reads only; no command was run by the researcher. Citations in this spec use symbols, headings, and test names rather than line numbers or commit identifiers.


## Repro & Evidence
Steps to Reproduce:
1. Run an orchestrated feature to the PR-authoring step with a checkpoint that records `issue-num` and a PR context that lists no verified autoclose issues.
2. Delegate to `Agent(pr-author)`; observe the PR body Auto-close section reads `- None` and the issue stays open after merge.
3. Run `gh pr edit <N> --body-file artifacts/pr_body_<N>.md` from the pr-author agent; observe the deny `TARGET_WORKTREE_NOT_DERIVABLE`, which recommends `--head`, an invalid flag for `gh pr edit`.
4. Attempt `gh pr view <N> --json closingIssuesReferences,body` from the pr-author agent; observe it is outside the agent's allowlist.

Expected:
- The orchestrate delegation names the run's issue as author-asserted, and the PR body emits `- Closes #NNN`.
- The hook derives the target from the current worktree's branch when the command carries no signal, and its message names the accepted forms for `gh pr create` and `gh pr edit`.
- The pr-author agent verifies closing references after every create or edit.

Actual:
- `Author-asserted autoclose issues` is never passed; PR body shows `- None`.
- `TARGET_WORKTREE_NOT_DERIVABLE` is returned for `gh pr edit` unless a `# branch: <branch>` shell comment is appended, which depends on incidental parsing: the `branch:` label alternative of the branch-signal pattern in `Find-WorktreeResolutionBranchSignal` matches anywhere in the command text, including a trailing shell comment.
- The agent reports the closing-reference check as unverified and hands it back to the caller.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `TARGET_WORKTREE_NOT_DERIVABLE: the call carries neither a canonical issue number line nor a branch signal (--head, --branch, or branch:)`


## Scope & Non-Goals
- In scope:
  - Orchestrate skill, orchestrator agent, and pr-author skill prose for the author-asserted delegation line and its use as a `- Closes #NNN` source.
  - A new Agent PreToolUse check inside `.claude/hooks/enforce-model-routing-receipt.ps1` that enforces the delegation line, with Pester coverage and static-contract rows for the prose edits.
  - A current-branch fallback for target derivation in `Resolve-PrAuthorWorktreeTarget`, a new sibling hook file holding the git wrapper and branch derivation, and a rewritten `TARGET_WORKTREE_NOT_DERIVABLE` message.
  - An exact-shape `gh pr view <digits> --json closingIssuesReferences,body` allowlist clause, the matching agent `tools:` entry, and pr-author skill and agent verification prose.
  - Claude bundle copies under `extensions/drm-copilot/resources/claude-customizations/`, including the new hook file and its `pack-manifests/core.json` entry.
- Out of scope / non-goals:
  - Changes to the worktree-resolution library (`WorktreeItemResolution.psm1`, `WorktreeTargetResolution.psm1`); `Find-WorktreeResolutionBranchSignal` is unchanged.
  - Feeding the derived branch into epic-scope resolution (`Resolve-EpicScopeCheckpoint`).
  - Using `Resolve-WorktreeItemTargetByPrNumber` as a cross-check for `gh pr edit <N>`; recorded as an optional planner decision, not adopted by default.
  - Extending `validate-pr-author-output.ps1` to enforce that closing references are reported; this stays a prompt-level obligation.
  - Changes to `.codex` agent variants or the Codex generator output.
  - Changes to PR-context collection or rendering code (`collector_documents.py`, `render.py`, `collector.py`).
- Explicitly excluded systems, integrations, or datasets:
  - Live GitHub validation of closing references; the hook compares the delegation line to the checkpoint `issue-num` only.
  - Copilot-side `.github` agents and prompts.

## Root Cause Analysis
- Defect 1: `.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)` and `.claude/agents/orchestrator.md` `## PR Creation Delegation` never mention auto-close. In addition, `.claude/skills/pr-author/SKILL.md` `## Issue/PR Reference Rules` sources `- Closes #NNN` only from the PR-context "Issues to autoclose" or "Author-asserted autoclose issues" sections; the latter is rendered from the PR Intent, and nothing reads a delegation prompt as a source. When the context lists none, the skill falls through to `- None`.
- Defect 2: `Resolve-PrAuthorWorktreeTarget` in `.claude/hooks/enforce-pr-author-skill-helpers.ps1` passes only command text to `Resolve-WorktreeItemTarget`, which returns NoTarget when no signal exists. The deny text produced in `Get-PrAuthorTargetCheckpointResolution` advises `--head`, which `gh pr edit` does not accept.
- Defect 3: `.claude/agents/pr-author.md` `tools:` and `Test-PrAuthorAllowlistForm` in `.claude/hooks/enforce-pr-author-command-allowlist.ps1` exclude `gh pr view`. No `.claude` surface currently states the `closingIssuesReferences` verification, so the post-create/edit verification is new text rather than a restoration.


## Proposed Fix

### Design summary (what changes where):
1. **Author-asserted delegation line (Defect 1).** Prose in the orchestrate skill and orchestrator agent requires the line `Author-asserted autoclose issues: #<issue-num>` in every `Agent(pr-author)` delegation prompt, omitted only when the checkpoint has no `issue-num` or the run is an epic child whose integration PR owns the closing keyword. Enforcement is a new check in `.claude/hooks/enforce-model-routing-receipt.ps1`, executed after the per-feature checkpoint is resolved and receipt presence is confirmed, only for subagent `pr-author`. It denies an `Agent(pr-author)` delegation that lacks the line when the resolved per-feature checkpoint has an `issue-num` and `epic_mode` is not true. Static-contract Pester rows pin the prose edits.
2. **Current-branch target derivation (Defect 2).** A new sibling hook file `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` holds a never-throwing mockable git wrapper (`git rev-parse --abbrev-ref HEAD`, injectable invoker) and `Get-PrAuthorCurrentBranch`. `Resolve-PrAuthorWorktreeTarget` falls back to the derived branch when the command carries no signal. The `TARGET_WORKTREE_NOT_DERIVABLE` message is rewritten to name the accepted forms. The file is registered in `pack-manifests/core.json` and copied into the Claude bundle.
3. **`gh pr view` allowlist (Defect 3).** `Test-PrAuthorAllowlistForm` gains an exact-shape clause for `gh pr view <digits> --json closingIssuesReferences,body`; `PrAuthorAllowlistFormText` is updated; `agents/pr-author.md` `tools:` gains `Bash(gh pr view *)`; the skill and agent gain a verification step; new AL rows pin the behavior.

### Boundaries and invariants to preserve:
- The epic-scope early return in `Invoke-ModelRoutingReceiptDecision` (`Resolve-EpicScopeCheckpoint`) is unchanged; the epic integration PR delegation is not subject to the new rule.
- Target-derivation ordering is: explicit signal in the command, else current checked-out branch, else deny. A signal that matches no live worktree does not trigger the fallback.
- A detached HEAD (including the literal `HEAD` printed by `--abbrev-ref`), a non-zero git exit, or empty output keeps the original NoTarget deny with the same reason code.
- Branch-based resolution continues to flow through the existing resolver so ambiguity handling and `SessionRoot`/`OtherWorktree` labelling are unchanged.
- The `TARGET_WORKTREE_NOT_DERIVABLE` message keeps the leading `<ReasonCode>: <Detail>` structure and the substring `--head`.
- Only the exact `gh pr view` form is allowed; every other form denies with `PR_AUTHOR_COMMAND_NOT_ALLOWED:`. The allowlist record checks (wrappers, substitutions, redirections, variable prefixes, delimiters) run before the form test and are unchanged.
- `Get-PrAuthorBypassReason` already returns allow for anything that is not structurally `gh pr create` or `gh pr edit`; the skill-gate hook is not changed.
- Hook code must not invoke Python, must not throw on git failure (an uncaught hook error exits 1, which PreToolUse treats as non-blocking), and must follow the guarded dot-source pattern used by existing sibling files.
- No production, test, or reusable script file may exceed 500 lines.

### Dependencies or blocked work:
- None blocking. The change touches more than three production PowerShell files once bundle copies and the new sibling are counted, so it belongs on the orchestrated large path.
- Isolated subagents run `main`'s copies of hook scripts, so hook behavior on this branch is proven by Pester, not by a live subagent.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

| File | Change |
|---|---|
| `.claude/skills/orchestrate/SKILL.md` | `## PR Authoring (pr-author Handoff)`: add the required line and the two omission conditions. |
| `.claude/agents/orchestrator.md` | `## PR Creation Delegation`: add a short sentence stating the same requirement and deferring to the skill. |
| `.claude/skills/pr-author/SKILL.md` | `## Issue/PR Reference Rules`: add the delegation-prompt source, the statement that it is valid even when the PR context lists no verified autoclose issues, and `- None` only when neither list has an entry. Reconcile `## PR Body Structure` item 11 ("only from verified autoclose lists") and the "if GitHub validation is unavailable, do not emit `Closes`" rule with the new source. Add the post-create/edit `gh pr view` verification step. Update `## Required --head on gh pr create (issue #687)` with the `gh pr edit` forms. |
| `.claude/agents/pr-author.md` | `tools:` gains `Bash(gh pr view *)`; allowed-forms paragraph gains the view form; verification step added; `gh pr edit` forms and run-from-item-worktree guidance added. |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | New author-asserted decision step for `pr-author`. |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | Dot-source the new sibling; fallback in `Resolve-PrAuthorWorktreeTarget`; rewritten message in `Get-PrAuthorTargetCheckpointResolution`; update the header comment that says pr-author passes `--head` on every create. |
| `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` (new) | Git wrapper, `Get-PrAuthorCurrentBranch`, fallback-text builder. |
| `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | `view` clause in the `gh` arm of `Test-PrAuthorAllowlistForm`; updated `PrAuthorAllowlistFormText` and header form list. |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Add the new hook path. |
| Claude bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/` | Byte-equal copies of every edited `.claude` file above and of the new hook file. |

Physical line counts of the three edited hook files must be confirmed with `@(Get-Content -LiteralPath <path>).Count` before editing. The helpers file is near the cap (reported at 438 lines by file read), which is why the wrapper and branch helpers live in the sibling file.

#### Functions/classes/CLI commands impacted:
- `Invoke-ModelRoutingReceiptDecision` (new step), reading `issue-num` through the already-imported `ConvertTo-WorktreeItemIssueNumber`.
- `Resolve-PrAuthorWorktreeTarget` (fallback), `Get-PrAuthorTargetCheckpointResolution` (message), `Get-PrAuthorBypassReason` and `Resolve-PrAuthorArtifactRoot` (consumers; unchanged).
- New: the git wrapper (following the `Invoke-PrAuthorDocsOnlyGitExe` precedent in `enforce-pr-author-skill.docs-only.ps1`, with an injectable `GitInvoker` returning `ExitCode` and `Output`), `Get-PrAuthorCurrentBranch`, and the fallback-text builder.
- `Test-PrAuthorAllowlistForm` and `$script:PrAuthorAllowlistFormText`.
- CLI forms: `gh pr create`, `gh pr edit <N>`, `gh pr view <N> --json closingIssuesReferences,body`, `git rev-parse --abbrev-ref HEAD`.

#### Data flow and validation changes:
- **Author-asserted check.** After the per-feature checkpoint is read and receipt presence is confirmed, for `pr-author` only: read checkpoint `issue-num`; skip when `$null`. Test for the `epic_mode` property by presence first (strict mode throws on a missing property, as handled in `Test-EpicBaseBranchOverride`); skip when true. Otherwise require a prompt line anchored at line start matching `Author-asserted autoclose issues:` followed by `#<issue-num>`, where the number is followed by a non-digit or end of line, so `#98` does not satisfy `#989`. Absent a match, deny.
- **Target fallback.** Resolve with the command text as today. When the result is NoTarget and neither `Find-WorktreeResolutionBranchSignal` nor `Find-WorktreeItemIssueSignal` finds a signal in the text, call `Get-PrAuthorCurrentBranch`. When non-null, re-resolve through `Resolve-WorktreeItemTarget` with the derived branch supplied as a `branch: <branch>` signal so the existing branch resolver applies. When null, return the original NoTarget result.
- **Branch derivation.** `Get-PrAuthorCurrentBranch` returns the trimmed branch name, or `$null` for non-zero exit, empty output, or the literal `HEAD`.
- **Allowlist clause.** Exact six tokens: `gh`, `pr`, `view`, `<digits>` matched by `^\d+$`, `--json`, `closingIssuesReferences,body`, all other tokens compared case-sensitively. This denies `--web`, `--comments`, `--jq`, `--template`, `-R/--repo`, extra or reordered fields, a missing number, a branch or URL argument, and any trailing token. The form is read-only by construction. The frontmatter `Bash(gh pr view *)` is broader than the hook by design: the frontmatter grants the tool class and the hook narrows it.
- **Verification step (skill and agent).** After every create or edit, run `gh pr view <N> --json closingIssuesReferences,body` as a single command, report the closing issue numbers found, and report any mismatch with the author-asserted list. Code spans in the skill and agent that start with `gh ` are scanned by AL-34, which substitutes `<N>` and `<branch>` and requires each span to be an allowed form; every such span must therefore be an allowed form (no bare `gh pr view`, no spans with extra flags).
- **Rewritten message.** After the reason code and detail, the message names: for `gh pr create`, `--head <branch>`; for `gh pr edit`, run from the item worktree (the branch is derived), or append a shell comment `# branch: <branch>`; and states that `--head` is not valid for `gh pr edit`.

#### Error handling and logging updates:
- The new author-asserted denial uses a new reason code within the hook's existing `MODEL_ROUTING_RECEIPT_BLOCKED:` family and names the expected line, including the issue number.
- `TARGET_WORKTREE_NOT_DERIVABLE` remains the reason code for underivable targets; only its guidance text changes.
- The git wrapper never throws; failures are returned as exit code and output and map to `$null` in `Get-PrAuthorCurrentBranch`. stderr is discarded.
- Disallowed `gh pr view` forms deny with the existing `PR_AUTHOR_COMMAND_NOT_ALLOWED:` prefix and the updated allowed-forms sentence.
- No new telemetry or log channels.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is a revert of the change set, including bundle copies and the `core.json` entry. Reverting the hook edits restores prior gate behavior; reverting the prose restores the prior delegation contract.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Delegation line: `Author-asserted autoclose issues: #<issue-num>`, one line in the `Agent(pr-author)` prompt, number from checkpoint `issue-num`.
- `Get-PrAuthorCurrentBranch`: input is an optional injectable git invoker; output is a branch-name string or `$null`.
- Git wrapper: input is git arguments and an invoker; output is an object with `ExitCode` and `Output`; never throws.
- Allowlist: input is a single command record; output is allowed or denied with the allowed-forms sentence.
- Verification command: `gh pr view <N> --json closingIssuesReferences,body`.
- pr-author decision: `- Closes #NNN` is valid from the PR-context verified list, the PR-Intent author-asserted list, or the delegation prompt line; `- None` is correct only when none has an entry.

#### Required configuration keys and defaults:
- Checkpoint keys read: `issue-num`, `epic_mode`. No new configuration keys. `.claude/settings.json` has no `gh pr` permission entries and requires no edit; the Agent PreToolUse registration of `enforce-model-routing-receipt.ps1` already exists.
- Manifest: the new hook path is added to `pack-manifests/core.json`.

#### Backward-compatibility expectations:
- Commands carrying a `--head`, `--branch`, or `branch:` signal or a canonical issue line take the unchanged path.
- Existing allowed forms (`gh pr create`, `gh pr edit`, receipt commands) are unchanged.
- Existing `Agent(pr-author)` tests in `enforce-model-routing-receipt.EpicScope.Tests.ps1` use checkpoints with no `issue-num` and are unaffected.
- Tests that mock `Resolve-PrAuthorWorktreeTarget` are unaffected by the inner fallback.
- The `--head` substring is retained in the deny message so the existing TargetResolution assertions still hold.

#### Performance constraints (latency/throughput/memory):
One additional local `git rev-parse` process in the NoTarget no-signal path only; no cost on the signal-present path. The Agent hook adds an in-memory string match. No throughput or memory constraints beyond hook responsiveness.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The hook process working directory is the pr-author subagent's session directory, so the derived branch is that of the worktree the agent runs in.
  - `epic_mode` and `issue-num` are present in the per-feature checkpoint when applicable; `epic_mode` may be absent and must be tested by property presence.
  - A CI pull-request checkout is a detached HEAD, which yields NoTarget by design.
- Constraints (budget, performance, compatibility):
  - 500-line file limit; the helpers file requires the sibling split.
  - Tests may not use temporary files or the real git executable; git, checkpoint reads, and the worktree resolver are reached through mocks of wrapper functions.
  - Linux CI hook suites run on a case-sensitive file system with no drive letters; synthetic roots are composed with `Join-Path` or the existing `/synthetic-worktrees/...` pattern.
  - Coverage must meet the root `CLAUDE.md` or default thresholds (line coverage at least 85% per changed or new PowerShell file, measured from `artifacts/pester/powershell-coverage.xml`; the new sibling counts in the denominator).
- External dependencies (services, libraries, releases):
  - `git` executable at runtime for the wrapper only; `gh` for the agent commands. No new libraries.

**Mirror surface.**
- Claude bundle copies under `extensions/drm-copilot/resources/claude-customizations/` for every edited `.claude` file and the new hook file, plus the `pack-manifests/core.json` entry: required, byte-equal.
- `.agents/skills/pr-author/SKILL.md` and its bundle copy: optional parity edit limited to the AC2 sentence; no contract test requires it.
- `.agents/skills/orchestrate/SKILL.md`: no edit (Codex-specific variant without a pr-author handoff section).
- `.codex` agent variants (`.codex/agents/pr-author*.toml`) and their bundle copies: no edit; no `.codex/hooks` counterpart exists for the changed hooks. The Codex generator `--check` is still run to confirm no drift.
- `.github` Copilot surfaces and converter fixtures: no edit.

**Residual limits.**
- Wrong-worktree derivation in parallel topologies: the fallback uses the hook process working directory. If the pr-author runs outside the item worktree with a no-signal command, the derived branch may belong to a coordinator or sibling worktree. This fails closed: with no checkpoint in the derived worktree the preflight denies (`ORCHESTRATOR_STATE_PREFLIGHT_FAILED`), and with a sibling's checkpoint the canonical `artifacts/pr_body_<N>.md` and matching receipt in that same worktree are still required, so a body authored elsewhere fails the receipt checks. Mitigation is policy text instructing the agent to pass signals when running outside the item worktree.
- Epic edge: when the working-directory branch is an epic integration branch, epic-scope resolution has already declined on the command text, so the fallback finds no per-feature checkpoint and denies. This is fail-closed and not a regression.
- The author-asserted check compares the delegation line to the checkpoint `issue-num` only; the deterrent is policy-level, in the same sense as the existing receipt gate, and it cannot confirm that the issue is correct for the PR.
- Hook behavior on this branch cannot be demonstrated by a live isolated subagent; acceptance relies on Pester evidence.

## Data / API / Config Impact
- User-facing or API changes: new required delegation line for orchestrated `Agent(pr-author)` calls; new hook deny for its absence; changed `TARGET_WORKTREE_NOT_DERIVABLE` guidance text; one additional permitted `gh pr view` form for the pr-author agent.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none beyond the new deny reason text.
- Compatibility notes (CLI flags, config schemas, versioning): no checkpoint schema change; `--head` remains valid for `gh pr create` and is documented as not valid for `gh pr edit`; new hook file added to the core pack manifest.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: Pester for the seam fallback (branch derived, detached HEAD, signal present, git failure), the deny message, and the allowlist `gh pr view` form; a validator/test failing when an orchestrated pr-author delegation omits the author-asserted line while the checkpoint has an `issue-num`.
- [ ] Integration scenario to retest
- [ ] Manual verification notes

### Acceptance Criteria

- [x] AC1: The orchestrate skill and `agents/orchestrator.md` require the pr-author delegation prompt to carry `Author-asserted autoclose issues: #<issue-num>`, omitted only when the checkpoint has no `issue-num` or the run is a child of an epic whose integration PR owns the closing keyword.
- [x] AC2: `skills/pr-author/SKILL.md` states that an issue named as author-asserted in the delegation prompt is a valid source for `- Closes #NNN` even when the PR context lists no verified autoclose issues, and that `- None` is correct only when neither list has an entry.
- [x] AC3: A test or validator check fails when an orchestrated run's pr-author delegation omits the author-asserted line while the checkpoint has an `issue-num`.
- [x] AC4: When a `gh pr create` or `gh pr edit` command carries no branch or issue signal, the PreToolUse hook derives the target from the current worktree's checked-out branch and applies the existing checks to that item; a detached HEAD or unreadable branch keeps the NoTarget deny.
- [x] AC5: The `TARGET_WORKTREE_NOT_DERIVABLE` message names the exact accepted forms for `gh pr edit` and `gh pr create` and states that `--head` is not valid for edit.
- [x] AC6: `agents/pr-author.md` allows `Bash(gh pr view *)`; the allowlist hook permits `gh pr view <N> --json closingIssuesReferences,body` and no other `gh pr view` form with write effect; allowlist tests cover the new entry.
- [x] AC7: `skills/pr-author/SKILL.md` and the agent require running `gh pr view <N> --json closingIssuesReferences,body` after every create or edit and reporting the closing references found.
- [ ] AC8: Every change is mirrored under `extensions/drm-copilot/resources/` and the `.agents`/`.codex` parallel surfaces as the contract tests require, and the seven-stage toolchain passes.

Interpretation notes for AC8: the contract tests require Claude bundle mirroring only. The `.agents` pr-author pair receives an optional AC2 parity sentence; no `.codex` change is made. AC3 is satisfied by the new Agent PreToolUse check and its Pester suite, not by static prose tests alone.

- Regression tests to add or update:
  - New: `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`. Rows: present line allows; missing line denies; wrong number denies; `#98` against `#989` prefix case denies; no `issue-num` allows; `epic_mode` true allows; other subagent types unaffected; epic scope unaffected. Reuse the `New-AgentPayload` and `Set-FeatureCheckpointSeam` pattern from `enforce-model-routing-receipt.EpicScope.Tests.ps1` (mocks `Resolve-ModelRoutingWorktreeTarget` and `Get-ModelRoutingCheckpoint`). Covers AC1 and AC3 enforcement.
  - New: static-contract rows in `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` or a new sibling contract file, using `Get-SkillSection` for the skills and equivalent heading extraction for `## PR Creation Delegation` in the agent file; tokens containing backticks use `.Contains`. Covers the prose of AC1, AC2, AC7.
  - New: `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1`. Rows: derived branch re-resolves to a worktree (SessionRoot and OtherWorktree); detached `HEAD` stays NoTarget; non-zero git exit stays NoTarget; empty output stays NoTarget; signal present does not call the git seam; a signal that matches no worktree does not trigger the fallback; ambiguity from the derived branch is returned unchanged; wrapper never-throw contract with an injected invoker; message rows for the accepted forms. Covers AC4 and AC5.
  - Update: `enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, row "pr-author R2 denies with the no-target code when only the sibling session-root checkpoint is present", and any sibling rows asserting the no-target prefix without mocking `Resolve-PrAuthorWorktreeTarget`: mock the branch seam to return `$null`.
  - Update: `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`, row "blocks gh pr create --body-file end-to-end in a real pwsh process (exit 0, deny, TARGET_WORKTREE_NOT_DERIVABLE)": the inner here-string script redefines the branch function to return `$null` after dot-sourcing the hook.
  - Update: `enforce-pr-author-command-allowlist.Tests.ps1`: new AL rows after AL-38 and updated synopsis comment (see below). Covers AC6.
  - Optional: a `gh pr view 5 --json closingIssuesReferences,body` allow row in `enforce-pr-author-skill.Tests.ps1` next to the existing `allows gh pr view 13` row.
  - Check: `enforce-pr-author-skill.TargetResolution.Tests.ps1` assertions of `--head` in the reason continue to hold because the new message retains that substring.
- Unit tests (pytest) for the fixed behavior and boundaries: not applicable to hook behavior (Pester only, per repository policy). Python contract tests are run, not extended: `test_push_down_claude_resource_contracts.py` (bundle equality), `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and the Codex generator `--check`.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Delegation line: missing, wrong issue number, prefix-number collision, no `issue-num`, `epic_mode` true or absent, non-pr-author subagent.
  - Branch derivation: detached HEAD, git non-zero exit, empty output, branch matching zero worktrees, branch matching more than one worktree, signal already present.
  - Allowlist deny rows: `gh pr view 5`, `gh pr view 5 --web`, `gh pr view 5 --json body`, `gh pr view 5 --json closingIssuesReferences,body --jq .number`, `gh pr view --json closingIssuesReferences,body`, `gh pr view abc --json closingIssuesReferences,body`, `gh -R owner/repo pr view 5 --json closingIssuesReferences,body`, and a redirected variant. Allow row: `gh pr view 5 --json closingIssuesReferences,body`.
- Error handling and logging verification: assert the new deny reason text names the expected delegation line; assert `TARGET_WORKTREE_NOT_DERIVABLE` message content for create and edit forms and the statement that `--head` is not valid for edit; assert the wrapper returns rather than throws.
- Coverage impact and targets for changed lines/modules: line coverage at least 85% for each changed or new PowerShell file, read from `artifacts/pester/powershell-coverage.xml`; the wrapper body is exercised with a test-local stand-in invoker so its lines are covered without a real process start. PowerShell has no branch-coverage gate. No coverage exclusions.
- Toolchain commands to run (format → lint → type-check → test): PowerShell formatting and PSScriptAnalyzer through the repository PoshQC toolchain (type check not applicable to PowerShell); architecture-boundary and unit stages including the touched Pester suites run in seeded shuffled order with at least three seeds, then a fresh single-process run over `tests/scripts`; Python contract tests listed above; Codex generator `--check`; `hook-dependency-guard-completeness.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1`; contract and integration stages as defined in the repository seven-stage loop.
- Manual validation steps (if required): none for acceptance. Test synopsis updates: the allowlist test header ("T-ALLOW, AL-01 to AL-37") and the hook header form list are updated. Grep `docs/` for a pr-author tool list and update it if present.


## Acceptance Criteria
- [ ] Repro steps now produce the expected behavior in all documented environments.
- [x] Regression test(s) added and passing (list file path and test name).
- [x] Edge cases and invalid inputs are handled with correct errors or fallbacks.
- [x] No unintended behavior changes outside the defined scope.
- [x] Required logs/telemetry updated and validated (if applicable).
- [x] Performance constraints met or explicitly waived with rationale.
- [x] Full toolchain pass completed (format → lint → type-check → test).
- [x] Docs/config references updated to match the new behavior.

## Risks & Mitigations
- Technical or operational risks:
  - Prose drift: the pr-author skill allows `Closes` from the prompt while `## PR Body Structure` item 11 still says "only from verified autoclose lists", or new prose names a command form that AL-34 rejects.
  - Test isolation: after the fallback, two existing rows (R2 in the WorktreeResolution suite and the real-pwsh row in the OrchestratorStatePreflight suite) would depend on the real checkout branch, passing locally on a named branch and differing on a detached CI checkout.
  - Coverage: the new sibling file could fall below the line threshold if the git-wrapper body is reachable only by a real call.
  - File size: the helpers file would exceed 500 lines if the fallback were inlined.
  - Mirror parity: every edited `.claude` file needs a byte-equal bundle copy and the new hook needs a manifest entry.
  - Wrong-worktree derivation in parallel topologies (see Residual limits).
  - Evidence: PoshQC MCP results carry no counts and live subagents run `main`'s hooks.
- Mitigations and rollbacks:
  - Edit `## PR Body Structure` item 11 and `## Issue/PR Reference Rules` together, and re-run the allowlist suite after prose edits.
  - Neutralize the branch seam in both existing rows; run touched suites in shuffled order with three seeds; never call real git in a unit test.
  - Use an injectable invoker, as `Invoke-PrAuthorDocsOnlyGitExe` does, and verify per-file coverage from the coverage XML.
  - Place the wrapper and branch helpers in the sibling file; confirm physical line counts after editing.
  - Run `test_push_down_claude_resource_contracts.py`, the two manifest tests, and the Codex generator `--check` after the edits.
  - Evidence is the Pester JUnit file and coverage XML under `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/evidence/`; no acceptance condition depends on a live subagent exercising the new hook.
  - Rollback: revert the change set including bundle copies and the manifest entry.

## Rollout & Follow-up
- Release/rollout steps: deliver through the orchestrated large path with Claude bundle mirrors; ship in the next extension release that carries the Claude customizations bundle.
- Post-fix monitoring or clean-up tasks:
  - Observe the next orchestrated PR authored after merge for `- Closes #NNN` in the Auto-close section and a closed issue after merge.
  - Decide whether to add the optional `Resolve-WorktreeItemTargetByPrNumber` cross-check for `gh pr edit <N>` if wrong-worktree derivation is observed.
  - Decide whether `validate-pr-author-output.ps1` should enforce that closing references are reported.
- Links: issue #989 (https://github.com/drmoisan/drm-copilot/issues/989); PRs: none yet; related docs: `issue.md` and `research/research.2026-10-28T12-10.md` in this folder; related prior work: issue #687 (required `--head` on `gh pr create`).
