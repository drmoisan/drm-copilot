# Policy Compliance Audit — relocate-research-canonical-location (Issue #227)

- **Timestamp:** 2026-06-24T13-55
- **Feature folder:** docs/features/active/2026-06-24-relocate-research-canonical-location-227
- **Base branch (resolved):** origin/main @ ea94a068e0a071940858a0694c47e204244c09af
- **Head:** drm-copilot-wt-2026-06-24-13-02 @ d200d8961843f8b9d040f6c847b8ae186035dc90
- **Merge base:** ea94a068e0a071940858a0694c47e204244c09af
- **Range:** ea94a068e0a071940858a0694c47e204244c09af..d200d8961843f8b9d040f6c847b8ae186035dc90
- **Work mode:** full-feature (marker in issue.md: `- Work Mode: full-feature`)
- **Scope:** full branch diff vs merge-base (feature-vs-base). 51 changed files.

## Policy Reading Order Applied

1. CLAUDE.md (standing instructions)
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. Language-specific rules in scope:
   - .claude/rules/powershell.md (PowerShell hooks and tests changed)
   - .claude/rules/python.md, .claude/rules/python-suppressions.md (Python validator and test changed)
   - .claude/rules/quality-tiers.md (coverage thresholds)
   - .claude/rules/tonality.md (instruction-surface prose changes)

## Rejected Scope Narrowing

No caller instruction attempted to narrow scope below the full feature-vs-base diff. The audit covered every language with changed files in the branch diff (PowerShell, Python, and Markdown/TOML documentation). No narrowing to reject.

## Languages With Changed Files (scope determination)

| Language | Changed files (representative) | In coverage scope |
|---|---|---|
| PowerShell | .claude/hooks/validate-task-researcher-output.ps1, .claude/hooks/enforce-evidence-locations.ps1, two Claude bundled mirrors, Codex enforce-evidence-locations.ps1, two hook test files | Yes |
| Python | scripts/dev_tools/validate_evidence_locations.py, tests/scripts/dev_tools/test_validate_evidence_locations.py | Yes |
| Markdown / TOML (docs, prompts, agents, skills) | task-researcher.md/.agent.md/.toml, orchestrator.md/.toml, research-issue/orchestrate/evidence-and-timestamp-conventions SKILL.md, prompts | No executable code; no coverage instrument applies |

## Toolchain Results

### Python (independently re-run by reviewer)

| Stage | Command | Exit | Verdict |
|---|---|---|---|
| Format | `poetry run black --check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py` | 0 | PASS (2 files unchanged) |
| Lint | `poetry run ruff check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py` | 0 | PASS (All checks passed) |
| Type | `poetry run pyright scripts/dev_tools/validate_evidence_locations.py` | 0 | PASS (0 errors/warnings) |
| Test+coverage | `poetry run pytest tests/scripts/dev_tools/test_validate_evidence_locations.py --cov=scripts.dev_tools.validate_evidence_locations --cov-branch --cov-report=term-missing` | 0 | PASS (7 passed) |

### PowerShell (independently re-run by reviewer)

| Stage | Command | Result | Verdict |
|---|---|---|---|
| Format | mcp__drm-copilot__run_poshqc_format (executor evidence: final-poshqc.2026-06-24T13-09.md) | ok:true | PASS |
| Analyze | mcp__drm-copilot__run_poshqc_analyze (executor evidence) | ok:true, 0 findings | PASS |
| Test | Invoke-Pester on validate-task-researcher-output.Tests.ps1 + enforce-evidence-locations.Tests.ps1 | Total=32, Passed=32, Failed=0 | PASS |

## Coverage Verification

Reviewer inspected the existing coverage artifacts and independently re-ran the targeted Pester coverage and pytest coverage. Coverage thresholds are uniform per quality-tiers.md: line >= 85%, branch >= 75%, no regression on changed lines.

### Python — artifact: artifacts/python/lcov.info

| File | Type | Line cov | Branch cov | Verdict |
|---|---|---|---|---|
| scripts/dev_tools/validate_evidence_locations.py | modified | 100% (28/28) | 100% (12/12) | PASS |

Repo-wide per language (Python validator module under test): 100% line, 100% branch. PASS.

### PowerShell — artifact: artifacts/pester/powershell-coverage.xml (repo-wide JaCoCo) plus targeted per-hook coverage

Note: The repo-wide artifact at artifacts/pester/powershell-coverage.xml was produced over the `.claude/hooks`, `scripts/dev-tools`, and `scripts/powershell` packages and reports 46.8% repo-wide line coverage (LINE missed=313 covered=275). It does not contain the two changed hooks as named source files. The reviewer therefore re-ran targeted Pester coverage scoped to the two changed hooks; the per-file values below are from that re-run and corroborate the executor's coverage-delta.2026-06-24T13-09.md evidence.

| File | Type | Line cov | Threshold | Verdict |
|---|---|---|---|---|
| .claude/hooks/validate-task-researcher-output.ps1 | modified | 88.5% (54/61, executor) / 91.8% command-cov (reviewer) | >= 85% | PASS |
| .claude/hooks/enforce-evidence-locations.ps1 | modified | 81.5% (22/27, executor) / 78.8% command-cov (reviewer) | >= 85% | **FAIL** |

Branch coverage for PowerShell: Pester's PowerShell coverage engine emits line/command coverage only; branch counters are not produced. This is a tooling limitation, not a regression. Documented in coverage-delta.2026-06-24T13-09.md.

