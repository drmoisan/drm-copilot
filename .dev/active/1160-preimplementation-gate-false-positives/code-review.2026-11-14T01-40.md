# Code Review: Pre-Implementation Gate False Positives (Issue #1160), Re-audit After Remediation Cycle 3

**Review Date:** 2026-11-14
**Branch:** `bug/preimplementation-gate-false-positives-1160` @ `25cc3ffce7b3ab58c716b724451ca395fe9e4425` (PR #1174)
**Base:** `main`; merge base `eb73f1dff52e7175228a03740b53281c81e1c00c` (`git merge-base origin/main HEAD` after a fetch)
**Scope:** full branch diff, 123 files (PowerShell gate and sibling hooks with bundle copies, ten new Pester files, six brief copies, two orchestrate copies, two pack manifests, feature-folder records)
**Review standard:** owner directive OD-1 and spec decision D18 (policy-level standard for stage 2).

## Executive Summary

Cycle 3 resolves F2. Decision D17 replaces the open-ended consumer walk with a closed rule: a stage-1 hit is dropped only when the command consists of allowlisted constructs, every carrying record is a mention-host operand, and every pipeline mate before or after the carrier is an accepted consumer. Any group, substitution, redirection, here-document, background job, comment, assignment word, compound command, shell-state builtin, or unparsed PowerShell node keeps the hit. The reviewer re-ran the sixteen F2 forms and ED-94 to ED-96 on both surfaces; all are classified at head, and FP-01 to FP-17 remain unclassified.

One blocking defect (F3) is in the subcommand selection of `Test-OrchestrationGateMentionHostRecord`, which D17 did not change. For a subcommand-scoped host it skips tokens that start with `-` and takes the next token as the subcommand. The value of a value-taking global option (`npm -w <name>`, `npm --prefix <dir>`, `poetry -C <dir>`, `poetry --directory <dir>`) is read as the subcommand. When that value is a listed host subcommand (`search`, `view`, `help`, `info`, `show`, `list`, and others), an ordinary runner invocation is declassified. Five non-blocking items follow, two of them dispositioned out of scope under OD-1 / D18.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (blocking, F3) | `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` and its three copies | `Test-OrchestrationGateMentionHostRecord`, the subcommand loop (`if (-not $tokens[$next].StartsWith('-', ...)) { $subcommand = $tokens[$next]; break }`) | The loop skips option tokens but not their values, so the value of a value-taking global option becomes the subcommand. Twelve runner invocations are classified by the merge-base decision and unclassified at head, identically on both surfaces: `npm -w search run lint`, `npm --workspace search run lint`, `npm --prefix search run lint`, `npm --prefix help run lint`, `npm -w view run test:unit`, `npm -w help run typecheck`, `npm --prefix info exec prettier`, `poetry -C search run pytest`, `poetry --directory search run pytest`, `poetry --directory show run pytest`, `poetry -P show run pytest`, `pip --cache-dir list install black`. The same commands with a path value (`npm -w packages/search run lint`, `poetry -C services/search run pytest`) or the `=` form (`npm --workspace=search run lint`) stay classified. | Record decision D19 (amending the D2 subcommand-scoped row) and implement it in all four copies: a subcommand-scoped host is a host only when the token immediately after the command word (after transparent wrappers) is a listed subcommand; any option before the subcommand keeps the hit. Add ED rows for at least `npm -w search run lint`, `npm --prefix search run lint`, `poetry -C search run pytest`, `poetry --directory search run pytest`, and `pip --cache-dir list install black` to the Cases file (both runners), one named case in `-commands.Tests.ps1`, and fail-before evidence. FP-07, FP-08, FP-11, FP-12, and FP-13 place the subcommand directly after the command word, so they stay unclassified. Cost: `git --no-pager log --grep pytest` becomes classified, as at the merge base (no widening, AC-3). | `npm -w <workspace> run lint` and `poetry -C <dir> run pytest` are ordinary, documented forms (the repository's own bash-command-shape rule prescribes `npm --prefix <abs>` and `poetry -C <abs>`). A workspace or directory named `search`, `view`, `info`, or `show` is a plain naming choice, not text written to evade the matcher, so OD-1 makes the declassification a defect. | Reviewer probes of `Test-ImplementationCommand` at head and with stage 2 forced to confirm (merge-base decision), `.claude/hooks` and `.codex/hooks` |
| Minor (N1) | same file | D17 N1 | A hand-off through a host's own output-file option across statements, or through state left by an earlier call, stays outside the model, as D17 states. | None. | Recorded in D17. | `spec.md` D17 |
| Info (N2) | same file | coverage | Two uncovered lines per measured copy: the `break` after a PowerShell `-CommandWithArgs`, `-cwa`, or `-EncodedCommand` flag whose payload is the last word (new in D17), and the unchanged `continue` after an Opaque NoPayload record without a governed word. Both copies are at 99.01%. | Optional: one modelled mention written with `-cwa` and the payload last. | Above every threshold; disclosed by the executor. | `evidence/qa-gates/coverage-comparison.2026-11-14T01-33.md`; reviewer parse of `powershell-coverage.xml` |
| Info (N3, out of scope under OD-1 / D18) | same file | `Get-OrchestrationGateMentionHostTable`, `npm` subcommands | `npm help --viewer=browser --browser=prettier lint` is unclassified at head and classified at the merge base. npm opens the help page with the configured `browser` command, so this form would start `prettier` with a URL argument. | None in this PR. | Using `npm help` as a launcher through its browser option is not an ordinary invocation of `prettier`; it is a further evasion variant of the kind D18 excludes. Disposition: out of scope under OD-1 / D18. | Reviewer probe S01 |
| Info (N4, out of scope under OD-1 / D18) | same file | `ag` host | `ag --pager pytest x` is unclassified at head and classified at the merge base. `ag` documents that the pager is ignored when output is not a terminal, which is the case for an agent tool call, so the form does not start `pytest` in the hook's context. | None in this PR. | Not an ordinary invocation, and inert without a terminal. Disposition: out of scope under OD-1 / D18. | Reviewer probe Q14 |
| Info (N5) | feature folder | `evidence/other/evidence-stamp-disclosure.2026-11-14T01-36.md` | Thirteen cycle 3 evidence filenames differ from their write minute by one minute; the executor disclosed this instead of renaming. | None. | Append-only rule kept; no content or file selection depends on the difference. | Disclosure file; `git diff --name-status 762a9c9e1..HEAD -- docs` shows additions only plus `spec.md` |

No covered file is at or above 700 logical lines (largest: Codex gate 499, commands sibling 489, Claude gate 485); no file-size Warning row applies. No finding unrelated to issue #1160 was identified.

## Detailed Review

### F2 re-verification

D17 adds four functions to the commands sibling. `Test-OrchestrationGatePosixTextModelled` scans the normalized text with quote awareness and rejects any unquoted `( ) { } < >`, backtick, `#`, lone `&`, ANSI-C quoting, a substitution inside double quotes, and a `$_` expansion when the text has more than one top-depth record. `Test-OrchestrationGatePowerShellPayloadModelled` parses the payload with `Parser::ParseInput` and accepts only the listed AST node types, with a scriptblock only as an argument of a host command. `Test-OrchestrationGateCommandModelled` applies both scans to the command and to each payload, and rejects reserved words, `eval`, `source`, shell-state builtins, `printf -v`, the `env` split-string option, assignment words, and a word after a payload. A backward walk from each carrier applies the accepted-consumer rule to earlier pipeline stages.

Reviewer probes on both surfaces: `(echo pytest) | xargs env`, `xargs env < <(echo pytest)`, `bash -c 'echo pytest; env $_'`, `git grep -iOpytest pytest`, and `rg --hostname-bin pytest x` are classified at head; FP-01 to FP-17 are unclassified at head. A host scriptblock that calls a runner directly (`pwsh -c "Get-ChildItem | Where-Object { pytest }"`, `Sort-Object { pytest $_.FullName }`, `Format-Table { pytest }`, `Where-Object { Invoke-Pester }` with `tests/scripts`) is classified at head, because the record reader expands the scriptblock body and the `pytest` record is not a host record. Ordinary compound forms (`which pytest && pytest -q`, `grep -r pytest . ; pytest`, `time pytest`, `pgrep -f pytest || pytest`, `bash -c 'grep pytest x; pytest'`, `pwsh -c "Get-Command pytest; pytest"`) are classified. F2 is resolved.

### F3, value-taking options before a host subcommand

`Test-OrchestrationGateMentionHostRecord` determines the subcommand for `git`, `npm`, `pip`, `pip3`, and `poetry` as the first later token that does not begin with `-`. Each of these tools has global options that take a separate value: `npm -w/--workspace`, `--prefix`, `-C`; `poetry -C/--directory`, `-P/--project`; `pip --cache-dir`, `--log`, `--python`; `git -C`, `-c`, `--git-dir`. The loop returns the option value as the subcommand. For `git -C . log` this keeps the hit (recorded as N4 in the first and second reviews). For `npm -w search run lint` the value `search` is in the `npm` subcommand set, so the record is accepted as a mention host, no other rule fires, D17 finds the command modelled, and the hit is dropped. The defect has existed since cycle 1 and is independent of D16 and D17.

The recommended fix keeps the D2 negative model and is fail-closed: require the listed subcommand to be the first token after the command word. Every FP row already has that shape. A value-aware option table per tool would also work but adds a table that must track each tool's option set; the fail-closed form costs only the classification of mentions written with a leading global option, which the merge base classifies as well.

Classification: autonomous (a rule change inside the item's commands sibling and tests, recorded as a spec decision; no external system, CI result, or owner decision is needed). Finding scope: contained (one loop in one function, four byte-identical copies, the Cases file, and the commands suite). The fix changes a hook decision, so the remediation path is full.

### Bookkeeping leg

Unchanged since the first review, which verified it by real-process probes; the final gate passes the leg suites on both surfaces.

### Tests

Cycle 3 adds ED-51 to ED-96 to the shared corpus and a new `Modelled` suite of 39 cases per surface (36 classified, 3 guards). The fail-before run shows exactly the 256 expected failures and no other failure, and the guards pass before and after, so the new rows discriminate. The existing commands suite changes in one assertion only (the `rg` executing-option pin).

### Mirrors and documentation

The commands sibling has one SHA256 (`c39100dc8993f104...`) across four copies and the bookkeeping sibling one (`55e6e9200b258924...`). Each gate file equals its bundle copy. The six brief copies share one SHA256 and each carries the D18 sentence once; the four sibling copies carry it once in the header. D17 and D18 are recorded in `spec.md` under `## Decisions`.

### Security and correctness

The header and D18 state that this is a policy-level control and not a security boundary. F3 is judged under that standard: the triggering commands are ordinary forms, not obfuscation. No absolute path appears in any changed file or evidence artifact.

## Verification Performed

- `git -C <item worktree> diff <merge base>..HEAD` over the gate files, the siblings, the corpus, and the suites; `git diff 762a9c9e1..HEAD` for the cycle 3 delta.
- Classification probes: 62 commands through `Test-ImplementationCommand` on the head Claude and Codex gates, at head and with stage 2 forced to confirm (the merge-base decision, since stage 1 is unchanged); Claude and Codex decisions identical on every command.
- Coverage: reviewer parse of `artifacts/pester/powershell-coverage.xml` (root and per-file LINE counters) matched `evidence/qa-gates/coverage-comparison.2026-11-14T01-33.md`.
- `sha256sum` of the sibling, gate, and brief copies; `grep -cF` of the D18 sentence; logical line counts (`@(Get-Content).Count`) of all 22 changed PowerShell files.
- `validate_evidence_locations.py --root <item worktree>`: exit 0.

## Verdict

**REMEDIATION REQUIRED.** F2 is resolved. One blocking finding (F3, autonomous, contained). N1 to N5 need no change in this PR; N3 and N4 are out of scope under OD-1 / D18.
