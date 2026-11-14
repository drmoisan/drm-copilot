# PoshQC Format Gate (loop pass 2)

Timestamp: 2026-11-03T13-52
Task: [P8-T1]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-static.ps1 -ApplyFormat (Invoke-Formatter -ScriptDefinition with scripts/powershell/PoshQC/settings/pssa.settings.psd1, writing back only when the text changes); sha256sum of each file before and after
EXIT_CODE: 0
Output Summary: 10 of 10 files UNCHANGED. This is the second loop pass: P8-T11 failed in pass 1 (enforcement-hooks-no-python-invocation.Tests.ps1 rejected two `& $variable` scriptblock invocations in ParallelAdmissionPrecedence.psm1), the module was changed to use a named helper and a sort-property array, and the loop restarted here.

| File | SHA256 before | SHA256 after | Result |
| --- | --- | --- | --- |
| .claude/lib/parallel-admission/ParallelAdmission.psm1 | fddb9a9063cbca48ab2864257e039bef7a11df0ed94334350ace9db78e192362 | fddb9a9063cbca48ab2864257e039bef7a11df0ed94334350ace9db78e192362 | UNCHANGED |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1 | 0f1c3f690cf0fa67ac19df440006699296992c720b426782779a10f3792603a9 | 0f1c3f690cf0fa67ac19df440006699296992c720b426782779a10f3792603a9 | UNCHANGED |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | dfb1c3c654320e584cd5b2db3c10986f3c25983f88a2e5453c4993a38c2ca50e | dfb1c3c654320e584cd5b2db3c10986f3c25983f88a2e5453c4993a38c2ca50e | UNCHANGED |
| .claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1 | cd065d41ae3ff1b9053433a7236c01739009becdad10324d530fe4f019304358 | cd065d41ae3ff1b9053433a7236c01739009becdad10324d530fe4f019304358 | UNCHANGED |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 | d0b5a30446b395153781504bf68ba9726b381e372b7938b463b23a3fca84c0f3 | d0b5a30446b395153781504bf68ba9726b381e372b7938b463b23a3fca84c0f3 | UNCHANGED |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 | 5a115bb4c9cd8ef98f40e6bdf5dcd126847324fe61e5fd0387ce333ce6fba23e | 5a115bb4c9cd8ef98f40e6bdf5dcd126847324fe61e5fd0387ce333ce6fba23e | UNCHANGED |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 8eb69680d6314f147c5cb7786ab45fdbd39aed6659f62cbaff6fff9320f30e27 | 8eb69680d6314f147c5cb7786ab45fdbd39aed6659f62cbaff6fff9320f30e27 | UNCHANGED |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 774a1f06d7229e49e32d78df99825b9783e5bc0478adb9aa96d6c7930a4c1d8d | 774a1f06d7229e49e32d78df99825b9783e5bc0478adb9aa96d6c7930a4c1d8d | UNCHANGED |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 | 99d5458ad8f5c8e9293148c1a18f9474ce23fb2403b64f722ca10e54a0dc3de3 | 99d5458ad8f5c8e9293148c1a18f9474ce23fb2403b64f722ca10e54a0dc3de3 | UNCHANGED |
| tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | 96baf1995581b9d804f58e013a353b00c248e40b7109cdda032dcaaa8b89f77b | 96baf1995581b9d804f58e013a353b00c248e40b7109cdda032dcaaa8b89f77b | UNCHANGED |