Repo-wide PowerShell coverage from the existing repo-wide artifact (46.8% line) is below the 85% repo-wide threshold. This artifact aggregates many unchanged files unrelated to this feature and predates a clean repo-wide PowerShell coverage run; it is recorded here as observed. The feature-scoped determination is the per-file modified-file result above. The blocking finding is the per-file enforce-evidence-locations.ps1 result.

**Coverage FAIL summary:** `.claude/hooks/enforce-evidence-locations.ps1` (modified file) is at 81.5% line coverage, below the uniform 85% line threshold. The uncovered lines (146, 148, 149, 152, 154) are the script entry-point execution block, unreachable when the script is dot-sourced by unit tests. The feature's changed line (added `artifacts/research/` forbidden prefix) is inside the fully covered `Test-EvidenceLocationForbidden` function, and there is no regression on changed lines. The threshold is nonetheless not met, which is a FAIL per the SKILL coverage contract and routes to remediation.

### Markdown / TOML

No executable code; no coverage instrument applies. Not a language with executable changed files for coverage purposes. Verdict: not applicable to coverage (zero executable changed lines).

## Evidence Location Compliance

Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — EXIT 0 (no violations).

Branch-diff scan for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: none found. All feature evidence is written to the canonical `<FEATURE>/evidence/<kind>/` path (baseline/, qa-gates/, other/). No evidence-location violations.

| Check | Result |
|---|---|
| Files under artifacts/baselines/ | none — PASS |
| Files under artifacts/qa/ | none — PASS |
| Files under artifacts/evidence/ | none — PASS |
| Files under artifacts/coverage/ | none — PASS |
| validate_evidence_locations.py --root . | exit 0 — PASS |

## modified-workflow-needs-green-run

Branch diff scanned for paths matching `.github/workflows/**`, `scripts/benchmarks/**`, `.github/actions/**`. No matching paths changed. Rule does not fire. PASS.

## Cross-Ecosystem Consistency (root vs bundled mirror)

| File pair | Result |
|---|---|
| validate-task-researcher-output.ps1 (root vs Claude bundled) | IDENTICAL — PASS |
| enforce-evidence-locations.ps1 (root vs Claude bundled) | IDENTICAL — PASS |
| task-researcher.md (root vs Claude bundled) | IDENTICAL — PASS |
| orchestrator.md (root vs Claude bundled) | IDENTICAL — PASS |
| research-issue/SKILL.md (root vs Claude bundled) | IDENTICAL — PASS |
| orchestrate/SKILL.md (root vs Claude bundled) | IDENTICAL — PASS |
| evidence-and-timestamp-conventions/SKILL.md (root vs Claude bundled) | IDENTICAL — PASS |
| task-researcher.agent.md (root vs Copilot bundled) | IDENTICAL — PASS |
| research-issue.prompt.md (root vs Copilot bundled) | IDENTICAL — PASS |
| fillout-prd-feature.prompt.md (root vs Copilot bundled) | IDENTICAL — PASS |
| enforce-evidence-locations.ps1 (root vs Codex bundled) | DIVERGENT — expected (Codex translation: converted-hook header and `.agents/skills/` path); the `artifacts/research/` forbidden prefix change is present at lines 23 and 71 — PASS for the relocation change |
| Codex task-researcher.toml / orchestrator.toml / three .agents/skills | equivalent relocation text present — PASS |

The Codex `.agents/skills/` files carry substantial pre-existing translation differences (AGENTS.md vs CLAUDE.md, `.agents/skills/` paths, differing orchestration content). These predate this feature. The spec requires only the equivalent research-relocation text changes in the Codex translations; those are present and verified.

## Residual Reference Scan

Command: content search for `artifacts[/\\]research` across .claude, .github, scripts, extensions, tests (excluding docs/features historical records).

All remaining matches are intentional: forbidden-prefix list entries in the three `enforce-evidence-locations.ps1` copies (the relocation's purpose) and test assertions that exercise rejection of the retired path. No operational/instruction file still treats `artifacts/research/` as a canonical or permitted research target. PASS.

## Verdict Summary

| Area | Verdict |
|---|---|
| Python toolchain | PASS |
| PowerShell toolchain | PASS |
| Python coverage | PASS |
| PowerShell coverage (validate-task-researcher-output.ps1) | PASS |
| PowerShell coverage (enforce-evidence-locations.ps1) | **FAIL** (81.5% < 85% line) |
| Markdown/TOML coverage | N/A (zero executable changed lines) |
| Evidence-location compliance | PASS |
| modified-workflow-needs-green-run | PASS (does not fire) |
| Cross-ecosystem consistency | PASS |
| Residual reference scan | PASS |
| Tonality (instruction prose) | PASS |

**Overall policy verdict: PARTIAL.** One coverage threshold FAIL (enforce-evidence-locations.ps1) triggers remediation. All other policy areas PASS.

## Appendix B — Command Reference

- `git diff --stat ea94a068e0a071940858a0694c47e204244c09af..d200d8961843f8b9d040f6c847b8ae186035dc90`
- `poetry run black --check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`
- `poetry run ruff check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`
- `poetry run pyright scripts/dev_tools/validate_evidence_locations.py`
- `poetry run pytest tests/scripts/dev_tools/test_validate_evidence_locations.py --cov=scripts.dev_tools.validate_evidence_locations --cov-branch --cov-report=term-missing`
- `Invoke-Pester -Configuration <cfg>` scoped to the two hook test files with CodeCoverage on the two hooks
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
- `diff <root file> <bundled mirror>` for each cross-ecosystem pair
- content search for `artifacts[/\\]research` across operational directories
