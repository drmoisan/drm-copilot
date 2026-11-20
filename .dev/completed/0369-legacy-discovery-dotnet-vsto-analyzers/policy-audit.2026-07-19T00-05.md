# Policy Compliance Audit — legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Timestamp: 2026-07-19T00-05
- Reviewer: feature-review agent
- Work mode: full-feature (marker `- Work Mode: full-feature` in `issue.md`)
- Feature folder: `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369`
- Nature of review: re-audit after remediation cycle 3, which addressed the prior blocking finding (PA-1 / R-1): the mandatory PowerShell coverage artifact was absent for the two pushed-down `.ps1` bundle mirror files. Cycle 3 produced `artifacts/pester/powershell-coverage.xml` (present on disk, 190943 bytes) and committed a durable coverage summary under `evidence/qa-gates/` (`r3c3-` prefix).
- Template note: the MCP asset resolver (`resolve_policy_audit_template_asset`) is not exposed in this execution environment. This artifact follows the required artifact shape defined by `feature-review-workflow` and mirrors the structure of the prior template-derived audit (`policy-audit.2026-07-18T23-16.md`). This is a documented environmental assumption, not a scope deviation.

## Scope and Baseline

- Base branch (resolved): `epic/legacy-discovery-and-parity-integration`
- Merge-base SHA: `01fb34a8468090db01db471bb339a0dd6391a9d7`
- Head SHA: `08b65760fdbcc61b4bff4db8a0d29921f4a201be`
- Diff range: `01fb34a8468090db01db471bb339a0dd6391a9d7..08b65760fdbcc61b4bff4db8a0d29921f4a201be`
- The merge-base equals the resolved base head (`01fb34a8`), so the base is fully merged into the feature branch; the two-dot diff over this range is the full branch-vs-base diff.
- Audit scope: the full branch diff versus the resolved base. Scope was not narrowed to any plan, task, phase, or file subset.

### PR-context freshness

The refreshed PR-context summary (`artifacts/pr_context.summary.txt`) records the correct base/head for this cycle (base `01fb34a8`, head `08b65760`) and was used as primary evidence. The changed-file inventory and coverage claims were cross-checked directly against the git range and against the on-disk coverage artifacts in the feature worktree; those direct observations are authoritative where they add precision.

### Languages with changed files in the branch diff

- **Python** — five new production modules (`source_text.py`, `dotnet_inventory.py`, `vsto_office.py`, `vsto_patterns.py`, `stack_cli.py`), six test modules (`test_domain_neutrality.py` modified; `test_dotnet_inventory.py`, `test_source_text.py`, `test_stack_cli.py`, `test_stack_neutrality.py`, `test_vsto_office.py` added), raw text fixtures, and two `pyproject.toml` console-script lines. Toolchain and coverage mandatory.
- **PowerShell** — two files added under the bundled extension payload: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1` and `.../validate-discovery-artifact-gate.ps1`. PowerShell has changed files on the branch; an explicit coverage verdict is required (see Coverage Verification).
- **JSON (config)** — `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (bundle registration mirror). Not a coverage-bearing toolchain language.
- **TypeScript, C#** — zero changed source files. The `.cs.txt` / `.xmlproj.txt` / `.xml.txt` files under `tests/fixtures/discovery_dotnet_vsto/` are raw text fixtures (`.txt` suffix, not compiled), not C# source. Coverage N/A for these two languages (zero changed files).

## Rejected Scope Narrowing

None detected. No caller instruction attempted to narrow the audit scope, mark any language "informational only," or skip a coverage/toolchain check. The caller directed a full-branch-diff audit and instructed the reviewer to determine review scope per the scope invariant.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. Python: `.claude/rules/python.md` (and suppression/commenting rules where present)
5. PowerShell: `.claude/rules/powershell.md`
6. Supporting: `.claude/rules/quality-tiers.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/benchmark-baselines.md`, `.claude/skills/feature-review-workflow/SKILL.md`

