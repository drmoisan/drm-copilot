# AC3 — Measurement Obligation Intact (Issue #476)

Timestamp: 2026-08-16T17-29

Command: read-through of every added line in `git diff -- .claude/ .agents/ README.md extensions/`, evaluated against the question "does this passage state or imply that PowerShell files are excluded from coverage *measurement*?"

EXIT_CODE: 0

## Per-Passage Read-Through

Nine distinct amended passages exist (each appears twice where a bundle mirror exists; the mirror text is byte-identical and is not re-evaluated separately).

| # | File (root) | Amended passage, abbreviated | Excludes from measurement? | Basis |
| --- | --- | --- | --- | --- |
| 1 | `.claude/rules/powershell.md:64` | "Pester reports command (instruction) coverage and line coverage only... Branch coverage is not measurable by Pester for PowerShell; there is no PowerShell branch-coverage gate. This removes an unevaluable threshold, not a measurement obligation: PowerShell production files remain in the coverage denominator..." | NO | States the opposite explicitly. The subject removed is a *threshold* and a *gate*; the passage affirms denominator membership |
| 2 | `.claude/rules/general-unit-test.md:24` | "...PowerShell (Pester) and bash (kcov) are the exceptions... only the line threshold applies to them and there is no branch-coverage gate. This is a threshold exemption only; PowerShell and bash production files remain in the coverage denominator under the Coverage Exclusion Policy below." | NO | Names the exemption as a *threshold* exemption and re-asserts denominator membership |
| 3 | `.claude/rules/quality-tiers.md:25` | "The line threshold applies to every coverage language; the branch threshold applies to languages whose coverage tooling measures branch coverage." | NO | Scopes thresholds only; makes no statement about which files are measured |
| 4 | `.claude/rules/quality-tiers.md:34` | "Branch coverage: >= 75% for languages whose coverage tooling measures branch coverage. PowerShell (Pester) and bash (kcov) are exempt from this threshold... no branch-coverage gate applies to them." | NO | The word "exempt" is bound to "this threshold", not to measurement |
| 5 | `.claude/rules/quality-tiers.md:51` | "...That exemption is a capability limit on an unevaluable threshold, not a licence to exclude files from measurement: PowerShell and bash production files remain in the coverage denominator under the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`." | NO | Pre-empts the misreading in terms |
| 6 | `.claude/skills/feature-review-workflow/SKILL.md:111-114` | "...PowerShell is a coverage language and is fully subject to the line threshold and the no-regression requirement, but Pester measures command (instruction) coverage and line coverage only, so no branch percentage exists to evaluate and no branch threshold applies to it... Do not flag a missing PowerShell branch figure as FAIL" | NO | Affirms PowerShell's status as a coverage language and its line/no-regression obligations; the PowerShell coverage-artifact path at line 109 is unchanged, so the artifact is still required |
| 7 | `.claude/agents/feature-review.md:112-116` | Same qualification plus "Do not record FAIL for an absent PowerShell branch figure." | NO | Same; the PowerShell row of the Coverage Artifact Paths table is unchanged, so the artifact remains mandatory |
| 8 | `.claude/skills/powershell-qa-gate/SKILL.md:45` | "line coverage >= 85% per the uniform tier rule... No regression on changed lines. Pester measures command (instruction) coverage and line coverage only; branch coverage is not measurable for PowerShell, so no branch-coverage gate applies here." | NO | The per-file and overall coverage-delta bullets at lines 43-44 are unchanged, so per-file measurement remains required |
| 9 | `README.md:298` | "...PowerShell (Pester) and bash (kcov) are exempt from the branch threshold because neither tool measures branch coverage, and they remain fully subject to the line threshold and the no-regression requirement." | NO | "exempt from the branch threshold" is explicitly bounded; the sentence closes by re-asserting the remaining obligations |

Codex-surface passages `.agents/skills/general-unit-test/SKILL.md:29` and `.agents/skills/quality-tiers/SKILL.md:30,39,56` carry the same text as rows 2-5 with Codex-relative cross-references and were read with the same result: NO.

**Count of passages that state or imply exclusion from measurement: 0 of 9 (0 of 17 files).**

## Corroborating Structural Facts

- No `exclude` entry, coverage-configuration key, or file-path glob was added or modified anywhere in this change. The change set is prose only.
- `pester.runsettings.psd1` is not modified (spec non-goal), so the set of files Pester measures is unaltered by this change.
- The Coverage Exclusion Policy section of `.claude/rules/general-unit-test.md` (and its Codex counterpart) is byte-unchanged; this change adds a cross-reference *to* it, never an exception *from* it.

## Explicit Threshold-Versus-Measurement Distinction (required by AC3)

Located in `.claude/rules/powershell.md`, line 64, final sentence:

> This removes an unevaluable threshold, not a measurement obligation: PowerShell production files remain in the coverage denominator per the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`, and command coverage is reported for information only, with no threshold attached.

A second, independent statement of the same distinction is located in `.claude/rules/general-unit-test.md`, line 24, final sentence:

> This is a threshold exemption only; PowerShell and bash production files remain in the coverage denominator under the Coverage Exclusion Policy below.

A third is located in `.claude/rules/quality-tiers.md`, line 51:

> That exemption is a capability limit on an unevaluable threshold, not a licence to exclude files from measurement: PowerShell and bash production files remain in the coverage denominator under the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`.

AC3 requires at least one such statement in `.claude/rules/powershell.md` or `.claude/rules/general-unit-test.md`; both carry one, and `quality-tiers.md` carries a third. Each has a byte-identical bundle mirror.

Output Summary: PASS. Zero of the nine amended passages (across all 17 files) state or imply that PowerShell files are excluded from coverage measurement. The explicit threshold-versus-measurement distinction is present in three places, including the AC3-required location `.claude/rules/powershell.md:64`. The Coverage Exclusion Policy text itself is unmodified and is cross-referenced, not excepted.
