# Code Review: Progress Report Orchestration Step Model (Issue #1118)

**Review Date:** 2026-11-08
**Branch:** `feature/progress-orchestration-step-model` @ `d5f4ff971160186c29d794422098f6314e7b8268`
**Diff:** merge base `12825cb00` (with `origin/main`) to head; 92 files. Cycle-2 delta `b82381ed2..d5f4ff971`, 37 files.
**Review type:** Re-audit after remediation cycle 2 (NB1, NB3, NB4 of `remediation-inputs.2026-11-08T00-16.md`).
**Companion artifacts:** `policy-audit.2026-11-08T01-07.md`, `feature-audit.2026-11-08T01-07.md`.

## Executive Summary

The cycle-2 changes are small, sit where the remediation plan placed them, and are described in each function's help text. The entry script (495 lines) is unchanged. NB1, NB3, and NB4 are resolved, each with a test that fails when the fix is reverted. The full-branch review found no new blocking defect.

**NB1, Now line without a recorded start: resolved.** `Get-EpicProgressTypeEstimate` (`Metrics.ps1`) adds `StartRecorded = ($null -ne $entry.StartedUnixSeconds)` to each InProgress row. `Get-EpicProgressTldrLine` (`Render.ps1`) prints `#<i> <type> (start not recorded; median <m>)` when the property is `$false`, and otherwise keeps the elapsed form with its `, over median` suffix. Only an explicit `$false` selects the new text, so a row without the property keeps the old form. Real output at this head:

```text
-EpicFolder documentation-estate-tooling -Mode TLDR (main checkout)
**Now:** #1019 integration-pr (start not recorded; median 0 h 45 min). 10 of 11 types use defaults.
-Issue 1118 -Mode TLDR
**Now:** #1118 review (start not recorded; median 0 h 09 min). 3 of 9 types use defaults.
```

Both outputs stay at four TL;DR lines. Steps with a start keep the elapsed form. This is pinned by the unchanged goldens 'prints the Now line with elapsed against median for review, ci and main-sync' and the ItemMode Now-line cases, which all pass. The optional part of the prior recommendation (starting a cycle's re-audit at the cycle plan's last tick) was not adopted. The estimate therefore still does not fall during a re-audit inside a remediation cycle. The Now line no longer presents that state as a measured figure. This follows Decision D2 and is noted as Info.

**NB3, `S2_feature_documents`: resolved.** The alias table maps `s2_feature_documents` to `spec`. The reviewer parsed the real `policy-consistency` worktree checkpoint with the shipped `ConvertFrom-EpicProgressStageTiming` and `Get-EpicProgressStageSample`. The parse gave `S2_feature_documents -> spec` and a 180-second spec sample. Of that checkpoint's eight stages, only `S3_promotion` stays unmapped, as the spec requires.

**NB4, merged-item anchors: resolved.** In `Get-EpicProgressStepReport` (`Gather.ps1`), an item with a done `merge` step is removed from `Items`. `ItemsChanged` is set only when the stored state held that entry. The reviewer checked whether a merged item could still pass through the tick split, which would re-seed an anchor and set `ItemsChanged` on every run. It cannot: `Get-EpicProgressItemStep` marks every step of a merged item done, so the Gather `$merged` guard skips the tick split. A scratch probe confirmed this for a merged item with an unchecked plan task and for one with an open execution stage. Over two consecutive runs each case gave `Items.Count` 0, `ItemsChanged` False, and `LedgerChanged` False. On live data, the migration run wrote `items` empty for the 11 merged children of Epic #1019, and a second Full run did not rewrite the state file.

**Test discrimination.** The reviewer copied the skill and its tests to a scratch tree and applied four mutants, scoring each against its own test file and the ItemMode tests:

