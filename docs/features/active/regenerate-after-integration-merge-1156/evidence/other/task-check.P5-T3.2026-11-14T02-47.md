# Task check — [P5-T3]

Timestamp: 2026-11-14T02-47
Command: sh SCRATCH/issue-1156-p5t3.sh; sh SCRATCH/issue-1156-tc-pester.sh (Run.Path = Pester selection below); pwsh SCRATCH/issue-1156-ledger-sub.ps1
EXIT_CODE: 0
Output Summary: brief updated identically in all six copies (cmp equal); pytest selection 167 passed; Pester selection 624 passed, 0 failed (after the ledger fix below). Not a gate.

## Changed files

- .claude/skills/execution-environment/SKILL.md and its five byte-identical copies (.agents, .github, and the three bundle copies): two bullets in ## Hook Execution Context (Regeneration merge-gate check, Regeneration allowance), one bullet in ## CI Shape and Required Checks (Integration-tip CI, holding "dispatches CI on the integration branch after each child merge"), one bullet in ## Contract Tests That Pin Mirrored Files (regeneration-path-skill-contract.Tests.ps1).

## Finding and fix (related finding, fixed in this item)

The first Pester run of the selection failed 3 tests of tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 (PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-SUBCHAIN-HOLDS, PRC-LEDGER-NO-EXCEPTIONS). The plan listed that suite as unaffected. Cause: earlier #1156 edits (P4-T1, P4-T2, P4-T4, P5-T2) landed inside regions recorded by ledger entries 0002, 0009, and 0010, and the first placement of the new contract-test bullet sat inside the 0001 hunk context of the brief. The same chain run with origin/main live text reports 0 errors, so the failures were caused by this branch.

- 0010 stored patch: the epic-orchestrator.md tools hunk, the epic skill early_start hunk, and the surface-expectations hunk now carry the #1156 lines in both images; bundle sections synced; index lines set to the chain pre/post blobs (post blobs equal the HEAD blobs); prior digests set to the SHA-256 of the files after reverting 0010. git apply -R --check of those five paths against the tree exits 0.
- 0009 stored patch: the orchestrate item 11 '+' line carries the #1156 sentence; bundle section and index line synced.
- 0002 entry: the orchestrate Current fence item 7 carries the #1156 sentence.
- Brief: the contract-test bullet was moved after the parallel_orchestrator_surface_expectations.py bullet, outside every recorded region, so entry 0001 needs no change.

Committed separately with the subject tokens reduction: 0002, reduction: 0009, reduction: 0010, per the README revert-order rule. No test or assertion was changed.

## Selection and rule

Rule: contract tests that read the brief (plan-named list plus git grep execution-environment under tests/), the ledger suites that read the edited regions, and the bundle resource contract tests.

- pytest (-n auto): test_execution_environment_brief_contracts.py, test_discovery_documentation_contracts.py, test_single_pass_preflight_contracts.py, test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_issue_824_follow_ups.py, test_typescript_toolchain_instruction_contracts.py
- Pester: planning-contract-wording, NestingDepthContract, ProcessReductionChain.Ledger, ProcessReductionChain, ProcessReductionLedger, ProcessReductionLedger.Index, ProcessReductionLedger.Replay, cleanup-merged-worktrees.SkillText, parallel-gate-wording, test-cadence-wording, regeneration-path-skill-contract, concurrent-review-skill-contract, ReviewVerdictEligibility.PullRequest

## Commands and exit codes

| Step | Command | Exit | Result |
|---|---|---|---|
| copy | cp + cmp (5 copies) | 0 | all equal |
| test | poetry run pytest -n auto (7 files) | 0 | 167 passed |
| test (first) | Invoke-Pester (7 files) | 3 | 381 passed, 3 failed (ledger chain) |
| fix | ledger rebase (SCRATCH scripts) and bullet move | 0 | full chain 0 errors; every StopBefore sub-chain 0 errors |
| test (final) | Invoke-Pester (13 files) | 0 | 624 passed, 0 failed |
