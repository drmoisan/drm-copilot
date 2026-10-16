# AC-1/AC-2 Fail-Before Record (P2-T5)

Timestamp: 2026-10-16T01-54
Command: git diff --stat ae0204c6e58b573eab716015a1be7d767e67b4ef HEAD -- tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 (recorded by P0-T5; output EMPTY); source record read: `evidence/regression-testing/ps-fail-before.2026-10-13T12-04.md` in folder `2026-10-11-round-2-review-nits-and-evidence-timestamps-903/` (under `docs/features/active/` or `docs/features/archive/`)
EXIT_CODE: 0

Output Summary:
- Form: run citation (P0-T5 recorded `EMPTY` for the helper diff, so `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` before this item's Phase 2 equals the helper at `ae0204c6e`, the pre-change helper the run exercised).
- Source run: #903 CI run 38392312722 (https://github.com/drmoisan/drm-copilot/actions/runs/38392312722), head `ae0204c6e58b573eab716015a1be7d767e67b4ef`. At that head the recovered F-1/F-2 rows were present and the helper was the pre-change helper, so the rows ran fail-first.
- Recovered row names (all six, per the plan's Row Names section): `F-1 non-compliant ESR mock inside if ($false)`, `F-1 non-compliant ESR mock inside try/catch`, `F-1 non-compliant ESR mock inside a Get-Command guard naming another seam`, `F-1 compliant ESR mock inside a matching Get-Command guard`, `F-1 compliant baseline helper inside a matching Get-Command guard`, `F-2: reports no dot-source loads the hook when only a helper is dot-sourced`.

Failing rows, quoted from the source record (four `[-]` lines per job):

```text
Linux: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside if ($false)
Linux: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside try/catch
Linux: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside a Get-Command guard naming another seam
Linux: [-] issue #903 F-1 conditional ancestors.F-2: reports no dot-source loads the hook when only a helper is dot-sourced
Windows: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside if ($false)
Windows: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside try/catch
Windows: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside a Get-Command guard naming another seam
Windows: [-] issue #903 F-1 conditional ancestors.F-2: reports no dot-source loads the hook when only a helper is dot-sourced
```

Passing guard rows, quoted from the source record (Linux JUnit `pester-junit-linux-hooks.xml` of that run; self-closing elements, so no `failure` or `skipped` child):

```text
<testcase name="issue #903 F-1 conditional ancestors.F-1 compliant ESR mock inside a matching Get-Command guard" status="Passed" classname="/home/runner/work/drm-copilot/drm-copilot/tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1" assertions="0" time="0.011" />
<testcase name="issue #903 F-1 conditional ancestors.F-1 compliant baseline helper inside a matching Get-Command guard" status="Passed" classname="/home/runner/work/drm-copilot/drm-copilot/tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1" assertions="0" time="0.009" />
```

The two `F-1 compliant` rows are pass-before/pass-after guard rows: the pre-change predicate already returns zero findings for them, so no failing run is possible for them. They guard against the F-1 change over-reporting.
