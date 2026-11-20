# PowerShell Coverage Comparison (P11-T4)

Timestamp: 2026-09-30T15-55
Command: comparison of `evidence/baseline/pester-orchestrator-state-baseline.md` (P0-T22) against `evidence/qa-gates/pester-orchestrator-state-coverage-final.md` (P10-T5, loop iteration 2); git diff -U0 origin/epic/orchestrator-state-contract-correctness-integration -- .claude/lib/orchestrator-state/OrchestratorState.psm1; then poetry run python -c "import xml.etree.ElementTree as E; r=E.parse('artifacts/pester/coverage-523-final.xml').getroot(); ls=[l for l in r.iter('line') if int(l.get('nr')) in (96,97,98,99,286,329)]; [print(l.get('nr'), l.get('mi'), l.get('ci')) for l in ls]; print(len(ls))"
EXIT_CODE: 0
Output Summary: `OrchestratorState.psm1` line coverage 100.00% (109/109) -> 100.00% (110/110); post-change >= 85 and not below baseline. Every changed line that appears as a JaCoCo `line` element (97, 98, 99, 286, 329) has `ci` > 0.

## Line percentages

| File | Baseline (P0-T22) | Post-change (P10-T5) | Threshold | Result |
|---|---|---|---|---|
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 109/(109+0) = 100.00% | 110/(110+0) = 100.00% | >= 85; not below baseline | PASS |

## Changed lines

Hunk headers from the anchored `git diff -U0`:

- `@@ -96,11 +96,4 @@` -> added lines 96 through 99 (comment line 96; `MECHANICAL_BLOCKED_REASONS = @(` line 97; `NON_MECHANICAL_BLOCKED_REASONS = @(` line 98; `VALID_BLOCKED_REASONS` composition line 99)
- `@@ -293 +286 @@` -> added line 286 (count omitted: single line): the `VALID_BLOCKED_REASONS -cnotcontains` membership check
- `@@ -336 +329 @@` -> added line 329 (count omitted: single line): the `-cne 'none'` readiness check

Added-line set: {96, 97, 98, 99, 286, 329}

JaCoCo `line` elements in `artifacts/pester/coverage-523-final.xml` whose `nr` is in that set (`nr mi ci`):

```
97 0 2
98 0 2
99 0 2
286 0 1
329 0 2
5
```

Line 96 is a comment and has no `line` element. Every changed line that appears as a `line` element has `ci` greater than 0 and `mi` equal to 0.
