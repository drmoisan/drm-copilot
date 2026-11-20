# Policy Compliance Audit — legacy-discovery-analyzer-framework (#363), Remediation Cycle 3 Exit Reaudit

- Timestamp: 2026-07-18T17-40 (UTC)
- Branch: `feature/legacy-discovery-analyzer-framework-363` at head `f22b09e8`
- Diff base: `origin/epic/legacy-discovery-and-parity-integration` (epic integration branch; PR #378 base)
- Work Mode: `full-feature` (persisted marker in `issue.md` line 10)
- Prior audit: `policy-audit.2026-07-18T16-54.md` (cycle-2 exit reaudit, PASS, 0 blocking)
- Reviewer: feature-review agent (independent verification; all commands rerun in this worktree)

## Scope

Full branch diff `origin/epic/legacy-discovery-and-parity-integration...HEAD`: 100 files,
+4375/-61. Production scope: 7 Python analyzer modules (`scripts/dev_tools/discovery/analyzer/`),
8 mirrored test files, `pyproject.toml` (console script + one `exclude_lines` pattern), 4 bundled
agent payload files under `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`,
and the pack manifest `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
Remainder is feature documentation and evidence under the canonical feature folder.

Cycle-3 delta (commits `64a94ad2`, `99e4772d`, `f22b09e8` since the cycle-2 reaudit at `3d2544ec`),
verified by `git diff 3d2544ec..HEAD --name-status`: exactly one production file changed —
`core.json` (+4 lines) — plus remediation-cycle documentation and evidence. No repo `.claude/`
source file, no bundled payload file, and no Python/TypeScript source file changed in cycle 3.

## Rejected Scope Narrowing

None. The caller prompt supplied focus areas for the cycle-3 delta but did not restrict the audit
scope; the full branch diff against the resolved base was reviewed.

## Cycle-3 Change Compliance (core.json)

- **Valid JSON**: `python -m json.tool` — exit 0.
- **Minimal**: exactly 4 added lines registering the four #365 agent paths
  (`legacy-parity-analyst`, `migration-coverage-reviewer`, `requirements-reconciler`,
  `runtime-characterization-analyst`); no other key or entry touched.
- **Alphabetical ordering**: the `.claude/agents/` group within `paths` is fully sorted
  (17 entries, verified programmatically). The three non-monotonic pairs in the overall `paths`
  array are pre-existing category-group boundaries (settings -> agents -> skills -> lib), not
  introduced by this change.
- **Formatting**: `npx prettier --check` on `core.json` — "All matched files use Prettier code
  style!".
- **No source or payload drift**: all four bundled payload files are byte-identical to their repo
  `.claude/agents/` sources (verified with `diff -q`); the branch diff contains zero changes under
  the repo-root `.claude/` tree.

## Toolchain Verification (independently rerun)

### Python

| Stage | Command | Result |
|---|---|---|
| Formatting | `poetry run black --check scripts tests` | PASS — 290 files unchanged |
| Linting | `poetry run ruff check scripts tests` | PASS — all checks passed |
| Type checking | `poetry run pyright` | PASS — 0 errors, 0 warnings |
| Unit/integration tests | `poetry run pytest --cov --cov-branch` | PASS — 1769 passed, 0 failed |
| Bundle contract test | `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | PASS — 7/7, includes `test_bundled_claude_payload_contains_all_repo_runtime_contracts` |

### TypeScript / extension

| Stage | Command | Result |
|---|---|---|
| Formatting | `npx prettier --check` (core.json) | PASS |
| Linting | `npm run lint` (eslint src test) | PASS — 0 problems |
| Type checking | `npm run typecheck` (tsc --noEmit) | PASS |
| Tests | `node run-jest.cjs --testMatch "**/test/**/*.test.ts"` | PASS — 158 suites, 1886/1886 tests |
| Target test | `--testPathPattern claude-pack-manifest-completeness` | PASS — 7/7 |
| Coverage | `npm run test:coverage -- --testMatch "**/test/**/*.test.ts"` | PASS — 96.74% line / 89.29% branch |

## Test-Discovery Environment Note (validated)

The CI-exact command `npm --prefix extensions/drm-copilot run test` was rerun in this worktree and
reproduces the reported behavior: "No tests found" (exit 1), with Jest reporting
`testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/.../test/**/*.test.ts — 0 matches`
against 353 checked files. The resolved rootDir contains a literal backslash segment
(`\.claude`) that the glob matcher treats as an escape, so discovery fails only under this
`.claude/worktrees/` checkout path. The executor's `--testMatch "**/test/**/*.test.ts"` override
affects discovery only: it discovered the full expected population (158 suites / 1886 tests,
matching the CI suite size), including the previously failing manifest-completeness test, and
coverage collection and `coverageThreshold` enforcement ran unmodified. Conclusion: the override
does not mask a real failure; CI checks out to a normal path and is unaffected. The reasoning
recorded in `evidence/baseline/remediation3-ci-test-command.2026-07-18T17-05.md` is sound.

## Coverage Verification (per language)

| Language | Changed files in diff | Artifact | Verdict |
|---|---|---|---|
| Python | Yes (7 production, 8 test, pyproject.toml) | `artifacts/python/lcov.info` (regenerated during this reaudit) | PASS — repo-wide 88.62% line (10292/11614) / 79.25% branch (3400/4290) vs thresholds 85%/75%; all 7 new analyzer modules 100% line / 100% branch; identical to cycle-2 figures — no regression |
| TypeScript | Yes (core.json — JSON resource under the extension; no `src/**` code changed) | `extensions/drm-copilot/coverage/lcov.info` (regenerated during this reaudit) | PASS — repo-wide 96.74% line (36133/37349) / 89.29% branch (5034/5638); identical to the cycle-3 baseline; per-file `coverageThreshold` gates satisfied; no regression |
| PowerShell | None (bundled `.md` mirrors are Markdown resources) | n/a | N/A (zero changed files) |
| C# | None | n/a | N/A (zero changed files) |

Coverage exclusion policy: the `pyproject.toml` delta adds one `[tool.coverage.report]
exclude_lines` pattern (`^\s*\.\.\.\s*$`) for `typing.Protocol` ellipsis bodies. This is a
line-level type-only exclusion sanctioned by the spec and by the general-unit-test rule
(type-only constructs with no executable behavior); it is not a production-file exclusion. No
production path is excluded from coverage; all 7 analyzer modules appear in the lcov denominator.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0, no
  violations.
- Branch-diff scan: no files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`,
  or `artifacts/coverage/`. All cycle-1/2/3 evidence is under the canonical
  `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/<kind>/` tree.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events; no non-canonical path was supplied.

## CI-Workflow and Benchmark-Baseline Rules

No workflow YAML and no benchmark baseline is touched by this diff; `.claude/rules/ci-workflows.md`
and `.claude/rules/benchmark-baselines.md` impose no obligations here.

## Remediation Exit Conditions (cycle 3)

- CI failure root cause (`claude-pack-manifest-completeness.test.ts`) fixed: target test 7/7 PASS
  (independently rerun); regression evidence pair
  `remediation3-fail-before-` / `remediation3-pass-after-manifest-completeness.2026-07-18T17-05.md`
  present.
- Both bundle-contract tests pass: Python payload contract 7/7 and TypeScript manifest
  completeness 7/7 (both independently rerun).
- Full toolchains green in a single pass (tables above).
- Coverage thresholds hold with no regression (table above).
- PR #378 mergeable against the integration branch: `gh pr view 378` reports
  `mergeable: MERGEABLE`, `mergeStateStatus: CLEAN`, head `f22b09e8...` (improved from UNSTABLE at
  cycle 2).

## Findings Summary

- Blocking (FAIL): 0
- Blocking (PARTIAL): 0
- Non-blocking observations: recorded in `code-review.2026-07-18T17-40.md` (carried-forward note
  that `quality-tiers.yml` is absent at repo root — a pre-existing repo-wide condition not
  introduced or worsened by this branch; the uniform coverage thresholds were enforced directly).

Verdict: PASS — no policy violations found in the branch diff at head `f22b09e8`.
