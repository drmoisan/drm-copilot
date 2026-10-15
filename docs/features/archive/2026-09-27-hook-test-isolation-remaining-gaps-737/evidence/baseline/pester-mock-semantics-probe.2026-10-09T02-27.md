# P0-T7 Mock-semantics probe

Timestamp: 2026-10-09T02-27
Command: Route C: scratchpad .ps1 holding the in-memory probe body of P0-T7 (New-Module Probe737; helper function Register-Probe737Mock registering a module-scoped mock and a script-scope mock from a file-level BeforeAll; four It rows), run with pwsh -NoProfile -File; no file is created under the repository.
EXIT_CODE: 0
Output Summary:
PROBE: Passed=4 | Failed=0
EXIT_CODE_COMPUTED: 0
Tests Passed: 4, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Rows passed: module mock registered by a helper function applies in a nested It; module mock call count is observable inside one It (Should -Invoke -ModuleName ... -Times 1 -Exactly); script-scope mock registered by a helper function applies in a nested It; script-scope mock call count is observable inside one It.
Conclusion: root-level mock placement, helper-registered mock placement, and Should -Invoke count semantics hold as the guard and the interception probe assume.
