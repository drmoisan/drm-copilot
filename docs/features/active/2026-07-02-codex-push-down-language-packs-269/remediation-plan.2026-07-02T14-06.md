# Remediation Plan: Codex Push-Down Language Packs (#269)

- Issue: #269
- Feature folder: `docs/features/active/2026-07-02-codex-push-down-language-packs-269`
- Primary requirements source: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/remediation-inputs.2026-07-02T14-06.md`
- Review artifacts:
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/policy-audit.2026-07-02T14-06.md`
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/code-review.2026-07-02T14-06.md`
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/feature-audit.2026-07-02T14-06.md`
- PR context:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`
- Original feature plans:
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/plan.2026-07-02T13-15.md`
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/plan.2026-07-02T13-20.md`
- Work mode: `full-feature`

### Phase 0 — Remediation Baseline

- [x] [P0-T1] Read `AGENTS.md`, `.agents/skills/policy-compliance-order/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/python/SKILL.md`, `.agents/skills/python-suppressions/SKILL.md`, `.agents/skills/typescript/SKILL.md`, and `.agents/skills/typescript-suppressions/SKILL.md`.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/remediation-baseline/phase0-instructions-read.md` with `Timestamp:`, `Policy Order:`, and the explicit file list.
- [x] [P0-T2] Capture the remediation baseline evidence-location validation result by running `python scripts/dev_tools/validate_evidence_locations.py --root .` from the repository root.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/remediation-baseline/evidence-location-validation-baseline.md` with `Timestamp:`, `Command: python scripts/dev_tools/validate_evidence_locations.py --root .`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T3] Capture the remediation baseline changed production file line-count result by measuring changed non-test production files and confirming whether each file is at or below 500 lines.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/remediation-baseline/changed-production-line-count-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing each changed production file measured and any file above 500 lines.
- [x] [P0-T4] Capture the remediation baseline Python targeted test result for Codex pack selection by running `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_pack_selection.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts/dev_tools --cov-report=term-missing` from the repository root.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/remediation-baseline/python-targeted-tests-baseline.md` with `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_push_down_codex_pack_selection.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` including the test result and numeric coverage headline.
- [x] [P0-T5] Capture the remediation baseline TypeScript Jest coverage result by running `npm run test:unit -- --coverage` from `extensions/drm-copilot`.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/remediation-baseline/typescript-jest-coverage-baseline.md` with `Timestamp:`, `Command: npm run test:unit -- --coverage`, `EXIT_CODE:`, and `Output Summary:` including the Jest result and numeric coverage headline.
- [x] [P0-T6] Capture the remediation baseline lcov parse result for `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts` from `extensions/drm-copilot/coverage/lcov.info`.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/remediation-baseline/codex-pack-selection-lcov-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including the numeric line coverage for `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts`.

### Phase 1 — Evidence Location and Plan References

- [x] [P1-T1] Move or recreate `artifacts/research/2026-07-02T13-23-codex-push-down-language-packs-269-research.md` under `docs/features/active/2026-07-02-codex-push-down-language-packs-269/research/` or `docs/research/`, then remove the non-canonical `artifacts/research/` copy.
  - Acceptance: `python scripts/dev_tools/validate_evidence_locations.py --root .` no longer reports the issue #269 research artifact path.
- [x] [P1-T2] Update `docs/features/active/2026-07-02-codex-push-down-language-packs-269/plan.2026-07-02T13-20.md` and any other issue #269 references so research context points to the canonical research path.
  - Acceptance: `Get-ChildItem docs/features/active/2026-07-02-codex-push-down-language-packs-269 -Recurse -File -Exclude remediation-plan.2026-07-02T14-06.md | Select-String 'artifacts/research/2026-07-02T13-23-codex-push-down-language-packs-269-research.md'` returns no matches outside the active remediation plan itself.

### Phase 2 — TypeScript File-Size Remediation

- [x] [P2-T1] Extract repeated MCP push-down schema property builders from `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` into a cohesive helper file under `extensions/drm-copilot/src/`.
  - Acceptance: `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` is at or below 500 lines and the new helper file is at or below 500 lines.
- [x] [P2-T2] Extract a cohesive command-argument section from `extensions/drm-copilot/src/workflow-command-arguments.ts` into a separate helper file while preserving exported behavior and tests.
  - Acceptance: `extensions/drm-copilot/src/workflow-command-arguments.ts` is at or below 500 lines and all new or modified helper files are at or below 500 lines.
- [x] [P2-T3] Run TypeScript format, lint, and typecheck after the extraction.
  - Acceptance: Run the TypeScript loop from `extensions/drm-copilot` in this order: `npm run format`, `npm run lint`, then `npm run typecheck`; if any command fails or changes files, restart the loop from `npm run format`. Write separate artifacts `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/remediation-typescript-format.md`, `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/remediation-typescript-lint.md`, and `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/remediation-typescript-typecheck.md`, each with `Timestamp:`, its exact `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.

