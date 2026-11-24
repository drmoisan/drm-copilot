# Coverage Comparison and Limits (P4-T5)

Timestamp: 2026-11-23T12-13
Command: (1) sh SCRATCH/issue-1219-compare.sh (compares the Phase 0 baseline summary with the final-gate summary, both read from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml of the respective single gate runs); (2) @(Get-Content -LiteralPath <path>).Count per new or changed .psm1, .ps1 and .yml file (SCRATCH/issue-1219-linecount.sh); (3) git merge-base origin/main HEAD, then git diff <merge base> -- .claude/lib/docs/DocsCoverageReport.psm1 (working tree against the merge base)
EXIT_CODE: 0
Output Summary:
- Inputs: baseline evidence/baseline/pester-gate.2026-11-23T07-39.md; final evidence/qa-gates/pester-gate.2026-11-23T12-11.md.

| Check | Baseline | Final | Rule | Result |
|---|---|---|---|---|
| DocsPagePlaceholder.psm1 line coverage | N/A - no pre-change run (new file) | 100.00% (37/37) | at least 85% | PASS |
| DocsLedgerCommands.psm1 line coverage | 99.69% (325/326) | 99.70% (327/328) | no drop; at least 85% | PASS |
| DocsProfileCommands.psm1 line coverage | 97.75% (87/89) | 97.87% (92/94) | no drop; at least 85% | PASS |
| Repo-wide line coverage | 96.84% | 96.85% | no drop | PASS |
| Per-file coverage drops across all 482 baseline files | - | 0 drops | no per-file drop | PASS |
| Tests failing in final that passed in baseline | 29135 passed, 0 failed | 29193 passed, 0 failed | none | PASS (one baseline id, 'docs workflow template content.contains no linter step', is absent from the final run because P2-T2 replaced that test as the plan states; it is removed, not failing) |
| DocsLedgerCommands.psm1 logical lines | 758 | 760 | at most 762 | PASS |
| DocsPagePlaceholder.psm1 | new | 136 | at most 800 | PASS |
| DocsProfileCommands.psm1 | 270 | 276 | at most 800 | PASS |
| templates/_docs-quality.yml | - | 112 | at most 800 | PASS |
| DocsTonality Certainty/Exclamation/Filler/Hyperbole/Intensifiers.yml | new | 19/11/16/33/15 | at most 800 | PASS |
| DocsPagePlaceholder.Tests.ps1 | new | 231 | at most 800 | PASS |
| DocsInitTemplate.DocsWorkflow.Tests.ps1 | 216 | 438 | at most 800 | PASS |
| DocsLedgerCommands.Tests.ps1 | 553 | 600 | at most 800 | PASS |
| DocsPageTemplates.Tests.ps1 | 181 | 256 | at most 800 | PASS |
| DocsProfileCommands.Tests.ps1 | 351 | 375 | at most 800 | PASS |
| DocumentationEstateOnboarding.Tests.ps1 | 305 | 321 | at most 800 | PASS |
| docs-authoring-roles.Skills.Tests.ps1 | 116 | 117 | at most 800 | PASS |
| git diff <merge base of origin/main and HEAD> -- .claude/lib/docs/DocsCoverageReport.psm1 | - | 0 lines (empty) | empty | PASS |

- No FAIL row; P4-T4 needs no re-run.
