# Code Review — relocate-research-canonical-location (Issue #227)

- **Timestamp:** 2026-06-24T14-18
- **Base branch (resolved):** origin/main @ ea94a068e0a071940858a0694c47e204244c09af
- **Head:** drm-copilot-wt-2026-06-24-13-02 @ eb85c8789cd99907cac8363a95c3c9043341d995
- **Scope:** full branch diff vs merge-base (two commits: relocation + coverage remediation)
- **Review type:** Re-audit after remediation

## Executive Summary

The change relocates the canonical research-output path from the git-ignored `artifacts/research/` to two tracked roots (`docs/features/<feature>/research/` and `docs/research/`) across the Claude, Codex, and GitHub Copilot ecosystems and their bundled copies. The remediation commit (`eb85c87`) extracted the `enforce-evidence-locations.ps1` entry-point dispatch into a testable `Invoke-EvidenceLocationEntryPoint` function and added three dispatch tests, raising that hook's line coverage from 81.5% to 96.43%.

Code quality is consistent with repository policy. PowerShell functions use `CmdletBinding()`, named/validated parameters, and `[OutputType]`; the dot-source guard preserves the exclusion-only model and the testable-wiring seam. The Python validator is fully type-annotated, Pyright-clean, and 100% covered. Tests follow Arrange-Act-Assert with descriptive names and no temporary-file usage or external dependencies. Cross-ecosystem mirrors are byte-identical where required. No blocking code-quality findings.

The remediation introduced a clean design seam: the dispatch logic now returns an exit code from a unit-testable function, and only a single thin `exit (...)` statement remains in the host-bound entry point. This is the refactor approach the general-unit-test coverage-exclusion policy prescribes (push logic into testable host-neutral code; keep the host-bound wiring minimal and visible in the denominator). No coverage exclusion was added.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | .claude/hooks/enforce-evidence-locations.ps1 | L140-169, L176 | Dispatch logic extracted into `Invoke-EvidenceLocationEntryPoint` (returns int exit code); a single thin `exit (Invoke-EvidenceLocationEntryPoint)` wiring statement remains in the host-bound entry point. Clean seam; function is fully exercised by three new tests. | None. Consistent with the coverage-exclusion refactor policy. | The only uncovered line (176) is the structurally unreachable `exit` wiring; no exclusion was introduced, keeping the line in the denominator (96.43% line coverage). | Reviewer Pester re-run (13 tests, 94.29% command cov, only L176 missed); coverage-threshold-verification.2026-06-24T13-55.md |
| Info | tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | L126-170 | New `entry-point dispatch` context adds three tests covering allow-output, malformed-JSON error (asserts exit 1 and error record), and block-output paths. AAA structure, deterministic, no temp files. | None. | Directly closes the prior coverage gap with behavioral assertions on the decision-to-output mapping. | Reviewer Pester run; final-pester-coverage.2026-06-24T13-55.md |
| Info | scripts/dev_tools/validate_evidence_locations.py | L38 | Added `artifacts/research/` to `_FORBIDDEN_PREFIX_TO_CANONICAL` with a canonical suggestion naming both new roots. Single-line additive change; module remains 100% line/branch covered. | None. | Fully type-annotated, Pyright-clean; matched by the new `test_artifacts_research_is_forbidden` test asserting both new roots in the suggestion. | pytest 7 passed, 100%/100% coverage; ruff/pyright clean |
| Info | .claude/hooks/validate-task-researcher-output.ps1 | L60-83, L190-200 | `Test-IsUnderResearchRoot` rewritten for dual-root acceptance (feature path with `/research/` segment, or `docs/research/`); three error messages updated to cite both new roots. | None. | Logic is explicit and case-insensitive; negative paths (no `/research/` segment, retired path) covered by tests. | Reviewer Pester run (22 tests, 91.84% command cov) |
| Low | coverage.xml | repo root | Regenerated generated JaCoCo coverage report committed in the diff (net -98 lines). | Optional: exclude regenerated coverage.xml from feature commits. | Generated output is out of scope per spec Non-Goals; incidental churn, not a path violation. | git diff --stat; spec.md Non-Goals |
| Low | extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md | L24, L175 | References `artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md` as a historical input artifact the skill consumes. | None required; optional accuracy update on next touch of this skill. | This is a pointer to a specific historical research input, not the research-output-path contract; file is outside the spec's in-scope inventory and out of scope per Non-Goals. | Grep; spec.md In-Scope File Inventory |
| Low | .claude/hooks/enforce-evidence-locations.ps1 | EOF | Mixed line endings reported by a direct `Invoke-Formatter -ScriptDefinition` call; authoritative PoshQC format gate passes (EXIT 0). | Optional cleanup on next edit. | Cosmetic; PSScriptAnalyzer reports 0 findings. Carried over from prior review. | Reviewer Invoke-Formatter probe; final-poshqc-format.2026-06-24T13-55.md |

## Design and Standards Assessment

- **Simplicity / separation of concerns:** The relocation is a path-contract change with no behavioral re-architecture, matching the spec's stated intent. The remediation seam adds one small function plus thin wiring — the minimal change that makes the dispatch path testable.
- **Error handling:** Both hooks fail fast (malformed JSON throws / returns exit 1 with `Write-Error`); the Python validator exits 1 on violations and 0 when clean. No broad catch-all handlers.
- **Documentation:** Python functions and the PowerShell functions carry contract-oriented docstrings; the new `Invoke-EvidenceLocationEntryPoint` docstring explains why the wrapper exists (testability) and that it does not call `exit`. Consistent with self-explanatory-code-commenting policy.
- **Testing standards:** Tests are independent, isolated, deterministic, and free of temporary files and external dependencies. Mocking in the Python tests patches `rglob`/`find_forbidden_paths` at the import location used by the unit under test, per python.md.
- **File-size limit:** All changed source and test files are well under 500 lines.

## Conclusion

No blocking or actionable code-quality findings. The remediation is correct, minimal, and consistent with repository policy. Three Low/Info observations are non-gating.
