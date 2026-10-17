# Attestation coverage — Bounded Auxiliary Plan

- Issue: #977
- Work Mode: full-feature
- Status: Approved — executor preflight all clear
- Purpose: authorized auxiliary remediation for the attestation coverage deficit; this does not replace the authoritative migration plan.
- FEATURE: docs/features/active/2026-10-17-current-codex-model-routing-977
- Parent plan: FEATURE/plan.2026-10-17T13-21.md
- Evidence baseline: FEATURE/evidence/baseline/powershell-bundle-coverage.2026-10-17T17-39.md records actual bundled hook coverage 103/192 = 53.6458%.
- Research: FEATURE/research/2026-10-17T17-41-attestation-coverage-research.md

## Required References and Invariants

Apply AGENTS.md and .agents/skills/{general-code-change,general-unit-test,powershell,atomic-plan-contract,execution-environment,evidence-and-timestamp-conventions}/SKILL.md. The parent plan owns complete ordered language baselines, final toolchains, coverage comparisons, isolation checks, and branch self-review. Reuse those tasks/evidence rather than launch duplicate broad suites for this addendum.
Tool routes, launchers, coverage invocation, and installed-validator behavior remain owned by execution-environment.
SCRATCH resolves to `<session scratchpad>/issue-977/`; auxiliary runners/reports use issue-prefixed names there. Each actual command has its own canonical timestamped artifact containing Timestamp:, Command:, EXIT_CODE:, Output Summary:.
Preserve runtime defaults, CLI stdout/stderr and exit status, input/checkpoint parsing, JSON receipt fields, exact model/effort/hash/profile/authority checks, single-use consumption, exclusive file access, durable flush, and disposal. No compatibility schema, weakened attestation, filesystem-backed unit tests, dependencies, or general I/O framework.
The parent owns preflight and execution sequencing. Complete this auxiliary implementation within parent P1-T5/P1-T12/P1-T9 before parent final QA; original 39 task IDs/order and task-35 commit boundary stay fixed.

## Exact File Scope and Existing Test Dispositions

- SOURCE: .codex/hooks/record-subagent-routing-attestation.ps1.
- MIRROR: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1.
- PERSISTENCE-TEST: tests/scripts/codex-hooks/subagent-attestation-persistence.Tests.ps1.
- COMMAND-TEST: tests/scripts/codex-hooks/subagent-attestation-command.Tests.ps1.
- Conditional HELPER, only if SOURCE would otherwise exceed 500 physical lines: .codex/hooks/codex-subagent-attestation-command.ps1 and its same-relative-path mirror under extensions/drm-copilot/resources/codex-and-agents-customizations/. Register that one helper in extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json. If not necessary, create none of these conditional changes.
- Existing model-profile-attestation.Tests.ps1, epic-provenance.Tests.ps1, epic-child-launch-attestation.Tests.ps1, codex-bundle-hook-probe.Tests.ps1, and codex-epic-runtime-contracts.Tests.ps1 under tests/scripts/codex-hooks/ retain their behavioral assertions; existing calls remain valid because seam parameters have defaults. Model literal changes remain parent-plan work. No probe/process test is treated as evidence of unexecuted hook paths.
- Existing test_push_down_codex_and_agents_resource_contracts.py, test_push_down_codex_and_agents_pack_manifest_completeness.py, and test_codex_core_manifest_closure.py under tests/scripts/dev_tools/ remain unchanged and execute in parent QA; they assert mirror/manifest completeness. New helper dot-sourcing, if needed, follows the existing guarded dependency convention.

## Design

Write-CodexSubagentAttestation receives defaulted, named OpenStream and EnsureDirectory delegates. OpenStream accepts path/mode/access/share and defaults to the existing File.Open behavior; EnsureDirectory defaults to the existing Directory.CreateDirectory behavior. Preserve CreateNew/Write/None, encoding, writer/stream disposal, returned path, and exception propagation.
Get-CodexSubagentAttestationFromAuthority receives defaulted OpenStream and, if required for a genuine MemoryStream test double, a defaulted FlushStream delegate whose runtime default performs the existing Flush(true). Preserve Open/ReadWrite/None, early returns, JSON validation, authorization-before-consumption, truncation/rewind, consumed metadata, durable flush, and finally disposal.
Expose the existing command body through Invoke-CodexSubagentAttestationCommand. Narrow defaulted input/checkpoint/head/clock delegates make console input, checkpoint reads, git HEAD result/exit status, and time deterministic; use existing mockable authority/persistence commands. Return an internal command result with exit status/stdout/stderr to a thin entry wrapper that emits exactly the existing CLI output and status. Preserve dot-source return behavior and canonical repository-root derivation. Do not add a second implementation of model/receipt validation.
Tests execute the actual imported source or actual bundled file, with injected memory streams and command delegates. They never rewrite production source or measure extracted AST/scriptblocks. Supplemental container adaptation may bind test import targets only.

## Implementation Plan

### Phase 0 — Bounded Baseline Confirmation

- [x] [P0-T1] Review required policies, research, and latest parent baseline artifacts; write FEATURE/evidence/remediation-baseline/attestation-coverage.<timestamp>.md. Acceptance: evidence preserves the 103/192 (53.6458%) bundled hook baseline, identifies all missed persistence/command/JSON paths, records SOURCE's current physical size, and references complete parent language baselines without rerunning them solely for this addendum.

