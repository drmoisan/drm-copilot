# P6-T18 PowerShell fail-first CI evidence (expect-fail)

Timestamp: 2026-10-13T12-04
Command: gh workflow run ci.yml --ref bug/round-2-review-nits-and-evidence-timestamps-903; gh run watch 38392312722 --exit-status; gh run view 38392312722 --json jobs; gh run view 38392312722 --log-failed; gh run download 38392312722 -n poshqc-linux-hook-test-results -D artifacts/scratch-903/ci-failfirst-903
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Commands were executed by the orchestrator (the executor session has no `gh`); outputs were saved to git-ignored scratch files and verified by the executor: `artifacts/scratch-903/ci-failfirst-run-903.json`, `artifacts/scratch-903/ci-failfirst-steps-903.txt`, `artifacts/scratch-903/ci-failfirst-log-failed-903.txt`, `artifacts/scratch-903/ci-failfirst-903/pester-junit-linux-hooks.xml`.
- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38392312722
- headSha: ae0204c6e58b573eab716015a1be7d767e67b4ef (equals the Phase 6 commit and the branch HEAD at recording time).
- Run conclusion: failure. `gh run watch --exit-status` exit 1, matching ExpectedExitCode 1.
- Jobs: `poshqc / PowerShell QC` failure and `poshqc / PowerShell hook suites (Linux)` failure; all 15 other jobs success.
- Linux Pester summary: `Tests Passed: 6175, Failed: 33, Skipped: 0, Inconclusive: 0, NotRun: 0`; JUnit `tests="6208" failures="33"`.
- Windows Pester summary: `Tests Passed: 10251, Failed: 34, Skipped: 10, Inconclusive: 0, NotRun: 0`.
- `[-]` lines in `--log-failed`: 67 (33 Linux + 34 Windows). Windows has one more because it also runs `tests/scripts/claude-lib` (the `kelvin-sign-extension` row).
- Deviation: `dotted-capital-i-extension` does not fail (no `[-]` line in either job). See Deviations.

## PowerShell QC step conclusions (Windows job)

| Step | Conclusion |
|---|---|
| Set up job | success |
| Check out repository | success |
| Install PoshQC tooling | success |
| Format PowerShell | success |
| Analyze PowerShell | success |
| Test PowerShell | failure |
| Upload PowerShell test artifacts | skipped |
| Post Check out repository | success |
| Complete job | success |

## PowerShell hook suites (Linux) step conclusions

| Step | Conclusion |
|---|---|
| Set up job | success |
| Check out repository | success |
| Install PoshQC tooling | success |
| Test PowerShell hook suites | failure |
| Upload PowerShell hook-suite test results | success |
| Post Check out repository | success |
| Complete job | success |

`Format PowerShell` and `Analyze PowerShell` concluded success, so the repeat condition of P6-T18 does not apply.

## Expected failing rows: disposition

| Expected failing row | Linux `[-]` | Windows `[-]` | Disposition |
|---|---|---|---|
| M8fe, M8fp (Claude surface) | present (2) | present (2) | as expected |
| M8fe, M8fp (Codex surface) | present (2) | present (2) | as expected |
| S06 `)` `]` `>` `*` `_` (Claude) | present (5) | present (5) | as expected |
| S06 `)` `]` `>` `*` `_` (Codex) | present (5) | present (5) | as expected |
| S06c both rows (Claude) | present (2) | present (2) | as expected |
| S06c both rows (Codex) | present (2) | present (2) | as expected |
| O-4 three rows | present (3) | present (3) | as expected |
| U11b both rows, U24 (.claude/hooks surface) | present (3) | present (3) | as expected |
| U11b both rows, U24 (.codex/hooks surface) | present (3) | present (3) | as expected |
| 120-character parity row | present (1) | present (1) | as expected |
| CR-9 contract row | present (1) | present (1) | as expected |
| F-1 non-compliant three rows | present (3) | present (3) | as expected |
| F-2 row | present (1) | present (1) | as expected |
| `kelvin-sign-extension` | not run (claude-lib is outside the Linux job scope) | present (1) | as expected |
| `dotted-capital-i-extension` | not run (claude-lib is outside the Linux job scope) | ABSENT | DEVIATION |

## Deviations

- DEVIATION-1: `dotted-capital-i-extension` in `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` produced no `[-]` line in the Windows `PowerShell QC` job (the only job that runs `tests/scripts/claude-lib`); the row therefore passed on the current code. The plan listed it as an expected failing row "per the unverified research expectation". This matches the executor's P4-T6 observation in the Python leg, where the dotted-capital-I row also passed before the fix. A likely explanation is that `'notes.' + [char]0x130` lower-cases (invariant or culture) to a two-code-point or non-ASCII result that the existing ASCII-only `$script:FileExtensionPattern` already rejects, whereas U+212A (Kelvin sign) lower-cases to ASCII `k` and is accepted. The row remains a valid regression guard after P7-T1; no plan change is made. The Windows passing result for this row cannot be quoted from a testcase element because the Windows `poshqc-test-results` artifact is not uploaded when its Test step fails; its absence from the `[-]` list is the recorded observation.
- No other deviation: every other expected failing row has its `[-]` line quoted below, and every expected passing row passed.

