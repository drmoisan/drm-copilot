Timestamp: 2026-10-29T19-20
Command: Invoke-Pester over the 11 enforce-epic-merge-gate.*.Tests.ps1 files in one process, file order shuffled with System.Random seeds 11, 23, 37 (sh-launched pwsh from SCRATCH); Python modules reversed (see isolation-python artifact)
EXIT_CODE: 0
Output Summary: 0 failures in every run, 245 passed each.
- seed 11 order: AuthorizationFields, GreenCiDecision, GreenCi, TriggerScoping, MergeQueue, WorktreeResolution, Coverage, Authorization, GreenCiRegression, DocsOnly, ItemResolution
- seed 23 order: GreenCiRegression, WorktreeResolution, DocsOnly, AuthorizationFields, GreenCi, GreenCiDecision, Authorization, TriggerScoping, MergeQueue, Coverage, ItemResolution
- seed 37 order: ItemResolution, Authorization, DocsOnly, GreenCiRegression, WorktreeResolution, MergeQueue, Coverage, AuthorizationFields, GreenCiDecision, GreenCi, TriggerScoping
Fresh single-process run over tests/scripts: see pester-full qa-gate artifact (0 failed). Python reversed-order run: 120 passed.
