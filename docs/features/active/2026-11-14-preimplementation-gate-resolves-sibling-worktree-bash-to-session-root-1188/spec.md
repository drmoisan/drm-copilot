# 2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root (Spec)

- **Issue:** #1188
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-15
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** full-bug (acceptance criteria source: this file only)
- **Research:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/research/research.2026-11-14.md` (authoritative; this spec adopts its recommended design, decision rule, non-goals, and AC-1..AC-15 table)

## Context

In the sibling-worktree topology (a non-isolated agent working in an item worktree under `.claude/worktrees/`), the preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, Codex twin `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`) resolves gated Bash commands other than `git add` and `git commit` to the session root instead of the item worktree. The session root holds no orchestrator checkpoint, so the gate denies with `PREIMPLEMENTATION_GATE_BLOCKED`. The #1158 executor could run its pytest gate only through scratch `sh` scripts, which hide the command from every text-based hook. The same gate treats a shell-variable selector (`git -C $W ...`) as a relative path and therefore decides it against the session root's checkpoint.

Environment:
- OS/version: Windows 11, Claude Code runtime, PowerShell 7
- Python version: not applicable
- Command/flags used: a direct test-runner command from a sibling item worktree, for example `env -u VIRTUAL_ENV poetry -C <abs worktree> run pytest <abs test path>`, and the post-#1158 launcher form `sh <abs worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest`
- Data source or fixture: reported by the #1158 run (PR #1184 body, ORCH-D8)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence

Steps to Reproduce:
1. In a session whose root has no orchestrator checkpoint, work in a sibling item worktree that has a ready checkpoint.
2. Run the item's test gate with a command that names the worktree through `poetry -C <abs>`, `npm --prefix <abs>`, the absolute launcher path, or absolute test paths.
3. Observe `PREIMPLEMENTATION_GATE_BLOCKED` naming the missing checkpoint, although the named worktree's checkpoint is ready.

Expected:
The gate resolves the target worktree from the directory selectors, script operands, and absolute literal operands of every command family it gates, and allows the command when that worktree's checkpoint is ready. Commands whose target cannot be derived from literal text fail closed.

Actual:
Direct commands are denied, and agents fall back to scratch `sh` scripts. A command that names its worktree only in a shell variable is decided against the session root's checkpoint.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: see PR #1184, `## Decisions` (ORCH-D8) and `## Follow-ups`.

## Scope & Non-Goals

