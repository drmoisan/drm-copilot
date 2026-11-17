# 2026-11-15-preimplementation-gate-wrapped-shell-commands-and-test-rows (Spec)

- **Issue:** #1195
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-15
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug (this file is the only acceptance-criteria source)
- **Research:** `docs/features/active/2026-11-15-preimplementation-gate-wrapped-shell-commands-and-test-rows-1195/research/research.2026-11-15.md` (authoritative on design)

## Context

Two gaps remain in the preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`) after #1188 (PR #1191, merged into `main` as `b58f045bc` and merged into this branch):

1. Part 1. A test or lint command wrapped in a literal shell or PowerShell payload (`sh -c "pytest -q"`, `pwsh -Command "npm run lint"`) is not classified. Stage 1 of `Test-ImplementationCommand` never matches it, so stage 2 is never consulted and the command is allowed without a ready checkpoint.
2. Part 2. #1188 final review finding R3 was accepted as non-blocking deviation DEV-R3 (owner directive OD-2 of #1188). Six regression rows are absent for the cycle-3 guards of the classify sibling; reverted mutants N2, N5, N6, and N7 of those guards fail no existing row.

Environment:
- OS/version: Windows 11 and Linux CI (case-sensitive file system), Claude Code and Codex runtimes
- Python version: not applicable (PowerShell hooks only; hooks never invoke Python)
- Command/flags used: `sh -c "pytest -q"`, `bash -c 'ruff check .'`, `pwsh -Command "npm run lint"`, and the #1188 cycle-3 forms `` echo `npm --version` lint ``, `echo $(echo npm --version) lint`, `FOO=$(echo npx jest) ls`, `FOO=$(echo npm x lint) npm --version`
- Data source or fixture: #1188 records `remediation-inputs.2026-11-15T21-47.md` (Finding R3), `remediation-inputs.2026-11-15T22-11.md` and `feature-audit.2026-11-15T22-11.md` (DEV-R3, recommendation 1)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Repro & Evidence

Steps to Reproduce:
1. From a worktree with no ready checkpoint, call `Test-ImplementationCommand -Command 'sh -c "pytest -q"'` in either gate (or run the command through the hook).
2. Observe that it returns `$false` and the hook allows the command.
3. For Part 2, apply mutant N2, N5, N6, or N7 in memory to `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` and run the classify tables; observe that no row fails.

Expected:
The gate classifies the literal payload of a payload wrapper in the same way it classifies the bare command, with every new stage-1 hit confirmed by stage 2 against the whole command. The policy-level standard of #1160 (decision D18; #1160 OD-1) is kept: deliberately obfuscated or run-time-built payloads stay out of scope. Each of the four unpinned cycle-3 guards has at least one row that fails when the guard is removed.

Actual:
Wrapped commands pass unclassified, and the cycle-3 guards C2 to C5 have no discriminating rows.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: #1188 feature folder `remediation-inputs.2026-11-15T21-47.md` (R3) and PR #1191 (DEV-R3).

## Scope & Non-Goals

- In scope:
  - Part 1: stage-1 classification of a literal payload of `sh`, `bash`, `zsh`, `dash`, `ksh` with `-c` or an option bundle containing `c` (for example `-lc`); `pwsh` and `powershell` with `-c`, a `-Command` prefix of length 4 or more, `-CommandWithArgs`, or `-cwa`; and `eval`. The wrapper may follow the transparent prefixes `env` (with its value options, including `env -u NAME`, `--unset NAME`, `--unset=NAME`, `-C DIR`, `--chdir DIR`, `--chdir=DIR`, other dash tokens, and `NAME=value`), `timeout` (with its duration), `time` (including `time -p`), `command`, `nohup`, and `xargs` (the injected word list is re-examined for a wrapper). Literal nested wrappers are followed to depth 4.
  - The payload text is scanned exactly as a bare command line: each `ScanText` of `Read-CommandLineSegment` over the normalized payload is matched against stage-1 patterns 1 to 4, and `Get-OrchestrationGateSupplementalPatternIndex` (the #1188 supplement) is applied to the payload.
  - Part 2: the six DEV-R3 rows and the reverted-mutant discrimination proof.
  - Brief update in the six execution-environment brief copies and the classify parity wording token.
- Out of scope under #1160 decision D18 (policy-level standard), each pinned by a Negative row so that a later change is deliberate:
  - A payload held in a variable: `sh -c "$CMD"`, `CMD=pytest; sh -c "$CMD"`.
  - An `-EncodedCommand` payload (any encoded-command flag: `-e`, `-ec`, or a prefix of `-encodedcommand` of length 3 or more): `pwsh -EncodedCommand <base64 of UTF-16LE "pytest">`.
  - A payload built at run time: `sh -c "$(cat cmd.txt)"`.
  - The `env -S` / `--split-string` split string: `env -S "sh -c 'pytest'"` style forms are declined by the new function (D17 already treats them as unmodelled). A split string whose governed word is preceded by whitespace (`env -S 'sh -c pytest'`) is already classified by the outer raw scan and stays classified.
- Non-goals (recorded with rationale; pinned by Negative rows per Decision D-6):
  - `powershell -Command "Invoke-Pester"` and `powershell -File tests/scripts/...`: pattern 4 names `pwsh` only, and the same gap exists for the bare top-level command, so closing it is a pattern-vocabulary change, not a wrapper change.
  - `cmd /c "pytest"`: `cmd` is an evaluator outside the issue's wrapper list and is not a payload wrapper in the shared payload model.
  - A quote-adjacent command word after a non-payload transparent wrapper (`timeout 60 "pytest"`): there is no payload; the quoting is on the command word itself, which is outside the wrapper defect.
  - `bash -c -- "pytest"`: `Get-CommandLineWrapperPayload` takes the `--` token as the payload; changing that would edit the shared payload module used by many hooks.
- Explicitly excluded systems, integrations, or datasets:
  - Stage 2 (`Test-OrchestrationGateInvocationConfirmed` in `enforce-orchestration-preimplementation-gate-commands.ps1`) is not changed.
  - Shared scanner and payload modules (`hook-command-scanner.ps1`, `hook-command-payload.ps1`, `hook-command-payload-powershell.ps1`, `hook-command-invocation.ps1`, `hook-command-invocation-operands.ps1`, `hook-command-heredoc.ps1`) are not changed.
  - The five stage-1 pattern literals and the index-0 structural staging check are not changed.
  - The operands sibling (target-worktree resolution) is not changed.

## Root Cause Analysis

The gap is in stage 1 only; the issue text "wrapper payloads are opaque strings" is accurate for stage 1 but not for stage 2.

- Stage 1 (`Test-ImplementationCommand`) matches five patterns, each anchored by `(^|\s)`, against `@(Read-CommandLineSegment -CommandText $normalizedCommand).ScanText`. For a wrapper-led segment `ScanText` is the raw text, so in `sh -c "pytest -q"` the word `pytest` is preceded by `"` and pattern 1 does not match. No hit is produced and stage 2 is never called.
- Forms in which the governed word is preceded by whitespace inside the payload (`sh -c "poetry run pytest"`, `sh -c "cd x && npm run lint"`), `pwsh ... Invoke-Pester` anchored on the outer `pwsh`, and payload `git add`/`git commit` through the structural check are already classified and are not the defect.
- Stage 2 already expands literal wrapper payloads through `Read-CommandLineInvocationSegment` (depth 4) and confirms a payload record that carries a governed word and is not a mention host. Payload extraction therefore exists; stage 1 simply never applies its patterns to an extracted payload.
- Additional extraction limit: `Skip-CommandLineTransparentWrapper` does not skip the value of `env -u NAME`, so for `env -u VIRTUAL_ENV bash -c "pytest"` no payload is found. This is the form the brief prescribes for Poetry and pytest in agent worktrees, so the new function handles `env` value options locally.
- Part 2 root cause: #1188 cycle 3 added guards C2 (backtick arm of the unclosed-substitution member filter, `Get-OrchestrationGateJoinedWordText`), C3 (member-tail match), C4 (member `npm` word check), and C5 (member `npx` word check) in `Get-OrchestrationGateSupplementalPatternIndex` without rows that exercise them; reverted mutants N2, N5, N6, and N7 respectively fail no row.

