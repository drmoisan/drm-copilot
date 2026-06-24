# Policy Compliance Audit — relocate-research-canonical-location (Issue #227)

- **Timestamp:** 2026-06-24T14-18
- **Feature folder:** docs/features/active/2026-06-24-relocate-research-canonical-location-227
- **Base branch (resolved):** origin/main @ ea94a068e0a071940858a0694c47e204244c09af
- **Head:** drm-copilot-wt-2026-06-24-13-02 @ eb85c8789cd99907cac8363a95c3c9043341d995
- **Merge base:** ea94a068e0a071940858a0694c47e204244c09af
- **Range:** ea94a068e0a071940858a0694c47e204244c09af..eb85c8789cd99907cac8363a95c3c9043341d995
- **Work mode:** full-feature (marker in issue.md: `- Work Mode: full-feature`)
- **Scope:** full branch diff vs merge-base (feature-vs-base). 66 changed files across two commits (`d200d89` relocation, `eb85c87` coverage remediation).
- **Review type:** Re-audit after remediation. Prior review (2026-06-24T13-55) recorded a single Blocking finding: `enforce-evidence-locations.ps1` line coverage below 85%.

## Policy Reading Order Applied

1. CLAUDE.md (standing instructions)
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. Language-specific rules in scope:
   - .claude/rules/powershell.md (PowerShell hooks and tests changed)
   - .claude/rules/python.md, .claude/rules/python-suppressions.md (Python validator and test changed)
   - .claude/rules/self-explanatory-code-commenting.md (Python docstring/comment policy)
   - .claude/rules/quality-tiers.md (coverage thresholds)
   - .claude/rules/tonality.md (instruction-surface prose changes)

## Rejected Scope Narrowing

No caller instruction attempted to narrow scope below the full feature-vs-base diff. The delegation prompt explicitly directed review of the complete branch diff across both commits and the full toolchain/coverage expectations for every language with changed files. The audit covered every language with changed files in the branch diff (PowerShell, Python, and Markdown/TOML documentation). No narrowing to reject.

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
| Format | Invoke-Formatter / PoshQC format (executor evidence: final-poshqc-format.2026-06-24T13-55.md, EXIT 0) | ok:true | PASS |
| Analyze | Invoke-ScriptAnalyzer over the six PowerShell files (reviewer re-run) | 0 findings on every file | PASS |
| Test | Invoke-Pester on validate-task-researcher-output.Tests.ps1 (22) + enforce-evidence-locations.Tests.ps1 (13) | Total=35, Passed=35, Failed=0 | PASS |

Note on format: a direct `Invoke-Formatter -ScriptDefinition` call against the raw text of `enforce-evidence-locations.ps1` reports "mixed line endings." The authoritative repo format gate (PoshQC MCP run in executor evidence final-poshqc-format.2026-06-24T13-55.md) reports EXIT 0. The mixed-line-ending condition is a known cosmetic artifact tolerated by the PoshQC formatter and recorded below as a non-blocking observation; PSScriptAnalyzer reports 0 findings.

## Coverage Verification

Reviewer inspected the existing coverage artifacts and independently re-ran the targeted Pester coverage and pytest coverage. Coverage thresholds are uniform per quality-tiers.md: line >= 85%, branch >= 75%, no regression on changed lines.

### Python — artifact: artifacts/python/lcov.info

| File | Type | Line cov | Branch cov | Verdict |
|---|---|---|---|---|
| scripts/dev_tools/validate_evidence_locations.py | modified | 100% (28/28) | 100% (12/12) | PASS |

Repo-wide per language (Python validator module under test): 100% line, 100% branch. PASS.

### PowerShell — targeted per-hook coverage (reviewer re-run; corroborates executor evidence)

| File | Type | Line / command cov | Threshold | Verdict |
|---|---|---|---|---|
| .claude/hooks/enforce-evidence-locations.ps1 | modified | 96.43% line (27/28, executor) / 94.29% command (33/35, reviewer) | >= 85% | PASS |
| .claude/hooks/validate-task-researcher-output.ps1 | modified | 91.84% command (90/98, reviewer) | >= 85% | PASS |

Reviewer Pester command (New-PesterConfiguration, CodeCoverage scoped to the named hook):
- enforce-evidence-locations.Tests.ps1: 13 tests, 13 passed, 0 failed. Command coverage 94.29%; the only uncovered statement is line 176 `exit (Invoke-EvidenceLocationEntryPoint)`, the thin process-exit wiring that is structurally unreachable when the script is dot-sourced by unit tests.
- validate-task-researcher-output.Tests.ps1: 22 tests, 22 passed, 0 failed. Command coverage 91.84%; uncovered statements are the entry-point dispatch block (lines 219-225) plus two minor branches.

Remediation confirmation: the prior Blocking finding (enforce-evidence-locations.ps1 at 81.5% line coverage) is RESOLVED. The remediation commit `eb85c87` extracted the dispatch logic into a testable `Invoke-EvidenceLocationEntryPoint` function and added three entry-point dispatch tests (allow-output, malformed-JSON error, block-output). Post-change line coverage 96.43% >= 85% with no coverage exclusion introduced (line 176 remains in the denominator) and no regression on the changed line (the `'artifacts/research/'` forbidden prefix in `Test-EvidenceLocationForbidden`, fully covered by two passing tests).

