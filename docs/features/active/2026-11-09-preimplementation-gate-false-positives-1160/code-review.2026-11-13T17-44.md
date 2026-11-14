# Code Review: Pre-Implementation Gate False Positives (Issue #1160)

**Review Date:** 2026-11-13
**Branch:** `bug/preimplementation-gate-false-positives-1160` @ `4767fe8a35e9a1b8f404ff827f009098b7ed9855` (PR #1174)
**Base:** `main`; merge base `18520b3fce8b6273ac63a16fef03816f7119dcad` (equals `origin/main` at review time)
**Scope:** full branch diff, 56 files (PowerShell gate and sibling hooks with bundle copies, nine new Pester files, six brief copies, two orchestrate copies, two pack manifests, feature-folder records)

## Executive Summary

The change is well contained. Stage 1 is untouched, so no command is newly classified; stage 2 and the bookkeeping leg live in two byte-identical siblings with guarded loading; the bookkeeping leg composes with the #539 exemption, the #1026 cleanup leg, and the `-C` selector check without editing any of them. The reviewer ran the shipped Claude gate as a real process against JSON payloads in a scratch repository with no checkpoint: agent-memory `git add`, pathless `git commit -m` with an agent-memory-only index, and `git commit -F <file> -- <agent-memory path>` allow; `git add src/x.py`, a pathless commit with a mixed index, and `pytest -q` deny with the unchanged text; an invalid and a `[]` configuration deny.

One blocking design defect (F1): stage 2 judges each invocation record independently, so a pipeline in which a mention host emits the governed word and a later stage executes it is no longer classified. Four non-blocking items follow.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (blocking, F1) | `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` and its three copies | `Test-OrchestrationGateInvocationConfirmed`, the per-record loop (`if (-not $carries[$position]) { continue }`) | A record that does not carry the governed word is skipped before any host check, so an executing consumer fed by a carrying mention host is never examined. These commands are classified by the merge-base gate and unclassified at head on both surfaces: `pwsh -NoProfile -Command "Get-ChildItem tests/scripts/run.ps1 ... ForEach-Object { & $_.FullName }"` (pipe between the two cmdlets), the same with `% { & $_ }`, `Get-ChildItem tests/scripts/ -Filter *.Tests.ps1` piped to `ForEach-Object { & $_ }`, `Get-Command pytest` piped to `ForEach-Object { & $_ }` and to `ForEach-Object { & $_.Source -q }`, `Get-Command Invoke-Pester` piped to `ForEach-Object { & $_ }`, and `echo pytest` piped to `xargs env`. Each runs the governed tool or a script under `tests/scripts/`. | Record a spec decision (D16) and confirm a stage-1 hit when a record that follows a carrying record in the same pipeline is not itself a mention host (for example `ForEach-Object`, `%`, `foreach`, `xargs`, `env`, `Invoke-Item`, or any unmodelled command word), or at least when it is a `NotHost` entry, an evaluator, the call operator `&`, or an `xargs` wrapper. Add existing-denial rows for these forms to `Classification.Cases.ps1` and named cases to `-commands.Tests.ps1`; confirm FP-01 to FP-17 still allow (each pipes only into hosts such as `grep` and `Where-Object`). | The issue asks the gate to classify only real invocations; D2 states the negative model fails closed for launchers it does not model, and its table marks `ForEach-Object` as not a host because it can execute its arguments. The per-record rule defeats that marking whenever the argument arrives through the pipeline. | Reviewer probes of `Test-ImplementationCommand` at head (Claude and Codex identical) and on a `git archive` copy of the merge-base hooks; all seven forms return true at base and false at head |
| Minor (N1) | `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | `Get-OrchestrationGateMentionHostTable`, `ExecutingOption` | `sort` is a host with no executing-option exclusion, but `sort --compress-program <prog>` runs `<prog>`; `sort --compress-program pytest big.txt` is classified at base and unclassified at head. | Optional: add `sort = @('--compress-program')` to `ExecutingOption` with a pin row, in the F1 cycle. | Same class as `rg --pre`, which the table already excludes; the form is unlikely in practice. | Reviewer probe at head |
| Info (N2) | `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | `NotHost` table key | The decision logic never reads `NotHost`; a command word not in a host list is already a non-host, so the entry is documentation pinned by a test. | Optional: either consult it in the F1 pipeline rule or state in the help text that it is descriptive. | Avoids implying an enforcement that does not exist. | Reading of the function body |
| Info (N3) | same file | Subcommand lookup | `git -C . log --grep pytest` stays classified because the first non-option token after `git` is the `-C` value. This fails closed and matches D2. | None required. | Conservative; consistent with the negative model. | Reviewer probe at head |
| Info (N4) | `spec.md` | AC-22 | AC-22 names `evidence/coverage/`, which is not a canonical evidence sub-path; the executor recorded the override and wrote the figures under `evidence/qa-gates/`. | None; the substitution follows `evidence-and-timestamp-conventions`. | Recorded so the AC-22 PASS is not read as a location defect. | `evidence/qa-gates/coverage-comparison.2026-11-13T17-27.md` |

No covered file is at or above 700 logical lines (largest: Codex gate 499, Claude gate 485); no file-size Warning row applies. No finding unrelated to issue #1160 was identified.

## Detailed Review

### F1, pipeline-fed execution

`Read-CommandLineInvocationSegment` returns one record per pipeline stage and per expanded payload. Stage 2 counts records that carry a governed word and requires each such record to be led by a host. A stage that does not carry the word is skipped (`if (-not $carries[$position]) { continue }`) unless its command word is an evaluator. `ForEach-Object { & $_ }` carries no governed word, so it is skipped, and the carrying `Get-ChildItem tests/scripts/...` or `Get-Command pytest` record is a host. The hit is dropped.

The same gap applies to `xargs`: the wrapper clause ("a wrapper whose payload never carries the word confirms") runs only for a wrapper record that itself carries the word. In `echo pytest | xargs env`, the `xargs` record does not carry `pytest`, so the clause never runs, while `xargs` runs `env pytest`. `echo pytest | xargs sh -c` stays classified only because `sh -c` without a payload is an Opaque `NoPayload` record.

The FP rows do not need this path: every FP row pipes into a host (`grep`, `Where-Object`) or has no pipeline. A rule that confirms the hit when any later stage of the same pipeline is not a mention host keeps all 17 FP rows allowed and restores the base decision for the seven forms above. Because it changes the D2 rule text, it needs a recorded decision and corpus rows, so it is a design-scope fix. It requires no external system or owner decision, so it is autonomous.

### Bookkeeping leg

The leg runs after the cleanup leg, so it can only convert a deny into an allow. The predicate is the union of the #539 trees and the declared roots, and the D14 anchor requires at least one declared-root path, so #539-tree-only commands keep the previous deny text. The worktree root is derived from the checkpoint read path; with injected `-CheckpointRaw` there is no root and a pathless commit denies without reading the index. The predicate records observed paths through the caller's scope chain; this works because `hook-epic-fan-in.ps1` is dot-sourced into the same script scope, as the real-process probe confirmed. The configuration parser rejects every invalid shape the spec lists, and the suffix is appended after the cleanup suffix.

### Tests

The corpus is shared by both surface runners, and the fail-before run shows exactly the 68 FP tests failing on the unfixed gates while every ED and NG row passed, so the FP rows discriminate. The unit suites mock both seams and create no files. The parity suites pin four-copy SHA256 identity and the 500-line bound.

### Mirrors and documentation

Both siblings have one SHA256 digest across four copies; both gate files equal their bundle copies; both `core.json` manifests list both siblings; the six brief copies carry the same bullet; the orchestrate base equals its bundle. The orchestrate paragraph and brief bullet describe the default, `[]` opt-out, and invalid-file suffix accurately.

### Security and correctness

The headers state this is a policy-level control. F1 is a correctness defect against the issue's own requirement, not a security claim. No absolute path appears in any changed file or evidence artifact.

## Verification Performed

- `git -C <item worktree> diff 18520b3fc..HEAD` over both gate files, both siblings, the brief and orchestrate copies, and the manifests.
- Classification probes: 28 commands through `Test-ImplementationCommand` on the head Claude and Codex gates (identical output), and 16 commands compared between head and a `git archive` copy of the merge-base hooks.
- Real-process probe: `pwsh -File` of the head Claude gate with JSON payloads in a scratch git repository with no checkpoint, 9 cases.
- Coverage: reviewer parse of `artifacts/pester/powershell-coverage.xml` (root and six per-file LINE counters) matched the coverage-comparison evidence.
- `sha256sum` of the sibling copies; `cmp` of gate bundle copies; brief bullet comparison.
- `validate_evidence_locations.py --root <item worktree>`: exit 0.

## Verdict

**REMEDIATION REQUIRED.** One blocking design finding (F1). N1 may be folded into the same cycle; N2 to N4 need no change.
