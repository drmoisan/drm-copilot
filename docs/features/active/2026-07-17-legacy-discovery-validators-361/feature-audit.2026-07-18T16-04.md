# Feature Audit — legacy-discovery-validators (#361)

- Timestamp: 2026-07-18T16-04
- Work mode: `full-feature` (per `issue.md` marker). AC sources per the
  acceptance-criteria-tracking protocol: `spec.md` (Definition of Done +
  Seeded Test Conditions) and `user-story.md` (Acceptance Criteria).
- Baseline for diff: `origin/epic/legacy-discovery-and-parity-integration`
  (merge-base `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`).

## spec.md — Definition of Done

| Item | Verdict | Evidence |
|---|---|---|
| Pure `validate_<artifact>_text` function per artifact type (config + 7 schemas), returning `list[str]` | **PASS** | `validate_discovery_profile.py::validate_profile_text`; `validate_discovery_schema_artifacts.py`'s seven `validate_<schema>_text` functions. All confirmed by direct source read. |
| Single argparse CLI, one subparser per type plus `all`, canonical stdout/stderr/exit-code contract | **PASS** | `validate_discovery_artifacts.py::build_parser`/`main`; verified subparser set, positional `path`, exit codes 0/1, and message formats via source read and dispatch tests. |
| `dev.discovery.validate-*` Poetry console-script entries registered | **PASS** | `pyproject.toml` diff shows all nine entries with the exact target strings from spec.md; independently confirmed via `git diff`. |
| Schema-location resolution via shared loader keyed off `$schema`, no hardcoded schema directory or version string | **PASS** | `_extract_schema_uri` + `schema_loading.load_schema`, no `base_path` passed by the schema validators; grep confirms no `schemas/vN` literal in code (only in a docstring describing what is *not* done). |
| No TaskMaster/TMW/Outlook/VSTO/email/task-management identifier in new validator source, docstrings, error messages, or comments | **PASS** | Independently re-ran the grep gate (including `email`, not in the plan's literal command) across all ten new/modified files; zero matches. |
| Tests updated/added (inline literals now; fixture-based once #9002 ships) | **PASS** | Five new test files added, all using inline literals per the plan's fixture note; no `#9002` fixtures exist yet, matching the stated deferral. |
| Edge cases and error handling covered by tests (malformed JSON, missing `$schema`, missing required profile fields) | **PASS** | `test_validate_against_schema_rejects_malformed_json`, `test_validate_against_schema_reports_missing_schema_field_as_error_string`, `test_validate_profile_text_reports_missing_legacy_source_path`, `test_validate_profile_text_rejects_malformed_yaml`, `test_validate_profile_text_rejects_non_mapping_root` all present and passing. |
| Docs updated (this spec and user-story, `docs/features/active/...` links) | **UNCHECKED — legitimate gap** | No further doc cross-links were required or expected: the plan contains no doc-update task beyond the spec/user-story files themselves (which are the AC sources under audit here), and Non-Goals explicitly defers #9004/#9010/#9011 (the features that would consume and cross-link to this one) to future work. Leaving this unchecked is correct; it is a legitimate, intentionally deferred item, not an oversight. |
| Toolchain pass completed with line coverage >= 85% / branch coverage >= 75% on **all new/changed files** | **PARTIAL — un-checked by this review** | Repo-wide aggregate and three of the four new files pass. `schema_loading.py` (new file) has branch coverage 71.43% < 75% (its `file://` scheme branch and both `FileNotFoundError` branches are untested by any test in the repository). The spec's own wording is explicit ("on all new/changed files"), so this item cannot be marked PASS as literally written. See `code-review.2026-07-18T16-04.md` Finding 1 and `remediation-inputs.2026-07-18T16-04.md`. **Un-checked in `spec.md` by this review** (was previously `[x]`). |

## spec.md — Seeded Test Conditions

All seven items independently re-verified as **PASS** and left checked:
conforming/non-conforming fixture handling per artifact type, CLI subparser
dispatch for each type and `all`, CLI exit codes 0/1, schema-location
resolution via the `$schema` seam, `all`'s success-on-first-match /
aggregated-prefixed-failure semantics, and the domain-neutrality grep gate
(re-run independently with an additional `email` token; still zero matches).

## user-story.md — Acceptance Criteria

| Item | Verdict | Evidence |
|---|---|---|
| Pure `validate_<artifact>_text` function per type, returning `list[str]` | **PASS** | Same as spec.md row above. |
| Single argparse CLI, subparser per type plus `all`, canonical pattern | **PASS** | Same as spec.md row above. |
| `dev.discovery.validate-*` console-script entries registered | **PASS** | Same as spec.md row above. |
| Each validator accepts conforming / rejects non-conforming fixtures with human-readable errors | **PASS** | Verified across all eight validators' test coverage (profile + seven schemas), both branches, in the new test files. |
| Per-schema validators locate schemas via #9002's convention (via `$schema`, no hardcoded layout) | **PASS** | Same as spec.md row above. |
| No domain-specific identifier in validator source | **PASS** | Same as spec.md row above. |
| Tests satisfy quality-tier policy (line >= 85%, branch >= 75%), co-located in mirrored `tests/` tree | **PARTIAL — un-checked by this review** | Test co-location is fully compliant (all five new test files under `tests/scripts/dev_tools/`, none colocated with source). Aggregate/repo-wide coverage meets policy (88.21%/79.02%; new-code aggregate 93.33%/88.64%). However, `schema_loading.py`'s own branch coverage (71.43%) is below the 75% uniform threshold this AC cites verbatim. **Un-checked in `user-story.md` by this review** (was previously `[x]`), for consistency with the identical underlying gap flagged against spec.md's more explicit per-file wording. |

## AC Traceability Cross-Check (plan.2026-07-17T14-03.md table, lines 652-665)

Spot-checked the plan's own AC-traceability table against the diff; all
mappings (Phase 2/3 -> pure functions, Phase 4 -> CLI, Phase 5 -> Poetry
entries, Design Decision 6 + Phase 3 -> schema location, Phase 6 -> domain
neutrality, Phase 7 -> coverage, Phase 1 -> `validate_json.py` regression) are
accurate representations of what was actually delivered, with the one
exception already noted above (Phase 7's coverage claim does not hold at the
per-new-file granularity for `schema_loading.py`).

## Acceptance Criteria Status

- Source: `docs/features/active/2026-07-17-legacy-discovery-validators-361/spec.md` (Definition of Done: 9 items; Seeded Test Conditions: 7 items), `docs/features/active/2026-07-17-legacy-discovery-validators-361/user-story.md` (Acceptance Criteria: 7 items)
- Total AC items: 23
- Checked off (delivered, verified PASS): 21
- Remaining (unchecked): 2
- Items remaining:
  - spec.md Definition of Done: "Docs updated (this spec and user-story, `docs/features/active/...` links)." — legitimate, intentionally deferred gap (not a defect).
  - spec.md Definition of Done: "Toolchain pass completed ... with line coverage >= 85% and branch coverage >= 75% on all new/changed files." — un-checked by this review; `schema_loading.py`'s branch coverage (71.43%) fails the threshold at the per-file granularity the item's own wording specifies.
  - user-story.md Acceptance Criteria: "Tests satisfy quality-tier policy (line >= 85%, branch >= 75%) ..." — un-checked by this review for the same underlying reason (co-location itself is fully compliant).

(Note: three items are listed above against a stated total of 2 remaining
because one item — "Docs updated" — was already correctly left unchecked by
the executor and is unchanged by this review; the two items this review
newly un-checked are the coverage-related ones.)

## Overall Feature-Audit Verdict

**Changes requested.** The implementation delivers the feature's core
contract completely and correctly: all eight `validate_<artifact>_text`
functions, the CLI umbrella with correct `all` semantics, the nine Poetry
console-script entries, domain neutrality, and the shared schema-loading
extraction are all verified present and correct against spec.md,
user-story.md, and the plan's six binding Design Decisions. The one
substantive gap is narrowly scoped: `schema_loading.py`'s branch coverage is
below threshold due to an untested `file://` schema-resolution branch
(inherited from `validate_json.py`'s pre-existing, equally-untested logic, not
new incorrect logic). Remediation is two small, additive tests; no production
code change is required. See `remediation-inputs.2026-07-18T16-04.md`.
