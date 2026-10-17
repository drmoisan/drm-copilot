# #737 F-1/F-2 withhold decision (P12-T27)

Timestamp: 2026-10-13T13-44
Command: git checkout 95d6c9b22088b885225b63313b7bdb34968caa40 -- tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1; git commit -m "revert(903): withhold #737 F-1 and F-2 pending Discovery-guard findings"; git push origin bug/round-2-review-nits-and-evidence-timestamps-903
EXIT_CODE: 0
Output Summary: `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` reported findings for seven suites in CI run 38404520141 (both jobs). The four F-1/F-2 files were restored to PHASE0 content (`git diff --stat 95d6c9b22 -- <four paths>` empty after the restore), committed as 4e8d9f92d63c686f64f9f97e975448dc126c92f1 (4 files changed, 3 insertions, 183 deletions; `git show --name-only` lists only the four paths), and pushed (exit 0; HEAD equals `origin/bug/round-2-review-nits-and-evidence-timestamps-903`). Phase 12 restarts at P12-T1.

Decision: F-1 and F-2 withheld

- PHASE0: 95d6c9b22088b885225b63313b7bdb34968caa40
- Withhold commit: 4e8d9f92d63c686f64f9f97e975448dc126c92f1
- Run: https://github.com/drmoisan/drm-copilot/actions/runs/38404520141
- Source rows: `evidence/qa-gates/ps-rows.2026-10-13T13-43.md`
- Restored content includes the Phase 6 F-1/F-2 fail-first rows in `enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1` (that file is restored as a whole). The `issue.md` dispositions for F-1/F-2 are updated in P13-T1.

Every finding carries the F-2 literal `no dot-source loads the hook`; no finding text attributable to the F-1 conditional-ancestor predicate was observed. The plan withholds F-1 and F-2 together.

## Flagged suites and ownership

Ownership sources: `issue.md` `## Concurrency Constraints` (concurrent epic reserves `hook-dependency-failure*`, `validate-orchestrator-output*`, `hook-import-failure-exemptions.FailClosed.Tests.ps1`), `issue.md` `## Note Dispositions` (`#786` -> concurrent epic `subagentstop-envelope`; `#850` -> issue #901), and `git log -- <suite>`. `issue.md` itself records that the epic's file list was not inspected, so epic ownership is reserved-pattern ownership, not a verified file list.

| # | Suite | Owner | Basis |
|---|---|---|---|
| 1 | `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` | unknown (neither #901 nor the concurrent epic is evidenced) | history: 32cef1ec0 `feat(824)`, e9ee93686 `test(737)`; matches no reserved pattern |
| 2 | `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` | unknown (possible #901 link) | history: fee4f572c `test(824)`, de19e542b `fix(850)` (#850 notes are owned by #901), e9ee93686 `test(737)`; matches no reserved pattern |
| 3 | `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` | concurrent epic `subagentstop-envelope` | matches reserved `hook-dependency-failure*`; history: #786 commits (e58047fd8, 11f2aac9d, 2dc8e7eea) |
| 4 | `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` | concurrent epic `subagentstop-envelope` | matches reserved `hook-dependency-failure*`; history: #786 commits (c4cc2fd63, e58047fd8, 2dc8e7eea) |
| 5 | `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` | #901 (inferred) | created by 72a4f15ba `docs(850)`; #850 notes are owned by #901; also e9ee93686 `test(737)` |
| 6 | `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` | unknown (neither #901 nor the concurrent epic is evidenced) | history: 9bfe62e16 `feat(codex)`, e9ee93686 `test(737)`, ae0204c6e `test(903)` (this branch's CR-9 row) |
| 7 | `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` | concurrent epic `subagentstop-envelope` | matches reserved `hook-dependency-failure*`; history: #786 commits (11f2aac9d, 2dc8e7eea, b054e8a59) |

Summary: 3 suites concurrent epic, 1 suite #901 (inferred), 3 suites unknown.