No policy document was modified during this review.

## Toolchain Verdicts

### Python (primary changed language)

| Stage | Command | Result | Verdict |
|---|---|---|---|
| Formatting (Black) | `poetry run black --check .` | exit 0 (evidence `r3c3-black.2026-07-18T23-30.md`) | PASS |
| Linting (Ruff) | `poetry run ruff check .` | exit 0 (evidence `r3c3-ruff.2026-07-18T23-30.md`) | PASS |
| Type checking (Pyright) | `poetry run pyright` | 0 errors (evidence `r3c3-pyright.2026-07-18T23-30.md`) | PASS |
| Unit tests (Pytest, full suite) | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 2065 passed, 0 failed, 0 skipped (evidence `r3c3-pytest.2026-07-18T23-30.md`) | PASS |
| Coverage | parsed on-disk `artifacts/python/lcov.info` (349334 bytes) | see Coverage Verification | PASS |

Independent inspection of the five new modules confirms they are consistent with Black/Ruff/Pyright expectations: `from __future__ import annotations` throughout, fully typed signatures, no suppressions, forward-reference annotations valid under `TYPE_CHECKING`.

### PowerShell (bundle hook mirrors)

| Stage | Method | Result | Verdict |
|---|---|---|---|
| Formatting / Linting (PSScriptAnalyzer) | byte-identity to repo originals `.claude/hooks/*.ps1` | both bundle files are byte-identical to the repo originals (verified via `git show` + `diff` at head `08b65760`); the originals are the authored, linted source | PASS (by byte-identity) |
| Type checking | not applicable to PowerShell per toolchain policy | — | N/A |
| Unit tests (Pester) | discovery-artifact-gate hook logic exercised by `tests/scripts/claude-hooks/{enforce,validate}-discovery-artifact-gate.Tests.ps1` | 28 passed, 0 failed, 0 skipped (evidence `r3c3-powershell-coverage-summary.2026-07-18T23-30.md`) | PASS |
| Coverage (Pester) | parsed on-disk `artifacts/pester/powershell-coverage.xml` (190943 bytes) | line 87.27% / 87.93% (>= 85%) | PASS (see Coverage Verification) |

## Coverage Verification

Coverage was verified by parsing the pre-existing on-disk coverage artifacts in the feature worktree. Generation was not re-run.

### Python — PASS

New production modules (added this feature) — line and branch coverage parsed directly from `artifacts/python/lcov.info`:

| Module (new) | Line coverage | Branch coverage | Verdict |
|---|---|---|---|
| `scripts/dev_tools/discovery/analyzer/source_text.py` | 100.00% (144/144) | 96.15% (50/52) | PASS |
| `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py` | 96.83% (122/126) | 90.91% (40/44) | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_office.py` | 97.76% (131/134) | 93.33% (56/60) | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_patterns.py` | 100.00% (16/16) | n/a (0 branches) | PASS |
| `scripts/dev_tools/discovery/analyzer/stack_cli.py` | 94.23% (49/52) | 100.00% (2/2) | PASS |

Repo-wide (parsed from `artifacts/python/lcov.info`, 143 files):

- Line coverage: 89.29% (11138/12474) — >= 85% required → PASS
- Branch coverage: 80.09% (3628/4530) — >= 75% required → PASS
- No regression: committed `evidence/qa-gates/r3c3-python-coverage-delta.2026-07-18T23-30.md` shows line/branch identical to the Phase-0 baseline; cycle 3 added no Python production code.

Every new module exceeds the new-file target (line >= 85%, branch >= 75%) and the supplementary 90% new-file line target. Modified files: `pyproject.toml` (two console-script lines; not executable Python in the denominator) and `tests/.../test_domain_neutrality.py` (test file, excluded by policy). No modified production source file regressed on changed lines.

Python coverage verdict: PASS.

