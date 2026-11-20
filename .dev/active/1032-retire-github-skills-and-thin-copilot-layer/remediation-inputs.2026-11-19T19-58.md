# Remediation Inputs — Issue #1032 (second integration sync: #1049, #1050, #1051)

Timestamp: 2026-11-19T19-58
Issue: #1032
Branch: feature/retire-github-skills-and-thin-copilot-layer-1032
Trigger: integration_sync merge conflict. origin/epic/shared-agent-harness-layer-integration advanced with #1049 (PR #1209), #1050 (PR #1210) and #1051 (PR #1211) after the H3 and Branch B plans completed at 660f6c7c5. config/orchestration-regeneration.json is absent, so the regenerate path does not apply (no_config) and the conflict is handled through the remediation loop.
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: design

Rationale for the mode: every finding is resolved inside files already in the branch diff (the retired brief copies, the remaining execution-environment brief copies, the Copilot pack manifests) plus their tests and mirrors. No spec acceptance criterion or public interface changes.

## Captured conflict list (from a non-committing merge preview of HEAD and origin/epic/shared-agent-harness-layer-integration)

- CONFLICT (modify/delete): `.github/skills/execution-environment/SKILL.md` — deleted on this branch (retired by main plan P1-T9), modified on the integration branch.
- CONFLICT (modify/delete): `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` — same.
- CONFLICT (content): `extensions/drm-copilot/resources/customizations/pack-manifests/core.json`.
- Auto-merged (verify): `.agents/skills/execution-environment/SKILL.md`, `.claude/skills/execution-environment/SKILL.md` and their two bundle copies, `config/harness-parity-matrix.json`, `extensions/drm-copilot/CHANGELOG.md`, `extensions/drm-copilot/README.md`.

## Blocking Findings

### F1 — Resolve the modify/delete conflicts on the retired brief copies
- Severity: Blocking
- Remediability: autonomous
- Finding-Scope: contained
- Required change: merge origin/epic/shared-agent-harness-layer-integration into the branch; keep both retired copies deleted (`RETIRED-SKILL-TREES` stay empty; `CLR-SKILL-TREES-ABSENT`). Confirm that every fact the integration branch added to the retired copies is present in the four remaining copies (`REMAINING-BRIEF-COPIES`), and that the four remaining copies are byte-identical and still state the four-copy facts S1 to S5 (`test_brief_copies_are_byte_identical`, `CLR-BRIEF-COUNT`). If an integration edit introduced new six-copy wording (for example a new bullet saying six copies or naming the retired paths), rewrite it to the four-copy form in all four copies.

### F2 — Resolve the core.json content conflict
- Severity: Blocking
- Remediability: autonomous
- Finding-Scope: contained
- Required change: take every entry the integration branch added to `extensions/drm-copilot/resources/customizations/pack-manifests/core.json` and every other change, minus any path under either `RETIRED-SKILL-TREES` tree; then confirm no pack manifest names `RETIRED-PATH` (`CLR-PACK-MANIFESTS`) and the push-down manifest completeness, closure and contract tests pass (including any test #1049, #1050 or #1051 added for manifests, CI workflows or the integration skill).

### F3 — Re-verify the merged head
- Severity: Blocking
- Remediability: autonomous
- Finding-Scope: contained
- Required change: on the merge head, check any new #1049/#1050/#1051 file for `RETIRED-PATH` (stale-reference classification) and for pins of retired copies; run the guard suite, ledger-chain tests (the integration may have touched ledger records), parity-matrix repo gate, both generator checks, the Codex generator check, and then the three parallel gates once. Record the merge and every resolution under `<FEATURE>/evidence/`.

## Non-Blocking Notes
- Do not force-push. The merge commit message ends with the session attribution lines.
- Orchestrator decisions AD-7 (scope diffs against the integration merge base) and AD-8 (atomic-plan-contract copies form two pre-existing pairs) still apply.
