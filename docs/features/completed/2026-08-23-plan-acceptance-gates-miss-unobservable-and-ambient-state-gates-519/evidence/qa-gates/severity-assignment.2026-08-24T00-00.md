# Severity Assignment — [P6-T5]

Timestamp: 2026-08-26T13-34
Task: [P6-T5]
Command: `poetry run python -c "import scripts.dev_tools.plan_gate_observability as m; print(m.G7_SEVERITY, m.G8_SEVERITY, m.G8B_SEVERITY, m.G9_SEVERITY)"`, then `poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py -k severity`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

Both commands exited 0. Each exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect; no pipe stands between either command and its capture. The `-c` form is single-line, because a multi-line `-c` exits 0 on this host having done nothing.

## The assignment, per rule

The decision rule is the one pre-declared by [P6-T1] and committed as `7a339fac` before any count was taken. The counts are those recorded by [P6-T3] in `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/corpus-measurement.2026-08-24T00-00.md`. The rule is applied mechanically to those counts and to nothing else.

### G7 — `G7_SEVERITY`

- **Counts:** corpus files 194, candidates 519, findings 466, true positives 444, **false positives 22**.
- **Rule applied:** blocking if and only if the finding count is greater than zero **and** the false-positive count is zero; otherwise warning. The finding count is 466, which is greater than zero, so the first conjunct holds. The false-positive count is 22, which is not zero, so the second conjunct fails.
- **Resulting constant value: `warning`.**

### G8 — `G8_SEVERITY`

- **Counts:** corpus files 194, candidates 237, findings 82, true positives 75, **false positives 7**.
- **Rule applied:** the finding count is 82, which is greater than zero, so the first conjunct holds. The false-positive count is 7, which is not zero, so the second conjunct fails.
- **Resulting constant value: `warning`.**

### G8b — `G8B_SEVERITY`

- **Counts:** corpus files 194, candidates 47, findings 19, true positives 19, **false positives 0**.
- **Rule applied:** G8b is exempt from the two-condition rule and takes the warning channel unconditionally, because it carries the highest false-positive surface of the set. The exemption was declared in advance of measurement and is not contingent on the measured outcome. A recorded false-positive count of zero over this corpus does not license promotion, because a false-positive count taken over one corpus does not bound the false-positive surface of the predicate.
- **Resulting constant value: `warning`.**

This is the case where the pre-declaration did work. G8b's measured false-positive count is zero and its finding count is non-zero, so under the two-condition rule alone it would have taken the blocking channel. The unconditional clause, written before the count existed, is what keeps it a warning.

### G9 — `G9_SEVERITY`

- **Counts:** corpus files 194, candidates 273, findings 8, true positives 4, **false positives 4**.
- **Rule applied:** the finding count is 8, which is greater than zero, so the first conjunct holds. The false-positive count is 4, which is not zero, so the second conjunct fails.
- **Resulting constant value: `warning`.**

## No rule carries the blocking channel

The acceptance condition of this task requires that no rule carries the blocking channel unless its measurement was non-vacuous **and** its recorded false-positive count is zero.

**No rule carries the blocking channel at all.** The condition is satisfied vacuously in the direction that matters — nothing was promoted — and the underlying facts are recorded above: each of G7, G8, and G9 has a non-zero recorded false-positive count and therefore could not be promoted, and G8b is exempt by its unconditional clause.

Every measurement was non-vacuous. All four rules recorded a finding count greater than zero, so no rule's false-positive count was taken over an empty population.

## State of the constants in both runtimes

All four constants were authored at the warning channel in Phase 2 and Phase 3, and the decision rule applied to the measured counts yields the warning channel for all four. **The assignment therefore confirms the authored values rather than changing them, and no source edit was required.** The constants were read from both runtimes to verify that, rather than assumed.

### Python — `scripts/dev_tools/plan_gate_observability.py`

Read at runtime, so the value the module actually exposes is the value recorded, not the value its source line appears to hold:

```
$ poetry run python -c "import scripts.dev_tools.plan_gate_observability as m; print(m.G7_SEVERITY, m.G8_SEVERITY, m.G8B_SEVERITY, m.G9_SEVERITY)"
warning warning warning warning
EXIT=0
```

### TypeScript — `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts`

The four declarations, read from the module source:

```
51:export const G7_SEVERITY: string = "warning";
54:export const G8_SEVERITY: string = "warning";
57:export const G8B_SEVERITY: string = "warning";
60:export const G9_SEVERITY: string = "warning";
```

The source comment on each constant already names `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/corpus-measurement.2026-08-24T00-00.md` as the artifact that fixes its final value, and that artifact now exists and carries the counts. No comment was rewritten, because doing so would perturb a green state for no gate.

## Cross-runtime parity

`poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py -k severity` — EXIT_CODE 0:

```
collected 9 items / 4 deselected / 5 selected

tests\scripts\dev_tools\test_plan_gate_parity.py .....                   [100%]

======================= 5 passed, 4 deselected in 0.16s =======================
```

**`5 passed`**, which is the pre-existing G5 assertion plus the four added by [P4-T2]. Each of the four new assertions reads the constant from the TypeScript module and compares it with the Python value, so this run is what establishes that the two runtimes agree on all four severities and not merely that each is internally consistent.

## Why the rule-behaviour tests are unaffected

The plan's frozen design records that rule-behaviour tests assert findings against the union of both channels and assert the channel separately against the module's own severity constant, so a Phase 6 severity change breaks no test. In this measurement no value changed, so the point is not exercised; it is recorded here only so a later reader does not conclude that the absence of test churn means the mechanism was untested. The parity assertions above are what tested it.

## Output Summary

The pre-declared decision rule was applied mechanically to the counts [P6-T3] recorded. **All four constants resolve to the warning channel: `G7_SEVERITY` = `warning` (466 findings, 22 false positives), `G8_SEVERITY` = `warning` (82 findings, 7 false positives), `G8B_SEVERITY` = `warning` (19 findings, 0 false positives, exempt and unconditional), `G9_SEVERITY` = `warning` (8 findings, 4 false positives).** No rule carries the blocking channel. The values were confirmed by reading the Python module at runtime and the TypeScript declarations from source; both agree and no source edit was required. `poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py -k severity` exited 0 and reported **`5 passed`**.