## Expected passing rows (from `artifacts/scratch-903/ci-failfirst-903/pester-junit-linux-hooks.xml`)

Each element below is self-closing, so it has no `failure` or `skipped` child.

```text
<testcase name="preimplementation gate targets (.claude/hooks).U11c gives git-relocation for an env-drive assignment" status="Passed" classname="/home/runner/work/drm-copilot/drm-copilot/tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1" assertions="0" time="0.003" />
<testcase name="preimplementation gate targets (.codex/hooks).U11c gives git-relocation for an env-drive assignment" status="Passed" classname="/home/runner/work/drm-copilot/drm-copilot/tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1" assertions="0" time="0.003" />
<testcase name="preimplementation gate targets (.claude/hooks).U11d still denies a standalone-word mention of a relocation name (recorded fail-closed residual)" status="Passed" classname="/home/runner/work/drm-copilot/drm-copilot/tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1" assertions="0" time="0.002" />
<testcase name="preimplementation gate targets (.codex/hooks).U11d still denies a standalone-word mention of a relocation name (recorded fail-closed residual)" status="Passed" classname="/home/runner/work/drm-copilot/drm-copilot/tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1" assertions="0" time="0.002" />
<testcase name="issue #903 F-1 conditional ancestors.F-1 compliant ESR mock inside a matching Get-Command guard" status="Passed" classname="/home/runner/work/drm-copilot/drm-copilot/tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1" assertions="0" time="0.011" />
<testcase name="issue #903 F-1 conditional ancestors.F-1 compliant baseline helper inside a matching Get-Command guard" status="Passed" classname="/home/runner/work/drm-copilot/drm-copilot/tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1" assertions="0" time="0.009" />
```

## Every `[-]` line from `gh run view 38392312722 --log-failed` (ANSI codes and durations stripped; job prefixed)