| Mutant | Caught by |
|---|---|
| NB1 branch disabled (`if ($false)`) | 'prints start not recorded on the Now line for a step without a start' |
| NB3 alias removed | 'maps each live stage alias to its step type' |
| NB4 removal rule disabled | 'drops the stored anchor of a merged item and keeps an unmerged one' |
| NB4 stored-entry guard removed (`$itemsChanged = $true` always) | 'leaves ItemsChanged false for a merged item with no stored entry' |

The unmutated tree passes 268 of 268 skill and forwarder tests.

**Full-branch re-check.** CLI backward compatibility holds. The scheduled TL;DR and Full forms bind and run from the main checkout, `-ResetBaseline -PairSamples` throws the documented message, and `-EpicFolder` with `-Issue` fails parameter-set binding. Version 1 migration on a scratch copy of the live state file gives `version` 2, `unit` `steps`, `baselineDone` 615 (the current step count), the original `startUnixSeconds` and `baselineWeeklyPct`, and one check-in sample. PSSA reports 0 findings, all ten bundle copies are byte-identical, and `git merge-tree` with `origin/main` (`e33635c14`) is clean.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (non-blocking, NB2, carried) | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Gather.ps1` | `Get-EpicProgressEpicCheckpointRow` (absent file) | In epic mode, an absent epic checkpoint gives empty rows with no warning, so every child reads as running when the script runs outside the main checkout | Write a warning naming `-CheckpointPath` when the file is absent in epic mode | Behavior predates the branch and was outside cycle 2 scope; the scheduled location (main checkout) is correct | Prior review runs; unchanged code |
| Info | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Steps.ps1` | `next_step` fallback in `Get-EpicProgressItemStep` | A re-audit inside a remediation cycle has no recorded start, so its median credit stays whole and the estimate is flat for the re-audit; the Now line now states `start not recorded` | Optional: start a cycle's re-audit step at the cycle plan's last tick | Follows Decision D2; no criterion requires it | Real `-Issue 1118` run |
| Info | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Stages.ps1`; `.claude/skills/epic-progress-report/SKILL.md` | `ConvertTo-EpicProgressStepType` `.DESCRIPTION`; `## Step Model` alias bullet | The cycle-2 edit left one long, unwrapped line in each text block | Re-wrap when the text is next edited | Cosmetic; the formatter and contract tests pass | Cycle-2 diff |
| Info | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | whole file | 495 logical lines, unchanged, just under the 500-line guidance tier | Keep further changes in the dot-sourced files | Guidance tier only; no gate | Reviewer `@(Get-Content).Count` |

No covered file in the branch diff is at or above 700 logical lines (largest 656, `Get-EpicProgressReport.Tests.ps1`), so no file-size Warning row applies. `config/file-size-baseline.json` is not in the branch diff.

## Prior Findings Disposition

| Finding | Status | Verification |
|---|---|---|
| NB1 step without a recorded start prints `0 h 00 min` | Resolved | Real TL;DR runs (epic and item) show `start not recorded`; golden added; mutant caught |
| NB2 no warning when the epic checkpoint is absent | Open, non-blocking | Not in cycle 2 scope; unchanged |
| NB3 `S2_feature_documents` unmapped | Resolved | Alias in table, spec, and SKILL.md; real-checkpoint parse gives a spec sample; mutant caught |
| NB4 merged-item anchors retained | Resolved | Live migration writes `items` empty; no rewrite on a repeat run; two mutants caught |
| RF1, RF2, RF3 (first review) | Resolved (cycle 1) | Cycle-1 tests still pass in the reviewer's run |

## Positive Observations

- The plan's premise correction (Render cannot tell a missing start from a zero elapsed time without a new property) was stated before the change and kept the fix to one property and one branch.
- The executor's self-review found an uncovered `elseif` line that the cycle introduced, added a test, and re-ran the gates, rather than accepting a per-file figure that was already above threshold.
- Each new test pins the exact literal or property that the fix introduces, and each one discriminates (four of four mutants caught).
- Bundle copies stay byte-identical, and `core.json` needed no change because no file was added.
