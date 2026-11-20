# Code Review: Pre-Implementation Gate False Positives (Issue #1160), Re-audit After Remediation Cycle 2

**Review Date:** 2026-11-13
**Branch:** `bug/preimplementation-gate-false-positives-1160` @ `762a9c9e12077f974bb0bc369abbd28e289afda5` (PR #1174)
**Base:** `main`; merge base `eb73f1dff52e7175228a03740b53281c81e1c00c` (`git merge-base origin/main HEAD` after a fetch)
**Scope:** full branch diff, 85 files (PowerShell gate and sibling hooks with bundle copies, nine new Pester files, six brief copies, two orchestrate copies, two pack manifests, feature-folder records)

## Executive Summary

Cycle 2 resolves F1. Decision D16 adds a consumer check: a record that follows a carrying record in the same pipeline, does not carry the governed word, and is not a mention host or a plain PowerShell expression confirms the hit. `NotHost` is now read in rule 3 and in the consumer check, and `sort --compress-program` is an executing option. The reviewer re-ran the seven F1 probe commands and the N1 form against the head gate and a `git archive` copy of the merge-base gate on both surfaces. All eight are classified at head and at base, and FP-01 to FP-17 remain unclassified on both surfaces.

One new blocking defect (F2). The D16 Posix walk follows a pipeline only while each same-depth record ends with `|`. The shared parser ends a record at a subshell or process-substitution boundary with a `(` or `)` delimiter, and at the close of a brace group with `;`. A pipeline that passes through one of these boundaries is therefore cut. A consumer that precedes the carrying record through `< <( ... )` is never examined, because the walk only looks forward. Four non-blocking items follow.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (blocking, F2) | `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` and its three copies | `Test-OrchestrationGateInvocationConfirmed`, the D16 consumer loop (`if ($record.Dialect -ne 'PowerShell' -and $previous.Delimiter -ne '\|') { break }`) | The walk stops at a `(`, `)`, or `;` delimiter that the shared parser emits at the same depth for `( ... )`, `{ ...; }`, `<( ... )`, and `>( ... )`, and it never looks at records before the carrying record. Sixteen real invocations are classified by the merge-base gate and unclassified at head, identically on both surfaces: `(echo pytest) \| xargs env`, `{ echo pytest; } \| xargs env`, `echo pytest \| (cat) \| xargs env`, `cat <(echo pytest) \| xargs env`, `cat < <(echo pytest) \| xargs env`, `xargs env < <(echo pytest)`, `xargs env 0< <(echo pytest)`, `xargs -n1 env < <(echo pytest)`, `xargs env < <(printf pytest)`, `xargs env < <(grep -o pytest x)`, `env < <(echo pytest) xargs env`, `while read c; do $c; done < <(echo pytest)`, `echo pytest > >(xargs env)`, `echo pytest 1> >(xargs env)`, `echo pytest >> >(xargs env)`, `grep -o pytest x > >(xargs env)`. | Record decision D17 (amending D16) and implement it in all four copies. For a `Posix` carrying record, do not end the walk at a `(` or `)` delimiter, and treat the records of the same statement on both sides of a process substitution as consumers. One fail-closed form: when any same-depth record of the command ends with `(` or `)`, or the command text holds a brace group, treat every non-carrying same-depth record of the command, before and after the carrying record, as a consumer. FP-01 to FP-17 contain none of these constructs, so they stay unclassified. Add ED rows for the sixteen forms on both runners and named cases to `-commands.Tests.ps1`, with fail-before evidence. | The issue requires classifying real invocations only; D16 states its purpose as examining the executing stage of a pipeline, and a process substitution or a group is a pipeline in shell semantics. D16 also claims that every row on which head and merge base agree keeps its value; these rows do not. | Reviewer probes of `Test-ImplementationCommand` (head Claude, head Codex, base Claude, base Codex); record dump of `Read-CommandLineInvocationSegment` showing `delim=[(]`, `[)]`, and `[;]` at depth 0 for these forms |
| Minor (N1) | same file | D16 scope | A file hand-off across a statement boundary, `echo pytest > f; xargs env < f`, is classified at base and unclassified at head. D16 limits the consumer check to a pipeline, and `;` ends it by design. | None required in this PR; the D17 record may state that a file hand-off across statements is outside the model, in the same way as `sh <launcher>.sh`. | A file intermediary has no syntactic link to its reader; following it would require data-flow tracking that a command-text gate does not do. | Reviewer probe B08 |
| Info (N2) | same file | coverage | The one uncovered line in each measured copy is the unchanged `continue` after the Opaque NoPayload check; no current test reaches an Opaque NoPayload record without a governed word. | Optional: a case such as `ls \| sh` with a stage-1 hit elsewhere. | Pre-existing and recorded by the executor. | `evidence/qa-gates/coverage-comparison.2026-11-13T19-19.md` |
| Info (N3) | `spec.md` | D16 cost | A PowerShell payload treats every later statement as a consumer, so `Get-Command pytest; Get-Date` is classified. D16 records this cost, and it matches the merge base. | None. | Fail-closed and documented. | Reviewer probe A21 |
| Info (N4) | same file | Subcommand lookup | Carried from the first review: `git -C . log --grep pytest` stays classified because the first non-option token after `git` is the `-C` value. | None required. | Conservative. | First review N3 |

No covered file is at or above 700 logical lines (largest: Codex gate 499, Claude gate 485, commands unit suite 361); no file-size Warning row applies. No finding unrelated to issue #1160 was identified.

## Detailed Review

### F1 re-verification

`Test-OrchestrationGateInvocationConfirmed` now walks forward from each carrying record. A record of greater depth is skipped as a nested payload, a record of lower depth ends the walk, and for a Posix carrying record the walk ends at the first same-depth record whose delimiter is not `|`. Each consumer is accepted only when it is a mention host with no executing option (through `Test-OrchestrationGateMentionHostRecord`, which reads `NotHost` first) or a PowerShell expression without `::` or `.Invoke`. Reviewer probes, head and merge base on both surfaces:

| Probe | Head Claude | Head Codex | Base |
|---|---|---|---|
| ED-43 to ED-48 (`Get-ChildItem tests/scripts/...` or `Get-Command ...` piped to `ForEach-Object` or `%`) | classified | classified | classified |
| ED-49 `echo pytest \| xargs env` | classified | classified | classified |
| ED-50 `sort --compress-program pytest big.txt` | classified | classified | classified |
| FP-01 to FP-17 | unclassified | unclassified | classified |

Further PowerShell probes are classified at head: `Where-Object`, `Select-Object`, `Sort-Object`, `Format-Table`, and `Measure-Object` with a script block calling `&`; `& (Get-Command pytest)`; `$c = Get-Command pytest; & $c`; `Tee-Object -Variable c; & $c`; and `Invoke-Item` consumers. Further Posix probes are classified at head: `|&`, a newline after `|`, `timeout`, `nice`, `command`, `exec`, and `env sh` consumers; `tee >(sh)`; `if` and `for` compound producers; and here-strings into `xargs`. The PowerShell design is sound.

### F2, pipeline cut at group and process-substitution boundaries

A record dump of `Read-CommandLineInvocationSegment` shows the cause:

- `(echo pytest) | xargs env`: `echo pytest` at depth 0 with delimiter `)`, then `xargs env` at depth 0. The `|` after the group is not recorded on the `echo` record, so the walk breaks before `xargs`.
- `{ echo pytest; } | xargs env`: `echo pytest` with delimiter `;`; the same break.
- `cat <(echo pytest) | xargs env`: `cat <` with delimiter `(`, `echo pytest` with delimiter `)`, then `xargs env`. The walk from `echo` breaks at `)`.
- `xargs env < <(echo pytest)`: `xargs env < <` with delimiter `(`, then `echo pytest`. The consumer precedes the carrying record, and the walk only looks forward.
- `echo pytest > >(xargs env)`: `echo pytest > >` with delimiter `(`, then `xargs env`. The walk breaks at `(`.

The sixteen forms in the table all execute `pytest` (through `xargs env`, or through `$c` in the `while` loop). Each is classified by the merge-base gate on both surfaces. Forms that consume through a mention host stay correctly unclassified at head and need not change: `cat <(echo pytest) | grep x`, `ps aux > >(grep pytest)`, and `echo pytest > >(cat)`. They are classified at base, so classifying them under a fail-closed D17 is not a widening. `echo pytest 2> >(xargs env)` and `echo pytest >(xargs env)` do not execute `pytest`; a fail-closed rule may classify them, which matches the base.

The fix changes the D16 rule text and needs corpus rows on both surfaces and four-copy edits, so it is design scope. It needs no external system or owner decision, so it is autonomous. The parser files (`hook-command-*`) are protected by D9 and must not be edited; the fix belongs in the commands sibling.

### Bookkeeping leg

Unchanged since the first review, which verified it by real-process probes; the post-merge gate passes the leg suites on both surfaces.

### Tests

Cycle 2 adds ED-43 to ED-50 to the shared corpus and 17 D16 cases per surface to the commands suite. The fail-before run shows exactly the 66 expected failures (32 classification, 34 commands-suite) and no other failure, and the five guard cases pass before and after, so the new rows discriminate. The guard `does not treat records nested in a wrapper payload as consumers of the wrapper` uses the P1 input, `accepts a PowerShell expression consumer without :: or .Invoke` is present (P2), and `confirms a consumer with an executing option` is present (P3).

### Mirrors and documentation

The commands sibling has one SHA256 (`e32ac31e98c618d9...`) across four copies; the six brief copies share one SHA256; no protected file changed against the merge base. The sibling header documents rules 1 to 5 and the `NotHost` precedence.

### Security and correctness

The header states this is a policy-level control. F2 is a correctness defect against the issue's own requirement and D16's stated property, not a security claim. No absolute path appears in any changed file or evidence artifact.

## Verification Performed

- `git -C <item worktree> diff <merge base>..HEAD` over the gate files, the siblings, the corpus, and the commands suite.
- Classification probes: 122 commands through `Test-ImplementationCommand` on the head Claude and Codex gates and on a `git archive` copy of the merge-base gates; Claude and Codex decisions identical on every command.
- Record dumps of `Read-CommandLineInvocationSegment` for seven forms.
- Coverage: reviewer parse of `artifacts/pester/powershell-coverage.xml` (root and per-file LINE counters) matched `evidence/qa-gates/pester-gate.2026-11-13T19-43.md`.
- `sha256sum` of the four sibling copies; logical line counts of all 21 changed PowerShell files.
- `validate_evidence_locations.py --root <item worktree>`: exit 0.

## Verdict

**REMEDIATION REQUIRED.** F1 is resolved. One new blocking design finding (F2). N1 to N4 need no change in this PR.
