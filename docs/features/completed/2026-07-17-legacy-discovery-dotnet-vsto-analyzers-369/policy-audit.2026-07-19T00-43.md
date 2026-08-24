# Policy Compliance Audit — legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Timestamp: 2026-07-19T00-43
- Reviewer: feature-review agent
- Work mode: full-feature (marker `- Work Mode: full-feature` in `issue.md`)
- Feature folder: `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369`
- Nature of review: re-audit after remediation cycle 4. Cycle 4 resolved the CI failure `claude-pack-manifest-completeness` (extension jest suite) by registering the two cycle-2 bundle hook mirrors in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (a two-line JSON edit). This cycle added no Python or PowerShell source code.
- Template note: the MCP asset resolver (`resolve_policy_audit_template_asset`) is not exposed in this execution environment. This artifact follows the required artifact shape defined by `feature-review-workflow` and mirrors the structure of the prior template-derived audits (`policy-audit.2026-07-19T00-05.md`). Documented environmental assumption, not a scope deviation.

## Scope and Baseline

- Base branch (resolved): `epic/legacy-discovery-and-parity-integration`
- Merge-base SHA: `01fb34a8468090db01db471bb339a0dd6391a9d7`
- Head SHA: `937cfeb7fa9ea362454fa2d4834bed6f4416ca21`
- Diff range: `01fb34a8468090db01db471bb339a0dd6391a9d7..937cfeb7fa9ea362454fa2d4834bed6f4416ca21`
- The merge-base equals the resolved base head (`01fb34a8`), so the base is fully merged into the feature branch; the two-dot diff over this range is the full branch-vs-base diff.
- Audit scope: the full branch diff versus the resolved base. Scope was not narrowed to any plan, task, phase, or file subset.

### PR-context freshness

The refreshed PR-context summary (`artifacts/pr_context.summary.txt`) records the correct base/head for this cycle (base `01fb34a8`, head `937cfeb7`) and was used as primary evidence. The changed-file inventory and coverage claims were cross-checked directly against the git range and against the on-disk coverage artifacts in the feature worktree; those direct observations are authoritative where they add precision.

### Languages with changed files in the branch diff

- **Python** — five new production modules (`source_text.py`, `dotnet_inventory.py`, `vsto_office.py`, `vsto_patterns.py`, `stack_cli.py`), six test modules (`test_domain_neutrality.py` modified; `test_dotnet_inventory.py`, `test_source_text.py`, `test_stack_cli.py`, `test_stack_neutrality.py`, `test_vsto_office.py` added), raw text fixtures, and two `pyproject.toml` console-script lines. Toolchain and coverage mandatory.
- **PowerShell** — two files added under the bundled extension payload: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1` and `.../validate-discovery-artifact-gate.ps1`. PowerShell has changed files on the branch; an explicit coverage verdict is required (see Coverage Verification).
- **JSON (config)** — `extensions/.../pack-manifests/core.json` (cycle-4 manifest registration; two lines) and `extensions/.../.claude/settings.json` (bundle hook registration mirror). Not a coverage-bearing toolchain language.
- **TypeScript, C#** — zero changed source files. The `.cs.txt` / `.xmlproj.txt` / `.xml.txt` files under `tests/fixtures/discovery_dotnet_vsto/` are raw text fixtures (`.txt` suffix, not compiled), not C# source. Coverage N/A for these two languages (zero changed files).

## Rejected Scope Narrowing

None detected. No caller instruction attempted to narrow the audit scope, mark any language "informational only," or skip a coverage/toolchain check. The caller directed a full-branch-diff audit and instructed the reviewer to determine review scope per the scope invariant.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. Python: `.claude/rules/python.md`
5. PowerShell: `.claude/rules/powershell.md`
6. Supporting: `.claude/rules/quality-tiers.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/benchmark-baselines.md`, `.claude/rules/tonality.md`, `.claude/skills/feature-review-workflow/SKILL.md`

No policy document was modified during this review.

## Toolchain Verdicts

Cycle 4 changed only `core.json` (a JSON data file) plus documentation/evidence. It added no Python or PowerShell source, so the Python and PowerShell toolchain verdicts carry forward unchanged from the prior cycles' committed evidence and are re-confirmed by the cycle-4 full-suite re-run.

### Python (primary changed language)

| Stage | Command | Result | Verdict |
|---|---|---|---|
| Formatting (Black) | `poetry run black --check .` | exit 0 (evidence `r4c4-black.2026-07-19T00-23.md`) | PASS |
| Linting (Ruff) | `poetry run ruff check .` | exit 0 (evidence `r4c4-ruff.2026-07-19T00-23.md`) | PASS |
| Type checking (Pyright) | `poetry run pyright` | 0 errors (evidence `r4c4-pyright.2026-07-19T00-23.md`) | PASS |
| Unit tests (Pytest, full suite) | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 2065 passed, 0 failed, 0 skipped (evidence `r4c4-pytest.2026-07-19T00-23.md`) | PASS |
| Coverage | parsed on-disk `artifacts/python/lcov.info` (349334 bytes) | see Coverage Verification | PASS |

Independent inspection at head `937cfeb7` confirms the five new production modules carry no `# noqa` / `# type: ignore` suppressions (grep count 0 each) and use `from __future__ import annotations` with fully typed signatures.

