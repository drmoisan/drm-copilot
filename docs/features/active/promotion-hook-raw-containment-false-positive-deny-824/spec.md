# promotion-hook-raw-containment-false-positive-deny (Spec)

- **Issue:** #824 (primary); bundled #742, #733
- **Parent (optional):** Epic #852 `enforcement-hook-precision`, child C1a command-invocation matching (`docs/features/epics/enforcement-hook-precision/epic.md`)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T14-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria live in this file only; no `user-story.md` by design)
- **Authoritative research:** `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/research/research.2026-10-08T14-00.md` (cited below as "research §N")

## Context

- **Summary.** `Resolve-CommandLineInvocation` (`.claude/hooks/hook-command-invocation.ps1:166-238`) classifies every wrapper-led segment (`pwsh -Command '...'`, `bash -c "..."`, `xargs`, `eval`, and others) and every segment with a live substitution through `Test-CommandLineRawContainment` (`:92-117`, called at `:202-205`). That check is an ordinal, case-insensitive substring test with no word boundaries, no ordering, and no adjacency. Its docblock (`:98-99`) states that "a false positive only forces a checkpoint check". That statement is false for the hooks that consume it:
  - `enforce-promotion-mcp-only.ps1` denies unconditionally with `PROMOTION_MCP_ONLY_BLOCKED` (`:126-128`); it has no checkpoint (#824 main defect).
  - `enforce-epic-worktree-removal-gate.ps1` and `enforce-parallel-worktree-removal-gate.ps1` receive an empty operand and deny with `TARGET_WORKTREE_NOT_DERIVABLE`, which no checkpoint can authorize (#824 addendum 1).
  - `enforce-pr-author-skill-helpers.ps1` reaches Case B and denies with `PR_AUTHOR_SKILL_BLOCKED` (`:319-323`) (#733 items 2 and 4).
- A second, independent cause produces #742 item 1: `Skip-CommandLineOption` (`:119-164`) treats `git --version` as an unmodeled option, and rule R3 (`:220-223`) classifies an unmodeled option as a match (research §4).
- #733 item 1: the `pr-author` agent's `Bash(git log *)` permission entry does not form a command boundary, because the repository runs in `defaultPermissionMode: bypassPermissions` (`.claude/settings.json:292`), which subagents inherit (research §6.2).
- **Observed environments.** Windows 11 Pro 10.0.26200, PowerShell 7 hooks registered as `pwsh -NoProfile -File` on both runtimes (`.claude/settings.json:95-123`; `.codex/config.toml:124-149`). The matcher is pure string logic, so the defect is platform-independent.
- **Impact and severity.** High. Every agent session that sends a read-only wrapped command or a heredoc commit message containing the governed letters is denied with no escape path. Agents lose remediation rounds and adopt workarounds. The same loose matcher is shared by the Claude hooks enumerated in research Claim N1 (validate-bash, enforce-promotion-mcp-only, enforce-pr-author-skill.epic-base-branch, enforce-pr-author-skill-helpers, enforce-parallel-worktree-removal-gate, enforce-orchestration-preimplementation-gate, enforce-epic-worktree-removal-gate, enforce-epic-merge-gate) and the Codex hooks (validate-bash, enforce-promotion-mcp-only, enforce-orchestration-preimplementation-gate, enforce-epic-worktree-removal-gate, enforce-epic-merge-gate).
- **First observed.** #824 filed 2026-10-03 against main at 93725814. #742, #733 observed 2026-09 (#706, #707, #712, #713, #714, #715). A prior #824 run (read-only checkout `wt-824`, head dc0d8d4c) went through three review passes without converging (research §7).

## Repro & Evidence

All reproductions below are carried as named Pester regression cases (Test Strategy). Each trace was established by reading the code (research §3, §4, §6.1); fail-before evidence is captured during execution.

| ID | Hook | Command | Actual | Expected |
|---|---|---|---|---|
| R-824-MAIN | `enforce-promotion-mcp-only.ps1` (Claude, Codex) | `pwsh -NoProfile -Command '$parts = New-Object System.Collections.Generic.List[string]; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'` | Deny, `PROMOTION_MCP_ONLY_BLOCKED` (gh issue reason, `:43`) | Allow |
| R-824-ADD1 | Epic and parallel worktree-removal gates (Claude); epic gate (Codex) | `pwsh -NoProfile -Command 'Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'` | Deny, `EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE` (epic `:399-403`; parallel `:416-420`) | Allow |
| R-742-1 | Epic and parallel worktree-removal gates (Claude); epic gate (Codex); preimplementation gate | `git --version` | Deny, `PARALLEL_WORKTREE_REMOVAL_BLOCKED` / `EPIC_WORKTREE_REMOVAL_BLOCKED`; also classified as `git add` by the preimplementation gate (`:142`) | Allow; not classified |
| R-733-714 | `enforce-pr-author-skill.ps1` | `git commit -m "$(cat <<'EOF'` + body containing "through", "process", "created" + `EOF` + `)"` (representative fixture; the exact #714 text is not recorded in the repository, research §6.1) | Deny, `PR_AUTHOR_SKILL_BLOCKED` | Allow |
| R-733-GREP | `enforce-pr-author-skill.ps1` | `pwsh -NoProfile -Command 'Select-String -Path x.md -Pattern "high priority" \| ForEach-Object { "create" }'` (prior-run fixture AC-18, `wt-824: spec.md:211`) and a `sed -n` / `grep` variant inside `$(...)` | Deny, `PR_AUTHOR_SKILL_BLOCKED` | Allow |
| R-733-715 | `enforce-pr-author-skill.ps1` | `gh pr create --body-file "artifacts/pr_body_5.md"`, `--body-file=artifacts/pr_body_5.md`, `--body-file <session-root>/artifacts/pr_body_5.md`, `--body-file ./artifacts/pr_body_5.md`, `--body-file artifacts\pr_body_5.md` | Deny, `PR_BODY_PATH_NONCANONICAL` (raw regex at `:171`) | Proceed to context/receipt checks |
| R-733-712 | pr-author agent (no hook today) | `git log -1 --format=%H && sha256sum artifacts/pr_body_5.md && date -u +%Y-%m-%dT%H:%M:%SZ` | Accepted as a whole under `Bash(git log *)` | Denied as a chain; each sanctioned segment allowed when issued alone |

- **Frequency.** Deterministic. Any wrapper-led or substitution segment whose raw text contains the governed words as substrings classifies.
- **Logs.** Deny text is emitted as the PreToolUse decision reason; no additional logs exist.

## Scope & Non-Goals

### In scope

1. **#824 main.** Replace substring containment on the classification path with structural matching inside wrapper payloads and substitution bodies, plus a closed Indeterminate fallback (research §8).
2. **#824 addendum 1.** Both Claude worktree-removal gates and the Codex epic gate: allow the reproduction; authorize every matched removal target; keep the five listed invocations gated.
3. **#742 item 1.** `git --version` (and the other git/gh terminal options) resolves as a non-match in every consumer.
4. **#733.** Matching-only changes in `enforce-pr-author-skill.ps1` and its helpers; a new per-segment allowlist hook for the `pr-author` agent; a sanctioned receipt procedure.
5. Codex copies under `.codex/hooks/` where one exists; bundled mirrors under `extensions/drm-copilot/resources/`; pack-manifest entries and parity coverage for new files.

### Out of scope / non-goals

- **#824 addendum 2** (#823 follow-ups FU-823-1, FU-823-2, FU-823-3, FU-823-5 and #823 review notes A and B). A concurrent parallel run delivers it. This feature plans and changes none of it, including `.codex/codex-web-setup.sh`, `KcovFunctionCoverageGate`, `_shell-coverage.yml`, the TaskMaster neutralization, and the `validate-feature-review-coverage` thresholds present on the `wt-824` branch (research §7).
- **#742 item 2 (worktree isolation guard).** Not repository-owned (orchestrator decision D1). A repository-wide content search for the guard's message fragments returns no match outside `docs/`, no project hook implements it, and the user-level PreToolUse hook only emits `{}` (research §5.1). Disposition: no code change; a #742 PR comment records that it is a Claude Code runtime control and lists the established workarounds (`sh file.sh`, `npx --yes ...`, MCP PoshQC tools). An upstream report is an optional human action.
- **#742 item 3 (evidence-filename Write guard, "report").** Not repository-owned (D1). No repository Write/Edit hook contains such a rule; `enforce-evidence-locations.ps1` matches directory prefixes only (`:65-80`) (research §5.2). Disposition: no code change; recorded in the same #742 PR comment.
- **#742 item 4 (`cd ... && <read>`).** Repository-owned but intentional: `validate-bash.ps1` `CdChainedReadCommandPattern` (`:222`), `Get-CdChainedReadCommandMatch` (`:230-323`), deny text `:340-343`, rationale `:214-221` (research §5.3). Disposition: unchanged behavior; recorded in the #742 PR comment.
- Changes to `enforce-pr-author-skill.ps1` beyond matching (worktree resolution, session-root reads) belong to C3 (#850).
- Per-segment `git -C` resolution and exempt-operand precision belong to C1b (#732, #738).
- Script-file forms (`bash x.sh`, `pwsh -File x.ps1`) remain uninspected, which is parity with today.
- No bash or Python port of any hook.

### Explicitly excluded systems

- The Claude Code permission engine and runtime guards (not modifiable from this repository).
- `.claude/settings.json` hook registration (the new pr-author hook is registered in agent frontmatter, not globally; research §8 rejected alternatives).
- Codex has no parallel worktree gate and no pr-author hook (research §10); #733 changes are Claude-only.

## Root Cause Analysis

### Confirmed root cause (by code trace, research §2-§4, §6)

1. **Substring classification (R2).** `Resolve-CommandLineInvocation` rule R2 (`hook-command-invocation.ps1:202-205`) classifies a wrapper-led or live-substitution segment when `Test-CommandLineRawContainment` (`:92-117`) finds the command word and each subcommand element as substrings anywhere in the raw text. A balanced quoted payload is a single token (`hook-command-scanner.ps1:49-97`), so the payload is never matched structurally.
   - R-824-MAIN: "gh" in "through", "issue" in "(issue #1)", "new" in "New-Object" (research §3).
   - R-824-ADD1: "git" in `git status`, "worktree" in "worktrees", "remove" in "Remove-Item" (research §4).
   - R-733-714: the double-quoted `$(cat <<'EOF' ...)` sets `HasLiveSubstitution` (`hook-command-scanner.ps1:382`); the commit body supplies "gh", "pr", "create" (research §6.1).
2. **Unmodeled option classifies (R3).** `Skip-CommandLineOption` returns `Unmodeled = $true` for `--version` (`:160`); R3 (`:220-223`) classifies. R-742-1 follows (research §4).
3. **Empty operand on classification.** R1, R2, and R3 set `OperandIndex = -1`; `Get-CommandLineOperand` returns `@()` (`:310-312`); the gates pass `$null` to the run-target resolver, which returns `NoTarget` (`TARGET_WORKTREE_NOT_DERIVABLE`, `.claude/lib/worktree-resolution/WorktreeResolution.psm1:59`). The deny is effectively unconditional.
4. **First-match-only reading.** Only the first matching segment is read (`:166-238`), so `git worktree remove B && git worktree remove A` authorizes on B's path alone and never inspects A (research §2.1).
5. **Raw-text body-file regex.** Check 1 (`enforce-pr-author-skill-helpers.ps1:171`) uses `-cnotmatch '--body-file\s+artifacts/pr_body_(\d+)\.md\b'` over the whole command text, rejecting quoted, `=`, absolute, and backslash spellings and accepting the pattern anywhere in the text (research §6.1).
6. **No command boundary for pr-author.** `Bash(git log *)` and siblings (`pr-author.md:10-13`) are not enforced under `bypassPermissions` (research §6.2).

### Pre-existing structural gaps closed by this change (research §2.1)

- Backslash-newline continuation produces a `\` token (`ConvertTo-CommandLineToken`, `hook-command-scanner.ps1:83-93`), so `gh issue \<LF>create` does not match structurally.
- The command word is compared literally (`:215`), so `/usr/bin/git` and `gh.exe` do not match.
- `--exec-path` is modeled as `WithArgument` (`:34`), but git accepts its value only in `=` form.

### Affected components

- `.claude/hooks/hook-command-invocation.ps1` and `.codex/hooks/hook-command-invocation.ps1` (483 lines each).
- `.claude/hooks/hook-command-scanner.ps1` and Codex copy (483 lines each), only if the `Delimiter` field and continuation normalization require it.
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (457 lines), `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (474 lines), `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`.
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (385 lines) and `.claude/hooks/enforce-pr-author-skill.ps1`.
- `.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`.
- Bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/`.

## Proposed Fix

### Design summary (what changes where):

Parse wrapper payloads and substitution bodies, then match the governed invocation structurally inside them; fall back to a closed **Indeterminate** classification only when the governed words are present as whole tokens and the payload is not proven inert (research §8, recommended approach).

1. **Pre-normalization.** Replace POSIX backslash-newline with a space before segmenting. PowerShell payloads rely on the PowerShell parser.
2. **Command-word normalization.** At every depth, take the leaf after the last `/` or `\` and strip a trailing `.exe`, case-insensitively.
3. **Terminal options.** Add a modeled `Terminal` list per command word. git: `--version`, `-v`, `--help`, `-h`, `--html-path`, `--man-path`, `--info-path`, and `--exec-path` without `=`. gh: `--version`, `--help`. A terminal option ends the segment as a resolved non-match. Correct `--exec-path` so that only the `--exec-path=<value>` form takes a value.
4. **Wrapper payload extraction** (new module):
   - POSIX shells (sh, bash, zsh, dash, ksh): the argument after `-c`, plus trailing positional arguments.
   - `pwsh`, `powershell`: the text after `-Command`, `-c`, `-CommandWithArgs`, or `-cwa`. `-EncodedCommand`, `-e`, `-ec`: decode base64 UTF-16LE and recurse; a decode failure is Indeterminate.
   - `eval`: the arguments joined.
   - `xargs`: the remaining tokens as a command whose operands are incomplete (`OperandsComplete = $false`).
   - Transparent wrappers (command, env, nohup, time, timeout) keep their current handling.
   - Recursion depth limit 4; reaching the limit is Indeterminate.
5. **Dialect-correct parsing.** POSIX payloads are re-segmented with `Read-CommandLineSegment`. PowerShell payloads are parsed with `[System.Management.Automation.Language.Parser]::ParseInput` (in memory, no execution); every `CommandAst`, including nested script blocks and subexpressions, is visited. A parse error is treated as Unbalanced.
6. **Substitution bodies.** For a top-level segment with `HasLiveSubstitution`, re-segment the content of each double-quoted span that contains `$(` or a backtick. Heredoc bodies remain masked by the scanner, so a `$(cat <<'EOF' ... EOF)` commit body is inert.
7. **Classification per segment at each depth:**
   - Unbalanced, parse error, decode failure, or depth limit: **Indeterminate**.
   - Structural token walk (extended by items 2 and 3) matches: **Structural**, carrying operands, ordered global options, and `OperandsComplete`.
   - Otherwise, for a segment inside a wrapper payload or substitution body: **Indeterminate** when both (a) the command word and every subcommand element occur as whole tokens (`(?<![\w-])word(?![\w-])`, `IgnoreCase, CultureInvariant`; prior art `wt-824: .claude/hooks/hook-command-raw-invocation.ps1:88-111`) in the root segment's raw text (whole command text for `xargs`-led segments), and (b) the payload is not proven inert.
   - Otherwise: no match.
8. **Inert proof (orchestrator decision D3).** A payload is proven inert only when every command in it is fully literal (no variable, splat, subexpression, `$`, or backtick token), no command name is non-literal, and every string literal or bare argument that contains the command word as a whole token is an argument to a command in the fixed sink allowlist: `Write-Output`, `Write-Host`, `Write-Verbose`, `Write-Information`, `echo`, `printf`, `Select-String`, `grep`, `rg`. The allowlist fails closed; any other command (for example `iex`, `Invoke-Expression`, `Start-Process`, `ForEach-Object`) is not inert. The list is not extended in this feature.
9. **All matches.** Results are returned for every match in source order, not only the first.
10. **Worktree gates (D2).** Replace `Get-EpicWorktreeRemovalCommandPath` (Claude `:111-150`), `Get-ParallelWorktreeRemovalCommandPath` (`:168-211`), and `Get-CodexWorktreeRemovalPath` (Codex `:36-68`) with `Resolve-CommandLineInvocationTarget`. `NoMatch` allows (out of the gate's scope). `Indeterminate` denies with the existing prefix and the `TARGET_WORKTREE_NOT_DERIVABLE` detail. `Targets` authorizes each target through the existing checkpoint cascade and allows only when every target is authorized; the deny names the first unauthorized target. Wrapped removals (`pwsh -Command 'git worktree remove <path>'`, `bash -c "git worktree remove <path>"`) become authorizable by a checkpoint; this is an intended behavior change accepted by the orchestrator (D2, research §4).
11. **pr-author skill hook (D4, matching only).** In `enforce-pr-author-skill-helpers.ps1`:
    - Gate `gh pr create` / `gh pr edit` detection (`:279-280`, `:290-291`) on the new matcher, so commit-message text and read-only grep/sed/Select-String payloads no longer classify.
    - Read `--body-file` through `Get-CommandLineFlagValue` (quotes stripped; `--flag value` and `--flag=value`). Normalize: backslashes to `/`, strip a leading `./`, convert a rooted path to a path relative to the session root via `[System.IO.Path]::GetRelativePath`. Require `-cmatch '^artifacts/pr_body_(\d+)\.md$'`. Keep the session root behind one helper (for example `Get-PrAuthorBodyFileRoot`) so C3 (#850) changes one line.
    - Restrict the raw `--body*` `IndexOf` fallback (`:299-311`) to Indeterminate matches.
12. **pr-author allowlist hook (D4, new file).** Add `.claude/hooks/enforce-pr-author-command-allowlist.ps1`, registered in `.claude/agents/pr-author.md` frontmatter under `hooks.PreToolUse` with matcher `Bash`, beside the existing `SubagentStop` entry (`pr-author.md:15-20`). It denies with leading token `PR_AUTHOR_COMMAND_NOT_ALLOWED:` unless every segment, at every depth, structurally matches exactly one allowed invocation:
    - `git log ...` and `git rev-parse ...` with no git global options before the subcommand.
    - `gh pr create ...`, `gh pr edit ...` (still subject to `enforce-pr-author-skill.ps1`).
    - `sha256sum artifacts/pr_body_<N>.md` with exactly one operand matching `^artifacts/pr_body_\d+\.md$` and no options.
    - `date -u` with at most one additional argument that begins with `+` (for example `+%Y-%m-%dT%H:%M:%SZ`).
    It also denies any segment that carries a redirection token, is wrapper-led, contains a substitution, is Unbalanced, or is Indeterminate. The two receipt forms are allowed only as single segments (a chain is evaluated segment by segment and any non-allowed segment denies the whole command). `enforce-pr-author-skill.ps1` is not structurally reorganized so that C3's later edits do not collide.

### Boundaries and invariants to preserve:

- **Fail-closed** for any unresolvable or ambiguous target (epic Shared Design). No Indeterminate classification and no unreadable operand routes to an allow (prior review rule, research §7).
- **Unbalanced segments remain fail-closed** in every consumer (D3).
- **Deny reasons keep their leading tokens:** `PROMOTION_MCP_ONLY_BLOCKED:`, `EPIC_WORKTREE_REMOVAL_BLOCKED:`, `PARALLEL_WORKTREE_REMOVAL_BLOCKED:`, `PR_AUTHOR_SKILL_BLOCKED:`, `PR_BODY_PATH_NONCANONICAL:`. Only the new hook introduces `PR_AUTHOR_COMMAND_NOT_ALLOWED:` (research §13).
- **Existing public signatures** of `Test-CommandLineInvocation`, `Resolve-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag`, `Test-CommandLineMention`, `Get-CommandLineGlobalOption`, and `Get-CommandLineTransparentWrapperName` are preserved.
- **`hook-command-invocation.ps1` remains owned by C1a**; later children consume the API and do not re-implement substring matching.
- **No Python** in any hook. **No file exceeds 500 lines.**
- **Claude, Codex, and bundled copies** of each changed shared module remain byte-identical where they are required to be.
- The `promotion` hook's adjacency regex (`enforce-promotion-mcp-only.ps1:116-120`), forbidden-token check (`:106-112`), and `gh api ... POST` check (`:136-141`) are unchanged.

### Dependencies or blocked work:

- Upstream: none (`depends_on: []` in the epic manifest).
- Downstream consumers of the matcher API defined below: C1b (#732, #738) and C3 (#850). C3 also edits `enforce-pr-author-skill.ps1` and both worktree gates; this feature keeps those edits to matching and target resolution.
- Concurrent: the #824 addendum 2 parallel run. No file overlap is planned; if a shared file is touched by both runs, the later merge rebases.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

| File (plus Codex copy and bundled mirrors where they exist) | Change |
|---|---|
| `.claude/hooks/hook-command-invocation.ps1`, `.codex/hooks/hook-command-invocation.ps1` | Add `Terminal` table and command-word leaf normalization; add `Status`, all-matches, payload-aware resolution through the new modules; add `Get-CommandLineInvocation`; remove `Test-CommandLineRawContainment` from the classification path; correct the contract text at `:28-30`, `:96-99`, `:172-174`. Operand and flag readers move out to stay under 500 lines. |
| new `.claude/hooks/hook-command-payload.ps1`, `.codex/hooks/hook-command-payload.ps1` | Wrapper payload extraction, base64 decode, PowerShell AST adapter, substitution bodies, inert proof, `Read-CommandLineInvocationSegment`, `Test-CommandLineWordPresent`. |
| new `.claude/hooks/hook-command-invocation-operands.ps1`, `.codex/hooks/hook-command-invocation-operands.ps1` | Moved `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag`; new `Resolve-CommandLineInvocationTarget`. |
| `.claude/hooks/hook-command-scanner.ps1`, Codex copy (conditional) | Backslash-newline normalization and `Delimiter` capture. If the line budget requires it, move `Read-CommandLineHeredocHeader` and `Read-CommandLineHeredocBody` (`:198-301`) to new `hook-command-heredoc.ps1` (both surfaces). |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | Authorize every target via `Resolve-CommandLineInvocationTarget`; Indeterminate denies with the existing prefix. |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (and `enforce-pr-author-skill.ps1` only if a call site moves) | Matching-only changes listed in design item 11. |
| new `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | Per-segment allowlist (design item 12). |
| `.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md` | Frontmatter `hooks.PreToolUse` registration; receipt procedure names `sha256sum artifacts/pr_body_<N>.md` and `date -u +%Y-%m-%dT%H:%M:%SZ` as separate single-segment commands (`pr-author.md:46-65`, `SKILL.md:47-71`). Planning confirms whether `.github/agents/pr-author.agent.md` and `.codex/agents/pr-author*.toml` name the receipt procedure and updates them if so. |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (`:55-56`), `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (`:45-46`) | List each new module and the new hook. |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30` | Add new module names to `SharedModuleNames` on the existing line (file is at 497 lines). |
| `enforce-promotion-mcp-only.ps1`, `validate-bash.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1` (both surfaces where present) | No production change required beyond any dot-source line needed for new modules; regression rows only. |

Every dot-sourcing consumer must load the new modules, either through `hook-command-invocation.ps1` dot-sourcing them (preferred; consumers unchanged) or by explicit lines.

#### Functions/classes/CLI commands impacted:

- Changed behavior, same signature: `Resolve-CommandLineInvocation` (adds `Status`; no R2 substring classification; R3 no longer classifies terminal options), `Test-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag`, `Test-CommandLineMention` (now token-bounded), `Skip-CommandLineOption` (terminal options), `Get-CommandLineGlobalOption` (adds `Terminal` property).
- Removed from the classification path: `Test-CommandLineRawContainment`. It may remain defined for compatibility but no consumer path calls it; a negative-control test pins this.
- New: `Read-CommandLineInvocationSegment`, `Get-CommandLineInvocation`, `Resolve-CommandLineInvocationTarget`, `Test-CommandLineWordPresent` (API below); internal helpers for payload extraction, AST adaptation, and inert proof.
- Replaced: `Get-EpicWorktreeRemovalCommandPath`, `Get-ParallelWorktreeRemovalCommandPath`, `Get-CodexWorktreeRemovalPath`.
- Changed: pr-author helper check 1 and the `--body*` fallback; new allowlist hook entry point and decision function (testable seam, for example `Invoke-PrAuthorCommandAllowlistDecision -CommandText <string>`).

#### Data flow and validation changes:

1. Hook reads `tool_input.command`.
2. `Read-CommandLineInvocationSegment` produces top-level segments, wrapper payload segments, substitution-body segments, and argument-injector segments in source order, each with depth, origin, dialect, tokens, and flags.
3. `Get-CommandLineInvocation` classifies each segment as Structural, Indeterminate, or no match.
4. Consumers decide:
   - Promotion: any match (Structural or Indeterminate) denies.
   - Worktree gates: `Resolve-CommandLineInvocationTarget` -> NoMatch / Targets (authorize each) / Indeterminate (deny).
   - pr-author skill: Structural `gh pr create|edit` reads flags from the matched segment; Indeterminate keeps the raw `--body*` fallback.
   - pr-author allowlist: every segment must be an allowed Structural invocation.
   - Other consumers (validate-bash, preimplementation, merge gate, epic-base-branch): unchanged logic over the corrected matcher.

#### Error handling and logging updates:

- Parse errors, base64 decode failures, and depth-limit hits are not thrown to the caller; they produce an Indeterminate record with `Reason` set (`Unbalanced`, `Opaque`, `DepthLimit`), which consumers treat fail-closed.
- An unexpected exception inside the new modules propagates to the hook's existing top-level handling, which already denies on failure; this feature does not add a fail-open path.
- No new logging. Deny text for the worktree gates on Indeterminate keeps the existing `TARGET_WORKTREE_NOT_DERIVABLE` detail. The multi-target deny names the first unauthorized target in the existing message format.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a revert of the PR; the shared module, its Codex copy, and the bundled mirrors revert together. The new pr-author hook is removed by reverting the frontmatter registration.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Matcher API for downstream consumers (research §9). Names follow `<Verb>-CommandLine<Noun>`.

```powershell
# Preserved signatures (behavior changes noted)
Test-CommandLineInvocation -CommandText <string> -CommandWord <string> -SubcommandPath <string[]>
# => [bool] true for any match, Structural or Indeterminate.

Resolve-CommandLineInvocation -CommandText <string> -CommandWord <string> -SubcommandPath <string[]>
# => $null, or [pscustomobject] { Segment, OperandIndex [int], Status [string] } for the FIRST match.
#    OperandIndex = -1 when Status = 'Indeterminate'.

Get-CommandLineOperand / Get-CommandLineFlagValue / Test-CommandLineFlag   # existing parameters
# Read from the FIRST Structural match; inside a wrapper payload this is the payload segment's tokens.

Test-CommandLineMention -CommandText <string> -CommandWord <string> -SubcommandPath <string[]>
# => [bool] token-bounded presence (Test-CommandLineWordPresent), informational only.

# New
Read-CommandLineInvocationSegment -CommandText <string> [-MaxDepth <int> = 4]
# => [pscustomobject[]] in source order, each:
#    Index [int], RootIndex [int], Depth [int],
#    Origin [string]      'TopLevel' | 'WrapperPayload' | 'Substitution' | 'ArgumentInjector'
#    Wrapper [string]     'bash','sh','zsh','dash','ksh','pwsh','powershell','xargs','eval', or ''
#    Dialect [string]     'Posix' | 'PowerShell'
#    RawText [string], RootRawText [string], Tokens [string[]],
#    CommandWord [string] (leaf-normalized, '.exe' stripped)
#    Literal [bool]       (no $, backtick, splat, or subexpression token)
#    Unbalanced [bool], Opaque [bool], OpaqueReason [string]
#    Delimiter [string]   separator that ended the segment: ';','&&','||','|','&',"`n",'(',')','{','}','$(','`',''

Get-CommandLineInvocation -CommandText <string> -CommandWord <string> -SubcommandPath <string[]>
# => [pscustomobject[]] in source order, each:
#    Status [string]   'Structural' | 'Indeterminate'
#    Reason [string]   '' | 'Unbalanced' | 'Opaque' | 'DynamicPosition' | 'NotProvenInert' | 'DepthLimit'
#    Segment [pscustomobject] (iterator record), OperandIndex [int] (-1 when Indeterminate)
#    GlobalOptions [pscustomobject[]] ordered {Name, Value} pairs between command word and subcommand
#    Operands [string[]], OperandsComplete [bool] (false for xargs origin or any non-literal operand)

Resolve-CommandLineInvocationTarget -CommandText <string> -CommandWord <string> -SubcommandPath <string[]>
# => [pscustomobject] { Status 'NoMatch' | 'Targets' | 'Indeterminate'; Targets [string[]] distinct, ordinal }
#    'Indeterminate' when any match is Indeterminate, any match lacks exactly one literal operand,
#    or any OperandsComplete is false. Never returns 'Targets' with an empty array.

Test-CommandLineWordPresent -RawText <string> -Word <string>
# => [bool] regex (?<![\w-])<escaped word>(?![\w-]), IgnoreCase | CultureInvariant.
```

Consumer obligations:

- **C1b (#732, #738):** iterate `Read-CommandLineInvocationSegment` and `Get-CommandLineInvocation git add|commit`; read `GlobalOptions` entries named `-C` per match and `Delimiter` for `cd` propagation (`&&`, `;`, newline propagate; `|`, `(` run in a subshell). Indeterminate is unresolved and fails closed.
- **C3 (#850):** consume `Resolve-CommandLineInvocationTarget` in both worktree gates; do not re-implement matching.

#### Required configuration keys and defaults:

- No configuration keys. `MaxDepth` default 4. The sink allowlist and terminal-option tables are script-scoped constants in the new or changed modules.
- New frontmatter key in `.claude/agents/pr-author.md`: `hooks.PreToolUse` with `matcher: "Bash"` and `command: pwsh -NoProfile -File .claude/hooks/enforce-pr-author-command-allowlist.ps1`.

#### Backward-compatibility expectations:

- Existing function signatures are preserved; callers compile and run unchanged.
- Intended behavior changes:
  - Wrapper-led and substitution segments no longer classify on substrings.
  - Terminal options are non-matches.
  - Wrapped worktree removals become authorizable (D2).
  - Multi-target removals require every target to be authorized.
  - `--body-file` spellings that normalize to the canonical path are accepted.
  - Chained pr-author commands are evaluated per segment.
- Existing tests that pin R2 substring behavior (`tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1:200-223`, including `:201-206` for wrapper and `xargs git add`) are updated to the new contract: wrapped governed invocations become Structural or Indeterminate matches rather than substring matches. Signature pins near `:324` remain.

#### Performance constraints (latency/throughput/memory):

- The matcher runs inside every Bash PreToolUse invocation of the consuming hooks. `Parser.ParseInput` is invoked only for PowerShell wrapper payloads, and recursion is capped at depth 4. No network, file, or process I/O is added to the matcher. No numeric latency budget is set; a measurable regression observed during execution is reported in the plan evidence.

## Assumptions, Constraints, Dependencies

- **Assumptions.**
  - Hooks run under PowerShell 7+ (`Compatible with PowerShell 7+`, for example `enforce-epic-worktree-removal-gate.ps1:59`); `Parser.ParseInput` and `[System.IO.Path]::GetRelativePath` are available. Windows PowerShell 5.1 is not required.
  - Subagent frontmatter supports `hooks.PreToolUse` scoped to the subagent's lifetime (Claude Code hooks documentation, fetched 2026-10-08, research §6.2). Live firing can be proven only by a live `pr-author` delegation (research Automation Feasibility, qualification 2).
  - `sha256sum` and `date` are available in the pr-author agent environment (#712 recorded `sha256sum` running).
- **Constraints.**
  - 500-line cap per production and test file. Current sizes: `hook-command-invocation.ps1` 483, `hook-command-scanner.ps1` 483, `enforce-parallel-worktree-removal-gate.ps1` 474, `enforce-epic-worktree-removal-gate.ps1` 457, `validate-bash.ps1` 443, `enforce-pr-author-skill-helpers.ps1` 385, `legacy-codex-hook-contracts.Tests.ps1` 497 (research §13).
  - No Python in hooks; no temporary files in tests.
  - Evidence artifacts are written only under `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/<kind>/`.
  - The isolation guard text-denies `pwsh` and `bash` in agent worktrees; executors use the MCP PoshQC tools or the self-hosted module (`Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .`).
- **External dependencies.** None added. `System.Management.Automation.Language.Parser` is part of PowerShell.

## Data / API / Config Impact

- **User-facing or API changes.** The matcher API above. Deny text unchanged except the new `PR_AUTHOR_COMMAND_NOT_ALLOWED:` token and the per-target naming in the worktree gates' existing message format.
- **Data or migration.** None.
- **Logging/telemetry.** None.
- **Compatibility notes.**
  - `pr-author.md` gains a `hooks.PreToolUse` frontmatter entry.
  - Both `pack-manifests/core.json` files gain entries for each new file.
  - Bundled resources change, which requires an extension rebuild for push-down to deliver them (the push-down serves the installed extension payload).

## Test Strategy

- **Framework.** Pester for the Claude and Codex copies. New rows are tagged `Issue824`. No temporary files: the matcher is pure string logic, and the gates are exercised only through their existing read seams (`Get-EpicWorktreeGateCheckpointContent`, `Resolve-*RunTarget`, `Get-PrAuthorReceiptContent`, `Get-PrBodyFileBytes`) (research §11).
- **Regression tests to add or update** (named cases):
  - `R-824-MAIN`: promotion hook allows, on Claude and Codex.
  - `R-824-ADD1`: allowed by the Claude epic gate, the Claude parallel gate, and the Codex epic gate.
  - `R-742-1`: `git --version` allowed by all three worktree gates and not classified as `git add` by the preimplementation gate (both surfaces).
  - `R-733-714`: heredoc commit message not denied by the pr-author skill hook.
  - `R-733-GREP`: read-only grep/sed/Select-String payloads not denied.
  - `R-733-715`: each body-file spelling accepted when it normalizes to the canonical path.
  - `R-733-712`: the chain is denied by the allowlist hook; each sanctioned segment alone is allowed.
- **Gated-invocation rows with negative controls.**
  - Addendum 1: `git worktree remove <path>`, `git worktree remove --force <path>`, `git -C <dir> worktree remove <path>`, `pwsh -Command 'git worktree remove <path>'`, `bash -c "git worktree remove <path>"`. Each is denied without an authorizing checkpoint and allowed with one, on each worktree gate. Multi-target `git worktree remove B && git worktree remove A` denies when only one target is authorized.
  - Promotion: `gh issue create`, `gh issue new`, `pwsh -Command 'gh issue create ...'`, `bash -c "gh issue new ..."`, `/usr/bin/gh issue create`, `gh.exe issue create`, and `gh issue \<LF>create` deny.
  - pr-author: `gh pr create` with no body flag, and with inline `--body`, denies with `PR_AUTHOR_SKILL_BLOCKED`; the wrapped `bash -c "gh pr create --body x"` is still matched.
  - A negative-control row in each consumer suite fails if `Test-CommandLineRawContainment` (substring classification) is restored on the classification path. Example: a payload whose only matches are substrings ("through", "Remove-Item") must remain allowed, and a test-local stub that reinstates substring classification must make that row fail.
- **Prior-run corpus as acceptance rows** (research §7): B1-B5 (`wt-824: remediation-inputs.2026-10-03T10-30.md:33-39`), X1-X10 and Y1-Y5 (`...T13-56.md:44-52`, `:77-82`), W1-W6 (`...T16-55.md:52-59`), and fixtures AC-4, AC-5, AC-6, AC-18, AC-19, AC-21 (`wt-824: spec.md:183-214`). Expected outcomes follow the research §8 fixture table; no row resolves to an allow through an Indeterminate classification or an unreadable operand.
- **Unit tests** for `Read-CommandLineInvocationSegment`, `Get-CommandLineInvocation`, `Resolve-CommandLineInvocationTarget`, `Test-CommandLineWordPresent`, payload extraction for each wrapper and flag spelling, `-EncodedCommand` decode success and failure, PowerShell parse error, depth limit, the inert proof (each sink command and a non-sink command), terminal options, command-word leaf normalization, backslash-newline, and `Delimiter` values.
- **Edge cases and negatives.**
  - `pwsh -c 'Write-Output "gh issue create"'` is allowed (proven inert).
  - `pwsh -c 'Write-Output "$prefix issue create"'` is allowed (presence fails; CR-2).
  - `c=gh; $c issue create` is Indeterminate.
  - `pwsh -c 'iex "gh issue create"'` and `pwsh -c 'Start-Process gh issue create'` are Indeterminate.
  - `xargs git worktree remove` is Indeterminate.
  - Unbalanced quotes and unterminated heredocs are Indeterminate.
  - `--exec-path=<value>` is absorbed, and `--exec-path` alone is terminal.
- **Static tests.**
  - `pr-author.md` frontmatter registers the allowlist hook under `hooks.PreToolUse` with matcher `Bash`.
  - Every Bash command form named in the pr-author procedure (`pr-author.md`, `SKILL.md`) is allowed by the allowlist hook.
- **Parity.**
  - Claude/Codex identity of the shared modules by `Get-FileHash`.
  - Bundled mirror identity.
  - pytest: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_push_down_codex_and_agents_pack_manifest_completeness.py`.
  - jest: `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` and related push-down tests.
  - Pester: `legacy-codex-hook-contracts.Tests.ps1`.
  - `test_bundled_claude_payload_contains_all_repo_runtime_contracts` may fail locally on gitignored state (#510) and is judged in CI.
- **Unchanged-behavior regression.**
  - The existing suites for validate-bash (including the `cd ... && <read>` rows), the preimplementation gate, the merge gate, and epic-base-branch pass on both surfaces where present.
  - Their governed invocations are still detected, including wrapped forms.
- **Fail-before evidence.** Each named regression row is run against the integration-branch base and recorded failing, then recorded passing after the change, under `evidence/regression/`.
- **Error handling verification.** Indeterminate deny text on the worktree gates contains the existing prefix and `TARGET_WORKTREE_NOT_DERIVABLE`; allowlist denies start with `PR_AUTHOR_COMMAND_NOT_ALLOWED:`.
- **Coverage.**
  - Line coverage of at least 85% for every changed or new PowerShell file, with no uncovered changed lines (`.claude/rules/powershell.md:63-65`).
  - The population comes from `config/poshqc-coverage.json:3-9`, so new modules are measured automatically.
  - Branch coverage is not gated for PowerShell.
  - Evidence goes under `evidence/coverage/`.
- **Toolchain.** PowerShell: Invoke-Formatter, PSScriptAnalyzer, and Pester with coverage, repeated until a single clean pass. Python and TypeScript parity tests run through Poetry and npx. Evidence goes under `evidence/qa/`.
- **Manual validation.** A live `pr-author` delegation smoke step confirms that the frontmatter hook fires. This is an orchestration step, not a unit test.

## Acceptance Criteria

- [x] AC-1: The R-824-MAIN reproduction command is allowed by `enforce-promotion-mcp-only.ps1` on both the Claude and Codex copies, proven by a named Pester row in each surface's suite.
- [x] AC-2: `gh issue create` and `gh issue new` remain denied with a reason starting `PROMOTION_MCP_ONLY_BLOCKED:` in each of these forms, on both surfaces: bare, `pwsh -Command '...'`-wrapped, `bash -c "..."`-wrapped, `/usr/bin/gh`, `gh.exe`, and backslash-newline continued. Each row is a Pester case.
- [x] AC-3: The R-824-ADD1 reproduction command is allowed by `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, and `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`, proven by a named Pester row per gate.
- [x] AC-4: Each of `git worktree remove <path>`, `git worktree remove --force <path>`, `git -C <dir> worktree remove <path>`, `pwsh -Command 'git worktree remove <path>'`, and `bash -c "git worktree remove <path>"` is denied by each worktree-removal gate when no authorizing checkpoint exists. The deny reason keeps the gate's existing leading token. Each row is a Pester case.
- [x] AC-5: Each of the five AC-4 invocations is allowed by each worktree-removal gate when an authorizing checkpoint covers `<path>`. This includes the two wrapped forms, which is the accepted behavior change (D2). Each row is a Pester case.
- [x] AC-6: A command carrying more than one removal target is allowed only when every target is authorized. `git worktree remove B && git worktree remove A` with only A authorized, and the W1-W6 corpus rows, deny on each worktree-removal gate, and the deny names the first unauthorized target.
- [x] AC-7: A worktree-removal invocation classified Indeterminate (Unbalanced, parse error, decode failure, depth limit, dynamic position, or not proven inert), or one without exactly one literal operand, is denied by each gate. The reason carries the existing prefix and the `TARGET_WORKTREE_NOT_DERIVABLE` detail. This is the recorded disposition of addendum 1 requirement 2: a false-positive class no longer classifies, and a genuine removal with no derivable target stays fail-closed.
- [x] AC-8: `git --version` is allowed by all three worktree-removal gates and is not classified as `git add` or `git commit` by `enforce-orchestration-preimplementation-gate.ps1` on either surface. Unit rows cover the remaining git and gh terminal options and the `--exec-path=<value>` correction.
- [x] AC-9: The inert proof accepts exactly the sink allowlist `Write-Output`, `Write-Host`, `Write-Verbose`, `Write-Information`, `echo`, `printf`, `Select-String`, `grep`, `rg`. `pwsh -c 'Write-Output "gh issue create"'` and `pwsh -c 'Write-Output "$prefix issue create"'` are allowed by the promotion hook. `pwsh -c 'iex "gh issue create"'`, `pwsh -c 'Start-Process gh issue create'`, and `c=gh; $c issue create` are denied. Each row is a Pester case.
- [x] AC-10: An Unbalanced segment that contains the governed words as whole tokens is denied by the promotion hook, each worktree-removal gate, and the pr-author allowlist hook (fail-closed preserved).
- [x] AC-11: The prior-run corpus rows whose command text is recorded in the prior run (B1-B5; X1, X2, X3, X4, X7, X8, X10; Y1, Y2, Y3, Y5; W1-W6) and fixtures AC-4, AC-5, AC-6, AC-18, AC-19, AC-21 (research §7) exist as Pester rows tagged `Issue824` and resolve as specified in the research §8 fixture table. None resolves to an allow through an Indeterminate classification or an unreadable operand. An evidence artifact records the search for X5, X6, X9, and Y4: the command `git grep -n -E "\b(X5|X6|X9|Y4)\b" bug/promotion-hook-raw-containment-false-positive-deny-824 -- docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824` and its result.
  - Note (2026-10-08, orchestrator decision D10, plan revision round 1): X5, X6, X9, and Y4 have no recorded command text in the prior run, so no Pester row can reproduce them. The criterion therefore requires rows for the recorded IDs and an auditable search record for the four unrecorded IDs. The AC ID is unchanged.
- [x] AC-12: `Read-CommandLineInvocationSegment`, `Get-CommandLineInvocation`, `Resolve-CommandLineInvocationTarget`, and `Test-CommandLineWordPresent` exist on both surfaces with the parameters and return shapes defined in "Inputs/outputs and formats". Unit tests assert each documented property. `Resolve-CommandLineInvocationTarget` never returns `Targets` with an empty array.
- [x] AC-13: The existing signatures of `Test-CommandLineInvocation`, `Resolve-CommandLineInvocation` (plus the new `Status` property), `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag`, and `Test-CommandLineMention` are unchanged, as pinned by the existing signature tests. `Test-CommandLineMention` uses token-bounded presence.
- [x] AC-14: A negative-control Pester row in the promotion, worktree-gate, and pr-author skill suites fails when substring classification (`Test-CommandLineRawContainment`) is reinstated on the classification path, and passes on the delivered code. No production consumer path calls `Test-CommandLineRawContainment`.
- [x] AC-15: The R-733-714 heredoc commit-message fixture and the R-733-GREP read-only grep, sed, and Select-String fixtures are not denied by `enforce-pr-author-skill.ps1`.
- [x] AC-16: These `--body-file` spellings pass check 1 and proceed to the context and receipt checks: `"artifacts/pr_body_5.md"`, `--body-file=artifacts/pr_body_5.md`, `./artifacts/pr_body_5.md`, `artifacts\pr_body_5.md`, and an absolute path under the session root. A path in another directory, a different file name, an absolute path outside the session root, and a canonical-looking path that appears only in a different segment are still denied with `PR_BODY_PATH_NONCANONICAL:`. The session root is obtained through a single helper.
- [x] AC-17: `gh pr create` with no body flag, and `gh pr create` or `gh pr edit` with inline `--body`, are still denied with `PR_AUTHOR_SKILL_BLOCKED:`, including the `bash -c "..."`-wrapped form. Changes in `enforce-pr-author-skill.ps1` and `enforce-pr-author-skill-helpers.ps1` are limited to matching and body-file path normalization.
- [x] AC-18: New `.claude/hooks/enforce-pr-author-command-allowlist.ps1` evaluates every segment at every depth. It allows a command only when each segment is one of the allowed invocations listed in design item 12. It denies, with a reason starting `PR_AUTHOR_COMMAND_NOT_ALLOWED:`, the R-733-712 chain, any non-allowed segment, `git -C <dir> log`, `sha256sum` with any other operand or option, `date` without `-u` or with a non-`+` argument, and any redirection, wrapper-led, substitution, Unbalanced, or Indeterminate segment.
- [x] AC-19: `sha256sum artifacts/pr_body_<N>.md` and `date -u +%Y-%m-%dT%H:%M:%SZ`, each issued as a single command, are allowed by the allowlist hook. `pr-author.md` and `.claude/skills/pr-author/SKILL.md` name them as the receipt procedure. A static test confirms that every Bash command form named in that procedure is allowed by the hook.
- [ ] AC-20: `.claude/agents/pr-author.md` frontmatter registers the allowlist hook under `hooks.PreToolUse` with matcher `Bash`, and the existing `SubagentStop` entry is unchanged. A static Pester test asserts the registration. A live `pr-author` delegation smoke result is recorded under `evidence/`.
- [ ] AC-21: The #742 PR comment records that items 2 (worktree isolation guard) and 3 (evidence-filename Write guard containing "report") are runtime-owned with no repository code change, and that item 4 (`validate-bash.ps1` `cd ... && <read>` rule) is intentional and unchanged. The existing validate-bash `cd`-chain tests pass unmodified.
- [x] AC-22: The existing suites for `validate-bash.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1`, and `enforce-pr-author-skill.epic-base-branch.ps1` pass on every surface where they exist, and each still detects its governed invocations in bare and wrapped forms.
- [x] AC-23: Every changed shared module (`hook-command-invocation.ps1`, `hook-command-payload.ps1`, `hook-command-invocation-operands.ps1`, and `hook-command-scanner.ps1` / `hook-command-heredoc.ps1` if changed or created) is byte-identical between `.claude/hooks/` and `.codex/hooks/`, verified by `Get-FileHash` with evidence recorded. Every changed hook, agent, and skill file is byte-identical to its bundled mirror under `extensions/drm-copilot/resources/`.
- [ ] AC-24: Each new file is listed in the applicable `pack-manifests/core.json` (Claude, and Codex for shared modules) and in `SharedModuleNames` of `legacy-codex-hook-contracts.Tests.ps1`. The pytest, jest, and Pester parity and manifest-completeness tests named in Test Strategy pass in CI.
- [x] AC-25: Deny reasons keep their existing leading tokens (`PROMOTION_MCP_ONLY_BLOCKED:`, `EPIC_WORKTREE_REMOVAL_BLOCKED:`, `PARALLEL_WORKTREE_REMOVAL_BLOCKED:`, `PR_AUTHOR_SKILL_BLOCKED:`, `PR_BODY_PATH_NONCANONICAL:`), asserted by Pester rows. The only new token is `PR_AUTHOR_COMMAND_NOT_ALLOWED:`.
- [x] AC-26: No changed or new hook file invokes Python, verified by the existing no-Python guard and a search of the changed files.
- [x] AC-27: No changed or new production or test file exceeds 500 lines, verified by a line count recorded in evidence.
- [x] AC-28: Every changed or new PowerShell file has line coverage of at least 85%, with no uncovered changed lines. The coverage report is recorded under `evidence/coverage/`.
- [x] AC-29: The PowerShell toolchain (format, lint, Pester with coverage) completes in a single clean pass. Evidence is recorded under `evidence/qa/`. No test creates temporary files.
- [x] AC-30: Each named regression row (R-824-MAIN, R-824-ADD1, R-742-1, R-733-714, R-733-GREP, R-733-715, R-733-712) is recorded failing against the integration-branch base and passing after the change. Evidence is recorded under `evidence/regression/`.
- [x] AC-31: No file or behavior belonging to #824 addendum 2 (FU-823-1, FU-823-2, FU-823-3, FU-823-5, #823 review notes A and B) is changed by this feature, verified by a review of the PR diff against that list.

## Risks & Mitigations

- **Risk: bypass spellings missed by the new matcher.** The prior run needed three review passes because each pass found more spellings.
  - Mitigation: structural parsing replaces the spelling list.
  - Mitigation: the closed Indeterminate fallback catches whole-token presence that has not been proven inert.
  - Mitigation: the full B/X/Y/W corpus runs as acceptance rows.
- **Risk: the inert proof is too narrow and some legitimate wrapped commands are still denied.** This is accepted as the fail-closed residual (D3). Extending the sink list is a later, separate decision.
- **Risk: the wrapped-removal behavior change (D2) authorizes removals that were previously always denied.** Mitigation: authorization uses the same checkpoint cascade, and every target must be authorized.
- **Risk: the 500-line cap on the shared module and the scanner.** Mitigation: the module split defined above, with the heredoc helpers moved out if needed.
- **Risk: the frontmatter hook does not fire at runtime.** Mitigation: a static registration test plus a live delegation smoke step (AC-20). If the hook does not fire, the gap is recorded and registration is revisited with the operator.
- **Risk: collision with C3 (#850) edits to the pr-author hook and worktree gates.** Mitigation: the allowlist lives in a new file, changes to the pr-author skill hook are limited to matching, and the session root sits behind a single helper.
- **Risk: a local parity failure on gitignored state (#510).** Mitigation: judge that test in CI.
- **Rollback.** Revert the PR. The shared module, its copies, and its mirrors revert together.

## Rollout & Follow-up

- **Release and rollout.**
  1. Merge into `epic/enforcement-hook-precision-integration`.
  2. The epic integration PR carries the change to `main`.
  3. Bundled resources ship with the next extension build; push-down delivers them after rebuild and reinstall.
- **Post-fix tasks.**
  - Post the #742 PR comment (AC-21).
  - Optional human actions: file an upstream report for #742 items 2 and 3, and decide whether to re-measure the item 4 engine prompt under `bypassPermissions`.
  - C1b (#732) and C3 (#850) consume the matcher API.
  - Back-fill the epic manifest `feature_folder` basename at fan-in (`epic.md:49-51`).
- **Links.**
  - Issues: #824, #742, #733.
  - Epic: #852 (`docs/features/epics/enforcement-hook-precision/epic.md`).
  - Research: `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/research/research.2026-10-08T14-00.md`.
  - Prior art: `wt-824` head dc0d8d4c.