## Proposed Fix

### Design summary (what changes where):

Research design C.

1. Add a pure function `Get-OrchestrationGateWrappedPatternIndex -CommandText <string> -Pattern <string[]>` to the existing classify sibling `enforce-orchestration-preimplementation-gate-classify.ps1`. It returns the ascending, de-duplicated subset of indexes 1, 2, 3, 4 for which some literal payload text P (at nesting depth 1 to 4) satisfies either: some `ScanText` of `Read-CommandLineSegment -CommandText (ConvertTo-CommandLineNormalizedText P)` matches `Pattern[index]`, or `Get-OrchestrationGateSupplementalPatternIndex -CommandText P` contains the index. Index 0 is never returned.
2. In both gates, change the one existing line `$supplementalIndex = @(Get-OrchestrationGateSupplementalPatternIndex -CommandText $normalizedCommand)` to
   `$supplementalIndex = @(Get-OrchestrationGateSupplementalPatternIndex -CommandText $normalizedCommand) + @(Get-OrchestrationGateWrappedPatternIndex -CommandText $normalizedCommand -Pattern $implementationCommandPatterns)`.
   No line is added to either gate.
3. Every index contributed by the new function feeds the existing stage-1 loop, which still calls stage 2 against the whole command; a hit that stage 2 drops (mention host, modelled non-host consumer) stays unclassified.
4. Add the six DEV-R3 rows to the existing classify tables, and new wrapped-payload tables to the same Cases file.
5. Copy the edited classify sibling to its three mirrors and each edited gate to its bundle copy; update the brief in six copies.