### PowerShell (bundle hook mirrors)

| Stage | Method | Result | Verdict |
|---|---|---|---|
| Formatting / Linting (PSScriptAnalyzer) | byte-identity to repo originals `.claude/hooks/*.ps1` | both bundle files verified byte-identical to the repo originals in the working tree at head `937cfeb7` (`diff` clean); the originals are the authored, linted source | PASS (by byte-identity) |
| Type checking | not applicable to PowerShell per toolchain policy | — | N/A |
| Unit tests (Pester) | discovery-artifact-gate hook logic exercised by `tests/scripts/claude-hooks/{enforce,validate}-discovery-artifact-gate.Tests.ps1` | 28 passed, 0 failed, 0 skipped (evidence `r3c3-powershell-coverage-summary.2026-07-18T23-30.md`) | PASS |
| Coverage (Pester) | parsed on-disk `artifacts/pester/powershell-coverage.xml` (190943 bytes) | line 87.27% / 87.93% (>= 85%) | PASS (see Coverage Verification) |

## Coverage Verification

Coverage was verified by parsing the pre-existing on-disk coverage artifacts in the feature worktree at head `937cfeb7`. Generation was not re-run. Because cycle 4 changed only a JSON manifest and documentation, coverage figures are unchanged from the cycle that produced each coverage-bearing artifact; the cycle-4 delta artifact (`r4c4-python-coverage-delta.2026-07-19T00-23.md`) confirms zero change.

### Python — PASS

New production modules — line and branch coverage parsed first-hand from `artifacts/python/lcov.info`:

| Module (new) | Line coverage | Branch coverage | Verdict |
|---|---|---|---|
| `scripts/dev_tools/discovery/analyzer/source_text.py` | 100.00% (144/144) | 96.15% (50/52) | PASS |
| `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py` | 96.83% (122/126) | 90.91% (40/44) | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_office.py` | 97.76% (131/134) | 93.33% (56/60) | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_patterns.py` | 100.00% (16/16) | n/a (0 branches) | PASS |
| `scripts/dev_tools/discovery/analyzer/stack_cli.py` | 94.23% (49/52) | 100.00% (2/2) | PASS |

Repo-wide (parsed first-hand from `artifacts/python/lcov.info`):

- Line coverage: 89.29% (11138/12474) — >= 85% required → PASS
- Branch coverage: 80.09% (3628/4530) — >= 75% required → PASS
- The full-suite term report (`r4c4-pytest.2026-07-19T00-23.md`) records a coverage.py branch figure of 87.55% (3966/4530); the lcov BRDA-based figure of 80.09% is the stricter of the two. Both exceed the 75% threshold; the difference is a measurement-basis difference (lcov BRDA vs coverage.py branch pairs), not a regression.
- No regression: `r4c4-python-coverage-delta.2026-07-19T00-23.md` shows line/branch/TOTAL byte-identical to the cycle-4 Phase-0 baseline; cycle 4 added no Python production code.

Every new module exceeds the new-file target (line >= 85%, branch >= 75%) and the supplementary 90% new-file line target. Modified files: `pyproject.toml` (two console-script lines; not executable Python in the denominator) and `tests/.../test_domain_neutrality.py` (test file, excluded by policy). No modified production source file regressed on changed lines.

Python coverage verdict: PASS.

### PowerShell — PASS

The branch adds two `.ps1` files, so a PowerShell coverage verdict is mandatory. Cycle 4 changed no PowerShell code, so the cycle-3 coverage artifact is authoritative and unchanged. The artifact `artifacts/pester/powershell-coverage.xml` is present on disk (190943 bytes) and was parsed first-hand:

