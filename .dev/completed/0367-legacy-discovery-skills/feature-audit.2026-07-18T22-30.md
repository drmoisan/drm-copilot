# Feature Audit — legacy-discovery-skills (Issue #367) — Cycle 1 Reaudit

- Timestamp: 2026-07-18T22-30
- Branch: `feature/legacy-discovery-skills-367` (HEAD `bb8f8b79`) vs `origin/epic/legacy-discovery-and-parity-integration`
- Work Mode: `full-feature` — AC sources: `spec.md` (AC-1..AC-9) and `user-story.md` (7 ACs)
- Purpose: re-confirm every spec and user-story AC remains satisfied after the Cycle 1 remediation (registration of the seven bundled discovery skills in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`), and confirm the manifest edit introduces no AC regression.

## Cycle 1 Change Recap

Single production file changed: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (7 lines added, 0 removed, commit `bb8f8b79`). No `.claude/skills/discovery-*/SKILL.md` file, no bundle mirror, and no test module changed in this cycle — all AC evidence gathered in the initial-cycle feature audit (`feature-audit.2026-07-18T21-26.md`) for those files remains valid by non-modification, independently re-confirmed below via byte-identity and re-run checks rather than assumed.

## spec.md Acceptance Criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 (seven skills sequence the workflow in stage order) | PASS (unaffected) | Seven `.claude/skills/discovery-*/SKILL.md` files unchanged by Cycle 1 (not present in `bb8f8b79` diff). Re-verified via `poetry run pytest tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py -q`: all `test_skill_file_exists` cases pass. |
| AC-2 (frontmatter contract; plain-name references; body-level Worker Routing) | PASS (unaffected) | Test module unchanged; re-run confirms `test_skill_frontmatter_name_matches_folder`, `test_skill_has_nonempty_single_quoted_description`, `test_worker_routing_pairing_present` still pass (0 failures in the 67-test re-run). |
| AC-3 (no name collision) | PASS (unaffected) | `.claude/skills/` folder set is unchanged by Cycle 1 (only a manifest JSON file changed, not a `.claude/skills/` directory). `test_skill_name_does_not_collide_with_code_modernization` re-run passes (7 cases). |
| AC-4 (banned substrings absent; no literal stack-specific analyzer; runtime domain specificity) | PASS (unaffected) | `core.json` introduces only file-path string literals (`.claude/skills/discovery-*/SKILL.md`), containing none of the banned substrings and no prose. Skill file content is unchanged (byte-identity check below). `test_banned_substrings_absent` re-run passes. |
| AC-5 (upstream references isolated; assumptions flagged; no upstream existence assertions) | PASS (unaffected) | `discovery-workflow/SKILL.md` registry unchanged by Cycle 1. `test_umbrella_registry_and_fan_in_flags_present` re-run passes. |
| AC-6 (contract test module exists and passes, asserting only on own files) | PASS (unaffected) | `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` unchanged by Cycle 1 (not in `bb8f8b79` diff). Re-run: 67 passed (60 module-specific + 7 push-down parity), 0 failed, exit 0. |
| AC-7 (byte-identical bundle mirrors; push-down gate passes) | PASS (re-verified, directly relevant to Cycle 1) | `cmp` of all 7 skill/mirror pairs, independently re-run in this reaudit: all 7 IDENTICAL. `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` (subset of the 67-test re-run): all 7 push-down parity tests pass. The Cycle 1 manifest edit does not touch any `.claude/skills/discovery-*` file or its mirror, so byte-identity is preserved by construction and confirmed empirically. |
| AC-8 (scope clarification recorded in spec) | PASS (unaffected) | `spec.md` Scope Clarification 1 unchanged by Cycle 1; still records the byte-copy as in-feature and broader `resources/` publishing (including pack-manifest curation for other packs) as #9012. The Cycle 1 fix registers the already-in-scope bundle copies in the `core.json` pack manifest to satisfy the always-on extension completeness test; it does not expand scope into #9012's broader publishing work (no other pack manifest, no converter registration, no `.github`/`.agents` mirror was touched). |
| AC-9 (500-line cap; toolchain passes; no coverage reduction) | PASS (re-verified) | `core.json` is a data file, not subject to the 500-line cap (cap applies to production/test code files per `general-code-change.md`); it remains well under any practical concern. Python toolchain re-run in this reaudit: Black check exit 0, Ruff exit 0, Pyright 0 errors, Pytest exit 0 (67 passed). No Python production or test file changed in Cycle 1, so the coverage figures reported in the initial audit (line 88.87%, branch 87.28%, delta 0.00 pp) are unaffected and carry forward unchanged. |

## Extension Test Suite (not a numbered spec AC, but the Cycle 1 trigger and a repository-required check)

- The jest suite `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, which asserts every bundled `.claude` skill/agent/hook file is listed in at least one `pack-manifests/*.json`, is not one of spec.md's AC-1..AC-9 (those cover the Python push-down parity gate, AC-7, but not the TypeScript/jest pack-manifest completeness gate). It is nonetheless the required CI check that failed on PR #381 (`Extension Tests (ubuntu-latest)`).
- Independently re-verified in this reaudit: targeted `--testMatch` re-run — `Tests: 7 passed, 7 total`, `missing` empty; full-suite `--testMatch` re-run — `Test Suites: 158 passed, 158 total`, `Tests: 1886 passed, 1886 total`, 0 failed (matches the pre-remediation `1886` total from the P0-T2 baseline with the single failure resolved, confirming no regression elsewhere in the suite).
- The literal `npm test -- <file>` invocation still exits non-zero in this specific worktree due to an independently-reproduced, pre-existing Jest-on-Windows glob-escaping defect tied to the dot-prefixed `.claude` checkout-path segment (`docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-jest-pack-manifest-completeness.2026-07-18T21-40.md`). This is treated as an environment artifact, not a feature defect, per task instruction; the authoritative signal is the `ubuntu-latest` CI run and the `--testMatch` workaround, both of which are green.

## user-story.md Acceptance Criteria

| AC | Verdict | Evidence |
|---|---|---|
| US-1 (full workflow sequenced by the seven skills, no hand-orchestration) | PASS (unaffected) | Same evidence as spec AC-1; skill content unchanged by Cycle 1. |
| US-2 (SKILL.md conventions; routing by slug; names referenced) | PASS (unaffected) | Same evidence as spec AC-2. |
| US-3 (no collision with plugin commands/agents or existing skills) | PASS (unaffected) | Same evidence as spec AC-3. |
| US-4 (domain-neutral; no literal stack analyzer; runtime profile) | PASS (unaffected) | Same evidence as spec AC-4. |
| US-5 (upstream names isolated in registry with flagged assumptions) | PASS (unaffected) | Same evidence as spec AC-5. |
| US-6 (structural checks pass, asserting only on own files) | PASS (unaffected) | Same evidence as spec AC-6. |
| US-7 (push-down parity gate passes) | PASS (re-verified) | Same evidence as spec AC-7; additionally, the Cycle 1 fix directly restores the sibling extension-side completeness gate that the push-down parity gate does not itself cover, closing the CI-visible gap that motivated this remediation cycle. |

## Regression Check

No spec.md or user-story.md acceptance criterion is weakened, narrowed, or newly failing as a result of the Cycle 1 `core.json` edit. The edit is strictly additive (7 new array entries), touches no skill content, no bundle mirror, and no test module, and both required Python gates (push-down parity, legacy-discovery-skills contracts) plus the previously-failing jest completeness gate are independently confirmed green in this reaudit.

## Check-Off Actions

All 9 spec ACs and all 7 user-story ACs were already checked (`[x]`) in the source files prior to this reaudit (confirmed by reading current `spec.md` and `user-story.md`). Every AC evaluated PASS above; no check-off edit was required and none was made. No unchecked AC remains.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-07-17-legacy-discovery-skills-367/spec.md`, `docs/features/active/2026-07-17-legacy-discovery-skills-367/user-story.md`
- Total AC items: 16 (9 spec + 7 user-story)
- Checked off (delivered): 16
- Remaining (unchecked): 0
- Items remaining: none

## Blocking Findings

Blocking findings count: 0
