# blast-radius-mandate-reads-scripts-vscode (Issue #620)

- Date captured: 2026-09-01
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/blast-radius-mandate-reads-scripts-vscode/ (Issue #620)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #620
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/620
- Last Updated: 2026-09-01
## Summary

`config/blast-radius.json` and its bundled copy omit `scripts/vscode/**` from `mandate_reads`, so blast-radius derivation counts every citation of the standard C# toolchain wrapper scripts (e.g. `Invoke-MSTestWithCoverage.ps1`, `Invoke-Restore.ps1`, `Install-RepoDotNetSdk.ps1`) as a genuine write-path overlap between parallel items, producing spurious `path_overlap` conflict edges.

## Environment

- OS/version: Windows 11 (repo also runs in CI on Linux runners)
- Python version: repo-standard Poetry environment
- Command/flags used: blast-radius derivation during `/parallel-plan` and `/parallel-add` admission
- Data source or fixture: TaskMaster downstream repo, `bugs-638-644-647` parallel run

## Steps to Reproduce

1. Author two independent C# atomic plans that each cite a `scripts/vscode/**` toolchain wrapper script as a command they RUN (not a file they write).
2. Run blast-radius derivation for both items via the parallel planner/admission path.
3. Observe a `path_overlap` conflict edge recorded between the two items solely due to the shared `scripts/vscode/**` citation.

## Expected Behavior

A citation of a `scripts/vscode/**` toolchain wrapper script as a command an item RUNS should be excluded from the derived write-path radius, per the existing "Read-by-mandate classification" doctrine already applied to `.claude/rules/**` and `quality-tiers.yml`. No conflict edge should be produced from that citation alone.

## Actual Behavior

Every pair of C# parallel items that cites the standard toolchain scripts under `scripts/vscode/` acquires a spurious `path_overlap` conflict edge. In TaskMaster's `bugs-638-644-647` parallel run, 21 of 91 recorded conflict edges rest on a `scripts/vscode/` path citation. Multiple independent `/parallel-add` admission reports (items 285, 287, 648, 662, 663) flagged this exact gap and declined to work around it per the "never narrow a declared radius to suppress a conflict edge" rule.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: 21/91 conflict edges in TaskMaster's bugs-638-644-647 run trace to `scripts/vscode/` citations (see admission reports for items 285, 287, 648, 662, 663).

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

`config/blast-radius.json` (repo root) and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` (bundled copy) both omit `scripts/vscode/**` from `mandate_reads`. `mandate_reads` is one of the three keys (`version`, `over_breadth_fraction`, `mandate_reads`) required to be byte-identical between the two copies per `.claude/rules/parallel-orchestration.md`.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`
- [ ] Integration scenario to retest
- [x] Manual verification notes: after the config change, run `push_down_claude_customizations` so downstream repos (TaskMaster included) pick up the fix. Do not weaken the planner's obligation to declare a genuine write under `scripts/vscode/` when a diff actually touches a file there.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