| Hook (new `.ps1`) | LINE covered/total | LINE % | Verdict |
|---|---|---|---|
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 48/55 | 87.27% | PASS |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 51/58 | 87.93% | PASS |
| Aggregate (two hooks) | 99/113 | 87.61% | PASS |

- Line coverage for each new hook and the aggregate is >= 85% → PASS.
- Branch coverage: the parsed XML emits no `BRANCH` counter for either sourcefile (confirmed first-hand: `type="BRANCH"` absent). Pester's `CoverageGutters` (JaCoCo) output is command/line-based and does not emit report-level branch counters. Per the established repository convention recorded under issue #344 (`remediation-ps-test-coverage.2026-07-10T20-46.md`), this is the authorized line-based-instrument limitation and the recorded line figure is the threshold value; it is a documented convention, not a skip and not a policy-document edit.

PowerShell coverage verdict: PASS.

### TypeScript, C# — N/A

Zero changed source files on the branch. Coverage N/A (legitimate: no changed files).

## Extension Test Suite (cycle-4 CI-failure resolution)

The cycle-4 change registers both bundle hook paths in `core.json`. The regression that failed CI (`claude-pack-manifest-completeness`, `expect(missing).toEqual([])` receiving the two unregistered hook paths) is resolved:

- `r4c4-pass-after-manifest-completeness.2026-07-19T00-23.md`: the `claude-pack-manifest-completeness` suite now passes (7 passed, 7 total; previously 1 failed / 6 passed). The `missing` set is empty.
- `r4c4-extension-suite.2026-07-19T00-23.md`: full extension jest suite green (158 suites, 1886 tests, 0 failed), manifest-completeness suite included.
- `r4c4-manifest-edit-verification.2026-07-19T00-23.md`: `core.json` remains well-formed JSON; the diff adds exactly two alphabetically-ordered `paths` entries and nothing else.
- Independent re-verification in the working tree at head `937cfeb7`: `core.json` parses as valid JSON and contains both `discovery-artifact-gate` entries (grep count 2); `settings.json` parses as valid JSON.

Verdict: PASS.

## Evidence Location Compliance

- Branch diff scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: none found (`git diff --name-only 01fb34a8..937cfeb7 | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'` → no matches).
- All feature evidence is under the canonical `<FEATURE>/evidence/<kind>/` tree (`evidence/baseline/`, `evidence/qa-gates/`, `evidence/remediation-baseline/`, `evidence/regression-testing/`, `evidence/other/`).

Verdict: PASS.

## Modified-Workflow-Needs-Green-Run Rule

The branch diff modifies no path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (`git diff --name-only 01fb34a8..937cfeb7 | grep -E '(\.github/workflows/|scripts/benchmarks/|\.github/actions/)'` → no matches). The two `.ps1` files are Claude Code hooks under `.claude/hooks/` and the bundled `extensions/**` mirror, not CI workflow steps. The `core.json` manifest is a bundle packaging file, not a workflow. The rule does not fire.

Verdict: PASS (rule not triggered).

## Bundle Push-Down Integrity

- `enforce-discovery-artifact-gate.ps1`: bundle copy verified byte-identical to repo original in the working tree at head `937cfeb7` (`diff` clean). PASS.
- `validate-discovery-artifact-gate.ps1`: bundle copy verified byte-identical to repo original in the working tree at head `937cfeb7` (`diff` clean). PASS.
- `settings.json`: registration adds both hooks (`PreToolUse`-side `enforce-discovery-artifact-gate.ps1` and `SubagentStop`-side `validate-discovery-artifact-gate.ps1`); consistent with the repo `.claude/settings.json` registrations. PASS.
- `core.json` (cycle 4): both bundle hook paths now registered in the `paths` array at alphabetically-correct positions; no other entry reordered. This closes the cycle-2 push-down: the Python bundle contract test (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) requires the mirror, and the extension `claude-pack-manifest-completeness` test requires manifest registration; both now pass. PASS.
- No merge conflict markers present in `scripts/dev_tools/discovery/analyzer/**` or `pyproject.toml`. PASS.

## File-Size Limit (<= 500 lines)

All new production and test files are within the limit. Production (head `937cfeb7`): `source_text.py` 476, `dotnet_inventory.py` 457, `vsto_office.py` 451, `stack_cli.py` 214, `vsto_patterns.py` 87. Tests: `test_vsto_office.py` 474, `test_dotnet_inventory.py` 410, `test_source_text.py` 325, `test_stack_cli.py` 212, `test_stack_neutrality.py` 129. The two added `.ps1` files are 213 and 237 lines. Raw text fixtures are exempt. Verdict: PASS.