### Phase 3 — Public C# Pack Contract and MCP Schema

- [x] [P3-T1] Update Python Codex pack selection so public pack input `csharp` is accepted and combined with `csharp_variant` to select the modern or legacy manifest content.
  - Acceptance: Add or update Python tests proving `--packs core,csharp --csharp-variant legacy` writes legacy C# content to canonical paths and rejects invalid variant combinations before writes.
- [x] [P3-T2] Update TypeScript Codex pack selection, service forwarding, MCP input handling, and VS Code command mapping so public pack input `csharp` plus `csharpVariant` selects exactly one C# variant.
  - Acceptance: Add or update Jest tests proving service, MCP, and VS Code paths accept `csharp` plus the selected variant and preserve workspace-root-only compatibility.
- [x] [P3-T3] Remove Codex-only `packs`, `csharp_variant`, and `memory_mode` fields from the `push_down_copilot_customizations` schemas in both MCP definition files.
  - Acceptance: Jest tests verify Copilot schema remains workspace-root-only and Codex schema retains the optional selection fields.
- [x] [P3-T4] Update issue #269 README/spec/user-story text only as needed to keep the documented public API and tests aligned.
  - Acceptance: The feature docs consistently describe the accepted C# public selector and still use issue number 269.

### Phase 4 — Coverage Completion

- [x] [P4-T1] Add focused Jest tests for uncovered branches in `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts`, including manifest object validation, path entry validation, source prefix validation, missing manifest, unknown pack, empty selection, and C# variant routing.
  - Acceptance: `extensions/drm-copilot/coverage/lcov.info` reports at least 90% line coverage for `src/lib/push-down/codex-pack-selection.ts`.
- [x] [P4-T2] Add Python tests if the public `csharp` selector change creates new Python branches not already covered.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/python-changed-coverage-remediation.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording changed Python coverage at or above 90%, or recording the authorized not-applicable condition that no new Python branches were created by the remediation.

### Phase 5 — Final Python QA

- [x] [P5-T1] Run the full Python QA loop from the repository root: `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, and `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Acceptance: Write one final QA artifact per command under `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/`, each with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.

### Phase 6 — Final TypeScript QA

- [x] [P6-T1] Run the full TypeScript QA loop from `extensions/drm-copilot`: `npm run format`, `npm run lint`, `npm run typecheck`, and `npm run test:unit -- --coverage`.
  - Acceptance: Write one final QA artifact per command under `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/`, each with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.

### Phase 7 — Final Validation and Status Synchronization

- [x] [P7-T1] Re-run evidence-location validation and changed production file line-count validation.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/evidence-location-validation-final.md` with `Timestamp:`, `Command: python scripts/dev_tools/validate_evidence_locations.py --root .`, `EXIT_CODE: 0`, and `Output Summary:`, and write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/changed-production-line-count-final.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` confirming every changed production file is at or below 500 lines.
- [x] [P7-T2] Update acceptance-criteria source checkboxes one at a time only for criteria that remain supported by post-remediation evidence, and leave any unmet criteria unchecked.
  - Acceptance: Because work mode is `full-feature`, use `docs/features/active/2026-07-02-codex-push-down-language-packs-269/spec.md` and `docs/features/active/2026-07-02-codex-push-down-language-packs-269/user-story.md` as the authoritative acceptance-criteria check-off sources; `docs/features/active/2026-07-02-codex-push-down-language-packs-269/issue.md` acceptance criteria are not the full-feature check-off source. Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/issue-updates/ac-status-remediation.2026-07-02T14-06.md` with total, checked, remaining, and itemized remaining criteria from `spec.md` and `user-story.md`.
- [x] [P7-T3] Synchronize original plan status in `plan.2026-07-02T13-20.md` so completed remediation-relevant original tasks remain checked only when evidence exists, and add no non-canonical evidence paths.
  - Acceptance: Plan references are consistent with canonical evidence and research paths.
- [x] [P7-T4] Regenerate or rerun feature review after remediation and validate the new policy-audit, code-review, and feature-audit artifacts through `mcp__drm-copilot__validate_orchestration_artifacts`.
  - Acceptance: The post-remediation review reports `REVIEW_STATUS: PASS` or documents any remaining remediation-required findings with new artifact paths.