- In scope:
  - Target-worktree resolution of the single-feature command leg of both preimplementation gates (`Resolve-OrchestrationGateTarget` in each surface's `enforce-orchestration-preimplementation-gate-epic-scope.ps1`).
  - A new operand-extraction function `Get-OrchestrationGateCommandTargetOperand` in a new byte-identical sibling `enforce-orchestration-preimplementation-gate-operands.ps1`.
  - Fail-closed handling of shell-variable, substitution, missing-value, unmodelled-option, and malformed-record operands.
  - Bundle mirrors, pack manifests, the Codex legacy contracts list, and the execution-environment brief.
- Out of scope / non-goals (behavior stays unchanged):
  - The `cd <abs> && <runner>` form (the brief forbids it and prescribes `-C` and `--prefix`).
  - The epic per-segment target rules R0-R7 (`Get-OrchestrationCommandTarget` in `enforce-orchestration-preimplementation-gate-targets.ps1`), including the R7 session-root target for non-git segments.
  - Classification, except for a two-form stage-1 supplement (remediation decision R1): `Test-ImplementationCommand` stage 1 additionally matches (1) the npm and npx patterns over the text of scan segments joined across a `$(`, `${`, or backtick split of one shell word (`npm --prefix $(pwd) run lint`), and (2) `npx` followed by the options `--prefix <v>`, `--prefix=<v>`, `-C <v>`, `--yes`, `-y`, `--no`, `-q`, or `--quiet` before the tool word (`npx --prefix <item> jest`, `npx --yes jest`). The supplement lives in the new byte-identical sibling `enforce-orchestration-preimplementation-gate-classify.ps1`, every supplement hit still passes stage 2 (`Test-OrchestrationGateInvocationConfirmed`) and the index-0 bookkeeping rule, and the patterns are unchanged. No command other than these two forms is newly classified, and no command is newly unclassified.
  - The Write/Edit file-path leg and the Codex `apply_patch` marker-path branch.
  - The delegation leg (portable-identity resolution).
  - Prunable-registration filtering (`Resolve-AgentTargetWorktree` is not adopted).
- Explicitly excluded systems, integrations, or datasets: the test-execution hook (`enforce-test-execution-policy.ps1`) and its `test-execution-command-form.ps1` (used only as a reference for option names; not loaded by the gate); `Resolve-HookTargetWorktree` and its Codex twin `hook-target-worktree.ps1` (called unchanged).

## Root Cause Analysis

`Resolve-OrchestrationGateTarget` (each surface's epic-scope file) passes `-CommandOperandPath @(Get-OrchestrationGateCommandOperandPath -Command $Command)` to `Resolve-HookTargetWorktree`. `Get-OrchestrationGateCommandOperandPath` returns only the `git` global `-C` values and the absolute literal operands of Structural `git add` and `git commit` matches. For every other gated family (Python tools, npm scripts, npx tools, Pester, and the `sh` launcher that classifies through its `pytest` operand), it returns nothing, so no resolver source is present and `Resolve-HookTargetWorktree` returns the session root with Source `SessionRoot`. The payload `cwd` is not read; the session root is the hook process location.

Shell-variable selectors are not filtered for literalness: `git -C $W add x` returns `$W`, which is not absolute, so the resolver's relative-path rule maps it to the session root. It fails closed today only when the session root lacks a ready checkpoint.

The defect lies entirely in the operand source of `Resolve-OrchestrationGateTarget`; neither gate file contains it.

## Proposed Fix

### Design summary (what changes where):

- Add `enforce-orchestration-preimplementation-gate-operands.ps1`, byte-identical in `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`. It defines `Get-OrchestrationGateCommandTargetOperand -Command <string>`, a pure string function (no file system, process, or clock access).
- Each surface's `enforce-orchestration-preimplementation-gate-epic-scope.ps1` (root and bundle copy) dot-sources the new sibling with the single-statement guarded form `try { . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-operands.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-orchestration-preimplementation-gate-operands.ps1' -ErrorRecord $_ }`.
- `Resolve-OrchestrationGateTarget` on each surface replaces its `-CommandOperandPath @(Get-OrchestrationGateCommandOperandPath ...)` argument with the new function's `Paths`, and, when `Unresolved` is set, returns `NoTarget` with reason code `TARGET_WORKTREE_NOT_DERIVABLE` and the function's `Detail` before calling the resolver or the listing.
- `Get-OrchestrationGateCommandOperandPath` stays in both epic-scope files, unchanged, and is called by the new function for the staging family.
- Remediation R1: add `enforce-orchestration-preimplementation-gate-classify.ps1`, byte-identical in the same four locations, defining the pure string function `Get-OrchestrationGateSupplementalPatternIndex -CommandText <string>`, which returns the subset of the stage-1 pattern indexes `2` (npm scripts) and `3` (npx tools) that the two supplement forms match. Each gate dot-sources it with the single-statement guarded form after the `enforce-orchestration-preimplementation-gate-commands.ps1` line, and `Test-ImplementationCommand` calls it once before its pattern loop and treats an index in the returned set as a stage-1 hit.
- Remediation R1: in the Codex gate, `Get-OrchestrationModeDenyReason` moves unchanged into `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (and its bundle copy) before any line is added, so the Codex gate stays within its 500-line cap.
- Remediation R1: the POSIX-shell branch of `Get-OrchestrationGateHostOperand` in the operands sibling skips the value of `--rcfile` and `--init-file`, so it is no longer taken as the script operand.

### Remediation Decision R1 (cycle 1)

- Route: the recommended route of finding R1 (classification supplement in a new byte-identical sibling; spec non-goal, AC-2, AC-6, and AC-14 revised). The fallback route (weakening AC-6 to the quoted form and AC-2 to state that `npx --prefix` is not gated) is not used.
- Rationale: owner directive OD-1 (autonomous mode) and the owner rule to fix related findings inside the item; shell-variable and substitution operands stay fail-closed, which requires that `npm --prefix $(pwd) run lint` be classified at all; the two unclassified forms are gate fail-opens that exist on `main`, and the fallback would leave both in place; the Codex gate is at its 500-line cap, so an existing block moves into a sibling before the two wiring lines are added.
- Corrected root cause of the AC-6 miss: stage 1 matches its patterns per `Read-CommandLineSegment` scan segment, and the scanner splits the unquoted `$(` word into `npm --prefix `, `pwd`, and ` run lint`, so no segment holds both `npm` and the script word and stage 1 never matches. `Test-OrchestrationGateInvocationConfirmed` (stage 2) returns true for every pattern index of that command; the earlier attribution of the miss to stage 2 was wrong. `npx --prefix <item> jest` is unclassified because the npx pattern requires the tool word directly after `npx`. `Get-OrchestrationGateCommandTargetOperand` already returns `Unresolved` for the unquoted npm form and the item root for the npx form, so once classified both reach the intended decisions.

### Boundaries and invariants to preserve:

- Each gate file (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`) differs from `main` only by the guarded dot-source of the classify sibling and the one supplement call in `Test-ImplementationCommand`, plus, in the Codex gate, the removal of the moved `Get-OrchestrationModeDenyReason` block. Stage 2, the index-0 bookkeeping rule, and the stage-1 patterns are unchanged.
- The function-definition parity of `Get-OrchestrationGateWorktreeList`, `Invoke-OrchestrationGateWorktreeList`, and `Get-OrchestrationGateCommandOperandPath` across both epic-scope files is preserved.
- Relative literal operands and lone absolute paths in no registered worktree keep the session root, as today.
- The listing seam `Get-OrchestrationGateWorktreeList` and the checkpoint seam `Get-CheckpointContent` remain the only I/O; the new file performs no `Test-Path` or `Get-Content`.
- Any call that binds `-CheckpointRaw` still bypasses target resolution.

### Dependencies or blocked work:

- None. #1158 (test-execution launcher) and #1010 (gate resolution through `Resolve-HookTargetWorktree`) are merged.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- New: `.claude/hooks/enforce-orchestration-preimplementation-gate-operands.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-operands.ps1`, and their two bundle copies.
- Edited: `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, and their two bundle copies.
- Edited: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (hand-maintained hook entries).
- Edited: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (`$script:SharedModuleNames` gains the new Codex sibling).
- Edited: the execution-environment brief in its six byte-identical copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.
- New tests: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1` (G-rows and Claude gate rows), a Codex suite under `tests/scripts/codex-hooks/`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Parity.Tests.ps1` (byte identity of the sibling copies).
- Remediation R1, new: `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-classify.ps1`, and their two bundle copies, listed in both `core.json` files and in `$script:SharedModuleNames`.
- Remediation R1, edited: both gate files and their bundle copies (guarded dot-source and supplement call; in the Codex gate, removal of the moved block), the Codex epic-scope file and its bundle copy (receives `Get-OrchestrationModeDenyReason`), and the four operands-sibling copies (`--rcfile`/`--init-file` value skip).
- Remediation R1, tests: new `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1`; edited `enforce-orchestration-preimplementation-gate-operands.Cases.ps1` (V3, N3, bash option-value G-rows), `enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (NG-02 removed), and `enforce-orchestration-preimplementation-gate.Parity.Cases.ps1` (`$script:CodexOnlyGateFunction` without the moved function).

#### Functions/classes/CLI commands impacted:

- New: `Get-OrchestrationGateCommandTargetOperand`.
- Changed: `Resolve-OrchestrationGateTarget` (each surface) — operand source and an `Unresolved` early return.
- Called unchanged: `Get-OrchestrationGateCommandOperandPath`, `Resolve-HookTargetWorktree`, `Read-CommandLineInvocationSegment`, `Test-CommandLineWordPresent`, `Test-CommandLineTokenLiteral`, `Get-CommandLineGlobalOption`.

#### Data flow and validation changes:

Decision rule of `Get-OrchestrationGateCommandTargetOperand`:

1. Staging family. Take the output of `Get-OrchestrationGateCommandOperandPath -Command`. Any returned value that fails `Test-CommandLineTokenLiteral` (for example a shell-variable `-C` value) sets `Unresolved`.
2. Record harvesting. Iterate the records of `Read-CommandLineInvocationSegment`. A record is harvested when it, or a payload record beneath it (greater Depth, before the next record of equal or lower Depth), carries a governed word of any stage-1 pattern: a whole token matched through `Test-CommandLineWordPresent` (`git`, `black`, `ruff`, `pyright`, `pytest`, `prettier`, `lint`, `typecheck`, `test:unit`, `eslint`, `tsc`, `jest`, `Invoke-Pester`) or the text `tests/scripts/`. A carrying record that is `Unbalanced`, or `Opaque` with `DecodeFailure` or `DepthLimit`, sets `Unresolved`.
3. Prefix walk per harvested record. Skip `VAR=value` tokens and the prefixes:
   - `env`: standalone options `-i`, `-`, `-0`, `-v`, `--ignore-environment`, `--null`, `--debug`; value options `-u`, `--unset`; selector options `-C`, `--chdir` (the value is a target operand); split options `-S`, `--split-string` set `Unresolved`.
   - `timeout`, `nohup`, `time`, `command`, `nice`.
   - An unmodelled dash token in a prefix sets `Unresolved`.
   The shared parser's `Skip-CommandLineTransparentWrapper` is not relied on for `env`, because it takes the value of `-u` as the command word.
4. Host selectors after the prefix walk:
   - `git`: global `-C`, with the arity of every git global option taken from `Get-CommandLineGlobalOption -CommandWord git`.
   - `poetry`: `-C`, `--directory`, `-P`, `--project`, in separate, inline `=`, and attached (`-Cvalue`) forms, skipping the standalone global options `-v`, `-vv`, `-vvv`, `--verbose`, `-h`, `--help`, `-q`, `--quiet`, `--ansi`, `--no-ansi`, `-V`, `--version`, `-n`, `--no-interaction`, `--no-plugins`, `--no-cache`. An unmodelled dash token before `run` sets `Unresolved`.
   - `npm` and `npx`: `--prefix` and `-C`, found by scanning the whole token list.
   - `pwsh` and `powershell`: `-WorkingDirectory` and `-wd`, and the operand of `-File` or `-f`, found by scanning the whole token list.
   - `sh`, `bash`, `zsh`, `dash`, `ksh`: the script-file operand, which is the first non-dash token when no `-c` cluster is present.
   - A selector whose value is missing or fails `Test-CommandLineTokenLiteral` sets `Unresolved`.
5. Runner operands. For harvested records whose host is not `git`, collect every bare literal absolute token (pattern `^([A-Za-z]:[\\/]|/)`) that is not a redirection operator or redirection target and is not the value of a selector or of a known value option. A non-literal token that contains `/` or `\` in an operand position sets `Unresolved`. Git operands come only from rule 1, so commit option values such as `-F <abs>` are never collected.
6. Output. `Paths` holds distinct values in first-seen order (selectors, script operands, absolute operands, staging operands). Relative literals are never added, so a command whose operands are all relative keeps the session root.

Resolution after extraction (unchanged `Resolve-HookTargetWorktree` semantics):

- `Unresolved` set: deny `TARGET_WORKTREE_NOT_DERIVABLE` with the unresolvable-operand `Detail`, before any listing call or checkpoint read, whatever the session root's checkpoint holds.
- All paths inside one registered worktree: that worktree's checkpoint decides.
- Paths in two different registered worktrees, or a registered worktree plus a path in none: `TARGET_WORKTREE_AMBIGUOUS`.
- A lone absolute path in no registered worktree, or no paths at all: the session root.
- Listing failure or empty listing: `TARGET_WORKTREE_NOT_DERIVABLE`, no checkpoint read.

#### Error handling and logging updates:

- New deny detail for the `Unresolved` case, carried under the existing `TARGET_WORKTREE_NOT_DERIVABLE` reason code; it names the unresolvable operand class (shell variable or substitution, missing selector value, unmodelled option, split string, or malformed record).
- A failed dot-source of the new sibling is recorded through `Add-HookDependencyFailure` and denies, naming the file, on both surfaces.

#### Rollback/feature-flag considerations (if applicable):

- No flag. Rollback is a revert of the epic-scope edits; reverting the epic-scope call site restores the prior operand source.
- Remediation R1: the classification supplement is rolled back by reverting the two-line wiring in each gate (guarded dot-source and supplement call); the classify sibling is then unused. The move of `Get-OrchestrationModeDenyReason` is behavior-neutral and need not be reverted.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- `Get-OrchestrationGateCommandTargetOperand -Command <string>` returns an object with `Paths` (string array, possibly empty), `Unresolved` (bool), and `Detail` (string; empty when `Unresolved` is false).

#### Required configuration keys and defaults:

- None.

#### Backward-compatibility expectations:

- Unchanged: relative selectors and operands, lone outside absolute paths, ambiguity and listing-failure results for git operands, the `apply_patch` branch, the Write/Edit leg, the delegation leg, the epic per-segment rules, and classification of every command outside the two supplement forms.
- Intended strengthening (remediation R1): an npm script word that follows a substitution-split shell word (`npm --prefix $(pwd) run lint`) and an npx tool after the options `--prefix`, `-C`, `--yes`, `-y`, `--no`, `-q`, or `--quiet` (`npx --yes jest`) are now classified; non-goal row NG-02 (`npx --yes jest`) leaves `$script:ClassificationNonGoalCase` and becomes a positive classify row. `bash --rcfile <v> <script>` and `bash --init-file <v> <script>` now take the script, not the option value, as the script operand.
- Intended strengthening: a shell-variable or substitution selector or path-like operand (including `git -C $W`) now denies `TARGET_WORKTREE_NOT_DERIVABLE` even when the session root's checkpoint is ready.
- Existing suites `enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` (B1-B15, T1-T15), `codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` (B1-B15, C1-C18), `...OperandResolution.Tests.ps1` (O4, O5, O10), `...EpicScopeHelperParity.Tests.ps1` (F1), and `...Parity.Tests.ps1` (AC-17, AC-18) pass unchanged.

#### Performance constraints (latency/throughput/memory):

- The new function is pure string processing over the already-parsed command records. The `Unresolved` path performs no listing call. No additional process starts.

## Assumptions, Constraints, Dependencies

- Assumptions:
  - The launcher derives its repository root from its own location (`Invoke-TestSuite.ps1` `RepositoryRoot` default; `run-test-suite.sh` `script_dir`), so an absolute launcher path is a legitimate target selector.
  - Option names follow npm (`-C` is the shorthand of `--prefix`) and Poetry 2 (`--directory`/`-C`, `--project`/`-P`) documentation, as recorded in the research.
- Owner constraints (mandatory):
  - The Codex gate `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is at exactly 500 lines, the cap asserted by `legacy-codex-hook-contracts.Tests.ps1` (`parse-checks each root and bundled hook and keeps every file within 500 lines`), and must not grow past it. Remediation R1 adds two lines to the Codex gate, so `Get-OrchestrationModeDenyReason` moves into `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` first, and the Codex gate ends below its starting length.
  - New logic lives in the new byte-identical sibling `enforce-orchestration-preimplementation-gate-operands.ps1` in `.claude/hooks`, `.codex/hooks`, and both bundles.
  - Hooks never invoke Python, and the change adds no new Python (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` continues to pass).
  - Every hook change is mirrored to the bundles and listed in the pack manifests.
  - The execution-environment brief is updated in all six byte-identical copies.
  - Artifacts encode no absolute host paths; evidence is append-only and clock-stamped.
- Constraints:
  - File size: the Claude epic-scope file and the Codex epic-scope file each grow by a guarded dot-source, one call, and one unresolved branch and stay under 500 lines; the new sibling targets under 300 lines.
  - Tests run in parallel only, through the test-execution launcher (`sh <abs worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <paths>` for task checks); no local integration or golden lanes.
  - Linux hook-suite job: fixtures use `/synthetic-worktrees/...` roots, forward slashes, exact file-name case, and `Join-Path`; Windows drive-letter rows are pure string inputs to the helper.
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: gated commands from a sibling worktree that name the worktree literally are decided against that worktree's checkpoint; shell-variable selectors deny with `TARGET_WORKTREE_NOT_DERIVABLE`.
- Data or migration considerations: none.
- Logging/telemetry updates: the new `Unresolved` deny detail only.
- Compatibility notes: Codex and Claude behave identically through the byte-identical sibling. Destination repositories receive the change through a push-down after the extension release that carries it.

## Test Strategy

Seeded from issue:

- [ ] Extend operand resolution to every command family the gate gates (poetry -C/--directory, npm --prefix, absolute script and test paths) with byte-identical behaviour in the Codex mirror
- [ ] Pester rows: each operand form resolving to a ready sibling worktree is allowed; the same form naming a not-ready worktree is denied; a shell-variable operand still denies
- [ ] Re-check the execution-environment brief text on sibling-worktree command shapes

- Regression tests to add or update:
  - New `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1`: G-rows for the function alone, and gate rows P1-P3, N1-N4, L1-L2, W1-W2, A1, V1-V5, M1-M2, R1-R3, F1-F2, U1-U4, I1 against the Claude gate.
  - New Codex suite under `tests/scripts/codex-hooks/` that dot-sources the Codex gate and feeds mapped tool input for the same gate rows.
  - New `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Parity.Tests.ps1` pinning byte identity of the sibling copies.
  - Update `legacy-codex-hook-contracts.Tests.ps1` `$script:SharedModuleNames`.
  - Add a fail-closed row for the new file following `hook-import-failure-exemptions.FailClosed.Tests.ps1` (`T13`/`C16` pattern).
  - Remediation R1: new `enforce-orchestration-preimplementation-gate-classify.Cases.ps1` (function rows and classification rows: positive rows for both supplement forms, negative rows for every near-miss form, and controls), `enforce-orchestration-preimplementation-gate-classify.Tests.ps1` on each surface (classification rows through `Test-ImplementationCommand`, function rows against the classify sibling, and row I2 for a failed dot-source of the classify sibling), and `enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1` (four-copy byte identity, 500-line cap, and brief wording rows). In the operands suites, V3 is the unquoted AC-6 command with the quoted form as an extra row, N3 is an allow/deny pair, and G-rows cover `bash --rcfile` and `bash --init-file`.
  - Remediation R1 fail-before: the unquoted V3 row, both N3 rows, both bash option-value G-rows, and every positive classify row fail against the unmodified hooks and pass after the change (recorded under `evidence/regression-testing/`).
- Fixture model: `Get-OrchestrationGateWorktreeList` mocked to an in-memory listing of the session root, `/synthetic-worktrees/w-item`, and `/synthetic-worktrees/w-other`; `Get-CheckpointContent` mocked per path as `Set-TargetFixture` does; the session-root body empty unless a row states otherwise. No files, processes, or clock reads. Mocks are registered per row; script-scope state such as `$script:OrchestrationGateWorktreeListFailed` is reset per the `EpicStateIsolation.Baseline.Helpers.ps1` pattern.
- Edge cases and negative scenarios: shell variables and substitutions in each selector family, missing selector values, `env -S`, unmodelled poetry options, unbalanced and undecodable records, redirection targets, `git commit -F <abs>`, mixed-worktree operands, outside-only operands, listing failure, empty listing.
- Error handling verification: every fail-closed row asserts the reason code, the absence of any checkpoint read, and (for `Unresolved`) the absence of a listing call.
- Coverage: the new PowerShell sibling reaches at least 85% line coverage (both copies execute through the Claude and Codex suites; `config/poshqc-coverage.json` includes `.claude/hooks` and `.codex/hooks` as folders); changed lines of the epic-scope files show no coverage regression. Branch coverage is not measured for PowerShell.
- Fail-before proof: the AC-1, AC-3, and AC-6 rows fail against the unmodified tree and pass after the change; the runs are recorded under the feature folder's `evidence/regression-testing/`.
- Toolchain: task checks through the launcher `pester` suite with `-TestPath`; phase gates and final QA run the full parallel Pester gate, `Invoke-PoshQCLeakScan`, PSScriptAnalyzer, formatting, and the pytest gate (push-down, manifest, and brief contract suites), one suite at a time through the launcher.
- Manual validation steps: none required; a live non-isolated check from the item worktree is optional evidence.

## Acceptance Criteria

- [x] AC-1: `env -u VIRTUAL_ENV poetry -C <item> run pytest <item>/tests/x.py` is admitted when the item worktree's checkpoint is ready and denied when it is not ready or absent; the item checkpoint is read once and the session-root checkpoint is never read. The same outcomes hold with `--directory <item>`, `--directory=<item>`, and `-P <item>` (rows P1 ready, P2 not ready, P3 absent, on both surfaces).
- [ ] AC-2: `npm --prefix <item> run test:unit`, `npm -C <item> run lint`, and `npx --prefix <item> jest` resolve to the item worktree: each is admitted against a ready item checkpoint, and a not-ready item checkpoint denies (rows N1-N2 allow, N4 deny, and N3 as a pair: `npx --prefix <item> jest` admitted against a ready item checkpoint with one item read, and denied against a not-ready one, on both surfaces).
- [x] AC-3: `sh <item>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` and `env -u VIRTUAL_ENV sh <item>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` resolve to the item worktree: admitted against a ready item checkpoint and denied against a not-ready one (rows L1, L2, on both surfaces).
- [x] AC-4: `pwsh -NoProfile -File <item>/tests/scripts/X.Tests.ps1` and `pwsh -WorkingDirectory <item> -Command "Invoke-Pester -Path tests/scripts"` resolve to the item worktree and are decided by its checkpoint (rows W1, W2, on both surfaces).
- [x] AC-5: `pytest <item>/tests/x.py` with no directory selector resolves to the item worktree and is decided by its checkpoint (row A1, on both surfaces).
- [ ] AC-6: Each of `git -C $W add x`, `poetry -C ${W} run pytest`, `npm --prefix $(pwd) run lint`, `sh $W/run-test-suite.sh pytest`, and `pytest $W/tests` denies with `TARGET_WORKTREE_NOT_DERIVABLE` and an unresolvable-operand detail even when the session-root checkpoint is ready, reads no checkpoint, and does not call `Get-OrchestrationGateWorktreeList` (rows V1-V5, on both surfaces). The quoted form `npm --prefix "$(pwd)" run lint` denies the same way (an extra V3 row).
- [x] AC-7: Operands that name two different registered worktrees (`poetry -C <item> run pytest <other>/tests`), or a registered worktree plus an absolute path in no registered worktree, deny with `TARGET_WORKTREE_AMBIGUOUS` (rows M1, M2, on both surfaces).
- [x] AC-8: Relative selectors and operands (`npm --prefix extensions/drm-copilot run test:unit`, `poetry run pytest tests/x.py`) and a lone absolute path in no registered worktree keep the session-root checkpoint: with a ready session-root checkpoint each is admitted and the item checkpoint is never read (rows R1-R3, on both surfaces).
- [x] AC-9: A listing failure or an empty listing with a runner selector denies with `TARGET_WORKTREE_NOT_DERIVABLE` and reads no checkpoint (rows F1, F2, on both surfaces).
- [x] AC-10: An unbalanced or undecodable record that carries a governed word, a selector with no value (`poetry -C` at the end of the command), an `env -S` split string, and an unmodelled poetry option before the selector (`poetry --frobnicate -C <item> run pytest`) each deny as unresolvable with `TARGET_WORKTREE_NOT_DERIVABLE` (rows U1-U4, on both surfaces).
- [x] AC-11: Unit rows for `Get-OrchestrationGateCommandTargetOperand` alone assert `Paths` and `Unresolved` for every form in AC-1 through AC-10, assert that redirection targets and `git commit -F <abs>` values are not collected, and pass in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1` and the Codex suite under `tests/scripts/codex-hooks/`; the existing B1-B15 rows of both surfaces pass unchanged; the new sibling reaches at least 85% line coverage in the Pester gate, and changed lines of the epic-scope files show no coverage regression.
- [x] AC-12: `enforce-orchestration-preimplementation-gate-operands.ps1` is byte-identical across `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` (pinned by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Parity.Tests.ps1`); each epic-scope file equals its bundle copy; the new file is listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, and in `$script:SharedModuleNames` of `legacy-codex-hook-contracts.Tests.ps1`; and `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, and `test_push_down_pack_manifest_dependency_closure.py` pass.
- [x] AC-13: When the dot-source of `enforce-orchestration-preimplementation-gate-operands.ps1` fails, each surface's gate denies fail-closed with a reason that names the file (row I1, following the `T13`/`C16` pattern), and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` passes with the new guarded dot-source in each epic-scope file.
- [ ] AC-14: Each of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` differs from `main` only by one guarded dot-source of the classify sibling and one `Get-OrchestrationGateSupplementalPatternIndex` call in `Test-ImplementationCommand`, plus, in the Codex gate, the move of `Get-OrchestrationModeDenyReason` to `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`; the `legacy-codex-hook-contracts.Tests.ps1` test `parse-checks each root and bundled hook and keeps every file within 500 lines` passes; the AC-18 function-inventory rows of `enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` pass with `$script:CodexOnlyGateFunction` updated for the move; the F1 rows of `enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1` pass unchanged; `enforce-orchestration-preimplementation-gate-classify.ps1` is byte-identical in its four copies (`enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1`) and listed in both `core.json` files and in `$script:SharedModuleNames`; and its positive rows classify and its negative rows stay unclassified on both surfaces.
- [x] AC-15: The `## Hook Execution Context` section of the execution-environment brief states that the preimplementation gate resolves, through the same resolver, the `git add`/`git commit` `-C` values and absolute operands and, for every other gated command, the directory selector (`poetry -C`/`--directory`/`-P`/`--project`, `npm`/`npx` `--prefix`/`-C`, `env -C`/`--chdir`, `pwsh -WorkingDirectory`), the script operand of `sh`/`bash` and `pwsh -File`, and absolute literal operands; that a shell-variable or substitution selector or path-like operand denies with `TARGET_WORKTREE_NOT_DERIVABLE`; that relative operands and absolute paths in no registered worktree keep the session root; and that the absolute launcher path is the sibling-worktree test form. The text is byte-identical in all six copies, and `test_execution_environment_brief_contracts.py` (`test_brief_copies_are_byte_identical`) passes.

## Risks & Mitigations

- Technical or operational risks:
  - A reviewer reads the `git -C $W` deny with a ready session-root checkpoint as an unintended behavior change.
  - Option tables duplicate names already held in `test-execution-command-form.ps1`.
  - A missed mirror copy, manifest entry, `$script:SharedModuleNames` entry, or brief copy fails a contract suite.
  - Script-scope state or mocks leak between test files in a shard.
  - Linux-only failures from drive letters, backslashes, or case.
- Mitigations and rollbacks:
  - The strengthening is stated in this spec as intended, and every unchanged row is listed under Backward-compatibility expectations.
  - The new sibling carries a comment naming `test-execution-command-form.ps1` as the source of the prefix and poetry/npm option names; the gate does not load that file.
  - One task per surface edits the root and bundle copies together; the parity suite pins the sibling copies; the brief task names all six copies.
  - Per-row mock registration, no file creation, and `Invoke-PoshQCLeakScan` in the static job.
  - Synthetic forward-slash roots and `Join-Path` in fixtures.
  - Rollback: revert the epic-scope edits; the gate files are untouched.

## Rollout & Follow-up

- Release/rollout steps: merge to `main`; isolated subagents use the new resolution after merge (hooks run the default branch's copies); destination repositories receive it through a push-down after the extension release that carries the bundle change.
- Post-fix monitoring or clean-up tasks: sibling-worktree executors use the literal absolute launcher form instead of scratch `sh` scripts for test gates. Widening the epic per-segment rule R7 to runner operands is a separate decision and is not filed by this item.
- Links: issue #1188; PR #1184 (`## Decisions` ORCH-D8); research `research/research.2026-11-14.md`.
