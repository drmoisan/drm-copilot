# Feature Audit — legacy-discovery-analyzer-framework (#363), Remediation Cycle 3 Exit Reaudit

- Timestamp: 2026-07-18T17-40 (UTC)
- Branch: `feature/legacy-discovery-analyzer-framework-363` at head `f22b09e8`
- Diff base: `origin/epic/legacy-discovery-and-parity-integration`
- Work Mode: `full-feature` — AC sources are `spec.md` (12 items) and `user-story.md` (8 items)
- Prior audit: `feature-audit.2026-07-18T16-54.md` (all 20 AC PASS)

## Reaudit Basis

The cycle-3 production delta is confined to `core.json` (pack-manifest registration of four #365
agent paths). No Python analyzer module, test file, or `pyproject.toml` line changed since the
cycle-2 audit (verified via `git diff 3d2544ec..HEAD --name-status`). All acceptance criteria were
therefore re-verified by rerunning the full verification suites at head `f22b09e8` rather than by
re-deriving each criterion from a changed implementation:

- `poetry run pytest --cov --cov-branch`: 1769 passed / 0 failed, including all
  `tests/scripts/dev_tools/discovery/analyzer/` suites (pipeline sequencing, enumeration, globs,
  markers, emission schema validation, CLI exit codes, domain neutrality, e2e determinism).
- Repo-wide Python coverage 88.62% line / 79.25% branch (thresholds 85%/75%); all 7 analyzer
  modules 100% line / 100% branch; figures identical to cycle 2 — no regression.
- Black, Ruff, Pyright: clean single pass.
- Extension suite 1886/1886 pass including `claude-pack-manifest-completeness.test.ts` 7/7;
  Python bundle payload contract test 7/7.

## spec.md Acceptance Criteria (12)

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | `Analyzer` protocol + `run_analyzer` runner; concrete analyzer plugs in | PASS | Unchanged since cycle 2; `test_pipeline.py` suites pass in this rerun. |
| 2 | Frozen dataclass value objects thread fixed stage order | PASS | Unchanged; `models.py` frozen/slots dataclasses; sequencing tests pass. |
| 3 | Inventory analyzer enumerates via profile `legacy_source.root` | PASS | Unchanged; e2e inventory tests pass. |
| 4 | `fnmatch` include/exclude on consumer-relative POSIX paths, deterministic ordering | PASS | Unchanged; parametrized glob tests pass; byte-identical re-run test passes. |
| 5 | Neutral profile-supplied marker classification, no stack literals | PASS | Unchanged; marker tests and neutrality grep clean. |
| 6 | Unreachable root -> `AnalyzerError`, distinct from `DomainProfileError` | PASS | Unchanged; distinctness tests pass. |
| 7 | Evidence Reference v1 emission contract | PASS | Unchanged; `test_emitter.py` field-set assertions and e2e schema validation pass. |
| 8 | `dev.discovery.inventory` console script, exit codes 0/1/2 | PASS | `pyproject.toml` mapping present in union diff; CLI exit-code tests pass. |
| 9 | Parsing-strategy decision recorded in spec | PASS | Spec "Specification Decision: Parsing Strategy" section present, four grounded justifications. |
| 10 | Domain-neutrality verified by contract test | PASS | `test_domain_neutrality.py` parametrized over all 7 modules — pass. |
| 11 | Quality-tier policy: pytest, line >= 85%, branch >= 75%, mirrored tree, no temp files, injected clock | PASS | 1769/0; 88.62%/79.25% independently measured from `artifacts/python/lcov.info`; mirrored tree; `mem_fs_path`; injected clock. |
| 12 | No file > 500 lines; no production module excluded from coverage | PASS | Max 231 lines (`inventory.py`); all 7 modules in lcov denominator at 100%/100%; the new `exclude_lines` pattern is line-level (Protocol `...`), not a file exclusion. |

All 12 spec AC items remain checked `[x]` in `spec.md` (every item re-verified PASS; no source
edits required).

## user-story.md Acceptance Criteria (8)

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | Run `dev.discovery.inventory` with a profile to produce inventory | PASS | Console-script mapping present; e2e profile-to-artifacts test passes. |
| 2 | Source location and globs read from profile; nothing hardcoded | PASS | `_build_context` maps profile fields; neutrality tests clean. |
| 3 | Deterministic enumeration honoring globs | PASS | POSIX-sorted walk; `test_end_to_end_is_byte_identical_on_rerun` passes. |
| 4 | Unreachable source -> immediate stop, path reported, no partial inventory | PASS | Fail-fast precedes walk; error-path tests pass. |
| 5 | Artifacts are Evidence Reference v1 with consumer-relative `location` | PASS | Schema validation against real v1 schema passes. |
| 6 | Exit codes 0/1/2; `--json` summary | PASS | CLI tests cover 0/1/2 and `--json` output. |
| 7 | Domain-neutral command and artifacts | PASS | Neutrality contract test passes. |
| 8 | Analyzer author can plug into the shared contract | PASS | Protocols exported via `__init__.py`; fake-analyzer plug-in test passes. |

All 8 user-story AC items remain checked `[x]` in `user-story.md` (every item re-verified PASS; no
source edits required).

## Cycle-3 Remediation Objective (CI pack-manifest failure)

- Root cause: the four #365 agent payloads were bundled but not registered in
  `pack-manifests/core.json`, failing `claude-pack-manifest-completeness.test.ts` in CI.
- Fix verified: 4 manifest entries added (valid JSON, alphabetical within the agents group,
  Prettier-clean); target test 7/7 PASS; full extension suite 1886/1886 PASS; Python bundle
  payload contract test 7/7 PASS; fail-before/pass-after regression evidence present under
  `evidence/regression-testing/`.
- No collateral change: no repo `.claude/` source, no bundled payload, and no analyzer code
  modified in cycle 3; TS coverage byte-identical to baseline (96.74%/89.29%).
- PR #378: `mergeable: MERGEABLE`, `mergeStateStatus: CLEAN` at head `f22b09e8`.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/spec.md`,
  `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/user-story.md`
- Total AC items: 20 (12 spec + 8 user-story)
- Checked off (delivered): 20
- Remaining (unchecked): 0
- Items remaining: none

## Verdict

PASS — all 20 acceptance criteria hold at branch head `f22b09e8`; 0 blocking findings. The cycle-3
remediation objective is met and the analyzer framework feature is unregressed.