Branch coverage for PowerShell: Pester's PowerShell coverage engine emits line/command counters only; branch counters are not produced. This is a documented tooling limitation (coverage-threshold-verification.2026-06-24T13-55.md), not a regression. Line coverage is the applicable PowerShell metric and meets threshold.

### Markdown / TOML

No executable code; no coverage instrument applies. Not a language with executable changed lines for coverage purposes. Verdict: not applicable to coverage (zero executable changed lines).

## Evidence Location Compliance

Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — EXIT 0 (no violations).

Branch-diff scan for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`, or `artifacts/research/`: none found (`git diff --name-only <range> | grep -E '^artifacts/...'` returned no matches). All feature evidence is written to the canonical `<FEATURE>/evidence/<kind>/` path (baseline/, qa-gates/, other/). No evidence-location violations.

| Check | Result |
|---|---|
| Files under artifacts/baselines/ in diff | none — PASS |
| Files under artifacts/qa/ in diff | none — PASS |
| Files under artifacts/evidence/ in diff | none — PASS |
| Files under artifacts/coverage/ in diff | none — PASS |
| Files under artifacts/research/ in diff | none — PASS |
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
| enforce-evidence-locations.ps1 (root vs Codex bundled) | DIVERGENT — expected (Codex translation: `# Converted hook` header banner and `.agents/skills/` path in the block reason); the `artifacts/research/` forbidden prefix change is present — PASS for the relocation change |
| Codex task-researcher.toml / orchestrator.toml / three .agents/skills | equivalent relocation text present — PASS |

The remediation refactor (extracting `Invoke-EvidenceLocationEntryPoint`) was applied to both the root hook and the Claude bundled mirror, which remain byte-identical (verified by `diff`). The Codex bundled hook is a translation; the only diffs versus root are the converted-hook header and the skills-path reference, both pre-existing translation conventions consistent with the spec.

## Residual Reference Scan

Command: content search for `artifacts[/\\]research` across .claude, .github, scripts, extensions, tests (excluding docs/features historical records and this feature's own docs).

All remaining matches in operational/instruction files are intentional: forbidden-prefix list entries and docstrings in the three `enforce-evidence-locations.ps1` copies (the relocation's purpose), the forbidden-prefix entry in `validate_evidence_locations.py`, and test assertions that exercise rejection of the retired path. `.claude/agents/task-researcher.md` and the Codex `task-researcher.toml` contain no residual `artifacts/research` references (verified). No operational/instruction file still treats `artifacts/research/` as a canonical or permitted research target. PASS.

One match outside the in-scope inventory: `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md` references `artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md` as a specific historical input artifact the skill consumes, not as the canonical research-output path contract. This file is not in the spec's in-scope inventory and the reference is a historical input pointer, out of scope per spec Non-Goals. Recorded as a non-blocking observation.

## Verdict Summary

| Area | Verdict |
|---|---|
| Python toolchain | PASS |
| PowerShell toolchain | PASS |
| Python coverage | PASS |
| PowerShell coverage (validate-task-researcher-output.ps1) | PASS |
| PowerShell coverage (enforce-evidence-locations.ps1) | PASS (resolved; 96.43% line, was 81.5%) |
| Markdown/TOML coverage | N/A (zero executable changed lines) |
| Evidence-location compliance | PASS |
| modified-workflow-needs-green-run | PASS (does not fire) |
| Cross-ecosystem consistency | PASS |
| Residual reference scan | PASS |
| Tonality (instruction prose) | PASS |

**Overall policy verdict: PASS.** The single prior Blocking finding (enforce-evidence-locations.ps1 coverage) is resolved. No FAIL or PARTIAL results remain. No remediation triggered.

## Non-Blocking Observations

- Low: `coverage.xml` at repo root (a tracked, generated JaCoCo Pester report) was regenerated and committed in the branch diff (net -98 lines). Generated coverage output is out of scope per spec Non-Goals ("testResults.xml and similar generated outputs are not authored and are out of scope"). Committing regenerated generated output is incidental churn; not a path violation (root path, not under a forbidden prefix). Optional: avoid committing regenerated coverage.xml.
- Low: `enforce-evidence-locations.ps1` reports "mixed line endings" under a direct `Invoke-Formatter -ScriptDefinition` call, while the authoritative PoshQC format gate passes (EXIT 0). Cosmetic; carried over from the prior review. Optional cleanup on next edit.

## Appendix B — Command Reference

- `git diff --stat ea94a068e0a071940858a0694c47e204244c09af..eb85c8789cd99907cac8363a95c3c9043341d995`
- `git log --oneline ea94a068e0a071940858a0694c47e204244c09af..eb85c8789cd99907cac8363a95c3c9043341d995`
- `poetry run black --check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`
- `poetry run ruff check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`
- `poetry run pyright scripts/dev_tools/validate_evidence_locations.py`
- `poetry run pytest tests/scripts/dev_tools/test_validate_evidence_locations.py --cov=scripts.dev_tools.validate_evidence_locations --cov-branch --cov-report=term-missing`
- `Invoke-Pester -Configuration <cfg>` scoped to each hook test file with CodeCoverage on the corresponding hook
- `Invoke-ScriptAnalyzer -Path <file> -Severity Warning,Error` over the six PowerShell files
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
- `diff <root file> <bundled mirror>` for each cross-ecosystem pair
- content search for `artifacts[/\\]research` across operational directories