## Dependency Policy

`pyproject.toml` adds only two `[tool.poetry.scripts]` console-entry lines (`dev.discovery.dotnet`, `dev.discovery.vsto`). No new runtime or dev dependency was added; no parser/grammar dependency (`tree.sitter|roslyn|libcst|antlr|pygments|parso`) is present. The implementation uses the Python standard library only. Verdict: PASS.

## Suppression Policy

No `# noqa` or `# type: ignore` suppressions appear in the five new production modules (grep count 0 each at head `937cfeb7`). Verdict: PASS.

## Coverage-Exclusion Policy

No coverage `exclude`/`omit` entry matching a `src/`-equivalent production path was added; the new `scripts/dev_tools/discovery/analyzer/` modules remain in the coverage denominator (confirmed present in the lcov). Verdict: PASS.

## Consumer-Neutrality (feature-scoped, highest-risk item)

Independent scan of the five production modules at head `937cfeb7` for consumer identifiers and per-application hardcoding (`taskmaster|tmw|interop\.outlook|interop\.excel|interop\.word|interop\.powerpoint|interop\.access`) returned zero matches. The feature-scoped contract test (`tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py`) bans consumer identifiers and per-Office-application hardcoding while permitting the generic stack literals (`csharp`, `vsto`, the `Microsoft.Office.Interop.` prefix, `.csproj`, customUI URIs) that are this feature's legitimate subject matter. The Office interop application name is captured as data into `metadata.interop_target` (via `INTEROP_USING_RE` named group `app`) and never branched on. Verdict: PASS.

## Overall Verdict

PASS. All Python, PowerShell, and structural gates pass. The cycle-4 CI failure (`claude-pack-manifest-completeness`) is resolved by the two-line `core.json` registration; the full extension jest suite (1886 tests) and full Python toolchain (2065 tests, 89.29% line / 80.09% lcov branch, no regression) are green, the Python bundle contract test passes, and the cycle-3 PowerShell coverage evidence (present and re-parsed) remains valid. No new blocking findings. No new remediation is required.

## Appendix A — Findings

| ID | Severity | Area | Finding | Status |
|---|---|---|---|---|
| PA-1 (prior, cycle 3) | Blocking (coverage-mandatory rule) | PowerShell coverage | `artifacts/pester/powershell-coverage.xml` was absent while the branch adds two `.ps1` files | RESOLVED in cycle 3: artifact produced and parsed (line 87.27% / 87.93%, >= 85%); branch handled under issue #344 line-based-instrument convention. Re-parsed first-hand this cycle; unchanged. |
| PA-2 (prior, cycle 4 entry) | Blocking (S9 CI-green gate) | Extension manifest | Two bundled discovery hooks not registered in any pack manifest; `claude-pack-manifest-completeness` failed | RESOLVED in cycle 4: both paths registered in `core.json`; manifest-completeness suite passes (7/7); full extension suite green (1886/1886) |

No open Blocking or PARTIAL findings.

## Appendix B — Command Reference

```
git cat-file -t 01fb34a8468090db01db471bb339a0dd6391a9d7
git cat-file -t 937cfeb7fa9ea362454fa2d4834bed6f4416ca21
git log -1 --format='%H %ci %s' 937cfeb7fa9ea362454fa2d4834bed6f4416ca21
git diff --stat 01fb34a8468090db01db471bb339a0dd6391a9d7..937cfeb7fa9ea362454fa2d4834bed6f4416ca21
git diff --name-status 01fb34a8468090db01db471bb339a0dd6391a9d7..937cfeb7fa9ea362454fa2d4834bed6f4416ca21
git diff 01fb34a8..937cfeb7 -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
diff .claude/hooks/enforce-discovery-artifact-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1
diff .claude/hooks/validate-discovery-artifact-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1
grep -c discovery-artifact-gate extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
python -c "import json; json.load(open('extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'))"
git diff --name-only 01fb34a8..937cfeb7 | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'
git diff --name-only 01fb34a8..937cfeb7 | grep -E '(\.github/workflows/|scripts/benchmarks/|\.github/actions/)'
# coverage parsed first-hand from on-disk artifacts (not regenerated):
#   artifacts/python/lcov.info                (Python: repo-wide 89.29% line / 80.09% lcov branch; all new modules >= 94% line)
#   artifacts/pester/powershell-coverage.xml  (PowerShell: 87.27% / 87.93% line; no BRANCH counter -> issue #344 convention)
```
