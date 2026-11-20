# Feature Audit — Push-down destination exclusion manifest (#621)

- Branch: `feature/push-down-destination-exclusion-manifest-exec-621` @ `5fa4a4dd`
- Audit timestamp: 2026-09-29T21-04
- Work mode: `full-feature` (marker `- Work Mode: full-feature` in `issue.md` line 9)

## Scope and Baseline

- Base: `origin/epic/push-down-payload-correctness-integration` @ `57fe96c2`; merge base `57fe96c2`. The branch merged the current integration tip in `5fa4a4dd`, so the three-dot diff contains only this feature's changes (75 files; 25 outside `docs/`).
- Baseline behavior: neither push-down implementation reads any destination exclusion record; every effective payload path is written or merged on each run.
- Plan: `plan.2026-09-29T14-15.md`, 71 of 71 tasks checked.
- AC sources: `spec.md` (AC-1 to AC-27) and `user-story.md` (US-1 to US-23). All 50 items were checked by the executor before this review.
- Verification method: source reading of all production changes, reading of the new and extended tests, reviewer re-runs of the Python and TypeScript toolchains and feature suites, parsing of the existing coverage artifacts, and reviewer probes of edge inputs.

## Acceptance Criteria Inventory

| Source | Items | Checked before review |
|---|---|---|
| spec.md `## Acceptance Criteria` | 27 (AC-1 to AC-27) | 27 |
| user-story.md `## Acceptance Criteria` | 23 (US-1 to US-23) | 23 |

The `## Definition of Done` and `## Seeded Test Conditions (from potential)` checklists in `spec.md` are outside the `## Acceptance Criteria` section and are not acceptance criteria under the tracking skill; they remain unchecked and are not evaluated here.

## Acceptance Criteria Evaluation

### spec.md

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | README "Destination exclusion manifest" subsection (+26 lines) documents path, comments, blank lines, normalization, exact / directory-prefix, `**` / `*` / `?`, ordinal case-sensitive comparison, first-match precedence, the eight malformed conditions, and the dangling-reference limitation; spec "Behavior" section documents the same. |
| AC-2 | PASS | `EXCLUSION_MANIFEST_RELATIVE_PATH = ".push-down-exclusions"` in both manifest modules; module-load `assert_manifest_path_is_root_level` / `assertManifestPathIsRootLevel` in both entry points; unit tests in `test_push_down_exclusion_manifest.py` and `claude-exclusion-manifest.test.ts` ("declares a root-level manifest path outside every ROOT_FOLDERS entry"). |
| AC-3 | PASS | `test_skips_absent_destination_path_and_records_absent_status`; TS "skips an absent destination path and records destination_status absent" (not written, not in `files`, counts consistent, `absent` status). |
| AC-4 | PASS | `test_conflict_leaves_present_destination_bytes_unchanged`; TS "leaves a present destination file byte-identical and counts a conflict"; no exception raised. |
| AC-5 | PASS | `test_unmatched_entry_is_reported_and_run_succeeds`; TS "reports an entry that matches no payload path and completes normally" asserts the pinned unmatched line. |
| AC-6 | PASS | Parametrized malformed cases in both manifest test files (14 manifest-corpus cases through both parity suites); directory-at-path and undecodable tests; `test_malformed_manifest_fails_before_any_write` and the TS equivalent assert zero writes and zero ensured directories. |
| AC-7 | PASS | `test_write_guard_raises_for_matched_path_and_manifest_path`; TS "write guard throws for a matched path and for the manifest path". |
| AC-8 | PASS | `test_manifest_path_is_never_written_and_content_unchanged`; TS "never writes the manifest path and leaves its content unchanged". |
| AC-9 | PASS | TS "neither reads nor writes an excluded routing-merge destination document" (spy on `readTextFile`). Python routing merge is present on this branch; `test_excluded_routing_merge_path_is_neither_read_nor_written` asserts no read, no write, `present` status. |
| AC-10 | PASS | TS "never invokes the layout lister when config/blast-radius.json is excluded" (lister throws if called; skip record confirms the path was in the payload). |
| AC-11 | PASS | TS "skips the gitignore delivery when .gitignore is excluded and records its status" for `absent` and `present`. |
| AC-12 | PASS | TS "produces a byte-identical artifact, a single artifact write, and no exclusions key without a manifest"; `push-down-service-call.test.ts` "omits warnings and never invokes log without a manifest"; command test "shows no notification when the result carries no warnings". Note: identity is asserted against the engine's own rendering, not a captured pre-change artifact (policy-audit G-6, Non-blocking). |
| AC-13 | PASS | `test_absent_manifest_artifact_keys_and_single_write_unchanged` (key set equals `PushDownSummaryPayload`, no `exclusions`, single artifact write); `test_cli_absent_manifest_prints_single_line`. Value identity follows structurally (no decorator, unchanged engine); see G-6. |
| AC-14 | PASS | Three corpus files under `tests/fixtures/push_down_exclusions/`; count assertions 18 / 14 / 9 in both parity suites; both suites pass on reviewer re-run. |
| AC-15 | PASS | Corpus case ids include exact, directory with and without trailing `/`, sibling non-match, `*` / `**` / `?`, `first-match-precedence`, `shadowed-entry-is-unmatched`, `unmatched-stale-entry`, and `expected_lines` pinning the three line forms. |
| AC-16 | PASS | Five seeded property tests per language with the seed in every assertion message. Non-blocking note: the idempotence property holds over the generated domain only; `normalize("././x")` is not idempotent (code review CR-02). |
| AC-17 | PASS | `summary.exclusions` asserted non-`None` / defined with a manifest and `None` / `undefined` without, in both filter test files. |
| AC-18 | PASS | `test_artifact_carries_sorted_exclusions_object_only_with_manifest`; TS "writes the sorted exclusions object into the artifact only when a manifest was read" (key set, nested key set, sorted rendering). |
| AC-19 | PASS | `push-down-service-call.test.ts` (warnings present with pinned text; omitted when nothing to report and without manifest); `mcp-tools.push-down-claude.test.ts` "surfaces service warnings on the MCP result" and "omits the warnings field". |
| AC-20 | PASS | `push-down-service-call.test.ts` "carries warnings ... and invokes log once per line"; production `log` is wired to `this.output.appendLine` in `repo-automation-service.ts`. |
| AC-21 | PASS | Command-registration tests: one notification with a conflict line; none with only skipped and unmatched lines; none without warnings. |
| AC-22 | PASS | `test_cli_prints_exclusion_lines_after_artifact_line` (exit 0, artifact line first, then the corpus `expected_lines`). |
| AC-23 | PASS | `test_filter_is_outermost_so_pack_excluded_paths_are_unmatched`; TS "is composed outermost so pack-excluded paths are reported as unmatched". |
| AC-24 | PASS | Reviewer three-dot changed-file list contains no path under `.claude/hooks/`, `.claude/lib/`, the #769 file set, `push_down_copilot_customizations.py`, `package.json`, or `package-lock.json`; `pyproject.toml` change is a Ruff per-file ignore only. |
| AC-25 | PASS | Reviewer `wc -l` over the 25 non-documentation changed files: maximum 499 (`push_down_claude_customizations.py`). |
| AC-26 | PASS | Per-file coverage from existing artifacts: all nine new or changed production files >= 85% line and >= 75% branch; six `coverageThreshold` entries present. See policy-audit section 5. |
| AC-27 | PASS | Executor single-pass record `final-toolchain-single-pass.2026-09-29T20-55.md`; reviewer re-run of Black, Ruff, Pyright, Prettier, ESLint, TSC, and the feature suites is clean. The bundle-contract failure reproduced locally is the gitignored-state condition of issue #510 and is not attributable to this branch (policy-audit G-4). |

