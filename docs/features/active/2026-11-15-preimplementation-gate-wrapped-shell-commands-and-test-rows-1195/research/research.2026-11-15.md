# Research: Preimplementation gate wrapped shell commands and #1188 R3 test rows (Issue #1195)

- Issue: #1195 (full-bug)
- Branch: `bug/gate-wrapped-shell-test-commands`
- Research date: 2026-11-15
- Sources read: this worktree (`main` state) and, read-only, the #1188 worktree on branch `bug/gate-sibling-worktree-pytest-target` (PR #1191, not merged at research time per the delegation prompt).
- All paths are repository-relative. Line counts are ripgrep line counts (`^` match count), which equal logical lines; the orchestrator should confirm any count it relies on with `@(Get-Content -LiteralPath <path>).Count` (see `## Facts for the Orchestrator to Confirm`).

## 1. Summary of Findings

1. The gap is stage 1 only. Stage 2 (`Test-OrchestrationGateInvocationConfirmed`) and the structural staging check already expand literal wrapper payloads. A wrapped command passes unclassified because the stage-1 regex anchor `(^|\s)` does not match a governed word that directly follows the quote character that opens the payload. The issue text "the second-stage classifier inspects top-level command segments only; wrapper payloads are opaque strings" is not accurate for stage 2 (verified below); the opaque treatment is in stage 1.
2. #1188 (unmerged) adds a stage-1 supplement sibling, `enforce-orchestration-preimplementation-gate-classify.ps1`, whose result `$supplementalIndex` is unioned into the stage-1 loop of both gates. That sibling and its case table are the natural home for both parts of #1195. Part 2 (R3 rows) cannot be done on `main` at all, because the functions under test exist only on the #1188 branch.
3. Recommended approach: a new pure function `Get-OrchestrationGateWrappedPatternIndex` in the classify sibling that returns the stage-1 indexes 1 to 4 matched by a literal wrapper payload, scanned exactly as a bare command line is scanned (per-segment `ScanText`, plus the #1188 supplement), recursively for literal nested wrappers. Each gate changes one existing line (the `$supplementalIndex` assignment) and gains no line. Stage 2 still judges the whole command, so every new hit must still be confirmed.
4. The six R3 rows are four function rows (`Indexes = @()`) and two Negative gate rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1`; each one is derived below with the guard whose removal makes it fail.
5. No existing test asserts that a wrapped test or lint command is allowed in a form the change would reclassify. Every wrapper row with `Expected = $false` or `Should -BeFalse` was traced and keeps its disposition.

## 2. Current State Analysis

### 2.1 Stage 1 in both gates

`Test-ImplementationCommand` (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`; `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`) holds five patterns:

| Index | Pattern | Governed words (stage 2) |
|---|---|---|
| 0 | `(^|\s)git\s+(add|commit)\b` (plus structural `Test-CommandLineInvocation` for `git add`/`git commit`) | `git` |
| 1 | `(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b` | black, ruff, pyright, pytest |
| 2 | `(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b` | prettier, lint, typecheck, test:unit |
| 3 | `(^|\s)npx\s+(prettier|eslint|tsc|jest)\b` | prettier, eslint, tsc, jest |
| 4 | `(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)` | Invoke-Pester, path marker `tests/scripts/` |

The patterns run against `@(Read-CommandLineSegment -CommandText $normalizedCommand).ScanText` (`.claude/hooks/hook-command-scanner.ps1`). `ConvertTo-CommandLineSegmentRecord` sets `ScanText` to `RawText` when the segment is wrapper-led (`$script:CommandLineWrapperNames`: sh, bash, zsh, dash, ksh, pwsh, powershell, xargs, env, command, eval, nohup, time, timeout), carries a live substitution, or is unbalanced; otherwise to `MaskedText` (quoted spans replaced by spaces).

Consequence for `sh -c "pytest -q"`: the segment is wrapper-led, so `ScanText` is the raw text `sh -c "pytest -q"`. In it `pytest` is preceded by `"`, so `(^|\s)` fails and pattern 1 does not match. Stage 2 is never called. Verified by reading the pattern and scanner code; consistent with the #1188 reviewer probe (`code-review.2026-11-15T21-47.md`, Info row: `sh -c "npm run lint"`, `bash -c "npx jest"`, and `pwsh -Command "npm run lint"` return false).

Forms that are already classified on `main` (and therefore are not the defect):

- A governed word preceded by whitespace inside the payload: `sh -c "poetry run pytest"` (matches ` pytest`), `sh -c "cd x && npm run lint"`, `sh -c pytest` (unquoted).
- `pwsh ... Invoke-Pester` and `pwsh ... tests/scripts/` in any position, because pattern 4 is anchored on the outer `pwsh` word (row ED-06).
- `git add`/`git commit` in a payload, through the structural check: `Get-CommandLineInvocation` (`.claude/hooks/hook-command-invocation.ps1`) walks the payload records of `Read-CommandLineInvocationSegment` and reports a Structural match (rows ED-14, ED-15, ED-23; trigger-scoping wrapper deny pins 2 and 3).

