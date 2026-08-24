# Feature Audit — legacy-discovery-analyzer-framework (Issue #363)

- Timestamp: 2026-07-18T11-53
- Branch: `feature/legacy-discovery-analyzer-framework-363` (HEAD `f7a57ff8`)
- Baseline: `origin/epic/legacy-discovery-and-parity-integration` (merge base `f18c1c16`)
- Work mode: `full-feature` — AC sources are `spec.md` (12 items) and `user-story.md` (8 items)
- Verification model: independent re-execution of the toolchain (Black, Ruff, Pyright, full pytest with
  coverage) plus direct source and test inspection. All referenced test results are from this review's
  own runs, not the executor's claims.

## spec.md Acceptance Criteria (12)

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | `Analyzer` protocol + thin `run_analyzer` runner; concrete analyzer plugs in | PASS | `pipeline.py:71-96` (Protocol), `pipeline.py:133-150` (runner); `InventoryAnalyzer` runs through it in `test_inventory_e2e.py`; fake analyzer proves pluggability in `test_pipeline.py:26-122`. |
| 2 | Frozen dataclass value objects flow between stages; fixed order with threaded outputs | PASS | `models.py` — all carriers `@dataclass(frozen=True, slots=True)`; order/threading asserted by `test_pipeline.py::test_run_analyzer_invokes_stages_in_fixed_order_and_threads_outputs`; frozenness asserted in `test_models.py:34-84`. |
| 3 | Inventory analyzer enumerates via domain-profile `legacy_source.root` | PASS | `cli.py:103-118` builds the context from `profile.legacy_source`; enumeration in `inventory.py:167-188`; verified by `test_inventory.py:52-81` and `test_cli.py:107-134`. |
| 4 | Include/exclude globs via `fnmatch` on consumer-relative POSIX paths; deterministic POSIX ordering | PASS | `inventory.py:72-97` (`fnmatchcase`), `inventory.py:188` (`sorted`); parametrized matrix `test_inventory.py:135-154` (include-only, exclude-only, both, empty-include=all) and ordering test at `test_inventory.py:52-65`. |
| 5 | Neutral, profile-suppliable marker table; no hardcoded stack literals | PASS | `DEFAULT_MARKERS` uses neutral tokens `*.solution`/`*.project` (`inventory.py:56-59`); injectable via constructor (`inventory.py:150-158`); custom-table test `test_inventory.py:190-197`; independent grep found no `.csproj`/`.sln` literals. |
| 6 | Unreachable root fails fast with `AnalyzerError` naming the path, distinct from `DomainProfileError` | PASS | `inventory.py:180-183`; distinctness asserted `test_inventory.py:121-127`; missing-root and file-root tests at `test_inventory.py:87-108`. |
| 7 | Evidence Reference v1 conformance: `schema_version ^1\.\d+\.\d+$`, scheme-less relative `$schema`, `id ^[a-z0-9][a-z0-9._-]*$`, required fields, consumer-relative POSIX `location`, extras only under `metadata` | PASS | `models.py:133-161` emits exactly the declared field set; `emitter.py:34-62` rejects absolute/drive-letter `$schema`; field-set/pattern tests `test_emitter.py:66-97`; `jsonschema` validation against the real v1 schema executed (not skipped) in `test_emitter.py:194-205` and `test_inventory_e2e.py:102-119`. |
| 8 | `dev.discovery.inventory` -> `scripts.dev_tools.discovery.analyzer.cli:main`; exit codes 0/1/2 | PASS | `pyproject.toml` diff adds exactly that entry; exit-code tests: usage 2 (`test_cli.py:88-93`), success 0 with `--json` (`test_cli.py:107-134`), malformed profile 1 (`test_cli.py:165-181`), unreachable root 1 (`test_cli.py:184-201`). |
| 9 | Parsing-strategy decision recorded and justified in the spec | PASS | `spec.md` "Specification Decision: Parsing Strategy" (stdlib regex/plain-text, four justifications); production imports verified stdlib-only. |
| 10 | Domain neutrality verified by contract test | PASS | `test_domain_neutrality.py` scans all 7 production modules for the banned identifier set; independent reviewer grep confirmed zero matches. |
| 11 | Quality-tier policy: pytest, line >= 85%, branch >= 75%, mirrored tree, no temp files, injected clock | PASS | Independently measured 88.43% line / 87.05% branch repo-wide, analyzer modules 100%/100%; mirrored tree at `tests/scripts/dev_tools/discovery/analyzer/`; in-memory `mem_fs_path` fixture only; injected clock (`cli.py:121-127`, fixed clocks in tests). |
| 12 | No file > 500 lines; no production analyzer module excluded from coverage | PASS | Max file 231 lines (`inventory.py`); no analyzer path in any coverage `omit`/`exclude`; the new `exclude_lines` bare-ellipsis pattern matches only Protocol stub lines (see policy audit item 7). |

