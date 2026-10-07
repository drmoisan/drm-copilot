# Issue acceptance-criteria check-off (P5-T20)

Timestamp: 2026-09-30T08-00
Command 1: git grep --no-index -c -F -e "- [x]" -- docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/issue.md
EXIT_CODE: 0
Output Summary: `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/issue.md:5`

Command 2: git grep --no-index -c -F -e "- [ ]" -- docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/issue.md
EXIT_CODE: 1 (git grep no-match status; the Bash tool reported "completed with no output")
Output Summary: empty output. No unchecked criterion remains.

Each criterion was changed with a single-line Edit that altered only the checkbox. Criteria and backing artifacts (under `docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/`):
1. Resolver in the routing validator: regression-testing/ts-resolver-unit-tests.2026-09-30T07-37.md, regression-testing/ts-single-resolution.2026-09-30T07-39.md.
2. Bug-type large-route pass: regression-testing/ts-regression-pass-after.2026-09-30T07-37.md.
3. Feature-type large-route no regression: regression-testing/ts-regression-pass-after.2026-09-30T07-37.md, regression-testing/ts-validate-dir-pass-after.2026-09-30T07-39.md.
4. New TypeScript tests for both cases plus dead-skill and bug-with-only-feature-tool rejection: regression-testing/ts-routing-contract-expect-fail.2026-09-30T07-35.md, regression-testing/ts-regression-pass-after.2026-09-30T07-37.md.
5. Full toolchain with no coverage regression: qa-gates/ts-coverage-delta, py-coverage-delta, ps-coverage-delta (2026-09-30T07-56) and the P5-T1 to P5-T13 artifacts. The full Pester run carries the same two pre-existing baseline failures and no new one.
