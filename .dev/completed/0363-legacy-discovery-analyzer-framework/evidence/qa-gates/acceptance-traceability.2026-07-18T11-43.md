# Acceptance-Criteria Traceability (P8-T6)

Timestamp: 2026-07-18T11-43

Maps each acceptance criterion to its implementing task(s) and passing test(s).
All tests referenced pass under `poetry run pytest` (1735 passed).

## spec.md — 12 Acceptance Criteria

1. Language-neutral `Analyzer` protocol + `run_analyzer` runner; concrete analyzer plugs in.
   - Tasks: P3-T1, P4-T1..T3. Tests: test_pipeline.py (stage sequencing, reexport),
     test_inventory_e2e.py.
2. Frozen dataclass value objects flow between stages; `run_analyzer` invokes four stages in
   fixed order threading outputs.
   - Tasks: P2-T1, P3-T1. Tests: test_models.py (frozen), test_pipeline.py (order + threading).
3. Inventory analyzer enumerates solutions/projects and files via profile `legacy_source.root`.
   - Tasks: P4-T1, P6-T1. Tests: test_inventory.py (enumeration), test_cli.py (valid run),
     test_inventory_e2e.py.
4. Enumeration honors include/exclude globs (fnmatch, consumer-relative POSIX) with
   deterministic POSIX ordering.
   - Tasks: P4-T1, P4-T2. Tests: test_inventory.py::test_parse_enumerates_tree_in_deterministic_posix_order,
     test_filter_paths_glob_matrix, test_parse_is_repeatable.
5. Project/solution units classified by neutral, profile-supplied marker table; no stack literals.
   - Tasks: P4-T3. Tests: test_inventory.py::test_classify_unit_uses_default_markers,
     test_classify_unit_honors_custom_marker_table; test_domain_neutrality.py.
6. Unreachable/missing root fails fast with domain-neutral `AnalyzerError` naming the path,
   distinct from `DomainProfileError`.
   - Tasks: P4-T1. Tests: test_inventory.py::test_parse_missing_root_raises_analyzer_error,
     test_parse_file_root_raises_analyzer_error, test_analyzer_error_is_distinct_from_domain_profile_error.
7. Each artifact is an Evidence Reference v1 instance: `schema_version` `^1\.\d+\.\d+$`,
   scheme-less relative `$schema`, `id` `^[a-z0-9][a-z0-9._-]*$`, required fields present,
   consumer-relative POSIX `location`, extras only under `metadata`.
   - Tasks: P5-T1, P5-T2. Tests: test_emitter.py (field set, patterns, $schema form,
     schema validation), test_models.py::test_to_json_dict_*.
8. `dev.discovery.inventory` console script maps to `...cli:main`, runs end-to-end, exit codes
   0/1/2.
   - Tasks: P1-T3, P6-T1, P6-T2. Tests: test_cli.py (exit 2 usage, exit 0 valid, exit 1 errors),
     pyproject.toml `[tool.poetry.scripts]` entry.
9. Parsing-strategy decision (regex/plain-text, stdlib only, no AST/Roslyn/tree-sitter) recorded
   and justified.
   - Location: spec.md "Specification Decision: Parsing Strategy". No stdlib-external parser used
     (verified: production imports are stdlib only).
10. Framework and inventory production modules contain no domain-specific identifiers; verified
    by a domain-neutrality contract test.
    - Tasks: P7-T1. Tests: test_domain_neutrality.py (parametrized over all 7 modules).
11. Tests satisfy quality-tier policy: pytest, line >= 85%, branch >= 75%, mirrored test tree,
    no temp files (mem_fs_path), injected clock.
    - Evidence: coverage-delta.2026-07-18T11-43.md (line 88.43% / branch 87.05%; new code 100%).
      Test tree at tests/scripts/dev_tools/discovery/analyzer/. No temp files; mem_fs_path used.
12. No production or test file exceeds 500 lines; no production analyzer module excluded from
    coverage.
    - Evidence: file-size check (all analyzer files well under 500 lines); no analyzer path in
      `[tool.coverage.run] omit`. Only the type-only `...` protocol stub lines are excluded via
      `exclude_lines`, not any production file.

## user-story.md — 8 Acceptance Criteria

1. Migration engineer runs `dev.discovery.inventory` with a profile to produce a machine-readable
   inventory. -> P6-T1; test_cli.py valid-run, test_inventory_e2e.py.
2. Command reads source location and include/exclude from the profile; nothing hardcoded.
   -> P6-T1; test_cli.py (_profile-driven run), test_domain_neutrality.py.
3. Inventory enumerates solutions/projects/files honoring globs, deterministic per tree+profile.
   -> P4-T1..T3; test_inventory.py ordering/globs, test_inventory_e2e.py determinism.
4. Unreachable source location stops immediately, reports the path, distinct from malformed-profile
   error, no partial inventory. -> P4-T1, P6-T1; test_inventory.py AnalyzerError tests,
   test_cli.py::test_unreachable_root_exit_1, test_malformed_profile_exit_1.
5. Each artifact is a discovery Evidence Reference v1 with repo-relative `location`, schema version,
   relative schema reference, required fields. -> P5-T1/T2; test_emitter.py, test_inventory_e2e.py
   schema validation.
6. Predictable exit codes 0/1/2; `--json` prints a summary. -> P6-T1; test_cli.py exit-code and
   --json summary tests.
7. Command and artifacts are domain-neutral (no app/stack identifiers). -> P7-T1;
   test_domain_neutrality.py.
8. Analyzer author can implement the framework contract and plug in without re-implementing.
   -> P3-T1; test_pipeline.py (fake Analyzer implements protocol and runs via run_analyzer).

No unmapped criterion. All referenced tests pass.