### Boundaries and invariants to preserve:

- Stage 2 judges the whole command for every new hit (D16, D17, D19 unchanged).
- The five stage-1 pattern literals, the loop order (index 0 first), and the index-0 bookkeeping exemption are unchanged.
- The five cycle-3 guards C1 to C5 in the classify sibling stay byte-unchanged (Part 1 adds code; it does not edit `Get-OrchestrationGateJoinedWordText` or the member loop of `Get-OrchestrationGateSupplementalPatternIndex`).
- The classify sibling stays byte-identical in `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
- The classify sibling keeps its header contract: pure string logic, no dot-source, no `$PSScriptRoot` dependency (manifest dependency closure unchanged).
- No existing test row changes disposition.
- No new sibling file, no new dot-source, no manifest entry, no `$script:SharedModuleNames` entry.

### Dependencies or blocked work:

- #1188 / PR #1191 is merged into `main` and `main` is merged into this branch (prerequisite satisfied). The planner confirms at the merge base that the classify sibling, both gates, and the Cases file equal the text the research read.
- The item route must be `large` (or another batch-budget-exempt route): the change touches more than three production PowerShell files (classify copies and gate copies).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

| File | Change |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` and its mirrors `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` | Add `Get-OrchestrationGateWrappedPatternIndex` and at most one private helper (env value-option skip and encoded-flag predicate); update `.DESCRIPTION` to state the wrapped-payload form and the D18 exclusions. Stays at or below 500 lines (the bound pinned by the classify parity test). |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, and their bundle copies under `extensions/drm-copilot/resources/` | Replace the `$supplementalIndex` line only. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` | Add the six R3 rows to `$script:ClassifyFunctionRows` and `$script:ClassifyGateRows`; add new tables `$script:ClassifyWrappedFunctionRows` (Name, Command, Indexes) and `$script:ClassifyWrappedGateRows` (Kind, Command, Expected); update the header comment to define both new tables. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` | One `It ... -ForEach` per new table on each surface. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1` | Add wording token `#1195` to the brief wording row. |
| The six execution-environment brief copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | Replace the sentence "no command is newly classified; issue #1188 later classifies exactly two further forms ..." in the #1160 bullet of `## Hook Execution Context` with text that also states the #1195 wrapped-payload form, the function name, stage-2 confirmation, and the D18 exclusions; optionally extend the #1188 classify bullet with one clause. |

#### Functions/classes/CLI commands impacted:

