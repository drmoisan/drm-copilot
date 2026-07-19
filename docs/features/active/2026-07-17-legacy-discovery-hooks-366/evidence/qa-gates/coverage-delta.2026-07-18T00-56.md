# Coverage Delta — Baseline vs. Final

- Timestamp: 2026-07-18T00-56
- Baseline source: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/baseline/pester-baseline.2026-07-18T00-15.md`
- Final source: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/pester-final.2026-07-18T00-55.md`

## Aggregate (JaCoCo report totals, `artifacts/pester/powershell-coverage.xml`)

| Metric | Baseline (P0-T9) | Final (P4-T3) | Delta |
|---|---|---|---|
| Line coverage | 89.41% (covered=1849, missed=219, total=2068) | 89.41% (covered=1849, missed=219, total=2068) | 0.00 pp (no regression) |
| Branch coverage | not emitted by tooling (pre-existing, documented) | not emitted by tooling (pre-existing, documented) | N/A |

No regression on any pre-existing changed line: the aggregate report is byte-for-byte identical
before and after this feature's changes, because neither new hook file is currently in the live
MCP session's active `CodeCoverage.Path` allowlist (see `pester-final.2026-07-18T00-55.md` for the
root-cause investigation).

## New-code coverage for the two new hook files

| File | Baseline | Post-change | New-code coverage |
|---|---|---|---|
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | did not exist | exists, 213 lines | **UNAVAILABLE** (see below) |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | did not exist | exists, 231 lines | **UNAVAILABLE** (see below) |

Numeric per-file line/branch coverage for these two files could not be captured in this session.
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (the repo-tracked, policy-referenced
config per `.claude/rules/powershell.md`) and its mirrored bundled-resource copy at
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` were both
updated to add both new files to `CodeCoverage.Path`, following the repo's established
per-issue convention (both copies already carried identical entries for issues #272, #214, #275,
#301, #298, #305, #312, #328, #334, #344, #357). The toolchain loop was restarted from P4-T1 twice
per the mandatory toolchain-loop rule (once per edited file) and reran clean (format/analyze zero
findings; test zero new failures). Despite this, the live `mcp__drm-copilot__run_poshqc_test`
session resolves its `CodeCoverage.Path` against a separately bundled/installed extension
snapshot that this worktree's edits do not reach within this session's lifetime — a tooling/
environment constraint outside this executor's control, not a code or configuration defect on the
production files themselves.

## Verdict

**BLOCKED** — not PASS. Per this task's own acceptance criteria ("verdict is BLOCKED (not PASS) if
any required numeric value is unavailable") and the atomic-plan-contract's Coverage Evidence
Contract, the required per-file numeric line/branch coverage for
`.claude/hooks/enforce-discovery-artifact-gate.ps1` and
`.claude/hooks/validate-discovery-artifact-gate.ps1` is unavailable in this execution session, so
this gate is recorded as BLOCKED rather than PASS. This is reported transparently for
feature-review/remediation follow-up; behavioral coverage (20/20 new Pester tests passing, zero
new failures, zero lint/format findings) is fully verified and is not in question.
