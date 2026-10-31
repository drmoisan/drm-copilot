# Research: pr-author impossible from a session not rooted in the item worktree (Issue #1011)

- Issue: #1011
- Branch: `bug/pr-author-session-not-rooted-1011`
- Work mode: full-bug (preparation-mode research)
- Inputs read: `issue.md`, `spec.md` (template, unfilled), `plan.2026-10-30T08-09.md` (template, unfilled), `docs/features/potential/promoted/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree.md`
- Researcher limits: no `git show`, no `gh`, no clock. Facts that need either are marked **[orchestrator to confirm]**.

## Executive Finding

The gate hook `.claude/hooks/enforce-pr-author-skill.ps1` (with its dot-sourced siblings) already resolves the item worktree from `--head`, already reads the PR context summary, the body, and the receipt beneath that worktree, and already accepts an absolute canonical `--body-file` beneath it (issue #850 work, pinned by `tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`). The deny for a relative `--body-file` from a non-session worktree already names the absolute path to use.

What makes the flow impossible is on the pr-author side:

1. `.claude/hooks/enforce-pr-author-command-allowlist.ps1` (registered in the pr-author agent frontmatter) allows `sha256sum` only for the relative token `^artifacts/pr_body_\d+\.md$` (`Test-PrAuthorAllowlistForm`, `'sha256sum'` branch). An absolute `sha256sum <item worktree>/artifacts/pr_body_<N>.md` is denied with `PR_AUTHOR_COMMAND_NOT_ALLOWED:`.
2. The allowlist has no form that lets pr-author discover the item worktree path from the `--head` branch (`git` is limited to `log` and `rev-parse`, and `git -C` / global options are denied).
3. The agent text (`.claude/agents/pr-author.md`) and skill text (`.claude/skills/pr-author/SKILL.md`) prescribe only relative paths for the body write, the checksum, the receipt, and `--body-file`.
4. The receipt write into the item worktree is additionally denied by the preimplementation gate (sibling #1010, out of scope here).

The `tools:` entries `"Bash(sha256sum *)"` and `"Write(/artifacts/**)"` are not the operative restriction (see Question 3).

## Question 1: How the PR gate resolves the item worktree today

Files: `.claude/hooks/enforce-pr-author-skill.ps1` (parent), `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`, `.claude/hooks/enforce-pr-author-skill.current-branch.ps1`, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`. The helpers file imports `.claude/lib/worktree-resolution/WorktreeResolution.psm1`, `WorktreeTargetResolution.psm1`, `WorktreeItemResolution.psm1`, `EpicScopeResolution.psm1`, `EpicScopeReadiness.psm1`.

Decision flow (`Get-PrAuthorBypassReason` in the helpers file):

- Trigger: structural `gh pr create` / `gh pr edit` (`Test-CommandLineInvocation`). Case A (inline `--body`), Case B (create with no body flag), and the edit-without-body allow perform no resolution.
- Resolution, once per call: `Resolve-PrAuthorArtifactRoot` (artifact-root sibling).
  - Epic scope: `Resolve-EpicScopeCheckpoint`; root from `Get-PrAuthorEpicArtifactRoot`.
  - Otherwise `Get-PrAuthorTargetCheckpointResolution` -> `Resolve-PrAuthorWorktreeTarget` -> `Resolve-WorktreeItemTarget -Text $CommandText -SessionRoot (Get-Location).Path` (portable identity: branch signal or canonical issue line), then `Resolve-PrAuthorCurrentBranchTarget` (issue #989 current-branch fallback, only when the command carries no signal).
  - `--head` handling: `Find-WorktreeResolutionBranchSignal` in `WorktreeTargetResolution.psm1` reads `--head`, `--branch`, or a `branch:` label (`$script:BranchPattern`). The branch is matched to a registered worktree's HEAD; status is `SessionRoot` or `OtherWorktree`; `NoTarget` and `Ambiguous` deny with the codes from `Get-WorktreeResolutionNoTargetReasonCode` / `Get-WorktreeResolutionAmbiguityReasonCode` (`TARGET_WORKTREE_NOT_DERIVABLE`, `TARGET_WORKTREE_AMBIGUOUS`) plus `Get-PrAuthorTargetGuidanceText`.
  - `RelativeBodyAllowed` is true only for a `SessionRoot` target (or an epic root equal to the session worktree).
- PR context summary read: Case C `PR_CONTEXT_MISSING` via `Get-PrContextArtifactExistence` on `Join-WorktreeResolutionPath -WorktreeRoot $artifact.ArtifactRoot -RepoRelativePath artifacts/pr_context.summary.txt`; and receipt check 5 via `Get-PrContextSummaryLastWriteUtc` on the same composed path.
- `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`: `Invoke-OrchestratorStatePreflight -CheckpointPath $checkpointPath` (`.claude/lib/orchestrator-state/OrchestratorState.psm1`), where the checkpoint path is the resolved worktree's absolute checkpoint (`Get-WorktreeItemCheckpointPath`). Its `$Invoker` scriptblock seam defaults to the in-process U-family checks plus `Test-OrchestratorStatePrCreationReadiness`; it starts no subprocess. When the preflight fails, `Get-PrAuthorDocsOnlyExemption` (docs-only sibling) may exempt a docs-only `gh pr create`. Epic scope uses `Get-EpicPrCreationReadinessFailure` instead.
- `--body-file` canonicalization: `Get-PrAuthorBodyFileValue` (backslash to slash, one leading `./` removed), then `ConvertTo-WorktreeResolutionNormalizedPath`, then `Get-PrAuthorBodyPathBindingReason`:
  - relative `artifacts/pr_body_<N>.md` (case-sensitive) allowed only when `RelativeBodyAllowed`; otherwise `PR_BODY_PATH_NONCANONICAL` naming the absolute canonical path;
  - absolute value allowed only when equal (`Test-PrAuthorBodyPathEqual`: case-insensitive for drive/UNC, ordinal otherwise) to `<ArtifactRoot>/artifacts/pr_body_<N>.md`;
  - `ConvertTo-PrAuthorBodyNumber` rejects leading zeros, overflow, non-ASCII digits.
- Receipt checks (`Test-PrAuthorReceiptVerification`): check 1 body-path binding, `PR_AUTHOR_RECEIPT_MISSING`, `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH`, `PR_AUTHOR_RECEIPT_HASH_MISMATCH`, `PR_AUTHOR_RECEIPT_STALE`, and a sixth check `EPIC_BASE_BRANCH_MISMATCH` (`Test-EpicBaseBranchOverride`, epic-base-branch sibling). The agent, skill, and orchestrate texts describe "five ordered checks"; the code docstring describes six (the sixth applies only under `epic_mode`). The receipt fields `pr_body_path` and `context_summary_path` are not read by any hook or script (search of `scripts/`, `.claude/lib/`, `.claude/hooks/`, `extensions/drm-copilot/src/` for those field names: no match).

Paths that a `Resolve-HookTargetWorktree` call would replace: **none recommended.** Reasons:

- `Resolve-PrAuthorWorktreeTarget` already derives the worktree from `--head` by identity. The #1009 resolver's Bash rule (2) is specified as "a `--body-file` / `--head` worktree the existing PR hook resolves", so for this hook the shared resolver defers to the existing logic; substituting it here would be circular.
- Issue #673 (comment in the helpers file) records why a path signal must not select the worktree for this gate: a merged feature-folder path exists in every checkout. The #1009 resolver's nearest-enclosing-worktree rule on a path is the behavior #673 moved away from.
- The only candidate seam is the body of `Resolve-PrAuthorWorktreeTarget`. If the operator requires the PR gate to call the shared resolver anyway, that function is the single replacement point; `Resolve-PrAuthorArtifactRoot`, `Get-PrAuthorTargetCheckpointResolution`, Cases A/B/C, the preflight and its `$Invoker` seam, the docs-only exemption, and `Test-PrAuthorReceiptVerification` must remain unchanged. See Open Question OQ1.

Paths that must stay unchanged: all of the above (the issue's Out of scope: receipt checks stay as strict as today).

Overlap with #1001: #1001 edits `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` and `.claude/hooks/enforce-epic-merge-gate.ps1`. The recommended file set for #1011 touches neither file nor the parent/helpers files that dot-source the epic-base-branch sibling, so there is no textual overlap. Residual risk: if OQ1 is resolved toward editing `enforce-pr-author-skill-helpers.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` dot-sources the same parent and both items would run it; merge order would need sequencing.

## Question 2: Codex counterparts, bundled copies, pack manifests

- Codex: no counterpart exists. `.codex/hooks/` has no `enforce-pr-author-*` file; `.codex/config.toml` registers no pr-author gate (its `pr-author` mentions are only subagent routing matchers). `.codex/agents/pr-author.toml` and its `-c1`/`-c2`/`-c3`/`-c3-elevated`/`-c4` variants carry no tool allow-list, no receipt protocol, and no body-file path. `.agents/skills/pr-author/SKILL.md` contains no `pr_body`, receipt, `--head`, or worktree text. The issue's "tests in every runtime carrying the hook" therefore resolves to the Claude runtime plus its bundled copies.
- Bundled copies (byte-identical mirrors under `extensions/drm-copilot/resources/claude-customizations/`): `.claude/hooks/enforce-pr-author-command-allowlist.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`, `.claude/hooks/enforce-pr-author-skill.current-branch.ps1`, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, `.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`.
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists all seven pr-author hook files, `.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`, and the seven `.claude/lib/worktree-resolution/*.psm1` modules. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lists the six `.codex/agents/pr-author*.toml` files. The recommended fix adds no file and no new `$PSScriptRoot` dependency, so no manifest changes.

## Question 3: pr-author tool allow-list, variants, and matcher semantics

- `.claude/agents/pr-author.md` frontmatter `tools:` is: `Read`, `"Bash(git log *)"`, `"Bash(git rev-parse *)"`, `"Bash(gh pr create *)"`, `"Bash(gh pr edit *)"`, `"Bash(gh pr view *)"`, `"Bash(sha256sum *)"`, `"Bash(date *)"`, `"Write(/artifacts/**)"`; `memory: project`; PreToolUse `Bash` hook `.claude/hooks/enforce-pr-author-command-allowlist.ps1`; SubagentStop hook `.claude/hooks/validate-pr-author-output.ps1`.
- Variants: the Claude agent is hand-edited, with one bundled byte-identical copy. `scripts/dev_tools/generate_codex_agent_variants.py` generates only `.codex/agents/<family>-c*.toml` variants, their bundle copies, and the Codex `core.json` from the hand-edited `.codex/agents/<family>.toml` base (`CORE_FAMILIES` includes `pr-author`). It does not read or write `.claude/agents/`. `.github/agents/pr-author.agent.md` (bundled under `extensions/drm-copilot/resources/customizations/.github/agents/`) is hand-edited and documentation-only for the receipt protocol.
- Matcher semantics that apply:
  - The execution-environment brief states that a `(pattern)` suffix on a `tools:` entry admits the bare tool. `"Bash(sha256sum *)"` therefore already admits Bash with any argument, including an absolute path.
  - Project memory `claude-permission-rule-matcher-semantics` (measured on Claude Code 2.1.246, about 65 days old) records that a `Write(<path>)` rule matches no tool, that a leading-slash path rule matches nothing, that the `(path)` suffix in an agent `tools:` entry contributes no restriction, and that `memory:` in agent frontmatter grants bare Write and Edit. On that basis `"Write(/artifacts/**)"` neither grants nor restricts, and pr-author can already Write an absolute `<item worktree>/artifacts/pr_body_<N>.md` subject to hooks. **[orchestrator to confirm the installed Claude Code version still behaves this way; the researcher cannot run a probe.]**
  - The operative restriction is the frontmatter-registered allowlist hook. The change that lets pr-author checksum an absolute body path is in `Test-PrAuthorAllowlistForm`, not in the `tools:` list. Editing `"Bash(sha256sum *)"` to `"Bash(sha256sum /**/artifacts/pr_body_*.md)"` would be documentary only and would not be enforced.
  - The Write of the body and receipt into the item worktree is still subject to `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (sibling #1010).
- Recommended allow-list change (in `.claude/hooks/enforce-pr-author-command-allowlist.ps1`):
  - `sha256sum`: keep the relative form; add one absolute form, as the whole command with exactly one argument, matching a rooted path (`/` or a drive letter followed by `:/`) that ends in `/artifacts/pr_body_<digits>.md`, with forward slashes only and no empty, `.`, or `..` segment. No resolver call: the checksum is read-only, and the gate hook binds the body path to the resolved worktree at `gh pr create` time (check 1).
  - Add the exact read-only form `git worktree list --porcelain` (four tokens) so pr-author can map the `--head` branch to its worktree path (the same data source the #1009 resolver uses).
  - Update `$script:PrAuthorAllowlistFormText` and the synopsis to name both new forms.
  - Optional for documentation consistency: add `"Bash(git worktree list *)"` to the `tools:` list. It changes no enforcement.

## Question 4: Skill and orchestrate text

- `.claude/skills/pr-author/SKILL.md` `## Output Artifact` and `.claude/agents/pr-author.md` `## PR Body and Receipt Write Protocol` prescribe only `artifacts/pr_body_<N>.md`, `sha256sum artifacts/pr_body_<N>.md`, `artifacts/pr_body_<N>.receipt.json`, and `gh pr create --body-file artifacts/pr_body_<N>.md`. Neither mentions the coordinator-session topology except the last bullet of `## Required --head on gh pr create (issue #687)` ("When running outside the item worktree, append ... and pass the absolute canonical body path beneath the item worktree"), which covers `gh pr edit` only.
- Text to add (both files, same content):
  - A coordinator-session subsection: when the process directory is not the item worktree, run `git worktree list --porcelain`, select the `worktree` entry whose `branch refs/heads/<head>` equals the `--head` branch, and use that absolute root (forward slashes) as `<item worktree>`. If no entry or more than one entry matches, stop and report.
  - Write the body and receipt to `<item worktree>/artifacts/pr_body_<N>.md` and `<item worktree>/artifacts/pr_body_<N>.receipt.json`; run `sha256sum <item worktree>/artifacts/pr_body_<N>.md` as a single command; keep `pr_body_path` and `context_summary_path` in the receipt repo-relative (no hook reads them, and absolute paths are not recorded in artifacts); pass `--body-file <item worktree>/artifacts/pr_body_<N>.md` with `--head <branch>`.
  - State that the PR context summary must already exist beneath `<item worktree>/artifacts/` (pr-author has no `collect_pr_context` tool), and that `created_at` must be newer than that file.
  - State that pr-author must not be delegated with worktree isolation in this topology, because the runtime isolation guard refuses command text that reaches outside the agent worktree (execution-environment brief, Command-Text Restrictions).
  - Keep the existing relative forms for the item-rooted session unchanged.
- `.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)`:
  - Step 1 should state that `mcp__drm-copilot__collect_pr_context` is called with `workspace_root` set to the item worktree and `target_ref` set to the head branch (both parameters exist in `extensions/drm-copilot/src/mcp-tool-definitions.ts`), so the summary lands under the item worktree.
  - The existing paragraph beginning "When the pr-author agent runs outside the item worktree" is accurate for the hook. Extend it to say the delegation prompt carries `branch: <branch>` and that pr-author derives the worktree root itself (no absolute path in the prompt), and that the delegation is not worktree-isolated.
  - `.claude/agents/orchestrator.md` `## PR Creation Delegation` defers to this section; no change required.

## Question 5: Existing tests and disposition

Pester, `tests/scripts/claude-hooks/`:

- `enforce-pr-author-command-allowlist.Tests.ps1`: **update.** Add allow rows (absolute POSIX root, drive-letter root, `git worktree list --porcelain`) and deny rows (relative `..`, absolute with `..`, absolute ending in another file, absolute plus a second argument, absolute inside a chain, `git worktree list` without `--porcelain`, `git worktree add`/`remove`). AL-34 must substitute the new placeholder (for example replace `<item worktree>` with `/repo/item`) or it fails on any new span containing `<`; AL-35 stays valid while the relative form is retained. AL-49 is unaffected (it checks only the `gh pr view` text in the forms sentence).
- `hook-command-invocation.Issue824Regression.Tests.ps1` REG rows for the allowlist: unaffected (existing allows stay allowed).
- `enforce-pr-author-skill.Tests.ps1`, `.BodyNumber`, `.CurrentBranch`, `.DocsOnly*`, `.EpicScope`, `.Issue824`, `.ItemArtifactRoot`, `.OrchestratorStatePreflight`, `.Payload`, `.TargetResolution`, `.TriggerScoping`, `.WorktreeResolution`, `.epic-base-branch*`: unaffected under the recommendation (the gate hook is not edited). `ItemArtifactRoot` already covers the issue's three hook-side scenarios: "allows an OtherWorktree target whose artifacts exist only in the item worktree", "keeps SessionRoot behavior with absolute artifact paths", "denies a relative body path for an OtherWorktree target and names the absolute path".
- `validate-pr-author-output*.Tests.ps1`: unaffected.

Pester, `tests/scripts/codex-hooks/`: no pr-author suite exists; none needed.

Pester, `tests/scripts/claude-runtime/`:

- `pr-author-issue-link-contract.Tests.ps1`: unaffected if the `## Required --head ...` section keeps `--head is not valid for gh pr edit` and `# branch: <branch>`, the closing-reference section keeps its form, and `"Bash(gh pr view *)"` stays in `tools:`. PC-01 reads `## PR Authoring (pr-author Handoff)`; keep `Author-asserted autoclose issues: #<issue-num>`, `issue-num`, and `epic_mode` in it.
- `claude-architecture-doc.Tests.ps1`: the architecture document does not mention `sha256sum` (search outside `docs/features/`); adding a `tools:` entry may require it to be listed **[planner to check the test's agent-tool coverage before adding the optional tools entry]**.
- `hook-dependency-guard-completeness.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1`: unaffected (no new import, no Python).
- Recommended new contract rows (in a new file such as `tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1`, or appended to `pr-author-issue-link-contract.Tests.ps1`): the skill and agent name `git worktree list --porcelain`, the absolute body path, and the coordinator-session rule; the orchestrate section names `workspace_root` and `target_ref`.

Python, `tests/scripts/dev_tools/`:

- `test_push_down_claude_resource_contracts.py`: run; passes when every bundled copy is byte-identical.
- `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`: unaffected (no new file or dependency); run.
- `parallel_orchestrator_surface_expectations.py` `PINNED_FROZEN_SURFACE_HASHES`: pins only `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`; neither is edited. Its `MERGE_ON_GREEN_FRAGMENTS` contain prose about `.claude/skills/orchestrate/SKILL.md` that lives in another document; editing the orchestrate skill does not affect them.
- `test_parallel_orchestrator_surface_contracts.py` (`Agent(pr-author)` grant): unaffected.
- `generate_codex_agent_variants.py --check`, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`: unaffected (no Codex change); run.
- `test_push_down_issue_824_follow_ups.py`: run; new skill text must name no consuming product.
- `test_claude_rules_frontmatter.py`: unaffected.

## Question 6: Coverage and file-size configuration

- `config/poshqc-coverage.json` lists roots (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`), not files. Not affected.
- `config/file-size-baseline.json` has no entry for any pr-author hook or test. Not affected.
- Current physical line counts (from file reads): `.claude/hooks/enforce-pr-author-command-allowlist.ps1` 285; `.claude/hooks/enforce-pr-author-skill.ps1` 359; `.claude/hooks/enforce-pr-author-skill-helpers.ps1` 443; `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` 233; `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` 149; `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1` 202. All are below the 500-line guidance tier; the planned additions (an estimated 20 to 40 lines in the allowlist hook and 30 to 60 in its test) keep both below 500.

## Question 7: Execution-environment brief

No fact in the brief changes. The brief does not describe the pr-author allowlist forms, the pr-author tool list, or the PR gate. The recommended change adds no CI job, required context, tool route for a named brief agent, batch-budget rule, or hook-execution fact. No brief-update task is required.

## Question 8: Risks, open questions, recommended minimal file set

### Recommended approach

Allowlist-and-text fix. Extend `enforce-pr-author-command-allowlist.ps1` with an absolute `sha256sum` form and the exact `git worktree list --porcelain` form; document the coordinator-session topology in the pr-author agent, the pr-author skill, and the orchestrate handoff section; leave the PR gate hook unchanged.

Rejected alternatives:

- Replace `Resolve-PrAuthorWorktreeTarget` with `Resolve-HookTargetWorktree`: no behavior gain (the gate already resolves from `--head`), circular with the #1009 spec rule (2), reopens the #673 path-signal concern, and raises #1001 overlap and #1009 merge-order risk.
- Bind the absolute `sha256sum` argument to a registered worktree through the resolver inside the allowlist hook: adds a git process and a module import to a pure-string hook (dependency closure, guard-completeness, manifest work) for a read-only command whose path is already bound at `gh pr create` by check 1.
- Put the absolute item-worktree path in the delegation prompt instead of `git worktree list --porcelain`: workable, but the prompt text is outside hook verification and the issue's Expected Behavior asks pr-author to resolve from `--head`. Kept as a fallback (OQ2).
- Change only the `tools:` entries: not enforced (Question 3).

### Minimal file set

Production (PowerShell, two files against the batch budget of three):

1. `.claude/hooks/enforce-pr-author-command-allowlist.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-command-allowlist.ps1`

Customization text (Markdown):

3. `.claude/agents/pr-author.md`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/pr-author.md`
5. `.claude/skills/pr-author/SKILL.md`
6. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-author/SKILL.md`
7. `.claude/skills/orchestrate/SKILL.md`
8. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`

Tests:

9. `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1`
10. `tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1` (new)

Feature documentation:

11. `docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011/spec.md`

Not changed: all `enforce-pr-author-skill*.ps1` files, `.claude/lib/worktree-resolution/*`, all `.codex/*`, `.agents/skills/pr-author/SKILL.md`, `.github/agents/pr-author.agent.md` (documentation-only surface; its "Claude and Codex" hook statement is inaccurate for Codex but outside this scope), pack manifests, `config/*`, and the six execution-environment brief copies.

### Risks

- R1 Isolation guard: if pr-author is delegated into an isolated worktree, the runtime guard may refuse `sha256sum` and `gh pr create` text naming another worktree. Mitigation: skill and orchestrate text require a non-isolated delegation in the coordinator topology.
- R2 Dependency on #1010: the Write of the body and receipt into the item worktree is denied until #1010 merges; end-to-end proof needs #1010 on `main`. Unit tests for #1011 do not depend on it.
- R3 Hook execution context: branch hook changes are not exercised by isolated subagents until merge; proof is by Pester.
- R4 Windows path spelling: a backslash path passed unquoted to bash loses its separators. Mitigation: the skill prescribes forward slashes; the allowlist accepts forward slashes only, and its deny text names the expected shape.
- R5 Permission-rule semantics are taken from a 65-day-old measured memory; a runtime change could make `"Write(/artifacts/**)"` restrictive. Mitigation: **[orchestrator to confirm]**; if it has become restrictive, replace it with a form that admits an absolute item-worktree path.
- R6 Count wording: documents say "five" receipt checks while the code runs six under epic scope. The acceptance criteria should say the receipt checks are unchanged rather than restate a count.

### Open questions

- OQ1 Does the operator require the PR gate hook itself to call `Resolve-HookTargetWorktree` (the delegation framing says #1011 consumes the resolver)? The research recommends no, because the existing resolution already meets the Expected Behavior. If yes, the replacement point is `Resolve-PrAuthorWorktreeTarget` only, the item depends on #1009 merging first, and the file set grows by `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, its bundled copy, `core.json` (if the module is not already manifested by #1009), and `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`. **[orchestrator/operator decision]**
- OQ2 Worktree discovery: `git worktree list --porcelain` in the allowlist (recommended) or an orchestrator-supplied path in the prompt.
- OQ3 Final #1009 API names and file are not on `main`. **[orchestrator to confirm after #1009 merges]**

## Behavior Semantics

- Item-rooted session (process directory is the item worktree): unchanged. Relative body path, relative `sha256sum`, relative `--body-file`, `--head <branch>`.
- Coordinator-rooted session: pr-author derives `<item worktree>` from `git worktree list --porcelain` by the `--head` branch; writes body and receipt there; checksums by absolute path; passes the absolute `--body-file` with `--head`. The gate resolves the same worktree from `--head` and verifies receipts beneath it.
- Relative `--body-file` from a coordinator session: still denied with `PR_BODY_PATH_NONCANONICAL` naming the absolute path (existing behavior).
- Allowlist failure conditions: absolute `sha256sum` argument not rooted, containing `.`/`..`/empty segments or backslashes, not ending in `/artifacts/pr_body_<digits>.md`, with extra arguments or flags, or chained -> `PR_AUTHOR_COMMAND_NOT_ALLOWED:`. `git worktree` with any other token sequence -> denied.

## Testing Implications

- Fail-before: new allow rows for the absolute `sha256sum` form and `git worktree list --porcelain` fail against the current allowlist hook (both are denied today); record under `<FEATURE>/evidence/regression-testing/`.
- Unit (Pester, pure string decisions, no files, no processes): allow and deny rows listed in Question 5; one row per normalization edge (drive letter, POSIX root, trailing segment case `Artifacts/` denied, leading-zero number allowed or denied consistently with the relative form, which uses `\d+`).
- Contract (Pester static reads): skill/agent/orchestrate text rows, and AL-34 extended to the new placeholder so every documented command form is proven allowed.
- Parity: run the Python bundle-parity and manifest contract tests.
- Coverage: PowerShell line coverage of `.claude/hooks/enforce-pr-author-command-allowlist.ps1` from `artifacts/pester/powershell-coverage.xml`, at least 85%, and no regression on changed lines.

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for a `spec.md` acceptance criterion. The research recommends that the acceptance criteria avoid restating the receipt-check count (R6). The batch-budget figure (two production PowerShell files) is a planning note, not an acceptance criterion.

## Pre-Mortem

- Review checklists: a reviewer may flag that the issue's "via the shared resolver" wording is not met literally by the PR gate. Mitigation: the plan records the OQ1 decision and the reason (existing `--head` identity resolution; #1009 rule (2) defers to it) in `spec.md` before execution.
- Coverage: new branches in `Test-PrAuthorAllowlistForm` (absolute `sha256sum`, `git worktree list --porcelain`) could be left untested on their deny paths. Mitigation: one Pester row per new deny condition, and the PowerShell coverage figure for the allowlist hook is read from `artifacts/pester/powershell-coverage.xml` and recorded under `evidence/qa-gates/`.
- Mirror parity: four Markdown files and one hook have bundled copies; a missed copy fails `test_push_down_claude_resource_contracts.py`. Mitigation: each edit task names both paths and the plan runs the bundle-parity and manifest-completeness tests; no execution-environment brief update is needed (Question 7).
- File size: not applicable as a risk; the largest touched code file (the allowlist hook, 285 lines) stays below the 500-line guidance tier after the change, and Markdown is exempt.
- Test isolation: the new rows are pure string decisions with no temp files or processes; the existing AL-37 in-process run restores stdin and `CLAUDE_HOOK_INPUT` in `finally`. Mitigation: run the touched Pester suites in a seeded shuffled single-process order with at least three seeds, plus the fresh single-process `tests/scripts` run, and record both under `evidence/regression-testing/`.
- CI-only behavior: the Linux hook-suite job runs `tests/scripts/claude-hooks` on a case-sensitive file system; a test fixture using a drive-letter path as a filesystem path, or backslashes, would fail there. Mitigation: drive-letter values appear only as command-text strings (never joined or resolved as paths), sample roots use forward slashes (for example `/repo/item`), and new test file names use exact case.
- Evidence: an end-to-end coordinator-session PR cannot be demonstrated until #1010 and this branch merge (isolated subagents run `main`'s hooks). Mitigation: acceptance relies on Pester and contract tests, and the plan states that live verification is a post-merge follow-up within this item's remediation, not a fabricated pre-merge claim; evidence goes under `<FEATURE>/evidence/<kind>/` only.

## Automation Feasibility

All steps are automatable:

- Edits are text changes to one PowerShell hook, four Markdown files, their bundled copies, and two Pester files; the executor has Edit/Write, and the production PowerShell count (two) is within the direct-mode batch budget of three.
- Verification runs through existing routes: Pester via the self-hosted PoshQC module from a `sh`-launched PowerShell 7 (reading JUnit and coverage XML for counts), PSScriptAnalyzer with the repository settings, and the Python contract tests through Poetry.
- No step needs a live subagent run, a `gh` mutation, or a manual permission probe, except the optional confirmation of permission-rule semantics (R5), which is a read-only orchestrator check and does not block the fix.
- Facts requiring orchestrator confirmation: the #1009 final API (OQ3), the operator decision on OQ1, and the current permission-rule semantics (R5).
