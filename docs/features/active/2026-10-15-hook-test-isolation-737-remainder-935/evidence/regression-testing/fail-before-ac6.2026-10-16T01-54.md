# AC-6 Fail-Before Record (P2-T4)

Timestamp: 2026-10-16T01-54
Command: git diff --stat a255192220df6291a393333fcccd66950639437e 4e8d9f92d~1 -- tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
EXIT_CODE: 0

Output Summary:
- Source run: 38404520141 (https://github.com/drmoisan/drm-copilot/actions/runs/38404520141), head `a255192220df6291a393333fcccd66950639437e`.
- Configuration: F-1/F-2 applied, R1/R2 absent. Identity result (P0-T5): the `git diff --stat` above printed EMPTY with exit 0, so the four guard files at the run head are identical to the withheld state at `4e8d9f92d~1`, which Phase 2 of this item reapplied unchanged.
- Failing Discovery `AC-4` rows in that run, one per AC-6 suite, each with message `<suite>: seam <name>: no dot-source loads the hook`:
  1. `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`
  2. `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1`
  3. `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`
  4. `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`
  5. `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`
  6. `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`
  7. `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`
- Other failing Discovery rows in that run: none (7 of 325 Discovery testcases failed, all listed above).
- Source records (folder `2026-10-11-round-2-review-nits-and-evidence-timestamps-903/`, under `docs/features/active/` or `docs/features/archive/`): `evidence/qa-gates/ps-rows.2026-10-13T13-43.md` (Discovery: 325 matching testcases, 7 failed, the seven suites listed) and `evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md` (every finding carries the F-2 literal `no dot-source loads the hook`).
- Population limitation: the run's suite population predates suites merged after 2026-10-13 (for example the `validate-orchestrator-output.*` and `enforce-pr-author-skill.DocsOnly*` suites). Behavior on the current base for those suites is verified on the final head by AC-7 and AC-8 (P7-T4).
- JUnit confirmation: pending P7-T8
