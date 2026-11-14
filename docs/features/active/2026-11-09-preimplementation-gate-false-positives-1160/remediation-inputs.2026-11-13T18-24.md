# Remediation Inputs — Issue 1160 (cycle 2)

Timestamp: 2026-11-13T18-24
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate
Opened by: review 1 of PR #1174 (head `4767fe8a35e9a1b8f404ff827f009098b7ed9855`), carried forward from cycle 1
Prior cycle: `remediation-inputs.2026-11-13T17-44.md` and `remediation-plan.2026-11-13T17-44.md`. Cycle 1 ended at `blocked_preflight_iteration_limit` with no execution and no candidate applied.
Remediation plan target: `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/remediation-plan.2026-11-13T18-24.md`

Mode note: every finding below is fixed without changing an acceptance criterion's text or a public interface. The file inventory stays within the branch diff plus its tests and mirrors. Decision D16 is recorded in `spec.md`, which is in the feature folder.

## Findings requiring remediation

### F1 — Stage 2 declassifies a mention host piped into an executing consumer

Severity: Blocking
Relation: related to issue #1160
Remediability: autonomous
Finding-Scope: design

The finding, the seven probe commands, and the required change are unchanged from `remediation-inputs.2026-11-13T17-44.md` (F1). The cycle 1 remediation plan `remediation-plan.2026-11-13T17-44.md` implements F1, N1, and N2. That plan was cleared of every defect except the three below.

### P1 — Cycle 1 confirming preflight: wrapper-nesting guard cannot fail

Severity: Blocking
Relation: related to issue #1160 (test coverage of decision D16)
Remediability: autonomous
Finding-Scope: contained

In [P1-T3], change the input of `does not treat records nested in a wrapper payload as consumers of the wrapper` to `sh -c "make build; grep pytest x" | sort` (index 1). It returns false at head and under D16, and true under a mutant that treats nested payload records as consumers. Update the Pre-Mortem `Coverage` bullet.

### P2 — Cycle 1 confirming preflight: accepted expression consumer has no test

Severity: Blocking
Relation: related to issue #1160 (test coverage of decision D16)
Remediability: autonomous
Finding-Scope: contained

In [P1-T3], add the guard case `accepts a PowerShell expression consumer without :: or .Invoke` with input `pwsh -c "Get-Command pytest; $null"` (index 1). It returns false at head and under D16, and true under a mutant in which every expression consumer confirms. The guard count becomes five. Name the case in the Pre-Mortem `Coverage` bullet.

### P3 — Cycle 1 confirming preflight: executing option on a consumer has no test

Severity: Blocking
Relation: related to issue #1160 (test coverage of decision D16)
Remediability: autonomous
Finding-Scope: contained

In [P1-T3], add the confirm case `confirms a consumer with an executing option` with input `echo pytest | sort --compress-program gzip` (index 1). It returns false at head, true under D16, and stays false under a mutant whose consumer check ignores executing options. [P1-T3] then names fifteen new confirm cases and five guard cases. [P1-T4] names "the 66 expected tests ... (8 rows x 2 tests x 2 runners, and 17 cases x 2 surfaces)". Name the case in the Pre-Mortem `Coverage` bullet.

## Constraints

The constraints of `remediation-inputs.2026-11-13T17-44.md` (`## Constraints`) apply unchanged.
