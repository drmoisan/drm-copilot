# 2026-11-09-preimplementation-gate-false-positives (Spec)

- **Issue:** #1160
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09T21-55
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source)
- **Design source:** `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/research/research.2026-11-09T21-40.md`
- **Authoritative scope:** `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/issue.md`

## Context

- The orchestration pre-implementation gate denies two classes of calls that do not begin implementation work:
  1. **Staging false positive.** `git add` and `git commit` of agent-memory files in a coordinator checkout that holds no orchestrator checkpoint are denied. Operators fall back to git plumbing commands to record agent memory.
  2. **Keyword false positive.** A test-runner, formatter, linter, or type-checker word that appears only as an operand (inside a process listing, a grep pattern, a package lookup, or a `pwsh -Command` filter expression) causes the call to be classified as implementation and denied.
- Observed environment: a multi-feature epic with five features running in parallel on one shared development machine (owner report, 2026-11-09). Both surfaces are affected: the Claude gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`) and the Codex gate (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`), and their pushed-down bundle copies.
- Impact: coordinator sessions cannot commit agent memory through porcelain commands, and diagnostic commands (process inspection, code search) are denied while a feature is not yet ready. Severity is operational: no data loss, but repeated denials and plumbing workarounds in every parallel run.
- First observed: 2026-11-09, on the current `main` hook payload.

## Repro & Evidence

All reproductions are deterministic and require no checkpoint (single-feature branch, `Test-OrchestrationReady` false).

### False positive 1: agent-memory staging in a checkpoint-less coordinator checkout

- Input: a `git add` whose only pathspec operand is a file under `.claude/agent-memory/`, with the session root at a checkout that has no `artifacts/orchestration/orchestrator-state.json`.
- Actual: denied with the generic final text `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.`
- Also denied by the same path: a pathless `git commit -m <message>` whose staged index holds only agent-memory files, and `git commit -F <file> -- <agent-memory path>`.
- Expected: allowed, because the paths are bookkeeping and not implementation.

### False positive 2: runner word as an operand

- Inputs that are denied today and must be allowed: `ps aux | grep pytest`, `ps -ef | grep -i pytest`, `pgrep -f pytest`, `Get-Process -Name pytest`, `git log --grep pytest`, `git grep black`, `which pytest`, `Get-Command pytest`, `poetry show pytest`, `pip show black`, `npm ls prettier`, `echo git add docs`, and `pwsh -NoProfile -Command "Get-Process | Where-Object { $_.CommandLine -match 'Invoke-Pester' }"`. The complete list is research section 6.3.
- Actual: denied with the generic final text above.
- Expected: allowed; none of these invokes a runner or stages files.
- Not reproduced today (word quoted or not whitespace-preceded): `grep 'pytest'` forms and `-like *pytest*` filters. These remain allowed.

## Scope & Non-Goals

- In scope:
  - Command classification in `Test-ImplementationCommand` on both surfaces (stage-2 structural confirmation of regex hits).
  - A new allow-side bookkeeping staging leg at the final single-feature deny on both surfaces.
  - An optional configuration file `config/preimplementation-gate.json` (`bookkeeping_roots`), its parser, validation, default, and documentation.
  - Regression tests for both false-positive classes and for every existing denial, on both surfaces.
  - Push-down payload consistency (bundle copies and both `core.json` pack manifests) and documentation updates.
