# Remediation Inputs — Issue 1160 (review 2 of PR #1174)

Timestamp: 2026-11-13T19-53
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design
Head: `762a9c9e12077f974bb0bc369abbd28e289afda5`
Base: `main`, merge base `eb73f1dff52e7175228a03740b53281c81e1c00c`
Source review artifacts:
- `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/policy-audit.2026-11-13T19-53.md`
- `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/code-review.2026-11-13T19-53.md`
- `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/feature-audit.2026-11-13T19-53.md`
Remediation plan target: `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/remediation-plan.2026-11-13T19-53.md`
Prior finding F1 (`remediation-inputs.2026-11-13T17-44.md`): resolved at this head.

Path note: the single finding is autonomous but changes the D16 rule text and a hook decision, which requires a recorded spec decision, edits to all four sibling copies, and new corpus rows on both surfaces, so it takes the full path.

## Findings requiring remediation

### F2 — D16 consumer walk is cut at group and process-substitution boundaries

Severity: Blocking
Relation: related to issue #1160 (the D16 rule added by this branch)
Remediability: autonomous
Remediability-Evidence: The fix is a rule change inside the item's own commands sibling and its tests, recorded as a spec decision in the same manner as D16; it needs no external system, CI result, or owner decision.
Finding-Scope: design

- Location: the D16 consumer loop in `Test-OrchestrationGateInvocationConfirmed` in `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, and both bundle copies under `extensions/drm-copilot/resources/`. The loop breaks when `$record.Dialect -ne 'PowerShell' -and $previous.Delimiter -ne '|'`, and it walks only forward from the carrying record.
- Cause: `Read-CommandLineInvocationSegment` (protected by D9, not to be edited) emits same-depth records ending with `(` or `)` for subshell groups and process substitutions, and ending with `;` at the close of a brace group. The `|` that follows a group is not recorded on the group's last record. So the walk stops before the executing stage, and a consumer that reads a process substitution through `< <( ... )` precedes the carrying record and is never examined.
- Observed: these sixteen commands are classified by the merge-base gate and unclassified at head, identically on both surfaces (reviewer probes of `Test-ImplementationCommand`); each executes `pytest`:
  - `(echo pytest) | xargs env`
  - `{ echo pytest; } | xargs env`
  - `echo pytest | (cat) | xargs env`
  - `cat <(echo pytest) | xargs env`
  - `cat < <(echo pytest) | xargs env`
  - `xargs env < <(echo pytest)`
  - `xargs env 0< <(echo pytest)`
  - `xargs -n1 env < <(echo pytest)`
  - `xargs env < <(printf pytest)`
  - `xargs env < <(grep -o pytest x)`
  - `env < <(echo pytest) xargs env`
  - `while read c; do $c; done < <(echo pytest)`
  - `echo pytest > >(xargs env)`
  - `echo pytest 1> >(xargs env)`
  - `echo pytest >> >(xargs env)`
  - `grep -o pytest x > >(xargs env)`
- Required change: record decision D17 in `spec.md` (amending D16) and implement it in all four byte-identical copies. For a `Posix` carrying record, the walk must not end at a `(` or `)` delimiter, must follow a pipeline out of a subshell or brace group, and must treat the records of the same statement on both sides of a process substitution as consumers. One fail-closed form: when any same-depth record of the command ends with `(` or `)`, or the command holds a brace group, treat every non-carrying same-depth record of the command, before and after the carrying record, as a consumer. Keep FP-01 to FP-17 unclassified (none contains a group or a process substitution). Classifying mention-only forms such as `cat <(echo pytest) | grep x` is acceptable, since the merge base classifies them (no widening, AC-3). State in D17 that a file hand-off across statements (`echo pytest > f; xargs env < f`, code review N1) stays outside the model.
- Tests: add existing-denial rows for the sixteen forms to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (both runners), with the generic deny text. Add named confirm cases for the group, brace-group, input process-substitution, output process-substitution, and preceding-consumer shapes to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1`. Add one guard case showing that a mention-host consumer through a process substitution (`ps aux > >(grep pytest)`) is judged by the same accepted-consumer rule. Confirm each new row fails on the current head before the fix (expect-fail evidence under `evidence/regression-testing/`).
- Verification required: task checks per the cadence; one `Invoke-PoshQCParallelTest` final gate with 0 failures, compared with the Phase 0 baseline (95.80% repo-wide lines); commands sibling coverage at least 90% on both surfaces; four-copy parity suites; FP, ED, and NG rows on both surfaces; push-down contract tests and generator check, because the bundle copies change. Then re-review.

## Non-blocking items (no remediation required in this PR)

- N1: file hand-off across a statement boundary is outside the D16 pipeline model; record it in D17.
- N2: the unchanged Opaque NoPayload `continue` line is uncovered; optional test.
- N3: PowerShell later-statement cost is documented in D16; no change.
- N4: `git -C . log --grep pytest` stays classified; conservative, no change.
- AC-24 is pending CI (run 43494990169 in progress at this head) and is not a finding.
- No finding unrelated to issue #1160 was identified.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run per gate, re-run only after a fix. No serial, single-process, shuffled, or reversed gate runs.
- Evidence is append-only; no artifact records an absolute path.
- No Python in the hook path; no edit to the shared `hook-command-` matcher files, the helpers, targets, cleanup, epic-scope, or modes siblings, `hook-epic-fan-in.ps1`, or hook registrations.
- Existing gate suites stay unmodified (AC-9, AC-17); `$script:SharedGateFunction` stays unchanged (AC-14).