spec.md: 12 PASS / 0 PARTIAL / 0 FAIL / 0 UNVERIFIED.

## user-story.md Acceptance Criteria (8)

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | Run `dev.discovery.inventory` with a profile to get a machine-readable inventory | PASS | Console script wired in `pyproject.toml`; end-to-end run `test_cli.py:107-134`, `test_inventory_e2e.py:51-74`. |
| 2 | Source location and include/exclude come from the profile; nothing hardcoded | PASS | `cli.py:103-118` reads `legacy_source.root/include/exclude` and `artifacts.root` from the loaded profile; neutrality contract test confirms no hardcoded repository detail. |
| 3 | Enumerates solutions/projects/files honoring globs, deterministic per tree+profile | PASS | Glob matrix and ordering tests (`test_inventory.py`); byte-identical re-run (`test_inventory_e2e.py:77-95`). |
| 4 | Unreachable source stops immediately, reports path, distinct error, no partial inventory | PASS | Fail-fast check precedes the walk (`inventory.py:180-183`), so nothing is emitted; `test_cli.py::test_unreachable_root_exit_1` asserts the path appears on stderr; distinctness test present. |
| 5 | Each artifact is Evidence Reference v1 with repo-relative `location`, schema version, relative schema ref, required fields | PASS | `location` is consumer-relative POSIX (`inventory.py:184-187`); required-field and `$schema`-form assertions plus `jsonschema` validation (`test_emitter.py`, `test_inventory_e2e.py`). |
| 6 | Exit codes 0/1/2; `--json` prints a summary of what was written | PASS | Exit-code tests enumerated above; `--json` summary content asserted (`test_cli.py:128-133`). |
| 7 | Command and artifacts are domain-neutral | PASS | Neutrality contract test plus independent grep; emitted `description`/`tool` strings are neutral (`inventory.py:61,205-216`). |
| 8 | Analyzer author can implement the contract and plug in without re-implementation | PASS | `_RecordingAnalyzer` in `test_pipeline.py` implements the protocol and runs via `run_analyzer` with no inventory code reused. |

user-story.md: 8 PASS / 0 PARTIAL / 0 FAIL / 0 UNVERIFIED.

## AC Check-Off Reconciliation

All 12 spec.md and all 8 user-story.md acceptance criteria were already checked (`[x]`) by the executor.
Every one is evaluated PASS above, so the checked state is confirmed correct; no source-file changes were
required by this review. (Reviewer protocol: PASS items are checked; none required checking.)

## Cross-Feature Integration Notes

- **P1-T1 loader-symbol reconciliation:** confirmed. The delivered #360 surface exposes
  `load_domain_profile` (`scripts/dev_tools/discovery/domain_profile.py:387`) and
  `DEFAULT_PROFILE_FILENAME` (`domain_profile.py:50`); the CLI imports exactly these symbols
  (`cli.py:46-49`) and `DomainProfileError` from `domain_profile_models.py:27`. The reconciliation is
  documented in `evidence/other/upstream-dependency-status.2026-07-18T11-12.md`.
- **Emission-shape assumption:** the N-instances-per-unit pattern is recorded as a revisitable assumption
  in `evidence/other/emission-shape-assumption.2026-07-18T11-12.md`, consistent with the spec's
  "Documented cross-feature assumption" clause. Emission is isolated in `InventoryAnalyzer.emit` and
  `emitter.serialize_record`, so a later #359 decision remains a localized change.
- **Upstream schema present on branch:** `schemas/discovery/v1/evidence-reference.schema.json` exists at
  the merge base, so the schema-validation tests executed rather than skipping.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/spec.md`,
  `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/user-story.md`
- Total AC items: 20 (12 spec + 8 user-story)
- Checked off (delivered): 20
- Remaining (unchecked): 0
- Items remaining: none

## Verdict

PASS — 20/20 acceptance criteria verified against the baseline diff. 0 blocking findings.
