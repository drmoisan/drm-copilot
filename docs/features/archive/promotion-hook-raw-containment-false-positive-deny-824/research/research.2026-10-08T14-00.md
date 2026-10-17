# Research: Command-Invocation Matching (Epic #852 child C1a; #824, #742, #733)

- Timestamp: 2026-10-08T14-00
- Issue: #824 (primary); bundled #742, #733
- Branch: `bug/promotion-hook-raw-containment-false-positive-deny-824-r2` (off `origin/epic/enforcement-hook-precision-integration`)
- Mode: preparation, research only
- Scope exclusion: #824 addendum 2 (FU-823-1/2/3/5, review notes A/B) is out of scope.
- Line references are to the current workspace tree unless prefixed with `wt-824:` (the read-only prior-art checkout at `C:\Users\DanMoisan\repos\drm-copilot-wt-824`, head dc0d8d4c).

## 1. Summary of Findings

1. The defect is in one place. `Resolve-CommandLineInvocation` (`.claude/hooks/hook-command-invocation.ps1:166-238`) classifies any wrapper-led or live-substitution segment through `Test-CommandLineRawContainment` (`:92-117`, called at `:202-205`). That check is an ordinal, case-insensitive substring test with no word boundaries. Every caller of `Test-CommandLineInvocation`, `Resolve-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, and `Test-CommandLineFlag` inherits it. Claude has 8 consumer hook files and 22 call sites; Codex has 5 files and 12 call sites (Section 12).
2. #742 item 1 (`git --version` denied) has a second, independent cause. `Skip-CommandLineOption` (`:119-164`) treats `--version` as an unmodeled option, and an unmodeled option between the command word and the subcommand classifies as a match (`:220-223`). Both worktree-removal gates are affected, not only the parallel gate.
3. #742 items 2 and 3 do not come from a repository-owned hook. The isolation guard's message text and a filename rule containing "report" have no match in `.claude/`, `.codex/`, `scripts/`, or the bundled resources. The user-level PreToolUse hook is a telemetry relay that always emits `{}`. #742 item 4 does come from a repository hook: `validate-bash.ps1:222-323,340-343` produces it by design.
4. The `pr-author` `Bash(git log *)` entry does not form a command boundary. The repository runs in `defaultPermissionMode: bypassPermissions` (`.claude/settings.json:292`), and per the Claude Code subagent documentation a subagent runs in the parent's bypass mode. A repository PreToolUse hook that evaluates each segment is the only enforceable boundary.
5. The prior #824 run went through three review passes, and each pass found more bypass spellings in its raw-text regex grammar (B1-B5, X1-X10, Y1-Y5, W1-W6). Two parts of that run can be reused: its token-bounded word test and its fixture corpus. Its sequence and absorption grammar, and its first-segment-only operand reader, should not be carried forward.
6. Recommended design: parse wrapper payloads and substitution bodies, then match the governed invocation structurally inside them. Use a closed fallback: a segment is "Indeterminate" when it is unbalanced, or when the governed words are present as whole tokens and the payload is not proven inert. The worktree gates should then authorize every matched invocation, not only the first.

## 2. Current State (Question 1)

### 2.1 `hook-command-invocation.ps1` structure

- Size: 483 lines on both surfaces (`.claude/hooks/hook-command-invocation.ps1:483`, `.codex/hooks/hook-command-invocation.ps1:483`). That leaves 17 lines under the 500-line cap. `hook-command-scanner.ps1` is also 483 lines (`.claude/hooks/hook-command-scanner.ps1:483`).
- The file dot-sources `hook-command-scanner.ps1` (`:17`). Its tables are:
  - `CommandLineTransparentWrapperNames` = command, env, nohup, time, timeout (`:23`).
  - `CommandLineGlobalOptions` for git, gh, and npx (`:32-45`).
  - `CommandLineStandaloneFlagNames` (`:51`).
- Public functions and contracts:

| Function | Lines | Contract |
|---|---|---|
| `Get-CommandLineTransparentWrapperName` | 53-65 | Returns the transparent-wrapper set. |
| `Get-CommandLineGlobalOption` | 67-90 | Returns `{WithArgument, Standalone}` for a command word; an unknown word yields empty arrays. |
| `Test-CommandLineRawContainment` | 92-117 | Ordinal substring containment of the command word and each subcommand element. The docblock states "a false positive only forces a checkpoint check" (`:98-99`). That is false for the promotion hook. |
| `Skip-CommandLineOption` | 119-164 | Absorbs modeled options. A dash-leading token that is not modeled returns `Unmodeled = $true`. |
| `Resolve-CommandLineInvocation` | 166-238 | Applies four rules per segment, in order. R1: Unbalanced classifies (`:198-200`). R2: wrapper-led or live substitution plus raw containment classifies (`:202-205`). R3: an unmodeled option classifies (`:220-223`). R4: structural match. Returns `{Segment, OperandIndex}` for the **first** matching segment only, or `$null`. `OperandIndex = -1` for R1, R2, and R3. |
| `Test-CommandLineInvocation` | 240-269 | `$null -ne Resolve-...`. |
| `Get-CommandLineOperand` | 271-358 | Operands from the first matched segment. Empty when `OperandIndex -lt 0`. |
| `Get-CommandLineFlagValue` | 360-420 | Flag value from the first matched segment's tokens, or `$null`. |
| `Test-CommandLineFlag` | 422-455 | Presence of a flag in the first matched segment. |
| `Test-CommandLineMention` | 457-483 | Informational only; calls raw containment (`:482`). No hook calls it (Section 12). |

- Segmentation (`hook-command-scanner.ps1:303-483`):
  - The delimiters are `; & | newline ( ) { } $( backtick`, recognized outside quotes and heredoc bodies (`:31`, `:434-466`).
  - Wrapper-led means the command word is one of sh, bash, zsh, dash, ksh, pwsh, powershell, xargs, env, command, eval, nohup, time, timeout (`:21-24`, `:145-148`).
  - `HasLiveSubstitution` is set only by `$(` or a backtick inside double quotes (`:382`).
  - `Unbalanced` means an open quote, an unterminated heredoc, or a non-literal heredoc delimiter (`:428`, `:447`, `:475`).
  - A balanced quoted span becomes one token (`:49-97`), so a wrapper's `-c '<payload>'` argument is a single token and cannot be matched structurally.
- Pre-existing structural gaps, recorded for the design:
  - A backslash-newline continuation produces a `\` token, so `gh issue \<LF>create` does not match structurally (`ConvertTo-CommandLineToken`, `:83-93`).
  - The command word is compared literally (`:215`), so `/usr/bin/git` and `gh.exe` do not match.
  - Only the first matching segment is read, so in `git worktree remove B && git worktree remove A` the second removal is never inspected.

### 2.2 Callers that reach the raw-containment fallback

Every call below goes through `Resolve-CommandLineInvocation` and therefore through R2 for wrapper-led and substitution segments. The outcome column records what each hook does when the fallback classifies.

| Hook (surface) | Call sites | Outcome on an R2 classification |
|---|---|---|
| `enforce-promotion-mcp-only.ps1` (Claude `:126-127`, Codex `:123-124`) | `gh issue create`, `gh issue new` | **Unconditional deny**, `PROMOTION_MCP_ONLY_BLOCKED` (`:128`). There is no checkpoint. |
| `enforce-epic-worktree-removal-gate.ps1` (Claude `:140,141,355`; Codex `:58,59,126`) | `git worktree remove` | Operand empty, so the path is `$null` (or `--force`), so the deny reads `EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE` (Claude `:398-403`; Codex `:136-153`). The deny is effectively unconditional: a checkpoint cannot authorize an empty path. |
| `enforce-parallel-worktree-removal-gate.ps1` (Claude only, `:201,202,361`) | `git worktree remove` | Same as the epic gate, with the `PARALLEL_WORKTREE_REMOVAL_BLOCKED` prefix (`:415-420`). |
| `enforce-pr-author-skill-helpers.ps1` (Claude `:279,280,290,291`) | `gh pr create`, `gh pr edit` | Flags read absent, then the raw `IndexOf('--body*')` scan runs (`:299-311`). With no body text, Case B returns `PR_AUTHOR_SKILL_BLOCKED` (`:319-323`), an unconditional deny. With `--body-file` text, the context, preflight, and receipt checks run. |
| `enforce-pr-author-skill.epic-base-branch.ps1` (Claude `:92,100,138`) | `gh pr create` | Checkpoint-routed. Denies only under `epic_mode` when `--base` is absent or mismatched. |
| `enforce-epic-merge-gate.ps1` (Claude `:128,134,342,343`; Codex `:63,69,141,142`) | `gh pr merge` | Checkpoint and merge-authorization routed. |
| `enforce-orchestration-preimplementation-gate.ps1` (Claude `:142`; Codex `:161`) | `git add`, `git commit` | Routes to the preimplementation checkpoint check (`Test-ImplementationCommand`, `:124-159`). |
| `validate-bash.ps1` (Claude `:123,127`; Codex `:96,100`) | `git push`, `git reset` | Effectively no deny from R2 alone. The structural leg also requires a `--force`, `-f`, or `--hard` token (`:124-128`), which a collapsed wrapper token does not supply. Leg 1's raw `IndexOf` covers wrapper literals (`:197-199`). |
| `enforce-parallel-abandon-gate.ps1` (Claude) | none | Dot-sources the module (`:52`) but calls only scanner functions (`:144,183,218,226`), so it does not reach R2. |

No caller exists under `scripts/` or `.claude/lib`. The bundled mirrors under `extensions/drm-copilot/resources/{claude-customizations,codex-and-agents-customizations}` repeat the same dot-source lines.

## 3. #824 Main Defect (Question 2)

Call path: `Invoke-PromotionMcpOnlyDecision` (`enforce-promotion-mcp-only.ps1:213-250`) calls `Get-PromotionBypassReason` (`:73-144`), which makes three checks in order:

1. A forbidden-token `IndexOf` on each segment's ScanText (`:106-112`).
2. The adjacency regex `\bgh\s+issue\s+(?:create|new)\b` on ScanText (`:116-120`).
3. `Test-CommandLineInvocation` for both subcommand paths (`:126-129`).

The `gh api ... POST` pattern follows (`:136-141`).

Reproduction trace for `pwsh -NoProfile -Command '$parts = New-Object ...; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'`:

- The payload is one single-quoted span, so the scanner yields one segment with CommandWord `pwsh` and `IsWrapperLed = $true`.
- Check 2 does not match: `\b` fails before the `gh` inside "through".
- Check 3 reaches R2. `IndexOf('gh')` matches "through", `IndexOf('issue')` matches "(issue #1)", and `IndexOf('new')` matches "New-Object". The result is a deny with `Get-PromotionMcpOnlyGhIssueBlockedReason` (`:43`).

This was established by tracing the code. The code was not run in this research step.

## 4. #824 Addendum 1 and #742 Item 1: Worktree-Removal Gates (Question 3)

Call path (Claude epic gate):

1. `Invoke-EpicWorktreeRemovalGateDecision` (`:318-404`) applies the scope filter `Test-CommandLineInvocation git worktree remove` (`:355`).
2. `Get-EpicWorktreeRemovalCommandPath` (`:111-150`) is `Test-CommandLineFlag --force` plus `Get-CommandLineOperand`. It returns the first operand, or `'--force'`, or `$null`.
3. `Read-EpicWorktreeGateRunCheckpoint` (`enforce-epic-worktree-removal-gate-resolution.ps1:115-144`) resolves the run target from the path via `Resolve-WorktreeRunTargetByRecord` (`:112`). It runs once per checkpoint kind.

The parallel gate follows the same path: `Invoke-ParallelWorktreeRemovalGateDecision` (`:323-421`), `Get-ParallelWorktreeRemovalCommandPath` (`:168-211`, whose body its docblock states is identical, `:185-188`), and then `Read-ParallelWorktreeGateRunCheckpoint`. The Codex path is `Invoke-CodexWorktreeRemovalDecision` (`.codex/hooks/enforce-epic-worktree-removal-gate.ps1:110-154`) with `Get-CodexWorktreeRemovalPath` (`:36-68`), which returns `''` on a miss.

**Empty-operand deny signature.** Under R1, R2, or R3, `OperandIndex = -1`, so `Get-CommandLineOperand` returns `@()` (`:310-312`). Without `--force` the path is `$null`, the run-target resolver returns `NoTarget` (code `TARGET_WORKTREE_NOT_DERIVABLE`, `.claude/lib/worktree-resolution/WorktreeResolution.psm1:59`), and the gate emits `<PREFIX>: TARGET_WORKTREE_NOT_DERIVABLE: ... <PREFIX>: git worktree remove for '' requires ...` (epic `:399-403`, parallel `:416-420`).

**Addendum 1 reproduction.** `pwsh -NoProfile -Command 'Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; ... Remove-Item ...; git status --porcelain -- "src/Old.cs"'` classifies under R2 because of the substrings `git`, `worktree` (in "worktrees"), and `remove` (in "Remove-Item"). That produces the signature above.

**#742 item 1, `git --version`.** The tokens are `git`, `--version`. `Skip-CommandLineOption` finds `--version` in neither modeled list and returns `Unmodeled` (`:160`). R3 then classifies (`:221-223`), and the empty-operand deny follows. The epic gate is affected identically; #742 names only the parallel gate. The same R3 path also classifies `git --version` as `git add` for the preimplementation gate (`:142`).

**Invocations that must stay gated** (addendum 1):

1. `git worktree remove <path>`
2. `git worktree remove --force <path>`
3. `git -C <dir> worktree remove <path>`
4. `pwsh -Command 'git worktree remove <path>'`
5. `bash -c "git worktree remove <path>"`

Items 1-3 match structurally today, and their operand is read. Items 4 and 5 match only through R2 today, so their operand is never read and they are denied **even when a checkpoint authorizes the path**. The addendum's phrase "allowed with one [checkpoint]" does not describe current behavior for items 4 and 5. Under the recommended design those two become authorizable, which is a behavior change. The spec should state it as an intended change rather than as preservation.

## 5. #742 Items 2-4 (Question 4)

### 5.1 Item 2: worktree isolation guard

- A content search for the guard's message fragments ("shown not to run", "construct too complex", "plain command") across all non-`docs/` paths returns no match.
- The project `.claude/settings.json` registers eight Bash PreToolUse hooks (`:89-126`), and none of them is an isolation guard.
- The user-level `~/.claude/settings.json` PreToolUse hook (`:125-136`) is an Orca relay. `~/.orca/agent-hooks/claude-hook.cmd:3-11` echoes `{}` and posts telemetry. It never emits a deny.
- Prior repository evidence reaches the same conclusion: `docs/features/completed/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-environment-facts.2026-09-07T10-57.md:105-107` ("a runtime control, not a repository hook — a repository-wide content search for its message text returns zero matches").
- **Conclusion (verified by search): the guard is a Claude Code runtime control for agent-isolated worktrees.** No repository change can make it allow `git -C <own-worktree>`, `sh`-piped output, or the argument `hash`.
- Tokenized design, recorded for an upstream report only: for each segment, resolve the effective git directory from every `-C`, `--git-dir`, and `--work-tree` value and from any `cd` operand. Refuse only when that directory lies outside the isolated worktree root. Match the words `bash`, `pwsh`, and `wsl` only as a command word or wrapper, never as a substring or argument.
- **Recommended disposition:** the plan records item 2 as not repository-owned. The spec replaces the #742 acceptance condition for item 2 with that disposition. The established workarounds (`sh file.sh`, `npx --yes ...`, the MCP PoshQC tools) are documented in the plan. An upstream report is optional and is a human action.

### 5.2 Item 3: evidence-filename Write guard ("report")

- No repository Write or Edit hook contains a filename rule for "report". A search over `.claude/hooks`, `.claude/lib`, and `.codex/hooks` returns only comments and the bash `report-lane-assertion.sh` name.
- `enforce-evidence-locations.ps1` matches only directory prefixes (`:65-80`).
- The likely source is the runtime instruction given to subagents, which tells them not to write "report/summary/findings/analysis .md files". That instruction is present in this session's own system context. Whether the runtime also enforces it as a hard tool block is **unverified**.
- **Recommended disposition:** not repository-owned. Same spec treatment as item 2.

### 5.3 Item 4: `cd ... && <read>`

- **Repository-owned.**
  - `validate-bash.ps1` defines `CdChainedReadCommandPattern` (`:222`) and `Get-CdChainedReadCommandMatch` (`:230-323`).
  - The deny text "Forbidden Bash pattern: 'cd ... && <cmd>' ..." (`:340-343`) describes the permission engine, which is why it was taken for an engine refusal.
  - The block is deliberate. Its rationale is a measured engine prompt (`:214-221`).
- **Recommended disposition:** no behavior change in C1a. Record in the plan that the deny originates in `validate-bash.ps1` and is intentional. Open a follow-up only if the operator wants to re-measure whether the engine still prompts under `bypassPermissions`.

## 6. #733: pr-author (Question 5)

### 6.1 Hook matching

- **Commit-message false positive (#714).** The common commit form `git commit -m "$(cat <<'EOF' ... EOF\n)"` sets `HasLiveSubstitution`. The scanner does not process a heredoc inside double quotes, so R2 runs raw containment over the whole commit body. Substrings such as "gh" (in "through"), "pr" (in "process"), and "create" (in "created") then classify the segment as `gh pr create`. Case B denies with `PR_AUTHOR_SKILL_BLOCKED` (`enforce-pr-author-skill-helpers.ps1:319-323`). This mechanism is inferred from code. The exact #714 command is not recorded in the repository.
- **Read-only grep/sed false positive (2026-09-29 comment).** Same mechanism for any wrapper-led or substitution segment. Prior-run fixture AC-18 (`wt-824: spec.md:211`): `pwsh -NoProfile -Command 'Select-String ... "high priority" | ForEach-Object { "create" }'`, where "high" supplies gh, "priority" supplies pr, and the literal "create" completes the match.
- **`PR_BODY_PATH_NONCANONICAL` (#715).** Check 1 is a raw-text regex: `$CommandText -cnotmatch '--body-file\s+artifacts/pr_body_(\d+)\.md\b'` (`:171`). It rejects `--body-file "artifacts/pr_body_5.md"`, `--body-file=artifacts/...`, and absolute paths. It also accepts the pattern when it appears anywhere in the text, for example inside a chained segment.
- **C1a change, matching only.**
  - Gate both helpers on the new matcher.
  - Read `--body-file` through `Get-CommandLineFlagValue` (quotes already stripped; both `--flag value` and `--flag=value` forms).
  - Normalize the value: backslashes to `/`, strip a leading `./`, and convert a rooted path to a path relative to the session root via `[System.IO.Path]::GetRelativePath`. Then require the result to `-cmatch` `^artifacts/pr_body_(\d+)\.md$`.
  - Restrict the raw `--body*` fallback (`:299-311`) to Indeterminate matches.
  - C3 (#850) later replaces the session root with the resolved item worktree. Keep the root behind one helper so C3 changes one line.

### 6.2 Allowlist chaining boundary

- `pr-author.md:8-14` declares `Bash(git log *)`, `Bash(git rev-parse *)`, `Bash(gh pr create *)`, and `Bash(gh pr edit *)`. Permission rules are enforced by the Claude Code permission engine. This repository sets `defaultPermissionMode: bypassPermissions` (`.claude/settings.json:292`).
- The Claude Code subagent documentation (code.claude.com/docs/en/sub-agents, fetched 2026-10-08) says: "When the main conversation is in `bypassPermissions` ... the subagent runs in that same mode and Claude Code ignores the `permissionMode` you set." The per-command specifiers therefore do not restrict this agent.
- That Bash specifiers in an agent `tools:` list are inert is consistent with the user memory note `claude-permission-rule-matcher-semantics` (measured for Write and Edit on 2.1.246). It was not measured for Bash.
- A repository PreToolUse hook can evaluate chained segments. Read-CommandLineSegment already splits on `;`, `&`, `|`, and newline. The hooks documentation (code.claude.com/docs/en/hooks, fetched 2026-10-08) confirms:
  - Subagent frontmatter supports `hooks.PreToolUse`, scoped to that subagent's lifetime.
  - Hook input carries `agent_type` inside a subagent.
- **Recommendation:**
  - Add `.claude/hooks/enforce-pr-author-command-allowlist.ps1`, registered in `pr-author.md` frontmatter under `hooks.PreToolUse` with matcher `Bash`. The existing `SubagentStop` entry at `:15-20` is the precedent for frontmatter hooks.
  - It denies unless **every** segment, at every depth, structurally matches one allowed invocation: `git log`, `git rev-parse`, `gh pr create`, `gh pr edit`, `sha256sum artifacts/pr_body_<N>.md`, or `date -u ...`.
  - It also denies any segment carrying a redirection token, a wrapper, a substitution, or an Unbalanced state.
  - New leading token: `PR_AUTHOR_COMMAND_NOT_ALLOWED:`.
  - The file is new, which leaves `enforce-pr-author-skill.ps1` to C3.
- **Sanctioned receipt tool:**
  - No existing script writes the receipt. A search of `scripts/`, `.claude/lib`, `.claude/skills`, and the extension `src/` for receipt or SHA-256 helpers found only the hook's own inline SHA-256 (`enforce-pr-author-skill-helpers.ps1:208-214`).
  - Recommendation: allow two narrow single-segment forms in the new hook, `sha256sum artifacts/pr_body_<N>.md` and `date -u +%Y-%m-%dT%H:%M:%SZ`. Update `pr-author.md:46-65` and `.claude/skills/pr-author/SKILL.md:47-71` to name them.
  - #712 recorded `sha256sum` running in this environment.
  - Rejected: a `pwsh` receipt script (the isolation guard text-denies `pwsh` in agent worktrees, Section 5.1) and a new MCP tool (TypeScript and extension surface beyond C1a).
- Codex has no pr-author hook. `.codex/hooks/` contains no `enforce-pr-author-skill.ps1`. #733 is Claude-only.

## 7. Prior-Art Assessment (wt-824)

**Reusable:**

- The token-bounded word test `(?<![\w-])word(?![\w-])` with `IgnoreCase, CultureInvariant` (`wt-824: .claude/hooks/hook-command-raw-invocation.ps1:88-111`). Use it as the presence predicate.
- The review fixture corpus as acceptance rows:
  - B1-B5 (`wt-824: remediation-inputs.2026-10-03T10-30.md:33-39`).
  - X1-X10 (`...T13-56.md:44-52`).
  - Y1-Y5 (`...T13-56.md:77-82`).
  - W1-W6 (`...T16-55.md:52-59`).
  - AC-4, AC-5, AC-6, AC-18, AC-19, and AC-21 fixtures (`wt-824: spec.md:183-214`).
- The rule set by every review pass: no Indeterminate classification and no unreadable operand routes to an allow (`...T16-55.md:117`).
- The operand-status vocabulary `NoMatch`, `Operand`, `NoOperand`, `Indeterminate`.

**Not reusable:**

- The raw-text sequence and absorption regex grammar (`Get-CommandLineRawInvocationPattern`, `Get-CommandLineRawInvocationMatch`, `:36-160`). Each review pass found more spellings it missed. Reviewer advisory A1 (`...T13-56.md:127`) called it "a list of recognized spellings".
- `Get-CommandLineRawInvocationOperand` (`:198-263`), which reads operands from raw text and drops matches whose token is empty (W1-W4).
- `Resolve-CommandLineWrappedInvocationOperand` (`:265-300`), which reads the first classifying segment only (W5, W6).

**Review findings the new plan must address in advance:**

- R1/T10-30 (bypass forms B1-B5): an expansion, splat, or line continuation that stands in for a subcommand position.
- R1/T13-56 (X rows): an operand that follows a redirection, a `(`, or is supplied by `xargs` must be Indeterminate. It must never be NoOperand-then-allow.
- R2/T13-56 (Y rows): positional parameters (`"$@"`, `$*`, `$1`) and `xargs`-led command words.
- R1/T16-55 (W rows): authorize every matched invocation. A single literal operand must not authorize a command that carries a second removal, whether it is wrapped, in another segment, or in a second wrapper.
- CR-2/T10-30: an expansion in the command position must not classify when the command word is absent everywhere (`pwsh -c 'Write-Output "$prefix issue create"'` must stay allowed).

**Out-of-scope content on that branch, not to be carried:** `.codex/codex-web-setup.sh`, `KcovFunctionCoverageGate`, `_shell-coverage.yml`, the TaskMaster neutralization, and the `validate-feature-review-coverage` thresholds (addendum 2).

## 8. Candidate Approaches and Recommendation

**Recommended: parse payloads structurally, with a closed fallback.**

1. Pre-normalization. Replace backslash-newline (POSIX) with a space before segmenting. For PowerShell dialect, rely on the PowerShell parser instead.
2. Command word normalization. Use the leaf after the last `/` or `\` and strip a trailing `.exe`, case-insensitively, at every depth.
3. Terminal options. Add a modeled `Terminal` list per command word: git `--version`, `-v`, `--help`, `-h`, `--html-path`, `--man-path`, `--info-path`, and `--exec-path` without `=`; gh `--version`, `--help`. A terminal option ends the segment as a resolved non-match.
   - This closes #742 item 1 without weakening detection. Per git's documented handling, `git --version ...` and `git --help ...` dispatch to the `version` and `help` commands.
   - It also corrects the `--exec-path` modeling. It is currently `WithArgument` (`:34`), but git accepts its value only in `=` form.
4. Wrapper payload extraction (new module):
   - POSIX shells (sh, bash, zsh, dash, ksh): the argument after `-c`, plus trailing positional arguments.
   - `pwsh` and `powershell`: the text after `-Command`, `-c`, `-CommandWithArgs`, or `-cwa`. `-EncodedCommand`, `-e`, and `-ec` are base64 UTF-16LE: decode and recurse, and treat a decode failure as Indeterminate.
   - `eval`: the arguments joined.
   - `xargs`: the remaining tokens as a command whose operands are incomplete.
   - Script-file forms (`bash x.sh`, `pwsh -File x.ps1`) stay uninspected, which is parity with today.
   - Recursion depth limit: 4. Reaching the limit is Indeterminate.
5. Dialect-correct parsing:
   - POSIX payloads are re-segmented with `Read-CommandLineSegment`.
   - PowerShell payloads are parsed with `[System.Management.Automation.Language.Parser]::ParseInput`, which is in-memory, does not execute anything, and is deterministic. All `CommandAst` nodes are visited, including those nested in script blocks and subexpressions. A parse error is treated as Unbalanced.
   - This avoids the scanner's bash-specific handling of the PowerShell backtick escape.
6. Substitution bodies. For a top-level segment with `HasLiveSubstitution`, re-segment the content of each double-quoted span that contains `$(` or a backtick. The scanner already treats `$(`, `)`, and the backtick as delimiters and masks heredoc bodies, so the `git commit -m "$(cat <<'EOF' ... EOF)"` body is masked and inert.
7. Classification for each segment at each depth:
   - **Unbalanced**, parse error, decode failure, or depth limit: Indeterminate.
   - **Structural** match via the existing token walk, extended with points 2 and 3: a Structural match carrying operands, global options, and an `OperandsComplete` flag.
   - Otherwise, for segments inside a wrapper payload or substitution: **Indeterminate** when (a) and (b) both hold.
     - (a) The command word and every subcommand element occur as whole tokens in the root segment's raw text. Use the whole command text when the segment is led by an argument injector (`xargs`).
     - (b) The payload is **not proven inert**. Proven inert means every `CommandAst` or segment is fully literal (no variable, splat, subexpression, `$`, or backtick token), no command name is non-literal, and any string literal or bare argument that contains the command word as a whole token is an argument to a fixed **sink allowlist**: Write-Output, Write-Host, Write-Verbose, Write-Information, echo, printf, Select-String, grep, rg.
     - The allowlist fails closed: a command not in it, such as `iex` or `Start-Process gh issue create`, is not inert.
   - Otherwise: no match.
8. Results. Return **all** matches in source order, not only the first.

How the fixtures resolve under this design:

| Fixture | Expected | Reason |
|---|---|---|
| #824 reproduction, AC-6 | allow | Presence fails: no whole-token `gh`. |
| Addendum 1 reproduction | allow | Presence fails: no whole-token `worktree` or `remove`. |
| B1-B5, Y1, Y2, Y5 | Indeterminate | Dynamic element plus presence. |
| Y3 | Indeterminate | xargs payload with an incomplete path plus presence. |
| `c=gh; $c issue create` | Indeterminate | Non-literal command name plus presence. |
| CR-2 case `Write-Output "$prefix issue create"` | allow | Presence fails. |
| `pwsh -c 'Write-Output "gh issue create"'` | allow | Proven inert. |
| AC-10, AC-11, AC-12; addendum items 4 and 5 | Structural match | Matched inside the payload, with operands. |

**Rejected alternatives:**

- The prior run's raw-text regex sequence grammar. It produced three remediation cycles and remains an open-ended spelling list (Section 7).
- Token-bounded unordered presence as the only rule (prior advisory A1). It still denies inert wrapped mentions, and it yields no operand for wrapped removals, so addendum items 4 and 5 can never be authorized. It is kept as fallback component (a).
- Keeping substring containment but routing promotion matches to a checkpoint check. The promotion hook has no checkpoint to consult, so this would turn the deny into an allow.
- Registering the pr-author allowlist hook globally in `.claude/settings.json`, filtered on `agent_type == 'pr-author'`. It is workable, but it adds a ninth global Bash hook that runs on every command and changes settings registration. The frontmatter registration is narrower.

## 9. Matcher API for Downstream Consumers (Question 8)

Names follow the existing `<Verb>-CommandLine<Noun>` convention. Existing public signatures are preserved, with these behavior changes:

- `Test-CommandLineInvocation` returns true for any match, Structural or Indeterminate.
- `Resolve-CommandLineInvocation` keeps returning `{Segment, OperandIndex}` for the first match, plus a new `Status` property.
- `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, and `Test-CommandLineFlag` read from the first Structural match. Inside a wrapper payload, this means they read the payload segment's tokens.

New functions:

```powershell
# Per-segment iterator over top-level segments, wrapper payloads, and substitution bodies.
Read-CommandLineInvocationSegment -CommandText <string> [-MaxDepth <int> = 4]
# => [pscustomobject[]] in source order, each:
#    Index [int], RootIndex [int], Depth [int],
#    Origin [string]   'TopLevel' | 'WrapperPayload' | 'Substitution' | 'ArgumentInjector'
#    Wrapper [string]  e.g. 'bash','pwsh','xargs','eval' or ''
#    Dialect [string]  'Posix' | 'PowerShell'
#    RawText [string], RootRawText [string], Tokens [string[]], CommandWord [string] (leaf-normalized),
#    Literal [bool]    (no $, backtick, splat, subexpression token)
#    Unbalanced [bool], Opaque [bool], OpaqueReason [string]
#    Delimiter [string] the separator that ended the segment (';','&&','||','|','&',"`n",'(',')','{','}','$(','`','')

# All matches of one governed invocation.
Get-CommandLineInvocation -CommandText <string> -CommandWord <string> -SubcommandPath <string[]>
# => [pscustomobject[]] in source order, each:
#    Status [string]   'Structural' | 'Indeterminate'
#    Reason [string]   '' | 'Unbalanced' | 'Opaque' | 'DynamicPosition' | 'NotProvenInert' | 'DepthLimit'
#    Segment [pscustomobject] (an iterator record), OperandIndex [int] (-1 when Indeterminate)
#    GlobalOptions [pscustomobject[]] ordered {Name, Value} pairs between the command word and the subcommand
#                                     (for example every '-C <dir>' in order; C1b composes them)
#    Operands [string[]], OperandsComplete [bool] (false for xargs/find -exec origin or any non-literal operand)

# Operand set across ALL matches, for gates that authorize per target.
Resolve-CommandLineInvocationTarget -CommandText <string> -CommandWord <string> -SubcommandPath <string[]>
# => [pscustomobject] Status 'NoMatch' | 'Targets' | 'Indeterminate', Targets [string[]] (distinct, ordinal)
#    'Indeterminate' when any match is Indeterminate, any match lacks exactly one literal operand,
#    or OperandsComplete is false. Never returns 'Targets' with an empty array.

# Token-bounded presence (replaces Test-CommandLineRawContainment; used by Test-CommandLineMention).
Test-CommandLineWordPresent -RawText <string> -Word <string>   # => [bool]
```

**Consumer obligations:**

- **C1b (#732, #738).** Iterate `Read-CommandLineInvocationSegment` and `Get-CommandLineInvocation git add|commit`. Read `GlobalOptions` entries named `-C` per match, and `Delimiter` for `cd` propagation: `&&`, `;`, and newline propagate, while `|` and `(` run in a subshell. An Indeterminate match is unresolved and fails closed.
- **C3 (#850).** Consume `Resolve-CommandLineInvocationTarget` in both gates. Do not re-implement matching.
- **Worktree gates (C1a).** `NoMatch` leads to allow (out of scope). `Indeterminate` leads to a deny with the existing prefix and the existing `TARGET_WORKTREE_NOT_DERIVABLE` detail. `Targets` authorizes each target against the checkpoint cascade and allows only when all are authorized; the deny names the first unauthorized target.
  - This replaces `Get-EpicWorktreeRemovalCommandPath`, `Get-ParallelWorktreeRemovalCommandPath`, and `Get-CodexWorktreeRemovalPath`.
  - It closes W1-W6 and the pre-existing structural case `git worktree remove B && git worktree remove A`.
- **Addendum 1 requirement 2.** Under this design the false-positive class no longer classifies. An empty operand on a genuine, classified removal remains a fail-closed deny, consistent with the epic Shared Design ("Fail-closed is the repository norm") and with every prior review ruling. The plan must record this disposition explicitly.

**File placement (500-line cap):**

- `hook-command-invocation.ps1` (483 lines) cannot absorb this design.
- Proposed split:
  - `hook-command-invocation.ps1`: tables (adding `Terminal`), structural walk, `Resolve-`, `Test-`, `Get-CommandLineInvocation`.
  - New `hook-command-invocation-operands.ps1`: operand and flag readers, `Resolve-CommandLineInvocationTarget`.
  - New `hook-command-payload.ps1`: payload extraction, the PowerShell AST adapter, substitution bodies, the inert proof, and `Read-CommandLineInvocationSegment`.
- `Delimiter` requires a scanner change (483 lines). If it does not fit, move `Read-CommandLineHeredocHeader` and `Read-CommandLineHeredocBody` (`:198-301`) to a new `hook-command-heredoc.ps1`.
- Each new file needs a Codex copy, two bundled mirrors, entries in both pack manifests, and a `SharedModuleNames` entry (Section 10).

## 10. Mirrors, Parity, and Manifests (Question 6)

- **Copies of each affected file.**
  - Claude `.claude/hooks/<f>`, bundled at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<f>`.
  - Codex `.codex/hooks/<f>`, bundled at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/<f>`.
  - Codex has copies of `hook-command-invocation.ps1`, `hook-command-scanner.ps1`, `enforce-promotion-mcp-only.ps1`, and `enforce-epic-worktree-removal-gate.ps1`. It has no parallel worktree gate and no pr-author hook (Glob of `.codex/hooks/*.ps1`).
  - `pr-author.md` and `.claude/skills/pr-author/SKILL.md` have bundled copies. `.github/agents/pr-author.agent.md` and `.codex/agents/pr-author*.toml` exist. Confirm in planning whether their text names the receipt procedure.
- **Pack manifests.**
  - `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:55-56` lists the two hook modules.
  - `.../codex-and-agents-customizations/pack-manifests/core.json:45-46` does the same.
  - New modules and the new pr-author hook must be added.
- **Parity tests.**
  - pytest: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_push_down_codex_and_agents_pack_manifest_completeness.py`.
  - Pester: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. Its `SharedModuleNames` is on line 30, and the file is at 497 lines, so the entry must go on the existing line.
  - jest: `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, plus the push-down tests listed by a search for `core.json`.
  - User memory note `bundle-parity-test-fails-on-gitignored-state`: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails locally on gitignored state (#510) and passes in CI.
- **Claude/Codex identity.** No test currently pins Claude/Codex identity of `hook-command-invocation.ps1`; C5b adds such tests. The plan should verify identity by `Get-FileHash`.

## 11. Tests and Coverage (Question 7)

- **Existing suites, Claude** (`tests/scripts/claude-hooks/`):
  - `hook-command-invocation.Tests.ps1`. It pins R2 at `:200-223`, and `:201-206` asserts the wrapper and `xargs git add` classification. Signature pins start near `:324`.
  - `hook-command-scanner.Tests.ps1`
  - `hook-command-parser.AcceptanceCases.Tests.ps1`
  - `enforce-promotion-mcp-only{,.TriggerScoping}.Tests.ps1`
  - `enforce-epic-worktree-removal-gate{,.TriggerScoping,.WorktreeResolution}.Tests.ps1`
  - `enforce-parallel-worktree-removal-gate{,.TriggerScoping,.WorktreeResolution,.EpicAuthorization}.Tests.ps1`
  - `enforce-pr-author-skill{,.TriggerScoping,.Payload,.EpicScope,.OrchestratorStatePreflight,.TargetResolution,.WorktreeResolution,.epic-base-branch,.epic-base-branch.TriggerScoping}.Tests.ps1`
  - `validate-bash{,.TriggerScoping}.Tests.ps1`
  - `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`
  - `enforce-epic-merge-gate.TriggerScoping.Tests.ps1`
- **Existing suites, Codex** (`tests/scripts/codex-hooks/`):
  - `hook-command-invocation.Tests.ps1`, `hook-command-scanner.Tests.ps1`
  - `enforce-promotion-mcp-only-{trigger-scoping,decision-surface}.Tests.ps1`
  - `enforce-epic-worktree-removal-gate-{trigger-scoping,decision-surface}.Tests.ps1`
  - `validate-bash-{trigger-scoping,decision-surface}.Tests.ps1`
  - `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`
  - `enforce-epic-merge-gate-trigger-scoping.Tests.ps1`
  - `legacy-codex-hook-contracts.Tests.ps1`
- **Coverage.**
  - `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27` enables Pester CodeCoverage (CoverageGutters) with no path list.
  - The population comes from `config/poshqc-coverage.json:3-9`, whose roots are `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, and `scripts`. New hook modules are measured automatically.
  - The threshold is line coverage of at least 85% per changed file, with no uncovered changed lines (`.claude/rules/powershell.md:63-65`).
  - Per user memory notes, the MCP PoshQC runner may not honor workspace coverage settings and returns no output text. The prior run used `Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .` (`wt-824: remediation-inputs.2026-10-03T13-56.md:115`).
- **No temporary files.** The matcher is pure string logic. The gates expose read seams such as `Get-EpicWorktreeGateCheckpointContent`, `Resolve-*RunTarget`, `Get-PrAuthorReceiptContent`, and `Get-PrBodyFileBytes`, and the prior run's suites used only those seams (`wt-824: spec.md:165`). The PowerShell parser adapter is in-memory.
- **Test strategy.**
  - Tag new rows `Issue824`.
  - Unit rows for the three new or changed modules on both surfaces.
  - Decision-seam rows for the promotion hook (both surfaces), the three worktree gates, and the pr-author helpers and new allowlist hook.
  - A negative control that fails if `Test-CommandLineRawContainment` is restored on the classification path.
  - The full B, X, Y, and W corpora plus the five addendum invocations, each with and without an authorizing checkpoint.
  - `git --version` allowed by both gates.
  - Fail-before evidence against the integration-branch base.
  - A static test that `pr-author.md` frontmatter registers the allowlist hook.
  - The wiring itself can only be proven in a live session; see Section 13.

## 12. Numeric Derivation Evidence

### Claim N1: hook files that call the matcher API (Claude 8, Codex 5)

- **Complete Family.** Production `.ps1` files under `.claude/hooks`, `.codex/hooks`, `.claude/lib`, and `scripts` that call any of `Test-CommandLineInvocation`, `Resolve-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag`, `Test-CommandLineMention`, or `Test-CommandLineRawContainment`, excluding the defining module.
- **Exhaustive Search Scope.** Grep with glob `{.claude,.codex,scripts}/**/*.ps1` over the workspace root.
- **Inclusion Rules.** A file containing at least one call to a family member.
- **Exclusion Rules.** The two `hook-command-invocation.ps1` copies (definitions and internal calls), test files, and bundled mirrors, which duplicate the canonical files.
- **Primary Search Strategy.** Regex `Test-CommandLineInvocation|Resolve-CommandLineInvocation|Get-CommandLineOperand|Get-CommandLineFlagValue|Test-CommandLineFlag\b|Test-CommandLineMention|Test-CommandLineRawContainment`.
- **Primary Member Set.**
  - Claude: validate-bash, enforce-promotion-mcp-only, enforce-pr-author-skill.epic-base-branch, enforce-pr-author-skill-helpers, enforce-parallel-worktree-removal-gate, enforce-orchestration-preimplementation-gate, enforce-epic-worktree-removal-gate, enforce-epic-merge-gate.
  - Codex: validate-bash, enforce-promotion-mcp-only, enforce-orchestration-preimplementation-gate, enforce-epic-worktree-removal-gate, enforce-epic-merge-gate.
- **Primary Count.** Claude 8; Codex 5.
- **Cross-check Strategy.** Two steps.
  - (i) Regex `hook-command-invocation\.ps1` to list every dot-sourcing file. This gives Claude 9 and Codex 5.
  - (ii) For each dot-sourcing file not already confirmed, Grep `CommandLine`. `enforce-parallel-abandon-gate.ps1` shows only `Test-CommandLineSegmentRawScan` and `Read-CommandLineSegment` (`:144,183,218,226`), so it is excluded.
- **Cross-check Member Set.** The same 8 Claude files and 5 Codex files as the primary set.
- **Cross-check Count.** Claude 8; Codex 5.
- **Member-set Comparison.** The normalized sets are identical on both surfaces.

### Claim N2: call sites (Claude 22, Codex 12)

- **Complete Family.** Call expressions of the Claim N1 family in the Claim N1 member files.
- **Exhaustive Search Scope.** `{.claude,.codex}/hooks/*.ps1`.
- **Inclusion Rules.** One line equals one call. Every call passes a literal `-CommandWord`.
- **Exclusion Rules.** Docblock mentions, such as `enforce-epic-worktree-removal-gate.ps1:123` and `enforce-epic-merge-gate.ps1:103,105`.
- **Primary Search Strategy.** The Claim N1 function-name regex with content output.
- **Primary Member Set.**
  - Claude: validate-bash `:123,127`; promotion `:126,127`; epic-base-branch `:92,100,138`; helpers `:279,280,290,291`; parallel gate `:201,202,361`; preimplementation gate `:142`; epic gate `:140,141,355`; merge gate `:128,134,342,343`.
  - Codex: validate-bash `:96,100`; promotion `:123,124`; preimplementation gate `:161`; epic gate `:58,59,126`; merge gate `:63,69,141,142`.
- **Primary Count.** Claude 22; Codex 12.
- **Cross-check Strategy.** Regex `-CommandWord '(git|gh)'` in count mode over `{.claude,.codex}/hooks/*.ps1`.
- **Cross-check Member Set.**
  - Claude per file: merge-gate 4, epic-gate 3, helpers 4, parallel-gate 3, validate-bash 2, preimplementation 1, promotion 2, epic-base-branch 3.
  - Codex per file: validate-bash 2, promotion 2, preimplementation 1, epic-gate 3, merge-gate 4.
- **Cross-check Count.** Claude 22; Codex 12. The total is 34 across 13 files.
- **Member-set Comparison.** Per-file counts are equal to the primary per-file line sets on both surfaces, and the file sets are identical.

## 13. Constraints (Question 9)

- **No Python in hooks.** All proposed changes are PowerShell. The pr-author receipt route uses `sha256sum` and `date` as allowed commands, not a Python helper.
- **500-line cap.** Current sizes:
  - `hook-command-invocation.ps1` and `hook-command-scanner.ps1`: 483 each.
  - `enforce-parallel-worktree-removal-gate.ps1`: 474.
  - `enforce-epic-worktree-removal-gate.ps1`: 457.
  - `validate-bash.ps1`: 443.
  - `enforce-pr-author-skill-helpers.ps1`: 385.
  - `legacy-codex-hook-contracts.Tests.ps1`: 497.

  Replacing the two `Get-*RemovalCommandPath` bodies with `Resolve-CommandLineInvocationTarget` reduces the gate files.
- **PowerShell version.** Hooks declare "Compatible with PowerShell 7+" (for example `enforce-epic-worktree-removal-gate.ps1:59`). They are registered as `pwsh -NoProfile -File` on both runtimes (`.claude/settings.json:95-123`; `.codex/config.toml:124-149`). Windows PowerShell 5.1 compatibility is not required. `Parser.ParseInput` and `[System.IO.Path]::GetRelativePath` are available in PowerShell 7.
- **Deny reasons keep their leading tokens:** `PROMOTION_MCP_ONLY_BLOCKED:`, `EPIC_WORKTREE_REMOVAL_BLOCKED:`, `PARALLEL_WORKTREE_REMOVAL_BLOCKED:`, `PR_AUTHOR_SKILL_BLOCKED:`, `PR_BODY_PATH_NONCANONICAL:`. Only the new hook introduces a token (`PR_AUTHOR_COMMAND_NOT_ALLOWED:`).
- **Folder naming.** The epic manifest's placeholder `feature_folder` (`2026-10-08-promotion-hook-raw-containment-false-positive-deny-824`, `epic.md:20`) differs from the workspace folder (`promotion-hook-raw-containment-false-positive-deny-824`). The manifest states that basenames are back-filled at fan-in (`epic.md:49-51`).

## 14. Proposed File Changes

| File (plus Codex copy and bundled mirrors where they exist) | Change |
|---|---|
| `.claude|.codex/hooks/hook-command-invocation.ps1` | Add the `Terminal` option table and command-word leaf normalization. Add Status, all-matches, and payload-aware resolution via the new modules. Remove `Test-CommandLineRawContainment` from classification. Correct the `:28-30`, `:96-99`, and `:172-174` contract text. |
| new `.claude|.codex/hooks/hook-command-payload.ps1` | Wrapper payload extraction, base64 decode, PowerShell AST adapter, substitution bodies, inert proof, `Read-CommandLineInvocationSegment`. |
| new `.claude|.codex/hooks/hook-command-invocation-operands.ps1` | Moved operand and flag readers; `Resolve-CommandLineInvocationTarget`. |
| `.claude|.codex/hooks/hook-command-scanner.ps1` (optional) | Backslash-newline normalization and `Delimiter`. Move the heredoc helpers out if the line budget requires it. |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | Authorize every target. An Indeterminate result denies with the existing prefix. |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | Check 1 path canonicalization via the flag value. Restrict the raw `--body*` fallback to Indeterminate. Matching only. |
| new `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | Per-segment allowlist for the pr-author agent. |
| `.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md` | Frontmatter `hooks.PreToolUse` registration; receipt procedure via `sha256sum` and `date`. |
| Both `pack-manifests/core.json`; `legacy-codex-hook-contracts.Tests.ps1:30` | List the new modules and hook. |
| `enforce-promotion-mcp-only.ps1`, `validate-bash.ps1`, preimplementation gate, merge gate | No change required. They consume the corrected matcher. Regression rows only. |

## Automation Feasibility

Fully automatable, with the qualifications below.

- **Automatable.** Every code change, Pester suite, coverage measurement, parity hash, pytest and jest parity test, and fail-before/pass-after record can be produced by agents through the PoshQC MCP tools or the self-hosted PoshQC module, Poetry, and npx. None requires a human decision.
- **Qualification 1: isolation guard.** The isolation guard text-denies `pwsh` and `bash` in agent-isolated worktrees (Section 5.1). Executors should use the MCP PoshQC tools, or run in a non-isolated worktree.
- **Qualification 2: frontmatter hook wiring.** A static test can confirm that the pr-author frontmatter `PreToolUse` registration is present. Confirming that the runtime fires it requires a live `pr-author` delegation. That delegation can be automated as an orchestration smoke step, but it cannot be covered by a unit test.
- **Human interaction (optional).**
  - Filing upstream feedback for #742 items 2 and 3, which are runtime-owned.
  - Deciding whether to re-measure the item 4 engine prompt under `bypassPermissions`.

  Neither blocks C1a.

## Open Decisions for the Plan

1. Accept the disposition that #742 items 2 and 3 are not repository-owned, and restate their acceptance conditions in `spec.md`.
2. Confirm that addendum 1 items 4 and 5 become authorizable by a checkpoint, which is a behavior change from today's unconditional deny.
3. Confirm the sink allowlist for the inert proof and the accepted residual: string-evaluating constructs that are not in the sink list classify as Indeterminate, which is the fail-closed direction.
4. Confirm the pr-author receipt route (`sha256sum` and `date` as allowlisted segments) and frontmatter registration, rather than a global settings hook.
