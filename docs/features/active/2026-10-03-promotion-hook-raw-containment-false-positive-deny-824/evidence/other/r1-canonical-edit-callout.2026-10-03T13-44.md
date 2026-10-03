# r1 P9-T15 — canonical and rule-file edit callout (for the PR body)

Timestamp: 2026-10-03T13-44
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p9-t15.ps1 -Worktree WORKTREE (A0; `$numstat = @(git diff --numstat 079ebb9fad8fab1ee24e137e5bc605fc1df1948a -- .github/instructions/csharp-code-change.instructions.md .github/instructions/csharp-unit-test.instructions.md .claude/rules/architecture-boundaries.md .claude/rules/quality-tiers.md .claude/rules/general-unit-test.md); $numstat; "NUMSTAT-FILES=$($numstat.Count)"`; VERDICT), then pwsh -NoProfile -File SCRATCH/steps/r1-p9-t15-check.ps1 -Worktree WORKTREE (the URL and callout checks)
EXIT_CODE: 0
Output Summary: NUMSTAT-FILES=5; the check script result is recorded at the end of this file. This cycle edits policy text that is normally read-only; each edit is limited to the named lines.

CALLOUT: .github/instructions/csharp-code-change.instructions.md | AUTHORITY: FU-823-3, canonical edit authorized by the repository owner in https://github.com/drmoisan/drm-copilot/issues/824#issuecomment-5970141337 (spec.md Scope Extension, "Canonical policy edit authorization"); every `msbuild TaskMaster.sln` became `msbuild <solution>.sln`; numstat 4 4
CALLOUT: .github/instructions/csharp-unit-test.instructions.md | AUTHORITY: FU-823-3, canonical edit authorized by the repository owner in https://github.com/drmoisan/drm-copilot/issues/824#issuecomment-5970141337 (spec.md Scope Extension, "Canonical policy edit authorization"); every `msbuild TaskMaster.sln` became `msbuild <solution>.sln`; numstat 2 2
CALLOUT: .claude/rules/architecture-boundaries.md | AUTHORITY: FU-823-2 lists this file (AC-35); names only: the No-COM description and heading and the TaskMaster.Domain / TaskMaster.Application names became host-neutral wording and `<Product>`; numstat 5 5
CALLOUT: .claude/rules/quality-tiers.md | AUTHORITY: review note A, AC-38 ("the per-metric fallback is stated wherever the precedence wording appears"); one per-metric fallback sentence at each of the two existing threshold-precedence statements (lines 31 and 55), nothing else; numstat 2 2
CALLOUT: .claude/rules/general-unit-test.md | AUTHORITY: review note A, AC-38; one per-metric fallback sentence appended to the existing threshold-precedence statement (line 23), nothing else; numstat 1 1

No other `.github/instructions/` or `.claude/rules/` file is edited. The bundle mirrors of these files were refreshed by byte copy (P6-T1).

Step script 1 output (TS=2026-10-03T13-44, exit 0):

- 5 5 .claude/rules/architecture-boundaries.md
- 1 1 .claude/rules/general-unit-test.md
- 2 2 .claude/rules/quality-tiers.md
- 4 4 .github/instructions/csharp-code-change.instructions.md
- 2 2 .github/instructions/csharp-unit-test.instructions.md
- NUMSTAT-FILES=5

Step script 2 output (SCRATCH/steps/r1-p9-t15-check.ps1, TS=2026-10-03T13-44, exit 0):

- URL-COUNT=2 CALLOUT-LINES=5 CALLOUT-DIFFERENCES=0
- Top-level EXIT_CODE is the larger of the two process exit codes: 0.
