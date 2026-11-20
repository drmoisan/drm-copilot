# Reviewer Re-Verification - Issue 1019

Timestamp: 2026-11-06T18-47
Command: sh SCRATCH/issue-1019-review.sh (SCRATCH/issue-1019-ci-parse.ps1 over the downloaded `poshqc-test-results` artifact of CI run 42138261703; SCRATCH/issue-1019-review.ps1 -Root <worktree>: logical line counts through Get-Content, Invoke-Formatter comparison, Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1, per-file parse of artifacts/pester/powershell-coverage.xml, Pester 6 run of SUITE with coverage off, guard run on a scratch mutant); gh run download 42138261703 --name poshqc-test-results; poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT_CODE: 0
Output Summary: SUITE passed 56, failed 0, skipped 0, not run 0 in 32.54 s at head fe9a4023d. Formatter text equal and analyzer findings 0 for MODULE and SUITE. MODULE line coverage 151 of 151. Repo-wide line coverage is 95.19% in the merged CI artifact of the last merged head and derives to 95.20% on this branch. The structural guard passes on a mutant whose lexing window is unbounded, so it does not pin the window bound.

`SUITE`, `MODULE`, and `SCRATCH` carry the meanings stated in the plan in this folder.

## Logical Line Counts

| File | Logical lines |
| --- | --- |
| `.claude/lib/docs/DocsPythonTokens.psm1` | 265 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPythonTokens.psm1` | 265 |
| `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | 492 |

## PowerShell Coverage

| Scope | Source | Line covered | Line missed | Percent |
| --- | --- | --- | --- | --- |
| Repository, baseline | CI run 42138261703, merged shards, head of the branch merged at the merge base | 31773 | 1604 | 95.19 |
| `MODULE`, baseline with all tests | Same artifact | 128 | 0 | 100.00 |
| `MODULE`, post-change | `artifacts/pester/powershell-coverage.xml` | 151 | 0 | 100.00 |
| Repository, post-change | Derived: baseline plus the `MODULE` delta of 23 covered lines | 31796 | 1604 | 95.20 |

CI run 42138261703 concluded success with `poshqc / PowerShell QC` successful. Its head is an ancestor of the merge base, confirmed with `git merge-base --is-ancestor` (exit 0), and the merge-base commit is the merge of that head.

The derivation rests on `MODULE` being the only changed file in the coverage denominator: `config/poshqc-coverage.json` does not list `extensions/`, and zero measured packages in either report name `extensions`. As a cross-check, the local artifact's root counter totals 33400 lines (8982 covered, 24418 missed), which equals the derived post-change denominator of 33400. The local root percentage of 26.89% lines comes from one test folder and is not a repository-wide measure. Its 31.61% figure, printed by that run and quoted in `suite-duration-after`, is the instruction counter (17868 of 56521).

## Structural Guard on an Unbounded Window

A scratch copy of `.claude/lib` had both `$source` assignments in `Get-DocsPythonToken` replaced so that each window has no length bound: `$sourceText.Substring($windowStart)` and `$sourceText.Substring(0)`. The final `SUITE` was copied alongside it and only `Describe 'Get-DocsPythonToken structural scaling guard'` was run.

| Run | Passed | Failed | Not run (outside the filter) |
| --- | --- | --- | --- |
| Guard describe on the unbounded mutant | 2 | 0 | 54 |

Read from the code, the mutant passes the remaining source to `Regex.Match` after every string token, which is the call pattern the root-cause profile measured as quadratic on a string-heavy source. The mutant's run time was not measured. No production file was edited. The scratch copy was removed after the run.

## Evidence Locations

`validate_evidence_locations.py --root .` exited 0 with no output. `git diff --name-only MERGE_BASE...HEAD -- artifacts .github config scripts .claude/rules .github/instructions` returned no path.

## Route

Inside this agent-isolated worktree the runtime refused a plain `pwsh` command. The reviewer used the `sh` launcher stored under `SCRATCH` that the `execution-environment` skill names for this case. The scripts run no `git` command.
