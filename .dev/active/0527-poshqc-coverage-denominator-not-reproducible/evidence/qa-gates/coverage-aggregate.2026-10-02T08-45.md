# Coverage Aggregate and Baseline Delta (P6-T14)

Timestamp: 2026-10-02T08-45
Command: comparison of `evidence/baseline/pwsh-coverage-baseline.2026-10-02T07-45.md` (P0-T5; CI run 36978425380, `artifacts/ci/run-36978425380/cx.txt`) with `evidence/qa-gates/final-pwsh-coverage-run-a.2026-10-02T08-45.md` (P6-T5; CI run 36983551836, `artifacts/ci/run-36983551836/cx.txt`). Follow-up list: the orchestrator's `artifacts/ci/run-36983551836/below85.txt` (every run A KEY row with covered/(missed+covered) below 85.00, sorted by missed descending), read with the Read tool and copied below.
EXIT_CODE: 0
Output Summary: baseline LINE_PCT=96.38 LINE_TOTAL=11887 FILES=127 -> run A LINE_PCT=84.67 LINE_TOTAL=15738 FILES=174. PoshQC.Testing.psm1: baseline 202/202 = 100.00% -> run A 200/200 = 100.00%. Run A aggregate is below 85.00, so the follow-up section below is present (42 KEY rows).
- Cause of the drop: the measured population changed from the 127-file runsettings allow-list to the 174 files derived from `config/poshqc-coverage.json` (net 47 more files); the newly measured files include scripts absent from the baseline population (for example `scripts/dev-tools/bootstrap-host.ps1`, 0/177, which has no baseline KEY row). No production file is excluded and no root is narrowed (evidence only, not a gate).
- Acceptance: all numeric values present; the follow-up section exists exactly when the aggregate is below 85.00 (84.67 < 85.00, section present). Met.

| Metric | Baseline (P0-T5) | Run A (P6-T5) |
| --- | --- | --- |
| LINE_PCT | 96.38 | 84.67 |
| LINE_TOTAL | 11887 | 15738 |
| FILES | 127 | 174 |
| LINE_MISSED / LINE_COVERED | 430 / 11457 | 2413 / 13325 |
| PoshQC.Testing.psm1 | 202/202 (100.00%) | 200/200 (100.00%) |

## Follow-up item: run A KEY rows below 85.00 (sorted by missed, descending)

Repository aggregate PowerShell line coverage under the derived population is 84.67%, below the 85% policy line. The rows below are the files to raise; this is recorded as a follow-up item per AC-14 and is not addressed in this change.

```text
.codex/scripts|epic-child-launch-runtime.ps1 missed=199 covered=30 pct=13.10
.codex/scripts|launch-epic-child-wave.ps1 missed=194 covered=97 pct=33.33
scripts/dev-tools|bootstrap-host.ps1 missed=177 covered=0 pct=0.00
scripts/dev-tools|verify-host.ps1 missed=153 covered=0 pct=0.00
.codex/scripts|resume-epic-child.ps1 missed=143 covered=38 pct=20.99
scripts/dev-tools|publish-sideloaded-extension.ps1 missed=138 covered=0 pct=0.00
.codex/hooks|validate-feature-review-coverage.ps1 missed=127 covered=10 pct=7.30
.claude/hooks|validate-feature-review-coverage.ps1 missed=106 covered=104 pct=49.52
.codex/hooks|record-subagent-routing-attestation.ps1 missed=89 covered=103 pct=53.65
.codex/scripts|post-codex-worktree-session.ps1 missed=85 covered=0 pct=0.00
.codex/hooks|enforce-epic-wave-barrier.ps1 missed=48 covered=85 pct=63.91
.codex/hooks|authorize-root-epic-invocation.ps1 missed=46 covered=54 pct=54.00
scripts/dev-tools|run-actionlint.ps1 missed=44 covered=6 pct=12.00
scripts/dev-tools|bootstrap-host.helpers.ps1 missed=43 covered=0 pct=0.00
.codex/hooks|validate-codex-subagent-routing.ps1 missed=42 covered=20 pct=32.26
.codex/scripts|epic-child-launch-contract.ps1 missed=39 covered=190 pct=82.97
scripts/dev-tools|sync-agents-from-instructions.ps1 missed=35 covered=94 pct=72.87
.claude/hooks|validate-executor-output.ps1 missed=34 covered=79 pct=69.91
.codex/hooks|enforce-codex-model-routing.ps1 missed=31 covered=41 pct=56.94
.codex/hooks|enforce-epic-root-invocation.ps1 missed=30 covered=20 pct=40.00
scripts/dev-tools|new-claude-worktree-session.ps1 missed=29 covered=46 pct=61.33
.codex/scripts|epic-child-persistence-runtime.ps1 missed=22 covered=29 pct=56.86
scripts/powershell/PoshQC|PoshQC.psm1 missed=20 covered=40 pct=66.67
scripts/dev-tools|vscode-cli.helpers.ps1 missed=18 covered=9 pct=33.33
scripts/powershell/PoshQC|convert-poshqc-coverage.ps1 missed=16 covered=0 pct=0.00
scripts/dev-tools|load-openai-key.ps1 missed=16 covered=0 pct=0.00
.codex/hooks|codex-authority-store.ps1 missed=16 covered=42 pct=72.41
.claude/hooks|validate-required-artifact-output.ps1 missed=16 covered=37 pct=69.81
scripts/dev-tools|new-potential-entry.ps1 missed=15 covered=72 pct=82.76
.codex/hooks|codex-epic-child-launch-attestation.ps1 missed=15 covered=51 pct=77.27
scripts/dev-tools|DrmCopilotPromptSupport.ps1 missed=11 covered=27 pct=71.05
.codex/hooks|enforce-completion-helpers.ps1 missed=9 covered=34 pct=79.07
scripts/powershell/PoshQC|PoshQC.FileDiscovery.psm1 missed=8 covered=41 pct=83.67
scripts/dev-tools|link-feature-docs.ps1 missed=8 covered=37 pct=82.22
.codex/scripts|epic-child-sandbox-preflight.ps1 missed=8 covered=26 pct=76.47
scripts/dev-tools|tree.ps1 missed=7 covered=12 pct=63.16
scripts/dev-tools|Enter-DrmCopilotShell.ps1 missed=6 covered=0 pct=0.00
scripts/dev-tools|run-psscriptanalyzer.ps1 missed=5 covered=0 pct=0.00
scripts/dev-tools|run-poshqc-suite.ps1 missed=5 covered=0 pct=0.00
scripts/dev-tools|run-pester.ps1 missed=5 covered=0 pct=0.00
scripts/dev-tools|format-powershell.ps1 missed=5 covered=0 pct=0.00
.claude/hooks|validate-pr-author-output.ps1 missed=5 covered=28 pct=84.85
```

Note: `below85.txt` holds a 43rd line, ` missed=0 covered=0 pct=0.00`, with an empty key. The run A CX output has no KEY row with `missed=0 covered=0`, so that line is an artifact of the reduction (a blank input line parsed as a row) and is omitted above. The follow-up list is the 42 rows shown.
