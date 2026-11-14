# Research: Agents repeatedly hit the cd-chained read-command deny (Issue #1165)

- Issue: #1165
- Branch: `bug/cd-chained-command-recurring-deny-1165`
- Work mode: full-bug
- Requirements source: `docs/features/active/cd-chained-command-recurring-deny-1165/issue.md`
- Researcher tools: Read, Grep, Glob, WebFetch, Write. No `git` or `gh` was run; items that need either are marked `ORCHESTRATOR-CONFIRM`.
- Timestamp note: the filename stamp is the latest host-clock value readable by this agent (the runtime-recorded timestamp of this agent's own most recent tool call, 2026-11-09T22:58Z UTC); the researcher has no clock command.

## 1. Hook Mechanics (verified)

### 1.1 Claude copy: `.claude/hooks/validate-bash.ps1`

- Dot-sourced or imported dependencies, each in a guarded single-statement `try`: `hook-dependency-guard.ps1` (bootstrap form with `$script:HookDependencyGuardLoadFailed`), `../lib/hook-payload/HookPayload.psm1` (`Import-Module ... -ErrorAction Stop`), `hook-command-scanner.ps1`, `hook-command-invocation.ps1`.
- `Get-BlockedBashPattern`: the six destructive literals (`rm -rf`, `git push --force`, `git push origin --force`, `Remove-Item -Recurse -Force`, `git reset --hard`, `git push -f`).
- `Get-BlockedPatternMatch`: leg 1 literal token runs per segment (plus raw `ScanText` scan for wrapper-led, live-substitution, or unbalanced segments); leg 2 structural git classification (`Get-BlockedStructuralGitMatch`), which also denies relocating spellings such as `git -C <path> reset --hard`.
- `$script:CdChainedReadCommandPattern` = `cd\s+\S.*?(&&|;)\s*(grep|cat|head|tail|less|more|awk|sed\s+-n)\b` (retained constant). `$script:CdChainedReadCommandWords` = `grep cat head tail less more awk sed`.
- `Get-CdChainedReadCommandMatch -Command`: two legs over `Read-CommandLineSegment` output.
  - Raw leg first: for each segment where `Test-CommandLineSegmentRawScan` is true (wrapper-led, live substitution, or unbalanced), the regex is applied to `ScanText`; returns capture group 2 with whitespace collapsed (for example `sed -n`).
  - Walk leg: once a segment with `CommandWord` `cd` and at least two tokens is seen, the first later segment whose `CommandWord` is in the read-word family is returned (`sed` only when its second token is `-n`). Adjacency is not required, and every segment delimiter counts (`;`, `&`, `&&`, `||`, `|`, newline, `(`, `)`, `{`, `}`, backtick, `$(`; `$script:CommandLineSegmentDelimiters` in `hook-command-scanner.ps1`).
- `Get-BashBlockReason -Command`: destructive match first (`Blocked dangerous command pattern detected: '<literal>'`), then the cd-chained match. Current cd-chained text, verbatim:

  > `Forbidden Bash pattern: 'cd ... && $readOp' (or ';'-chained). Claude Code's Bash permission engine cannot resolve a file-reading command ($readOp) against Read() rules once a preceding 'cd' has changed the working directory in the same command line - it always requires manual approval, regardless of any Read() or Bash() allow rule, and regardless of whether the path argument is relative or absolute. Rewrite as a single command using an absolute path instead of 'cd'-ing first, e.g. run $readOp directly against the absolute file path, with no leading 'cd'.`

- Emission: `Get-BashDenyDecision` builds `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<reason>"}}`; the entry point writes it with `ConvertTo-Json -Compress -Depth 5` and exits 0. Allow is no output and exit 0. A dependency failure emits a deny with prefix `HOOK_DEPENDENCY_LOAD_FAILED:`; a failed guard bootstrap writes that prefix to stderr and exits 2.
- Size: 448 lines (read in full). Not listed in `config/file-size-baseline.json`.

### 1.2 Codex copy: `.codex/hooks/validate-bash.ps1`

- Not byte-identical to the Claude copy, and it has **no cd-chained leg**. Its header comment states: "This copy has no cd-chained leg and none is added." It defines `Get-BlockedBashPattern`, `Test-BlockedPatternTokenRun`, `Get-BlockedStructuralGitMatch`, `Get-BlockedPatternMatch`, `Get-BashBlockReason` (destructive literal only), `Get-BashDenyDecision`, `Get-BashCommandToCheck` (plain `ConvertFrom-Json`, no `HookPayload.psm1`), `Invoke-ValidateBashDecision`, and `ConvertFrom-CodexBashHookPayload` (exit 2 on empty or malformed stdin). It dot-sources `hook-dependency-guard.ps1`, `hook-command-scanner.ps1`, and `hook-command-invocation.ps1`. Size: 319 lines.
- Consequence: the deny the owner sees is produced only on the Claude surface. `.github/hooks/` contains no cd-chained logic (Grep for the read-command family and `Forbidden Bash` returned no files).
- Defect in the brief (related finding): `## Command-Text Restrictions` in all six execution-environment copies attributes `Get-CdChainedReadCommandMatch` and the cd-chained deny to `.codex/hooks/validate-bash.ps1` as well. That is inaccurate and is corrected in the recommended design.

### 1.3 Tests that assert the message or the decisions

| Test file | Tests touching the cd-chained leg or message | Effect of a guidance-only change |
|---|---|---|
| `tests/scripts/claude-hooks/validate-bash.Tests.ps1` | Context `Get-CdChainedReadCommandMatch detects cd-chained read commands`: family cases, absolute-path case, bare-read null, `cd ... && npm test/ci`, `npx jest` null, empty/null; `produces a deny reason via Get-BashBlockReason naming the matched read command` (asserts `*cd ... && grep*` and `*Read()*`); `the dangerous-pattern denylist takes precedence...` (`*Blocked dangerous command pattern*`); `denies through Invoke-ValidateBashDecision...` (`*cd ... && grep*`); `Hook source contains no deny-path exit 1` | Unchanged if the new reason keeps the first sentence and the `Read()` rationale sentence. |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | Context `the cd-chained read-command leg` (quoted `cd docs && cat notes.md` allows; non-adjacent `cd /tmp/x && npm test && grep ...` returns `grep`); Context `R-2.d wrapper-led cd-chain` (`bash -c`, `sh -c`, `pwsh -Command` forms) | Decision-only; unchanged. |
| `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` | CN-01..CN-05 on both runtimes (destructive rows) | Unchanged. |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` | `validate-bash.ps1 emits a PreToolUse deny shape` | Unchanged (shape only). |
| `tests/scripts/claude-hooks/review-verdict-status.HookAllowance.Tests.ps1` | allow decisions for review commands | Unchanged. |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1` (C7) | dependency-failure deny with `HOOK_DEPENDENCY_LOAD_FAILED:` | Unchanged; the new guarded edge is covered by the same mechanism. |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | S1..S6 over every registered hook, repository and both bundle roots | Must pass for the new guarded dot-source (S2 single-statement try with `Add-HookDependencyFailure`; S4 the helper must be a terminating leaf). |
| `tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1`, `validate-bash-trigger-scoping.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1` | Codex destructive decisions and envelope | Unchanged because the Codex copy is not edited. |
| `tests/scripts/claude-runtime/claude-settings.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, `owner-directives-skill-contract.Tests.ps1`, `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_claude_customizations.py` | name the file only | Unchanged. |

No standalone corpus fixture of allow/deny commands exists. The corpus is the inline case set of the first two rows plus the Issue824 rows; the recommended regression test reuses those commands verbatim (section 5).

## 2. Intent Detection Design

### 2.1 How the two observed shapes are classified today

- Shape 1, `cd <dir> && git status --short && git log --oneline -3 && cat ...`: the walk sees the `cd` segment, skips the two `git` segments, and returns `cat`. Denied by the cd-chained leg. Independently, inside an agent-isolated worktree the Claude Code runtime guard refuses a `cd <path> &&` prefix before `git` (brief, `## Command-Text Restrictions`).
- Shape 2, `cd <dir> && env -u VIRTUAL_ENV poetry install --no-interaction ...`: the `env` segment is wrapper-led (`env` is in `$script:CommandLineWrapperNames`), so its raw text is regex-scanned, but that text contains no `cd`, so the raw leg does not match; the walk skips `env` because it is not a read word. The command **as written does not match**. It is denied only when the elided tail contains a later read segment, typically an output filter such as `2>&1 | tail -n 20` (the `|` and the `&` of `2>&1` are both segment delimiters, and the `tail` segment's command word is `tail`). The trigger is therefore the trailing pipe filter, not the Poetry call. ORCHESTRATOR-CONFIRM if the exact transcript text is wanted; the conclusion follows from the code for any tail that does not contain a read word.
- Driver of shape 2 (related finding): the `## Worktree Python Environment` section of the brief says "run `env -u VIRTUAL_ENV poetry install` once from the worktree root", and the `WORKTREE_VENV_BLOCKED:` reason in `worktree-poetry-venv-policy.ps1` (Claude and Codex, plus both bundle copies; byte-identical reason string verified by Grep) says "From the worktree root run env -u VIRTUAL_ENV poetry install". An agent whose Bash working directory resets to the session root reads both as "cd first". The venv guard already honors `-C`, `--directory`, `-P`, and `--project` (`$script:WorktreePoetryDirectoryOption`, `Resolve-WorktreePoetryTargetDirectory`), so `env -u VIRTUAL_ENV poetry -C <worktree root> install` is accepted by that guard.

### 2.2 Replacement forms (verified against tool documentation, 2026-11-09)

| Intent | Form | Verification |
|---|---|---|
| Read a file | Read or Grep tool, or the read command against an absolute path with no `cd` | Hook rationale comment above `$script:CdChainedReadCommandPattern`. |
| git | `git -C <abs> <subcommand>` | Already used in `.claude/skills/parallel-orchestrate/SKILL.md` and `.claude/skills/cleanup-merged-worktrees/SKILL.md`. Refused by the runtime guard inside an isolated worktree when `<abs>` is another worktree. |
| Poetry | `poetry -C <abs> <command>` (`--directory`) | python-poetry.org CLI docs: `--directory (-C)` "The working directory for the Poetry command"; arguments are resolved relative to it. Whether `poetry run` also changes the child process directory is not stated in the docs (unverified); test paths passed to `poetry -C <abs> run pytest` should therefore be absolute or the `sh` route used. |
| npm | `npm --prefix <abs> run <script>` / `ci` / `test` | npm config docs: setting `prefix` on the command line forces non-global commands to run in that folder; npm-run docs: scripts run from the package root regardless of the current directory. |
| npx | No `--prefix` documented for `npm exec`/`npx`; use `npm --prefix <abs> run <script>` when a package script exists, otherwise the `sh` route | npm-exec docs do not mention `--prefix`. |
| Multi-step | A script under `SCRATCH` that may `cd` internally, run as `sh <SCRATCH>/<file>.sh` | Brief: `sh <file>.sh` with a literal path passes the isolation guard; the hook sees only the `sh` command text. |

Context split (for the table and the rule): inside an agent-isolated worktree the Bash working directory is already the worktree root, so the `cd` is dropped and plain `git`/`poetry`/`npm` is used; `git -C <other worktree>` is refused there. A non-isolated agent working in a sibling worktree has its Bash working directory reset to the session root on each call, so it uses the `-C`/`--prefix`/absolute-path forms or the `sh` route.

### 2.3 Proposed pure functions (PowerShell)

New helper `.claude/hooks/bash-command-shape-guidance.ps1`, dot-sourced by the Claude `validate-bash.ps1` with the guarded single-statement form pinned by `hook-dependency-guard-completeness.Tests.ps1`:

```powershell
try { . (Join-Path $PSScriptRoot 'bash-command-shape-guidance.ps1') } catch { Add-HookDependencyFailure -Name 'bash-command-shape-guidance.ps1' -ErrorRecord $_ }
```

The helper defines functions only, dot-sources nothing (a terminating leaf for S4), and relies on `Read-CommandLineSegment` and `Test-CommandLineSegmentRawScan`, which `validate-bash.ps1` loads before it. Two functions:

1. `Get-CdChainedCommandIntent -Command <string> -ReadOp <string>` returns `[pscustomobject]@{ ReadOp; CdTarget; Tools; IsMultiStep }`.
   - `CdTarget`: second token of the first qualifying `cd` segment; for the raw leg, the `cd\s+(\S+)` capture from `ScanText`.
   - `Tools`: ordered distinct subset of `git`, `poetry`, `npm`, `npx` found after the `cd`: a later segment whose `CommandWord` is the tool, or a later wrapper-led segment (`env`, `command`, `time`, `timeout`, `nohup`, `xargs`) whose tokens contain the tool as a whole token; for raw-scan segments, a whole-word match in `ScanText` after the `cd`.
   - `IsMultiStep`: `Tools.Count -ge 2`.
2. `Get-CdChainedRewriteGuidance -Intent <pscustomobject>` returns the guidance sentence(s):
   - No tool: read the file with the Read or Grep tool, or run `<ReadOp>` against the absolute path, with no leading `cd`.
   - One tool: the tool's form from 2.2 (with `CdTarget` shown as the directory to make absolute), and, because a read command is present, that piping into `<ReadOp>` is allowed once the `cd` is removed.
   - Multi-step: write the steps to a `sh` script under the scratch directory and run `sh <file>.sh`; the tool forms are listed as well.
   - Always: one sentence stating the isolated-worktree versus sibling-worktree split, and a pointer to `.claude/rules/bash-command-shape.md` and the `## Command-Text Restrictions` table.

`Get-BashBlockReason` keeps the first two sentences byte-unchanged and replaces only the final "Rewrite as a single command ..." sentence with `Get-CdChainedRewriteGuidance (Get-CdChainedCommandIntent -Command $Command -ReadOp $readOp)`. The decision, the pattern constant, the read-word family, `Get-CdChainedReadCommandMatch`, and the leading `Forbidden Bash pattern:` token are unchanged.

Shape classification under the design: shape 1 gives `Tools = git`, `IsMultiStep = false`, so `git -C <abs> status --short` style guidance plus the absolute-path read; shape 2 (with a trailing `| tail`) gives `Tools = poetry` (detected through the `env` wrapper), so `env -u VIRTUAL_ENV poetry -C <abs> install ... | tail ...` guidance.

### 2.4 Sharing between Claude and Codex

A byte-identical twin in `.codex/hooks/` (the pattern of `enforce-epic-merge-gate-child-ci.ps1`) is not recommended: the Codex `validate-bash.ps1` has no cd-chained leg by recorded decision (#545), Codex has no `Read()` permission-engine limitation, and a twin with no caller would ship dead code in the Codex bundle. The helper is Claude-only and is mirrored only to the Claude bundle.

Rejected alternatives: (a) inline the two functions in `validate-bash.ps1` - rejected because the file would pass the 500-line guidance tier and mix message text with detection; (b) add a cd-chained leg to the Codex copy for parity - rejected because it adds a deny the issue forbids (decision set must not change) and contradicts the #545 decision.

## 3. Always-Loaded Rule Surfaces

### 3.1 Claude

- Claude Code documentation (`code.claude.com/docs/en/memory`, read 2026-11-09): "Rules without `paths` frontmatter are loaded at launch with the same priority as `.claude/CLAUDE.md`." and "A path-scoped rule loads when Claude uses the Read, Write, or Edit tool on a matching file." `paths` is the only frontmatter field Claude Code reads; other fields are ignored.
- Subagents (`code.claude.com/docs/en/sub-agents`, "What loads at startup"): ordinary custom and built-in subagents load the project CLAUDE.md hierarchy "including ... project rules"; the built-in Explore and Plan agents and agents with `omitClaudeMd` skip it. No agent under `.claude/agents/` sets `omitClaudeMd` (Grep, zero matches).
- Current repository state: all 19 `.claude/rules/*.md` files carry a `paths:` list (Grep `^paths:` count 19). The four repository-wide rules (`general-code-change.md`, `general-unit-test.md`, `quality-tiers.md`, `tonality.md`) use `paths: - "**"`, which under the documented behavior loads on the first Read/Write/Edit of any file, not at launch. No rule currently loads before an agent's first Bash call.
- `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` pins two things the new rule conflicts with: `test_every_claude_rule_carries_parseable_paths_and_description` requires a non-empty `paths:` list in every rule, and `test_unconditional_rule_set_is_exactly_the_four_deliberate_files` requires the unconditional set (absent frontmatter, empty `paths`, or a match-everything glob) to equal `DELIBERATE_UNCONDITIONAL_RULES`.
- Recommendation: add `.claude/rules/bash-command-shape.md` with frontmatter carrying `description:` and **no** `paths:` key, so it loads at launch. Update `test_claude_rules_frontmatter.py`: add a `LAUNCH_LOADED_RULES` set containing `bash-command-shape.md` that is exempt from the non-empty `paths:` requirement but must carry a description and must have no `paths:` key, and add the file to the deliberate unconditional set. This is an edit to an existing Python test, not new Python production code.
- Related finding, recorded for the owner rather than changed here: the test module docstring and `UNCONDITIONAL_GLOBS` treat `paths: "**"` as equivalent to unconditional, which the current documentation contradicts. Changing the four repository-wide rules to launch-loaded would also change how the Codex converter classifies them (`has_repo_wide_paths_yaml` in `scripts/dev_tools/codex_native_converter/classifier_claude.py` routes `paths: - "**"` rules to `AGENTS.md` standing guidance), so it is a separate policy decision.

### 3.2 Codex

- Codex reads the repository `AGENTS.md` at session start. The root `AGENTS.md` and its bundle copy are converter output ("Converted standing guidance") merging `general-code-change.md`, `general-unit-test.md`, `tonality.md`, and `AGENTS.md`; it omits `quality-tiers.md`, so it is not regenerated by any CI check. The Codex push-down publishes only `.codex` and `.agents` (`ROOT_FOLDERS` in `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`), so a root `AGENTS.md` is not delivered to destinations.
- The parallel Codex surface for a Claude rule is a hand-maintained converted-rule skill `.agents/skills/<rule>/SKILL.md` ("Source: legacy Claude rule `<rule>`."; eight exist, no generator found by Grep). Recommendation: add `.agents/skills/bash-command-shape/SKILL.md` and its bundle copy, stating that the cd-chained deny exists only on Claude Code and that the shapes still apply to Codex sessions working across worktrees, and list it in the Codex `pack-manifests/core.json`. `generate_codex_agent_variants.py` preserves existing manifest entries and only appends agent paths (`render_manifest`), so a hand-added entry passes `--check` provided the file stays in `json.dumps(indent=2)` form.
- Root `AGENTS.md` is not edited (not distributed, and its regeneration is out of scope).

### 3.3 Copilot

- `.github/copilot-instructions.md` is named in the CLAUDE.md reading order as an authoritative file not to be modified. Adding a new file is not a modification of a listed policy file. The established repository-wide Copilot form is `.github/instructions/<name>.instructions.md` with `applyTo: "**"`, `name:`, and `description:` (for example `tonality.instructions.md`). The VS Code customization page describes `applyTo` as file matching and does not state that `**` applies to every request (unverified for requests with no file context).
- Recommendation: add `.github/instructions/bash-command-shape.instructions.md` (`applyTo: "**"`) and its bundle copy under `extensions/drm-copilot/resources/customizations/.github/instructions/`. The Copilot push-down publishes `.github/instructions` as a root folder (`COPILOT_ROOT_FOLDERS` in `copilot-customizations-engine.ts`), so no manifest entry is needed. No parity test for the `.github` bundle was found; the plan must verify byte equality of the copy explicitly. The Copilot base agents already read the execution-environment brief first (`test_brief_is_referenced_by_copilot_base_agents`), so the brief table reaches them.

### 3.4 Push-down and contract tests for the new files

- Claude rule and helper: add both paths to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (rules are listed there, for example `.claude/rules/tonality.md`; `validate-bash.ps1` is in core). Pinned by `test_push_down_claude_resource_contracts.py` (bundle text equality), `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_pack_manifest_dependency_closure.py` (the helper is a `$PSScriptRoot` dependency of a manifested hook, so it must be in core).
- Codex skill: `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, and the generator `--check`.
- All new rule and skill text: `test_push_down_issue_824_follow_ups.py` scans every pushed rule and skill file for consuming product names (`PINNED_NAME_OCCURRENCES` is empty, so any occurrence fails).
- Name convention: rule files are kebab-case topic names; `bash-command-shape` follows it across all three surfaces.

## 4. Playbook (`execution-environment`)

- Six byte-identical copies, pinned by `test_brief_copies_are_byte_identical` (`tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`) and by `test_discovery_documentation_contracts.py` (rglob of every `execution-environment/SKILL.md`).
- Wording pins that touch the section: `test_brief_states_isolation_guard_as_runtime_behavior` requires `Worktree isolation guard (Claude Code runtime behavior, not a repository hook)`, `` `.claude/hooks/validate-bash.ps1` ``, `` `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` ``, and `No file under `.claude/hooks/` implements this guard`. `test_brief_has_required_headings` pins heading order (no new `## ` heading may be inserted between existing ones out of order; a `###` sub-heading or a table inside the section is safe). `test_brief_has_no_g11_or_g12_findings` forbids line-number and commit-SHA citations. `test_brief_npm_run_tokens_exist_in_package_json` matches every backticked `` `npm run <x>` `` token against the root `package.json`: the table must not contain a backticked `npm run <script>` placeholder (write `` `npm --prefix <abs> run <script>` ``, which the regex does not match because it requires `npm run` adjacent). `test_brief_copies_carry_no_removed_run_tokens` forbids words such as `single-process` and `seeded`. `test_brief_worktree_python_environment_section_states_bootstrap` requires `env -u VIRTUAL_ENV poetry install`, `WORKTREE_VENV_BLOCKED:`, `enforce-worktree-poetry-venv.ps1`, `PYTHONPATH`, and `push-down` in that section. Also `planning-contract-wording.Tests.ps1`, `NestingDepthContract.Tests.ps1`, and `cleanup-merged-worktrees.SkillText.Tests.ps1` read other sections and are unaffected by edits confined to `## Command-Text Restrictions` and one sentence of `## Worktree Python Environment`.
- `ProcessReductionChain.Ledger.Tests.ps1` reverts stored patches by content search (`Invoke-ProcessReductionHunkRevert`); no stored patch under `docs/engineering/process-reductions/patches/` contains a `## Command-Text Restrictions` line (Grep for the four bullet openings returned zero), so edits there do not break the ledger chain.
- #1158 overlap: #1158 edits a different section (test-execution policy). Minimal-conflict edit: change only the body of `## Command-Text Restrictions` (correct the Codex attribution in the "Repository hooks" bullet and append a "Preferred forms" table after it) and add one sentence to `## Worktree Python Environment`; do not touch the frontmatter `description`, `## Purpose and Maintenance`, or `## Contract Tests That Pin Mirrored Files`. Git merges non-adjacent hunks without conflict. ORCHESTRATOR-CONFIRM which section #1158 edits before planning.

## 5. Briefs That Restate Command Text

Searched `.claude`, `.agents`, `.github`, `.codex`, and the bundle for `Command-Text Restrictions`, `Forbidden Bash pattern`, `absolute path instead of`, `cd ... &&`, `rather than `cd``, `git -C <`, `poetry -C`, `npm --prefix`, and `env -u VIRTUAL_ENV poetry install`.

- `## Command-Text Restrictions` and `## Worktree Python Environment` of the six brief copies (edited as above).
- `.claude/skills/parallel-orchestrate/SKILL.md` (and its Claude bundle copy), conflict-resolution step (c): "each with path arguments rather than `cd`". Add a pointer to the brief table. The same step instructs `git -C <worktree_path> reset --hard HEAD~1`, which `validate-bash.ps1` denies through the structural leg (relocating `git reset --hard`). Related finding; recommended fix in the same change: `git -C <worktree_path> reset --keep HEAD~1` (not denied; equivalent on a clean tree after the commit). ORCHESTRATOR-CONFIRM that `.agents`/`.github` copies of `parallel-orchestrate` do not exist (Grep found the phrase only in the Claude copy and its bundle).
- `worktree-poetry-venv-policy.ps1` `WORKTREE_VENV_BLOCKED:` reason (four byte-identical copies): append the `poetry -C <worktree root>` form. Tests assert only the prefix, `*env -u VIRTUAL_ENV poetry install*`, and `*never repoint the main checkout's environment*` (`tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1`, `returns the deny reason with the prefix and the legitimate path`), and prefix-only on Codex (`tests/scripts/codex-hooks/enforce-worktree-poetry-venv.Tests.ps1`).
- No agent file restates the cd rule. `.claude/skills/cleanup-merged-worktrees/SKILL.md` already uses `git -C`; no change.

## 6. Recurrence Measurement

- The repository hooks log no denials: `validate-bash.ps1` is declared read-only, writes only stdout/stderr, and `.claude/state/` holds only batch-budget, epic-progress, and session-id files. No repository count is available.
- Host-local proxy (not repository evidence): the Claude Code session transcripts of the main-checkout project contain the deny text. A Grep for `Forbidden Bash pattern: 'cd \.\.\. &&` over that project's `*.jsonl` transcripts on 2026-11-09 found 747 matching lines in 333 transcript files. The figure is not deduplicated, includes quotations of the message (including this research session), and excludes transcripts of other worktree project directories. It may be recorded as an approximate baseline described only as "host transcript directory of the main checkout"; no absolute path or host name may be written into evidence.

## 7. Batch Budget and File Size

- PowerShell production files the recommended design writes: `.claude/hooks/validate-bash.ps1`, its Claude bundle copy, `.claude/hooks/bash-command-shape-guidance.ps1` (new), its Claude bundle copy, and the four `worktree-poetry-venv-policy.ps1` copies: eight distinct files. The direct-mode cap is three per kind per session and worktree; an isolated subagent worktree has no checkpoint, so direct mode applies there. The plan must either run under a non-terminal `large` route checkpoint in the item worktree or write the bundle copies through a `sh` copy script (Bash-written files are not seen by the budget hooks). Python files touched are tests only and never count.
- Sizes: `validate-bash.ps1` 448 lines (grows by about 3); Codex copy 319 (unchanged); new helper estimated 120-180; new test file estimated 200-300; `validate-bash.Tests.ps1` 227. None is near 700/800, and none is in `config/file-size-baseline.json`. Markdown is exempt.
- Coverage: `config/poshqc-coverage.json` roots include `.claude/hooks`, so the new helper is measured automatically (PowerShell line threshold 85%).

## 8. Constraint Check: Message Consumers

- Grep for `Forbidden Bash pattern` outside feature folders finds only the hook and its bundle copy; `docs/` (excluding features) and `extensions/drm-copilot/src` contain no parser of `permissionDecisionReason` text. The only repository consumers are the Pester assertions listed in 1.3 (`*cd ... && grep*`, `*Read()*`), which remain satisfied when the first two sentences are kept byte-unchanged.
- External consumer: the Claude Code fleet notice groups failures by message text. Intent-specific tails may split that grouping into several messages that share the `Forbidden Bash pattern: 'cd ... && <op>'` prefix. This is not a repository contract.

## Recommended Design: File Inventory

| File | Role |
|---|---|
| `.claude/hooks/bash-command-shape-guidance.ps1` (new) + Claude bundle copy | Pure `Get-CdChainedCommandIntent` and `Get-CdChainedRewriteGuidance`. |
| `.claude/hooks/validate-bash.ps1` + Claude bundle copy | Guarded dot-source of the helper; `Get-BashBlockReason` final sentence replaced by the guidance; detection unchanged. |
| `.claude/hooks/worktree-poetry-venv-policy.ps1`, `.codex/hooks/worktree-poetry-venv-policy.ps1`, both bundle copies | Reason string gains the `poetry -C <worktree root>` form; prefix and tested substrings unchanged. |
| `.claude/rules/bash-command-shape.md` (new, no `paths:`) + Claude bundle copy | Launch-loaded command-shape rule with the intent-to-form table and the isolated/sibling split. |
| `.agents/skills/bash-command-shape/SKILL.md` (new) + Codex bundle copy | Codex converted-rule skill. |
| `.github/instructions/bash-command-shape.instructions.md` (new, `applyTo: "**"`) + Copilot bundle copy | Copilot repository-wide instruction. |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Lists the rule and the helper. |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | Lists the Codex skill. |
| Six `execution-environment/SKILL.md` copies | Correct the Codex attribution; add the preferred-forms table to `## Command-Text Restrictions`; one sentence in `## Worktree Python Environment`. |
| `.claude/skills/parallel-orchestrate/SKILL.md` + Claude bundle copy | Pointer to the table; `reset --keep` replacing the denied `reset --hard`. |
| `tests/scripts/claude-hooks/bash-command-shape-guidance.Tests.ps1` (new) | Unit tests of both helper functions. |
| `tests/scripts/claude-hooks/validate-bash.CdChainGuidance.Tests.ps1` (new) | Decision-regression corpus and reason-shape assertions through `Get-BashBlockReason`. |
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` | Launch-loaded rule exemption and unconditional-set update. |
| `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` | New assertion that `## Command-Text Restrictions` names `.claude/rules/bash-command-shape.md`, `git -C`, `poetry -C`, `npm --prefix`, and the `sh` route, and no longer attributes the cd-chained leg to the Codex copy. |

## Testing Strategy

- Helper unit tests (Pester 6, pure strings, no files): read-only chain (`cd /x && cat f`), git chain (shape 1), poetry through `env` with a pipe filter (shape 2), npm and npx chains, multi-step (`git` and `poetry`), wrapper-led raw leg (`bash -c "cd /x && git log | head"`), `CdTarget` extraction, and empty or null input.
- Decision regression: a table-driven test over every command in the existing cd-chained, trigger-scoping, and Issue824 suites plus the new intent cases, asserting `[bool](Get-BashBlockReason -Command $c)` and `Get-CdChainedReadCommandMatch` equal their pre-change values, that every cd-chained reason starts with `Forbidden Bash pattern: 'cd ... && <op>' (or ';'-chained).` and contains `Read()`, and that every destructive reason is byte-unchanged. A Phase 0 run of the same file on the unedited hook records the baseline.
- Gates: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, per the brief. The new test files under `tests/scripts/claude-hooks` also run in `poshqc / PowerShell hook suites (Linux)`; use `Join-Path` and forward-slash relative paths.

## Existing Tests Whose Disposition the Plan Must State

1. `tests/scripts/claude-hooks/validate-bash.Tests.ps1` - unchanged; the reason keeps `cd ... && grep` and `Read()`.
2. `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` - unchanged (decisions only).
3. `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` - unchanged.
4. `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` - unchanged.
5. `tests/scripts/claude-hooks/review-verdict-status.HookAllowance.Tests.ps1` - unchanged.
6. `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` and `hook-dependency-failure.SpecialCases.Tests.ps1` - unchanged; new edge covered generically.
7. `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` - unchanged; must pass S1-S6 for the new edge on the repository and Claude bundle roots.
8. `tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1` and `tests/scripts/codex-hooks/enforce-worktree-poetry-venv.Tests.ps1` - unchanged; asserted substrings retained.
9. Codex validate-bash suites (`validate-bash-decision-surface`, `validate-bash-trigger-scoping`, `codex-pretooluse-integration`, `legacy-codex-hook-contracts`, `hook-dependency-failure.Codex`) - unchanged; Codex hook not edited.
10. `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` - updated (launch-loaded rule).
11. `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` - updated (new section assertion); existing assertions retained.
12. `tests/scripts/dev_tools/test_discovery_documentation_contracts.py`, `planning-contract-wording.Tests.ps1`, `NestingDepthContract.Tests.ps1`, `cleanup-merged-worktrees.SkillText.Tests.ps1`, `ProcessReductionChain.Ledger.Tests.ps1` - unchanged; copies stay byte-identical and edited sections are not pinned there.
13. `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_issue_824_follow_ups.py`, generator `--check` - unchanged; satisfied by the bundle copies and manifest entries.

## Numeric Derivation Evidence

The only count the design relies on is the number of execution-environment brief copies.

- Complete Family: execution-environment/SKILL.md
- Exhaustive Search Scope: entire worktree source tree, including extensions/drm-copilot/resources and all variant folders
- Inclusion Rules: any committed file whose path ends in execution-environment/SKILL.md
- Exclusion Rules: none
- Primary Search Strategy or Query Expression: Glob pattern **/execution-environment/SKILL.md over the worktree root
- Primary Member Set: .claude/skills/execution-environment/SKILL.md, .agents/skills/execution-environment/SKILL.md, .github/skills/execution-environment/SKILL.md, claude-customizations/.claude/skills/execution-environment/SKILL.md, codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md, customizations/.github/skills/execution-environment/SKILL.md
- Primary Count: 6
- Cross-check Search Strategy or Query Expression: read the _BRIEF_COPIES tuple in tests/scripts/dev_tools/test_execution_environment_brief_contracts.py that enumerates execution-environment/SKILL.md copies
- Cross-check Member Set: .claude/skills/execution-environment/SKILL.md, claude-customizations/.claude/skills/execution-environment/SKILL.md, .agents/skills/execution-environment/SKILL.md, codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md, .github/skills/execution-environment/SKILL.md, customizations/.github/skills/execution-environment/SKILL.md
- Cross-check Count: 6
- Member-set Comparison: the normalized member sets are equal (same six paths in both enumerations)

## Automation Feasibility

Fully automatable with no human interaction. Every change is a text or PowerShell edit verified by Pester and pytest contract suites that run locally and in CI. No owner decision is required for the recommended scope; the `paths: "**"` load-timing finding for the four existing rules is recorded for the owner but is not part of this change. Constraints for automation: the executor reaches Pester through the `sh` launcher route; the batch budget requires a `large` route checkpoint or a `sh` copy script for the bundle mirrors; a branch hook change is proven by Pester, not by a live isolated subagent.

## Pre-Mortem

- **Review checklists**: a reviewer may flag that the issue says "Claude and Codex copies" while the Codex hook is untouched. Mitigation: the spec states the verified fact that the Codex copy has no cd-chained leg (#545) and that the brief's contrary sentence is corrected.
- **Coverage**: the new helper is in the coverage denominator through `config/poshqc-coverage.json`; untested branches (raw leg, wrapper-led tool detection, empty input) would pull it below 85%. Mitigation: the helper test file covers every branch listed in the testing strategy, and per-file coverage is read from `artifacts/pester/powershell-coverage.xml` of the single gate run.
- **Mirror parity**: eleven mirrored pairs or sets (hook, helper, venv policy x4, rule, Codex skill, Copilot instruction, six brief copies, parallel-orchestrate) can drift. Mitigation: each task names its mirror, the brief-update task covers all six copies in the same change, and the plan runs the contract tests listed in 3.4 and section 4 plus an explicit byte comparison for the Copilot instruction copy, which has no parity test.
- **File size**: no edited file approaches 700 lines. Mitigation: new logic goes into the new helper and new test files rather than `validate-bash.ps1` or `validate-bash.Tests.ps1`.
- **Test isolation**: the new tests dot-source `validate-bash.ps1` and the helper into the test scope; dot-sourced script-scope variables can leak across files in one shard. Mitigation: dot-source inside `BeforeAll` only, use in-memory command strings, no temporary files, and run `Invoke-PoshQCLeakScan`.
- **CI-only behavior**: the hook suites also run on Linux with a case-sensitive file system. Mitigation: `Join-Path`, forward-slash relative paths, exact file-name case, and no drive-letter fixtures in the new tests; no test reads gitignored `artifacts/` state.
- **Evidence**: the recurrence figure is host-local and could leak a host path into evidence. Mitigation: record it only as an approximate count with a path-free description, append-only, with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` fields under `<FEATURE>/evidence/baseline/`.
