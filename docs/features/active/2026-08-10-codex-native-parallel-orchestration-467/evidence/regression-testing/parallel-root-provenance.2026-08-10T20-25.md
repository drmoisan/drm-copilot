# P4-T4 Parallel Root Provenance Evidence

- Task: `[P4-T4]`.
- Scope: native root authorization, parallel authority-store isolation,
  PreToolUse enforcement, SubagentStart attestation, model-routing enforcement,
  and SubagentStop validation.
- Configuration and permission registration remain assigned to later plan tasks.

## Production owners

- `.codex/hooks/authorize-root-parallel-invocation.ps1`: 320 lines.
- `.codex/hooks/codex-authority-store.ps1`: 188 lines.
- `.codex/hooks/enforce-parallel-root-invocation.ps1`: 247 lines.
- `.codex/hooks/record-subagent-routing-attestation.ps1`: 497 lines.
- `.codex/hooks/enforce-codex-model-routing.ps1`: 224 lines.
- `.codex/hooks/validate-codex-subagent-routing.ps1`: 185 lines.

All six reusable files are within the 500-line repository limit. PowerShell
parser validation reported zero errors across the six files.

## Verification

- PoshQC format across all six hooks: PASS.
- PoshQC analyze across all six hooks: PASS with zero findings.
- Focused Pester regression set:
  `parallel-provenance.Tests.ps1`, `epic-provenance.Tests.ps1`, and
  `model-profile-attestation.Tests.ps1`: 50 tests, 0 failures, 0 errors.
- Root authorization classification: 6/6 PASS. Explicit root
  `parallel-plan`, `parallel-run`, and `parallel-orchestrate` invocations mint
  only the forced planner/orchestrator authority; an ordinary prompt mints no
  authority; child and epic personas are rejected; parallel and mutation
  identities are equal.
- PreToolUse authority enforcement: 13/13 PASS. Valid planner/orchestrator
  attestations and a matching mutation identity are accepted. Ordinary, child,
  and epic actors attempting the parallel surface, persona drift, model drift,
  reasoning drift, fallback use, and identity drift are denied.
- SubagentStart recorder: 5/5 PASS. Planner and both orchestrator entry modes
  require a fresh surface-isolated receipt, exact `gpt-5.6-sol` with `ultra`
  reasoning, `fallback_used=false`, and one shared mutation identity.
- Model-routing gate: 8/8 PASS. Exact parallel profiles are accepted; missing
  attestation, fallback, reasoning drift, and identity drift are denied; legacy
  epic behavior is preserved.
- SubagentStop gate: 10/10 PASS. Valid planner/orchestrator attestations may
  stop; missing or mismatched provenance, model, reasoning, fallback, and
  identity evidence request continuation; legacy epic behavior is preserved.
- Epic authority paths retain their prior default shape. Parallel receipts and
  attestations use a separate external `authority/parallel-entry` store.
- `.claude` status and diff counts: 0.
- `.codex/state`: absent after removing only the verified completed batch
  receipt.
- `git diff --check`: PASS.

## Acceptance

- Only explicit root parallel planning/execution entry points mint authority.
- Mutation entry points consume the same authorized parallel identity and do
  not mint independent authority.
- Forced persona, model, reasoning, profile, provenance, and no-fallback
  evidence are checked at start, mutation, and stop boundaries.
- Ordinary, child, and epic actors cannot act as parallel roots.
