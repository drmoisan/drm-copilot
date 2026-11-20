# Task Check [P1-T1]

Plan: remediation-plan.2026-11-19T12-09.md
Timestamp: 2026-11-19T13-45
Command: see the command table below
EXIT_CODE: 0
Output Summary: the three edited Copilot manifests drop 52 retired-path entries (core 129 to 81, csharp 8 to 6, powershell 8 to 6); remaining-root counts equal the P0-T1 counts (81, 6, 6); zero retired-path matches over all 18 pack manifests; GUARD-SUITE 16 passed, 0 failed; Jest selection 26 passed; PUSH-DOWN-CONTRACT-TESTS 45 passed.

## Changed Files

- `extensions/drm-copilot/resources/customizations/pack-manifests/core.json` (48 entries removed)
- `extensions/drm-copilot/resources/customizations/pack-manifests/csharp.json` (2 entries removed)
- `extensions/drm-copilot/resources/customizations/pack-manifests/powershell.json` (2 entries removed)

Edit route: hand edit (P0-T1 recorded `Generated: no`) through SCRATCH/issue-1032-r1-fixmanifests.ps1, which removes each line naming a path under the retired tree, strips the trailing comma of the new last entry, keeps LF line endings and the trailing newline, and asserts the remaining entries keep their order and that the result parses. `name` and `label` are unchanged. `LEDGER-STEP` not applied (`LedgerRegion: none`).

## Selection and Rule

Rule: the plan's P1-T1 task-check list (changed data files, so the contract tests that read them): the `GUARD-SUITE` file, the Jest files `push-down-bundle-manifest-completeness.test.ts` and `push-down-pack-resolver.test.ts`, and `PUSH-DOWN-CONTRACT-TESTS`; plus a Prettier check of the three JSON files.

## Commands

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| `npx prettier --check` on the three edited manifests | 0 | `All matched files use Prettier code style!` |
| `sh SCRATCH/issue-1032-r1-manifests.sh` (re-inventory) | 0 | core paths 81 / remaining-root 81; csharp 6 / 6; powershell 6 / 6; python 8 / 8; typescript 4 / 4; retired 0 in every manifest |
| `grep -F -c` for `RETIRED-PATH` over `extensions/drm-copilot/resources/*/pack-manifests/*.json` | 1 (no match) | 0 in each of 18 files |
| `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` | 0 | Tests Passed 16, Failed 0 (includes `CLR-PACK-MANIFESTS finds no retired path in any pack manifest`); three earlier attempts exited 75 (queue timeout) |
| `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down/push-down-bundle-manifest-completeness.test.ts test/lib/push-down/push-down-pack-resolver.test.ts` | 0 | Test Suites 2 passed; Tests 26 passed (includes `lists every Copilot bundle file`, `enumerates a non-empty bundle tree`); four earlier attempts exited 75 |
| `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` with the five `PUSH-DOWN-CONTRACT-TESTS` modules, `-q -p no:cacheprovider --no-cov` | 0 | 45 passed; five earlier attempts exited 75 |
