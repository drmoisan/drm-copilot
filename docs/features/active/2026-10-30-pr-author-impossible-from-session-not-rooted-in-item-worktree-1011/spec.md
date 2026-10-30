# 2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree (Spec)

- **Issue:** #1011
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria source: this file only)
- **Research:** `docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011/research/research.2026-10-30T12-20.md`

## Context

PR authoring is impossible from a session not rooted in the item worktree. No combination of actions that the hook and the `pr-author` agent allow satisfies `.claude/hooks/enforce-pr-author-skill.ps1`, so the PR is never created. This is one of four sibling bugs that share the target-worktree resolver fix; the resolver itself is specified and delivered by sibling issue #1009.

Environment:
- OS/version: not recorded
- Python version: not applicable
- Command/flags used: `gh pr create --body-file ...` run by `pr-author` from a coordinator-rooted session for an item in another worktree
- Data source or fixture: hook `enforce-pr-author-skill.ps1`, the pr-author command allowlist hook `enforce-pr-author-command-allowlist.ps1`, the `pr-author` agent tool list (`Bash(sha256sum *)`, `Write(/artifacts/**)`), and the `pr-author` skill text

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence

Steps to Reproduce:
1. Run `pr-author` from a coordinator-rooted session for an item whose worktree is elsewhere.
2. The gate hook requires `gh pr create --body-file <absolute item-worktree path>/artifacts/pr_body_<N>.md`; a relative path is denied `PR_BODY_PATH_NONCANONICAL`.
3. The pr-author allowlist hook and skill text only produce and checksum the relative `artifacts/pr_body_<N>.md`.

Expected:
- pr-author resolves the item worktree from the `--head` branch, and the PR gate resolves the same worktree through the shared resolver.
- pr-author writes the body and the receipt under that worktree's `artifacts/`, and the PR context summary is present under the same `artifacts/` directory.
- pr-author checksums the body by absolute path.
- pr-author passes the absolute body path to `--body-file` together with `--head <branch>`.
- The gate hook's receipt checks are unchanged.
- The pr-author skill documents the coordinator-session topology explicitly.

