# Execution Decisions, Continued (autonomous mode)

Timestamp: 2026-11-23T12-16
Command: none (decision record; follows decisions.2026-11-23T08-18.md, which is unchanged)
EXIT_CODE: 0
Output Summary: further decisions taken during execution, each with the recommended option.

- D-E5 (P1-T3 to P3-T2): because the machine test-suite lock was held by sibling worktrees for long periods, the edits of the next task were authored while the previous task's check was queued, only where the queued selection did not load the edited files; each task was checked off only after its own check passed, in plan order.
- D-E6 (P1-T2, phase gate P1): the repository test-name uniqueness guard folds case, so the two casing cases were labelled 'sme input required (lowercase)' and 'SME Input Required (title case)'; the inputs and the It name template are as the plan states.
- D-E7 (P1-T3): integration-lane files (DocsCompleteIntegration.Tests.ps1, DocsReferenceIntegration.Tests.ps1) are excluded from local task-check selections because the launcher refuses them locally (CI-only lane).
- D-E8 (P4-T2): the mismatch proof runs the extracted step body inside the GitHub pwsh wrapper shape ($ErrorActionPreference = 'stop' before, LASTEXITCODE exit after) so the recorded exit code matches the runner behavior; ANSI codes and host paths are removed from the recorded output (token SCRATCH).
- D-E9 (P4-T3): Vale's line output does not print the alert level, so the proof also runs Vale with --output JSON on the same page to record severity=error for DocsTonality.Hyperbole.
