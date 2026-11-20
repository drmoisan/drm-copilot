# Remediation Inputs: #1195 cycle 1 (orchestrator-opened after PASS review)

- Timestamp: 2026-11-16T02-21
- Issue: #1195
- Branch: bug/gate-wrapped-shell-test-commands
- PR: #1196
- Opening review: code-review.2026-11-16T02-17.md, policy-audit.2026-11-16T02-17.md, feature-audit.2026-11-16T02-17.md (verdict PASS at head ebacd29f19918dcced5caedefe91ecf7316a85a8, no blocking findings)
- Remediation-Mode: proportionate

## Why this cycle exists

The review recorded one Low, non-blocking finding that is directly related to this item's scope. The standing rule for this run is that related findings are fixed inside the item through a remediation cycle rather than deferred, so the orchestrator opens this cycle autonomously under owner directive OD-1. No acceptance criterion, public interface, or file set beyond the branch diff (classify sibling copies, the classify Cases and Tests files) changes, so the cycle is proportionate.

## Finding F1 (related; autonomous)

- Remediability: autonomous
- Finding-Scope: contained
- Source: code-review.2026-11-16T02-17.md, Findings row "Low (non-blocking)" on `Get-OrchestrationGateWrapperPayloadText`, env loop.
- Observed: the local `env` value-option handling in the classify sibling runs only at the head of the segment. When `env` with a value option (for example `env -u NAME`) follows another transparent prefix, `Skip-CommandLineTransparentWrapper` reads the option value as the command word and no payload is found. `timeout 60 env -u X sh -c "pytest"` returns `$false` from `Test-ImplementationCommand`, while the bare analogue `timeout 60 env -u X pytest` is classified. `env -u X timeout 60 sh -c "pytest"` is unaffected.
- Required change: apply the env value-option skip (`-u NAME`, `--unset NAME`, `--unset=NAME`, `-C DIR`, `--chdir DIR`, `--chdir=DIR`, other dash tokens, `NAME=value`, and the `-S` / `--split-string` decline) after each transparent prefix, not only at the head of the segment, in `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1`, then copy it byte-for-byte to its three mirrors. The shared module `hook-command-payload.ps1` stays unchanged, the cycle-3 guards stay byte-unchanged, and neither gate changes.
- Required tests: add `$script:ClassifyWrappedFunctionRows` rows that fail without the change: `timeout 60 env -u X sh -c "pytest"` with `Indexes = @(1)`, `nohup env --unset X bash -c "ruff check ."` with `Indexes = @(1)`, and `timeout 60 env -S sh -c "pytest"` with `Indexes = @()`; add a `$script:ClassifyWrappedGateRows` Kind `Positive` row `timeout 60 env -u X sh -c "pytest"` (`Expected = $true`). Record fail-before evidence for the Positive and `@(1)` rows.
- Verification: both classify `Tests.ps1` files pass on both surfaces; the classify parity test passes; the classify file keeps 100% line coverage in the Pester gate; one full parallel Pester gate and the final QA static loop pass.

## Other review items (no action)

- Info: the xargs loop limit has no comment. Not related to behavior; no change.
- Info: `find -exec sh -c` and `cmd /c` are outside the wrapper list or recorded non-goals; no change.
