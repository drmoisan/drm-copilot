# Remediation Inputs — Issue 1130

Timestamp: 2026-11-08T15-30
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Remediation-Mode: light
Source review artifacts:
- `docs/features/active/2026-11-08-epic-child-pr-merges-without-ci-1130/policy-audit.2026-11-08T15-30.md`
- `docs/features/active/2026-11-08-epic-child-pr-merges-without-ci-1130/code-review.2026-11-08T15-30.md`
- `docs/features/active/2026-11-08-epic-child-pr-merges-without-ci-1130/feature-audit.2026-11-08T15-30.md`
Head reviewed: `03d222c55e3724bbd1d92db549e0017d02c306be` (merge base `cdcff3871765396183590128e142a929cf78327b`)
Prior cycle: none (first review).

## Findings requiring remediation

### F1 — The Codex `ci-workflows` skill carrying the `epic/**` trigger requirement is not pushed down

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix adds one path to a pack manifest that is already in the branch diff and removes the same path from an exception set in an existing test; it needs no external party, owner decision, or CI result.
Finding-Scope: contained

- Files: `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`; `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` (`PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS`).
- Problem: `.agents/skills/ci-workflows/SKILL.md` and its bundle copy now carry section `## Epic Integration-Branch Trigger (Required When Epic Branches Are Used)`, which requires `epic/**` in the `CI` workflow trigger and states that destinations receive the rule through push-down. The file is in no Codex pack manifest, and `compute_published_paths()` publishes only manifest-listed files, so a push-down refresh never delivers it. The statement is inaccurate for Codex destinations, and spec criterion AC13 is only partly met.
- Required change: add `".agents/skills/ci-workflows/SKILL.md"` to the `paths` array of the Codex `core.json` beside the other `.agents/skills/*` entries (alphabetical position), and remove `".agents/skills/ci-workflows/SKILL.md"` from `PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS`. Do not edit the skill text.
- Verification required: Black, Ruff, and Pyright on the edited Python test file; one `pytest -n auto` run with 0 failures, including the Codex manifest-completeness, dependency-closure, bundle-parity, and `test_ci_gate_epic_child_contracts.py` tests; then mark AC13 in `spec.md` as checked (checkbox only, text unchanged), which this review unchecked because of this finding.

## Light Fix Tasks

- [x] [P0-T1] `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` (F1): register `.agents/skills/ci-workflows/SKILL.md` in the Codex `core.json` and remove it from `PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS`, run the Python toolchain and one `pytest -n auto` run, and re-check spec AC13.

## Non-remediation items (record only)

- CR2, Minor: the Codex child branch denies a mismatched explicit PR number at stage 1 instead of falling through, unlike the Claude gate; spec-directed and fail-closed.
- CR3, Minor: the assumption that `gh pr checks` lists `workflow_dispatch` check runs on the PR head is unconfirmed; failure would stall S9, not weaken the gate.
- CR4 and CR5, Nit: entry-level mocks in some existing suites (plan-sanctioned); no Codex load-failure row for the new helper.
- CI on the PR head is pending-CI and owned by the orchestrator at S9; no PR exists yet. It is not a finding.

## Constraints

- Tests run in parallel only: one `pytest -n auto` run.
- Tests create no files.
- Edit only the two named files and the AC13 checkbox in `spec.md`.
- Any commit makes this review stale, so a re-review follows.