- Out of scope / non-goals:
  - Widening classification. The D2 declared non-goals (below) remain unclassified, as today.
  - Epic-scope decisions (#663, #1136, #1141), delegation modes, the path leg, and the NoTarget and Ambiguous denies.
  - Write and Edit of non-Markdown files under `.claude/agent-memory/` (the issue scopes staging and committing only; Markdown is already not an implementation extension).
  - Session-root and target resolution (issue #1163) and hook consolidation (issue #1159).
- Explicitly excluded systems: the shared hook-command scanner, invocation, and payload matchers; the #539 helpers file; the targets, cleanup, epic-scope, and modes siblings; `hook-epic-fan-in.ps1`; the worktree-resolution modules; hook registrations in `.claude/settings.json` and `.codex/config.toml`.

## Root Cause Analysis

Confirmed by reading both gate files and their siblings (research sections 2.3 to 2.7).

### Command classification (false positive 2)

- `Test-ImplementationCommand` computes `ScanText` for each segment through `Read-CommandLineSegment` (`hook-command-scanner.ps1`). `ScanText` is the masked text (quoted spans and heredoc bodies blanked), or the raw text when the segment is unbalanced, has a live substitution, or is led by a member of `$script:CommandLineWrapperNames` (`sh`, `bash`, `zsh`, `dash`, `ksh`, `pwsh`, `powershell`, `xargs`, `env`, `command`, `eval`, `nohup`, `time`, `timeout`).
- Five regular expressions are applied to every `ScanText` element: `git add|commit`; `(poetry run) black|ruff|pyright|pytest`; `npm ... prettier|lint|typecheck|test:unit`; `npx prettier|eslint|tsc|jest`; `pwsh ... Invoke-Pester|tests/scripts/`.
- Any hit on the four runner patterns returns implementation. Only the staging pattern can be cleared, and only by the #539 exemption. The patterns do not distinguish a command word from an operand, so an unquoted runner word in any non-wrapper segment matches (`ps aux | grep pytest`), and a wrapper-led segment is scanned raw, so a filter expression inside `pwsh -Command` matches.
- The regex half of the staging pattern also matches an unquoted mention such as `echo git add docs`.

### Staging exemption (false positive 1)

- Structural staging detection (`Test-CommandLineInvocation` in `hook-command-invocation.ps1`) is correct: a `git add` or `git commit` is a real staging invocation.
- The only staging exemption on the classification path is the #539 orchestration-bookkeeping exemption, `Test-ExemptOrchestrationStagingCommand` (in `enforce-orchestration-preimplementation-gate-helpers.ps1`), through `Test-ExemptOrchestrationSegmentToken` and `Test-ExemptOrchestrationOperand`. It covers the trees `docs/features/epics/`, `docs/features/parallel/`, `docs/features/active/`, `docs/features/potential/`, and `artifacts/orchestration/`. It does not cover `.claude/agent-memory/`, it requires at least one pathspec operand (so a pathless `git commit` is never exempt), and its option table models only `-m`, `--message`, and `--trailer` (so `-F` is denied).
- With no checkpoint, `Read-OrchestrationGateCheckpoint` returns empty content, `ConvertFrom-CheckpointJson` throws on the empty argument, the error is caught, and `Test-OrchestrationReady` returns false. The #1026 cleanup leg (`Get-OrchestrationCleanupContextResult`) requires `git -C <absolute> add|commit` and does not apply. The call reaches the final single-feature deny.

### Affected components

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`: `Test-ImplementationCommand` and `Invoke-OrchestrationPreimplementationGateDecision`.
- Their bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
- Twin differences (unchanged by this fix): the Codex `Test-ImplementationCommand` adds apply_patch marker loops ahead of the patterns; the Codex decision function allows an empty `ToolInputRaw`, throws on malformed JSON, reads `Get-StringProperty`, passes `-AllowPatchManifest` to the cleanup leg, and has no entry-point wrapper. These are declared divergences in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1`.

## Decisions

All decisions below are adopted. Each restates the research decision of the same number with a one-line rationale.

- **D1. Tokenizer reuse.** Keep the stage-1 regex scan as a candidate filter and add a gate-local stage-2 structural confirmation over `Read-CommandLineInvocationSegment` records (using `Skip-CommandLineTransparentWrapper`, `ConvertTo-CommandLineLeafWord`, `Test-CommandLineWordPresent`, and `Get-CommandLineInvocation` for git); do not edit the shared `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `hook-command-invocation-operands.ps1`, `hook-command-payload.ps1`, `hook-command-payload-powershell.ps1`, or `hook-command-heredoc.ps1`.
  - Rationale: stage 1 guarantees the change only removes classifications, and the shared matchers are byte-identical, pinned, and used by other gates.
- **D2. Scope of "real invocation" (negative model).** A stage-1 hit stands unless every occurrence of the governed word is an operand of a known non-executing mention host; evaluator and opaque-shell fallbacks confirm the hit; unmodelled launchers stay denied.
  - Rationale: the negative model fails closed for any launcher it does not know (`conda run`, `hatch run`, `coverage run -m`, `tox`) while clearing both reported classes.
  - Stage-2 rule. A regex hit is confirmed (classified) unless all of the following hold:
    1. No iterator record is Unbalanced, Opaque with `DecodeFailure` or `DepthLimit`, or an Opaque `NoPayload` shell wrapper (a shell reading stdin, a shell fed a heredoc, or `pwsh -File`) while its own raw text or the whole normalized text carries a governed word.
    2. No record's command word is an evaluator (`Invoke-Expression`, `iex`, `Invoke-Command`, `icm`, `Start-Process`, `saps`, `start`, `cmd`, `cmd.exe`, `source`, `.`; `eval` is already expanded by the iterator) while the whole normalized text carries a governed word.
    3. Every record that carries the governed word as a whole token (for the `pwsh` pattern: `Invoke-Pester` as a whole token or the substring `tests/scripts/`) is either led by a mention host with no executing option, or is a PowerShell non-command expression record whose text contains neither `::` nor `.Invoke`.
  - Mention-host table (data with a getter, pinned by test):

    | Group | Hosts | Executing-option exclusions |
    |---|---|---|
    | Search | `grep`, `egrep`, `fgrep`, `rg`, `ag`, `ack`, `findstr`, `Select-String`, `sls` | `rg` is not a host when any token starts with `--pre` |
    | Process | `ps`, `pgrep`, `pidof`, `pkill`, `kill`, `killall`, `tasklist`, `taskkill`, `Get-Process`, `gps`, `Stop-Process`, `Get-CimInstance`, `gcim`, `Get-WmiObject` | none |
    | Output | `echo`, `printf`, `Write-Output`, `Write-Host`, `Write-Verbose` | none |
    | Read and filter | `cat`, `Get-Content`, `head`, `tail`, `less`, `more`, `wc`, `sort`, `uniq`, `Where-Object`, `Select-Object`, `Sort-Object`, `Measure-Object`, `Format-Table`, `Format-List`, `Out-String`, `Get-ChildItem`, `Test-Path` | none |
    | Lookup | `which`, `where`, `where.exe`, `type`, `Get-Command`, `gcm` | none |
    | Subcommand-scoped | `git` with `grep`, `log`, `show`, `diff`, `blame`, `ls-files`, `status`; `npm` with `ls`, `list`, `view`, `info`, `show`, `outdated`, `explain`, `why`, `search`, `help`; `pip` and `pip3` with `show`, `list`, `freeze`; `poetry` with `show`, `search` | `git` is not a host with `-O` or `--open-files-in-pager` |
    | Not hosts | `ForEach-Object`, `find` | can execute their arguments |

  - Declared non-goals (no widening; these remain unclassified, as today): `.venv/bin/pytest`, `npx --yes jest`, `node run-jest.cjs`, `npm test`, bare `Invoke-Pester` on Codex, `Invoke-PoshQCParallelTest`, and `sh <launcher>.sh`.
- **D3. Staging token-awareness.** Keep structural staging detection (`Test-CommandLineInvocation`, Indeterminate treated as a match) as a direct classifier; only the regex half of the staging check receives stage-2 confirmation.
  - Rationale: this clears `echo git add docs` while `echo git add . | bash` still denies through the opaque-shell fallback.
- **D4. Bookkeeping exemption placement.** The bookkeeping exemption is a new allow-side leg evaluated only at the final single-feature deny (after the #1026 cleanup leg), reusing `Get-EpicFanInAllowance`.
  - Rationale: pathless commits need a staged-index read, which is I/O and must follow target resolution, and the #539 helpers file is byte-pinned and size-bounded.
- **D5. Composition with the #539 exemption.** The leg predicate is the union of the five #539 trees and the declared roots, active only when the declared roots are non-empty; the #539 classification-time exemption is untouched; each declared widening is pinned by a test row.
  - Rationale: "alongside" in the issue requires mixed commands that combine #539-tree and declared-root paths to pass.
  - Declared widenings (allowed only when the leg is enabled; denied today): a pathless `git commit` whose staged index holds only #539-tree paths; `git commit -F <file>` or `--file <file>` with `-- <#539-tree paths>`.
- **D6. Configuration.** Optional `config/preimplementation-gate.json`, key `bookkeeping_roots`, `schema_version` 1; built-in default `[".claude/agent-memory/"]`; `[]` restores today's behavior exactly; an invalid file disables the leg and appends the `BOOKKEEPING_CONFIG_INVALID` suffix; the file is read relative to `$PSScriptRoot` through an injected seam.
  - Rationale: `$PSScriptRoot`-relative reading is independent of session-root resolution (#1163), and the same relative path serves `.claude/hooks` and `.codex/hooks`.
- **D7. Unparseable command.** An unparseable command keeps today's fail-closed behavior and deny text.
  - Rationale: Unbalanced records are already Indeterminate staging, stage 2 confirms any hit on Unbalanced or opaque records, and the leg denies unresolvable text through `Get-EpicFanInAllowance`.
- **D8. Codex parity.** The identical change is made on the Claude and Codex gates; all new logic lives in two new byte-identical siblings, `enforce-orchestration-preimplementation-gate-commands.ps1` (stage 2 and the mention-host table) and `enforce-orchestration-preimplementation-gate-bookkeeping.ps1` (configuration parser, configuration seam, root helper, and leg), with four copies each (`.claude/hooks`, `.codex/hooks`, and both bundles), loaded by guarded dot-source.
  - Rationale: the parity-pinned gate function inventory (`$script:SharedGateFunction`) does not change, and `hook-dependency-guard-completeness.Tests.ps1` is satisfied by the guarded form.
- **D9. Interaction with #1163 and #1159.** Do not edit the `-epic-scope`, `-targets`, `-cleanup`, `-helpers`, or `-modes` siblings, the worktree-resolution files, `hook-epic-fan-in.ps1`, or the `hook-command-` matcher files; derive the staged-index root from the `Path` returned by `Read-OrchestrationGateCheckpoint`; the gate stays a standalone registered hook with no settings or registration change; shared files are re-read at execution start.
  - Rationale: the fix composes with sibling #1163 in either merge order, and #1159 can absorb the standalone hook later without a registration conflict.
- **D10. Test strategy.** A data-only classification corpus run on both surfaces; a unit suite per new sibling; four-copy parity tests; mocked seams for the staged index and the configuration text; no temporary files; a parallel-only Pester gate.
  - Rationale: the decision function is pure behind injected seams, so every row is deterministic and host-neutral.
- **D11. Documentation.** One `## Hook Execution Context` bullet in all six execution-environment `SKILL.md` copies; one paragraph in `## Pre-Implementation Gate` of `.agents/skills/orchestrate/SKILL.md` and its bundle copy; gate header comments.
  - Rationale: the issue requires documenting changed behavior and the new key. The `.claude` orchestrate skill and its bundle copy have no `## Pre-Implementation Gate` section (confirmed by search), so no paragraph is added there.
- **D12. Configuration file not committed.** `config/preimplementation-gate.json` is not committed; the built-in default applies when it is absent, so a push-down never overwrites a destination's own file; the key and schema are documented.
  - Rationale: the default lives in code, and destinations keep control of their own override.
- **D13. Default carries agent memory.** The built-in default is `[".claude/agent-memory/"]`, a deliberate behavior change requested by the issue's acceptance criteria; the issue's General Constraints permit a non-preserving default "unless this entry states otherwise"; `[]` is the documented opt-out.
  - Rationale: an empty default would leave the reported defect in every destination.
- **D14. Declared-root anchor and selector check (recorded 2026-11-10 at execution, supersedes the D5 declared widenings).** The leg allows a command only when at least one path it names, or, for a pathless commit, at least one path of the staged index, lies under a declared root; every other path must still lie under the union of the five #539 trees and the declared roots. A command carrying a `-C` worktree selector is admitted by the leg only when `Test-ExemptOrchestrationSelector` (helpers file, called and not edited) accepts that selector. The two D5 declared widenings (a pathless commit whose index holds only #539-tree paths; `git commit -F <file>` or `--file <file>` with `-- <#539-tree paths>` only) are withdrawn and keep today's deny text.
  - Rationale: the P1-T1 shared-file re-read (`evidence/other/shared-file-reread.2026-11-10T03-52.md`) found that the D5 widenings and the leg's `-C` shape rule flip existing deny rows in `enforce-orchestration-preimplementation-gate.MergedFollowUp.Tests.ps1`, `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, and their Codex twins, which AC-9 and AC-17 require to pass without modification. Anchoring the leg on a declared root leaves #539-tree-only commands under the unchanged #539 exemption, keeps the mixed agent-memory and #539-tree case of the issue ("alongside"), and keeps every existing suite unmodified. The selector check closes the same gap for a command that also names a declared-root path.
- **D15. Evaluator and `::` existing-denial rows (recorded 2026-11-10 at execution).** The AC-2 rows `pwsh -c "Invoke-Expression 'pytest'"` and `pwsh -c "[Diagnostics.Process]::Start('pytest')"` are replaced in AC-2 and the existing-denial table by `pwsh -c "Invoke-Expression 'Invoke-Pester'"` and `pwsh -c "[Diagnostics.Process]::Start('tests/scripts/run.ps1')"`, which stage-1 pattern `(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)` classifies today on both surfaces and which the evaluator and `::` fallbacks of AC-4 must keep classified. The two original rows are recorded in the declared non-goal table as unclassified today and unchanged.
  - Rationale: the execution probe (`evidence/other/corpus-classification-probe.2026-11-10T04-23.md`) found that today's gate does not classify the two original rows on either surface, because `pytest` follows a single quote and no stage-1 pattern matches; research sections 4.1 and 6.2 stated otherwise. Making them classified would widen stage 1, which D1 and AC-3 prohibit, so AC-2 was unsatisfiable as worded.
- **D16. Pipeline consumers (recorded 2026-11-13 at remediation, amends the D2 stage-2 rule and table).** A fourth confirmation is added to the D2 stage-2 rule: a stage-1 hit is confirmed when a record that does not carry the governed word is a pipeline consumer of a carrying record and is not an accepted consumer.
  - Pipeline consumer. A record R that follows a carrying record C in record order at the same `Depth`, with no record of lower `Depth` between them; records of greater `Depth`, which are nested payloads, are skipped. For a `Posix` C, every same-depth record from C up to the record before R ended with the `|` delimiter, so `;`, `&&`, `||`, and `&` end the pipeline. For a `PowerShell` C, every later record of the same payload qualifies, because PowerShell payload records carry no pipeline delimiter (fail-closed).
  - Accepted consumer. R is led (after transparent wrappers) by a mention host under the same lookup that rule 3 uses, with no executing option, or R is a PowerShell non-command expression record whose text contains neither `::` nor `.Invoke`. Every other consumer confirms: `ForEach-Object`, `%`, `foreach`, an evaluator, a call-operator record, `xargs`, `env`, any wrapper, a mention host carrying an executing option, and any unmodelled command word.
  - Table changes. `NotHost` becomes `ForEach-Object`, `%`, `foreach`, `find`, and is read: a command word in `NotHost` is never a host even when a host group lists it, in rule 3 and in the consumer check alike. `ExecutingOption` gains `sort` with `--compress-program`, after `rg` and `git`.
  - Rationale: stage 2 judged each record alone and skipped every record that did not carry the governed word, so in `Get-Command pytest | ForEach-Object { & $_ }` and `echo pytest | xargs env` the executing stage was never examined (review finding F1, remediation cycle 2). An accepted-consumer rule keeps the D2 negative model: an enumerated list of executing consumers would reopen the finding for any unlisted executor (`Invoke-Item`, `parallel`). Stage 1 is unchanged and D16 only adds confirmations, so the classified set lies between the head set and the merge-base set: no widening (AC-3), and every row on which head and merge base agree keeps its value. In FP-01, FP-02, FP-15, FP-16, and FP-17 the carrying record is the last stage of its pipeline or is followed only by an accepted consumer; the other FP rows have no pipeline, so all 17 stay unclassified.
  - Cost. A PowerShell payload with a later unrelated statement (`Get-Command pytest; Get-Date`) is classified, as it is at the merge base.
  - AC reading. AC-2's existing-denial table includes rows ED-43 to ED-50 (the seven F1 probe commands and `sort --compress-program pytest big.txt`); AC-5's "D2 table" is the D2 table as amended by D16. No AC text changes.
- **D17. Closed modelled-command rule (recorded 2026-11-14 at remediation, amends the D2 stage-2 rule, the D2 table, and decision D16).** Where rules 1 to 5 (D2, D16) would drop a stage-1 hit, the hit is dropped only when all three conditions below hold; otherwise it is confirmed. Stage 2 is a policy-level control, not a security control, and any construct whose meaning the model does not decode keeps the hit classified.
  - Conditions. (1) Modelled: the normalized command text, every modelled Posix payload, and every PowerShell payload consist only of the allowlisted constructs below. (2) Operand: every record carrying a governed word is a mention-host record (rule 3 lookup), a modelled payload wrapper whose payload carries the word, or a PowerShell expression record inside the scriptblock argument of a mention-host command. (3) Pipeline mates: every non-carrying record of the same pipeline as a carrying record, before or after it, is an accepted consumer (D16 definition); for Posix the pipeline is the maximal run of same-depth records joined by `|`, skipping deeper payload records and ended by a lower-depth record; for PowerShell every record of the same payload qualifies (fail-closed, as in D16).
  - Posix allowlist (quote-aware scan of the text after `ConvertTo-CommandLineNormalizedText`): unquoted words, `'...'`, `"..."` without `$(` or a backtick inside, backslash escapes, unquoted `$name` operands, and the standalone `{}` word that normalization quotes; the separators `|`, `;`, `&&`, `||`, and newline; the transparent wrappers `env`, `timeout`, `time`, `command`, `nohup` (for `env`, only without a split-string option); the payload wrappers `sh`, `bash`, `zsh`, `dash`, `ksh` with a `-c` flag whose payload is the last word, `pwsh` or `powershell` with `-c` or a `-Command` prefix, or with `-CommandWithArgs`, `-cwa`, or an `-EncodedCommand` form whose payload is the last word, and `xargs` with its injected command, each re-derived through `Get-CommandLineWrapperPayload`; and the mention hosts of the table with their operands.
  - Unmodelled (keeps the hit): any unquoted `(`, `)`, `{`, `}`, `<`, `>`, backtick, `#`, or `&` outside `&&` (groups, substitutions, process substitution, here-document, here-string, redirection, background job, comment, function definition, array assignment); ANSI-C quoting (an unquoted `$` immediately followed by `'`); `$(` or a backtick inside double quotes; a backslash in the raw command text immediately followed by LF or CR LF; a `$_` expansion, unquoted or inside double quotes, in the normalized command text or in any modelled Posix payload at any depth, when that text or payload has more than one record at its own top depth (a `$_` in the only top-depth record, as in FP-16, stays modelled, and a PowerShell payload's `$_` is judged by the PowerShell allowlist); a record whose first token or command word is a reserved word (`if`, `then`, `else`, `elif`, `fi`, `case`, `esac`, `for`, `select`, `while`, `until`, `do`, `done`, `function`, `!`, `[[`, `]]`, `coproc`), `eval`, `source`, `.`, or a shell-state builtin (`alias`, `unalias`, `hash`, `enable`, `builtin`, `exec`, `trap`, `set`, `shopt`, `export`, `declare`, `typeset`, `readonly`, `local`, `unset`, and `printf` with a `-v` option, separate or attached as `-vNAME`); an `env` option before the command word that is `-S...`, a short-option bundle containing `S`, or a prefix of `--split-string` from `--s` on (the env split-string option); an assignment word `NAME=value` anywhere, including after `env`; a wrapper word after its payload; and every Opaque or Unbalanced record.
  - PowerShell allowlist (AST from `[System.Management.Automation.Language.Parser]::ParseInput`, which never executes): `ScriptBlockAst` with only an unnamed end block, `NamedBlockAst`, `PipelineAst`, `CommandAst` with a constant name, no `&` or `.` operator, and no redirection, `CommandParameterAst`, `StringConstantExpressionAst`, `ConstantExpressionAst`, `ExpandableStringExpressionAst`, `VariableExpressionAst`, non-static `MemberExpressionAst` with a constant member, `UnaryExpressionAst`, `BinaryExpressionAst`, `CommandExpressionAst`, and `ScriptBlockExpressionAst` only as an element of a mention-host `CommandAst` (its body judged by the same list). A `CommandExpressionAst` outside such a scriptblock must not carry a governed word. Every other node type, a parse error, assignment, method call, static member, type literal, array, hashtable, subexpression, function, and control flow, is unmodelled.
  - Mention-host executing options. `Test-OrchestrationGateMentionHostRecord` also treats a long option as executing when its nonempty name (the text after `--` and before any `=`) is a prefix of the name of an executing long option of that host (GNU abbreviation, for example `sort --compress`), and, for `git`, treats a single-dash token (not `--`) whose option letters contain the uppercase `O` (ordinal) as the executing `-O` option (`git grep -iOpytest pytest`). `Get-OrchestrationGateMentionHostTable` changes in one entry: `ExecutingOption.rg` becomes `--pre`, `--hostname-bin` (`rg --hostname-bin pytest x`); every other group, set, and entry is unchanged.
  - Placement. Four functions in `enforce-orchestration-preimplementation-gate-commands.ps1`: `Test-OrchestrationGatePosixTextModelled`, `Test-OrchestrationGatePowerShellPayloadModelled`, `Test-OrchestrationGateCommandModelled`, and `Test-OrchestrationGateAcceptedConsumer` (shared by the forward D16 walk and a new backward walk). `Test-OrchestrationGateInvocationConfirmed` evaluates D17 only where it would otherwise return `$false`, so rules 1 to 5 keep their order.
  - Bound and cost. Stage 1 is unchanged and D17 and the abbreviation check only add confirmations, so the classified set lies between the head set and the merge-base set (AC-3), and every row on which head and merge base agree keeps its value. A mention with a redirection (`2>&1`), comment, background job, assignment word, compound command, line continuation, or PowerShell assignment or method call stays classified, as at the merge base.
  - N1. A redirection hand-off (`echo pytest > f; xargs env < f`) is now classified; a hand-off through a host's own file option across statements (`grep -o pytest x | sort -o f; xargs -a f env`), or through state left by an earlier call, stays outside the model.
  - FP analysis. No FP row contains an unmodelled construct; the stages before the carrier in FP-01 and FP-02 are `ps`, in FP-16 `Get-Process`; FP-16's scriptblock is the argument of the host `Where-Object` and holds only a variable, a member access, a constant, and `-match`, and its `$_` sits in its only depth-0 record; FP-07's `--grep` is no prefix of `--open-files-in-pager`, and no FP row carries a `git` token with an uppercase `O` bundle or an `rg` long option, so all 17 stay unclassified.
  - Rows. ED-51 to ED-66 are the sixteen F2 probe commands of review 2; ED-67 to ED-85 are the construct classes (here-string, here-document, command and backtick substitution, `eval`, PowerShell function, array, redirection, and method call, redirection, background job, word after payload, function definition, array assignment, comment, compound command, stage before the carrier, assignment word, shell-state builtin); ED-86 to ED-93 are ANSI-C quoting, `$_` across records, `printf -v`, a backslash before a newline, and the env split-string option; ED-94 to ED-96 are a `$_` inside a wrapper payload, a `git` bundle with `O`, and `rg --hostname-bin`. Each is unclassified at the cycle 2 head and classified at the merge base.
  - AC reading. AC-2's existing-denial table includes ED-51 to ED-96; AC-4's fallbacks include the D17 classes; AC-5's "D2 table" is the D2 table as amended by D16 and D17. No AC text changes.
- **D18. Deliberately obfuscated commands are a non-goal (recorded 2026-11-14 at remediation, owner directive OD-1 of 2026-11-14).** Deliberately obfuscated commands are out of scope for stage 2, because the gate is a policy-level control and not a security boundary. A later finding that is only a further obfuscation variant is dispositioned out of scope rather than remediated; an ordinary, non-obfuscated invocation that stage 2 misclassifies is still a defect. The commands sibling header and the #1160 bullet of the execution-environment brief carry the sentence: "Deliberately obfuscated commands are out of scope (decision D18): a later finding that is only a further obfuscation variant is dispositioned out of scope, while a misclassified ordinary invocation remains a defect."
- **D19. Subcommand position (recorded 2026-11-14 at remediation, amends the D2 subcommand-scoped row and the D17 FP analysis).** A subcommand-scoped host is a mention host only when its listed subcommand is the token immediately after its command word. Closes review finding F3 of remediation cycle 3 for the whole class, under the policy-level review standard of owner directive OD-1 (decision D18).
  - Cause. The subcommand loop of `Test-OrchestrationGateMentionHostRecord` took the first later token that does not start with `-` as the subcommand. The value of a value-taking global option is such a token, so `npm -w search run lint` read `search` as the subcommand and dropped the hit. Which options take a value differs per tool and release, so skipping option values from a list would reopen the finding for any unlisted option.
  - Rule. A subcommand-scoped host (`git`, `npm`, `pip`, `pip3`, `poetry`: every key of `Subcommand` in `Get-OrchestrationGateMentionHostTable`) is a mention host only when the token immediately after its command word, after transparent-wrapper removal (`Skip-CommandLineTransparentWrapper`), is a listed subcommand (ordinal, as before). Any token before the subcommand (a flag-only option, a value-taking option in separate or attached `=value` form, or its value) keeps the hit classified. No listed subcommand starts with `-`, so the rule needs no option test. The executing-option scan of the same function, `Get-OrchestrationGateMentionHostTable`, and every other rule are unchanged.
  - Class covered. Every subcommand-scoped host of the table, with each value-taking global option in ordinary use whose value can equal a listed subcommand: `npm -w`, `--workspace`, `--prefix`, `--loglevel`; `poetry -C`, `--directory`, `-P`, `--project`; `pip` and `pip3` `--cache-dir`, `--log`; `git -C`, `--git-dir`, `--work-tree` (rows ED-97 to ED-116, each unclassified at the cycle 3 head and classified at the merge base). `git -c` is not a row: its value has the form `name=value` and never equals a subcommand. Attached `=value` forms already resolved to a non-listed word at the cycle 3 head; rows ED-117 to ED-120 pin them so a fix that strips only separate values cannot pass.
  - Bound and cost. Stage 1 is unchanged and D19 only turns host records into non-host records, which only adds confirmations through rule 3, the D16 consumer walk, and the D17 operand and pipeline-mate conditions; the classified set lies between the head set and the merge-base set (AC-3 holds), and every row on which head and merge base agree keeps its value. Cost: a mention through a subcommand-scoped host with any option before its subcommand is classified, as at the merge base: `git --no-pager log --grep pytest`, `npm --silent ls prettier`, `pip -q show black`, `poetry --no-ansi show pytest`.
  - FP analysis. The subcommand-scoped FP rows FP-07 (`git log`), FP-08 (`git grep`), FP-11 (`poetry show`), FP-12 (`pip show`), and FP-13 (`npm ls`) carry the subcommand directly after the command word; no other FP row is led by a subcommand-scoped host; all 17 stay unclassified. NG-01 to NG-09 miss stage 1. ED-01 to ED-96 stay classified.
  - AC reading. AC-2's existing-denial table includes ED-97 to ED-120; AC-5's D2 table is unchanged in data (only its lookup changes). No AC text changes.

## Proposed Fix

### Design summary (what changes where):

- **Classification.** `Test-ImplementationCommand` keeps its five patterns and `$isStaging` (stage 1). When a pattern hits (including the regex half of the staging pattern while `$isStaging` is false), it calls a stage-2 function in `enforce-orchestration-preimplementation-gate-commands.ps1` that applies the D2 rule over `Read-CommandLineInvocationSegment` records. A command with no stage-1 hit remains unclassified. Structural staging classifies and then consults the #539 exemption, as today.
- **Bookkeeping leg.** `Invoke-OrchestrationPreimplementationGateDecision` calls `Get-OrchestrationBookkeepingStagingResult` (in `enforce-orchestration-preimplementation-gate-bookkeeping.ps1`) in the single-feature branch after the cleanup leg and before the final deny, only when the command is non-empty and is not apply_patch text. The leg delegates to `Get-EpicFanInAllowance` with a scope object `{ Checkpoint = $null; WorktreeRoot = <root> }`, the staged-index reader `Get-OrchestrationGateStagedIndex`, and a path and operand predicate over the effective roots built with `Test-EpicMergedFeaturePath`.
- **Configuration.** `Get-OrchestrationGateBookkeepingConfigText` (I/O seam) reads `config/preimplementation-gate.json` relative to `$PSScriptRoot` and returns `$null` when absent. `ConvertFrom-OrchestrationGateBookkeepingConfig` (pure) returns `Valid`, `Roots`, and `Detail`.

### Boundaries and invariants to preserve:

- Stage 1 is unchanged: the set of commands classified after the change is a subset of the set classified before it.
- Every existing denial (research section 6.2) still denies with byte-identical deny text on both surfaces.
- The #539 exemption, the #1026 cleanup leg and its `DenySuffix`, epic scope, delegation modes, the path leg, and the NoTarget and Ambiguous denies are unchanged.
- Decision order (research section 6.1): classification (stage 1, stage 2), structural staging and #539, declared-checkpoint check, epic scope, mode branch, read and resolve, readiness, cleanup leg, bookkeeping leg, final deny with the cleanup suffix followed by the configuration suffix.
- Claude and Codex decisions are identical for every corpus row; the declared twin divergences are unchanged.

### Dependencies or blocked work:

- Sibling #1163 (session-root and target resolution) may modify `Read-OrchestrationGateCheckpoint` and the epic-scope, cleanup, and worktree-resolution files. This fix edits none of them. If #1163 merges first and exposes a resolved root on the read result, the leg uses that root instead of the suffix strip.
- #1159 (hook consolidation) can absorb the gate later; no registration change is made here.
- Shared files named in D9 are re-read at execution start, because a concurrent merge can change them.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Modified production files:

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`

Changes in each: the `Test-ImplementationCommand` body, two guarded dot-source lines, one bookkeeping-leg call line in the decision function, and the header comment. The edits are kept contiguous to limit merge conflicts.

New production files (byte-identical within each sibling):

- `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`
- `.claude/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1`

Pack manifests (dependency closure):

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (hook entries are hand-maintained; a hand edit must match the `json.dumps(indent=2)` formatting produced by `scripts/dev_tools/generate_codex_agent_variants.py`)

Documentation:

- `.claude/skills/execution-environment/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`
- `.agents/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`

New test files:

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (data-only corpus: existing-denial rows, false-positive rows, declared non-goal rows, bookkeeping-leg rows, D5 widening rows)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Tests.ps1` (Claude runner over the corpus)
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classification.Tests.ps1` (Codex runner over the same corpus)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1` (unit suite for the commands sibling, run against the `.claude/hooks` and `.codex/hooks` copies through `-ForEach`)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Parity.Tests.ps1` (byte identity and line bound across the four copies)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-bookkeeping.Tests.ps1` (unit suite for the bookkeeping sibling, run against the `.claude/hooks` and `.codex/hooks` copies through `-ForEach`)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-bookkeeping.Parity.Tests.ps1` (byte identity and line bound across the four copies)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.BookkeepingLeg.Tests.ps1` (Claude decision-level leg tests)
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-bookkeeping-leg.Tests.ps1` (Codex decision-level leg tests)

#### Files not to modify:

- `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, and their bundle copies
- `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`, and their bundle copies
- `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1`, and their bundle copies
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, and their bundle copies
- `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, and their bundle copies
- `.claude/hooks/hook-epic-fan-in.ps1`, `.codex/hooks/hook-epic-fan-in.ps1`, and their bundle copies
- `.claude/hooks/hook-cleanup-context.ps1`, `.codex/hooks/hook-cleanup-context.ps1`, and their bundle copies
- `.claude/hooks/hook-command-scanner.ps1`, `.claude/hooks/hook-command-invocation.ps1`, `.claude/hooks/hook-command-invocation-operands.ps1`, `.claude/hooks/hook-command-payload.ps1`, `.claude/hooks/hook-command-payload-powershell.ps1`, `.claude/hooks/hook-command-heredoc.ps1`, and their `.codex/hooks` and bundle copies
- `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`, `.codex/hooks/hook-target-worktree.ps1`, and their bundle copies
- `.claude/settings.json`, `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`, `.codex/config.toml` (no registration change)
- `config/preimplementation-gate.json` is not created (D12)

#### Functions/classes/CLI commands impacted:

- Modified: `Test-ImplementationCommand`, `Invoke-OrchestrationPreimplementationGateDecision` (both surfaces).
- New, in the commands sibling: the stage-2 confirmation function and the mention-host table getter.
- New, in the bookkeeping sibling: `Get-OrchestrationGateBookkeepingConfigText` (seam), `ConvertFrom-OrchestrationGateBookkeepingConfig` (pure parser), the root helper that normalizes `\` to `/` and strips the suffix `/artifacts/orchestration/orchestrator-state.json` (ordinal, case-insensitive) from the checkpoint read path, and `Get-OrchestrationBookkeepingStagingResult` (leg).
- Reused unchanged: `Read-CommandLineSegment`, `Read-CommandLineInvocationSegment`, `Skip-CommandLineTransparentWrapper`, `ConvertTo-CommandLineLeafWord`, `Test-CommandLineWordPresent`, `Get-CommandLineInvocation`, `Test-CommandLineInvocation`, `Test-ExemptOrchestrationStagingCommand`, `Split-OrchestrationCommandLine`, `Test-OrchestrationCommandTextUnresolvable`, `Get-EpicFanInAllowance`, `Test-EpicMergedFeaturePath`, `Get-OrchestrationGateStagedIndex`, `Read-OrchestrationGateCheckpoint`.

#### Data flow and validation changes:

- Leg shape rules (inherited from `Get-EpicFanInAllowance` and `Get-EpicFanInShapeDetail`): every segment split on `;`, `&`, `|`, CR, or LF must be `git [-C <absolute>] add [--] <paths>` or `git [-C <absolute>] commit` with only `-m`, `--message`, `-F`, `--file`, or `--trailer` (each with a separate value), followed by nothing or by `-- <paths>`.
- Path rules (inherited from `Test-EpicMergedFeaturePath`): every path lies strictly under an effective root (a path equal to a root is rejected) and carries no backslash, `*`, `?`, `[`, `.` or `..` segment, or leading `/`.
- Pathless commit: the staged index read through `Get-OrchestrationGateStagedIndex` must exit 0, be non-empty and NUL-terminated, and name only paths under the effective roots. A commit with `-- <paths>` needs no index read.
- Root resolution: when `-CheckpointRaw` was injected (no read happened) or the read path does not end with the checkpoint suffix, the root is `$null`, and a pathless commit is denied. A pathspec-only call does not need the root.
- Known limitation: in `git add <path> && git commit -m <message>` the index is read before the add runs; the commit is allowed only when the pre-existing index is already non-empty and entirely bookkeeping. The documented alternative is `git commit -m <message> -- <path>` or two calls.

#### Error handling and logging updates:

- Dependency loading: both new siblings are dot-sourced with `try { . <sibling> } catch { Add-HookDependencyFailure ... }`; a load failure denies with the existing `PREIMPLEMENTATION_GATE_BLOCKED:` dependency-failure text.
- Invalid configuration: the leg is disabled and the final deny text gains the suffix ` Bookkeeping leg not applied: BOOKKEEPING_CONFIG_INVALID: <detail>.`, placed after the #1026 cleanup suffix. With an absent or valid file the suffix is absent.
- Deny text is otherwise unchanged when the leg does not apply.

#### Rollback/feature-flag considerations (if applicable):

- A destination can restore today's staging behavior by committing `config/preimplementation-gate.json` with `"bookkeeping_roots": []`.
- Code rollback is a revert of the PR; the change adds no state, registration, or migration.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- `Get-OrchestrationBookkeepingStagingResult -Command <string> -CheckpointPath <string or empty> [-ConfigReader <scriptblock>] [-StagedIndexReader <scriptblock>]` returns an object with an allow flag and a deny-suffix string (empty unless the configuration is invalid).
- `ConvertFrom-OrchestrationGateBookkeepingConfig -Text <string>` returns `Valid` (bool), `Roots` (string array), and `Detail` (string).

#### Required configuration keys and defaults:

- File: `config/preimplementation-gate.json` (optional; not committed in this repository).
- Schema: a JSON object with exactly the keys `schema_version` (integer `1`) and `bookkeeping_roots` (array of strings).
- Entry validation: each entry matches `^[A-Za-z0-9._/-]+/$`, does not start with `/`, contains no `//`, and contains no `.` or `..` segment. Duplicate entries and unknown top-level keys are rejected.
- Semantics: file absent uses the built-in default `[".claude/agent-memory/"]`; a valid file's list replaces the default; `[]` disables the leg (today's behavior); an invalid file disables the leg and appends the `BOOKKEEPING_CONFIG_INVALID` suffix.

#### Backward-compatibility expectations:

- With `"bookkeeping_roots": []`, every gate decision and deny text equals today's.
- With the default, the only staging decisions that change are the bookkeeping-leg allows (the D5 declared widenings are withdrawn by D14).
- Classification changes only by removing false-positive classifications (stage 1 is a superset filter).

#### Performance constraints (latency/throughput/memory):

- Stage 2 runs only on a stage-1 hit and reuses in-process parsers; it starts no child process. The leg performs at most one staged-index read (existing seam) and one configuration read per denied single-feature call. No timing assertion is added.

## Assumptions, Constraints, Dependencies

- Assumptions: the helpers, targets, cleanup, `hook-epic-fan-in.ps1`, and `hook-command-` matcher files are byte-identical across their copies, as their headers state and their parity suites assert; this is re-confirmed at execution start.
- Constraints:
  - Hook logic is PowerShell only. No new Python file, and the enforcement hook path does not invoke Python.
  - The helpers file is pinned to a 500-line bound and is not edited. Each new sibling stays below 500 logical lines. The Codex gate file approaches the 500-line guidance tier; no gate fails below 801 lines.
  - Batch budget: bundle copies count as production PowerShell files, so the item runs on the orchestrated `large` route.
- External dependencies: none beyond Pester 6.x and the existing push-down contract tests.

## Data / API / Config Impact

- User-facing changes: fewer false denials; agent-memory staging and committing allowed by default in checkpoint-less checkouts.
- Data or migration considerations: none.
- Logging/telemetry: the `BOOKKEEPING_CONFIG_INVALID` deny suffix is the only new diagnostic.
- Compatibility notes: new optional configuration key `bookkeeping_roots` with `schema_version` 1, documented in the execution-environment brief and the bookkeeping sibling header.

## Test Strategy

- Regression tests to add: the classification corpus (`enforce-orchestration-preimplementation-gate.Classification.Cases.ps1`) with tables for existing denials (research 6.2, expected classified, deny text unchanged), false positives (research 6.3, expected unclassified), declared non-goals (D2, expected unclassified), bookkeeping-leg rows (research 6.4), and D5 widening rows. The Claude and Codex runners execute every row through `Invoke-OrchestrationPreimplementationGateDecision` with an injected not-ready `-CheckpointRaw`, or through `Test-ImplementationCommand` for classification-only rows.
- Unit tests (Pester): one suite per new sibling covering stage-2 rule branches, the mention-host table pin, configuration parsing (valid, absent, empty, each invalid case), the root helper (backslash normalization, suffix match and mismatch, case), and the leg (allow and deny shapes, index outcomes).
- Edge cases and negative scenarios: unbalanced text, opaque payloads, evaluators, executing options (`rg --pre`, `git grep -O`), path equal to root, `..` segments, backslash paths, mixed operands, non-git segments, unresolvable text, empty, mixed, or unreadable index, injected `-CheckpointRaw`.
- Error handling verification: dependency-load failure of each new sibling denies through the guarded dot-source; invalid configuration produces the suffix with its detail, after the cleanup suffix.
- Isolation: `Get-OrchestrationGateStagedIndex` and `Get-OrchestrationGateBookkeepingConfigText` are mocked in every suite that reaches the leg; no temporary files, child processes, clock reads, or real git index reads. Fixtures use forward-slash relative paths and synthetic absolute roots without drive letters, so the Linux hook-suite job behaves the same as Windows. Every mock and global set by a new suite is restored (`Invoke-PoshQCLeakScan` clean).
- Coverage: per-file line coverage for the `.claude/hooks` and `.codex/hooks` copies of both new siblings, read from `artifacts/pester/powershell-coverage.xml`.
- Toolchain: `Invoke-Formatter`, PSScriptAnalyzer, then one parallel `Invoke-PoshQCParallelTest` run (parallel only; no serial, single-process, shuffled, or reversed runs), then the push-down contract tests and the Codex generator `--check`.
- Evidence: Phase 0 baseline under `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/evidence/baseline/`; fail-before evidence for the false-positive rows under `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/evidence/regression-testing/`; final gate results under `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/evidence/qa-gates/`; coverage under `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/evidence/coverage/`. Evidence is append-only.
- Preflight check: search the test tree for pathless `git commit` rows driven through the decision function and confirm each injects `-CheckpointRaw` or mocks `Get-OrchestrationGateStagedIndex`.
- Manual validation: none. The live hook cannot be exercised by an isolated subagent before merge; acceptance rests on Pester.

## Acceptance Criteria

- [x] AC-1 Keyword false positives allow on both surfaces: every research section 6.3 row, including `ps aux | grep pytest`, `ps -ef | grep -i pytest`, `pgrep -f pytest`, `Get-Process -Name pytest`, `git log --grep pytest`, `git grep black`, `which pytest`, `Get-Command pytest`, `poetry show pytest`, `pip show black`, `npm ls prettier`, `echo git add docs`, and `pwsh -NoProfile -Command "Get-Process | Where-Object { $_.CommandLine -match 'Invoke-Pester' }"`, is unclassified with a not-ready checkpoint, proven by the false-positive table of `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` passing in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classification.Tests.ps1`, with fail-before evidence for the same rows on the unfixed gate recorded under `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/evidence/regression-testing/`.
- [x] AC-2 Every existing denial is preserved on both surfaces: every research section 6.2 row, including the added fail-closed rows (`env -u VIRTUAL_ENV poetry run pytest`, `timeout 60 pytest`, `FOO=1 pytest`, `python -m pytest`, `echo pytest | bash`, a heredoc piped into `bash`, `pwsh -c "Invoke-Expression 'Invoke-Pester'"`, `pwsh -c "[Diagnostics.Process]::Start('tests/scripts/run.ps1')"`, `xargs -n1 pytest`, `npm install prettier`, `command -v pytest`, and an unbalanced `echo "pytest`), is classified and denied with deny text byte-equal to today's, proven by the existing-denial table of the classification corpus passing in both classification runners. (Amended 2026-11-10 by recorded decision D15: the two `pwsh -c` rows were replaced because today's gate does not classify the originals.)
- [x] AC-3 Classification is never widened: the D2 declared non-goals (`npx --yes jest`, `node run-jest.cjs`, `npm test`, `Invoke-PoshQCParallelTest`, bare `Invoke-Pester` on Codex, a `.venv` runner path, `sh` with a launcher script, and, per D15, `pwsh -c "Invoke-Expression 'pytest'"` and `pwsh -c "[Diagnostics.Process]::Start('pytest')"`, which are unclassified today) remain unclassified, and the stage-2 function is invoked only after a stage-1 hit, proven by the non-goal table of the classification corpus and a stage-1-miss test in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1`.
- [x] AC-4 Stage-2 fallbacks fail closed: an Unbalanced record, an Opaque `DecodeFailure` or `DepthLimit` record, an opaque `NoPayload` shell wrapper carrying a governed word, an evaluator command word, `rg` with a `--pre` token, `git` with `-O` or `--open-files-in-pager`, `ForEach-Object`, `find`, and a PowerShell expression containing `::` or `.Invoke` each confirm the hit, proven by named cases in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1`.
- [x] AC-5 The mention-host table getter returns exactly the D2 table (each group, each subcommand set, and the executing-option exclusions), proven by a pin test in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1`.
- [x] AC-6 Agent-memory staging and committing allow on both surfaces with no checkpoint and the default configuration: `git add` of a file under `.claude/agent-memory/`, `git add --` of such a file, `git commit -m <message> -- <agent-memory path>`, `git commit -F <file> -- <agent-memory path>`, and a pathless `git commit -m <message>` whose mocked staged index names only `.claude/agent-memory/` paths, proven by allow rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.BookkeepingLeg.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-bookkeeping-leg.Tests.ps1`.
- [x] AC-7 Mixed bookkeeping forms behave as declared in D5 as amended by D14 on both surfaces: a `git add --` naming one path under `.claude/agent-memory/` and one under `docs/features/active/` allows, and a pathless commit whose mocked index holds one `.claude/agent-memory/` path and one `docs/features/active/` path allows; a pathless commit whose mocked index holds only #539-tree paths, `git commit -F <file>` or `--file <file>` with `-- <#539-tree paths>` only, and a bookkeeping command whose `-C` selector `Test-ExemptOrchestrationSelector` rejects deny with today's text; each allow row denies with today's text under a `[]` configuration, proven by D5/D14 rows in both decision-level leg suites. (Amended 2026-11-10 by recorded decision D14; the original wording required the two withdrawn D5 widenings to allow.)
- [x] AC-8 Non-exempt and unsafe staging still denies with unchanged deny text on both surfaces under the default configuration: `git add .`, `git add -A`, `git add -u`, `git add :/`, a glob pathspec, `git add` of exactly `.claude/agent-memory/`, a path with a `..` segment, a backslash path, mixed agent-memory and non-bookkeeping operands, `git commit -a`, `git commit -am`, `git commit --amend`, `git commit -i`, `git commit -o`, `--pathspec-from-file`, inline `--message=`, a bookkeeping `git add` chained with `&& pytest` or `&& git push`, unresolvable text containing `$`, and a pathless commit with an empty, mixed, or unreadable mocked index or with an injected `-CheckpointRaw`, proven by deny rows in both decision-level leg suites.
- [x] AC-9 The #539 classification-time exemption is unchanged: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1` pass without modification.
- [x] AC-10 Configuration absent: `Get-OrchestrationGateBookkeepingConfigText` returns `$null` when the file does not exist, resolves the file relative to `$PSScriptRoot` with forward-slash-safe path construction, and the leg then uses the default `[".claude/agent-memory/"]` with no deny suffix, proven by mocked-seam cases in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-bookkeeping.Tests.ps1`.
- [x] AC-11 Configuration `[]`: with `{"schema_version": 1, "bookkeeping_roots": []}` the leg is disabled and every allow row of AC-6 and AC-7 denies with deny text byte-equal to today's and no suffix, proven by `[]` cases in both decision-level leg suites.
- [x] AC-12 Configuration invalid: malformed JSON, a non-object, `schema_version` other than integer 1, a non-array `bookkeeping_roots`, a non-string entry, an entry failing `^[A-Za-z0-9._/-]+/$`, an entry starting with `/`, an entry containing `//`, an entry with a `.` or `..` segment, a duplicate entry, and an unknown top-level key each yield `Valid` false with a detail from `ConvertFrom-OrchestrationGateBookkeepingConfig`, disable the leg, and append ` Bookkeeping leg not applied: BOOKKEEPING_CONFIG_INVALID: <detail>.` after the #1026 cleanup suffix, proven by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-bookkeeping.Tests.ps1` and by suffix-ordering cases in both decision-level leg suites.
- [x] AC-13 Unparseable commands keep today's fail-closed behavior and deny text (D7), proven by unbalanced-text rows in the existing-denial table of the classification corpus and an unbalanced bookkeeping row in both decision-level leg suites.
- [x] AC-14 Claude and Codex parity: both classification runners produce the same decision for every corpus row; `$script:SharedGateFunction` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1` is unchanged; `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` passes.
- [x] AC-15 Byte identity and size of the new siblings: `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, and their bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` have equal SHA256 and fewer than 500 logical lines, and the same holds for `enforce-orchestration-preimplementation-gate-bookkeeping.ps1`, proven by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Parity.Tests.ps1` and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-bookkeeping.Parity.Tests.ps1`.
- [x] AC-16 Guarded loading: both gates dot-source each new sibling in the `try { . ... } catch { Add-HookDependencyFailure ... }` form, proven by `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, and `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` passing.
- [x] AC-17 Existing gate suites pass without modification in the parallel Pester gate: every suite listed in research section 8, including `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1`, and `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`, with the run recorded under `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/evidence/qa-gates/`.
- [x] AC-18 Protected files are unchanged: `git diff main --stat` shows no change to any file listed under "Files not to modify", and `config/preimplementation-gate.json` does not exist in the PR.
- [x] AC-19 Push-down consistency: the bundle copies of both gate files are byte-equal to their source copies; both new siblings are listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`; `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, and `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` pass, and `scripts/dev_tools/generate_codex_agent_variants.py --check` exits 0.
- [x] AC-20 Documentation: a `## Hook Execution Context` bullet describing stage-2 classification, the bookkeeping leg, the `bookkeeping_roots` key, its schema, default, `[]` opt-out, and invalid-file suffix is present in `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, and `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`; a paragraph is added to `## Pre-Implementation Gate` in `.agents/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`; and the header comment of each gate file and each new sibling describes the change, verified by review of the diff.
- [x] AC-21 No Python in the hook path: the PR adds no `.py` file, and neither gate file nor either new sibling invokes `python`, `python3`, `py`, or `poetry run python`, verified by a search of those files recorded in the QA evidence.
- [x] AC-22 Coverage: per-file line coverage is at least 90% for each of `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, and `.codex/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1`, and line coverage of the changed lines in both gate files does not fall below the Phase 0 baseline, read from `artifacts/pester/powershell-coverage.xml` and recorded under `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/evidence/coverage/`.
- [x] AC-23 Test hygiene: the new suites mock `Get-OrchestrationGateStagedIndex` and `Get-OrchestrationGateBookkeepingConfigText` wherever the leg is reached, create no temporary files, and leave `Invoke-PoshQCLeakScan` clean, recorded in the QA evidence.
- [x] AC-24 CI is green on the PR head (CI-dependent criterion; checked off at S9 by the item's own orchestrator run after `ci_gate.conclusion` is `success`).

## Risks & Mitigations

- **Undeclared widening.** A reviewer may find a staging allow that today denies and the spec does not declare. Mitigation: every D5 widening is a named corpus row, and the `[]` configuration rows prove exact reversion.
- **Gate function inventory drift.** Adding a function to a gate file breaks the parity inventory. Mitigation: all new functions live in the two siblings (D8); AC-14 pins the inventory.
- **Mirror drift.** Four copies per sibling, gate bundle copies, two manifests, six brief copies, and two orchestrate copies. Mitigation: AC-15 parity suites, AC-19 contract tests and generator check, AC-20 file list.
- **Real I/O in tests.** A suite could read the real git index or a real configuration file. Mitigation: mocked seams (AC-23), the no-root rule under injected `-CheckpointRaw`, and the preflight search for pathless commit rows.
- **Linux-only CI failures.** Backslash path construction or a case-sensitive suffix match fails only in the Linux hook-suite job. Mitigation: `Join-Path` with forward-slash normalization, ordinal case-insensitive suffix match, and synthetic roots without drive letters.
- **Merge conflict with #1163.** Mitigation: D9 file boundaries; gate edits kept contiguous; shared files re-read at execution start.
- **Shared wrapper skip residual.** `env -u NAME` and `command -v X` resolve the command word to the operand; both stay denied (fail closed). This is accepted and pinned by AC-2 rows.
- Rollback: revert the PR, or set `"bookkeeping_roots": []` in a destination's `config/preimplementation-gate.json` to disable the leg.

## Rollout & Follow-up

- Release: ships in the next extension release through the bundle copies and `core.json` manifests; no registration change, so destinations pick up the change on push-down.
- Destinations that do not want the agent-memory default commit `config/preimplementation-gate.json` with `"bookkeeping_roots": []`; a push-down never overwrites that file because the repository does not ship one.
- Follow-up: if #1163 exposes the resolved root on the `Read-OrchestrationGateCheckpoint` result, the leg's root helper is replaced by that value inside this item when #1163 merges first, or in #1163's own change when it merges second.
- Links: issue #1160; research `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/research/research.2026-11-09T21-40.md`; related issues #539, #1026, #1141, #1159, #1163.
