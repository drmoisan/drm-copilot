# Fail-Before Exception Dossier: F1 Helper Parity Rows (Issue #1010, remediation cycle 1, P1-T2)

Timestamp: 2026-10-30T22-17
Command: sh SCRATCH/issue-1010-pt.sh issue-1010-r1-s3.txt -NoCoverage
EXIT_CODE: 0
Output Summary: The three F1 parity rows pass on the unmodified tree; a failing run of them is not possible before this cycle. The two negative rows pass and provide the alternative proof that the assertion can fail.

WhyFailingRunImpossible: The three helper definitions (Get-OrchestrationGateWorktreeList, Invoke-OrchestrationGateWorktreeList, Get-OrchestrationGateCommandOperandPath) are byte-identical in the Claude and Codex `-epic-scope` files before this cycle, so the parity rows cannot fail on the unmodified tree. The finding is the absence of enforcement, not a present divergence.

## Alternative Proof

The parity rows use the test-local helper `Assert-GateHelperDefinitionParity`. Two rows drive that helper with in-memory text and assert that it throws:

- `F1 a definition that differs by one character fails the parity assertion` passed: the helper threw for two definitions of `Get-SampleHelper` that differ in one character (`'a'` and `'b'`).
- `F1 a definition missing from one surface fails the parity assertion` passed: the helper threw when the right-hand text holds no `Get-SampleHelper` definition.

Both rows passed in the run recorded in `f1-parity-detection.2026-10-30T22-17.md`, so a drift between the two surfaces, or a removed definition, fails the parity rows.
