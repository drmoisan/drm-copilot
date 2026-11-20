# Remediation Plan — Cycle 1 (Issue #367)

- Feature: `legacy-discovery-skills` (issue #367)
- Remediation inputs: `docs/features/active/2026-07-17-legacy-discovery-skills-367/remediation-inputs.2026-07-18T21-40.md`
- Single blocking finding: the seven new bundled discovery skills are not registered in
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, causing
  `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` to fail.
- Scope: exactly one production file changes (`core.json`). No `.claude`-source change is
  required; the seven skills and their bundle copies already exist.

## Evidence Location

All evidence artifacts for this remediation cycle are written under
`docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/<kind>/` using
ISO-8601 `yyyy-MM-ddTHH-mm` timestamps. No `artifacts/` path is used for evidence.

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read repository policy files in the order defined by the `policy-compliance-order`
      skill — `CLAUDE.md`, `.claude/rules/general-code-change.md`,
      `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`,
      `.claude/rules/python.md`, `.claude/rules/tonality.md` — and record the reading evidence.
      Acceptance: file
      `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/remediation-baseline/phase0-instructions-read.2026-07-18T21-40.md`
      exists and contains `Timestamp:`, `Policy Order:`, and an explicit numbered list of the six
      files read in the stated order.

- [x] [P0-T2] [expect-fail] Capture the pre-fix baseline of the jest pack-manifest completeness
      suite by running, from `extensions/drm-copilot`,
      `npm test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
      Acceptance: file
      `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/remediation-baseline/baseline-jest-pack-manifest-completeness.2026-07-18T21-40.md`
      exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:` recording a non-zero exit code,
      and `Output Summary:` reporting the `missing` array containing the seven
      `.claude/skills/discovery-*/SKILL.md` paths and the `1 failed, 1885 passed, 1886 total`
      signature (or the current equivalent counts observed at run time).

- [x] [P0-T3] Capture the pre-fix baseline of the Python push-down parity and
      legacy-discovery-skills contract tests by running
      `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`.
      Acceptance: file
      `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/remediation-baseline/baseline-python-push-down-parity.2026-07-18T21-40.md`
      exists and contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`
      reporting the pass count with zero failures.

### Phase 1 — Manifest Registration

- [x] [P1-T1] Add the seven bundled discovery-skill paths to the `paths` array of
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`,
      inserted in alphabetical order immediately after
      `".claude/skills/commit-message/SKILL.md"` and immediately before
      `".claude/skills/epic-orchestrate/SKILL.md"`:
      `.claude/skills/discovery-behavior-reconciliation/SKILL.md`,
      `.claude/skills/discovery-coverage-ledger/SKILL.md`,
      `.claude/skills/discovery-parity-matrix/SKILL.md`,
      `.claude/skills/discovery-repo-inventory/SKILL.md`,
      `.claude/skills/discovery-runtime-characterization/SKILL.md`,
      `.claude/skills/discovery-validate-artifacts/SKILL.md`,
      `.claude/skills/discovery-workflow/SKILL.md`.
      Acceptance: `core.json` parses as valid JSON; the `paths` array contains, contiguously and
      in this exact order, the seven new entries between the existing
      `.claude/skills/commit-message/SKILL.md` and `.claude/skills/epic-orchestrate/SKILL.md`
      entries; no other line in the file is changed; this is the only file modified by this
      remediation cycle.

### Phase 2 — Final QC

- [x] [P2-T1] Re-run the Python push-down parity and legacy-discovery-skills contract tests
      after the manifest edit: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`.
      Acceptance: file
      `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-python-push-down-parity.2026-07-18T21-40.md`
      exists and contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`
      reporting the pass count with zero failures, at or above the P0-T3 baseline pass count.

- [x] [P2-T2] Re-run the previously failing jest pack-manifest completeness suite after the
      manifest edit, from `extensions/drm-copilot`:
      `npm test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
      Acceptance: file
      `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-jest-pack-manifest-completeness.2026-07-18T21-40.md`
      exists and contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`
      confirming `missing` is empty and all suite tests pass (1886 total, 0 failed, matching the
      pre-remediation total from P0-T2 with the single failure resolved). `EXIT_CODE: SKIPPED`
      is not a valid outcome for this task.
