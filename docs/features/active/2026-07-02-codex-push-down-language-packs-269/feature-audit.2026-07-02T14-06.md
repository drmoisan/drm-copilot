# Feature Audit: Codex Push-Down Language Packs (#269)

**Audit Date:** 2026-07-02
**Feature Folder:** `docs/features/active/2026-07-02-codex-push-down-language-packs-269`
**Base Branch:** `main`
**Head Branch:** `feature/codex-push-down-language-packs-269`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

## Scope and Baseline

- **Base branch:** `main` / `origin/main` at `51867789325248793a241886033c3ce86681f9ad`
- **Head branch/commit:** `feature/codex-push-down-language-packs-269` at `4fd8353e7997b51f20942d4de11bc2ec28d24537`
- **Merge base:** `51867789325248793a241886033c3ce86681f9ad`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/**`
  - Coverage artifacts: `artifacts/python/lcov.info`; `extensions/drm-copilot/coverage/lcov.info`
- **Feature folder used:** `docs/features/active/2026-07-02-codex-push-down-language-packs-269`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` declares `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are authoritative acceptance-criteria sources.
- **Scope note:** The audit covers the full branch diff against the resolved merge base. GitHub CLI and CI status are unavailable in the PR context.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-02-codex-push-down-language-packs-269/spec.md` - primary full-feature source
- `docs/features/active/2026-07-02-codex-push-down-language-packs-269/user-story.md` - primary full-feature source

### From `spec.md`

1. No-argument Codex push-down publishes the complete `.codex` and `.agents` trees and preserves current summary artifact behavior.
2. Explicit pack selection always includes `core`.
3. `--packs core,typescript` publishes only `core` and TypeScript pack files.
4. Codex pack manifests are loaded from the Codex bundle and are not written to the destination.
5. Bundle-only C# variant roots are excluded from default root enumeration and from destination writes.
6. The selected C# variant writes exactly one toolchain to canonical `.agents` and `.codex` C# destination paths.
7. Invalid pack names, malformed manifests, missing variant sources, and selection of both C# variants fail before writes.
8. VS Code Codex push-down prompts for language packs and conditionally prompts for a C# variant only when C# is selected.
9. MCP definitions and input resolution accept optional `packs`, `csharp_variant`, and `memory_mode` while preserving workspace-root-only compatibility.
10. Python and TypeScript test coverage proves backward compatibility, selected-pack behavior, C# variant routing, schema parity, and cancellation behavior.

### From `user-story.md`

11. A no-argument Codex push-down invocation continues to publish the complete `.codex` and `.agents` trees and preserves existing summary artifact behavior.
12. When the user selects any explicit language pack set, the system includes `core` automatically.
13. When the user selects TypeScript only, the destination receives `core` and TypeScript pack files and does not receive Python, PowerShell, or C# pack files.
14. When the user selects C# with the legacy variant, legacy C# content is written to canonical `.agents` and `.codex` C# destination paths.
15. The destination never receives bundle-only Codex variant roots such as `.agents-variants/**` or `.codex-variants/**`.
16. The system rejects a request that would select both C# variants before writing any destination files.
17. The VS Code Codex push-down flow presents language-pack selection and prompts for a C# variant only when C# is selected.
18. Cancelling any VS Code selection step stops the operation before the push-down service is invoked.
19. The MCP tool accepts optional `packs`, `csharp_variant`, and `memory_mode` fields, and an invocation with only `workspace_root` remains valid.
20. Python and TypeScript tests verify the selected-pack behavior, C# variant routing, invalid-selection failures, no-argument compatibility, and MCP or service input forwarding.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| 1 | No-argument Codex push-down publishes full trees and summary behavior | PASS | Python and TypeScript no-argument tests; final QA evidence | `poetry run pytest --cov=...`; `npm run test:unit -- --coverage` | Evidence supports backward compatibility. |
| 2 | Explicit pack selection always includes `core` | PASS | Pack-selection tests in Python and TypeScript | Same final QA commands | Core inclusion is tested. |
| 3 | `--packs core,typescript` publishes only core and TypeScript files | PASS | Selected TypeScript tests verify Python, PowerShell, and C# exclusions | Same final QA commands | Requirement uses `typescript`, which is accepted. |
| 4 | Codex pack manifests loaded from bundle and not written to destination | PASS | Resource contract tests and selected-pack tests | `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`; final QA | Manifests are under the bundle path and excluded from destination writes. |
| 5 | Bundle-only C# variant roots are excluded from root enumeration and destination writes | PASS | `codex-variant-roots-exclusion.md`; Python and TypeScript selected C# tests | Final QA and resource-contract test | Variant roots are tested as excluded. |
| 6 | Selected C# variant writes exactly one C# toolchain to canonical paths | PARTIAL | Tests pass for `csharp-legacy` pack input and `csharp_variant=legacy`; spec documents `csharp` pack plus variant | Final QA; inspected selector constants | The documented public selector is inconsistent with implementation. |
| 7 | Invalid pack names, malformed manifests, missing variant sources, both C# variants fail before writes | PASS | Negative tests for manifests, unknown packs, and both variants | Final QA | Covered for implemented pack naming. |
| 8 | VS Code prompts for language packs and C# variant only when C# selected | PASS | `repo-automation-command-registration-admin.test.ts` | `npm run test:unit -- --coverage` | Prompt and cancellation behavior are covered. |
| 9 | MCP definitions/input resolution accept optional fields while preserving workspace-root-only compatibility | PARTIAL | Codex MCP tests pass, but Copilot MCP schemas were also changed with Codex-only fields | `npm run test:unit -- --coverage`; diff inspection | Codex behavior is covered; adjacent Copilot schema expansion is a contract risk. |
| 10 | Python and TypeScript test coverage proves required behaviors | PARTIAL | Final QA passes, but TypeScript new file coverage is 85.43% and documented `csharp` public selector lacks coverage | lcov parsing and final QA | New-file coverage threshold and documented C# selector remain gaps. |
| 11 | No-argument invocation preserves full-tree behavior | PASS | Same as criterion 1 | Final QA | Duplicates spec criterion with user-story wording. |
| 12 | Explicit language pack set includes `core` | PASS | Same as criterion 2 | Final QA | Duplicates spec criterion with user-story wording. |
| 13 | TypeScript-only selection excludes Python, PowerShell, C# | PASS | Same as criterion 3 | Final QA | Duplicates spec criterion with user-story wording. |
| 14 | C# legacy variant writes legacy content to canonical paths | PARTIAL | Works when tests pass `csharp-legacy`; public story says user selects C# with legacy variant | Final QA and selector inspection | Needs `csharp` plus variant alignment or requirement revision. |
| 15 | Destination never receives bundle-only variant roots | PASS | Same as criterion 5 | Final QA | Supported by tests and evidence. |
| 16 | Both C# variants rejected before writes | PASS | Python and TypeScript mutual-exclusion tests | Final QA | Covered. |
| 17 | VS Code command presents language selection and conditional C# variant prompt | PASS | Same as criterion 8 | Final QA | Covered. |
| 18 | VS Code cancellation stops before service invocation | PASS | Command registration tests | `npm run test:unit -- --coverage` | Covered. |
| 19 | MCP tool accepts optional fields and workspace-root-only remains valid | PARTIAL | Codex MCP tests pass; Copilot MCP schema is unintentionally expanded | Final QA and diff inspection | Needs cleanup of adjacent Copilot schema. |
| 20 | Tests verify selected-pack, C# routing, invalid failures, compatibility, MCP/service forwarding | PARTIAL | Broad tests exist; documented C# selector and TypeScript new-file coverage remain gaps | Final QA, lcov parsing, diff inspection | Requires additional tests and/or API alignment. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 6 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. The documented C# public selector `--packs core,csharp --csharp-variant legacy` is not accepted by the implementation, which expects `csharp-legacy`.
2. TypeScript new-file coverage for `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts` is 85.43%, below the 90% new-file threshold.
3. Policy findings outside AC evaluation remain unresolved: evidence-location validator failure, file-size violations, and Copilot MCP schema expansion.

**Recommended follow-up verification steps:**

1. Add or adjust Python and TypeScript tests to verify `csharp` plus `csharp_variant` public selection across CLI/service/MCP paths.
2. Re-run Python and TypeScript full QA after remediation and update canonical evidence under the feature folder.
3. Re-run `python scripts/dev_tools/validate_evidence_locations.py --root .` and line-count checks before re-review.

## Acceptance Criteria Check-off

Per acceptance-criteria tracking, criteria already checked off in `spec.md` and `user-story.md` remain unchanged during this review. No new source-file check-off was made because several criteria are evaluated as PARTIAL.

### AC Status Summary

- Source: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/spec.md`; `docs/features/active/2026-07-02-codex-push-down-language-packs-269/user-story.md`
- Total AC items: 20
- Checked off (delivered): 20 in source files before this review
- Remaining (unchecked): 0 in source files
- Items remaining: None in source files; six reviewed criteria require remediation despite existing checked boxes.

| Source File | Total AC | Checked (PASS in source) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `docs/features/active/2026-07-02-codex-push-down-language-packs-269/spec.md` | 10 | 10 | 0 | Checkbox-backed; review evaluated 3 criteria as PARTIAL. |
| `docs/features/active/2026-07-02-codex-push-down-language-packs-269/user-story.md` | 10 | 10 | 0 | Checkbox-backed; review evaluated 3 criteria as PARTIAL. |
