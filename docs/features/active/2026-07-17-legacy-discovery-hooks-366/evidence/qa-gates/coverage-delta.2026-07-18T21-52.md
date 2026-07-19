# Coverage Delta — Baseline vs. Final (Real Numbers, Supersedes BLOCKED Cycle)

- Timestamp: 2026-07-18T21-52
- Baseline source: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/baseline/pester-baseline.2026-07-18T00-15.md`
- Final source: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/pester-final.2026-07-18T21-52.md`
- Supersedes: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/coverage-delta.2026-07-18T00-56.md`,
  which recorded a BLOCKED verdict because the MCP-wrapped test tool resolved a stale
  `CodeCoverage.Path` allowlist in that session. This artifact records the real, numeric per-file
  coverage recovered via the direct-`pwsh Invoke-PoshQCTest` reproduction documented in
  `pester-final.2026-07-18T21-52.md`.

## Aggregate (JaCoCo report totals, `artifacts/pester/powershell-coverage.xml`)

| Metric | Baseline (P0-T9) | Final (this cycle) | Delta |
|---|---|---|---|
| Line coverage | 89.41% (covered=1849, missed=219, total=2068) | 89.32% (covered=1948, missed=233, total=2181) | -0.09 pp (aggregate dilution only; see regression check below) |
| Branch coverage | not emitted by tooling (pre-existing, documented) | not emitted by tooling (pre-existing, documented) | N/A |

**No regression on any pre-existing changed line.** The final total (missed=233, covered=1948,
total=2181) equals the baseline total (missed=219, covered=1849, total=2068) plus exactly the two
new hook files' totals (missed=7+7=14, covered=48+51=99, total=55+58=113: 219+14=233, 1849+99=1948,
2068+113=2181). Every pre-existing source file's missed/covered counts are unchanged between the
baseline and final coverage reports. The small aggregate percentage decrease (89.41% -> 89.32%) is
arithmetic dilution from adding two new files that are each individually above 85% but below the
prior 89.41% average — not a regression on any previously-measured line.

## New-code coverage for the two new hook files

| File | Baseline | Post-change | LINE missed | LINE covered | LINE total | New-code line coverage |
|---|---|---|---|---|---|---|
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | did not exist (0%) | exists, 213 lines | 7 | 48 | 55 | **87.27%** |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | did not exist (0%) | exists, 231 lines | 7 | 51 | 58 | **87.93%** |

Both new files clear the mandatory >= 85% line-coverage threshold. Branch coverage for these files
is not emitted by this repo's coverage tooling (pre-existing, documented limitation affecting every
file in the report, not specific to these two files).

Line-level detail (source: `artifacts/pester/powershell-coverage.xml` `<sourcefile>` blocks) and the
rationale for the remaining uncovered lines in each file (unmocked external-process wrapper bodies;
subprocess-invoked entrypoint blocks not attributed by breakpoint-based coverage) are recorded in
`pester-final.2026-07-18T21-52.md`.

## Verdict

**PASS.** Real, numeric per-file line coverage is available for both
`.claude/hooks/enforce-discovery-artifact-gate.ps1` (87.27%) and
`.claude/hooks/validate-discovery-artifact-gate.ps1` (87.93%), both above the required 85%
threshold. No regression exists on any pre-existing changed line (verified by exact arithmetic
reconciliation of baseline vs. final aggregate totals, above). Branch coverage remains unavailable
for the entire repository's tooling, a pre-existing, documented condition treated as an accepted
exception per this task's directive, not as a blocking gap.
