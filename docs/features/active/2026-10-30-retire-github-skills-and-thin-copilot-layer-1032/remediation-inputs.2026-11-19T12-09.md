# Remediation Inputs — Issue #1032 (integration sync with #1029)

Timestamp: 2026-11-19T12-09
Issue: #1032
Branch: feature/retire-github-skills-and-thin-copilot-layer-1032
Trigger: integration_sync (merge of origin/epic/shared-agent-harness-layer-integration, which now carries #1029 PR #1208, into this branch; merge commit dfed33c32, no textual conflicts)
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

Rationale for the mode: every finding is fixed inside files already in the branch diff or in the files the main plan's conditional P1-T9 clause already names (Copilot pack manifests and child 4's completeness test for them), plus their tests and mirrors. No spec acceptance criterion or public interface changes.

## Context

The main plan `plan.2026-10-30T18-39.md` completed all 36 tasks before #1029 merged. Phase 0 P0-T5 recorded `CopilotManifests: absent`, so the P1-T9 clause "when `CopilotManifests: present`, remove every retired-path entry from those manifests and from child 4's completeness test for them" did not run. After the integration sync the manifests exist under `extensions/drm-copilot/resources/customizations/pack-manifests/` and list paths under the retired skill trees. The orchestrator scheduling decision (OD-4) states that if #1029 merges before this PR merges, the branch merges the integration branch and re-runs the affected checks.

## Blocking Findings

### F1 — Copilot pack manifests list retired skill paths
- Severity: Blocking
- Remediability: autonomous
- Finding-Scope: contained
- Location: `extensions/drm-copilot/resources/customizations/pack-manifests/core.json` (48 entries naming the retired skill root), `csharp.json` (2), `powershell.json` (2); any other manifest under that folder that names a path under either `RETIRED-SKILL-TREES` tree.
- Rule: spec AC12 and main plan P1-T9 (`CopilotManifests: present` branch); `CLR-PACK-MANIFESTS` in `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1`; P2-T1 zero manifest matches.
- Required change: remove every retired-path entry from every pack manifest, and from #1029's completeness, closure or contract tests that enumerate those manifest entries (find them by searching the test tree for the manifest file names and the retired paths). Do not remove entries for remaining Copilot surfaces (`.github/agents`, `.github/prompts`, `.github/hooks`, `.github/instructions`, `.github/copilot-instructions.md`). If a manifest is generated, regenerate it with its generator instead of hand-editing, and run the generator check.

### F2 — Re-verify the merged push-down engine and sync roots
- Severity: Blocking
- Remediability: autonomous
- Finding-Scope: contained
- Location: `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` (refactored by #1029; the merged file no longer holds the retired root) and its Jest tests; `scripts/dev_tools/agentic_sync.py` and its tests.
- Rule: main plan P1-T7 acceptance (no retired root in edited production files; engine Jest suite and the four pytest modules pass).
- Required change: confirm on the merged head that neither production file nor any new #1029 push-down module re-introduces the retired root, and that the engine Jest suite and `test_agentic_sync.py`, `test_agentic_sync_artifacts.py`, `test_push_down_copilot_customizations.py`, `test_push_down_copilot_customizations_rewrites.py` pass; fix any test #1029 added that pins the retired root.

### F3 — Re-run the guard, contract and stale-reference checks on the merged head
- Severity: Blocking
- Remediability: autonomous
- Finding-Scope: contained
- Location: whole branch at the merge head.
- Rule: main plan P2-T1, P2-T4, P2-T6; `PUSH-DOWN-CONTRACT-TESTS`; `LEDGER-CHAIN-TESTS`; execution-environment brief copy facts (S1 to S6) in any brief or contract copy #1029 edited.
- Required change: run `GUARD-SUITE`, the push-down pack-manifest completeness and dependency-closure tests, the Codex generator check and child 3's generator check, the ledger-chain tests, and repeat the P2-T6 stale-reference classification for files the merge added; confirm the brief and plan-contract copies still state the four-copy facts and are byte-identical. Then run the three parallel gates once (Pester, pytest, Jest) and record them.

## Non-Blocking Notes
- The ledger and evidence rules of the main plan apply: evidence is append-only, stamped from the clock, under `<FEATURE>/evidence/<kind>/`.