Actual:
The relative path resolves to the coordinator checkout, so the body, its receipt, and the PR context summary land under the coordinator root while the gate hook looks under the item worktree. The allowlist hook denies an absolute `sha256sum` argument with `PR_AUTHOR_COMMAND_NOT_ALLOWED:` and offers no read-only command that maps a branch to its worktree. Writing the receipt under the item worktree is also denied by the preimplementation gate (sibling #1010).

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `PR_BODY_PATH_NONCANONICAL`

Research findings (summary):
- The gate hook already derives the item worktree from `--head` by identity (`Resolve-PrAuthorWorktreeTarget` -> `Resolve-WorktreeItemTarget`), reads the PR context summary, body, and receipt beneath the resolved worktree, and accepts an absolute canonical `--body-file` beneath it (issue #850).
- The blocking restrictions are on the pr-author side: the allowlist hook form set (`Test-PrAuthorAllowlistForm`), and the agent and skill text, which prescribe only relative paths.
- The `tools:` entries `"Bash(sha256sum *)"` and `"Write(/artifacts/**)"` are not the operative restriction; the frontmatter-registered allowlist hook is.

## Scope & Non-Goals

- In scope:
  - `Resolve-PrAuthorWorktreeTarget` in `.claude/hooks/enforce-pr-author-skill-helpers.ps1` consumes the shared resolver `Resolve-HookTargetWorktree` (operator decision on research OQ1).
  - Two new command forms in `.claude/hooks/enforce-pr-author-command-allowlist.ps1` (research OQ2).
  - Coordinator-session topology text in `.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`, and `.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)`.
  - Byte-identical bundled copies of every edited file under `extensions/drm-copilot/resources/claude-customizations/`.
  - Pester unit and contract tests for the above.
- Out of scope / non-goals:
  - Relaxing any receipt check in `Test-PrAuthorReceiptVerification`.
  - Codex runtime changes. No Codex counterpart of the pr-author gate or allowlist exists (research Question 2): `.codex/hooks/` has no `enforce-pr-author-*` file, `.codex/config.toml` registers no pr-author gate, and `.codex/agents/pr-author*.toml` and `.agents/skills/pr-author/SKILL.md` carry no receipt, body-path, or worktree text. The issue's "tests in every runtime carrying the hook" resolves to the Claude runtime and its bundled copies.
  - `.github/agents/pr-author.agent.md` and its bundled copy.
  - Creating or modifying `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` or its pack-manifest entry (owned by #1009).
  - The preimplementation-gate change that permits the receipt write into the item worktree (owned by #1010).
  - Worktree-isolation behavior and checkpoint schemas.
  - The execution-environment brief and its copies: no fact in the brief changes (research Question 7).
- Explicitly excluded systems, integrations, or datasets: GitHub API behavior of `gh pr create`; the Claude Code permission-rule matcher.

## Root Cause Analysis

The root is derived from the session project directory, not from the worktree being acted on. In the PR gate this is already mitigated by `--head` identity resolution, but that resolution is a local implementation rather than the shared resolver the sibling bugs converge on. On the pr-author side, the allowlist hook admits `sha256sum` only for the relative token `artifacts/pr_body_<digits>.md`, admits no command that maps a branch to a worktree path (`git` is limited to `log` and `rev-parse`; `git -C` and global options are denied), and the agent and skill text prescribe only relative paths for the body write, checksum, receipt, and `--body-file`. A pr-author running in a coordinator session therefore cannot produce an absolute body path, cannot checksum one, and has no documented procedure for doing so.

## Proposed Fix

### Design summary (what changes where):

1. PR gate resolver consumption. `Resolve-PrAuthorWorktreeTarget` in `.claude/hooks/enforce-pr-author-skill-helpers.ps1` is the single replacement point. It delegates `--head`/branch resolution to `Resolve-HookTargetWorktree` (imported from `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`) and maps the resolver result `{ WorktreeRoot, Source, Ambiguous }` onto the existing target statuses and deny codes:
   - `Ambiguous` true -> status `Ambiguous`, deny code `TARGET_WORKTREE_AMBIGUOUS`.
   - A resolved root equal to the session worktree -> status `SessionRoot`.
   - A resolved root that is a different registered worktree -> status `OtherWorktree`.
   - No root, or a root reached only through the session-root fallback source with no command signal -> status `NoTarget`, which continues through the existing `Resolve-PrAuthorCurrentBranchTarget` (#989) fallback and, if still unresolved, denies with `TARGET_WORKTREE_NOT_DERIVABLE`.
   - The issue #673 rule is preserved: a result whose `Source` is a path-derived source (file-tool target path, or a Bash operand path that is a feature-folder or other non-`--head` path) never selects the worktree for this gate; such a result is treated as carrying no branch signal.
   - Resolution by canonical issue line (portable identity) is unchanged.
2. Allowlist forms. `Test-PrAuthorAllowlistForm` in `.claude/hooks/enforce-pr-author-command-allowlist.ps1` gains exactly two forms:
   - The exact four-token command `git worktree list --porcelain`.
   - `sha256sum` with exactly one argument that is an absolute path: rooted at POSIX `/` or at a drive letter followed by `:/`; forward slashes only; no empty, `.`, or `..` segment; ending in `/artifacts/pr_body_<digits>.md`. It must be the whole command (no chain, wrapper, substitution, redirection, flag, or second argument).
   - The existing relative `sha256sum artifacts/pr_body_<digits>.md` form stays. Every other command remains denied with `PR_AUTHOR_COMMAND_NOT_ALLOWED:`. `$script:PrAuthorAllowlistFormText` and the script synopsis name both new forms.
3. pr-author agent and skill text (`.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`), same content in both: a coordinator-session topology subsection stating that when the process directory is not the item worktree, pr-author runs `git worktree list --porcelain`, selects the `worktree` entry whose `branch refs/heads/<head>` equals the `--head` branch, and uses that absolute root (forward slashes) as `<item worktree>`; zero or multiple matches stop with a report. It then writes `<item worktree>/artifacts/pr_body_<N>.md` and `<item worktree>/artifacts/pr_body_<N>.receipt.json` by absolute path, runs `sha256sum <item worktree>/artifacts/pr_body_<N>.md` as a single command, records `pr_body_path` and `context_summary_path` in the receipt as repo-relative values, and passes `--body-file <item worktree>/artifacts/pr_body_<N>.md` with `--head <branch>`. The text states that the PR context summary must already exist under `<item worktree>/artifacts/` (pr-author does not call `collect_pr_context`), that the receipt `created_at` must be newer than that summary, and that pr-author is delegated without worktree isolation in this topology. The item-rooted procedure (relative forms) is unchanged.
4. Orchestrate handoff text (`.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)`): `mcp__drm-copilot__collect_pr_context` is called with `workspace_root` set to the item worktree and `target_ref` set to the head branch; the delegation prompt carries `branch: <branch>`; pr-author derives the item worktree root itself (no absolute path in the prompt); the delegation is not worktree-isolated.

### Boundaries and invariants to preserve:

- Unchanged: `Resolve-PrAuthorArtifactRoot` and its epic-scope branch, the #989 current-branch fallback (`Resolve-PrAuthorCurrentBranchTarget`), Cases A/B/C in `Get-PrAuthorBypassReason`, `Invoke-OrchestratorStatePreflight` and its `$Invoker` seam, the docs-only exemption (`Get-PrAuthorDocsOnlyExemption`), the body-path binding (`Get-PrAuthorBodyPathBindingReason`), and every receipt check in `Test-PrAuthorReceiptVerification`.
- A feature-folder path never selects the worktree for the PR gate (issue #673).
- `RelativeBodyAllowed` remains true only for a `SessionRoot` target (or an epic root equal to the session worktree); a relative `--body-file` from a coordinator session is still denied with `PR_BODY_PATH_NONCANONICAL` naming the absolute canonical path.
- The allowlist hook remains a pure string decision: no process start, no file read, no module import.
- Receipt `pr_body_path` and `context_summary_path` remain repo-relative; no absolute path is encoded in a committed artifact.
- Text pinned by `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1` stays present: `--head is not valid for gh pr edit`, `# branch: <branch>`, the closing-reference section form, `"Bash(gh pr view *)"` in the agent `tools:`, and in `## PR Authoring (pr-author Handoff)` the strings `Author-asserted autoclose issues: #<issue-num>`, `issue-num`, and `epic_mode`.

### Dependencies or blocked work:

- #1009 must be merged to `main` before execution: it delivers `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` exporting `Resolve-HookTargetWorktree` (contract `{ WorktreeRoot, Source, Ambiguous }`; sources in order: file-tool target path, Bash operand path including a `--head` worktree, delegation-prompt identity, session-root fallback; injectable `git worktree list --porcelain` invoker) and its entry in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- #1010 must be merged to `main` before execution: the preimplementation gate evaluates the resolved target worktree, which lets pr-author write the receipt into the item worktree.
- Neither is on `main` at the time of writing. Execution begins by merging `origin/main` into this branch and verifying that the #1009 module, its exported function, its manifest entry, and the #1010 gate change are present. If either dependency is absent, execution stops and reports blocked; no substitute resolver or local copy is created.
- If the merged #1009 API differs in name or result shape from the contract above (research OQ3), the plan records the actual names before editing `Resolve-PrAuthorWorktreeTarget`; the mapping rules above remain the requirement.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production PowerShell:
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1`
- `.claude/hooks/enforce-pr-author-command-allowlist.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-command-allowlist.ps1`

Customization text:
- `.claude/agents/pr-author.md` and its bundled copy
- `.claude/skills/pr-author/SKILL.md` and its bundled copy
- `.claude/skills/orchestrate/SKILL.md` and its bundled copy

Tests:
- `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1` (update)
- `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` (update)
- `tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1` (new)
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` only if its rules require the new import to be registered

Every edited file that has a bundled copy changes byte-identically in the same commit. Pack manifests are not edited by this item; the resolver manifest entry is delivered by #1009.

#### Functions/classes/CLI commands impacted:

- `Resolve-PrAuthorWorktreeTarget` (body replaced; signature and returned target shape consumed by `Get-PrAuthorTargetCheckpointResolution` preserved).
- `Test-PrAuthorAllowlistForm` (`git` and `sha256sum` branches extended).
- `$script:PrAuthorAllowlistFormText` (deny guidance text).
- No change to `Get-PrAuthorBypassReason`, `Get-PrAuthorTargetCheckpointResolution`, `Resolve-PrAuthorArtifactRoot`, `Resolve-PrAuthorCurrentBranchTarget`, `Test-PrAuthorReceiptVerification`, or `Invoke-OrchestratorStatePreflight`.

#### Data flow and validation changes:

- Coordinator session: orchestrator calls `collect_pr_context` with `workspace_root` = item worktree and `target_ref` = head branch -> summary lands at `<item worktree>/artifacts/pr_context.summary.txt` -> orchestrator delegates pr-author (not isolated) with `branch: <branch>` -> pr-author runs `git worktree list --porcelain`, selects the entry by `branch refs/heads/<head>` -> writes body, checksums by absolute path, writes receipt -> runs `gh pr create --head <branch> --body-file <item worktree>/artifacts/pr_body_<N>.md` -> gate resolves the same worktree through `Resolve-HookTargetWorktree` and verifies the receipt beneath it.
- Item-rooted session: unchanged.

#### Error handling and logging updates:

- Allowlist denials keep the `PR_AUTHOR_COMMAND_NOT_ALLOWED:` prefix; the guidance text names the two new forms.
- Gate denials keep `TARGET_WORKTREE_NOT_DERIVABLE`, `TARGET_WORKTREE_AMBIGUOUS`, and `PR_BODY_PATH_NONCANONICAL` with their existing guidance text. No new deny code is introduced.
- pr-author stops and reports when `git worktree list --porcelain` yields zero or multiple entries for the head branch.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. Rollback is a revert of this item's commits; the allowlist forms and the resolver delegation are independent of persisted state.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Allowlist absolute `sha256sum` argument grammar: `( "/" | [A-Za-z] ":/" ) segment ( "/" segment )* "/artifacts/pr_body_" digits ".md"`, where each `segment` is non-empty, is not `.` or `..`, and contains no `/` or `\`. Segment case for `artifacts` is exact (`Artifacts/` is denied). The digit rule matches the existing relative form.
- `git worktree list --porcelain`: exact tokens; any other `git worktree` subcommand, flag, or ordering is denied.
- Resolver input to `Resolve-HookTargetWorktree`: the command text and session root, plus the injectable invoker supplied by #1009; output mapped as described in the Design summary.

#### Required configuration keys and defaults:

None.

#### Backward-compatibility expectations:

- Every command the allowlist allows today remains allowed; every command it denies today, other than the two new forms, remains denied.
- Every gate decision for an item-rooted session, an epic-scope call, a docs-only exemption, and a receipt check outcome is unchanged; the existing gate Pester suites pass without modification of their expectations.

#### Performance constraints (latency/throughput/memory):

The allowlist hook remains a string decision with no added process. The gate hook performs no more `git worktree list` invocations per call than it does today, other than what `Resolve-HookTargetWorktree` performs in place of the replaced resolution.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - The `(pattern)` suffix on a `tools:` entry admits the bare tool, so `"Bash(sha256sum *)"` and `"Write(/artifacts/**)"` do not restrict absolute paths (research Question 3; based on measured permission-rule semantics, to be confirmed by the orchestrator on the installed Claude Code version). The `tools:` list is not changed by this item.
  - Isolated subagents run `main`'s hooks; branch hook changes are proven by Pester until merge.
- Constraints (budget, performance, compatibility):
  - Two production PowerShell hook files are edited, within the direct-mode batch budget.
  - Test fixtures use forward-slash sample roots (for example `/repo/item`); drive-letter values appear only as command-text strings, never as filesystem paths, so the Linux hook-suite job behaves the same as Windows.
  - No temporary files in tests; resolver and git state are mocked at the `Resolve-HookTargetWorktree` seam or through its injectable invoker.
- External dependencies (services, libraries, releases): #1009 and #1010 merged to `main` (see Dependencies).

## Data / API / Config Impact

- User-facing or API changes: two new allowlisted pr-author commands; documented coordinator-session procedure.
- Data or migration considerations: none. Receipt schema and field semantics are unchanged.
- Logging/telemetry updates (if any): allowlist guidance text updated.
- Compatibility notes (CLI flags, config schemas, versioning): none.

## Test Strategy

Seeded from issue:

- [x] Unit coverage areas: a coordinator-rooted pr-author for a worktree item -> body, receipt, and summary land under the worktree and `gh pr create` is allowed; the same flow in an item-rooted session -> unchanged; a relative `--body-file` from a coordinator session -> still denied, with a message naming the absolute path to use. Tests in every runtime carrying the hook (Claude and bundled copies; no Codex counterpart exists).
- [ ] Integration scenario to retest
- [ ] Manual verification notes

- Regression tests to add or update:
  - `enforce-pr-author-command-allowlist.Tests.ps1`: allow rows for an absolute POSIX-rooted `sha256sum`, a drive-letter-rooted `sha256sum`, and `git worktree list --porcelain`; deny rows for an absolute path containing `..`, `.`, an empty segment, or a backslash; an unrooted path; a path ending in another file name or in `Artifacts/`; an absolute `sha256sum` with a second argument or a flag; an absolute `sha256sum` inside a chain; `git worktree list` without `--porcelain`; `git worktree list --porcelain` with an extra token; `git worktree add` and `git worktree remove`. The existing documented-forms row (AL-34) substitutes the new placeholders so every documented form is proven allowed; the relative-form row stays.
  - `enforce-pr-author-skill.TargetResolution.Tests.ps1`: rows proving `Resolve-PrAuthorWorktreeTarget` calls `Resolve-HookTargetWorktree` and maps each resolver outcome (session root, other worktree, ambiguous, no root, session-root fallback without signal, path-derived source) to the expected status and deny code.
  - `pr-author-coordinator-topology-contract.Tests.ps1` (new): static reads proving the agent and skill name `git worktree list --porcelain`, the absolute body path, the absolute `sha256sum`, `--body-file` with `--head`, repo-relative receipt fields, the existing-summary requirement, and the non-isolated delegation; and that the orchestrate handoff section names `workspace_root`, `target_ref`, and `branch:`.
- Fail-before evidence: the new allowlist allow rows and the new resolver-consumption rows are run against the pre-change hooks and fail; output recorded under `<FEATURE>/evidence/regression-testing/`.
- Edge cases and negative scenarios: listed in the deny rows above; zero/multiple worktree matches are a documented pr-author stop, verified by the contract test.
- Error handling and logging verification: each deny row asserts the `PR_AUTHOR_COMMAND_NOT_ALLOWED:` prefix; gate rows assert the existing deny codes.
- Coverage impact and targets for changed lines/modules: PowerShell line coverage of `.claude/hooks/enforce-pr-author-command-allowlist.ps1` and `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, read from `artifacts/pester/powershell-coverage.xml`, at least 85% each, with no regression on changed lines; recorded under `<FEATURE>/evidence/qa-gates/`. No branch-coverage gate applies to PowerShell.
- Toolchain commands to run: Invoke-Formatter -> PSScriptAnalyzer with repository settings -> Pester (touched suites and the full `tests/scripts` run) -> Python contract and parity tests through Poetry (`test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`).
- Order independence: touched Pester suites run in seeded shuffled single-process order with multiple seeds; recorded under `<FEATURE>/evidence/regression-testing/`.
- Manual validation steps (if required): an end-to-end coordinator-session `gh pr create` is a post-merge verification within this item's remediation, because isolated subagents run `main`'s hooks.

## Acceptance Criteria

- [ ] Before any edit, execution merges `origin/main` and records evidence that `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` exports `Resolve-HookTargetWorktree`, that the module has an entry in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (#1009), and that the #1010 preimplementation-gate change is present; if either dependency is absent, execution stops and reports blocked without editing files.
- [ ] `enforce-pr-author-command-allowlist.Tests.ps1` contains allow rows for `git worktree list --porcelain`, an absolute POSIX-rooted `sha256sum .../artifacts/pr_body_<digits>.md`, and a drive-letter-rooted equivalent; fail-before output showing these rows fail against the unmodified hook is recorded under `<FEATURE>/evidence/regression-testing/`, and the rows pass after the change.
- [ ] `enforce-pr-author-command-allowlist.Tests.ps1` contains deny rows asserting the `PR_AUTHOR_COMMAND_NOT_ALLOWED:` prefix for: an absolute `sha256sum` path with a `..`, `.`, or empty segment; a backslash path; an unrooted non-canonical path; a path not ending in `/artifacts/pr_body_<digits>.md` (including `Artifacts/`); an extra argument or flag; the absolute form inside a chain; `git worktree list` without `--porcelain`; `git worktree list --porcelain` with an extra token; and `git worktree add` / `git worktree remove`. All rows pass.
- [ ] The relative `sha256sum artifacts/pr_body_<N>.md` form remains allowed, every pre-existing allowlist row passes unchanged in expectation, and the `hook-command-invocation.Issue824Regression.Tests.ps1` allowlist rows pass.
- [ ] `$script:PrAuthorAllowlistFormText` names both new forms, and the documented-forms row (AL-34) proves every form named in the text is allowed after placeholder substitution.
- [ ] `enforce-pr-author-skill.TargetResolution.Tests.ps1` contains rows proving that `Resolve-PrAuthorWorktreeTarget` invokes `Resolve-HookTargetWorktree` and maps its result to `SessionRoot`, `OtherWorktree`, `Ambiguous` (`TARGET_WORKTREE_AMBIGUOUS`), and `NoTarget` (`TARGET_WORKTREE_NOT_DERIVABLE` after the #989 fallback); fail-before output showing the invocation rows fail against the unmodified helpers file is recorded under `<FEATURE>/evidence/regression-testing/`, and all rows pass after the change.
- [ ] A `TargetResolution` row proves that a resolver result whose source is a feature-folder or other path-derived source does not select the worktree for the PR gate (issue #673 rule).
- [ ] The existing gate suites (`enforce-pr-author-skill.Tests.ps1` and its `BodyNumber`, `CurrentBranch`, `DocsOnly*`, `EpicScope`, `Issue824`, `ItemArtifactRoot`, `OrchestratorStatePreflight`, `Payload`, `TriggerScoping`, `WorktreeResolution`, and `epic-base-branch*` suites) pass with unchanged expectations, including the `ItemArtifactRoot` rows for an OtherWorktree target with item-only artifacts, SessionRoot behavior, and the relative-body denial naming the absolute path.
- [ ] `git diff` against the merge base shows no change to `Resolve-PrAuthorArtifactRoot`, `Resolve-PrAuthorCurrentBranchTarget`, `Get-PrAuthorBypassReason`, `Invoke-OrchestratorStatePreflight`, `Get-PrAuthorDocsOnlyExemption`, `Get-PrAuthorBodyPathBindingReason`, or `Test-PrAuthorReceiptVerification`; the receipt checks are unchanged.
- [ ] `tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1` exists and passes, proving that `.claude/agents/pr-author.md` and `.claude/skills/pr-author/SKILL.md` document the coordinator-session topology: `git worktree list --porcelain` selection by `branch refs/heads/<head>` with a stop on zero or multiple matches, absolute body and receipt writes, absolute `sha256sum`, absolute `--body-file` with `--head`, repo-relative `pr_body_path` and `context_summary_path`, the requirement that the PR context summary already exists under the item worktree, and delegation without worktree isolation; and that the item-rooted relative procedure is still documented.
- [ ] The same contract test proves that `.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)` states `collect_pr_context` is called with `workspace_root` set to the item worktree and `target_ref` set to the head branch, that the delegation carries `branch: <branch>`, that pr-author derives the worktree root itself, and that the delegation is not worktree-isolated.
- [ ] `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1` passes without modification.
- [ ] Every edited file under `.claude/` is byte-identical to its copy under `extensions/drm-copilot/resources/claude-customizations/`, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and `test_push_down_issue_824_follow_ups.py` pass.
- [ ] `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1` pass with the new `HookTargetWorktree.psm1` import in the helpers file.
- [ ] PowerShell line coverage of `.claude/hooks/enforce-pr-author-command-allowlist.ps1` and `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, read from `artifacts/pester/powershell-coverage.xml`, is at least 85% for each file with no regression on changed lines, recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] Invoke-Formatter reports no changes and PSScriptAnalyzer with the repository settings reports zero findings for both edited hook files and all new or edited Pester files.
- [ ] The touched Pester suites pass in seeded shuffled single-process order under multiple seeds, and the full `tests/scripts` Pester run passes; results recorded under `<FEATURE>/evidence/regression-testing/`.
- [ ] No file under `.codex/`, `.agents/`, `.github/agents/`, `.claude/lib/worktree-resolution/`, or any pack manifest is modified by this item, and no execution-environment brief copy is modified.

## Risks & Mitigations

- Technical or operational risks:
  - R1 Isolation guard: an isolated pr-author delegation may have command text naming another worktree refused. Mitigation: skill and orchestrate text require a non-isolated delegation in the coordinator topology.
  - R2 Dependency order: #1009 and #1010 are not on `main`. Mitigation: execution verifies both after merging `origin/main` and stops blocked if either is absent.
  - R3 Hook execution context: branch hook changes are not exercised by isolated subagents until merge. Mitigation: proof by Pester; live verification post-merge.
  - R4 Windows path spelling: an unquoted backslash path loses its separators in bash. Mitigation: forward slashes only, enforced by the allowlist and prescribed by the skill text.
  - R5 Permission-rule semantics: `"Write(/artifacts/**)"` is assumed non-restrictive based on a prior measurement. Mitigation: the orchestrator confirms on the installed version; if it has become restrictive, the plan adds a remediation task to adjust the `tools:` entry.
  - R6 Overlap with #1001: #1001 edits `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, which the helpers parent dot-sources, and both items run `enforce-pr-author-skill.epic-base-branch.Tests.ps1`. Mitigation: merge `origin/main` before execution and re-run the epic-base-branch suites after any later main merge.
  - R7 Resolver API drift (research OQ3): the merged #1009 names may differ. Mitigation: the plan records actual names after the dependency check; the mapping rules stay authoritative.
- Mitigations and rollbacks: revert this item's commits; no persisted state is affected.

## Rollout & Follow-up

- Release/rollout steps: standard PR to `main`; bundled copies ship with the next extension package.
- Post-fix monitoring or clean-up tasks: after merge (with #1009 and #1010 on `main`), run a coordinator-session pr-author for a worktree item and confirm `gh pr create` is allowed; record under `<FEATURE>/evidence/`.
- Links: issue #1011; sibling issues #1009 (shared resolver), #1010 (preimplementation gate); related #673, #687, #850, #989, #1001.
