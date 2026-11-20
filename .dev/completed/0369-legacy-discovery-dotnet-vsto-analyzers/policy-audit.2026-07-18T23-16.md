# Policy Compliance Audit — legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Timestamp: 2026-07-18T23-16
- Reviewer: feature-review agent
- Work mode: full-feature (marker `- Work Mode: full-feature` in `issue.md`)
- Feature folder: `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369`
- Nature of review: re-audit after two remediation cycles (pyproject.toml merge-conflict resolution against the integration branch; bundle push-down of two `.claude` hook files plus the settings.json registration mirror).

## Scope and Baseline

- Base branch (resolved): `epic/legacy-discovery-and-parity-integration`
- Merge-base SHA: `01fb34a8468090db01db471bb339a0dd6391a9d7`
- Head SHA: `62662879766c9280015800634195a9582cb52041`
- Diff range: `01fb34a8468090db01db471bb339a0dd6391a9d7..62662879766c9280015800634195a9582cb52041`
- The merge-base equals the current base head (`01fb34a8`), so the base is fully merged into the feature branch; the two-dot diff over this range is the full branch-vs-base diff.
- Audit scope: the full branch diff versus the resolved base. Scope was not narrowed to any plan, task, phase, or file subset.

### PR-context freshness

The canonical PR-context artifacts (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`) were stale at review time: they recorded merge-base `3a4985fa...` and head `e5b89002...`, predating the merge-integration commit and the bundle push-down. Scope was therefore re-derived directly from git against the base branch supplied by the caller (`01fb34a8..62662879`). The stale summary is retained as secondary/historical evidence only; the git-derived diff is authoritative for this audit.

### Languages with changed files in the branch diff

- **Python** — five new production modules, six test modules (one modified), raw text fixtures, and two `pyproject.toml` console-script lines. Toolchain and coverage mandatory.
- **PowerShell** — two files added under the bundled extension payload: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1` and `.../validate-discovery-artifact-gate.ps1`. PowerShell now has changed files on the branch; an explicit coverage verdict is required (see Coverage Verification).
- **JSON (config)** — `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (bundle registration mirror). Not a coverage-bearing toolchain language.
- **TypeScript, C#** — zero changed files. The `.cs.txt` / `.xmlproj.txt` / `.xml.txt` files under `tests/fixtures/discovery_dotnet_vsto/` are raw text fixtures (`.txt` suffix, not compiled), not C# source. Coverage N/A for these two languages (zero changed files).

## Rejected Scope Narrowing

None detected. No caller instruction attempted to narrow the audit scope, mark any language "informational only," or skip a coverage/toolchain check. The caller explicitly directed a full-branch-diff audit including the merge integration and bundle push-down.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. Python: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`
5. PowerShell: `.claude/rules/powershell.md`
6. Supporting: `.claude/rules/quality-tiers.md`, `.claude/skills/feature-review-workflow/SKILL.md`

No policy document was modified during this review.

## Toolchain Verdicts

### Python (primary changed language)

| Stage | Command | Result | Verdict |
|---|---|---|---|
| Formatting (Black) | `poetry run black --check .` | exit 0 (evidence `r2c2-black.2026-07-18T22-58.md`) | PASS |
| Linting (Ruff) | `poetry run ruff check .` | exit 0 (evidence `r2c2-ruff.2026-07-18T22-58.md`) | PASS |
| Type checking (Pyright, strict) | `poetry run pyright` | 0 errors (evidence `r2c2-pyright.2026-07-18T22-58.md`) | PASS |
| Unit tests (Pytest, full suite) | `poetry run pytest --cov --cov-branch` | 2065 passed, 0 failed (evidence `r2c2-pytest.2026-07-18T22-58.md`) | PASS |
| Coverage (lcov artifact) | inspected `artifacts/python/lcov.info` | see Coverage Verification | PASS |

The previously-failing contract test `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` now passes after the bundle push-down. Independent inspection of the five new modules confirms Black/Ruff/Pyright cleanliness.

### PowerShell (bundle hook mirrors)

| Stage | Method | Result | Verdict |
|---|---|---|---|
| Formatting / Linting (PSScriptAnalyzer) | byte-identity to repo originals `.claude/hooks/*.ps1` | both bundle files are byte-identical to the repo originals (verified by `diff`); the originals are the linted authored source | PASS (by byte-identity) |
| Type checking | not applicable to PowerShell per the toolchain policy | — | N/A |
| Unit tests (Pester) | hook logic tested via `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` on the repo originals | passing suite (repo originals) | PASS |
| Coverage (Pester) | inspected for `artifacts/pester/powershell-coverage.xml` | artifact absent | FAIL (see Coverage Verification) |

## Coverage Verification

Coverage was verified by inspecting pre-existing artifacts. Generation was not re-run.

### Python — PASS

Repo-wide (from `artifacts/python/lcov.info`, corroborated by `evidence/qa-gates/r2c2-coverage-delta.2026-07-18T22-58.md`):

- Line coverage: 89.29% (>= 85% required) → PASS
- Branch coverage: 87.55% (>= 75% required) → PASS
- No regression: line and branch coverage are byte-identical to the Phase-0 baseline; no Python production code was added or modified by the merge/bundle cycles.

New production modules (added this feature) — per-file line/branch coverage parsed from `artifacts/python/lcov.info`:

| Module (new) | Line coverage | Branch coverage | Verdict |
|---|---|---|---|
| `scripts/dev_tools/discovery/analyzer/source_text.py` | 100.0% (144/144) | 96.2% (50/52) | PASS |
| `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py` | 96.8% (122/126) | 90.9% (40/44) | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_office.py` | 97.8% (131/134) | 93.3% (56/60) | PASS |
| `scripts/dev_tools/discovery/analyzer/stack_cli.py` | 94.2% (49/52) | 100.0% (2/2) | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_patterns.py` | 100.0% (16/16) | 100.0% (0/0) | PASS |

All new modules exceed both the new-file target (line >= 85%, branch >= 75%) and the stricter 90% new-file line target used as a supplementary check. Modified source files: `pyproject.toml` (two console-script lines; not executable Python measured by coverage) and `tests/.../test_domain_neutrality.py` (test file, excluded from the denominator by policy). No modified production source file regressed on changed lines.

Python coverage verdict: PASS.

### PowerShell — FAIL (coverage artifact absent)

The branch diff adds two `.ps1` files, so PowerShell is a language with changed files and a coverage verdict is mandatory. The required artifact `artifacts/pester/powershell-coverage.xml` is absent. Per the feature-review coverage rule, "coverage artifact absent for PowerShell; coverage verification is mandatory for all languages with changed files." This is recorded as a FAIL and a remediation trigger.

Mitigating context (recorded for accurate risk assessment, does not change the verdict):

- Both added `.ps1` files are byte-identical to the pre-existing repo originals `.claude/hooks/enforce-discovery-artifact-gate.ps1` and `.claude/hooks/validate-discovery-artifact-gate.ps1` (verified by `diff`). No new PowerShell logic is introduced on this branch.
- The repo originals are exercised by an existing Pester suite (`tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1`).
- The bundle mirror's byte-identity to the tested originals is enforced by the now-passing pytest contract test `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- The bundle payload path (`extensions/drm-copilot/resources/claude-customizations/**`) is packaged mirror output and is outside the Python coverage `source` (`["src", "scripts/dev_tools"]`), so it is not measured by the Python artifact.

The residual risk is low, but the mandatory PowerShell coverage artifact is not present; the finding stands until the remediation in `remediation-inputs.2026-07-18T23-16.md` is satisfied.

### TypeScript, C# — N/A

Zero changed files on the branch. Coverage N/A.

## Evidence Location Compliance

- Branch diff scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: none found.
- All feature evidence is under the canonical `<FEATURE>/evidence/<kind>/` tree (`evidence/remediation-baseline/`, `evidence/qa-gates/`, `evidence/other/`).
- `python scripts/dev_tools/validate_evidence_locations.py --root .` executed: exit 0 (no violations).

Verdict: PASS.

## Modified-Workflow-Needs-Green-Run Rule

The branch diff modifies no path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. The rule does not fire.

Verdict: PASS (rule not triggered).

## Bundle Push-Down Integrity

- `enforce-discovery-artifact-gate.ps1`: bundle copy byte-identical to repo original. PASS.
- `validate-discovery-artifact-gate.ps1`: bundle copy byte-identical to repo original. PASS.
- `settings.json`: bundle registration adds both hooks (`PreToolUse`-side `enforce-discovery-artifact-gate.ps1` and `SubagentStop`-side `validate-discovery-artifact-gate.ps1`); the repo `.claude/settings.json` carries the same two registrations (grep count 2). Registration mirror is consistent. PASS.
- No merge conflict markers present in any tracked file (scanned `scripts/dev_tools/discovery/analyzer/**` and `pyproject.toml`). PASS.

## Merge-Conflict Resolution (pyproject.toml)

The `[tool.poetry.scripts]` block cleanly contains both new console scripts (`dev.discovery.dotnet`, `dev.discovery.vsto`) alongside the integration-branch entries; no duplicate keys and no conflict residue. PASS.

## File-Size Limit (<= 500 lines)

All new production and test files are within the limit (largest: `source_text.py` at 476 lines; `test_vsto_office.py` at 474; `dotnet_inventory.py` at 457; `vsto_office.py` at 451). Raw text fixtures are exempt. The two added `.ps1` files are 213 and 237 lines. Verdict: PASS.

## Dependency Policy

`pyproject.toml` adds only two `[tool.poetry.scripts]` console-entry lines. No new runtime or dev dependency was added; the implementation uses the Python standard library only. Verdict: PASS.

## Suppression Policy

No `# noqa` or `# type: ignore` suppressions appear in the five new production modules. Verdict: PASS.

## Coverage-Exclusion Policy

No coverage `exclude`/`omit` entry matching a `src/`-equivalent production path was added; the new `scripts/dev_tools/discovery/analyzer/` modules remain in the coverage denominator. Verdict: PASS.

## Consumer-Neutrality (feature-scoped)

Independent grep of the five new production modules for consumer identifiers (`taskmaster`, `tmw`, `outlook`) returned no matches. The feature-scoped contract test (`tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py`) bans consumer identifiers and per-Office-application hardcoding while permitting generic stack literals; the Office interop application name is captured as data into `metadata.interop_target` and never branched on. Verdict: PASS.

## Overall Verdict

PARTIAL / FAIL on one gate. All Python and structural gates PASS. One FAIL: the mandatory PowerShell coverage artifact (`artifacts/pester/powershell-coverage.xml`) is absent for the two bundle hook mirror files added on the branch. Remediation is required and is documented in `remediation-inputs.2026-07-18T23-16.md`.

## Appendix A — Findings

| ID | Severity | Area | Finding | Remediation |
|---|---|---|---|---|
| PA-1 | Blocking (coverage-mandatory rule) | PowerShell coverage | `artifacts/pester/powershell-coverage.xml` absent while the branch adds two `.ps1` files under the bundle payload | Produce the Pester coverage artifact for the discovery-artifact-gate hooks demonstrating line >= 85% / branch >= 75%, OR record an explicit policy classification treating the `extensions/**` bundle payload as excluded packaged/mirror output not subject to per-language coverage (mirroring the coverage-exclusion policy's treatment of build output). See remediation inputs. |

## Appendix B — Command Reference

```
git rev-parse HEAD
git merge-base HEAD origin/epic/legacy-discovery-and-parity-integration
git diff --stat 01fb34a8468090db01db471bb339a0dd6391a9d7..62662879766c9280015800634195a9582cb52041
git diff --name-status 01fb34a8468090db01db471bb339a0dd6391a9d7..62662879766c9280015800634195a9582cb52041
git log --oneline --merges 01fb34a8468090db01db471bb339a0dd6391a9d7..62662879766c9280015800634195a9582cb52041
diff <(git show HEAD:.claude/hooks/enforce-discovery-artifact-gate.ps1) <(git show HEAD:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1)
diff <(git show HEAD:.claude/hooks/validate-discovery-artifact-gate.ps1) <(git show HEAD:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1)
grep -rinE "taskmaster|tmw|outlook" scripts/dev_tools/discovery/analyzer/*.py
python scripts/dev_tools/validate_evidence_locations.py --root .
# coverage inspected, not regenerated:
#   artifacts/python/lcov.info                     (Python: present)
#   artifacts/pester/powershell-coverage.xml       (PowerShell: ABSENT -> FAIL)
```