### PowerShell — PASS

The branch adds two `.ps1` files, so a PowerShell coverage verdict is mandatory. This gate was the prior blocking finding (PA-1 / R-1: artifact absent). Cycle 3 remediated it under acceptance option 1 (produce the artifact), not by editing policy. The artifact `artifacts/pester/powershell-coverage.xml` is present on disk (190943 bytes) and was parsed directly:

| Hook (new `.ps1`) | LINE covered/total | LINE % | Verdict |
|---|---|---|---|
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 48/55 | 87.27% | PASS |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 51/58 | 87.93% | PASS |
| Aggregate (two hooks) | 99/113 | 87.61% | PASS |

- Line coverage for each new hook and the aggregate is >= 85% → PASS.
- Branch coverage: the parsed XML emits no `BRANCH` counter for either sourcefile (confirmed directly against the artifact). Pester's `CoverageGutters` (JaCoCo) output is command/line-based and does not emit report-level branch counters. Per the established repository convention recorded under issue #344 (`remediation-ps-test-coverage.2026-07-10T20-46.md`), this is the authorized line-based-instrument limitation and the recorded line figure is the threshold value; it is a documented convention, not a skip and not a policy-document edit. Under that convention the branch requirement is satisfied by the authorized line figure.
- Tooling note carried from cycle 3: the mandated `mcp__drm-copilot__run_poshqc_test` wrapper runs against the installed server's frozen bundled runsettings, which predate the issue #366 `CodeCoverage.Path` additions for the two discovery hooks, so the wrapper's own XML omits them. The authoritative XML on disk was regenerated against the live repo runsettings using the repo PoshQC module (identical underlying operation, includes both hooks). The installed bundle converges at the next packaged extension release.

PowerShell coverage verdict: PASS.

### TypeScript, C# — N/A

Zero changed source files on the branch. Coverage N/A (legitimate: no changed files).

## Evidence Location Compliance

- Branch diff scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: none found (`git diff --name-only 01fb34a8..08b65760 | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'` → no matches).
- All feature evidence is under the canonical `<FEATURE>/evidence/<kind>/` tree (`evidence/baseline/`, `evidence/qa-gates/`, `evidence/remediation-baseline/`, `evidence/regression-testing/`, `evidence/other/`).
- `python scripts/dev_tools/validate_evidence_locations.py --root .` executed in the feature worktree: exit 0 (no violations).

Verdict: PASS.

## Modified-Workflow-Needs-Green-Run Rule

The branch diff modifies no path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. The two `.ps1` files are Claude Code hooks under `.claude/hooks/` and the bundled `extensions/**` mirror, not CI workflow steps. The rule does not fire.

Verdict: PASS (rule not triggered).

## Bundle Push-Down Integrity

- `enforce-discovery-artifact-gate.ps1`: bundle copy byte-identical to repo original at head `08b65760` (`diff` clean). PASS.
- `validate-discovery-artifact-gate.ps1`: bundle copy byte-identical to repo original at head `08b65760` (`diff` clean). PASS.
- `settings.json`: the bundle registration adds both hooks (`PreToolUse`-side `enforce-discovery-artifact-gate.ps1` and `SubagentStop`-side `validate-discovery-artifact-gate.ps1`); the repo `.claude/settings.json` carries the same two registrations (grep count 2). Registration mirror is consistent. PASS.
- No merge conflict markers present in `scripts/dev_tools/discovery/analyzer/**` or `pyproject.toml`. PASS.

## File-Size Limit (<= 500 lines)

All new production and test files are within the limit (largest: `source_text.py` 476, `test_vsto_office.py` 474, `dotnet_inventory.py` 457, `vsto_office.py` 451). The two added `.ps1` files are 213 and 237 lines. Raw text fixtures are exempt. Verdict: PASS.

## Dependency Policy

