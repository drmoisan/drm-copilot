# Acceptance criteria check-off (P3-T5)

Timestamp: 2026-11-24T14-55
Command: sed check-off of the checkbox lines under `## Acceptance Criteria` of spec.md and `## Acceptance Criteria` of user-story.md, after each criterion's evidence passed
EXIT_CODE: 0
Output Summary: spec.md AC-1 to AC-13 checked (13 of 13); user-story.md 8 of 8 checked. The remaining 10 unchecked boxes in spec.md are the Definition of Done (7) and Seeded Test Conditions (3) lists, which are not acceptance criteria and are left unchanged. No CI-dependent acceptance criterion exists, so the pending-CI list is empty; the CI run on the pull request head is pending.

| AC | Evidence |
|---|---|
| AC-1 Placement | EpicRouting suite, It 'places ## Epic-Scale Routing once...' 4 of 4 rows pass (qa-gates/final-qc-pester.2026-11-24T14-33.md) |
| AC-2 Routing condition | It 'states the routing condition and the page threshold' 4 of 4 pass |
| AC-3 Wave order | It 'lists the waves in order with each family id in its own wave segment' 4 of 4 pass |
| AC-4 Ownership | It 'states ownership and omits family-record field names' 4 of 4 pass |
| AC-5 Dispatch | It 'states the dispatch rule' 4 of 4 pass |
| AC-6 Receipt | It 'states the receipt rule' 4 of 4 pass |
| AC-7 Qualifications | It 'qualifies the single-run statements' 4 of 4 pass |
| AC-8 Standard | It 'states the epic standard behavior' 2 of 2 pass; other/standard-contract.2026-11-24T13-35.md VIOLATION_COUNT=0 |
| AC-9 Contract test | suite exists (207 lines), runs in the parallel Pester gate, creates no temp file, reads no clock, defines the threshold once in DefaultPageThreshold, removes its four helpers in AfterAll (file inspection plus gate pass) |
| AC-10 Generator parity | qa-gates/generator.2026-11-24T13-40.md and qa-gates/final-qc-parity.2026-11-24T14-50.md (-Check exit 0; substitutions file unchanged) |
| AC-11 Bundle contracts | qa-gates/final-qc-pytest.2026-11-24T14-45.md (17104 passed); other/bundle-parity.2026-11-24T13-40.md |
| AC-12 Brief listing | It 'lists this suite in ## Contract Tests That Pin Mirrored Files' 4 of 4 pass; brief contract test and copilot-layer-retirement pass |
| AC-13 Scope guard | qa-gates/final-qc-parity.2026-11-24T14-50.md |