- New: `Get-OrchestrationGateWrappedPatternIndex` (classify sibling).
- Changed call site: `Test-ImplementationCommand` in both gates (one line each).
- Consumed unchanged: `Read-CommandLineSegment`, `ConvertTo-CommandLineNormalizedText`, `Split-CommandLinePosixWord`, `Get-CommandLineWrapperPayload`, `Get-OrchestrationGateSupplementalPatternIndex`, `Test-OrchestrationGateInvocationConfirmed`. These are available at call time because the gate dot-sources the shared modules before the classify sibling is invoked; the classify sibling itself dot-sources nothing.

#### Data flow and validation changes:

Payload enumeration in `Get-OrchestrationGateWrappedPatternIndex`:

1. Return an empty array for empty or whitespace input.
2. For each segment of `Read-CommandLineSegment` over the normalized text, split the segment token text with `Split-CommandLinePosixWord`.
3. Strip leading transparent prefixes. For `env`, skip `-u NAME`, `--unset NAME`, `--unset=NAME`, `-C DIR`, `--chdir DIR`, `--chdir=DIR`, other dash tokens, and `NAME=value`; decline the segment when an `env` split-string option (`-S`, `--split-string`, `--split-string=...`) is present.
4. Call `Get-CommandLineWrapperPayload -Word <remaining words>`. Accept `Kind` `Posix` (sh family `-c`, `eval`) and `Kind` `PowerShell` that is not Opaque and whose host flags contain no encoded-command flag (the same predicate the commands sibling uses). For `Kind` `Words` (xargs), re-examine the injected word list for a wrapper. Decline everything else.
5. For an accepted payload P at depth d (d = 1 for a wrapper at the top level), collect the indexes matched by P as described in the design summary, then recurse into P with depth d + 1 while d < 4.
6. Return the ascending distinct union of collected indexes in 1 to 4.

A payload is literal when it is taken directly from a quoted or unquoted word of the command text. A payload that is a variable expansion or a substitution is not interpreted; the variable or substitution text itself is what gets scanned, which carries no governed command word for the D18 rows.

#### Error handling and logging updates:

- The function has no I/O and raises no errors on malformed input; an unbalanced or unparseable segment yields no payload and contributes no index.
- A dot-source failure of the classify sibling already denies with `PREIMPLEMENTATION_GATE_BLOCKED:` naming the file (row I2 on both surfaces); this is unchanged and must keep passing.
- No logging change.

#### Rollback/feature-flag considerations (if applicable):

No flag. Rollback is reverting the gate line on both runtimes (the function then has no caller) or reverting the commit.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- `Get-OrchestrationGateWrappedPatternIndex`
  - `-CommandText` `[string]`, mandatory, empty string allowed.
  - `-Pattern` `[string[]]`, mandatory; the gate's own `$implementationCommandPatterns` array (indexes 0 to 4). The function reads indexes 1 to 4 only.
  - Output: `[int[]]`, ascending, distinct, subset of 1, 2, 3, 4; empty when no literal payload matches.
- Gate contract: `Test-ImplementationCommand -Command <string>` returns `[bool]`; its signature is unchanged.

#### Required configuration keys and defaults:

None. The depth limit 4 is a constant matching `Read-CommandLineInvocationSegment`.

#### Backward-compatibility expectations:

