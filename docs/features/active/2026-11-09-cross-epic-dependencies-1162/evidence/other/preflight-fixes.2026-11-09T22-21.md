# Preflight Fixes

Timestamp: 2026-11-09T22-21
Plan: docs/features/active/2026-11-09-cross-epic-dependencies-1162/plan.2026-11-09T16-32.md
Validators after fixes: Python CLI `plan` subcommand exit 0; MCP `validate_orchestration_artifacts` ok.

## Fixes

1. [P1-T1] | literal detail aligned with spec AC2.2 | The main-sync test case now states that the `chore/epic-1188-main-sync-2` PR's listed files include a path under the prerequisite feature folder, so the case exercises the file rule as well as the token rule.
2. [P3-T1] | ambiguous file citation | Two test files are named `Get-EpicProgressReport.Tests.ps1`. The task now names the full path `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` and states that the forwarder suite under `tests/scripts/dev-tools/` stays unchanged.
3. [P4-T1] | validator-blind class: existing asserting tests not named | Added an "Existing tests" entry with dispositions for `test_epic_orchestrate_main_sync_contract.py`, `early-start-skill-contract.Tests.ps1` (`ESS-KICKOFF-LITERAL-INTACT`), `test_epic_bounded_child_return_contract.py`, and `test_epic_skill_script_citations_shipped.py`, each unchanged, with the constraint on the appended text that keeps it unchanged.
4. [P4-T3] | validator-blind class: existing asserting tests not named | Added an "Existing tests" entry with dispositions for `ESS-KICKOFF-LITERAL-INTACT` on the Codex skill, `test_epic_orchestrate_main_sync_contract.py` (Codex section not edited), and the no-`command =` line rule of `codex-epic-runtime-contracts.Tests.ps1`.
5. [P4-T2] | citation correction | The acceptance now states that `DocumentationEstateEpicTemplate.Tests.ps1` reads the documentation-estate template, which the task does not edit, and that the byte identity of the two edited templates is pinned by P4-T4.
6. [P5-T10] | pathspec completeness | The no-hook listing now also covers the bundled `.claude/settings.json`, the Codex bundle `.codex/hooks/`, and the Codex bundle `.codex/config.toml`.