```text
Linux: [-] enforce-completion-consistency.ps1 payload envelope.Entrypoint transport.O-4: converts a throwing payload reader into a COMPLETION_CONSISTENCY_BLOCKED deny without throwing
Linux: [-] enforce-completion-consistency.ps1 payload envelope.Entrypoint transport.O-4: returns allow for a benign non-checkpoint payload read through the entry point
Linux: [-] enforce-completion-consistency.ps1 payload envelope.Entrypoint transport.O-4: reads the payload through the default reader when no -ReadPayload is supplied
Linux: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside if ($false)
Linux: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside try/catch
Linux: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside a Get-Command guard naming another seam
Linux: [-] issue #903 F-1 conditional ancestors.F-2: reports no dot-source loads the hook when only a helper is dot-sourced
Linux: [-] enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Claude, issue #565).issue #565 CR-1: keyed-only issue source and the D3 hash fallback.M8fe: denies an epic delegation that cites an unrecorded folder with only a bare #302 as target-record
Linux: [-] enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Claude, issue #565).issue #565 CR-1: keyed-only issue source and the D3 hash fallback.M8fp: denies a parallel delegation that cites an unrecorded folder with only a bare #302 as target-record
Linux: [-] enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps every line of every surface copy at or under 120 characters (issue #903, #732 CR-4)
Linux: [-] preimplementation gate targets (.claude/hooks).U11b resolves git add docs/legit_dir-notes.md to the session root (identifier-embedded name)
Linux: [-] preimplementation gate targets (.claude/hooks).U11b resolves MY_GIT_DIR=1 git add a.ps1 to the session root (identifier-embedded name)
Linux: [-] preimplementation gate targets (.claude/hooks).U24 gives git-command-word-missing for a token array without git
Linux: [-] preimplementation gate targets (.codex/hooks).U11b resolves git add docs/legit_dir-notes.md to the session root (identifier-embedded name)
Linux: [-] preimplementation gate targets (.codex/hooks).U11b resolves MY_GIT_DIR=1 git add a.ps1 to the session root (identifier-embedded name)
Linux: [-] preimplementation gate targets (.codex/hooks).U24 gives git-command-word-missing for a token array without git
Linux: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character ()) from the folder segment
Linux: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (]) from the folder segment
Linux: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (>) from the folder segment
Linux: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (*) from the folder segment
Linux: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (_) from the folder segment
Linux: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06c: trims wrapping punctuation from a composite citation ((docs/features/active/x))
Linux: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06c: trims wrapping punctuation from a composite citation (**docs/features/active/x**)
Linux: [-] Codex epic runtime configuration and distribution contracts.documents the one-paragraph multi-message trailer form in the Codex epic-plan skill
Linux: [-] enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Codex, issue #565).issue #565 CR-1: keyed-only issue source and the D3 hash fallback.M8fe: denies an epic delegation that cites an unrecorded folder with only a bare #302 as target-record
Linux: [-] enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Codex, issue #565).issue #565 CR-1: keyed-only issue source and the D3 hash fallback.M8fp: denies a parallel delegation that cites an unrecorded folder with only a bare #302 as target-record
Linux: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character ()) from the folder segment
Linux: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (]) from the folder segment
Linux: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (>) from the folder segment
Linux: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (*) from the folder segment
Linux: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (_) from the folder segment
Linux: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06c: trims wrapping punctuation from a composite citation ((docs/features/active/x))
Linux: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06c: trims wrapping punctuation from a composite citation (**docs/features/active/x**)
Windows: [-] enforce-completion-consistency.ps1 payload envelope.Entrypoint transport.O-4: converts a throwing payload reader into a COMPLETION_CONSISTENCY_BLOCKED deny without throwing
Windows: [-] enforce-completion-consistency.ps1 payload envelope.Entrypoint transport.O-4: returns allow for a benign non-checkpoint payload read through the entry point
Windows: [-] enforce-completion-consistency.ps1 payload envelope.Entrypoint transport.O-4: reads the payload through the default reader when no -ReadPayload is supplied
Windows: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside if ($false)
Windows: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside try/catch
Windows: [-] issue #903 F-1 conditional ancestors.F-1 non-compliant ESR mock inside a Get-Command guard naming another seam
Windows: [-] issue #903 F-1 conditional ancestors.F-2: reports no dot-source loads the hook when only a helper is dot-sourced
Windows: [-] enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Claude, issue #565).issue #565 CR-1: keyed-only issue source and the D3 hash fallback.M8fe: denies an epic delegation that cites an unrecorded folder with only a bare #302 as target-record
Windows: [-] enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Claude, issue #565).issue #565 CR-1: keyed-only issue source and the D3 hash fallback.M8fp: denies a parallel delegation that cites an unrecorded folder with only a bare #302 as target-record
Windows: [-] enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps every line of every surface copy at or under 120 characters (issue #903, #732 CR-4)
Windows: [-] preimplementation gate targets (.claude/hooks).U11b resolves git add docs/legit_dir-notes.md to the session root (identifier-embedded name)
Windows: [-] preimplementation gate targets (.claude/hooks).U11b resolves MY_GIT_DIR=1 git add a.ps1 to the session root (identifier-embedded name)
Windows: [-] preimplementation gate targets (.claude/hooks).U24 gives git-command-word-missing for a token array without git
Windows: [-] preimplementation gate targets (.codex/hooks).U11b resolves git add docs/legit_dir-notes.md to the session root (identifier-embedded name)
Windows: [-] preimplementation gate targets (.codex/hooks).U11b resolves MY_GIT_DIR=1 git add a.ps1 to the session root (identifier-embedded name)
Windows: [-] preimplementation gate targets (.codex/hooks).U24 gives git-command-word-missing for a token array without git
Windows: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character ()) from the folder segment
Windows: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (]) from the folder segment
Windows: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (>) from the folder segment
Windows: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (*) from the folder segment
Windows: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (_) from the folder segment
Windows: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06c: trims wrapping punctuation from a composite citation ((docs/features/active/x))
Windows: [-] feature-folder-resolution.ps1 (Claude surface).Find-FeatureFolderCandidate (R1).S06c: trims wrapping punctuation from a composite citation (**docs/features/active/x**)
Windows: [-] Test-FileShapedComponent (issue #797).Predicate cases.reports the component case kelvin-sign-extension
Windows: [-] Codex epic runtime configuration and distribution contracts.documents the one-paragraph multi-message trailer form in the Codex epic-plan skill
Windows: [-] enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Codex, issue #565).issue #565 CR-1: keyed-only issue source and the D3 hash fallback.M8fe: denies an epic delegation that cites an unrecorded folder with only a bare #302 as target-record
Windows: [-] enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Codex, issue #565).issue #565 CR-1: keyed-only issue source and the D3 hash fallback.M8fp: denies a parallel delegation that cites an unrecorded folder with only a bare #302 as target-record
Windows: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character ()) from the folder segment
Windows: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (]) from the folder segment
Windows: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (>) from the folder segment
Windows: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (*) from the folder segment
Windows: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06: trims a trailing sentence character (_) from the folder segment
Windows: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06c: trims wrapping punctuation from a composite citation ((docs/features/active/x))
Windows: [-] feature-folder-resolution.ps1 (Codex surface).Find-FeatureFolderCandidate (R1).S06c: trims wrapping punctuation from a composite citation (**docs/features/active/x**)
```