- Every command classified today stays classified (the union only adds indexes).
- Every command unclassified today stays unclassified unless it carries a literal payload whose scan matches pattern 1 to 4 and stage 2 confirms the hit.
- A newly classified wrapped command follows the same downstream gate path as the bare command (checkpoint readiness and #1188 target-worktree resolution).

#### Performance constraints (latency/throughput/memory):

- The function performs string work only, bounded by depth 4 and the number of segments. No process, file, or network access is added to the hook.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access): the branch contains #1188 at merge `b58f045bc`; the shared scanner and payload functions keep their current signatures.
- Constraints (budget, performance, compatibility): PowerShell 7+; no new Python, and hooks never invoke Python; file-size tiers (Codex gate and its siblings under the 500-line cap enforced by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`; the classify sibling under its pinned 500 bound; every file at or below 800 lines); large route for the PowerShell batch budget.
- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact

- User-facing or API changes: agents that ran test or lint commands through a literal wrapper without a ready checkpoint are now denied with the existing preimplementation-gate reason, as for the bare command.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): the brief text in `## Hook Execution Context` changes in six copies; no CI job, required context, tool route, or batch-budget rule changes.

## Test Strategy

Seeded from issue:

- [ ] Classify the literal `sh -c "<payload>"`, `bash -c`, and `pwsh -Command "<payload>"` / `-c` payloads with the existing stage-two rules, in both the Claude and Codex gates, plus the bundles
- [ ] Add the six missing R3 regression rows; each one must fail when its check is removed
- [ ] Pester rows for wrapped test, lint and allowed commands, including the obfuscated forms that stay out of scope

- Regression tests to add or update (all rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1`, consumed by the Claude and Codex classify `Tests.ps1` files):
  - `$script:ClassifyWrappedGateRows`, Kind `Positive` (false before, true after): `sh -c "pytest -q"`; `bash -c 'ruff check .'`; `bash -lc "pyright"`; `sh -c "npm run lint"`; `bash -c "npx jest"`; `pwsh -Command "npm run lint"`; `pwsh -NoProfile -c "pytest"`; `powershell -Command "npx eslint ."`; `pwsh -CommandWithArgs "pytest"`; `eval "pytest"`; `env -u VIRTUAL_ENV bash -c "pytest"`; `timeout 600 sh -c 'npx jest'`; `echo x | xargs sh -c 'pytest'`; `bash -c "bash -c 'pytest'"`; `bash -c "pwsh -File tests/scripts/x.Tests.ps1"`; `sh -c "npm --prefix $(pwd) run lint"`.
  - `$script:ClassifyWrappedGateRows`, Kind `Negative` (false before and after): mentions `sh -c "echo 'pytest'"`, `bash -c "grep -rn 'ruff' docs/"`, `pwsh -c "Write-Output 'npm run lint'"`, `echo "sh -c 'pytest'"`; D18 exclusions `sh -c "$CMD"`, `CMD=pytest; sh -c "$CMD"`, `pwsh -EncodedCommand cAB5AHQAZQBzAHQA` (recomputed by the planner with `[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes('pytest'))` before use), `sh -c "$(cat cmd.txt)"`, `env -S "sh -c 'pytest'"`; non-goals `powershell -Command "Invoke-Pester"`, `cmd /c "pytest"`, `timeout 60 "pytest"`, `bash -c -- "pytest"`.
  - `$script:ClassifyWrappedGateRows`, Kind `Control` (true before and after): `sh -c "poetry run pytest"`; `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"`; `bash -c 'git add .'`; `sh -c "cd x && npm run lint"`.
  - `$script:ClassifyWrappedFunctionRows` (Name, Command, Indexes), one row per branch of the new function: plain `sh -c` (index 1), option bundle `-lc`, `pwsh -Command` prefix, `-CommandWithArgs` / `-cwa`, `eval`, `env -u NAME`, `env --unset=NAME`, `env -C DIR`, `env -S` declined (`@()`), encoded-command flag declined (`@()`), xargs injected words, `timeout`/`time -p`/`command`/`nohup` prefixes, nested payload at depth 4 (index returned), nested payload at depth 5 (`@()`), payload matched only through the #1188 supplement (`sh -c "npm --prefix $(pwd) run lint"`, index 2), masked mention in a payload (`@()`), variable payload (`@()`), segment with no wrapper (`@()`), and empty command (`@()`).
  - R3 rows in `$script:ClassifyFunctionRows` and `$script:ClassifyGateRows` (see Part 2 acceptance criteria).
- Unit tests (Pester 6.x) for the fixed behavior and boundaries: the classify `Tests.ps1` files on both surfaces, one `It -ForEach` per new table, using the existing BeforeAll isolation (no temporary files, no clock, no process or network access).
- Edge cases and negative scenarios: the Negative and Control rows above; depth boundary 4/5; empty and whitespace input; unbalanced payload quote.
- Error handling and logging verification: row I2 (classify dot-source failure denies naming the file) passes on both surfaces.
- Coverage impact and targets for changed lines/modules: classify sibling line coverage at least 85% (target 100%, as on #1188) read per file from `artifacts/pester/powershell-coverage.xml` of the parallel gate run; no changed executable line at zero hits.
- Toolchain commands to run (format, lint, test; type checking is not applicable to PowerShell): PoshQC format, PoshQC analyze, then Pester. Task checks run `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <paths>`; phase gates and the final QA loop run one parallel `Invoke-PoshQCParallelTest` through the launcher. No serial, single-process, shuffled, or reversed runs; test-order dependence is a violation to fix, not to work around.
- Contract suites: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `scripts/dev_tools/generate_codex_agent_variants.py --check`, the classify, commands, and gate `Parity.Tests.ps1` files, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`. These existing Python test suites are run, not extended.
- Manual validation steps (if required): none beyond the evidence below.

Evidence (append-only, clock-read UTC timestamps, repository-relative paths only, scratch recorded as `SCRATCH`):
- Fail-before: `<FEATURE>/evidence/regression-testing/`, the new wrapped gate rows run against the pre-change hooks.
- R3 mutant discrimination: `<FEATURE>/evidence/regression-testing/`, the in-memory probe command and per-mutant result.

## Acceptance Criteria

Part 1: wrapped payload classification

- [x] AC-1: `Get-OrchestrationGateWrappedPatternIndex` exists in `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` with parameters `-CommandText [string]` and `-Pattern [string[]]` and returns an ascending distinct subset of 1, 2, 3, 4; every `$script:ClassifyWrappedFunctionRows` row passes on both `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1`.
- [x] AC-2: every Kind `Positive` row of `$script:ClassifyWrappedGateRows` (covering `sh`, `bash` bundle `-lc`, `pwsh -Command`, `pwsh -c`, `pwsh -CommandWithArgs`, `powershell -Command`, `eval`, `env -u VIRTUAL_ENV`, `timeout`, `xargs`, nested `bash -c`, a nested `pwsh -File tests/scripts/...`, and a #1188-supplement form inside a payload) returns `$true` from `Test-ImplementationCommand` on both surfaces.
- [x] AC-3: fail-before evidence under `<FEATURE>/evidence/regression-testing/` shows each Kind `Positive` wrapped gate row returning `$false` against the pre-change hooks and each Kind `Negative` and `Control` wrapped gate row returning its expected value before the change; the record carries the command run, a clock-read UTC timestamp, and the per-row result.
- [x] AC-4: every Kind `Negative` row of `$script:ClassifyWrappedGateRows` returns `$false` on both surfaces, including the mention rows, each D18 exclusion (variable payload, assignment-then-variable payload, `-EncodedCommand`, run-time-built payload, `env -S`), and each recorded non-goal (`powershell -Command "Invoke-Pester"`, `cmd /c "pytest"`, `timeout 60 "pytest"`, `bash -c -- "pytest"`).
- [x] AC-5: every Kind `Control` row of `$script:ClassifyWrappedGateRows` returns `$true` on both surfaces.
- [x] AC-6: in each of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, the diff against the merge base changes only the `$supplementalIndex` assignment line, to the union with `Get-OrchestrationGateWrappedPatternIndex -CommandText $normalizedCommand -Pattern $implementationCommandPatterns`; neither gate's logical line count increases, and the Codex gate passes the 500-line row of `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
- [x] AC-7: `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, the stage-1 pattern literals in `$implementationCommandPatterns`, and the shared modules `hook-command-scanner.ps1`, `hook-command-payload.ps1`, `hook-command-payload-powershell.ps1`, `hook-command-invocation.ps1`, `hook-command-invocation-operands.ps1`, and `hook-command-heredoc.ps1` are unchanged against the merge base on both runtimes and in the bundles.
- [x] AC-8: no existing row changes disposition: the full shared Classification table (`enforce-orchestration-preimplementation-gate.Classification.Cases.ps1`, including FP-16, FP-17, NG-08, NG-09), the existing `$script:ClassifyFunctionRows` and `$script:ClassifyGateRows` rows, the commands, Modelled, and TriggerScoping suites, and `hook-command-consumers.Issue824.Tests.ps1` pass on both surfaces with no row text or expected value edited.
- [x] AC-9: the classify sibling is byte-identical in `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1` passes (including its 500-line bound); each gate's bundle copy equals its source, and the push-down resource-contract, pack-manifest completeness, and dependency-closure suites and the Codex generator `--check` pass.
- [x] AC-10: no new file is added under any `hooks/` directory, no dot-source line is added to either gate, and no pack-manifest or `$script:SharedModuleNames` entry is added.
- [x] AC-11: row I2 (classify dot-source failure denies naming the file) passes on both surfaces, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` passes.

Part 2: DEV-R3 rows

- [x] AC-12: `$script:ClassifyFunctionRows` contains a row with `Indexes = @()` for each of these commands, and each passes on both surfaces: `` echo `npm --version` lint `` (pins C2), `echo $(echo npm --version) lint` (pins C4), `FOO=$(echo npx jest) ls` (pins C5), `FOO=$(echo npm x lint) npm --version` (pins C3).
- [x] AC-13: `$script:ClassifyGateRows` contains Kind `Negative` rows with `Expected = $false` for each of these commands, and each passes on both surfaces: `` echo `npm --version` lint `` and `echo $(echo npm --version) lint`.
- [x] AC-14: evidence under `<FEATURE>/evidence/regression-testing/` records an in-memory reverted-mutant probe run against the final classify text (after Part 1), with its command and a clock-read UTC timestamp, showing that each of N2 (backtick arm of the member filter removed), N5 (npm pattern matched against the whole run text instead of the member tail), N6 (member `npm` word check removed), and N7 (member `npx` word check removed) fails at least one of the rows added under AC-12 and AC-13, and that the unmutated control fails none; the probe creates no temporary file inside the test suite and writes nothing outside `SCRATCH` and the evidence folder.
- [x] AC-15: the cycle-3 guards (the unclosed-substitution member filter in `Get-OrchestrationGateJoinedWordText` and the member-tail match and member `npm`/`npx` word checks in `Get-OrchestrationGateSupplementalPatternIndex`) are byte-unchanged against the merge base.

Cross-cutting

- [x] AC-16: the `## Hook Execution Context` section of the execution-environment brief states that issue #1195 classifies a literal payload of the sh family `-c`, `pwsh`/`powershell -c`/`-Command`/`-CommandWithArgs`, and `eval` (after `env` with value options, `timeout`, `time`, `command`, `nohup`, or `xargs`) as the bare command through `Get-OrchestrationGateWrappedPatternIndex`, with every hit confirmed by stage 2, and that `-EncodedCommand`, variable-held, and run-time-built payloads stay out of scope (D18); the sentence "no command is newly classified" no longer stands unqualified; the text is byte-identical in `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, and `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`; the classify parity wording row pins the token `#1195`.
- [x] AC-17: the classify sibling `.DESCRIPTION` states the wrapped-payload form and the D18 exclusions, and the Cases file header defines `$script:ClassifyWrappedFunctionRows` and `$script:ClassifyWrappedGateRows`.
- [x] AC-18: `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` reports at least 85% line coverage in `artifacts/pester/powershell-coverage.xml` from the parallel phase-gate Pester run, and no changed executable line in it has zero hits.
- [x] AC-19: every changed file is at or below 800 logical lines; the classify sibling is at or below 500 lines; any changed file at or above 700 lines is reported as an advisory warning in the plan.
- [x] AC-20: the full PowerShell toolchain (PoshQC format, PoshQC analyze with zero findings, parallel Pester run) passes in a single pass with no file changed by the formatter, and CI on the PR head succeeds, including the Linux hook-suite job.

## Decisions

- D-1 (design): adopt research design C (pure function in the classify sibling, unioned into `$supplementalIndex`). Rationale: zero gate line growth (the Codex gate must not grow), stage 2 keeps whole-command context, and no new file means no manifest, shared-module, or parity overhead. Rejected: widening the `(^|\s)` anchor (newly classifies unrelated raw-scanned commands such as a `gh` command with a quoted governed word after a live substitution, and edits pinned pattern literals); recursing `Test-ImplementationCommand` on payloads (loses D16/D17 pipeline context, needs gate lines); a new sibling file (overhead without behavioral benefit).
- D-2 (env value options): handle `env -u NAME` and the other `env` value options inside the new function instead of editing `Skip-CommandLineTransparentWrapper`. Rationale: the shared payload module is used by many hooks across surfaces and sits near its size limit; local handling is contained. `env -u VIRTUAL_ENV ...` is the brief-prescribed form, so it is an ordinary invocation that must be covered.
- D-3 (index 0 excluded): the new function never returns index 0. Rationale: the structural staging check already sees payload `git add`/`git commit` (rows ED-14, ED-15, ED-23), and the index-0 bookkeeping exemption must not be evaluated on a fragment.
- D-4 (separate tables): the wrapped rows live in new tables `$script:ClassifyWrappedFunctionRows` and `$script:ClassifyWrappedGateRows`, while the six R3 rows go into the existing `$script:ClassifyFunctionRows` and `$script:ClassifyGateRows`. Rationale: the existing function-table header defines `Indexes` as a subset of 2 and 3 (supplement only), which the wrapped function does not satisfy; the R3 rows test the supplement and belong with it, matching the #1188 fix text.
- D-5 (no wrapped R3 variants as Negative rows): wrapped forms of the R3 mentions (for example `sh -c 'echo $(echo npm --version) lint'`) are already classified on `main` through the raw wrapper segment, so they cannot discriminate and are not added as Negative rows. No gate row is added for the R3-3 and R3-4 commands because a top-level segment already matches at stage 1 with or without the guard.
- D-6 (pin non-goals): each recorded non-goal is pinned by a Negative row in addition to the D18 exclusions. Rationale: makes a later change to those forms deliberate and visible; the research traced each as false before and after.
- D-7 (depth): nesting depth is counted from 1 for the payload of a top-level wrapper and is limited to 4, matching `Read-CommandLineInvocationSegment`; the depth-5 function row expects `@()`.
- D-8 (row kind correction): if fail-before evidence shows a proposed Positive wrapped gate row already returns `$true` before the change, the planner moves it to Kind `Control`, records the observed result in the fail-before evidence, and keeps at least one Positive row per wrapper family; if a proposed Negative or Control row does not hold its expected value before the change, the planner records it and drops or corrects the row rather than changing the expected value to match the new behavior.
- D-9 (parity token): add `#1195` to the classify parity wording row. Rationale: pins the brief update in all six copies through an existing test rather than by inspection only.
- D-10 (`powershell` vocabulary): `powershell -Command "Invoke-Pester"` stays unclassified. Rationale: the gap is in pattern 4 vocabulary and also exists for the bare top-level command; closing it belongs to a pattern change, not to this wrapper fix.
- D-11 (route): the item runs on the `large` route because the change touches more than three production PowerShell files.
- D-12 (no numeric assertions in acceptance criteria): the research record's `## Numeric Derivation Evidence` limits each claim to named feature-folder records and files and does not declare an exhaustive repository search scope. The acceptance criteria therefore assert no count or total. Each criterion names its members (commands, mutants, file paths) individually, so verification checks each named member rather than a population size. The counts in the narrative sections (Context, Scope, Proposed Fix) are descriptive and are not acceptance criteria.

## Risks & Mitigations

- Technical or operational risks:
  - A new hit that stage 2 should drop is confirmed, denying an unrelated command. Mitigation: Negative mention rows and the unchanged shared Classification table on both surfaces (AC-4, AC-8).
  - Part 1 edits the file whose guards Part 2 pins. Mitigation: AC-15 byte-unchanged guards; AC-14 probe runs against the final text.
  - Uncovered branches (env options, encoded flag, xargs, depth limit) drop coverage below 85%. Mitigation: one function row per branch; per-file figure from the gate run (AC-18).
  - Mirror drift across classify copies, gate bundle copies, or brief copies. Mitigation: one copy task after the edit and the parity and push-down contract suites (AC-9, AC-16).
  - Linux-only failures. Mitigation: rows carry no drive letters or backslash paths; the base64 literal is ASCII; file-name case is exact; CI hook-suite job (AC-20).
- Mitigations and rollbacks: revert the gate line on both runtimes or revert the commit.

## Rollout & Follow-up

- Release/rollout steps: merge via PR; the bundle copies ship with the next extension build. Hooks fired for isolated subagents use the default branch scripts, so the change applies to them after merge.
- Post-fix monitoring or clean-up tasks: none planned. A `powershell` pattern-4 vocabulary change (D-10) is not filed by this spec.
- Links: issue #1195; #1188 / PR #1191 (DEV-R3); #1160 (D16 to D19, OD-1); research `research/research.2026-11-15.md`.
