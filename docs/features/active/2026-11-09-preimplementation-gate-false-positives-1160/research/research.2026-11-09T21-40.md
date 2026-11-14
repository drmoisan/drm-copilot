# Research: Pre-implementation gate false positives (Issue #1160)

- Issue: #1160
- Branch: bug/preimplementation-gate-false-positives-1160
- Work mode: full-bug
- Authoritative scope: `issue.md` in this feature folder (not shrunk)
- Method: every finding below was verified by reading the named file in the item worktree. Facts that need `git show`, a hash, or a live run are listed under "Items for the orchestrator to confirm".

## 1. Summary

1. The gate classifies Bash commands in `Test-ImplementationCommand` (present in both `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`). Staging is detected structurally (`Test-CommandLineInvocation`), but formatters, linters, type checkers, and test runners are detected by five regular expressions applied to each segment's `ScanText`.
2. False positive 2 (keyword): `ScanText` masks quoted spans only. An unquoted runner word in any non-wrapper segment matches, for example `ps aux | grep pytest`, `Get-Process -Name pytest`, `rg -n pytest pyproject.toml`, and `git log --grep pytest`. A wrapper-led segment (`pwsh`, `bash`, and similar) is scanned raw, so `pwsh -Command "Get-Process | Where-Object { $_.CommandLine -match 'Invoke-Pester' }"` also matches.
3. False positive 1 (staging): the only staging exemption on the classification path is the issue #539 orchestration-bookkeeping exemption (`Test-ExemptOrchestrationStagingCommand`). It covers five trees, does not cover `.claude/agent-memory/`, and never exempts a pathless `git commit`. With no checkpoint, the readiness check fails, the #1026 cleanup legs do not apply outside the consolidation worktree, and the call is denied with the generic `PREIMPLEMENTATION_GATE_BLOCKED:` text.
4. The repository already contains the matchers this fix needs: the payload-aware iterator `Read-CommandLineInvocationSegment`, the structural matcher `Get-CommandLineInvocation`, the scanner `Read-CommandLineSegment`, and the path-scoped staging allowance `Get-EpicFanInAllowance` with `Test-EpicMergedFeaturePath` (issue #1141). That allowance already models `git add [--] <paths>`, the five commit options, `-- <paths>`, and a pathless commit checked against the staged index.
5. Recommended design: keep today's regex scan as a stage-1 candidate filter, so no new command can be classified. Add a stage-2 structural confirmation that drops a hit only when every occurrence of the governed word is an operand of a known non-executing "mention host" (grep, process listings, lookups) and no evaluator or opaque shell is present.
6. Recommended staging fix: add a new allow-side bookkeeping leg, evaluated only where the gate would otherwise return its final single-feature deny (the same position as the #1026 cleanup leg). It reuses `Get-EpicFanInAllowance` with a predicate over the union of the five #539 trees and the declared bookkeeping roots.
7. Declared roots come from an optional `config/preimplementation-gate.json` (`bookkeeping_roots`). The built-in default is `[".claude/agent-memory/"]`, which is the explicit behavior change the issue requests. `[]` disables the leg and restores today's behavior exactly. An invalid file also disables the leg and appends a diagnostic suffix.
8. The Claude and Codex twins differ only in transport, in the apply_patch marker legs of the Codex `Test-ImplementationCommand`, and in deny-reason plumbing. Both must change identically. New logic goes into two new byte-identical sibling files (four copies each: `.claude`, `.codex`, and both bundles), so the parity-pinned function inventory of the gate files does not change.
9. The issue #1163 overlap is session-root and target resolution (`Resolve-OrchestrationGateTarget`, `Read-OrchestrationGateCheckpoint`, and the `(Get-Location).Path` reads in the epic-scope and cleanup siblings). The recommended design edits none of those files and reads its configuration relative to `$PSScriptRoot`, so it composes in either merge order. For #1159 the hook remains a standalone registered script and needs no registration change.
10. No human interaction is required. Every step can be automated and verified with Pester suites.

## 2. Current State

### 2.1 Gate files and sizes

Line counts were taken with a line-count search (`^` per line) on the item worktree. They match the last line number shown by a full read, so they are logical lines.

| File (Claude / Codex) | Claude lines | Codex lines | Role |
|---|---|---|---|
| `enforce-orchestration-preimplementation-gate.ps1` | 473 | 493 | entry point, `Test-ImplementationCommand`, `Test-ImplementationPath`, decision flow |
| `...-gate-helpers.ps1` | 470 | 470 | #539 exemption: `Test-ExemptOrchestrationStagingCommand`, `Split-OrchestrationCommandLine`, `Test-OrchestrationCommandTextUnresolvable`, `ConvertTo-OrchestrationCommandToken` (stated byte-identical across four copies; `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` pins SHA256 equality and a 500-line bound) |
| `...-gate-modes.ps1` | 496 | 493 | delegation mode dispatch (not involved in command classification) |
| `...-gate-epic-scope.ps1` | 402 | 462 | checkpoint read seams, `Resolve-OrchestrationGateTarget`, `Read-OrchestrationGateCheckpoint`, `Get-OrchestrationEpicScopeDecision` (twins differ) |
| `...-gate-targets.ps1` | 433 | 433 | `Get-OrchestrationCommandTarget` (header: four copies byte-identical) |
| `...-gate-cleanup.ps1` | 481 | 481 | #1026 cleanup legs and `Get-OrchestrationGateStagedIndex` seam (header: byte-identical) |
| `...-gate-epic-resolution.ps1` | n/a | 493 | Codex-only epic resolution |
| `hook-epic-fan-in.ps1` | 488 | 488 | #1136 and #1141 allowances (header: byte-identical) |
| `hook-command-scanner.ps1` | 400 | 400 | `Read-CommandLineSegment` |
| `hook-command-invocation.ps1` | 482 | 482 | `Get-CommandLineInvocation`, `Test-CommandLineInvocation` |
| `hook-command-payload.ps1` | 484 | 484 | `Read-CommandLineInvocationSegment`, `Skip-CommandLineTransparentWrapper`, `Test-CommandLineWordPresent`, `Test-CommandLinePayloadInert` |
| `hook-command-payload-powershell.ps1` | 201 | 201 | PowerShell AST payload records |

`config/file-size-baseline.json` has no entry for any of these files.

### 2.2 Registrations

- Claude: `.claude/settings.json` registers `pwsh -NoProfile -File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1` in three PreToolUse matcher groups. The bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` registers the same three entries.
- Codex: `.codex/config.toml` has two `[[hooks.PreToolUse.hooks]]` entries for `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.
- The recommended design adds no hook script and changes no registration.

### 2.3 Command classification: exact logic

`Test-ImplementationCommand` (Claude gate; the Codex body is identical after its apply_patch marker loops):

1. `$scanText = @(Read-CommandLineSegment -CommandText $normalizedCommand).ScanText`. `ScanText` is `MaskedText` (quoted spans and heredoc bodies replaced by spaces). It is `RawText` when the segment is `Unbalanced`, has a live substitution, or is led by a member of `$script:CommandLineWrapperNames` (`sh bash zsh dash ksh pwsh powershell xargs env command eval nohup time timeout`).
2. `$isStaging` is true when `Test-CommandLineInvocation` finds `git add` or `git commit`. This check is structural, covers payloads, and treats Indeterminate results as matches. `Get-CommandLineInvocation` marks every `Unbalanced` record Indeterminate unconditionally, so any unbalanced command text counts as staging today.
3. Five patterns are evaluated against every `ScanText` element:
   - index 0 `(^|\s)git\s+(add|commit)\b` (or `$isStaging`)
   - index 1 `(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b`
   - index 2 `(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b`
   - index 3 `(^|\s)npx\s+(prettier|eslint|tsc|jest)\b`
   - index 4 `(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)`
4. Only index 0 can be cleared, and only by `Test-ExemptOrchestrationStagingCommand`. A hit on any other index returns `$true` (implementation).

The issue's description "keyword classification" applies to indexes 1 to 4 and to the regex half of index 0. The regex half of index 0 also matches an unquoted mention such as `echo git add docs`.

### 2.4 Decision flow and deny texts

`Invoke-OrchestrationPreimplementationGateDecision` (both surfaces) runs these steps:

1. Dependency failure: deny with `PREIMPLEMENTATION_GATE_BLOCKED:` prefix.
2. Classification (path, command, or delegation leg). If the call is not classified, allow.
3. `Test-OrchestrationDelegationDeclaredCheckpointPath`: deny with the mode reason `declared-checkpoint-path`.
4. `Get-OrchestrationEpicScopeDecision` for path and command legs. In epic scope it allows or denies with `target-unresolvable`, `target-ambiguous`, `target-mixed`, `target-not-ready`, or the session-root readiness text.
5. Epic and parallel delegation modes: deny with `Get-OrchestrationModeDenyReason`.
6. Single feature: `Read-OrchestrationGateCheckpoint` (not called when `-CheckpointRaw` is injected). It denies `PREIMPLEMENTATION_GATE_BLOCKED: <reason code>: the target worktree of this single-feature call could not be resolved ...` for NoTarget or Ambiguous.
7. `Test-OrchestrationReady`: allow when ready.
8. `Get-OrchestrationCleanupContextResult` (#1026): allow, or contribute a `DenySuffix`.
9. Final deny: `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.` + `$cleanup.DenySuffix`.

### 2.5 Reproduction: false positive 1 (agent memory in a checkpoint-less coordinator checkout)

Command `git add .claude/agent-memory/task-researcher/notes.md`, session root = main checkout with no `artifacts/orchestration/orchestrator-state.json`:

- `$isStaging` is true. `Test-ExemptOrchestrationStagingCommand` calls `Test-ExemptOrchestrationSegmentToken` and then `Test-ExemptOrchestrationOperand`. The operand passes the ASCII allowlist and is not rooted, but it starts with none of `docs/features/epics/`, `docs/features/parallel/`, `docs/features/active/`, `docs/features/potential/`, or `artifacts/orchestration/`. The exemption returns false, so the command is classified.
- Epic scope finds no epic checkpoint and returns `$null`.
- `Read-OrchestrationGateCheckpoint`: `Get-OrchestrationGateCommandOperandPath` returns no path (the operand is relative), so `Resolve-HookTargetWorktree` resolves the session root and `Get-CheckpointContent` returns `''`.
- `ConvertFrom-CheckpointJson -Json ''` throws on the mandatory empty argument. The error is caught and the checkpoint becomes `$null`, so `Test-OrchestrationReady` returns false.
- Cleanup leg: `Test-OrchestrationCleanupSegmentShape` requires `git -C <absolute> add|commit`, so the result is not allowed and `DenySuffix` is empty. The call gets the final deny text in 2.4 step 9.
- `git commit -m "memory"` (pathless) is denied by the same path, because the #539 exemption requires at least one pathspec operand (rows 1, 4, 7). `git commit -F msg.txt -- .claude/agent-memory/x.md` is also denied, because the #539 option table models only `-m`, `--message`, and `--trailer` (`-F` falls to the unmodelled-option deny).

### 2.6 Reproduction: false positive 2 (runner word in a process listing or grep pattern)

- `ps aux | grep pytest`: the segments are `ps aux` and ` grep pytest`. Neither is wrapper-led, so `ScanText` is the masked text, the unquoted `pytest` survives, and index 1 matches ` pytest`. The call gets the final deny text.
- `Get-Process -Name pytest`, `pgrep -f pytest`, `rg -n pytest pyproject.toml`, `git log --grep pytest`, `which pytest`, `poetry show pytest`, `cat pytest.ini` (`\b` falls between `pytest` and `.`), and `npm ls prettier` (index 2) all match the same way.
- `pwsh -NoProfile -Command "Get-Process | Where-Object { $_.CommandLine -match 'Invoke-Pester' }"`: one wrapper-led segment, so `ScanText` is `RawText`, and index 4 matches `pwsh ... Invoke-Pester`. `pwsh -c "Get-ChildItem tests/scripts/"` matches index 4 through `tests/scripts/`.
- Not reproduced, because the word is quoted or not whitespace-preceded: `grep 'pytest' x`, `Get-CimInstance Win32_Process | Where-Object CommandLine -like *pytest*`.

### 2.7 Twin differences (Claude versus Codex)

- `Test-ImplementationCommand`: the five patterns, the loop, and the #539 call are identical. Codex adds two apply_patch marker loops ahead of them.
- Decision function: Codex allows an empty `ToolInputRaw`, throws on malformed JSON, reads `Get-StringProperty` (which trims), and has no `Invoke-...EntryPoint` (declared divergences in `enforce-orchestration-preimplementation-gate.Parity.Cases.ps1`). Its cleanup call passes `-AllowPatchManifest`. Its mode branch reads `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` without a target. Both surfaces call `Read-OrchestrationGateCheckpoint` for single feature.
- Both twins must change. The helper, targets, cleanup, `hook-epic-fan-in.ps1`, and `hook-command-*` files are stated byte-identical in their headers and are pinned by parity tests (`...-helpers.Parity.Tests.ps1`, `...-targets.Parity.Tests.ps1`, `hook-cleanup-context.Parity.Tests.ps1`, `...EpicScopeHelperParity.Tests.ps1`). The epic-scope siblings differ (402 and 462 lines).

## 3. Reusable Token-Aware Matchers

| Function | File | Loading | Host-neutral | Tested by | Reuse verdict |
|---|---|---|---|---|---|
| `Read-CommandLineSegment` | `hook-command-scanner.ps1` | dot-sourced (gate already loads it) | pure | `hook-command-parser.*`, trigger-scoping suites | reuse for stage 1 (unchanged `ScanText`) |
| `Read-CommandLineInvocationSegment` | `hook-command-payload.ps1` | dot-sourced via `hook-command-invocation.ps1` | pure; PowerShell payloads parsed by `Parser::ParseInput` (no execution) | `hook-command-invocation.*` | reuse for stage 2 (records for top-level segments, `sh/bash -c`, `pwsh -c/-EncodedCommand`, `eval`, substitution bodies, `xargs` injection; Opaque/Unbalanced/DepthLimit flags) |
| `Skip-CommandLineTransparentWrapper` | `hook-command-payload.ps1` | as above | pure | R6 pins | reuse to find a record's command word. Limitation: `env -u NAME` treats `NAME` as the command word, and `command -v X` treats `X` as the command word; both resolve fail-closed under the recommended rule |
| `ConvertTo-CommandLineLeafWord`, `Test-CommandLineWordPresent` | `hook-command-payload.ps1` | as above | pure | yes | reuse for whole-token presence and leaf comparison |
| `Get-CommandLineInvocation` / `Test-CommandLineInvocation` | `hook-command-invocation.ps1` | dot-sourced | pure | many | keep for `git add`/`git commit`. It cannot express a bare runner: `SubcommandPath` is `[ValidateNotNullOrEmpty()]`, and `Get-CommandLineStructuralWalk` takes a mandatory non-empty path. Do not edit this shared file |
| `Test-CommandLinePayloadInert` | `hook-command-payload.ps1` | as above | pure | yes | not reused for runners: its fixed sink allowlist (`Write-*`, `echo`, `printf`, `Select-String`, `grep`, `rg`) would keep the wrapped `Get-Process` listing denied. The file header says "Not extended here", so a gate-local mention-host table is used instead |
| `Get-EpicFanInAllowance`, `Test-EpicMergedFeaturePath`, `Test-EpicFanInStagedIndex`, `Get-EpicFanInShapeDetail` | `hook-epic-fan-in.ps1` | dot-sourced (guarded) by both epic-scope siblings | pure; staged index only through the injected reader | `hook-epic-fan-in.Tests.ps1`, EpicFanIn and MergedFollowUp suites | reuse for the bookkeeping leg with `-PathPredicate`/`-OperandPredicate` over the bookkeeping roots and a scope object carrying `WorktreeRoot` (`Checkpoint` may be `$null`; with predicates supplied, the status-document path is unused) |
| `Get-OrchestrationGateStagedIndex` | `...-gate-cleanup.ps1` | dot-sourced | I/O seam through `Invoke-DocsOnlyGitExe` (never throws; ExitCode -1 for a non-directory root) | cleanup suites mock it | reuse as the staged-index reader |
| `Get-CommandLineGlobalOption` (`npx` table) | `hook-command-invocation.ps1` | dot-sourced | pure | R6 | optional, for npx option absorption in mention-host checks |

The validate-bash functions (`Get-BlockedBashPattern`, `Get-CdChainedReadCommandMatch`, `Get-BashBlockReason`) apply destructive-pattern policy and are not classifiers for this gate. No other hook classifies test runners: a search of `.claude/hooks` for `pytest|Invoke-Pester` finds only this gate and a language label in `validate-feature-review-coverage-rules.ps1`.

## 4. Recommended Design

### 4.1 Classification: stage 1 filter plus stage 2 confirmation

- Stage 1 (unchanged): the five patterns over `ScanText`, plus `$isStaging`. A command with no stage-1 hit is not classified, exactly as today. This guarantees that the change only removes classifications and never adds one.
- Structural staging (`$isStaging` true, including Indeterminate) classifies as today and keeps the #539 exemption.
- Stage 2: a regex hit on any index (including the regex half of index 0 when `$isStaging` is false) is confirmed unless all of the following hold:
  1. No iterator record is `Unbalanced`, Opaque with `DecodeFailure` or `DepthLimit`, or an Opaque `NoPayload` shell wrapper (for example `bash` reading stdin, `bash <<EOF`, or `pwsh -File ...`) whose own raw text or the whole normalized text carries a governed word.
  2. No record's command word is an evaluator (`eval` is already expanded; `Invoke-Expression`, `iex`, `Invoke-Command`, `icm`, `Start-Process`, `saps`, `start`, `cmd`, `cmd.exe`, `source`, `.`) while the whole normalized text carries a governed word.
  3. Every record that carries the governed word as a whole token (`Test-CommandLineWordPresent` over the record's tokens; for index 4, `Invoke-Pester` as a whole token or the substring `tests/scripts/`) is either:
     - led by a mention host from the gate-local table, with no executing option, or
     - a PowerShell non-command expression record whose text contains neither `::` nor `.Invoke`.
- The mention-host table is data with a getter, pinned by test (the R6 pattern used by `Get-CommandLineWrapperName`):
  - Search hosts: `grep`, `egrep`, `fgrep`, `rg` (not when a token starts with `--pre`), `ag`, `ack`, `findstr`, `Select-String`, `sls`.
  - Process hosts: `ps`, `pgrep`, `pidof`, `pkill`, `kill`, `killall`, `tasklist`, `taskkill`, `Get-Process`, `gps`, `Stop-Process`, `Get-CimInstance`, `gcim`, `Get-WmiObject`.
  - Output hosts: `echo`, `printf`, `Write-Output`, `Write-Host`, `Write-Verbose`.
  - Read and filter hosts: `cat`, `Get-Content`, `head`, `tail`, `less`, `more`, `wc`, `sort`, `uniq`, `Where-Object`, `Select-Object`, `Sort-Object`, `Measure-Object`, `Format-Table`, `Format-List`, `Out-String`, `Get-ChildItem`, `Test-Path`.
  - Lookup hosts: `which`, `where`, `where.exe`, `type`, `Get-Command`, `gcm`.
  - Subcommand-scoped hosts: `git` {`grep`, `log`, `show`, `diff`, `blame`, `ls-files`, `status`} (not with `-O` or `--open-files-in-pager`); `npm` {`ls`, `list`, `view`, `info`, `show`, `outdated`, `explain`, `why`, `search`, `help`}; `pip`/`pip3` {`show`, `list`, `freeze`}; `poetry` {`show`, `search`}.
  - Not hosts: `ForEach-Object` and `find`, which can execute their arguments.
- Results:
  - `ps aux | grep pytest`, `Get-Process -Name pytest`, `rg -n pytest x`, `git log --grep pytest`, `npm ls prettier`, and `echo git add docs` are allowed.
  - `pwsh -c "Get-Process | Where-Object { $_.CommandLine -match 'Invoke-Pester' }"` is allowed. Its records are `Get-Process` (host), `Where-Object` (host), and the expression `$_.CommandLine -match 'Invoke-Pester'` (no `::`, no `.Invoke`).
  - Every row in 6.2 still denies. `env -u VIRTUAL_ENV poetry run pytest` still denies: the command word becomes `VIRTUAL_ENV`, which is not a host, and `pytest` is a token. `echo pytest | bash` still denies (opaque shell plus word in the whole text). `pwsh -c "Invoke-Expression 'pytest'"` still denies (evaluator).

### 4.2 Bookkeeping staging leg

- New allow-side leg `Get-OrchestrationBookkeepingStagingResult -Command <text> -CheckpointPath <read path or empty> [-ConfigReader] [-StagedIndexReader]`. It is called in the single-feature branch after the cleanup leg and before the final deny, on both surfaces, and only when `$command` is non-empty and not apply_patch text.
- Effective roots: the five #539 trees plus the declared roots, used only when the declared list is non-empty. An empty or invalid declared list disables the leg.
- Delegates to `Get-EpicFanInAllowance -Scope ([pscustomobject]@{ Checkpoint = $null; WorktreeRoot = <root> }) -Command $command -StagedIndexReader <seam> -PathPredicate $p -OperandPredicate $p`, where `$p = { param($Path) Test-EpicMergedFeaturePath -RelativePath $Path -Root $roots }`.
- Root for the staged index: derived from the `Path` returned by the gate's own `Read-OrchestrationGateCheckpoint` call. A pure helper normalizes `\` to `/` and strips the suffix `/artifacts/orchestration/orchestrator-state.json` (ordinal case-insensitive).
  - When the caller injected `-CheckpointRaw` (no read happened) or the suffix does not match, the root is `$null`. A pathless commit is then not allowed (fail closed). A pathspec-only call does not need the root.
  - This avoids editing the epic-scope siblings that #1163 is likely to touch.
- Fail-closed composition, inherited from `Get-EpicFanInAllowance`, `Get-EpicFanInShapeDetail`, and `Test-EpicMergedFeaturePath`:
  - Every segment (split by `Split-OrchestrationCommandLine` on `;`, `&`, `|`, CR, LF) must be `git [-C <absolute>] add [--] <paths>` or `git [-C <absolute>] commit` with only `-m`, `--message`, `-F`, `--file`, or `--trailer` (each with a separate value), followed by nothing or by `-- <paths>`.
  - Every path must lie strictly under a root (a path equal to a directory root is rejected) and must carry no backslash, `*`, `?`, `[`, `.` or `..` segment, or leading `/`.
  - Denied: `git add .`, `git add -A`, `git add -u`, `git add :/`, globs, mixed exempt and non-exempt operands, `git commit -a`, `-am`, `--amend`, `-i`, `-o`, `--pathspec-from-file`, inline `--message=`, any non-git segment (`&& pytest`, `&& git push`), and text that `Test-OrchestrationCommandTextUnresolvable` flags (`$`, backtick, `< > # { } , ( ) @` outside quotes, any backslash or typographic quote).
  - Pathless commit: the staged index read through `Get-OrchestrationGateStagedIndex` must exit 0, be non-empty and NUL-terminated, and name only paths under the roots. A commit with `-- <paths>` needs no index read, because git commits only the named paths (`--only` default).
  - Known limitation: in `git add X && git commit -m m` the index is read before the add runs. The commit is allowed only when the pre-existing index is already non-empty and all-bookkeeping. Use `git commit -m m -- X`, or two calls.
- Deny text is unchanged when the leg does not apply. When the configuration file is present and invalid, append ` Bookkeeping leg not applied: BOOKKEEPING_CONFIG_INVALID: <detail>.` (pattern of the #1026 `DenySuffix`), after the cleanup suffix.
- Scope limits:
  - Epic-scope decisions (#663, #1136, #1141), delegation modes, the path leg, and the NoTarget and Ambiguous denies are unchanged.
  - Write and Edit of `.claude/agent-memory/*.md` are already allowed by `Test-ImplementationPath`, because `.md` is not an implementation extension. A `.json` under agent memory remains gated, since the issue scopes staging and committing only.

### 4.3 Configuration

- File: `config/preimplementation-gate.json`, read through the seam `Get-OrchestrationGateBookkeepingConfigText`. The seam reads `Join-Path $PSScriptRoot '../../config/preimplementation-gate.json'` and returns `$null` when the file is absent, following the precedent of `$RoutingMatrixReader` in `.claude/hooks/enforce-completion-helpers.ps1` for `config/orchestration-routing.json`. The same relative path serves `.claude/hooks` and `.codex/hooks`.
- Schema: `{ "schema_version": 1, "bookkeeping_roots": [".claude/agent-memory/"] }`. The pure parser `ConvertFrom-OrchestrationGateBookkeepingConfig -Text` returns `Valid`, `Roots`, and `Detail`.
  - Validation: a JSON object; `schema_version` equal to integer 1; `bookkeeping_roots` an array of strings.
  - Each entry must match `^[A-Za-z0-9._/-]+/$`, must not start with `/`, must contain no `//`, and must contain no `.` or `..` segment. Duplicate entries are rejected.
  - Unknown top-level keys are rejected, so a misspelled key is visible.
- Semantics:
  - File absent: built-in default `[".claude/agent-memory/"]`.
  - Valid file: its list replaces the default; `[]` disables the leg, which is today's behavior.
  - Invalid file: the leg is disabled and the deny suffix is appended.
- Push-down: no committed file is needed in this repository, because the default lives in code. Destinations receive the default with the hook and may add their own file, which a push-down never overwrites. Documentation goes in the execution-environment brief and the gate sibling header (see 7.3).

## 5. Decisions

- D1. Tokenizer reuse.
  - Options: (a) replace the regexes with `Get-CommandLineInvocation` calls; (b) edit the shared `hook-command-invocation.ps1` to accept an empty `SubcommandPath`; (c) keep the stage-1 regexes and add gate-local stage-2 confirmation over `Read-CommandLineInvocationSegment` records, using `Skip-CommandLineTransparentWrapper`, `ConvertTo-CommandLineLeafWord`, `Test-CommandLineWordPresent`, and `Get-CommandLineInvocation` for git.
  - Recommendation: (c).
  - Rationale: (a) cannot express bare runners. (b) changes a shared, byte-identical, R6-pinned file used by validate-bash, the merge gates, and pr-author. (c) is pure composition of tested matchers and, because of stage 1, provably never classifies a command that today's gate allows.
- D2. Scope of "real invocation".
  - Options: (a) positive model: governed word in command position after a pinned launcher table; (b) negative model: a stage-1 hit stands unless every occurrence is an operand of a mention host, with evaluator and opaque-shell fallbacks.
  - Recommendation: (b), with the table in 4.1.
  - Rationale: (b) is fail-closed for any unmodelled launcher (`conda run`, `hatch run`, `coverage run -m`, `tox`), fixes both reported classes, and keeps every existing denial. Covered forms:
    - Wrappers: `poetry run pytest`, `npx jest`, and `env X=1 pytest` stay denied.
    - Wrapper payloads: `pwsh -c Invoke-Pester` stays denied through the payload record.
    - Pipelines and chains (`&&`, `;`): each record is judged, so `pytest | tee x` denies and `ps aux | grep pytest` allows.
    - Subshells and substitutions: these are delimiters or substitution records, so `(pytest)` and `echo "$(pytest)"` deny.
  - Declared non-goals (no widening): `.venv/bin/pytest`, `npx --yes jest`, `node run-jest.cjs`, `npm test`, bare `Invoke-Pester` on Codex, `Invoke-PoshQCParallelTest`, and `sh <launcher>.sh` remain unclassified, as today.
- D3. Staging token-awareness.
  - Recommendation: keep `$isStaging` (structural, Indeterminate-fail-closed) as a direct classifier, and subject the regex half of index 0 to stage-2 confirmation.
  - Rationale: this narrows `echo git add docs`, while `echo git add . | bash` still denies through the opaque-shell fallback.
- D4. Bookkeeping exemption placement.
  - Options: (a) extend the #539 classification-time exemption (helpers file); (b) new allow-side leg at the final single-feature deny, reusing `Get-EpicFanInAllowance`.
  - Recommendation: (b).
  - Rationale: the helpers file is pinned byte-identical and to 500 lines. Pathless commits need the staged index, which is I/O and must run after target resolution. (b) follows the #1026 "evaluated only where the gate would otherwise deny" precedent and the #1141 predicate-reuse precedent.
- D5. Composition with the #539 exemption.
  - Recommendation: the leg's predicate is the union of the five #539 trees and the declared roots, active only when the declared list is non-empty. The #539 classification-time exemption is left untouched.
  - Rationale: "alongside" in the issue requires mixed commands (`-- docs/features/active/x.md .claude/agent-memory/y.md`) to pass.
  - Declared widenings, each to be pinned by a test row: a pathless commit whose index holds only #539-tree paths, and `-F`/`--file` with `-- <#539 paths>`. Both are allowed when the leg is enabled and denied today.
- D6. Configuration location, key, schema, and default.
  - Recommendation: `config/preimplementation-gate.json`, key `bookkeeping_roots`, `schema_version: 1`, built-in default `[".claude/agent-memory/"]`, `[]` meaning today's behavior, and an invalid file disabling the leg with the `BOOKKEEPING_CONFIG_INVALID` suffix. Read relative to `$PSScriptRoot` through an injected seam.
  - Rationale: the agent-memory exemption is the explicit change the issue requests, so the default carries it. An empty default would leave the reported defect in every destination. `$PSScriptRoot`-relative reading is independent of session-root resolution (#1163).
- D7. Unparseable command.
  - Recommendation: keep today's fail-closed behavior. Unbalanced text is still classified by `$isStaging`, because `Get-CommandLineInvocation` marks Unbalanced records Indeterminate. Stage 2 also confirms any hit when a record is Unbalanced, Opaque with `DecodeFailure` or `DepthLimit`, or an opaque shell. The bookkeeping leg denies unresolvable or unbalanced text through `Get-EpicFanInAllowance`. Deny text is unchanged.
- D8. Codex parity.
  - Recommendation: apply the identical `Test-ImplementationCommand` body change to both gates (the Codex apply_patch loops stay upstream). Add the identical leg call line to both decision functions. Put all new functions in two new byte-identical siblings (`enforce-orchestration-preimplementation-gate-commands.ps1` for stage 2 and the mention-host table; `enforce-orchestration-preimplementation-gate-bookkeeping.ps1` for the configuration parser, the seam, the root helper, and the leg). Each has four copies: `.claude/hooks`, `.codex/hooks`, and both bundles. Dot-source them with the guarded `try { . ... } catch { Add-HookDependencyFailure ... }` pattern.
  - Rationale: `$script:SharedGateFunction` in `...Parity.Cases.ps1` and AC-18 stay unchanged, and `hook-dependency-guard-completeness.Tests.ps1` is satisfied.
- D9. Interaction with #1163 and #1159.
  - Recommendation: do not edit `...-epic-scope.ps1`, `...-targets.ps1`, `...-cleanup.ps1`, `HookTargetWorktree.psm1`, `hook-target-worktree.ps1`, or any `hook-command-*` file. Derive the staged-index root from `Read-OrchestrationGateCheckpoint`'s returned `Path`. Keep the gate a standalone registered script with its entry-point guard.
  - Rationale: the shared surfaces most at risk from #1163 are `Resolve-OrchestrationGateTarget`, `Read-OrchestrationGateCheckpoint`, `Get-OrchestrationCleanupContextResult`, and `Get-OrchestrationEpicScopeDecision` (each reads `(Get-Location).Path`), plus the worktree-resolution module. The leg calls only the read result and the existing seam, so it follows whatever #1163 does to resolution. If #1163 merges first and exposes the resolved root on the read result, use it directly instead of the suffix strip. The remaining conflict surface is the gate main files: the `Test-ImplementationCommand` body, two dot-source lines, and one leg line, kept contiguous.
- D10. Test strategy.
  - Recommendation:
    - (a) A data-only regression corpus file, `enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (pattern of `...Parity.Cases.ps1`), with three tables: every existing denial (6.2) expected `$true`, every false-positive form (6.3) expected `$false`, and every declared widening of D5 expected allow. Both surfaces run it.
    - (b) Pure unit suites for each new sibling.
    - (c) A byte-identity and line-bound parity test for each new sibling across four copies (pattern of `...-helpers.Parity.Tests.ps1`).
    - (d) A pin test for the mention-host table getter.
    - (e) Leg tests driven through `-CheckpointRaw` and direct calls, with `Get-OrchestrationGateStagedIndex` and `Get-OrchestrationGateBookkeepingConfigText` mocked.
    - No temporary files.
- D11. Documentation.
  - Recommendation: add one bullet under `## Hook Execution Context` in all six execution-environment copies. Add one paragraph to `## Pre-Implementation Gate` in `.agents/skills/orchestrate/SKILL.md`, its bundle copy, and any mirrored orchestrate skill that carries the section (the search found the section only in the `.agents` copy). Update the header comment of each gate.
  - Rationale: no existing brief sentence becomes false (the #1010 and #1026 bullets remain accurate), but the issue requires documenting changed behavior and the new configuration key.

## 6. Behavior Semantics and Edge Cases

### 6.1 Ordering

1. Classification: stage 1, then stage 2 for regex hits.
2. Structural staging, then the #539 exemption.
3. Declared-checkpoint check.
4. Epic scope.
5. Mode branch.
6. Read and resolve (NoTarget and Ambiguous deny).
7. Readiness.
8. Cleanup leg.
9. Bookkeeping leg.
10. Final deny (+ cleanup suffix + configuration suffix).

### 6.2 Existing denials that must be preserved (regression parity set)

These rows were gathered by reading the suites named in section 8.

- `poetry run pytest tests/...`, `git add .`, `git commit -m "test"`, `poetry run black ... --check`, `npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"` (`...gate.Tests.ps1`).
- `git -C ../other-worktree add .`, `git --git-dir=../other/.git commit -m wip`, `git --work-tree=../other add .`, `git --future-unmodeled-option add .`, `(git add .)`, `$(git add .)`, `echo scripts/powershell/Sample.ps1 | xargs git add`, `bash -c 'git add .'`, `sh -c "git add ."`, `env git add .`, the pwsh Invoke-Pester pin, a heredoc piped into bash, and `echo "$(git add .)"` (TriggerScoping, both surfaces).
- `git add src/app.ps1`, `poetry run black src/`, `npx prettier --check .` (Parity CommandCases).
- `git add src/feature.ps1`, `bash -c "git add src/feature.ps1"` (CN-06, CN-07); AT-6.
- `git add docs/features/epics/.../epic.md && poetry run pytest` (CommandExemption row 13a, both surfaces); `git -C <consolidation> add -- docs/research/y.md && pytest` (Cleanup).
- Additional fail-closed rows to add: `env -u VIRTUAL_ENV poetry run pytest`, `timeout 60 pytest`, `FOO=1 pytest`, `python -m pytest`, `pytest | tee out.txt`, `echo pytest | bash`, `bash <<'EOF'` with `pytest` in the body, `pwsh -c "Invoke-Expression 'pytest'"`, `pwsh -c "[Diagnostics.Process]::Start('pytest')"`, `pwsh -NoProfile -File tests/scripts/run.ps1`, `pwsh -c "& ./tests/scripts/x.ps1"`, `xargs -n1 pytest`, `find . -name x -exec pytest {} ;`, `npm install prettier`, `rg --pre pytest x`, `git grep -O vim pytest`, `command -v pytest` (residual: denied through the shared wrapper skip), and an unbalanced `echo "pytest`.

### 6.3 False positives that must allow (not-ready checkpoint)

`ps aux | grep pytest`, `ps -ef | grep -i pytest`, `pgrep -f pytest`, `Get-Process -Name pytest`, `rg -n pytest pyproject.toml`, `grep -rn ruff docs/`, `git log --grep pytest`, `git grep black`, `which pytest`, `Get-Command pytest`, `poetry show pytest`, `pip show black`, `npm ls prettier`, `cat pytest.ini`, `echo git add docs`, `pwsh -NoProfile -Command "Get-Process | Where-Object { $_.CommandLine -match 'Invoke-Pester' }"`, `pwsh -c "Select-String -Path x -Pattern Invoke-Pester"`.

### 6.4 Bookkeeping leg rows

The rows assume no checkpoint, the default configuration, and session-root resolution.

- Allow:
  - `git add .claude/agent-memory/r/notes.md`
  - `git add -- .claude/agent-memory/r/a.md docs/features/active/x/plan.md`
  - `git commit -m m -- .claude/agent-memory/r/a.md`
  - `git commit -F msg.txt -- .claude/agent-memory/r/a.md`
  - `git commit -m m` with a staged index of only `.claude/agent-memory/...` (mocked)
- Deny:
  - Index-dependent: `git commit -m m` with an empty, mixed, or unreadable index, or with an injected `-CheckpointRaw` (no root).
  - Option or pathspec shapes: `git commit -am m`, `git commit -a -m m`, `git commit --amend -m m`, `git add .`, `git add -A`, `git add .claude/agent-memory/` (equal to the root), `git add .claude/agent-memory/../src/x.ps1`, `git add .claude\agent-memory\x.md`.
  - Mixed segments: `git add .claude/agent-memory/a.md src/x.ps1`, `git add .claude/agent-memory/a.md && pytest`.
  - Unresolvable text: `git commit -m "$x" -- .claude/agent-memory/a.md`.
  - Configuration: a `[]` configuration (today's behavior), and an invalid configuration (deny with suffix).

## 7. Requirements Mapping and File Changes

### 7.1 Acceptance criteria to design

- AC(a): stage-2 confirmation (4.1, D1 to D3) using the existing iterator and matchers; corpus rows in 6.3 allow and 6.2 deny.
- AC(b): bookkeeping leg (4.2, D4, D5) and configuration (4.3, D6) with default `[".claude/agent-memory/"]`, validated, and documented.
- AC(c): regression corpus covering 6.2, 6.3, and 6.4 on both surfaces (D10), plus the unchanged existing suites.

### 7.2 Production files

- Modify:
  - `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`: `Test-ImplementationCommand` body, two guarded dot-sources, one leg call, and the header.
  - Their bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
- New (four byte-identical copies each):
  - `enforce-orchestration-preimplementation-gate-commands.ps1`
  - `enforce-orchestration-preimplementation-gate-bookkeeping.ps1`
- Pack manifests (dependency closure):
  - Add both new files to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
  - Add both new files to `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`. The hook entries in this manifest are hand-maintained: `render_manifest` in `scripts/dev_tools/generate_codex_agent_variants.py` appends only agent paths and re-serializes with `json.dumps(indent=2)`, so a hand edit must match that formatting.
- Batch budget: this exceeds three production PowerShell files, because bundle copies count. The item must run on the orchestrated `large` route.

### 7.3 Documentation files

- Execution-environment brief, six copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`. Add a new `## Hook Execution Context` bullet; the existing facts remain true.
- Orchestrate skill: `.agents/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` (`## Pre-Implementation Gate` paragraph). The planner should confirm whether `.claude/skills/orchestrate/SKILL.md` and its bundle carry an equivalent section (the search found none).

### 7.4 Files not to modify

`...-helpers.ps1`, `...-targets.ps1`, `...-cleanup.ps1`, `...-epic-scope.ps1`, `...-modes.ps1`, `hook-epic-fan-in.ps1`, `hook-command-*.ps1`, `hook-cleanup-context.ps1`, worktree-resolution modules, settings and registrations.

## 8. Tests That Assert the Gate's Denials or Deny Text (dispositions)

Unchanged and expected to pass. Each must be re-run in the parallel Pester gate.

- claude-hooks:
  - `enforce-orchestration-preimplementation-gate.Tests.ps1`: command denials and generic text. Note: its pathless `git commit -m "test"` runs with injected `-CheckpointRaw`, so under D9 the leg has no root and denies deterministically.
  - `.TriggerScoping.Tests.ps1`
  - `.Parity.Tests.ps1` and `.Parity.Cases.ps1`: the function inventory stays the same; extend CommandCases only if desired.
  - `.CommandExemption.Tests.ps1`, `-helpers.ChainEscape.Tests.ps1`, `-helpers.OperandNormalization.Tests.ps1`, `-helpers.Parity.Tests.ps1`
  - `.Cleanup.Tests.ps1`: DenySuffix rules; the configuration suffix must come after the cleanup suffix and be absent with the default configuration.
  - `.OperandBypass.Tests.ps1`, `.OperandResolution.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `.TargetWorktree.Tests.ps1`, `-absolute-paths.Tests.ps1`, `.AttributionTrailer.Tests.ps1`
  - `.EpicScope*.Tests.ps1`, `.EpicFanIn.Tests.ps1`, `.MergedFollowUp.Tests.ps1`, `-targets*.Tests.ps1`, `-mode-resolution*.Tests.ps1`, `-classifier.Tests.ps1`, `.C1bCoverage.Tests.ps1`
  - `hook-command-consumers.Issue824.Tests.ps1` (CN-06 to CN-08), `hook-command-parser.AcceptanceCases.Tests.ps1` (AT-6), `hook-command-invocation.Issue824Regression.Tests.ps1` (REG-08)
  - `hook-dependency-failure.Claude.Tests.ps1`, `hook-import-failure-exemptions.FailClosed.Tests.ps1`, `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`, `enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1`
- codex-hooks: `-trigger-scoping.Tests.ps1`, `-command-exemption.Tests.ps1`, `-command-exemption.Selectors.Tests.ps1`, `-cleanup.Tests.ps1`, `-target-worktree.Tests.ps1`, `-operand-bypass.Tests.ps1`, `-mode-routing.Tests.ps1`, `-mode-resolution*.Tests.ps1`, `-merged-follow-up.Tests.ps1`, `-epic-scope*.Tests.ps1`, `-epic-resolution.Tests.ps1`, `-epic-fan-in.Tests.ps1`, `codex-preimplementation-gate-absolute-paths.Tests.ps1`, `codex-pretooluse-transport.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`, `hook-import-failure-exemptions.FailClosed.Tests.ps1`.
- claude-runtime: `HookImportFailureExemptions.Helpers.ps1` (modes sibling only; unaffected); `hook-dependency-guard-completeness.Tests.ps1` (the new dot-sources must use the guarded form).
- Risk to verify in preflight: a suite that drives a pathless `git commit` through the decision without injecting `-CheckpointRaw`, with `Resolve-OrchestrationGateTarget` unmocked, would read the real index. Search the test tree for `git commit` rows without `--` and confirm that each injects `-CheckpointRaw` or mocks `Get-OrchestrationGateStagedIndex`.

New test files: a classification corpus with a Claude and a Codex runner (or one file with `-ForEach` runtimes), unit suites for the two new siblings, and four-copy parity tests for each sibling.

## 9. Testing Implications

- All decisions are driven through the pure seam `Invoke-OrchestrationPreimplementationGateDecision` with injected `-CheckpointRaw`, or through direct calls to the new pure functions. Configuration text and the staged index arrive through mocked seams. No temporary files, child processes, or clock reads.
- Gate: one `Invoke-PoshQCParallelTest` run (parallel only). Per-file line coverage of 85% or more for both new siblings, read from `artifacts/pester/powershell-coverage.xml`.
- Linux hook-suite job: fixtures use forward-slash relative paths and synthetic absolute roots of the form `/synthetic-worktrees/...`, with no drive letters (CI-only failure class).
- Contract tests: run `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness tests, `test_push_down_pack_manifest_dependency_closure.py`, the Codex generator `--check`, and `hook-dependency-guard-completeness.Tests.ps1`.
- `Invoke-PoshQCLeakScan`: the new suites must restore every mock and global they set.

## Numeric Derivation Evidence

No numeric count, enumeration size, or population is proposed for a `spec.md` acceptance criterion. Section 8 is a disposition inventory for the planner, not a numeric assertion. Any numeric AC the planner adds needs its own derivation evidence.

## Pre-Mortem

- Review checklists: a reviewer can flag (a) an undeclared widening, such as a pathless commit of #539-tree paths, or (b) a new function added to a gate file, which breaks the AC-18 inventory. Mitigation: the plan lists every D5 widening as a corpus row, keeps all new functions in the two siblings, and states the policy-level (not security) nature of the leg in the headers.
- Coverage: the new siblings are production PowerShell and need 85% line coverage or more. The I/O seams (configuration reader, staged-index reader) are thin and covered by mocked-seam tests. The plan names both files in the coverage comparison against the Phase 0 baseline.
- Mirror parity: four copies of each new sibling, two gate pairs with bundles, two `core.json` manifests (the Codex one hand-edited in `json.dumps(indent=2)` format), six execution-environment copies, and the orchestrate skill and its bundle. Mitigation: parity tests per sibling, the push-down contract tests, the generator `--check`, and a task that updates all six brief copies in the same change, named in this bullet.
- File size: the Codex gate is at 493 lines and rises toward 500 (guidance tier, no gate failure). Each new sibling stays below 500 by splitting along concern (commands versus bookkeeping). The helpers file is not edited (pinned at 500 or fewer).
- Test isolation: the risk is a real `git diff --cached` or a real configuration read inside a test. Mitigation: mock `Get-OrchestrationGateStagedIndex` and `Get-OrchestrationGateBookkeepingConfigText` in every suite that reaches the leg, keep the "no root when `-CheckpointRaw` is injected" rule, use no temporary files, and keep the leak scan clean.
- CI-only behavior: the Linux hook-suite job is case-sensitive and has no drive letters. A configuration path built with backslashes, or a root-strip helper that does not normalize separators, fails only there. Mitigation: `Join-Path` plus forward-slash normalization, and corpus rows with `/synthetic-worktrees/...` roots.
- Evidence: the Phase 0 baseline and final parallel-gate artifacts under `<FEATURE>/evidence/baseline/` and `<FEATURE>/evidence/qa-gates/`, with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`. Fail-before evidence for the 6.3 rows (they deny on the unfixed gate) is recorded under `<FEATURE>/evidence/regression-testing/`. Branch hooks are proven by Pester, not by isolated subagents.

## Automation Feasibility

No human interaction is required. Every change is code, tests, documentation, and manifests, verified by Pester suites and the existing contract tests. The live hook cannot be exercised by an isolated subagent until merge; acceptance therefore rests on Pester, as the execution-environment brief states.

## Rejected Alternatives (brief)

- Rewriting the five patterns with stricter regexes. This keeps keyword classification and cannot see payload structure.
- Extending the #539 tree list in the helpers file. That file is byte-pinned and capped at 500 lines, and the change still leaves pathless commits denied.
- Extending the shared `Test-CommandLinePayloadInert` sink list or the shared `Skip-CommandLineTransparentWrapper` `env -u` handling. Both change decisions of other consumers and conflict with sibling work.
- An empty default for `bookkeeping_roots`. It does not fix the reported defect.
- A configuration key inside `.claude/settings.json`. That file is runtime-owned, a mirror, and not schema-free.

## Items for the Orchestrator to Confirm

- SHA256 equality of the four copies of `...-helpers.ps1`, `...-targets.ps1`, `...-cleanup.ps1`, `hook-epic-fan-in.ps1`, and `hook-command-*.ps1` (these rest on file headers and line counts; the parity suites assert them).
- Which files #1163 actually modifies (`Resolve-OrchestrationGateTarget`, `Read-OrchestrationGateCheckpoint`, and session-root reads), to choose between the D9 suffix-strip and a returned root.
- Whether a pushed-down `config/` file would be overwritten in destinations (relevant only if the plan decides to commit `config/preimplementation-gate.json`).
