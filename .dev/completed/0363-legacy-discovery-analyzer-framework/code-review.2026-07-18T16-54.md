# Code Review — legacy-discovery-analyzer-framework (Issue #363) — Remediation Cycle-2 Exit Reaudit

- Timestamp: 2026-07-18T16-54
- Reviewer: feature-review agent (reaudit after remediation cycle 2)
- Branch: `feature/legacy-discovery-analyzer-framework-363` (HEAD `6126b4f5`)
- Diff base: `origin/epic/legacy-discovery-and-parity-integration` (merge base `e5f50108`)
- Prior review: `code-review.2026-07-18T11-53.md` (0 blocking)

## Review Scope and Method

The full branch diff (68 files) was reviewed. The analyzer production and test code is byte-identical to the
code reviewed in the prior cycle (`git diff cfc17114..HEAD` shows 0 changed files under the analyzer
production and test trees), so this reaudit re-verified the production modules directly, then focused on the
three post-audit changes: the integration merge (pyproject union), the bundle-mirror fix, and the
remediation documentation.

## Production Modules (re-verified)

| Module | Lines | Assessment |
|---|---|---|
| `models.py` | 174 | Frozen `slots=True` dataclasses; `UnitType(str, Enum)`; `to_json_dict` emits only the schema field set plus `metadata`. Clean separation of data from I/O. |
| `pipeline.py` | 150 | `Analyzer` and `AnalyzerFileSystem` as `typing.Protocol`; `run_analyzer` threads the four stages in fixed order; `RealAnalyzerFileSystem` is the only I/O-bearing class. Matches the spec contract. |
| `inventory.py` | 231 | Pure helpers (`filter_paths`, `classify_unit`, `classify_paths`) separated from the seam-using stages; `fnmatchcase` for platform-independent matching; fail-fast `AnalyzerError` on unreachable root; neutral marker table (`*.solution`, `*.project`). |
| `emitter.py` | 80 | `$schema` relative-path computation guards against drive letters and leading `/`; deterministic `sort_keys=True` serialization; no side effects. |
| `cli.py` | 163 | Thin boundary: argparse surface, injected clock/fs/schema-path keyword parameters with defaults, catches only `DomainProfileError` and `AnalyzerError`; exit-code contract 0/1/2 verified live via the installed console script (`--help` -> 0, bad flag -> 2, missing profile -> 1). |
| `__init__.py` | 53 | PEP 562 lazy re-exports with an explicit `AttributeError` on unknown names; no eager submodule import. |
| `__main__.py` | 12 | Minimal delegation via `SystemExit(main())`. |

Design-principle compliance (simplicity, reusability, extensibility, separation of concerns) holds. The
protocol-based seam plus keyword-injected defaults give #9014 a clean plug-in surface without a registry or
service locator.

## Post-Audit Change 1 — Integration Merge / pyproject Union (`1d31dcd0`)

- `pyproject.toml` parses as valid TOML (`tomllib`), which also proves no duplicate keys.
- `[tool.poetry.scripts]` contains the complete union: `dev.discovery.generate-acceptance-scenarios`,
  `dev.discovery.inventory`, `dev.discovery.profile`. The diff vs. base adds only the `inventory` entry;
  nothing was dropped or duplicated in conflict resolution.
- The installed console script resolves and runs (exit-code contract verified live).

## Post-Audit Change 2 — Bundle-Mirror Fix (`e0c68418`)

- All four mirrored persona files are byte-identical (`cmp`) to their `.claude/agents/` sources:
  `legacy-parity-analyst.md`, `migration-coverage-reviewer.md`, `requirements-reconciler.md`,
  `runtime-characterization-analyst.md`.
- No repo `.claude/agents/` source file is modified by the branch (empty diff vs. base for that path).
- `test_push_down_claude_resource_contracts.py` passes (independently rerun), confirming the complete
  non-memory `.claude/**` tree is mirrored, not just the four named files.
- The fix direction is correct: files were copied INTO the bundle; `push_down_claude_customizations`
  (bundle -> consumer) was not used.

## Test Quality (re-verified)

- 63 analyzer + bundle-contract tests pass in isolation; 1769 pass in the full suite.
- Arrange–Act–Assert structure with descriptive names and docstrings throughout.
- Scenario matrix coverage confirmed: stage sequencing (fake analyzer), enumeration ordering,
  include/exclude parametrization, marker classification, schema-conforming emission, unreachable-root
  error distinctness, CLI exit codes, domain-neutrality contract scan, e2e byte-identical re-run.
- The e2e schema-validation test (`test_end_to_end_instances_validate_against_schema`) previously carried a
  pre-merge `skipif`; the schema `schemas/discovery/v1/evidence-reference.schema.json` is now present on the
  merged branch and the test executes and passes (verified with a verbose targeted run: 3 passed, 0 skipped).
- No temporary files: all filesystem behavior goes through `mem_fs_path`.

## Non-Blocking Observations

1. **`quality-tiers.yml` absent at repo root.** `.claude/rules/quality-tiers.md` states every project must
   be classified in `quality-tiers.yml`; the file does not exist in the worktree. This is a pre-existing
   repo-wide condition, not introduced or worsened by this branch, and coverage thresholds are uniform
   across tiers so no gate outcome changes. Recorded for repo maintenance, not remediation of this feature.
   (Under the tier definitions, `scripts/dev_tools` is dev tooling — T4 — so property-based-test obligations
   do not attach.)
2. **Stateful analyzer instance.** `InventoryAnalyzer` stashes the run context in `parse` and later stages
   read it via `_require_ctx()`. This is a mild deviation from a fully-threaded pipeline but is guarded with
   a specific `AnalyzerError` on misuse and is documented; acceptable as-is.
3. **Branch-coverage headline formula.** The prior review reported 87.05% using `1 - (partial/branches)`;
   this reaudit reports 79.25% using `covered_branches/num_branches` (the stricter, conventional formula,
   and the one in the cycle-2 evidence). Both satisfy the >= 75% gate. Future evidence should stay on the
   `covered/num` formula for consistency.
4. **e2e schema path fixture.** `test_inventory_e2e.py::_context` points `schema_path` at a file that does
   not exist in the in-memory tree; this is intentional (the emitter only computes a relative path and never
   reads the schema), but a one-line comment would prevent a future reader from "fixing" it.

## Verdict

PASS — 0 blocking findings. The analyzer framework code is unchanged since the prior clean review, and both
post-audit changes (pyproject union, bundle mirror) are correct and verified.
