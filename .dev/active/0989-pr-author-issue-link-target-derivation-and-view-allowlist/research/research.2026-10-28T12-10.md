# Research: pr-author issue-link, target derivation, and `gh pr view` allowlist (Issue #989)

- Issue: #989
- Branch: drm-copilot-wt-2026-10-28T07-33
- Timestamp: 2026-10-28T12-10
- Scope: three defects in orchestration and PR-authoring tooling. Findings come from reading the files named below; no command was run. The researcher has no shell, so line counts come from file reads and must be re-confirmed with `@(Get-Content -LiteralPath <path>).Count` at plan time. Citations use symbols, headings, and test names only.

## Summary of Recommendations

| Defect | Recommended approach |
|---|---|
| 1. Author-asserted line never passed | Prose change in the orchestrate skill and orchestrator agent, prose change in the pr-author skill, and enforcement as a new check inside `enforce-model-routing-receipt.ps1` (Agent PreToolUse), plus a static-contract Pester row for the prose. |
| 2. `TARGET_WORKTREE_NOT_DERIVABLE` on `gh pr edit` | Fallback inside `Resolve-PrAuthorWorktreeTarget` using a new mockable git wrapper that reads the checked-out branch. Put the wrapper and fallback in a new dot-sourced sibling file. Rewrite the deny message in `Get-PrAuthorTargetCheckpointResolution`. |
| 3. No `gh pr view` | Add `Bash(gh pr view *)` to the agent tools; add one exact-shape clause to `Test-PrAuthorAllowlistForm`; update `PrAuthorAllowlistFormText`; add skill and agent prose for the post-create/edit verification. |

## Defect 1: Author-asserted autoclose issue never delegated

### Current state

- `.claude/skills/orchestrate/SKILL.md`, `## PR Authoring (pr-author Handoff)`: a four-step mandatory sequence (collect PR context, run the pr-author preflight, delegate to `Agent(pr-author)`, record `pr_author_receipt`). It says nothing about auto-close or issue references. `## Issue Number Consistency` already requires the line "Canonical issue number for this feature is <issue_num>..." and a `branch: <name>` label on every delegation to a receipt-gated type, and `pr-author` is in that list.
- `.claude/agents/orchestrator.md`, `## PR Creation Delegation`: a single paragraph that defers to the orchestrate skill section; no auto-close text.
- `.claude/skills/pr-author/SKILL.md`, `## Issue/PR Reference Rules`: "Auto-close bullets must use exactly `- Closes #NNN` format, sourced only from 'Issues to autoclose' or 'Author-asserted autoclose issues.'" and "If GitHub validation is unavailable/unverified, do not emit `Closes`; use the fallback `None` bullet." The `Author-asserted autoclose issues` label is, in code, a section the PR-context renderer emits from the PR Intent (`scripts/dev_tools/pr_context/collector_documents.py` and `render.py`, field `author_asserted` in `collector.py`). Nothing reads a delegation prompt as a source. So the gap is real: when the context lists none, the skill falls through to `- None`.
- `.claude/agents/pr-author.md` contains no auto-close text. No `.claude` surface mentions `closingIssuesReferences` (it appears only in the PR-context collector/renderer code, its tests, and the Copilot-side `.github` prompt and agent). The issue text says the pr-author "skill requires" the verification; the `.claude` skill does not currently say so. The post-create/edit verification is therefore new text, not a restoration.

### Hooks that already inspect `Agent(pr-author)` delegation prompts

`.claude/settings.json` registers, under `PreToolUse` matcher `Agent`: `enforce-prd-feature-before-planner.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-model-routing-receipt.ps1`, `enforce-epic-invocation-origin.ps1`, `enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-drift-gate.ps1`.

- Only `enforce-model-routing-receipt.ps1` is specific to `pr-author`: `Get-ModelRoutingGatedAgent` lists `pr-author`, and `Invoke-ModelRoutingReceiptDecision` reads the prompt via `Get-ClaudeHookToolInputString -Name 'prompt'`. The flow is: filter to gated subagent; try `Resolve-EpicScopeCheckpoint` (epic integration branch, returns early); otherwise `Get-ModelRoutingTargetCheckpointResolution` resolves the item worktree from the canonical issue line and `branch:` label; then `Get-ModelRoutingCheckpoint` reads the checkpoint (parsed object) and `Test-ModelRoutingReceiptPresent` decides. At the point of the final allow, the hook holds both the prompt and the resolved per-feature checkpoint object. That is exactly the data a new check needs.
- The preimplementation gate and the others do not special-case `pr-author` (the grep hits in those files are comments about a split-file precedent).
- `validate-pr-author-output.ps1` is a SubagentStop hook over the final message only; it never sees the prompt.
- `validate-orchestrator-output.ps1` is a SubagentStop hook on the orchestrator; it sees the checkpoint and the orchestrator's last message, not the prompts it sent. It cannot see whether the delegation carried the line.
- `.codex/hooks` has no counterpart of `enforce-model-routing-receipt.ps1` or of a pr-author gate (no file matched), so there is no Codex hook mirror to update.

