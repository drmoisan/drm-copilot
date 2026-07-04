# Feature Audit: Codex Push-Down Language Packs (#269)

REVIEW_STATUS: REMEDIATION_REQUIRED

**Audit Date:** 2026-07-02
**Feature Folder:** `docs/features/active/2026-07-02-codex-push-down-language-packs-269`
**Base Branch:** `main`
**Head Branch:** `feature/codex-push-down-language-packs-269 @ 8b73e5562048584f1fe3e672339717cda92caee9`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

## Scope and Baseline

- **Base branch:** `main` / `origin/main` at `51867789325248793a241886033c3ce86681f9ad`
- **Head branch/commit:** `feature/codex-push-down-language-packs-269` at `8b73e5562048584f1fe3e672339717cda92caee9`
- **Merge base:** `51867789325248793a241886033c3ce86681f9ad`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/**`
  - Coverage artifacts: `artifacts/python/lcov.info`; `extensions/drm-copilot/coverage/lcov.info`
- **Feature folder used:** `docs/features/active/2026-07-02-codex-push-down-language-packs-269`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` contains `- Work Mode: full-feature`; therefore `spec.md` and `user-story.md` are authoritative.
- **Scope note:** The review scope is the full feature-vs-base diff. No caller-supplied scope narrowing was applied.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-02-codex-push-down-language-packs-269/spec.md`
- `docs/features/active/2026-07-02-codex-push-down-language-packs-269/user-story.md`

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
|---|-----------|--------|----------|--------------------------|-------|
| 1 | No-argument Codex push-down publishes full trees and summary behavior | PASS | Python and TypeScript final QA evidence | `poetry run pytest ...`; `npm run test:unit -- --coverage` | Backward compatibility is preserved. |
| 2 | Explicit pack selection always includes `core` | PASS | Pack-selection tests and coverage | Final Python and TypeScript QA | Core inclusion is tested. |
| 3 | `--packs core,typescript` publishes only core and TypeScript files | PASS | Selected-pack tests | Final Python and TypeScript QA | Non-selected language files are excluded. |
| 4 | Codex pack manifests loaded from bundle and not written to destination | PASS | Resource-contract and filtering tests | Final Python and TypeScript QA | Manifests remain bundle resources. |
| 5 | Bundle-only C# variant roots excluded from destination writes | PASS | Variant-root evidence and tests | Final Python and TypeScript QA | Destination writes use canonical paths. |
| 6 | Selected C# variant writes exactly one C# toolchain | PASS | Public `csharp` plus legacy variant tests | Final Python and TypeScript QA | The public selector contract is aligned. |
| 7 | Invalid pack names, malformed manifests, missing variant sources, both C# variants fail before writes | PASS | Negative selector and manifest tests | Final Python and TypeScript QA | Failures occur before writes. |
| 8 | VS Code prompts for language packs and C# variant only when C# selected | PASS | Command registration tests | `npm run test:unit -- --coverage` | Prompt behavior is covered. |
| 9 | MCP definitions/input resolution accept optional fields and preserve workspace-root-only compatibility | PASS | MCP schema and input tests | `npm run test:unit -- --coverage` | Codex schema retains fields; Copilot schema remains scoped. |
| 10 | Python and TypeScript test coverage proves required behaviors | PASS | Final lcov and QA evidence | Coverage parse and final QA commands | Coverage thresholds are met. |
| 11 | No-argument invocation preserves full-tree behavior | PASS | Same as criterion 1 | Final QA | Supported. |
| 12 | Explicit language pack set includes `core` | PASS | Same as criterion 2 | Final QA | Supported. |
| 13 | TypeScript-only selection excludes Python, PowerShell, C# | PASS | Same as criterion 3 | Final QA | Supported. |
| 14 | C# legacy variant writes legacy content to canonical paths | PASS | Same as criterion 6 | Final QA | Supported. |
| 15 | Destination never receives bundle-only variant roots | PASS | Same as criterion 5 | Final QA | Supported. |
| 16 | Both C# variants rejected before writes | PASS | Mutual-exclusion tests | Final QA | Supported. |
| 17 | VS Code command presents language selection and conditional C# variant prompt | PASS | Same as criterion 8 | Final QA | Supported. |
| 18 | VS Code cancellation stops before service invocation | PASS | Command registration tests | Final QA | Supported. |
| 19 | MCP tool accepts optional fields and workspace-root-only remains valid | PASS | MCP tests | Final QA | Supported. |
| 20 | Tests verify selected-pack, C# routing, invalid failures, compatibility, MCP/service forwarding | PASS | Python and TypeScript test suites | Final QA | Supported. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 20 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Acceptance criteria pass, but PR readiness is blocked by the policy/code-review whitespace finding from `git diff --check`.

**Recommended follow-up verification steps:**

1. Remove the reported trailing whitespace and EOF blank line in the changed Markdown files.
2. Rerun `git diff --check 51867789325248793a241886033c3ce86681f9ad...HEAD`.
3. Rerun MCP validation for the new review artifacts.

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, criteria evaluated as PASS may be checked off. The authoritative source files were already fully checked before this re-audit, and this review did not need to update them.

### AC Status Summary

- Source: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/spec.md`; `docs/features/active/2026-07-02-codex-push-down-language-packs-269/user-story.md`
- Total AC items: 31
- Checked off (delivered): 31
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-02-codex-push-down-language-packs-269/spec.md` | 21 | 21 | 0 | Checkbox-backed full-feature source. |
| `docs/features/active/2026-07-02-codex-push-down-language-packs-269/user-story.md` | 10 | 10 | 0 | Checkbox-backed full-feature source. |