`pyproject.toml` adds only two `[tool.poetry.scripts]` console-entry lines (`dev.discovery.dotnet`, `dev.discovery.vsto`). No new runtime or dev dependency was added; the implementation uses the Python standard library only (`re`, `hashlib`, `argparse`, `json`, `dataclasses`, `datetime`, `pathlib`). Verdict: PASS.

## Suppression Policy

No `# noqa` or `# type: ignore` suppressions appear in the five new production modules. Verdict: PASS.

## Coverage-Exclusion Policy

No coverage `exclude`/`omit` entry matching a `src/`-equivalent production path was added; the new `scripts/dev_tools/discovery/analyzer/` modules remain in the coverage denominator (confirmed present in the lcov). Verdict: PASS.

## Consumer-Neutrality (feature-scoped, highest-risk item)

The feature-scoped contract test (`tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py`) bans consumer identifiers (`taskmaster`, `tmw`) and per-Office-application hardcoding (fully-qualified `Microsoft.Office.Interop.{Outlook,Excel,Word,PowerPoint,Access}` literals) across both production modules and raw fixtures, while permitting the generic stack literals (`csharp`, `vsto`, the `Microsoft.Office.Interop.` prefix, `.csproj`) that are this feature's legitimate subject matter. Independent inspection confirms the Office interop application name is captured as data into `metadata.interop_target` (via `INTEROP_USING_RE` named group `app`) and never branched on. Verdict: PASS.

## Overall Verdict

PASS. All Python, PowerShell, and structural gates pass. The prior blocking finding (PA-1 / R-1: mandatory PowerShell coverage artifact absent) is resolved: cycle 3 produced the coverage artifact (present on disk, 190943 bytes; parsed directly) demonstrating line coverage >= 85% for both new hooks, with the branch-instrument limitation handled by the established issue #344 convention. No new blocking findings. No new remediation is required.

## Appendix A — Findings

| ID | Severity | Area | Finding | Status |
|---|---|---|---|---|
| PA-1 (prior) | Blocking (coverage-mandatory rule) | PowerShell coverage | `artifacts/pester/powershell-coverage.xml` was absent while the branch adds two `.ps1` files | RESOLVED in cycle 3: artifact produced (190943 bytes); parsed line coverage 87.27% / 87.93% (>= 85%); branch handled under issue #344 line-based-instrument convention |

No open Blocking or PARTIAL findings.

## Appendix B — Command Reference

```
git cat-file -t 01fb34a8468090db01db471bb339a0dd6391a9d7
git cat-file -t 08b65760fdbcc61b4bff4db8a0d29921f4a201be
git merge-base 01fb34a8468090db01db471bb339a0dd6391a9d7 08b65760fdbcc61b4bff4db8a0d29921f4a201be
git diff --stat 01fb34a8468090db01db471bb339a0dd6391a9d7..08b65760fdbcc61b4bff4db8a0d29921f4a201be
git diff --name-status 01fb34a8468090db01db471bb339a0dd6391a9d7..08b65760fdbcc61b4bff4db8a0d29921f4a201be
diff <(git show 08b65760:.claude/hooks/enforce-discovery-artifact-gate.ps1) <(git show 08b65760:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1)
diff <(git show 08b65760:.claude/hooks/validate-discovery-artifact-gate.ps1) <(git show 08b65760:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1)
git diff --name-only 01fb34a8..08b65760 | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'
git diff --name-only 01fb34a8..08b65760 | grep -E '(\.github/workflows/|scripts/benchmarks/|\.github/actions/)'
python scripts/dev_tools/validate_evidence_locations.py --root .
# coverage parsed directly from on-disk artifacts (not regenerated):
#   artifacts/python/lcov.info                  (Python: repo-wide 89.29% line / 80.09% branch; all new modules >= 94% line)
#   artifacts/pester/powershell-coverage.xml    (PowerShell: 87.27% / 87.93% line; no BRANCH counter -> issue #344 convention)
```