### Phase 1 — Minimal Seams and Behavioral Tests

- [x] [P1-T1] Add the defaulted stream/directory/flush seams described above to Write-CodexSubagentAttestation and Get-CodexSubagentAttestationFromAuthority in SOURCE. Acceptance: only I/O construction/flush calls are delegated; parameter defaults retain exact existing modes, locking, encoding, write ordering, return values, disposal, and failure propagation. Existing attestation/provenance calls remain compatible; P1-T3 proves the boundary behavior.
- [x] [P1-T2] Extract SOURCE's existing command body into Invoke-CodexSubagentAttestationCommand with narrow input/checkpoint/head/clock seams and a thin output/exit wrapper. Use conditional HELPER only if needed for the 500-line cap, preserving existing dependency-guard conventions and default root derivation. Acceptance: successful invocation emits no extra output; provenance/routing failures retain their exact JSON context and exit 0; malformed required input, invalid HEAD, and persistence errors retain stderr diagnostics and exit 2. Existing CLI/dot-source contracts remain compatible; P1-T4 proves command behavior.
- [x] [P1-T3] Create PERSISTENCE-TEST with no-file memory-stream cases for JSON required/optional valid/blank/malformed input, missing identity/profile failure, root receipt invalid variants, writer serialization/path/mode/encoding/disposal/error propagation, and authority early-return/authorized consume/unauthorized no-rewrite/malformed receipt/stream-failure/disposal behavior. Acceptance: isolated cases assert unchanged results and consume-once metadata, recording fake delegate arguments and stream contents; no actual directory/file/network/process operation is needed and every new seam's meaningful positive/negative paths are exercised.
- [x] [P1-T4] Create COMMAND-TEST using injected input/checkpoint/HEAD/clock and mocked existing authority/persistence commands. Cover absent/valid/optional-malformed checkpoints, valid command, invalid HEAD result and nonzero exit, malformed required payload, provenance rejection, routing rejection, and propagated persistence error. Acceptance: exact stdout/stderr/exit status and dependency arguments match pre-refactor behavior, with no git invocation, console mutation, temporary files, or global state leak.
- [x] [P1-T5] Synchronize SOURCE to MIRROR and conditional HELPER/manifest only when used. Acceptance: direct source/bundle equality holds and physical sizes of changed source/test/helper files remain <=500; supplemental harness includes PERSISTENCE-TEST and COMMAND-TEST against each actual changed bundled target rather than transformed source. Parent P1-T9 and final contracts verify distribution completeness.

### Phase 2 — Targeted Proof and Parent QA Integration

- [x] [P2-T1] Run focused formatting, analysis, and coverage-bearing Pester for SOURCE/PERSISTENCE-TEST/COMMAND-TEST and actual MIRROR, adding conditional HELPER source/mirror if present; restart at formatting after any repair. Write one artifact per actual step under FEATURE/evidence/regression-testing/attestation-<step>.<timestamp>.md. Acceptance: positive/negative tests pass, every changed source and actual bundled production file independently measures >=85% line coverage, every new method reaches >=90%, and numerator/denominator/percent are recorded without exclusions. Include new suites in parent P2-T11/P2-T13 full configured Pester, >=3 shuffled file-order seeds, and fresh single-process tests/scripts run; parent full language gates remain mandatory.
- [x] [P2-T2] Self-review the auxiliary branch diff from the merge base of origin/main and HEAD against every policy-audit/code-review/feature-audit template item under docs/features/templates/policy_audit/; write FEATURE/evidence/qa-gates/self-review-attestation.<timestamp>.md with PASS/FAIL/justified N/A per item. Acceptance: no FAIL; evidence proves unchanged default runtime behavior, exact CLI output/schema/diagnostics and attestation checks, no-file tests, actual target coverage, mirror/manifest parity, and size compliance. Fix findings and rerun affected QA before rewriting review; parent P2-T14 still reviews the complete migration.

## Pre-Mortem

- Review checklists: P2-T2 checks all template items and parent P2-T14 covers the complete branch; existing profile/provenance assertions remain intact.
- Coverage: preserve 103/192 baseline; P2-T1 instruments actual source and bundled files separately, requires >=85% per file and >=90% per new method, and forbids source extraction/exclusions.
- Mirror parity: P1-T5 synchronizes exact source/bundle bytes and conditionally registers only the required helper; parent final resource/manifest contracts verify delivery. No execution-environment fact changes, so its six copies need no edits.
- File size: SOURCE currently has 414 physical lines; use the single named conditional helper only if necessary to stay <=500 and keep each new test file within that cap.
- Test isolation: memory streams/delegates/mocks replace external I/O; parent P2-T13 includes the new suites in >=3 recorded shuffled Pester file-order seeds and fresh single-process tests/scripts. Seeded shuffled Jest and reversed changed Python modules remain parent-plan requirements, with no additional Python/TypeScript changes here.
- CI-only behavior: preserve portable paths, exact casing, LF normalization, guarded imports, and runtime defaults; parent full required CI remains necessary at final PR head.
- Evidence: record true target identity, pass counts, coverage numerator/denominator, baseline delta, and unresolved failures; neither mirror parity nor invocation acknowledgement proves coverage.
