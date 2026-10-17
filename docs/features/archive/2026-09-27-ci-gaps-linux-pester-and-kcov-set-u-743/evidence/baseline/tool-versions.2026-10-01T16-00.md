# Tool Availability (P0-T7)

Timestamp: 2026-10-01T16-00
Deviation: D1 (plan section `## Execution Deviations`). The three `pwsh -NoProfile -Command` probes were not run; PowerShell and Pester versions come from the CI `PowerShell QC` job log of the P0-T22 baseline run, and the actionlint probe is `command -v actionlint`.

Command: shfmt --version
EXIT_CODE: 0
Output Summary: `v3.12.0` (CI pins 3.8.0; CI is canonical).

Command: shellcheck --version
EXIT_CODE: 0
Output Summary: `version: 0.11.0`

Command: npx --yes bats --version
EXIT_CODE: 0
Output Summary: `Bats 1.13.0` (line begins `Bats `; bats resolves through npx).

Command: gh version
EXIT_CODE: 0
Output Summary: `gh version 2.87.3 (2026-02-23)`

Command: command -v actionlint
EXIT_CODE: 0
Output Summary: a path ending `.../WinGet/Packages/rhysd.actionlint_Microsoft.Winget.Source_8wekyb3d8bbwe/actionlint` (host prefix omitted); `actionlint --version` prints `1.7.11`.
ACTIONLINT-ON-PATH: YES

PowerShell version (D1 source: CI run 36890793420, job `PowerShell QC` 110465608484, https://github.com/drmoisan/drm-copilot/actions/runs/36890793420/job/110465608484): the job's pwsh steps run `C:\Program Files\PowerShell\7\pwsh.EXE` on runner image version 20260925.250.1; the log prints PowerShell major version 7 and does not print the minor version.

Pester version (D1 source: same job, step `Install PoshQC tooling`): log line `Pester 5.9.0 already present.` Pester 5.9.0 is at or above 5.6.1.
