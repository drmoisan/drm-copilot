# Remediation Inputs — Issue 1160 (review 3 of PR #1174)

Timestamp: 2026-11-14T01-40
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate
Head: `25cc3ffce7b3ab58c716b724451ca395fe9e4425`
Base: `main`, merge base `eb73f1dff52e7175228a03740b53281c81e1c00c`
Source review artifacts:
- `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/policy-audit.2026-11-14T01-40.md`
- `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/code-review.2026-11-14T01-40.md`
- `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/feature-audit.2026-11-14T01-40.md`
Remediation plan target: `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/remediation-plan.2026-11-14T01-40.md`
Prior finding F2 (`remediation-inputs.2026-11-13T19-53.md`, cycle 3 per `remediation-inputs.2026-11-14T00-18.md`): resolved at this head.
Review standard: owner directive OD-1 and spec decision D18 (policy level; obfuscation-only variants are out of scope).

Path note: the single finding is autonomous and contained, but its fix changes a hook decision and needs a recorded spec decision, so it takes the full path.

## Findings requiring remediation

### F3 — Subcommand-scoped hosts read an option value as the subcommand

Severity: Blocking
Relation: related to issue #1160 (the D2 subcommand-scoped host rule added by this branch)
Remediability: autonomous
Remediability-Evidence: The fix is a rule change in one loop of the item's own commands sibling, its four byte-identical copies, the Cases file, and the commands suite, recorded as a spec decision; it needs no external system, CI result, or owner decision.
Finding-Scope: contained

- Location: the subcommand loop in `Test-OrchestrationGateMentionHostRecord` in `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, and both bundle copies under `extensions/drm-copilot/resources/`. The loop takes the first later token that does not start with `-` as the subcommand.
- Cause: the value of a value-taking global option (`npm -w`, `--workspace`, `--prefix`; `poetry -C`, `--directory`, `-P`; `pip --cache-dir`) is not an option token, so it is read as the subcommand. When the value equals a listed host subcommand, the record is accepted as a mention host and the hit is dropped.
- Observed: these twelve commands are classified by the merge-base decision and unclassified at head, identically on both surfaces (reviewer probes of `Test-ImplementationCommand`); each runs a governed tool:
  - `npm -w search run lint`
  - `npm --workspace search run lint`
  - `npm --prefix search run lint`
  - `npm --prefix help run lint`
  - `npm -w view run test:unit`
  - `npm -w help run typecheck`
  - `npm --prefix info exec prettier`
  - `poetry -C search run pytest`
  - `poetry --directory search run pytest`
  - `poetry --directory show run pytest`
  - `poetry -P show run pytest`
  - `pip --cache-dir list install black`
- Why it is in scope under OD-1: these are ordinary, documented forms of the workspace and directory options, and a workspace or directory named `search`, `view`, `info`, or `show` is a plain naming choice, not text written to evade the matcher.
- Required change: record decision D19 in `spec.md` (amending the D2 subcommand-scoped row and the D17 FP analysis) and implement it in all four byte-identical copies. A subcommand-scoped host is a host only when the token immediately after the command word (after transparent wrappers) is a listed subcommand; any option token before the subcommand keeps the hit. FP-07, FP-08, FP-11, FP-12, and FP-13 already have the subcommand in that position and stay unclassified. Stated cost: `git --no-pager log --grep pytest` becomes classified, as at the merge base (no widening, AC-3).
- Tests: add existing-denial rows for at least `npm -w search run lint`, `npm --prefix search run lint`, `poetry -C search run pytest`, `poetry --directory search run pytest`, and `pip --cache-dir list install black` to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (both runners), with the generic deny text. Add one named case for an option before a host subcommand to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1`. Confirm each new row fails on the current head before the fix (expect-fail evidence under `evidence/regression-testing/`).
- Verification required: task checks per the cadence; one `Invoke-PoshQCParallelTest` final gate with 0 failures, compared with the Phase 0 baseline (95.80% repo-wide lines); commands sibling coverage at least 90% on both surfaces; four-copy parity suites; FP, ED, and NG rows on both surfaces; push-down contract tests and generator check, because the bundle copies change. Then re-review.

## Non-blocking items (no remediation required in this PR)

- N1: hand-off through a host's own output-file option or prior state stays outside the model, as D17 records.
- N2: two uncovered lines per measured commands copy (99.01%); optional `-cwa` case.
- N3: `npm help --viewer=browser --browser=prettier lint` is declassified; out of scope under OD-1 / D18 (launcher abuse, not an ordinary invocation).
- N4: `ag --pager pytest x` is declassified; out of scope under OD-1 / D18 (the pager is ignored without a terminal).
- N5: thirteen evidence filename stamps differ from the write minute by one minute; disclosed, append-only kept.
- AC-24 is pending CI (queued at this head) and is not a finding.
- No finding unrelated to issue #1160 was identified.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run per gate, re-run only after a fix. No serial, single-process, shuffled, or reversed gate runs.
- Evidence is append-only; no artifact records an absolute path.
- No Python in the hook path; no edit to the shared `hook-command-` matcher files, the helpers, targets, cleanup, epic-scope, or modes siblings, `hook-epic-fan-in.ps1`, or hook registrations.
- Existing gate suites stay unmodified (AC-9, AC-17); `$script:SharedGateFunction` stays unchanged (AC-14).
