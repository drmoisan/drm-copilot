# Victim Order Classification (P0-T19)

Timestamp: 2026-11-04T00-52
Command: classification by the P0-T19 rule over recorded profiles: PL_min and PC from `evidence/regression-testing/repro-victim-set.2026-11-04T00-49.md`, CT1 and CT2 from `evidence/baseline/repro-control-1.2026-11-04T00-49.md` and `evidence/baseline/repro-control-2.2026-11-04T00-49.md`, solo profiles from `evidence/baseline/solo-victims.2026-11-04T00-52.md`, U from the victim-set artifact
EXIT_CODE: 0
Output Summary:
- Subject: the 76 keys that failed only without TARGET in the first run's diagnostic (`evidence/baseline/victim-set.2026-11-03T23-20.md`): 73 in `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1` and 3 in `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`.
- Resolve-CodexRouting.Parity: `NAMING-ARTIFACT`, `NO-VICTIM-ORDER-DEPENDENCE`.
- codex-pretooluse-transport: `NAMING-ARTIFACT`, `NO-VICTIM-ORDER-DEPENDENCE`.
- No `COUNT-DIFFERENCE`, `UNSTABLE`, or `PRE-EXISTING-ORDER-DEPENDENCE` label was assigned. No file of either suite was edited.

## Rule application

| Suite | PL_min failed | PC failed | Naming label | Solo profile | CT1 profile | CT2 profile | In U | Order label |
|---|---|---|---|---|---|---|---|---|
| tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 | 160 | 74 | NAMING-ARTIFACT (160 is not lower than 74) | tests=160 failed=74 blocks=0 container=0 | tests=160 failed=74 blocks=0 container=0 | tests=160 failed=74 blocks=0 container=0 | no (U is empty) | NO-VICTIM-ORDER-DEPENDENCE (solo equals CT1 and CT2) |
| tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | 51 | 4 | NAMING-ARTIFACT (51 is not lower than 4) | tests=51 failed=4 blocks=0 container=0 | tests=51 failed=4 blocks=0 container=0 | tests=51 failed=4 blocks=0 container=0 | no (U is empty) | NO-VICTIM-ORDER-DEPENDENCE (solo equals CT1 and CT2) |

## Interpretation

With TARGET first, both suites fail in a `BeforeAll` (one failed block each), so every test of the block fails and Pester reports unexpanded template names. Without TARGET, the same suites report their pre-existing host failures (74 and 4) under expanded names. The 76 keys that appeared to fail only without TARGET are therefore expanded names of failures that are also counted, under different names, when TARGET runs first; the count-based profiles show no failure that occurs only without TARGET, and the solo runs match the control runs, so neither suite depends on the order of the other victims.