The defect set is therefore: a literal wrapper payload whose governed form starts at the payload's opening quote (for patterns 1 to 3: `"pytest`, `'ruff`, `"npm run lint"`, `"npx jest"`; for pattern 4: a quote-adjacent `pwsh` inside another wrapper, `bash -c "pwsh -File tests/scripts/x.Tests.ps1"`), under any of the payload wrappers `sh`, `bash`, `zsh`, `dash`, `ksh` (`-c` or a bundle such as `-lc`), `pwsh`/`powershell` (`-c`, `-Command` prefixes, `-CommandWithArgs`/`-cwa`), and `eval`.

### 2.2 Stage 2 already understands payloads

`Test-OrchestrationGateInvocationConfirmed` (`.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, byte-identical in four copies) reads `Read-CommandLineInvocationSegment` (`.claude/hooks/hook-command-payload.ps1`), which expands `sh`/`bash`/`zsh`/`dash`/`ksh -c`, `pwsh`/`powershell -c`/`-Command`/`-CommandWithArgs`/`-EncodedCommand` (decoded by `ConvertFrom-CommandLineEncodedCommand` in `hook-command-payload-powershell.ps1`), `eval`, double-quoted substitution bodies, and `xargs`, up to `MaxDepth` 4. Its rule for a wrapper record (`$wrappers -contains $leaf`) judges the record through its payload records, and a payload record that carries a governed word and is not a mention host confirms the hit. Traced for the new forms:

- `sh -c "pytest -q"`: wrapper record carries `pytest` (whole-token presence `(?<![\w-])pytest(?![\w-])` matches after `"`), payload record `pytest -q` has leaf `pytest`, not a host, so the hit is confirmed.
- `pwsh -Command "npm run lint"`: PowerShell payload record `npm run lint` carries `lint`; leaf `npm` with subcommand `run` is not in the `npm` subcommand host list, so confirmed.
- `bash -c "pwsh -File tests/scripts/x.Tests.ps1"`: the payload record is Opaque `NoPayload` (`pwsh -File`) and carries the path marker, so rule 1 confirms.
- `sh -c "echo pytest"`, `sh -c "ps aux | grep pytest"`: payload records are mention hosts and the command is modelled, so the hit is dropped (existing behavior; the outer raw scan already hits these today).

Answer to the delegation question "is the stage-1 regex the gap, the payload extraction, or both?": the stage-1 regex anchor is the gap. Payload extraction exists (`Get-CommandLineWrapperPayload`, `Get-CommandLinePowerShellPayload`) and is used by stage 2 and the structural staging check, but stage 1 never applies the patterns to an extracted payload.

### 2.3 One extraction limit found during tracing

`Skip-CommandLineTransparentWrapper` skips `env` dash tokens and `NAME=value` tokens but not the value of `env -u NAME`. For `env -u VIRTUAL_ENV bash -c "pytest"` the command word resolves to `VIRTUAL_ENV`, so `Get-CommandLineWrapperPayload` finds no wrapper and no payload is extracted. Stage 2 would still confirm such a hit (leaf `VIRTUAL_ENV` is not a host), but stage 1 never hits, so the form stays unclassified. This is the form the brief prescribes for Poetry and pytest in agent worktrees (`env -u VIRTUAL_ENV ...`), so it is an ordinary invocation, not obfuscation. The recommended function handles the `env` value options locally (section 3) and does not edit the shared `hook-command-payload.ps1` (484 lines, byte-identical across surfaces, used by many hooks).

### 2.4 #1188 changes the baseline (branch `bug/gate-sibling-worktree-pytest-target`)

