# AC13 — No Command-Coverage Gate Introduced (Issue #476)

Timestamp: 2026-08-16T17-31

Command:
1. `git diff -U0 -- .claude/ .agents/ README.md extensions/ | grep -E "^\+" | grep -iE "command|instruction"` — every added line that mentions command or instruction coverage
2. `rg -i --hidden -n "(command|instruction)[ -]coverage[^.]{0,80}[0-9]+%" .claude/ .agents/ README.md extensions/drm-copilot/resources/` — repository-wide search for any percentage figure occurring within the same sentence as a command- or instruction-coverage mention

EXIT_CODE: 0 (check 1); 1 (check 2, ripgrep's no-match exit — the required outcome)

## Check 1 — Per-Passage Review of Every Added Mention

Command or instruction coverage is mentioned in four distinct amended passages (each duplicated in its bundle mirror, byte-identical).

| # | File (root) | Mention, verbatim | Grammatical role | Threshold attached? |
| --- | --- | --- | --- | --- |
| 1 | `.claude/rules/powershell.md:64` | "Pester reports **command (instruction) coverage and line coverage only**." | Descriptive: object of "reports", stating what the tool measures | NO |
| 1b | `.claude/rules/powershell.md:64` | "...and command coverage is reported for information only, with no threshold attached." | Explicit negative disclaimer | NO — states the absence in terms |
| 2 | `.claude/skills/feature-review-workflow/SKILL.md:111` | "...but Pester measures command (instruction) coverage and line coverage only, so no branch percentage exists to evaluate..." | Descriptive premise supporting the branch conclusion | NO |
| 3 | `.claude/agents/feature-review.md:116` | "...but Pester measures command (instruction) coverage and line coverage only, so no branch percentage exists to evaluate..." | Same | NO |
| 4 | `.claude/skills/powershell-qa-gate/SKILL.md:45` | "Pester measures command (instruction) coverage and line coverage only... Command coverage is informational and carries no threshold." | Descriptive plus explicit negative disclaimer | NO — states the absence in terms |

In every case the phrase appears as the object of a reporting or measuring verb describing tool capability. In no case does it appear as the subject of a requirement verb ("must remain", "must be", "applies"), and in no case is a numeral, percentage, comparison operator, or the word "threshold" (other than to deny one) attached to it.

Two of the four passages carry an explicit negative disclaimer ("with no threshold attached"; "carries no threshold"), which forecloses a later reader adopting command coverage as a substitute gated metric.

**Count of amended passages attaching a numeric threshold to command or instruction coverage: 0 of 4.**

## Check 2 — Repository-Wide Negative Search

The regular expression `(command|instruction)[ -]coverage[^.]{0,80}[0-9]+%` searches for any digit-plus-percent token appearing within 80 non-sentence-terminating characters after a command- or instruction-coverage mention, across `.claude/`, `.agents/`, `README.md`, and both bundle payload roots, hidden directories included.

Result: no matches (ripgrep exit code 1). No command-coverage or instruction-coverage percentage exists anywhere on the amended surfaces.

## Corroborating Facts

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is not modified; its `CoveragePercentTarget` remains at its pre-change value, so no mechanical command-coverage floor was introduced either.
- `.claude/hooks/validate-feature-review-coverage.ps1` is not modified (AC10), so no gate logic reads or thresholds an `INSTRUCTION` counter as a result of this change.

Output Summary: PASS. Zero command-coverage or instruction-coverage thresholds were introduced. Command (instruction) coverage appears in exactly four amended passages, in every instance descriptively as what Pester measures, and two of those passages additionally disclaim any threshold in explicit terms. The repository-wide negative search for a percentage figure adjacent to a command- or instruction-coverage mention returns no matches.
