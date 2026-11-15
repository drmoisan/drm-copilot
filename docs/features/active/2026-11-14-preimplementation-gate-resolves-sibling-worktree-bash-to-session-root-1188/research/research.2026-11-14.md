# Research: preimplementation gate resolves sibling-worktree Bash to the session root (Issue #1188)

- Issue: #1188
- Branch: bug/gate-sibling-worktree-pytest-target
- Feature folder: docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188
- Filename note: the task-researcher tool set has no clock. The file carries the session date (2026-11-14) without a time component, which the researcher-output hook's filename rule accepts (`research.<yyyy-MM-dd>.md`); the bare `research.md` fallback named in the delegation is rejected by that rule (`Test-TaskResearcherFileName` pattern in `.claude/hooks/validate-task-researcher-output.ps1`).
- Every finding below was verified by reading the named file and symbol in the item worktree. No line numbers or commit identifiers are cited.

## 1. Classification: which Bash commands each gate gates

Both gates classify a Bash command in `Test-ImplementationCommand` (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`). The two functions carry the same five stage-1 patterns; the Codex copy additionally classifies `apply_patch` marker paths (`*** Add|Update|Delete File:` and `*** Move to:`) through `Test-ImplementationPath` before the pattern loop.

| Index | Stage-1 pattern | Governed words (stage 2) | Family |
|---|---|---|---|
| 0 | `(^|\s)git\s+(add|commit)\b`, plus the structural check `Test-CommandLineInvocation -CommandWord git -SubcommandPath add|commit` | `git` | staging |
| 1 | `(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b` | `black`, `ruff`, `pyright`, `pytest` | Python tools |
| 2 | `(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b` | `prettier`, `lint`, `typecheck`, `test:unit` | npm scripts |
| 3 | `(^|\s)npx\s+(prettier|eslint|tsc|jest)\b` | `prettier`, `eslint`, `tsc`, `jest` | npx tools |
| 4 | `(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)` | `Invoke-Pester`, text `tests/scripts/` | Pester |

- A regex hit (not the structural staging hit) is confirmed by `Test-OrchestrationGateInvocationConfirmed` in the byte-identical `enforce-orchestration-preimplementation-gate-commands.ps1` (`.claude/hooks/` and `.codex/hooks/`). It drops a hit only when every governed word is a mention-host operand; it never adds a classification.
- A staging hit of index 0 can be cleared by `Test-ExemptOrchestrationStagingCommand` (helpers file, issue #539) when no other pattern also matches.
- Verified consequences for the forms this issue names:
  - `env -u VIRTUAL_ENV poetry -C <abs> run pytest <abs test>` is classified (index 1). It is also denied by the test-execution hook (`enforce-test-execution-policy.ps1`, #1158), which admits only the launcher.
  - The launcher `sh <abs worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` is classified (index 1): ` pytest` matches the stage-1 regex, and in stage 2 the `sh <file>` record is an Opaque `NoPayload` wrapper (`Get-CommandLineWrapperPayload` in `hook-command-payload.ps1`) whose own text carries `pytest`, which confirms the hit. This is the form a sibling-worktree executor must use after #1158, so it is the primary reproduction, not only the direct `poetry` form.
  - `sh <abs launcher> pester` and `sh <SCRATCH>/<file>.sh` are not classified (no governed word), so they never reach target resolution. This is why scratch scripts bypass every text-based hook.
  - `npm --prefix <abs> run test:unit`, `npx --prefix <abs> jest`, and `pwsh -NoProfile -File <abs>/tests/scripts/...` are classified (indexes 2, 3, 4).
- The launcher derives its repository root from its own location (`Invoke-TestSuite.ps1` parameter `RepositoryRoot` defaults to four `Split-Path -Parent` hops from `$PSScriptRoot`; `run-test-suite.sh` resolves `script_dir` from `$0`). An absolute launcher path therefore selects the worktree whose suite runs, which makes the script operand a legitimate target selector.

## 2. Target resolution today and why the session root is chosen

Single-feature command leg (both surfaces): `Invoke-OrchestrationPreimplementationGateDecision` calls `Read-OrchestrationGateCheckpoint -Mode single-feature -Command $command` only when `-CheckpointRaw` is unbound or empty. `Read-OrchestrationGateCheckpoint` calls `Resolve-OrchestrationGateTarget`, which (both in each surface's `enforce-orchestration-preimplementation-gate-epic-scope.ps1`):

1. sets the session root to `(Get-Location).Path`;
2. calls `Resolve-HookTargetWorktree -SessionRoot $sessionRoot -CommandOperandPath @(Get-OrchestrationGateCommandOperandPath -Command $Command) -WorktreeListInvoker $invoker` (Codex: only when the command is not an `apply_patch` body; marker paths go in as `-FilePath`);
3. maps a listing failure (`$script:OrchestrationGateWorktreeListFailed`) and a null root to `NoTarget` (`TARGET_WORKTREE_NOT_DERIVABLE`), an ambiguous result to `Ambiguous` (`TARGET_WORKTREE_AMBIGUOUS`), and otherwise to `SessionRoot` or `OtherWorktree`; `Read-OrchestrationGateCheckpoint` reads `artifacts/orchestration/orchestrator-state.json` beneath that root (`Get-WorktreeRunCheckpointPath` on Claude, string composition on Codex) through the `Get-CheckpointContent` seam.

`Get-OrchestrationGateCommandOperandPath` (byte-identical function text in both epic-scope files) returns only the `-C` global-option values and the absolute literal operands of Structural `git add` and `git commit` matches from `Get-CommandLineInvocation`. It returns nothing for any other command family.

`Resolve-HookTargetWorktree` (`.claude/lib/worktree-resolution/HookTargetWorktree.psm1`; Codex twin `.codex/hooks/hook-target-worktree.ps1`) selects the first present source in the order FilePath, CommandOperand, DelegationIdentity, SessionRoot. With an empty operand list and no prompt, no source is present and it returns the session root with Source `SessionRoot` without enumerating worktrees. Within the path source, a relative path and an absolute path inside no registered worktree each map to the session root, and roots that differ yield `TARGET_WORKTREE_AMBIGUOUS`.

Why each named form resolves to the session root:

| Command | Operands returned by `Get-OrchestrationGateCommandOperandPath` | Resolver outcome |
|---|---|---|
| `env -u VIRTUAL_ENV poetry -C <abs> run pytest <abs path>` | none (not a git staging invocation) | no source present: session root |
| `npm --prefix <abs> run test:unit` | none | session root |
| `sh <abs>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` | none | session root |
| `pwsh -File <abs>/tests/scripts/X.Tests.ps1` | none | session root |
| `git -C $W add x` | `$W` (global-option values are not filtered for literalness) | `$W` is not absolute, so it maps to the session root (relative rule) |

In the sibling-worktree topology the session root is the main checkout, which holds no checkpoint, so the gate denies with the generic `PREIMPLEMENTATION_GATE_BLOCKED` text. A shell-variable selector is therefore fail-closed today only because the session root has no ready checkpoint; with a ready session-root checkpoint, `git -C $W add x` is admitted against the session root's checkpoint.

`Resolve-AgentTargetWorktree` (`.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`, Codex twin `.codex/hooks/agent-target-worktree.ps1`) is not used by either preimplementation gate; a Grep of both epic-scope files and both gate files finds only `Resolve-HookTargetWorktree`.

Epic-scope precheck: before the single-feature path, `Get-OrchestrationEpicScopeDecision` resolves per-segment targets with `Get-OrchestrationCommandTarget` (byte-identical `enforce-orchestration-preimplementation-gate-targets.ps1`). For any segment whose command word is not `git` (including every runner and every wrapper-led record without a git staging match), rule R7 adds the session root as the target. Outside epic scope the decision returns `$null` and the single-feature path runs. The recommended design leaves this per-segment epic logic unchanged (see Section 10, non-goals).

Payload `cwd` is not read by either gate's command leg; the session root is the hook process location.

## 3. Reusable operand-extraction helpers

| Helper | Location | Selector options modelled | Reusable here |
|---|---|---|---|
| `Get-OrchestrationGateCommandOperandPath` | both epic-scope files (function text byte-identical, pinned by `enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1`) | `git -C`, absolute `git add`/`git commit` operands | Yes, called unchanged for the staging family |
| `Get-CommandLineGlobalOption`, `Skip-CommandLineOption`, `Get-CommandLineInvocation`, `Test-CommandLineTokenLiteral` | `hook-command-invocation.ps1` (shared parser) | git, gh, npx global options | Yes: literal test, git `-C` table |
| `Read-CommandLineInvocationSegment`, `Skip-CommandLineTransparentWrapper`, `ConvertTo-CommandLineLeafWord`, `Test-CommandLineWordPresent` | `hook-command-scanner.ps1` / `hook-command-payload.ps1` | records with Depth, Dialect, Tokens, Opaque, Unbalanced | Yes for record iteration; see the `env` limitation below |
| `$script:CommandLinePowerShellValueFlags` | `hook-command-payload-powershell.ps1` | includes `-workingdirectory`, `-wd` | Yes (pwsh selector names) |
| `$script:TestExecutionPrefixTable`, `$script:TestExecutionPoetryOption` (`-C`, `--directory`, `-P`, `--project`), `$script:TestExecutionNpmOption` (`--prefix`, `-w`, `--workspace`), `Get-TestExecutionShellFileOperand`, `Get-TestExecutionHostFileOperand`, `Get-TestExecutionCommandForm` | `test-execution-command-form.ps1` (test-execution hook; per the brief, run against the byte-identical `.claude/hooks` and `.codex/hooks` twins) | full prefix model incl. `env -u/--unset/-C/--chdir/-S` | Tables are a good reference, but `Get-TestExecutionCommandForm` discards selector values, and the gate does not load this file |
| `$script:WorktreePoetryDirectoryOption` (`-C`, `--directory`, `-P`, `--project`), `Get-WorktreePoetryCommandShape`, `Resolve-WorktreePoetryTargetDirectory` | `worktree-poetry-venv-policy.ps1` (poetry venv guard) | poetry directory options only | No: poetry-only, mutating-subcommand oriented |

Verified limitation of the shared parser: `Skip-CommandLineTransparentWrapper` skips `env` dash tokens and `VAR=value` tokens only, so in `env -u VIRTUAL_ENV poetry ...` the token `VIRTUAL_ENV` is taken as the command word. The new walker must model `env` value options (`-u`, `--unset`) and selector options (`-C`, `--chdir`) itself, as `$script:TestExecutionPrefixTable` does.

External option facts (fetched): npm documents `-C` as the shorthand of `--prefix` (docs.npmjs.com, config shorthands). Poetry 2 documents `--directory=DIRECTORY (-C)` ("The working directory for the Poetry command ... All command-line arguments will be resolved relative to the given directory") and `--project=PROJECT (-P)` ("Specify another path as the project root ... arguments will be resolved relative to the current working directory"), and the global standalone options `-v|-vv|-vvv`, `--verbose`, `-h`, `--help`, `-q`, `--quiet`, `--ansi`, `--no-ansi`, `-V`, `--version`, `-n`, `--no-interaction`, `--no-plugins`, `--no-cache`.

## 4. Fail-closed requirements

| Operand case | Current gate behavior | Required behavior |
|---|---|---|
| Shell variable or substitution in a selector position (`git -C $W`, `poetry -C ${W}`, `npm --prefix $(pwd)`) | `$W` treated as relative: session root checkpoint decides | Deny `TARGET_WORKTREE_NOT_DERIVABLE` with an "unresolvable operand" detail, reading no checkpoint, whatever the session root holds |
| Non-literal path-like operand of a runner (`pytest $W/tests`, `sh $W/run-test-suite.sh pytest`) | ignored: session root | Same deny |
| Selector option with no value (`poetry -C` at end) | not modelled | Same deny |
| Relative literal selector or operand (`npm --prefix extensions/drm-copilot run test:unit`, `git add scripts/x.ps1`) | session root (pinned by `T7`/`C9` rows and `O5`) | Unchanged: session root |
| Absolute literal operand in no registered worktree, alone | session root (`T7 outside`, `T14`) | Unchanged |
| Operands naming two different registered worktrees, or a registered worktree plus a path in none | `TARGET_WORKTREE_AMBIGUOUS` (`T8`) for git operands | Same rule for every family |
| Listing failure or empty listing | `TARGET_WORKTREE_NOT_DERIVABLE` (`T9`, `T10`) | Unchanged, now also for runner operands |
| Unbalanced, decode-failure, or depth-limit record that carries a governed word | git Indeterminate matches ignored: session root | Deny as unresolvable (fail closed) |
| Unmodelled option before a selector in a prefix or host option list (`poetry --frobnicate -C A run pytest`) | not modelled | Deny as unresolvable |
| `cd <abs> && <runner>` | session root (single-feature); epic scope denies through rule R3 | Unchanged (non-goal; the brief forbids the `cd` form and names `-C`/`--prefix`) |

## 5. Codex gate size and structure

- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`: 500 lines (the final line is `}` followed by a terminator). `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (`parse-checks each root and bundled hook and keeps every file within 500 lines`) asserts `(Get-Content -LiteralPath $path).Count | Should -BeLessOrEqual 500` for every name in `$script:StaticCheckNames`, which includes the gate. Any added line fails CI.
- It dot-sources (guarded): `hook-dependency-guard.ps1`, `codex-pretooluse-file-mapping.ps1`, `enforce-orchestration-preimplementation-gate-helpers.ps1`, `-modes.ps1`, `-epic-scope.ps1`, `-cleanup.ps1`, `-docs.ps1`, `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `-commands.ps1`, `-bookkeeping.ps1`. The Codex epic-scope file dot-sources `-epic-resolution.ps1` and `-targets.ps1` unguarded, and `hook-target-worktree.ps1`, `hook-epic-fan-in.ps1`, `hook-epic-regeneration.ps1` guarded.
- Byte-identical twins relevant here: `-commands.ps1` (header), `-targets.ps1` (four copies, `enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1`), `-docs.ps1` and `hook-docs-estate-context.ps1` (`hook-docs-estate-context.Parity.Tests.ps1`), `hook-epic-fan-in.ps1`, `hook-epic-regeneration.ps1`, `hook-planner-worktree-removal.ps1` (four-copy hash row in the legacy contracts suite). The two epic-scope files are not byte-identical; only three function definitions are pinned equal (`Get-OrchestrationGateWorktreeList`, `Invoke-OrchestrationGateWorktreeList`, `Get-OrchestrationGateCommandOperandPath`). `Resolve-OrchestrationGateTarget` differs by surface (Claude handles modes and calls `Resolve-WorktreeItemTarget`; Codex handles `apply_patch` markers).
- The gate files keep their function inventories pinned by `enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` (`AC-18 each gate's function names equal the shared set plus its declared per-surface set`).
- Conclusion: the defect lives entirely in `Resolve-OrchestrationGateTarget` and its operand source, which sit in the epic-scope siblings. Neither gate file needs an edit, so the Codex 500-line cap is not touched and no relocation is required.

## 6. Existing Pester suites, seams, and affected tests

Seams: the worktree listing is `Get-OrchestrationGateWorktreeList` (the only listing seam, mocked in every target suite and intercepted by `EpicStateIsolation.Baseline.Helpers.ps1`); checkpoint reads are `Get-CheckpointContent`, `Get-EpicCheckpointContent`, `Get-ParallelCheckpointContent`; `Resolve-OrchestrationGateTarget` is mocked wholesale by several suites. Any suite that binds `-CheckpointRaw` bypasses resolution entirely (`R13` in `...WorktreeResolution.Tests.ps1`), so the shared parity decision table (`...Parity.Cases.ps1`) and the classification suites are unaffected.

Suites that assert current resolution behavior:

| Test | Rows | Disposition under the recommended design |
|---|---|---|
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` | B1-B15 (`Get-OrchestrationGateCommandOperandPath`), T1-T15 | Unchanged: the git function is not modified, relative and outside operands still use the session root (T7, T14), ambiguity and listing rows hold. New rows go in a new test file. |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` | B1-B15, C1-C18 | Unchanged, same reasons; C7/C8 `apply_patch` branch untouched. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` | O4, O5 (command leg), O10 parse-tree scan of the gate, epic-scope, modes, helpers files | Unchanged; O10 must still pass: the new file performs no `Test-Path`/`Get-Content`. Add the new file to O10's file list only if it gains a read (it must not). |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1` | F1 parity of three definitions | Unchanged if `Get-OrchestrationGateCommandOperandPath` stays in both epic-scope files (recommended). Moving it would break F1 ("missing from one surface"). |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 500-line cap, root/bundle hash equality, core-manifest listing of `$script:SharedModuleNames` | Update: add the new Codex sibling to `$script:SharedModuleNames`. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` | AC-17 behavior table, AC-18 gate function inventory | Unchanged (gate files untouched; decision rows inject `-CheckpointRaw`). |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `...Classification.Tests.ps1`, `...TriggerScoping.Tests.ps1`, `...CommandExemption.Tests.ps1`, `...OperandBypass.Tests.ps1` | classification and decisions with injected checkpoints or a mocked `Resolve-OrchestrationGateTarget` | Unchanged; classification is not modified. |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | S1-S6 structural guard rules over the registered hooks' dot-source closure | Must pass: the new dot-source in each epic-scope file uses the single-statement guarded form `try { . (Join-Path $PSScriptRoot '<file>') } catch { Add-HookDependencyFailure -Name '<file>' -ErrorRecord $_ }`. |
| `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` | import failure rows | Review; add a fail-closed row naming the new file (see AC table). |

New contract coverage needed: a four-copy byte-identity row for the new sibling (pattern of `enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` and `hook-docs-estate-context.Parity.Tests.ps1`).

## 7. Bundle mirrors and pack manifests

- Claude bundle: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (header states it is mirrored byte-identically); manifest `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists every `enforce-orchestration-preimplementation-gate*.ps1` sibling and `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`.
- Codex bundle: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`; manifest `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`. `render_manifest` in `scripts/dev_tools/generate_codex_agent_variants.py` only appends agent paths, so hook entries in the Codex `core.json` are hand-maintained and the generator `--check` is unaffected.
- Brief copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and their bundles under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`, `codex-and-agents-customizations/.agents/skills/`, and `customizations/.github/skills/`.
- Contract tests: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` (the new `$PSScriptRoot` dependency of each epic-scope file must be in core), and `test_execution_environment_brief_contracts.py` (`test_brief_copies_are_byte_identical`).

## 8. Execution-environment brief text

The sentence in `## Hook Execution Context` (third bullet) reads: "The preimplementation gate (#1010) resolves the file path of a Write or Edit call and the `-C` values and absolute operands of `git add` and `git commit` through the same resolver, and denies when the worktree listing fails or names no worktree; its delegation checks still resolve by portable identity."

A Grep for that wording across the item worktree finds only the six brief copies and one historical plan (`docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011/plan.2026-10-30T08-09.md`, not to be edited). No test pins the sentence text; `test_brief_copies_are_byte_identical` pins identity across the six copies.

Replacement content (the planner fixes the final wording): after #1188 the gate resolves, through the same resolver, the `-C` values and absolute operands of `git add` and `git commit` and, for every other command it gates, the directory selector (`poetry -C`/`--directory`/`-P`/`--project`, `npm`/`npx` `--prefix`/`-C`, `env -C`/`--chdir`, `pwsh -WorkingDirectory`), the script operand of `sh`/`bash` and `pwsh -File`, and the absolute literal operands; a selector or path-like operand that holds a shell variable or substitution denies with `TARGET_WORKTREE_NOT_DERIVABLE`; relative operands and absolute paths in no registered worktree keep the session root; and it still denies when the listing fails or names no worktree. The `## Command-Text Restrictions` table already prescribes literal `-C <abs>` and `--prefix <abs>` forms, so it needs no change; a short clause can state that the absolute launcher path (`sh <abs worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh <suite>`) is the sibling-worktree test form.

## 9. File-size status

Counts are logical lines read from the item worktree. No touched file is listed in `config/file-size-baseline.json` (Grep for `preimplementation`, `epic-scope`, `HookTargetWorktree`, `hook-target` returns no match).

| File | Lines | Tier status | Recommended change |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 491 | under 500 | none |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | at the Codex 500 test cap | none |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 408 | under 500 | about +6 (guarded dot-source, one call, one unresolved branch) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 468 | under 500; not in the Codex 500-cap list | about +6; stays under 500 |
| `enforce-orchestration-preimplementation-gate-targets.ps1` (four copies) | 433 | under 500 | none |
| `enforce-orchestration-preimplementation-gate-commands.ps1` | 489 | under 500 | none |
| `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` | 391 | under 500 | none |
| New `enforce-orchestration-preimplementation-gate-operands.ps1` | new | target under 300 | new byte-identical sibling |
| `tests/scripts/claude-hooks/...TargetWorktree.Tests.ps1` | 423 | under 500 | none; new rows go in a new suite |
| Execution-environment `SKILL.md` | Markdown | exempt | text edit |

## 10. Recommended design

### Candidate approaches

1. Recommended: a new byte-identical sibling `enforce-orchestration-preimplementation-gate-operands.ps1` in `.claude/hooks/` and `.codex/hooks/` (and both bundles), dot-sourced with the guarded form by each surface's `-epic-scope.ps1`. It defines `Get-OrchestrationGateCommandTargetOperand -Command <text>`, returning `Paths` (string array), `Unresolved` (bool), and `Detail` (string). `Resolve-OrchestrationGateTarget` on each surface replaces its `-CommandOperandPath @(Get-OrchestrationGateCommandOperandPath ...)` argument with the new function's `Paths`, and returns `NoTarget` with the `TARGET_WORKTREE_NOT_DERIVABLE` reason code and the new `Detail` before calling the resolver when `Unresolved` is set. `Get-OrchestrationGateCommandOperandPath` stays where it is, unchanged, and is called by the new function for the staging family. Advantages: neither gate file changes (Codex 500 cap and AC-18 inventory untouched), the existing F1 parity and B-rows stay valid, one implementation serves both surfaces, pure string logic testable without disk or process.
2. Rejected: extend `Get-OrchestrationGateCommandOperandPath` in place. It is duplicated in two files kept equal only by a definition-level parity test, the Codex epic-scope file would approach 500 lines, and the function's name and contract (git add/commit) would no longer describe it.
3. Rejected: switch the gate to `Resolve-AgentTargetWorktree`. It adds prunable filtering and an agent-working-directory source the gate does not have (no payload `cwd` read), changes the resolution contract of every leg, and does not by itself extract runner operands.
4. Rejected: extend `Get-OrchestrationCommandTarget` (epic per-segment targets) in the same change. Its R7 session-root target for non-git segments feeds the epic D2 readiness rule; widening it changes epic-scope decisions for runners and belongs to a separate decision. Recorded as a non-goal.

### Decision rule (`Get-OrchestrationGateCommandTargetOperand`)

1. Staging family: take `Get-OrchestrationGateCommandOperandPath -Command`. Any returned value that fails `Test-CommandLineTokenLiteral` (a shell-variable `-C` value) sets `Unresolved`.
2. Records: iterate `Read-CommandLineInvocationSegment` records. A record is harvested when it, or a payload record beneath it (greater Depth, before the next record of equal or lower Depth), carries a governed word of any stage-1 pattern (whole token through `Test-CommandLineWordPresent`, or the `tests/scripts/` text). A carrying record that is `Unbalanced`, or `Opaque` with `DecodeFailure` or `DepthLimit`, sets `Unresolved`.
3. Prefix walk per harvested record: skip `VAR=value` tokens and the prefixes `env` (standalone `-i`, `-`, `-0`, `-v`, `--ignore-environment`, `--null`, `--debug`; value `-u`, `--unset`; selector `-C`, `--chdir`; split `-S`, `--split-string` sets `Unresolved`), `timeout`, `nohup`, `time`, `command`, `nice`. An unmodelled dash token in a prefix sets `Unresolved`.
4. Host selectors after the prefix walk: `git` global `-C` (from `Get-CommandLineGlobalOption -CommandWord git`, which also gives the arity of every git global option); `poetry` `-C`, `--directory`, `-P`, `--project` (inline `=` and attached `-Cvalue` forms included) with the standalone global options listed in Section 3; `npm` and `npx` `--prefix` and `-C`; `pwsh`/`powershell` `-WorkingDirectory`/`-wd` and the `-File`/`-f` operand; `sh`/`bash`/`zsh`/`dash`/`ksh` script-file operand (the first non-dash token when no `-c` cluster is present). A selector value that is missing or fails `Test-CommandLineTokenLiteral` sets `Unresolved`. An unmodelled dash token in the poetry global options before `run` sets `Unresolved`; for npm, npx, and pwsh the walk scans the whole token list for the selector names instead of stopping.
5. Runner operands: for harvested records whose host is not `git` (git operands come only from rule 1, so commit option values such as `-F <abs>` are never collected, preserving `B12`), collect every bare literal absolute token (pattern `^([A-Za-z]:[\\/]|/)`) that is not a redirection operator or its target and not the value of a selector or of a known value option. A non-literal token that contains `/` or `\` in an operand position sets `Unresolved`.
6. Output: distinct `Paths` in first-seen order (selectors, script operands, absolute operands, staging operands). Relative literals are never added, so a command with only relative operands keeps the session root.

Resolution then runs through `Resolve-HookTargetWorktree` unchanged: all paths in one registered worktree give that worktree; paths in two worktrees, or a worktree plus a path in none, give `TARGET_WORKTREE_AMBIGUOUS`; a lone path in no worktree gives the session root; a listing failure gives `TARGET_WORKTREE_NOT_DERIVABLE`. `Unresolved` denies before any listing or checkpoint read.

Non-goals (unchanged behavior, stated in the plan): the `cd <abs> &&` form; the epic per-segment target rules R0-R7; classification (`Test-ImplementationCommand` and stage 2); the Write/Edit path leg; the delegation leg; prunable-registration filtering.

### Acceptance criteria and Pester rows

The rows run on both surfaces (Claude dot-sources `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`; Codex dot-sources the Codex gate and feeds mapped tool input), with `Get-OrchestrationGateWorktreeList` mocked to an in-memory listing of the session root, `/synthetic-worktrees/w-item`, and `/synthetic-worktrees/w-other`, and `Get-CheckpointContent` mocked per path, as `Set-TargetFixture` already does. The session-root body is empty unless a row states otherwise.

| AC | Behavior | Rows |
|---|---|---|
| AC-1 | `env -u VIRTUAL_ENV poetry -C <item> run pytest <item>/tests/x.py` is admitted against a ready item checkpoint and denied against a not-ready or absent one; the item checkpoint is read once and the session checkpoint never | P1 ready, P2 not ready, P3 absent; repeat with `--directory <item>`, `--directory=<item>`, `-P <item>` |
| AC-2 | `npm --prefix <item> run test:unit`, `npm -C <item> run lint`, and `npx --prefix <item> jest` resolve to the item worktree | N1-N3 ready allow; N4 not-ready deny |
| AC-3 | `sh <item>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` and `env -u VIRTUAL_ENV sh <same> pytest` resolve to the item worktree | L1 ready allow, L2 not-ready deny |
| AC-4 | `pwsh -NoProfile -File <item>/tests/scripts/X.Tests.ps1` and `pwsh -WorkingDirectory <item> -Command "Invoke-Pester -Path tests/scripts"` resolve to the item worktree | W1, W2 |
| AC-5 | `pytest <item>/tests/x.py` with no selector resolves to the item worktree | A1 |
| AC-6 | A shell-variable or substitution selector or path-like operand (`git -C $W add x`, `poetry -C ${W} run pytest`, `npm --prefix $(pwd) run lint`, `sh $W/run-test-suite.sh pytest`, `pytest $W/tests`) denies with `TARGET_WORKTREE_NOT_DERIVABLE` even when the session-root checkpoint is ready, reads no checkpoint, and does not call the listing | V1-V5 |
| AC-7 | Operands in two registered worktrees (`poetry -C <item> run pytest <other>/tests`), or a worktree plus a path in none, deny with `TARGET_WORKTREE_AMBIGUOUS` | M1, M2 |
| AC-8 | Relative selectors and operands (`npm --prefix extensions/drm-copilot run test:unit`, `poetry run pytest tests/x.py`) and a lone absolute path in no registered worktree keep the session-root checkpoint | R1-R3 (session ready allow; item checkpoint never read) |
| AC-9 | A listing failure or empty listing with a runner selector denies `TARGET_WORKTREE_NOT_DERIVABLE` and reads no checkpoint | F1, F2 |
| AC-10 | An unbalanced or undecodable carrying record, a selector with no value, an `env -S` split, and an unmodelled poetry option before the selector deny as unresolvable | U1-U4 |
| AC-11 | Unit rows for `Get-OrchestrationGateCommandTargetOperand` alone: each form's `Paths` and `Unresolved`; redirection targets and `-F <abs>` commit values are not collected; existing B1-B15 rows of both surfaces still pass unchanged | G-rows in a new `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1`; Codex rows in `tests/scripts/codex-hooks/` |
| AC-12 | The new sibling is byte-identical in its four copies; each epic-scope copy equals its bundle copy; the new file is listed in both `core.json` manifests and in `$script:SharedModuleNames` | parity row (new `...-operands.Parity.Tests.ps1`), legacy contracts update, Python push-down contract tests |
| AC-13 | A failed dot-source of the new sibling denies naming the file (fail closed) on both surfaces | I1 (pattern of `T13`/`C16`) |
| AC-14 | Neither gate file changes; the Codex gate stays at 500 lines; the AC-18 inventory and F1 parity rows pass unchanged | existing suites |
| AC-15 | The execution-environment brief states the new resolution in all six byte-identical copies | `test_brief_copies_are_byte_identical`; a wording row may be added to an existing brief contract suite |

## Numeric Derivation Evidence

- Numeric spec.md acceptance criterion: AC-15 requires the brief update in 6 byte-identical execution-environment SKILL.md copies.
- Complete Family: execution-environment SKILL.md
- Exhaustive Search Scope: the entire item worktree repository tree, including extensions/drm-copilot/resources bundles
- Inclusion Rules: a file named SKILL.md inside a folder named execution-environment that carries the brief text
- Exclusion Rules: feature plans, research, and evidence files that quote the sentence
- Primary Search Strategy or Query Expression: enumerate the copy list declared in the brief section Purpose and Maintenance of the canonical execution-environment SKILL.md (three runtime copies plus their bundled copies under extensions/drm-copilot/resources)
- Primary Member Set: .claude/skills/execution-environment/SKILL.md, .agents/skills/execution-environment/SKILL.md, .github/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md
- Primary Count: 6
- Cross-check Search Strategy or Query Expression: Grep content search for the literal text "absolute operands of" across all md, ps1, and py files of the worktree, keeping hits whose path ends in execution-environment SKILL.md
- Cross-check Member Set: .claude/skills/execution-environment/SKILL.md, .agents/skills/execution-environment/SKILL.md, .github/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md
- Cross-check Count: 6
- Member-set Comparison: the normalized primary and cross-check member sets are equal (identical six paths); the seventh Grep hit is the #1011 plan file, excluded by rule.

## Testing Implications

- Every new row is a pure in-memory row: mocked listing seam, mocked checkpoint seam, no file creation, no process, no clock. New logic gets new test files (one per surface plus the parity file) so the existing 423-line Claude target suite does not grow.
- Task checks run the selected files through the launcher `pester` suite with `-TestPath`; the phase gates run the full parallel Pester gate and the pytest gate (for the push-down and brief contract tests), one suite at a time through the launcher. No local integration or golden lane.
- Fail-before proof: AC-1, AC-3, and AC-6 rows fail against the current tree (session root chosen, or `$W` admitted with a ready session root) and pass after the change.
- PowerShell line coverage of the new sibling is measured from the Pester gate (`config/poshqc-coverage.json` covers `.claude/hooks` and `.codex/hooks` as folders, so the new file is in the denominator automatically).

## Automation Feasibility

No human interaction is expected. Every step (helper authoring, Resolve-OrchestrationGateTarget edits on both surfaces, bundle copies, manifest entries, brief text in six copies, Pester and pytest contract runs) is executable by the orchestrator and executor through Write/Edit and the test-execution launcher. Hook behavior on the branch is proven by Pester suites, not by a live isolated subagent, because isolated subagents run the default branch's hook copies (`## Hook Execution Context`). A live non-isolated check from the item worktree is optional evidence, not a gate.

## Pre-Mortem

- Review checklists: a reviewer can flag the new `Unresolved` deny as a behavior change for `git -C $W` with a ready session-root checkpoint, or flag duplicated option tables. Mitigation: the plan records the strengthening as intended (owner directive on shell-variable operands), lists every unchanged row, and cites `test-execution-command-form.ps1` as the source of the prefix and poetry/npm option names with a comment naming it.
- Coverage: the new sibling must reach 85% line coverage on both surfaces. Mitigation: G-rows exercise every branch of the prefix walk, each host, each fail-closed rule, and the redirection skip; the Codex rows dot-source the Codex copy so both copies execute.
- Mirror parity: missing one of the four sibling copies, either epic-scope bundle copy, either `core.json` entry, `$script:SharedModuleNames`, or one of the six brief copies fails the parity, push-down, or brief contract tests. Mitigation: one plan task per surface edits root and bundle together, a parity test pins the four sibling copies, and the brief-update task names all six copies.
- File size: the Codex gate is at its 500-line test cap. Mitigation: no gate file is edited; the Codex epic-scope file grows only by the guarded dot-source and the unresolved branch (stays under 500); all logic goes into the new sibling.
- Test isolation: new suites must not leak script-scope state such as `$script:OrchestrationGateWorktreeListFailed` or mocks across files in a shard. Mitigation: follow the `EpicStateIsolation.Baseline.Helpers.ps1` pattern, register mocks per row, create no files, and confirm with `Invoke-PoshQCLeakScan` in the static job.
- CI-only behavior: the Linux hook-suite job is case-sensitive and has no drive letters. Mitigation: fixtures use `/synthetic-worktrees/...` roots, forward slashes, exact file-name case, and `Join-Path`; Windows-only `C:/` absolute rows are pure string inputs to the helper and never touch the file system.
- Evidence: evidence must be append-only, clock-stamped, and free of absolute paths. Mitigation: evidence files carry `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, record scratch locations as `SCRATCH`, and are never rewritten; fail-before runs are recorded under `evidence/regression-testing/`.