- New sibling `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` (133 lines; byte-identical in `.codex/hooks/` and both bundles, pinned by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1`, which also pins a 500-line bound and three wording tokens in `## Hook Execution Context` of the six brief copies).
- Both gates dot-source it (guarded: `try { . (Join-Path $PSScriptRoot '...-classify.ps1') } catch { Add-HookDependencyFailure ... }`) and add, in `Test-ImplementationCommand`:
  `$supplementalIndex = @(Get-OrchestrationGateSupplementalPatternIndex -CommandText $normalizedCommand)` and the loop condition `-not ($structural -or $supplementalIndex -contains $index -or (<ScanText match>))`.
- New sibling `enforce-orchestration-preimplementation-gate-operands.ps1` (296 lines) for target resolution.
- The Codex gate shrinks from 500 to 485 lines on the #1188 branch; the Claude gate grows from 491 to 493.
- Row NG-02 (`npx --yes jest`, previously a non-goal) is removed from `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` because #1188 classifies it.

Sequencing consequence: #1195 must start from `main` after PR #1191 merges (merge `main` into the #1195 branch as the first step). Without that merge the R3 rows have no code to test, and the Codex gate is at 500 lines with no room for even a dot-source line.

## 3. Candidate Approaches

### A. Widen the stage-1 anchor to `(^|[\s"'])` in the five patterns (rejected)

Zero new code and zero line growth. Rejected because the anchor applies to every raw-scanned segment, including live-substitution and unbalanced segments that are not wrappers. Example: `gh pr create --body "$(cat x) 'ruff'"` is raw-scanned (live substitution), would newly hit pattern 1 at `'ruff`, and stage 2 would confirm it (the `gh` record carries `ruff` and is not a host), so an unrelated command would be newly denied. It also changes the five pattern literals that the #1160 contract and the brief state are kept, and the #1188 supplement duplicates two of them.

### B. Recurse `Test-ImplementationCommand` on each payload (rejected)

Stage 2 would then judge the payload alone and lose the outer pipeline context that D16 and D17 depend on (for example a non-host consumer after the wrapper), and the index-0 bookkeeping exemption would be evaluated on a fragment. It also needs a recursion guard in both gates, which costs Codex gate lines.

### C. Payload stage-1 index function in the classify sibling, unioned into `$supplementalIndex` (selected)

Description:

- Add `Get-OrchestrationGateWrappedPatternIndex -CommandText <string> -Pattern <string[]>` to `enforce-orchestration-preimplementation-gate-classify.ps1` (pure string logic; no dot-source, consistent with the file's header). It returns the ascending subset of indexes 1, 2, 3, 4 for which some literal payload text P satisfies: a `ScanText` of `Read-CommandLineSegment -CommandText (ConvertTo-CommandLineNormalizedText P)` matches `Pattern[index]`, or `Get-OrchestrationGateSupplementalPatternIndex -CommandText P` contains the index. Index 0 is excluded because the structural staging check already sees payload `git add`/`git commit`.
- Payload enumeration (depth limit 4, matching `Read-CommandLineInvocationSegment`): for each segment of the normalized text, take `Split-CommandLinePosixWord -Text <segment TokenText>`; strip a leading `env` with its value options (`-u NAME`, `--unset NAME`, `--unset=NAME`, `-C DIR`, `--chdir DIR`, `--chdir=DIR`, other dash tokens, `NAME=value`), but decline an `env` split-string option (`-S`, `--split-string`), which D17 already treats as unmodelled; call `Get-CommandLineWrapperPayload -Word`; accept only `Kind` `Posix` (sh family `-c`, `eval`) and `Kind` `PowerShell` that is not Opaque and whose host flags contain no encoded-command flag (`-e`, `-ec`, or a prefix of `-encodedcommand` of length 3 or more, the same predicate as line 354 of the commands sibling); for `Kind` `Words` (xargs) re-examine the injected word list for a wrapper; emit P and recurse into P.
- In both gates, change the existing line to
  `$supplementalIndex = @(Get-OrchestrationGateSupplementalPatternIndex -CommandText $normalizedCommand) + @(Get-OrchestrationGateWrappedPatternIndex -CommandText $normalizedCommand -Pattern $implementationCommandPatterns)`.
  Passing the gate's own pattern array avoids a further copy of the pattern literals.

Advantages: the payload is classified exactly as the bare command (issue Expected Behavior), including the #1188 forms inside a payload (`sh -c "npm --prefix $(pwd) run lint"`); masking inside the payload keeps quoted mentions unclassified (`sh -c "echo 'pytest'"`); stage 2 still sees the whole command, so every new hit goes through D16, D17, and D19 unchanged; zero line growth in either gate; no new file, so no new manifest entry, parity test, or legacy-codex shared-module entry.

Limitations: one more function in a byte-identical four-copy file; the R3 mutant probe must run against the final classify text; `powershell -Command "Invoke-Pester"` stays unclassified because pattern 4 names `pwsh` only (see section 4, non-goals).

Alignment: follows the #1188 precedent of a stage-1 supplement in this sibling, the guarded dot-source already in place, and the PowerShell-only hook rule (no Python).

## 4. Behavior Semantics

Success conditions (classified after the change, unclassified before):

- A literal payload of `sh`/`bash`/`zsh`/`dash`/`ksh -c` (including option bundles such as `-lc`), `pwsh`/`powershell -c`/`-Command` (prefix of length 4 or more)/`-CommandWithArgs`/`-cwa`, or `eval`, after optional transparent wrappers (`env` with value options, `timeout`, `time -p`, `command`, `nohup`) and through `xargs`, whose segment scan or #1188 supplement matches pattern 1, 2, 3, or 4, and which stage 2 confirms against the whole command.
- Literal nested wrappers (`bash -c "bash -c 'pytest'"`) up to depth 4.

Unchanged (stays allowed or stays classified exactly as today):

- Quoted mentions inside a payload (masked), mention-host payloads that stage 2 drops, and every row of the existing ExistingDenial, FalsePositive, and NonGoal tables.
- Out of scope under decision D18, pinned by Negative rows so a later change is deliberate: a payload held in a variable (`sh -c "$CMD"`, `CMD=pytest; sh -c "$CMD"`), an `-EncodedCommand` payload, a payload built at run time, and the `env -S` split string.
- Non-goals recorded with rationale: `powershell -Command "Invoke-Pester"` and `powershell -File tests/scripts/...` (pattern 4 vocabulary names `pwsh`; the same gap exists at the top level, so it is a pattern-vocabulary change, not a wrapper change); `cmd /c "pytest"` (an evaluator, not a payload wrapper, and outside the issue's wrapper list); a quote-adjacent command word after a non-payload transparent wrapper (`timeout 60 "pytest"`); `bash -c -- "pytest"` (the `--` token is taken as the payload by `Get-CommandLineWrapperPayload`).

Ordering: the union is evaluated before the stage-1 loop; the loop order (index 0 first, bookkeeping exemption only for index 0) is unchanged. Failure behavior: a dot-source failure of the classify sibling already denies naming the file (row I2 in both classify test files).

## 5. Requirements Mapping

### 5.1 Part 1: wrapped payload classification

File changes (after merging `main` with #1188):

| File | Change |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` and its three byte-identical copies (`.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`) | Add `Get-OrchestrationGateWrappedPatternIndex` (and, if needed, one private helper for the env and encoded-flag checks); update the `.DESCRIPTION` to state the third form and the D18 exclusions. Expected size about 190 lines, within the pinned 500 bound. |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, plus their bundle copies | Modify the `$supplementalIndex` line only (no line added). |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` | New tables `$script:ClassifyWrappedFunctionRows` (Command, Indexes) and `$script:ClassifyWrappedGateRows` (Kind, Command, Expected); keep them separate from the R3 tables, whose header defines Indexes as a subset of 2 and 3. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` | One `It ... -ForEach` per new table on each surface. |
| Six brief copies (section 7) and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1` | Brief text update; optionally add a wording token (for example `#1195`) to the parity wording row. |

Proposed wrapped gate rows (Kind as defined in the Cases header; the planner verifies each by a fail-before run):

- Positive (false before, true after): `sh -c "pytest -q"`; `bash -c 'ruff check .'`; `bash -lc "pyright"`; `sh -c "npm run lint"`; `bash -c "npx jest"`; `pwsh -Command "npm run lint"`; `pwsh -NoProfile -c "pytest"`; `powershell -Command "npx eslint ."`; `eval "pytest"`; `env -u VIRTUAL_ENV bash -c "pytest"`; `timeout 600 sh -c 'npx jest'`; `echo x | xargs sh -c 'pytest'`; `bash -c "bash -c 'pytest'"`; `bash -c "pwsh -File tests/scripts/x.Tests.ps1"`; `sh -c "npm --prefix $(pwd) run lint"`.
- Negative (false before and after): `sh -c "echo 'pytest'"`; `bash -c "grep -rn 'ruff' docs/"`; `pwsh -c "Write-Output 'npm run lint'"`; `echo "sh -c 'pytest'"`; `sh -c "$CMD"`; `CMD=pytest; sh -c "$CMD"`; `pwsh -EncodedCommand cAB5AHQAZQBzAHQA` (the literal is the base64 of the UTF-16LE text `pytest`, computed by hand in this research; the planner must recompute it with `[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes('pytest'))` before use); `powershell -Command "Invoke-Pester"`.
- Control (true before and after): `sh -c "poetry run pytest"`; `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"`; `bash -c 'git add .'`; `sh -c "cd x && npm run lint"`.

A Negative row whose payload stage 2 drops (for example `sh -c "ps aux | grep pytest"`) is already false today and stays false; it may be added as a Negative row but proves stage 2, not the new function.

### 5.2 Part 2: the six R3 rows

Cycle-3 checks in `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` (#1188 branch), with the condition each enforces:

| Check | Function | Condition (source lines) |
|---|---|---|
| C1 unclosed-substitution member filter, `$(`/`${` arm | `Get-OrchestrationGateJoinedWordText` | a run member is skipped when, in the joined text before it, closers `)`/`}` are fewer than openers `$(`/`${` (lines 91-95, term `$beforeClosers -lt $beforeOpeners`) |
| C2 unclosed-substitution member filter, backtick arm | `Get-OrchestrationGateJoinedWordText` | a run member is skipped when the joined text before it holds an odd number of backticks (term `$beforeBackticks % 2 -ne 0`) |
| C3 member-tail match | `Get-OrchestrationGateSupplementalPatternIndex` | the npm and npx patterns are matched against `$member.Tail` (joined text from that member to the run end), not the whole run text (lines 125-126) |
| C4 member `npm` word check | `Get-OrchestrationGateSupplementalPatternIndex` | index 2 needs `Test-CommandLineWordPresent -RawText $member.Raw -Word 'npm'` (line 125) |
| C5 member `npx` word check | `Get-OrchestrationGateSupplementalPatternIndex` | index 3 needs `Test-CommandLineWordPresent -RawText $member.Raw -Word 'npx'` (line 127) |

Per the #1188 reviewer probe, C1 is pinned by the existing row `echo $(npm --version) lint` (mutants N1, N3), the run construction is pinned by the Positive rows (N4, N8), and C2, C3, C4, C5 (mutants N2, N5, N6, N7) are pinned by no row. The mutant scripts are in the gitignored `artifacts/scratch-issue-1188/` of the #1188 worktree and were not read.

The six rows (all in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1`, which both `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` consume):

| Row | Table | Command | Expected | Check removed that makes it fail | Trace at head |
|---|---|---|---|---|---|
| R3-1 | `$script:ClassifyFunctionRows` | `` echo `npm --version` lint `` | `Indexes = @()` | C2 (N2) | the member `npm --version` follows one backtick, so it is skipped; the first member's tail starts `` echo `npm `` where `npm` follows a backtick, so `(^|\s)npm` fails. Without C2 the member is kept and its tail `` npm --version` lint `` matches index 2. |
| R3-2 | `$script:ClassifyFunctionRows` | `echo $(echo npm --version) lint` | `Indexes = @()` | C4 (N6) | the first member `echo ` has the matching tail `echo $(echo npm --version) lint` but its raw text lacks `npm`; the `echo npm --version` member is inside an unclosed `$(` and skipped. Without C4 index 2 is returned. |
| R3-3 | `$script:ClassifyFunctionRows` | `FOO=$(echo npx jest) ls` | `Indexes = @()` | C5 (N7) | the first member `FOO=` has a tail matching the npx pattern but lacks `npx`; the `echo npx jest` member is skipped. Without C5 index 3 is returned. |
| R3-4 | `$script:ClassifyFunctionRows` | `FOO=$(echo npm x lint) npm --version` | `Indexes = @()` | C3 (N5) | the member ` npm --version` carries `npm` but its tail ` npm --version` does not match; the whole run text does (` npm x lint`). Matching the run text instead of the tail returns index 2. |
| R3-5 | `$script:ClassifyGateRows` (Kind `Negative`) | `` echo `npm --version` lint `` | `$false` | C2 (N2) | no segment alone matches pattern 2, so stage 1 has no hit; under N2 the supplement returns 2 and stage 2 keeps it (an unquoted backtick is unmodelled under D17), so the command would be classified. |
| R3-6 | `$script:ClassifyGateRows` (Kind `Negative`) | `echo $(echo npm --version) lint` | `$false` | C4 (N6) | no segment alone matches pattern 2 (`echo npm --version` has no script word); under N6 the supplement returns 2 and stage 2 keeps it (unquoted `$(` is unmodelled), so the command would be classified. |

No gate row is proposed for R3-3 and R3-4: on both commands a top-level segment (`echo npx jest`, `echo npm x lint`) already matches its pattern at stage 1 and stage 2 keeps the hit (unquoted `$(`), so the gate classifies them with or without the guard and a gate row could not discriminate. This matches the R3 fix text ("the first two commands become classified by the gate").

Verification required by R3: the new rows pass on both surfaces, and an in-memory probe that applies each of N2, N5, N6, and N7 to the classify source fails at least one new row, with the unmutated control failing none. The probe must run against the final classify text of #1195 (after Part 1), because Part 1 edits the same file.

Interaction with Part 1:

- Same production file (classify sibling) and same Cases file; Part 1 must leave the five cycle-3 checks byte-unchanged, and the R3 probe runs after Part 1.
- None of the six commands contains a payload wrapper (`echo` and an assignment are not payload wrappers), so `Get-OrchestrationGateWrappedPatternIndex` returns no index for any of them and the union leaves R3-5 and R3-6 false. The function rows drive `Get-OrchestrationGateSupplementalPatternIndex` alone and are unaffected by the union.
- Part 1 calls `Get-OrchestrationGateSupplementalPatternIndex` on each payload, so the C1 to C5 guards then also protect wrapped forms. A wrapped variant of a mention such as `sh -c 'echo $(echo npm --version) lint'` is already classified on `main` (the raw wrapper segment matches ` npm --version) lint`, and stage 2 keeps it as unmodelled), so wrapped R3 variants cannot serve as discriminating Negative gate rows; do not add them as such.

## 6. Size, Mirrors, Manifests, and Contract Tests

### 6.1 Logical line counts (ripgrep count)

| File | `main` (this worktree) | #1188 branch |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 491 | 493 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | 485 |
| `-classify.ps1` (both runtimes) | absent | 133 |
| `-operands.ps1` (both runtimes) | absent | 296 |
| `-commands.ps1` (both runtimes) | 489 | 489 |
| `-bookkeeping.ps1` (both) | 290 | 290 |
| `-cleanup.ps1` (both) | 481 | 481 |
| `-docs.ps1` (both) | 347 | 347 |
| `-helpers.ps1` (both) | 470 | 470 |
| `-targets.ps1` (both) | 433 | 433 |
| `-modes.ps1` Claude / Codex | 496 / 493 | 496 / 493 |
| `-epic-scope.ps1` Claude / Codex | 408 / 468 | 418 / 491 |
| `-epic-resolution.ps1` (Codex only) | 493 | 493 |
| `-parallel-records.ps1` (Claude only) | 136 | 136 |
| `hook-command-scanner.ps1` / `-payload.ps1` / `-payload-powershell.ps1` / `-invocation.ps1` / `-invocation-operands.ps1` / `-heredoc.ps1` (both) | 400 / 484 / 201 / 482 / 198 / 119 | same |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` | absent | 91 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` | absent | 85 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` | absent | 83 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1` | absent | 77 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` | 235 | 236 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Tests.ps1` | 92 | 92 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classification.Tests.ps1` | 89 | 89 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1` | 380 | 380 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Modelled.Tests.ps1` | 97 | 97 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | 344 | 344 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | 357 | 357 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | not measured | 517 |

The Codex siblings `-modes.ps1` (493), `-epic-resolution.ps1` (493), and `-epic-scope.ps1` (491 on #1188) are near the 500-line cap that `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` enforces for the files in `$script:SharedModuleNames`; none of them is touched by the recommended design. `hook-command-payload.ps1` (484) and `hook-command-invocation.ps1` (482) are also not touched.

### 6.2 Dot-source pattern, mirrors, manifests

- Guarded dot-source: each sibling is loaded as `try { . (Join-Path $PSScriptRoot '<file>') } catch { Add-HookDependencyFailure -Name '<file>' -ErrorRecord $_ }`, and `Get-HookDependencyFailureDecision -ReasonPrefix 'PREIMPLEMENTATION_GATE_BLOCKED:'` denies when any load failed. `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` pins the pattern. The recommended design adds no dot-source.
- Mirrors: the classify sibling and the two gates each exist in `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`. The classify sibling is byte-identical across all four (SHA256, `...-classify.Parity.Tests.ps1`); each gate's bundle copy must equal its source (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`).
- Pack manifests: on the #1188 branch `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` already list `enforce-orchestration-preimplementation-gate-classify.ps1`. A new sibling (not recommended) would need an entry in both (the Codex `core.json` is produced by `scripts/dev_tools/generate_codex_agent_variants.py`, checked with `--check`), an entry in `$script:SharedModuleNames` of `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, and a parity test.
- Contract tests to run after the edits: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` (the classify sibling has no `$PSScriptRoot` dependency, so closure is unchanged), the Codex generator `--check`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Parity.Tests.ps1` (unchanged file, still run), `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` (shared Claude/Codex `Test-ImplementationCommand` table), and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (500-line cap, root/bundle identity).

## 7. Existing Tests That Assert Wrapper Behavior

Search scope: `tests/` of this worktree and the #1188 worktree. Search strategies: (1) a regex for a payload wrapper followed by `-c`, `-Command`, `-EncodedCommand`, `-ec`, or `-e` restricted to `*preimplementation*` files; (2) a regex for `-c`/`-Command`/`-CommandWithArgs`/`-cwa` followed by a quote and a governed word over all of `tests/`; (3) `Test-ImplementationCommand -Command '<wrapper> ` over all of `tests/`.

Rows that assert a wrapped command is allowed or unclassified, with their disposition under the recommended design:

| Test | Command | Assertion | Disposition |
|---|---|---|---|
| `enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` FP-16 | `pwsh -NoProfile -Command "Get-Process \| Where-Object { $_.CommandLine -match 'Invoke-Pester' }"` | `$false` | unchanged: the payload masks the quoted word; pattern 4 needs `pwsh`, absent from the payload |
| same file FP-17 | `pwsh -c "Select-String -Path x -Pattern Invoke-Pester"` | `$false` | unchanged: no pattern 1 to 4 match in the payload |
| same file NG-08 | `pwsh -c "Invoke-Expression 'pytest'"` | `$false` | unchanged: `'pytest'` is masked in the payload scan |
| same file NG-09 | `pwsh -c "[Diagnostics.Process]::Start('pytest')"` | `$false` | unchanged: the quoted word is masked |
| `enforce-orchestration-preimplementation-gate-commands.Tests.ps1` | `sh -c "ps aux \| grep pytest"`, `sh -c "make build; grep pytest x" \| sort`, `pwsh -c "Get-Command pytest"; make build`, `pwsh -c "Get-Command pytest; $null"`, `pwsh -NoProfile -Command "Get-Process \| Where-Object {...'Invoke-Pester'...}"` | `Test-OrchestrationGateInvocationConfirmed ... \| Should -BeFalse` | unaffected: these call stage 2 directly, which the design does not change |
| `hook-command-consumers.Issue824.Tests.ps1` | `pwsh -NoProfile -Command 'Write-Output "digit address"'` | `Test-ImplementationCommand ... \| Should -BeFalse` | unchanged: no governed word |

Every other wrapper row found (ED-06, ED-14, ED-15, ED-23, ED-32 to ED-35, ED-43 to ED-48, ED-72 to ED-94 wrapper rows, the `Modelled.Tests.ps1` rows, the trigger-scoping wrapper deny pins 2, 3, and 5 on both surfaces, `hook-command-parser.AcceptanceCases.Tests.ps1` line asserting the `pwsh ... Invoke-Pester` form) asserts classification or deny; the design only adds indexes, so these stay true. The `test-execution-command-form.Tests.ps1`, `enforce-test-execution-policy.Tests.ps1`, `WorktreePoetryVenv.Cases.ps1`, `validate-bash.TriggerScoping.Tests.ps1`, and `bash-command-shape-guidance.Tests.ps1` wrapper rows belong to other hooks and are unaffected. Result: no existing assertion changes disposition. The `TriggerScoping.Tests.ps1` header text (stating that `bash -c`/`sh -c` forms "fail the `(^|\s)` boundary") is a historical description for #545 and asserts nothing.

## 8. Execution-Environment Brief Text This Change Alters

Copies (byte-identical, six): `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.

Facts in `## Hook Execution Context` (text as on the #1188 branch, which #1195 inherits):

1. Bullet "Preimplementation gate classification and bookkeeping leg (#1160)": "... and no command is newly classified; issue #1188 later classifies exactly two further forms, an npm script word after a substitution-split shell word and npx options before the tool word." This becomes false. Proposed replacement adds: issue #1195 classifies a literal payload of `sh`/`bash`/`zsh`/`dash`/`ksh -c`, `pwsh`/`powershell -c`/`-Command`/`-CommandWithArgs`, and `eval` (after `env` with its value options, `timeout`, `time`, `command`, `nohup`, or `xargs`) as it classifies the bare command, through `Get-OrchestrationGateWrappedPatternIndex` in `enforce-orchestration-preimplementation-gate-classify.ps1`, with every hit still confirmed by stage 2; an `-EncodedCommand` payload, a payload held in a variable, and a payload built at run time stay out of scope (decision D18).
2. Bullet on target resolution ("For `npm` and `npx`, `Test-ImplementationCommand` also classifies ... through `enforce-orchestration-preimplementation-gate-classify.ps1` (#1188)"): still true; optionally extend with one clause naming the wrapped-payload form so the classify file's responsibilities are stated in one place.
3. `## Contract Tests That Pin Mirrored Files`, the classify parity bullet: unchanged unless the parity test gains a new wording token, in which case the bullet's description of what it pins is updated.

No CI job, required context, tool route, or batch-budget rule changes.

## 9. Testing Implications

- Test files: the two classify `Tests.ps1` files (one `It -ForEach` per new table on each surface) and the shared classify `Cases.ps1`. Rows are in-memory; no temporary files, clock, process, or network access (the existing BeforeAll isolation pattern of the classify tests applies).
- Fail-before: the Positive wrapped rows and none of the Negative or Control rows fail against the pre-change hooks; record under `<FEATURE>/evidence/regression-testing/` with clock-read UTC stamps. The six R3 rows pass before and after (they pin existing behavior); their discrimination proof is the reverted-mutant probe (N2, N5, N6, N7), recorded as evidence with its command and result.
- Task checks run the selection through `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <paths>`; gates are one parallel `Invoke-PoshQCParallelTest` run through the launcher. No serial, shuffled, or single-process runs; test-order dependence is a violation.
- Coverage: the new function must reach the 85% line threshold in the classify file (the file reports 100% on #1188); read per-file figures from `artifacts/pester/powershell-coverage.xml` of the gate run.

## Numeric Derivation Evidence

### Claim N1: R3 requires six rows (four function rows, two gate rows)

- Complete Family: the regression rows that #1188 finding R3 requires for the cycle-3 classify checks.
- Exhaustive Search Scope: #1188 feature folder files `remediation-inputs.2026-11-15T21-47.md`, `code-review.2026-11-15T21-47.md`, `feature-audit.2026-11-15T21-47.md`.
- Inclusion Rules: a row named in a Fix or Recommendation for R3.
- Exclusion Rules: Info rows (wrapper payloads, M4, Form 1 mentions), and the existing `echo $(npm --version) lint` row.
- Primary Search Strategy or Query Expression: read the `Fix:` bullet of Finding R3 in `remediation-inputs.2026-11-15T21-47.md`.
- Primary Member Set: function rows `` echo `npm --version` lint ``, `echo $(echo npm --version) lint`, `FOO=$(echo npx jest) ls`, `FOO=$(echo npm x lint) npm --version`; Negative gate rows `` echo `npm --version` lint ``, `echo $(echo npm --version) lint`.
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: read the Recommendation cell of the Blocker row in the Findings Table of `code-review.2026-11-15T21-47.md`.
- Cross-check Member Set: function rows with `Indexes = @()` for the four commands `` echo `npm --version` lint ``, `echo $(echo npm --version) lint`, `FOO=$(echo npx jest) ls`, `FOO=$(echo npm x lint) npm --version`; Negative gate rows (`Expected = $false`) for `` echo `npm --version` lint `` and `echo $(echo npm --version) lint`.
- Cross-check Count: 6.
- Member-set Comparison: identical after normalization (same four function commands, same two gate commands, same table targets).

### Claim N2: four cycle-3 guards are unpinned (C2 to C5; mutants N2, N5, N6, N7)

- Complete Family: guards added in #1188 cycle 3 to the classify sibling that no row discriminates.
- Exhaustive Search Scope: `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` (#1188 branch, lines 42-133) and the R3 records.
- Inclusion Rules: a cycle-3 condition whose reversal changes the returned indexes for some command and that no existing row detects.
- Exclusion Rules: C1 (`$(`/`${` arm), detected by the existing row `echo $(npm --version) lint`; the run-start condition (cycle 1, mutant M4).
- Primary Search Strategy or Query Expression: code reading of the member filter (lines 91-95) and the member loop (lines 124-128), tracing each condition against the existing rows in `enforce-orchestration-preimplementation-gate-classify.Cases.ps1`.
- Primary Member Set: backtick arm of the member filter; member-tail match; member `npm` word check; member `npx` word check.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: the reviewer's mutant list in `feature-audit.2026-11-15T21-47.md` (remediation item 1) and `remediation-inputs.2026-11-15T21-47.md` (Observed bullet).
- Cross-check Member Set: N2 (backtick arm), N5 (tail instead of run text), N6 (member `npm` check), N7 (member `npx` check).
- Cross-check Count: 4.
- Member-set Comparison: one-to-one (C2=N2, C3=N5, C4=N6, C5=N7).

### Claim N3: six execution-environment brief copies

- Complete Family: byte-identical copies of the execution-environment brief.
- Exhaustive Search Scope: the brief's `## Purpose and Maintenance` paragraph and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1` (#1188 branch).
- Inclusion Rules: a path named as a copy of the brief.
- Exclusion Rules: other skills.
- Primary Search Strategy or Query Expression: the maintenance paragraph ("byte-identical in six locations": three source paths and their bundled copies).
- Primary Member Set: `.claude/skills/...`, `.agents/skills/...`, `.github/skills/...`, and the three bundle copies under `extensions/drm-copilot/resources/`.
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: the `-ForEach` list of the wording `It` in the classify parity test.
- Cross-check Member Set: the six `Copy` values listed in section 8.
- Cross-check Count: 6.
- Member-set Comparison: identical.

## Pre-Mortem

- Review checklists: a reviewer will check that every new hit is still confirmed by stage 2 and that no existing FalsePositive or NonGoal row flips; mitigation: the plan runs the full shared Classification table and the classify tables on both surfaces, includes the Negative and Control wrapped rows above, and states the D18 exclusions in the classify header and the brief.
- Coverage: the new function's env-option, encoded-flag, xargs, and depth-limit branches can leave lines uncovered below 85%; mitigation: one function row per branch (env `-u`, `--unset=`, `-S` declined, encoded flag declined, xargs words, nested depth 4 limit, empty command) and per-file figures read from the gate run's coverage XML.
- Mirror parity: the classify sibling must stay byte-identical in four copies, each gate's bundle copy must equal its source, and the six brief copies must change together; mitigation: one copy task after the edit, then the classify parity test, the push-down resource-contract tests, and the Codex generator `--check`; the Mirror parity bullet of the plan names the brief-update task.
- File size: the Codex gate is at 500 lines on `main`; mitigation: the design adds no gate line, the plan starts only after #1188 merges (Codex gate 485), and the classify sibling stays near 190 lines against its pinned 500 bound; no other Codex sibling near 500 is touched.
- Test isolation: new rows must not depend on state left by other files; mitigation: rows are data in the shared Cases file, driven by the existing classify BeforeAll mocks, with no global or environment mutation, so `Invoke-PoshQCLeakScan` stays clean; gates run in parallel only.
- CI-only behavior: the Linux hook-suite job runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on a case-sensitive file system; mitigation: row strings carry no drive letters or backslash paths, the base64 literal is ASCII, and file names keep exact case.
- Evidence: fail-before must show the Positive wrapped rows failing and the R3 discrimination must show N2, N5, N6, and N7 each failing a row; mitigation: append-only evidence files with clock-read UTC stamps under `<FEATURE>/evidence/regression-testing/`, the R3 probe run against the final classify text after Part 1, and no absolute paths (scratch recorded as `SCRATCH`).

## 12. Facts for the Orchestrator to Confirm (need git or gh)

- PR #1191 (#1188) merge state and merge commit; #1195 work starts after `main` contains it. If it is still open, the plan's first task waits for the merge and then merges `main` into `bug/gate-wrapped-shell-test-commands`.
- That the classify sibling, the two gates, and the Cases file on `main` after the #1188 merge equal the #1188 branch text read here (no later cycle on #1188).
- Line counts above, with `@(Get-Content -LiteralPath <path>).Count`, at the post-merge base.
- The item checkpoint `route_id` is `large` (or another batch-budget-exempt route): the design edits at least eight production PowerShell files (four classify copies and four gate copies), which exceeds the direct-mode cap of three.

## 13. Rejected Alternatives (brief)

- Widen the `(^|\s)` anchor in the five patterns: newly classifies unrelated raw-scanned commands such as a `gh` command with a quoted governed word after a live substitution; changes pinned pattern literals.
- Recurse `Test-ImplementationCommand` on payloads: stage 2 would lose whole-command pipeline context (D16, D17) and the Codex gate would need new lines.
- New sibling file for the wrapper function: needs manifest entries in two `core.json` files, a legacy-codex shared-module entry, a parity test, and a Codex gate dot-source line, with no behavioral benefit over the classify sibling.
- Edit `Skip-CommandLineTransparentWrapper` in `hook-command-payload.ps1` to skip `env -u` values: shared by many hooks across surfaces at 484 lines; the local handling in the new function is contained.

## Owner Directive

OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | - | Ran the research to completion without pausing; open choices were decided in the document (design C, D18 exclusions, non-goals) with rationale recorded.
