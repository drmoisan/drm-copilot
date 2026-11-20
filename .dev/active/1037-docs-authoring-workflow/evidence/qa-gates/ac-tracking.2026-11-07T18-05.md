# Acceptance Criteria Re-Evaluation at the Merged Head (remediation [P3-T3])

Timestamp: 2026-11-07T18-05
Command: Read of the `## Acceptance Criteria` sections of `<FEATURE>/spec.md` and `<FEATURE>/user-story.md`; mapping to the merged-head evidence of [P2-T3] to [P2-T6]; `git diff --stat <PreMergeHead> HEAD -- <FEATURE>/spec.md <FEATURE>/user-story.md` and `git diff <PreMergeHead> -- <FEATURE>/spec.md <FEATURE>/user-story.md` (PreMergeHead from `evidence/other/merge-result.2026-11-07T17-46.md`)
EXIT_CODE: 0
Output Summary: Spec AC 12 and user-story AC 9 are met at the merged head (already checked; unchanged). Spec AC 9 and user-story AC 7 are met at the merged head except for the "without modification" clause, which stays governed by main-plan note N4 and remediation finding PA-2 (owner decision); both remain unchecked. Both spec and user-story diffs against PreMergeHead are empty (0 lines, committed and working tree), so no criterion text or checkbox changed. Work mode: full-feature.

## Item-to-evidence mapping

| Item | Text (abridged) | Merged-head evidence | Result | Checkbox |
|---|---|---|---|---|
| spec AC 9 | Mirror and push-down parity for all new agents and skills; bundle copies byte-identical; every Claude and Codex file in its `pack-manifests/core.json`; existing contract tests pass without modification, including the Codex generator `--check` | `pester-coverage.2026-11-07T17-58.md` (Mirrors suite 25 tests and Registration suite 19 tests, 0 failed; 64 bundle pairs); `pytest-regression.2026-11-07T18-03.md` (twenty contract modules, 1011 tests, 0 failed); `codex-generator-check.2026-11-07T17-47.md` (exit 0); `jest-regression.2026-11-07T18-03.md` (`claude-pack-manifest-completeness.test.ts` among 337 passed suites); `merge-result.2026-11-07T17-46.md` (23 item paths once in the resolved Claude `core.json`) | Met except the "without modification" clause (three guard suites carry additive rows; N4, PA-2) | Unchecked (unchanged) |
| spec AC 12 | `docs_operations` block in `config/orchestration-routing.json`; held tools; three byte-identical copies; other blocks unchanged; routing parity tests pass | `pester-coverage.2026-11-07T17-58.md` (`keeps the three routing copies byte-identical` passed); `pytest-regression.2026-11-07T18-03.md` (`test_orchestration_routing_config_parity` 1 test and `test_codex_topology_policy_config_parity` 5 tests, 0 failed); `merge-preview.2026-11-07T17-45.md` (the three routing copies are unchanged on the base) | Met | Checked (unchanged) |
| user-story AC 7 | Mirror and push-down parity for agents, skills and templates; bundle copies byte-identical; files in pack manifests; existing contract tests and generator `--check` pass without modification | As spec AC 9 | Met except the "without modification" clause (N4, PA-2) | Unchecked (unchanged) |
| user-story AC 9 | Hooks registered in `.claude/settings.json` and its byte-identical bundle copy; `docs_operations` routing block in the source and two byte-identical bundle copies | `pester-coverage.2026-11-07T17-58.md` (Registration suite 0 failed, including the settings pair and `keeps the three routing copies byte-identical`); `merge-preview.2026-11-07T17-45.md` (settings and routing copies unchanged on the base) | Met | Checked (unchanged) |

## Acceptance Criteria Status

- Source: `<FEATURE>/spec.md`, `<FEATURE>/user-story.md`
- Total AC items: 28 (spec 17, user-story 11)
- Checked off (delivered): 22 (spec 13, user-story 9)
- Remaining (unchecked): 6
- Items remaining: spec AC 9 and user-story AC 7 (the "without modification" clause, PA-2 owner decision); spec AC 11 (the "without modification" clause, PA-2 owner decision); spec AC 16 (seeded shuffled and single-process runs, waived by the owner directive of 2026-11-07); spec AC 17 and user-story AC 11 (CI-dependent, owned by the S9 CI green gate)