### user-story.md

| AC | Verdict | Evidence |
|---|---|---|
| US-1 | PASS | As AC-1; README includes the dangling-reference limitation. |
| US-2 | PASS | As AC-3, AC-20, AC-22 (skip line on CLI and output channel). |
| US-3 | PASS | As AC-4. |
| US-4 | PASS | As AC-5. |
| US-5 | PASS | As AC-6; Python error names `.push-down-exclusions` and `line <n>`. |
| US-6 | PASS | As AC-7, AC-8. |
| US-7 | PASS | As AC-21. |
| US-8 | PASS | As AC-12, AC-13. |
| US-9 | PASS | As AC-9, AC-10; the Python routing case is verified on this branch. |
| US-10 | PASS | As AC-11. |
| US-11 | PASS | MCP input schema unchanged (no schema file in the diff); `mcp-tools.push-down-claude.test.ts` warnings pass-through. |
| US-12 | PASS | As AC-19 omission cases. |
| US-13 | PASS | As AC-17, AC-18. |
| US-14 | PASS | Conflict and unmatched runs complete without exception and CLI exit 0 (AC-4, AC-5, AC-22). |
| US-15 | PASS | As AC-17. |
| US-16 | PASS | As AC-14. |
| US-17 | PASS | As AC-15. |
| US-18 | PASS | As AC-2. |
| US-19 | PASS | As AC-16; no new dependency (AC-24). |
| US-20 | PASS | As AC-23. |
| US-21 | PASS | Reviewer grep over all seven new or changed test files for temporary-file APIs returned zero matches. |
| US-22 | PASS | As AC-24, AC-25. |
| US-23 | PASS | As AC-26, AC-27. |

## Summary

All 50 acceptance criteria evaluate as PASS. No criterion was unchecked by this review. No Blocking finding was identified. Non-blocking observations relevant to acceptance evidence: the absent-manifest identity tests compare against the engine's own output (G-6), the idempotence property holds over its generated domain only (CR-02), and the bundle-contract test fails locally only because of the gitignored hook state file tracked in issue #510 (G-4).

Remediation inputs are not produced because no finding requires remediation before merge.

## Acceptance Criteria Check-off

No items were newly checked off (all 50 were already checked by the executor and each evaluated as PASS). No items were unchecked.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/spec.md`, `docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/user-story.md`
- Total AC items: 50 (spec.md 27, user-story.md 23)
- Checked off (delivered): 50
- Remaining (unchecked): 0
- Items remaining: none