### How epic-child runs are identified in the checkpoint

`epic_mode` (boolean) and `epic_context.integration_branch` in the per-feature `artifacts/orchestration/orchestrator-state.json`. Evidence: `Test-EpicBaseBranchOverride` in `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` tests `epic_mode` as a boolean property and reads `epic_context.integration_branch`; the orchestrate skill's `## PR Creation Gate` condition 7 states "`epic_mode` is `false`, OR (`epic_mode` is `true` AND the integration-branch merge ... has completed...)". The epic integration PR itself is gated in epic scope against the epic checkpoint (`Resolve-EpicScopeCheckpoint`), a different checkpoint with no `issue-num` key of the child kind. Parallel-mode items are not epic children and open their own PRs, so they must carry the line.

### Candidate designs for the AC3 check

1. Pester static-contract test over skill/agent text only (precedent: `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, helper `Get-SkillSection`, rows over `## Issue Number Consistency`). Cheap and drift-resistant for the prose, but it does not fail on an actual delegation that omits the line, so by itself it does not meet AC3 as worded.
2. New check in `enforce-model-routing-receipt.ps1` (PreToolUse on Agent). Enforces on the real delegation. Cost: about 30 to 40 added lines to a file read at roughly 300 lines; plus a new test file. Hook behavior is proven by Pester, not by a live isolated subagent (hooks for isolated subagents run `main`'s copies).
3. New standalone PreToolUse Agent hook. Duplicates the identity and checkpoint resolution already in option 2, adds a `settings.json` registration, a new file, a new manifest entry, and a bundle copy. More surface for the same data.
4. SubagentStop `validate-orchestrator-output.ps1`. Cannot see prompts. Rejected.

Recommendation: option 2 for enforcement, plus one option 1 row for the prose. Proposed decision rule, placed after the per-feature checkpoint is read and receipt presence is confirmed, only for `$subagent -eq 'pr-author'`:
- Read the checkpoint `issue-num` through the exported `ConvertTo-WorktreeItemIssueNumber` (already imported by the hook); skip when it is `$null`.
- Skip when the checkpoint has `epic_mode` true (property-presence test first, as `Test-EpicBaseBranchOverride` does, because strict mode throws on a missing property).
- Otherwise require the prompt to contain a line matching `Author-asserted autoclose issues:` followed by `#<issue-num>` (anchored at line start, number followed by a non-digit or end of line so `#98` does not satisfy `#989`). Deny with a new reason code in the hook's existing `MODEL_ROUTING_RECEIPT_BLOCKED:` family naming the expected line.
- The epic-scope early return is unchanged, so the epic integration PR delegation is not subject to the rule.
- Existing tests are unaffected: the `Agent(pr-author)` rows in `enforce-model-routing-receipt.EpicScope.Tests.ps1` use checkpoints with no `issue-num` (`ReadyEpicJson` and the `model_routing_receipts`-only object), which falls under "omitted when the checkpoint has no issue-num".
- Residual limit: the hook cannot confirm the issue is correct for the PR beyond equality with the checkpoint, and it is a policy deterrent in the same sense as the existing receipt gate.

### Files to change (Defect 1)

| File | Change |
|---|---|
| `.claude/skills/orchestrate/SKILL.md` | `## PR Authoring (pr-author Handoff)`: add the required line and the two omission conditions; cross-reference in `## Issue Number Consistency` is optional. |
| `.claude/agents/orchestrator.md` | `## PR Creation Delegation`: state the same requirement (the section defers to the skill; add a short sentence rather than restating the sequence). |
| `.claude/skills/pr-author/SKILL.md` | `## Issue/PR Reference Rules`: add the delegation-prompt source, the "valid even when PR context lists no verified autoclose issues" statement, and "`- None` only when neither list has an entry". Also reconcile the `## PR Body Structure` item 11 wording ("only from verified autoclose lists"). |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | New decision step as above. |
| New test file under `tests/scripts/claude-hooks/` (for example `enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`) | Rows: present line allows; missing line denies; wrong number denies; `#98` vs `#989` prefix case; no `issue-num` allows; `epic_mode` true allows; other subagent types unaffected; epic scope unaffected. Reuse the `New-AgentPayload`, `Set-FeatureCheckpointSeam` pattern from `enforce-model-routing-receipt.EpicScope.Tests.ps1` (mocks `Resolve-ModelRoutingWorktreeTarget` and `Get-ModelRoutingCheckpoint`). A new file keeps the existing suites untouched. |
| `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` (or a new sibling contract file) | Static rows over the three prose edits, using `Get-SkillSection` for the skills; for the agent file use the same heading extraction on `## PR Creation Delegation`. Backtick-bearing tokens must use `.Contains`. |

## Defect 2: `TARGET_WORKTREE_NOT_DERIVABLE` for `gh pr edit`

### Current state

- `Resolve-PrAuthorWorktreeTarget` (mockable seam, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`) is a single call: `Resolve-WorktreeItemTarget -Text $CommandText -SessionRoot (Get-Location).Path`.
- `Resolve-WorktreeItemTarget` (`.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`) reads issue signals via `Find-WorktreeItemIssueSignal` and a branch signal via `Find-WorktreeResolutionBranchSignal`. With no issue and no branch it returns `NoTarget` with the detail "the call carries neither a canonical issue number line nor a branch signal (--head, --branch, or branch:), so the item it acts on cannot be identified". With a branch it calls `Resolve-WorktreeItemTargetByBranch` (zero live matches: `NoTarget`; more than one: `Ambiguous`; one: resolved, with an issue cross-check if an issue line is also present).
- `Find-WorktreeResolutionBranchSignal` (`WorktreeTargetResolution.psm1`) applies `$script:BranchPattern`: case-insensitive, either `--head` or `--branch` (preceded by no word character or hyphen, followed by `=` or whitespace) or the label `branch:` (word boundary, optional whitespace), capturing `[A-Za-z0-9][A-Za-z0-9._/-]*`, then trims trailing `.` and `/`. The label alternative matches anywhere in the command text, including inside a trailing shell comment such as `# branch: feature/x`; that is why the comment workaround works today and why it is "incidental". It also matches the text of any quoted argument containing `branch:`.
- `Get-PrAuthorTargetCheckpointResolution` maps `SessionRoot`/`OtherWorktree` to the checkpoint path and every other status to a deny whose text ends: "Pass --head <branch> on the gh pr create command so the call names its own target." That advice is wrong for `gh pr edit`, which has no `--head`.
- `Get-PrAuthorBypassReason` calls `Resolve-PrAuthorArtifactRoot` (in `enforce-pr-author-skill.artifact-root.ps1`) before Case C. That function tries `Resolve-EpicScopeCheckpoint` on the command text first and, if not epic scope, calls `Get-PrAuthorTargetCheckpointResolution`. The artifact root, checkpoint path, and `RelativeBodyAllowed` (true only for `SessionRoot`) all come from the resolved target.
- Existing git precedent: `Invoke-PrAuthorDocsOnlyGitExe` in `enforce-pr-author-skill.docs-only.ps1` is a never-throwing git wrapper returning `ExitCode` and `Output`, with an injectable `GitInvoker`. The worktree-resolution module itself reads git state from files (no git executable). The repository PowerShell rule prefers a wrapper of the form `Invoke-<Tool>Exe -GitArgs`.

### Recommended design

- New sibling file, following the `.artifact-root.ps1` and `.docs-only.ps1` naming (for example `enforce-pr-author-skill.current-branch.ps1`), dot-sourced from the helpers file next to those two. It holds: a git wrapper (`git rev-parse --abbrev-ref HEAD`, never throws, returns exit code and trimmed output, stderr discarded), a function `Get-PrAuthorCurrentBranch` returning the branch name or `$null` (`$null` for non-zero exit, empty output, or the literal `HEAD` which `--abbrev-ref` prints on a detached HEAD), and a function that builds the fallback text.
- In `Resolve-PrAuthorWorktreeTarget`: call `Resolve-WorktreeItemTarget` with the command text as today. If the result is `NoTarget` and the command carried no signal (cheapest test: `Find-WorktreeResolutionBranchSignal` and `Find-WorktreeItemIssueSignal` on the text both empty; do not retry when the original NoTarget came from a branch signal that matched no worktree), obtain the current branch; when non-null, re-resolve with `Resolve-WorktreeItemTarget -Text "branch: $branch"` (or `"$CommandText`nbranch: $branch"`) so the existing branch resolver, ambiguity handling, and `SessionRoot`/`OtherWorktree` labelling all apply unchanged. When the branch is `$null` return the original NoTarget result (AC4 deny retained).
- Rewrite the message in `Get-PrAuthorTargetCheckpointResolution` to name the accepted forms: for `gh pr create`, `--head <branch>`; for `gh pr edit`, no flag exists (`--head` is not valid for `gh pr edit`), so run from the item worktree (branch is derived) or append the shell comment `# branch: <branch>`; both forms are read from the command text. Keep the leading `$($target.ReasonCode): $($target.Detail)` so tests that match the reason-code prefix still pass, and keep the substring `--head` (see tests below).
- Per the rules, a git failure must not throw (an uncaught hook error exits 1, which PreToolUse treats as non-blocking and would allow the call).

### Risk: derived branch in parallel and epic topologies

- The fallback uses the hook process's cwd, which is the pr-author subagent's session directory. The orchestrate skill states the pr-author may run outside the item worktree (it then passes an absolute `--body-file` and relies on `--head` for resolution). In that topology a no-signal command derives the branch of whichever worktree the agent runs in, which can be a coordinator or sibling worktree.
- Consequence analysis: the derived target is a real live worktree, so the gate validates that worktree's checkpoint and reads the body and receipt beneath it. If that worktree holds no checkpoint, the preflight fails closed (`ORCHESTRATOR_STATE_PREFLIGHT_FAILED`). If it holds a sibling item's ready checkpoint and body, the gate could allow a `gh pr edit <N>` against the wrong item's state. That is the false-allow class issue #687 removed; it is bounded to a command that carries no signal while run from the wrong worktree, and the `--body-file` must still be the canonical `artifacts/pr_body_<N>.md` with a matching receipt in that same worktree, so a body authored in another worktree fails the receipt checks.
- Mitigations available without scope growth: (a) keep the instruction in the skill and agent to pass signals when running outside the item worktree; (b) for `gh pr edit <N>`, `Resolve-WorktreeItemTargetByPrNumber` (exported by `WorktreeItemResolution.psm1`, currently used by the epic merge gate) resolves the worktree whose checkpoint records the PR number in `pr_gate.pr_number`; it could be used as a cross-check (derived worktree must not record a different PR number) but this extends the specification and is left to the planner as an option, not recommended by default.
- Epic edge: when the cwd branch is an epic integration branch, `Resolve-EpicScopeCheckpoint` has already declined on the command text, so the fallback resolves the epic worktree through the item path, finds no per-feature checkpoint, and denies. Fail-closed; not a regression. Feeding the derived branch to epic scope is out of the stated acceptance criteria.
- Detached HEAD (typical of CI pull-request checkouts) yields `HEAD`, which maps to `$null`, preserving NoTarget.

### Tests that pin current behavior

- `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`: context "an underivable target denies instead of answering from unrelated state" mocks `Resolve-PrAuthorWorktreeTarget` to NoTarget and asserts `Should -BeLike '*--head*'` on the reason and that the reason starts with the no-target code (`Get-WorktreeResolutionNoTargetReasonCode`); the "never reports success on a sibling checkpoint" row asserts the same prefix. Because the seam is mocked, the new fallback inside the seam does not run here. The new message must keep `--head` in the text or this row must be updated. The first context covers the SessionRoot/OtherWorktree checkpoint path and is unaffected.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`: row "pr-author R2 denies with the no-target code when only the sibling session-root checkpoint is present" mocks no resolver and runs `Invoke-PrAuthorSkillDecision` with the process directory set to a fixture directory through `Invoke-WorktreeResolutionFixtureCall`, with a command that names no branch. With the new fallback this row would call the real git wrapper in the fixture directory; it must mock the new branch seam to return `$null` (or a branch matching no live worktree) to stay deterministic. Other rows in that file that assert the no-target prefix (the rows around "denies with the no-target code" and the parameterized `NoTarget`/`Ambiguous` row) need the same inspection; those that mock `Resolve-PrAuthorWorktreeTarget` are unaffected. The branch-based rows (R1, R3) carry a `--head` command and take the unchanged path.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`: the row "blocks gh pr create --body-file end-to-end in a real pwsh process (exit 0, deny, TARGET_WORKTREE_NOT_DERIVABLE)" spawns a real pwsh, cannot use a Pester mock, and runs a command with no signal. With the fallback it would read the real checkout's branch and resolve it, so on a named branch the outcome changes and on a detached CI checkout it does not: a determinism hazard. The inner script (a here-string) should redefine the new branch function to return `$null` after dot-sourcing the hook, which keeps the deny and the `TARGET_WORKTREE_NOT_DERIVABLE` assertion deterministic.
- `enforce-pr-author-skill.EpicScope.Tests.ps1` (NoTarget fixture through the mocked seam), `ItemArtifactRoot.Tests.ps1`, `BodyNumber`, `DocsOnly.Decision`, `Issue824`, `Payload`, `TriggerScoping`, `epic-base-branch`, and `enforce-pr-author-skill.Tests.ps1` all mock `Resolve-PrAuthorWorktreeTarget`; the seam's inner change does not affect them.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1` covers `Find-WorktreeResolutionBranchSignal`; unaffected because the library is not changed.
- New tests required (new file, for example `enforce-pr-author-skill.CurrentBranch.Tests.ps1`): derived branch re-resolves to a worktree (SessionRoot and OtherWorktree); detached `HEAD` stays NoTarget; non-zero git exit stays NoTarget; empty output stays NoTarget; signal present does not call the git seam; a signal that matches no worktree does not trigger the fallback; ambiguity from the derived branch is returned unchanged; wrapper tests for the never-throw contract with an injected invoker; message tests for the accepted forms (create: `--head`; edit: shell-comment `# branch:` and run-from-worktree; states `--head` is not valid for `gh pr edit`).

### File-size position

`enforce-pr-author-skill-helpers.ps1` reads at 438 lines. The fallback, message text, and a git wrapper with documentation comments would add roughly 40 to 60 lines if inlined, reaching or exceeding the 500-line cap. Move the wrapper and branch-derivation helpers to the new sibling file; the helpers file then needs only a dot-source line, a short conditional in `Resolve-PrAuthorWorktreeTarget`, and the replaced message (net single digits to low tens of lines). The other changed files are far from the cap (allowlist hook about 280 lines; model-routing hook about 300 lines).

### Files to change (Defect 2)

| File | Change |
|---|---|
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | Dot-source the sibling; fallback in `Resolve-PrAuthorWorktreeTarget`; new message in `Get-PrAuthorTargetCheckpointResolution`. Update the header comment that says pr-author passes `--head` on every create. |
| New `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` | Git wrapper, `Get-PrAuthorCurrentBranch`, message builder. |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Add the new hook path (the dependency-closure and completeness tests require it; the existing siblings `.artifact-root.ps1` and `.docs-only.ps1` are listed there). |
| `.claude/agents/pr-author.md` and `.claude/skills/pr-author/SKILL.md` (`## Required --head on gh pr create (issue #687)`) | Add the `gh pr edit` form and the run-from-item-worktree fallback; both files currently say a call without `--head` is denied. |
| Tests listed above | Update R2 row, real-process row; add new file(s). |

## Defect 3: pr-author lacks `gh pr view`

### Current state

- `.claude/agents/pr-author.md` `tools:` lists Read, `Bash(git log *)`, `Bash(git rev-parse *)`, `Bash(gh pr create *)`, `Bash(gh pr edit *)`, `Bash(sha256sum *)`, `Bash(date *)`, `Write(/artifacts/**)`. The frontmatter registers `enforce-pr-author-command-allowlist.ps1` (PreToolUse, matcher `Bash`) and the SubagentStop `validate-pr-author-output.ps1`. The agent body lists the allowed forms in the paragraph after the write protocol.
- `Test-PrAuthorAllowlistForm` (`enforce-pr-author-command-allowlist.ps1`): the `gh` arm returns true for `Token.Count -ge 3`, `pr`, and `create` or `edit` (case-sensitive). `$script:PrAuthorAllowlistFormText` is the sentence echoed in every deny reason.
- Record checks in `Get-PrAuthorAllowlistRecordProblem` already reject wrappers, substitutions, nested records, redirections, VAR= prefixes, and non-allowed delimiters before the form test runs; `gh` global options before `pr` fail the form test because `Token[1]` must be `pr`.

### Recommended change

- Add a `view` clause to the `gh` arm with exact shape: six tokens, `gh pr view <digits> --json closingIssuesReferences,body`, with `<digits>` matched by `^\d+$` and the other tokens compared case-sensitively. This denies `--web`, `--comments`, `--jq`, `--template`, `-R/--repo`, extra or reordered fields, a missing number, a branch or URL argument, and any trailing token. It is read-only by construction. Update `PrAuthorAllowlistFormText` and the header comment form list. Frontmatter `Bash(gh pr view *)` is broader than the hook, which is the intended layering (the frontmatter grants the tool class, the hook narrows it).
- Interaction with `enforce-pr-author-skill.ps1`: `Get-PrAuthorBypassReason` begins with structural `Test-CommandLineInvocation` for `gh pr create` and `gh pr edit` and returns `$null` (allow) for anything else, before any flag, resolution, or receipt logic. The existing row `allows gh pr view 13` in `enforce-pr-author-skill.Tests.ps1` pins this. The token `body` inside `--json closingIssuesReferences,body` is not parsed as the `--body` flag, because flags are compared as exact tokens and the raw-scan fallback runs only for create/edit matches. No change is needed to the skill-gate hook; a new row for the exact new command text is a cheap addition to its tests.
- `validate-pr-author-output.ps1` (SubagentStop): it requires a PR URL, `PR #<n>`, or a `gh pr create|edit` confirmation with a number in the last message. Reporting closing references does not conflict and the hook needs no change. It does not enforce that closing references are reported; that stays a prompt-level obligation unless the planner decides to extend the validator (not required by AC6 or AC7).
- Skill and agent prose (AC7): add a step after every create or edit: run `gh pr view <N> --json closingIssuesReferences,body` as a single command, report the closing issue numbers found, and report any mismatch with the author-asserted list. Code spans written in the skill and agent that start with `gh ` are scanned by AL-34 (below), so every such span must be an allowed form once `<N>` becomes `5`; a bare `gh pr view` or a span with extra flags would fail that row.

### Tests that enumerate the allowlist

- `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1`, named `AL-01` to `AL-38`: `$script:AllowRows` (AL-02 to AL-10) and `$script:DenyRows` (AL-11 to AL-31) are data tables; there is no `gh pr view` entry in either. Rows to add (new ids after AL-38): allow `gh pr view 5 --json closingIssuesReferences,body`; deny `gh pr view 5`, `gh pr view 5 --web`, `gh pr view 5 --json body`, `gh pr view 5 --json closingIssuesReferences,body --jq .number`, `gh pr view --json closingIssuesReferences,body`, `gh pr view abc --json closingIssuesReferences,body`, `gh -R owner/repo pr view 5 --json closingIssuesReferences,body`, and a redirected variant. The synopsis comment ("T-ALLOW, AL-01 to AL-37") and the hook header list need updating.
- AL-33 asserts the exact frontmatter `hooks:` block lines; adding a `tools:` line does not change that block. AL-34 extracts inline code spans starting with `git`, `gh`, `sha256sum`, or `date` from the agent and the skill, substitutes `<N>` and `<branch>`, and requires every span to be allowed; AL-35 requires both documents to contain the two receipt commands. Both constrain the new prose as described above.
- Other pr-author tests that mention the allowlist: none found. Agent-tools tests: no test pins the pr-author `tools:` list. `test_parallel_orchestrator_surface_contracts.py` asserts only that the parallel orchestrator grants no pr-author channel; `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` and `test_push_down_claude_pack_manifest_completeness.py` reference the agent file for manifest membership, not its tools. `claude-architecture-doc.Tests.ps1` checks tool names in the architecture document; whether the document lists pr-author tools was not verified, so the planner should grep `docs/` for the pr-author tool list.
- `.claude/settings.json` has no `gh pr` permission entries, so no permission-list edit is indicated.

### Files to change (Defect 3)

`.claude/agents/pr-author.md` (tools line, allowed-forms paragraph, verification step), `.claude/hooks/enforce-pr-author-command-allowlist.ps1`, `.claude/skills/pr-author/SKILL.md`, the allowlist test file, and optionally a `gh pr view` row in `enforce-pr-author-skill.Tests.ps1`.

## Mirror and Contract Surface

Findings are from globbing for each file name across the repository.

| Changed file | Mirror / bundle locations found | Edit needed |
|---|---|---|
| `.claude/skills/orchestrate/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`. `.agents/skills/orchestrate/SKILL.md` and its `codex-and-agents-customizations` bundle copy are a Codex-specific variant with no pr-author handoff section. No `.github` copy. | `.claude` and Claude bundle: yes. `.agents`: no. |
| `.claude/agents/orchestrator.md` | Claude bundle copy; `.github/agents/orchestrator.agent.md` and its `customizations` bundle copy (no pr-author text); `.codex/agents/orchestrator*.toml` (no pr-author text); `tests/fixtures/codex_native_converter/claude/.claude/agents/orchestrator.md` and the `github_copilot` fixture (no pr-author text). | `.claude` and Claude bundle: yes. Others: no (fixtures are static converter inputs; the converter tests do not depend on the pr-author section). |
| `.claude/skills/pr-author/SKILL.md` | Claude bundle copy. `.agents/skills/pr-author/SKILL.md` and its bundle copy are a shorter variant sharing the "sourced only from ..." sentence; no test found comparing them with the `.claude` text. | `.claude` and Claude bundle: yes. `.agents` pair: optional parity edit for the AC2 sentence only; AC8 mentions `.agents`/`.codex` "as the contract tests require", and none require this one. |
| `.claude/agents/pr-author.md` | Claude bundle copy; `.github/agents/pr-author.agent.md` and bundle copy (Copilot surface, own auto-close wording); `.codex/agents/pr-author.toml` plus `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` variants and their bundle copies. | `.claude` and Claude bundle: yes. `.codex` toml variants: no. |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-command-allowlist.ps1`, `.claude/hooks/enforce-model-routing-receipt.ps1` | Claude bundle copies of each. No `.codex/hooks` counterparts exist. | `.claude` and Claude bundle: yes. |
| New hook sibling file | Needs a Claude bundle copy and an entry in `pack-manifests/core.json` of the Claude customizations. | Yes. |

Codex generator implication: `scripts/dev_tools/generate_codex_agent_variants.py` contains no reference to `.claude` paths (searched), and the `.codex/agents/pr-author*.toml` text is independent of `.claude/agents/pr-author.md`. Editing the `.claude` agent therefore does not require regenerating Codex variants, but `--check` (run in `_quality-checks.yml`) should still be run as part of the toolchain to confirm no drift. If the planner chooses to edit `.codex/agents/pr-author.toml` (not recommended), variants and bundle copies are generated and must be regenerated.

Contract tests to run after the edits (from the execution-environment brief): `test_push_down_claude_resource_contracts.py` (bundle text equality, covers every edited `.claude` file and the new hook), `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` (new hook file must be in `core.json`; the helpers file gains a `$PSScriptRoot` dependency), `test_codex_agent_wrapper_contracts.py` and `test_codex_handoff_contract_parity.py` (only if Codex surfaces change), the Codex generator `--check`, `test_claude_rules_frontmatter.py` (not affected), `hook-dependency-guard-completeness.Tests.ps1` (guarded dot-source pattern in hooks; the new dot-source in the helpers file should follow the same pattern as the existing sibling dot-sources), `enforcement-hooks-no-python-invocation.Tests.ps1` (the new hook code must not invoke Python), and `parallel_orchestrator_surface_expectations.py` hashes (they pin `epic-orchestrate` and `epic-orchestrator` only, which this change does not touch). Tests that read `orchestrate/SKILL.md` or `orchestrator.md` text were searched for the PR-authoring headings and pr-author strings; none pin those sections.

The execution-environment brief states no fact this change alters, so no brief update is indicated.

## Behavior Semantics

- Delegation line: `Author-asserted autoclose issues: #<issue-num>`, one line in the pr-author delegation prompt, number from checkpoint `issue-num`. Omitted only when the checkpoint has no `issue-num` or `epic_mode` is true.
- Pr-author decision: `- Closes #NNN` is valid from the context's verified list, the PR-Intent author-asserted list, or the delegation prompt line; `- None` only when none has an entry. The existing rule "do not emit `Closes` if GitHub validation is unavailable" and "do not invent numbers" must be reconciled with the new source in the same edit.
- Target fallback ordering: explicit signal in the command, else current checked-out branch, else deny. Detached HEAD, git failure, or empty output deny with the same code.
- Allowlist: only the exact view form; every other `gh pr view` form denies with `PR_AUTHOR_COMMAND_NOT_ALLOWED:`.

## Rejected Alternatives (brief)

- Standalone Agent PreToolUse hook for AC3: duplicates identity resolution already in the model-routing hook.
- Static-only test for AC3: does not fail on an actual omitted delegation.
- Inlining the branch fallback in the helpers file: reaches the 500-line cap.
- Deriving the target for `gh pr edit <N>` from the PR number alone (`Resolve-WorktreeItemTargetByPrNumber`): depends on `pr_gate.pr_number` already being recorded and does not help `gh pr create`; kept only as an optional cross-check.
- Editing `.codex/agents/pr-author*.toml`: no behavior there depends on the `.claude` agent.

## Testing Implications

- Pester only for hooks, matching repository policy; no temporary files; git, checkpoint reads, and the worktree resolver reached through mocks of wrapper functions, never the executable.
- New suites: author-asserted delegation check; current-branch fallback and wrapper; allowlist rows; static-contract rows.
- Edited existing rows: R2 in the WorktreeResolution suite and the real-process row in the OrchestratorStatePreflight suite (both need the new branch seam neutralized); the `--head` message assertion in the TargetResolution suite only if the new message drops that token.
- Coverage: each changed or new PowerShell file needs at least 85% line coverage from `artifacts/pester/powershell-coverage.xml`; the new sibling file counts in the denominator. Run the touched Pester suites in seeded shuffled order (at least three seeds) and a fresh single-process run over `tests/scripts`.

## Pre-Mortem

- Review checklists: a reviewer may find the three prose files disagree (for example the pr-author skill allowing `Closes` from the prompt while `## PR Body Structure` item 11 still says "only from verified autoclose lists"), or the new prose naming a command form that AL-34 rejects. Mitigation: the plan edits `## PR Body Structure` item 11 and `## Issue/PR Reference Rules` together, and the plan includes a task that re-runs the allowlist suite after the prose edits.
- Coverage: the new sibling hook file and the new model-routing branch could land below 85% line coverage if the git-wrapper body (process start) is only reachable by a real call. Mitigation: give the wrapper an injectable `GitInvoker` as `Invoke-PrAuthorDocsOnlyGitExe` does, and test the body with a test-local stand-in; verify per-file coverage from the coverage XML, not from the MCP summary (PoshQC MCP results carry no output).
- Mirror parity: every edited `.claude` file has a byte-equal bundle copy under `extensions/drm-copilot/resources/claude-customizations/`, the new hook needs a bundle copy plus a `core.json` entry, and a mirror edit by a Write call counts against the batch budget. Mitigation: plan mirror copies through the orchestrated large path, run `test_push_down_claude_resource_contracts.py`, the two manifest tests, and the Codex generator `--check` after the edits; the plan's own `Mirror parity` bullet names each mirror. No execution-environment brief update is needed because no stated fact changes.
- File size: `enforce-pr-author-skill-helpers.ps1` (about 438 lines) would exceed 500 if the fallback is inlined, and the new test cases could overgrow existing suites. Mitigation: the new sibling hook file and new test files; confirm each touched file with `@(Get-Content -LiteralPath <path>).Count` after editing.
- Test isolation: the fallback makes two existing rows depend on the real checkout (R2 in the WorktreeResolution suite; the real-pwsh row in the OrchestratorStatePreflight suite), which passes locally on a named branch and differs in CI on a detached checkout. Mitigation: neutralize the branch seam in both rows, never call the real git in a unit test, run the touched suites in shuffled order with three seeds, and keep the new mocks scoped to the test that registers them.
- CI-only behavior: the Linux hook-suite job runs `tests/scripts/claude-hooks` on a case-sensitive file system with no drive letters; synthetic roots must be composed with `Join-Path` or the existing `/synthetic-worktrees/...` pattern, and a CI pull-request checkout is detached, so any test touching the real branch would differ. Mitigation: all branch inputs injected; new test file names match the case used in `-Path` references.
- Evidence: hook behavior on this branch cannot be proven by a live isolated subagent (isolated subagents run `main`'s hook scripts), and PoshQC MCP results carry no counts. Mitigation: evidence is the Pester JUnit file and coverage XML, written under `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/evidence/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`; any acceptance condition that depends on a live subagent exercising the new hook is excluded from the plan.

## Open Items for the Planner

- Confirm physical line counts of the three hook files before editing (this researcher could not run a count).
- Decide whether the `.agents/skills/pr-author` pair receives the AC2 sentence (optional; no contract test forces it).
- Confirm whether `docs/` architecture text lists the pr-author tools.
- The change touches more than three production PowerShell files once bundle copies and the new sibling are counted (batch-budget rule), so it belongs on the orchestrated large path.
- `spec.md` is still a template with empty design sections; the planner or prd-feature step should fill them from this note.

## Automation Feasibility

No human interaction is required. Every change is a text edit to repository files, a PowerShell hook change, or a Pester test, and every verification step (Pester suites with coverage, the Python contract tests, the Codex generator `--check`, and the format and analyze tools) runs non-interactively through the PoshQC and repository toolchain.
