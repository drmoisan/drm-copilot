# Preflight Fixes (Stage B, Round 2)

Timestamp: 2026-10-31T05-02
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T23-35.md

Scope: trivial defects fixed in place in task text and plan preamble only. No task was added, removed or reordered (70 tasks before and after). Substantive defects are returned in the preflight signal and summarized at the end for traceability.

## Round 1 Defect Verification (D1-D8)

The round 1 defect text was not persisted in a repository file; the orchestrator checkpoint records only "8 substantive defects D1-D8", with D7 and D8 settled by the spec rulings. Verification was therefore made against the rulings in spec `## Orchestrator Rulings (preparation)` and the revision areas:

- R1 (blast-radius bundle copy): resolved in [P4-T3], the Existing Tests table and Open Questions; `test_class_two_bundled_path_roots_are_empty` and the Pester case "declares an empty bundled path_roots list" exist.
- R2 (OQ-6 `remove`, OQ-9 `yes`): resolved as halt branches in [P1-T1].
- R3 (`tests/fixtures/**`): resolved in [P1-T4] and [P7-T4].
- R4 (post-apply dry run with a derived decision file): resolved in [P7-T1].
- R5 (two executor runs): resolved in the Execution split preamble, [P2-T6] and [P3-T1].
- R6 (merge-base anchor on the integration branch): resolved through `BASE` in [P1-T6], [P3-T4], [P8-T13] and the other scope diffs.
- Commit and check-off protocol before each apply, the divergent-literal derivation ([P1-T3], [P4-T6], [P4-T7]) and the discovery-runtime packaging edit ([P5-T4]): present.

## Fixes

1. [P0-T5] | stale fact | The task asked the executor to confirm that the routing-config parity test covers all three copies. `test_canonical_and_bundled_routing_config_are_byte_identical` compares only `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json`, and child 2's plan leaves the test unchanged. The task now records which copies the test compares and points to [P4-T1] for the three-copy comparison.
2. [P4-T1] | acceptance clarity | The acceptance now states that all three copies are compared directly because the parity test compares two. The asserted condition (three byte-identical copies) is unchanged.
3. Existing Tests Asserting Changed Behavior, routing parity row | stale fact | The row now states that the test compares the canonical and `resources/config/` copies and that [P4-T1] compares all three.
4. Language Classification | table completeness | Rows added for the `.claude/settings.json` and `.codex/config.toml` allow-list entries with their bundle copies, the two `package.json` versions and the `pyproject.toml` comment (JSON and TOML, not code), and the `extensions/drm-copilot/CHANGELOG.md` entry (Markdown, not code). No artifact was misclassified; these planned artifacts had no row.
5. [P5-T8] | validator-blind defect (post-apply rewrite candidate) | The CHANGELOG entry is tracked prose written before [P7-T1]. A mention of the former root in its prefix form (with a trailing slash) would be a rewrite candidate in the [P7-T1] dry run. The task now requires the bare form `docs/features` with no trailing slash. The [P7-T1] assertion is unchanged.
6. [P6-T2] | validator-blind defect (post-apply rewrite candidate) | The same constraint now applies to the `RE-BASELINED by issue #1016` comment in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.

## Substantive Defects Returned (not fixed here)

- [P2-T4] (`BRANCH-OQ-12` = `moves-then-rewrites`): the second apply-mode call passes the original decision file after the moves. Under spec "Refusal rules" and user-story criterion "A change to the tree after approval causes apply to refuse on the `source_digest` check", the call refuses: the fresh digest differs, and the `decisions` sources (old `docs/features/...` paths) are no longer reported folders. Stage A tests only `applyMigrationPlan` on a prepared plan, so no gate shows that a rewrites-only planner call is accepted.
- [P1-T3] and [P1-T4]: the class scheme R, I, A and H has no class for a test whose `docs/` literal must equal content in a rewrite-excluded file. Evidence: `FOLDER_GLOB` in `tests/scripts/dev_tools/test_blast_radius_write_intent.py` against the frozen `tests/fixtures/blast_radius/write-intent/*.json` (ruling R3); `PROMOTED_RECORD_FRAGMENT` in `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` against `.claude/rules/orchestrator-state.md` under `BRANCH-OQ-5` = `no`.
- [P7-T1]: the derived exclusion list does not cover the post-move mapping records `checkpoint-path-handoff.*.md` ([P2-T6]) and the orchestrator's `checkpoint-path-update.*.md` ([P3-T1]), which record the old `docs/features/active/...` path. Once these records are tracked, under `BRANCH-OQ-2` = `references-and-links` they are rewrite candidates, and the zero-candidate acceptance fails.

## Validation

- Branch-current validator (`poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`): passed before and after the fixes.
- MCP validator (`validate_orchestration_artifacts`, `artifact_type: plan`): passed before and after the fixes.

Final signal: PREFLIGHT: REVISIONS REQUIRED
