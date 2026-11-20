# legacy-discovery-publishing (Issue #372)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/legacy-discovery-publishing/ (Issue #372)
- Epic: legacy-discovery-and-parity (child; manifest placeholder issue 9012)

- Issue: #372
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/372
- Last Updated: 2026-07-17
- Work Mode: full-feature

## Problem / Why

The legacy-discovery-and-parity epic adds new customization assets (agent personas,
skills, hooks, schemas, templates) under the repository-root native trees (`.claude/`,
`.github/`, `.codex/`+`.agents/`). The repository enforces byte-identical mirrors of
those trees under `extensions/drm-copilot/resources/` via push-down contract tests
(`test_push_down_claude_resource_contracts.py` and the Codex analogue). Any new asset
that is not mirrored breaks those contract tests, and consumer repositories (TaskMaster,
TMW) do not receive the discovery capability through the existing push-down tooling.

This feature makes the discovery assets shippable. It does not re-author the assets being
mirrored; it mirrors them, decides Codex-native converter registration, and selects the
push-down pack manifest.

## Proposed Behavior

- Mirror every new customization asset added by the epic (agent personas from
  legacy-discovery-agent-roles, skills from legacy-discovery-skills, hooks from
  legacy-discovery-hooks, schemas from legacy-discovery-schemas, templates from
  legacy-discovery-init-templates) into the matching `resources/` mirror subtrees so the
  push-down contract tests pass byte-identically.
- Determine whether the new skill/agent categories require registration in the
  Codex-native converter (`scripts/dev_tools/codex_native_converter/mapping.py`,
  `classifier.py`) or whether mirroring is purely structural, and document the
  determination in `spec.md`.
- Select the appropriate push-down pack manifest (`core` always-pushed vs a
  language-neutral pack) so consumers receive the discovery capability, and justify the
  choice.
- Extend/align the push-down contract tests (Python and the TypeScript twins) that enforce
  byte-identical `resources/` mirrors.

## Acceptance Criteria (early draft)

- [ ] Every new epic customization asset under `.claude/`, `.github/`, `.codex/`+`.agents/`
      is mirrored byte-identically into the matching `resources/` subtree.
- [ ] Push-down contract tests (Python + TS twins) pass with the mirrored assets present.
- [ ] The Codex-native converter registration determination is documented and, if required,
      implemented in `mapping.py`/`classifier.py`.
- [ ] The push-down pack-manifest placement is selected and justified.

## Constraints & Risks

- Domain neutrality: publishing mirrors generic discovery assets; no
  TaskMaster/TMW/Outlook/VSTO/email/task-management-specific behavior.
- Depends on upstream epic children (schemas, hooks, init-templates, agent-roles, skills)
  being merged into the epic integration branch before execution.
- Byte-identical mirror requirement: any drift fails the contract tests.

## Test Conditions to Consider

- [ ] Python push-down contract tests over `.claude/**`, `.github/**`, `.codex/**`+`.agents/**`.
- [ ] TypeScript twin push-down tests.
- [ ] Codex converter classifier/mapping tests if categories are registered.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/legacy-discovery-publishing/` folder from the template
