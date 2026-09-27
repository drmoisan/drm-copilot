# codex-gates-4-5-lack-epic-scope (Issue #707)

- Work Mode: full-bug
- Issue: #707
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/707
- Labels: bug
- Source: GitHub issue body, mirrored 2026-09-26 by the preparation-mode orchestrator. No potential entry exists in this branch; the lifecycle record is held outside this branch and is not a dependency of this item.
- Related: #663 (PR #700), the Claude-surface fix whose design decision D1 deferred this Codex-surface port.

## Summary

Issue #663 (PR #700) removed the gate-4 and gate-5 epic-scope denials on the Claude surface only. Its design decision D1 deferred the same fix for the Codex hooks, so a Codex-driven epic can still hit those denials.

## Environment

- OS/version: any
- Python version: n/a (PowerShell hooks)
- Command/flags used: a Codex-driven epic run exercising gate 4 (preimplementation) and gate 5 (completion consistency)
- Data source or fixture: an epic with a child feature checkpoint

## Steps to Reproduce

1. Run an epic through the Codex surface (`.codex/hooks/`).
2. Stage a production file in epic scope, or complete an epic child checkpoint.
3. Observe the gate-4 or gate-5 denial that #663 removed on the Claude surface.

## Expected Behavior

The Codex hooks honour the same epic-level checkpoint seam as the Claude hooks after #663.

## Actual Behavior

The three Codex hooks are unchanged: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1`. Only the byte-identical helpers copy (`.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`) was touched. `evidence/qa-gates/p7-d1-scope.md` in the #663 feature folder confirms this.

## Logs / Screenshots

- Snippet: see the #663 feature folder `evidence/other/follow-ups.md`, item 1.

## Impact / Severity

- Medium

## Acceptance Criteria

- [ ] AC-1: The Codex gate-4 hook (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`) accepts an epic-scope operation through the same epic-level checkpoint seam that the Claude gate-4 hook uses after #663, instead of denying it with `PREIMPLEMENTATION_GATE_BLOCKED`.
- [ ] AC-2: The Codex gate-5 hooks (`.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1`) accept an epic-level checkpoint edit through the same seam that the Claude gate-5 hooks use after #663, instead of denying it with `COMPLETION_CONSISTENCY_BLOCKED`.
- [ ] AC-3: Non-epic (single-feature) behaviour of the Codex gate-4 and gate-5 hooks is unchanged: every denial they issue today for a per-feature checkpoint is still issued.
- [ ] AC-4: Automated tests cover the Codex epic-scope allow path and the unchanged per-feature deny path for both gates, and they run in Linux CI without depending on gitignored state, `origin/main`, or Windows-only paths.
- [ ] AC-5: The Codex port mirrors the #663 Claude-side design (shared resolver seam and decision set) rather than introducing a separate design, and any intentional divergence is recorded as a numbered decision in `spec.md`.
