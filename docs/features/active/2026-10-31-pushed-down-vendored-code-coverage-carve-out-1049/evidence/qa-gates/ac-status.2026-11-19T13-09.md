# Acceptance Criteria Status - [P4-T8]

Timestamp: 2026-11-19T13-09
Command: per-item check-off in spec.md (`## Acceptance Criteria`) and user-story.md (`## Acceptance Criteria`) against the evidence named in `## AC Mapping` of the plan; git diff --stat HEAD on both files (25 lines changed, checkbox marks only)
EXIT_CODE: 0
Output Summary: Work mode full-feature; AC sources spec.md and user-story.md. 15 of 15 spec items and 10 of 10 user-story items verified and checked off. No item depends on a CI result by its text, so no item is held as pending-CI; the PR head CI (`CI Required Gate`, and for the Pester and Jest suites `poshqc / PowerShell QC` and `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` and `(windows-latest)`) remains the orchestrator's S9 confirmation.

## spec.md

| ID | Status | Evidence |
| --- | --- | --- |
| S1 | PASS, checked | evidence/qa-gates/rules-generation.2026-11-19T11-36.md (`-Surface rules -Check` exit 0); repo-gate cases `every general-unit-test copy carries the vendored push-down paragraph` (7 copies) in evidence/qa-gates/final-pester.2026-11-19T13-05.md; evidence/qa-gates/phase-gate.P3.2026-11-19T12-39.md |
| S2 | PASS, checked | evidence/qa-gates/final-pytest.2026-11-19T12-52.md (test_push_down_tier_rule_adoption_gate.py and test_push_down_issue_824_follow_ups.py pass and are unmodified); repo-gate case `no general-unit-test copy says not used in this repository` |
| S3 | PASS, checked | `records for every files entry the sha256 of the bytes now at that path` and `classifies the four arranged files as create, update, adopt and converged` (push-down-apply-hash-invariant.test.ts) in evidence/qa-gates/final-jest.2026-11-19T13-07.md |
| S4 | PASS, checked | evidence/other/corpus-digests.2026-11-19T09-19.md; `hashPayloadText matches the corpus digest for <name>` (Jest, final-jest) and `produces the corpus digest for <Name>` (Pester, final-pester); no temporary file in either |
| S5 | PASS, checked | `reports exempt ...`, `reports modified when the hash differs`, `reports modified for a reparse point`, `reports missing ...`, `reports unlisted ...`, `reports a case-renamed file unlisted` (PoshQC.VendoredCoverage.Tests.ps1) in final-pester |
| S6 | PASS, checked | `throws naming .push-down-manifest.json for <Case>` (malformed JSON, unknown major, absolute, drive-letter, UNC, `..`, bad sha256), `accepts a known major with a higher minor schema_version`, `stops before Pester when the resolver throws for an invalid manifest`, `logs one warning and exempts nothing when the manifest is absent` in final-pester |
| S7 | PASS, checked | `subtracts exempt paths for the config source with the opt-in`, `keeps the population for the config source without the opt-in`, `ignores the opt-in for the settings source and never calls the exemption seam`, `ignores the opt-in for the fallback source`, `default writer seams create the directory and write only the report file` in final-pester |
| S8 | PASS, checked | `reports a destination-added .claude/hooks file unlisted`; `keeps a destination-added .claude/hooks file in the population` in final-pester |
| S9 | PASS, checked | `renders sorted report JSON without timestamps or absolute paths`, `writes the report beside the coverage output file for <Case>`, `passes the exemptions and the effective coverage output path to the report seam` in final-pester |
| S10 | PASS, checked | `every general-unit-test copy carries both Blocking enforcement clauses`, `feature-review coverage step names the exemption report`, `feature-review coverage step carries both Blocking clauses` in final-pester; rules-generation (agents check exit 0) |
| S11 | PASS, checked | `README states the ownership policy` (both README copies) and the paragraph test in final-pester |
| S12 | PASS, checked | `repository coverage configuration does not declare exempt_unchanged_push_down_files`; `repository root has no .push-down-manifest.json` in final-pester |
| S13 | PASS, checked | evidence/qa-gates/brief-update.2026-11-19T11-36.md (six copies, one hash); `every brief copy names the vendored push-down exception` (final-pester); test_brief_copies_are_byte_identical (final-pytest) |
| S14 | PASS, checked | evidence/qa-gates/poshqc-bundle-copy.2026-11-19T11-01.md; test_poshqc_bundled_module_files_match_repo_root_sources, test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py in final-pytest |
| S15 | PASS, checked | evidence/qa-gates/coverage-delta-powershell.2026-11-19T13-06.md (each changed PowerShell file at least 85% with no drop; changed-line coverage 100% for modified files, 99.09% for the new file); final-jest (no TypeScript production file changed) |

## user-story.md

| ID | Status | Evidence |
| --- | --- | --- |
| U1 | PASS, checked | as S1 |
| U2 | PASS, checked | as S3 (final-jest) |
| U3 | PASS, checked | `reports modified when the hash differs`; `keeps modified and unlisted files in the population` (final-pester) |
| U4 | PASS, checked | as S8 |
| U5 | PASS, checked | `returns the opt-in for <Case>`; `throws for a non-boolean opt-in` (final-pester) |
| U6 | PASS, checked | as S6 |
| U7 | PASS, checked | as S9 |
| U8 | PASS, checked | as S10 |
| U9 | PASS, checked | as S11 |
| U10 | PASS, checked | as S12 |

### Acceptance Criteria Status
- Source: docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/spec.md; docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/user-story.md
- Total AC items: 25 (spec.md 15, user-story.md 10)
- Checked off (delivered): 25
- Remaining (unchecked): 0
- Items remaining: none
- Pending-CI items: none
