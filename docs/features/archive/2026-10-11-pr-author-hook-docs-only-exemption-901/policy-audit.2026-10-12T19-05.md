# Policy Audit: pr-author hook docs-only exemption (#901)

- Branch: `bug/pr-author-hook-docs-only-exemption-901`
- HEAD: `bdbf8851e8e2e880f37d4d98fc5d075fcc10e68d`
- Base: `origin/main` at `7d9a5c33526d7a98d5577ab4a9ad6f465f3dff3c` (merge base equals the tip of origin/main)
- Work mode: `minor-audit` (from `issue.md`)
- Review timestamp: 2026-10-12T19-05
- Diff command: `git diff origin/main...HEAD` (43 files, 3024 insertions, 26 deletions)

## Scope

The audit covers the full branch diff against `origin/main`. Changed files by category:

| Category | Files |
|---|---|
| PowerShell production (canonical) | `.claude/hooks/enforce-pr-author-skill.ps1` (M), `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (M), `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` (M), `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` (A) |
| PowerShell production (bundled mirrors) | the same four files under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` |
| PowerShell tests | `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`, `.DocsOnly.Exemption.Tests.ps1`, `.DocsOnly.Decision.Tests.ps1`, `.BodyNumber.Tests.ps1` (all A) |
| JSON manifest | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (M, one line) |
| Markdown | `issue.md`, `plan.2026-10-11T10-38.md`, `research/research.2026-10-11T10-45.md`, 27 evidence files under the feature folder |

Languages with changed files: PowerShell only. No Python, TypeScript, or C# files changed. The PR context artifacts under `artifacts/` were not consulted for the file list. The list above was derived directly from `git diff --name-status origin/main...HEAD`, which is the authoritative base diff.

## Rejected Scope Narrowing

Caller text: "AC-9 (per-file CI line coverage >= 85% for each edited hook file) is pending PR CI and must be recorded as PENDING CI evidence, not as FAIL, unless you find an independent defect in it."

Disposition: honored for the acceptance-criteria verdict in `feature-audit.2026-10-12T19-05.md`, because the AC-9 text itself names CI as its evidence source. Rejected for this policy audit's coverage verdict. The reviewer contract requires an explicit PASS or FAIL for every language with changed files, and the existing coverage artifact does not cover two of the four changed production files. See Coverage Verification below.

Caller text: "Scope notes: #850 note L20 is recorded only (epic merge-gate files are out of scope by operator decision); the four agent/skill docs that describe the checkpoint preflight are a recorded follow-up, not filed. These are intentional, not findings."

Disposition: not a narrowing of the audit scope. These are statements about work deliberately excluded from the branch, and neither removes any changed file from review. They are accepted as recorded decisions (evidence: `evidence/other/note-850-L20-record.2026-10-11T10-38.md`, `evidence/other/follow-up-and-decisions.2026-10-11T10-38.md`).

## Policy Reading Order

Read in order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`.

## Policy Compliance Verdicts

| # | Policy | Requirement | Verdict | Evidence |
|---|---|---|---|---|
| P1 | general-code-change: design priorities | Simplicity, separation of concerns, reuse | PASS | The exemption is a separate sibling file (`enforce-pr-author-skill.docs-only.ps1`) with pure helpers (`Get-PrAuthorDocsOnlyPathViolation`, `ConvertFrom-PrAuthorDocsOnlyNameList`, `Get-PrAuthorDocsOnlyBaseName`) separated from the single I/O seam (`Invoke-PrAuthorDocsOnlyGitExe`). The call site adds 4 lines to `Get-PrAuthorBypassReason`. |
| P2 | general-code-change: file size limit | No production or test file over 500 lines | PASS | `wc -l`: helpers 438, main hook 354, docs-only 265, artifact-root 233; tests 218, 209, 149, 141. |
| P3 | general-code-change: error handling | Fail fast; no silent catch-alls | PASS | The two `catch` blocks in the docs-only file convert any throw into a deny result (`DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` / `DOCS_ONLY_EXEMPTION_DIFF_FAILED`). The seam's catch returns `ExitCode = -1`, which also denies. The rationale is documented in the seam's `.DESCRIPTION`: an uncaught throw exits 1, which PreToolUse treats as non-blocking. The errors are converted to an explicit denial rather than discarded. |
| P4 | general-code-change: dependencies | No new external dependency | PASS | Only in-repo parsers and the `git` executable, which the hook family already uses. `.NOTES` sections now state this (AC-8). |
| P5 | general-code-change: I/O boundaries | I/O isolated; domain logic testable without process or filesystem | PASS | All git access goes through `Invoke-PrAuthorDocsOnlyGitExe`. Checkpoint presence goes through `Test-PrAuthorDocsOnlyCheckpointPresence`. Both are mocked in the decision suites. |
| P6 | general-code-change: public API compatibility | No breaking change to callers | PASS | `Get-PrAuthorBypassReason` signature unchanged. The deny text keeps the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED:` prefix and appends a parenthesized sub-code, so prefix-matching consumers are unaffected. |
| P7 | general-code-change: mandatory toolchain loop | Format, analyze, test pass in one pass | PASS (local), CI confirmation pending | `evidence/qa-gates/p2-poshqc-format`, `p2-poshqc-analyze` (status empty after MCP run; MCP results carry no finding count, so the CI Analyze step is the confirming source), `p2-pester` (tests=6093 failures=0 errors=0; pr-author family 230 passed, 0 failed). Type checking is not applicable to PowerShell. No architecture, contract, or integration stage applies to this hook family. |
| P8 | general-unit-test: core principles and AAA | Independence, isolation, determinism, AAA | PASS | All four suites use explicit `# Arrange` / `# Act` / `# Assert` sections, one behavior per `It`, and the repository baseline mock block plus interception probe. |
| P9 | general-unit-test: no temporary files | No temp file creation in tests | PASS | `grep -nE "TestDrive|New-TemporaryFile|GetTempPath|Temp|Start-Sleep|Get-Date|Out-File|Set-Content|New-Item"` over the four suites returned no match (reviewer run). It agrees with `evidence/qa-gates/p2-test-purity`. The checkpoint-presence rows read `$PSCommandPath` (an existing file) and a nonexistent sibling path. Both are read-only. |
| P10 | general-unit-test: test location | Tests under `tests/` mirroring source | PASS | `tests/scripts/claude-hooks/` is the established mirror location for `.claude/hooks/` in this repository. |
| P11 | general-unit-test: scenario completeness | Positive, negative, edge, error paths | PASS | The positive allow path, every AC-2 deny branch, throw paths for both git calls, prefix look-alikes (`docsx/`, `doc/`, `Docs/`, bare `docs`), an LF inside a name, and non-ASCII names are covered. See code review for two untested evasion shapes (advisory). |
| P12 | general-unit-test: determinism infrastructure | No clock or sleep APIs | PASS | No wall-clock or sleep APIs. Fixed timestamps are used in the receipt mocks. |
| P13 | powershell: advanced functions | `CmdletBinding`, typed params, `OutputType` | PASS | All six new functions and `ConvertTo-PrAuthorBodyNumber` declare `[CmdletBinding()]`, `[OutputType()]`, and comment-based help. |
| P14 | powershell: wrapper seam | `Invoke-<Tool>Exe -<Tool>Args <string[]>` | PASS | `Invoke-PrAuthorDocsOnlyGitExe -GitArgs [string[]]`. The tests mock the wrapper, not `git`, with `-ParameterFilter` on `$GitArgs`. |
| P15 | powershell: change budget | More than 3 production PowerShell files requires the large route | PASS | Four canonical production files changed. `evidence/baseline/p0-route` records `route_id: large`. |
| P16 | powershell: no Python in enforcement hooks | Hooks remain PowerShell-only | PASS | No Python file in the diff. |
| P17 | Bundled mirror parity | Mirrors byte-identical; new sibling registered | PASS | Reviewer `cmp` of all four pairs: identical. `core.json` adds `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` in sorted position. `evidence/regression-testing/p1-bundle-parity` records the parity pytest passing. |
| P18 | tonality | Professional, factual, no hyperbole | PASS | Code comments, help text, deny messages, and evidence use plain declarative language. |
| P19 | Coverage Exclusion Policy | No production path excluded from coverage | PASS | `config/poshqc-coverage.json` roots include `.claude/hooks`. The diff adds no `exclude` entry. |
| P20 | PowerShell coverage thresholds | Line >= 85% for new and modified files; no regression | FAIL | See Coverage Verification. |

## Coverage Verification

| Language | Changed production files | Artifact | Verdict |
|---|---|---|---|
| PowerShell | 4 (1 new, 3 modified) | `artifacts/pester/powershell-coverage.xml` (present locally, JaCoCo format) | FAIL |
| Python | 0 | not applicable | N/A (no changed files) |
| TypeScript | 0 | not applicable | N/A (no changed files) |
| C# | 0 | not applicable | N/A (no changed files) |

PowerShell detail, parsed by the reviewer from the local artifact (LINE counters per `sourcefile`):

| File | Status | Covered | Missed | Line % | Threshold | Result |
|---|---|---|---|---|---|---|
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | modified | 111 | 3 | 97.37 | 85.00 | PASS |
| `.claude/hooks/enforce-pr-author-skill.ps1` | modified | 53 | 4 | 92.98 | 85.00 | PASS |
| `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | new | absent from artifact | absent | none | 85.00 | FAIL (no measurement) |
| `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` | modified | absent from artifact | absent | none | 85.00 | FAIL (no measurement) |
| Repo-wide (artifact total) | n/a | 7308 | 4977 | 59.49 | 85.00 | FAIL (see note) |

Notes:

- The local artifact comes from a scoped MCP run over three test folders (`evidence/qa-gates/p2-pester`). It contains 127 source files and no entry for the two dot-sourced sibling files. The repo-wide 59.49% therefore reflects the scoped run, not the full CI run. It is not by itself evidence of a regression introduced by this branch.
- CI's `Invoke-PoshQCTest -Root <workspace>` derives the population from `config/poshqc-coverage.json` (roots include `.claude/hooks`), so the CI `poshqc-test-results` artifact is expected to measure all four files.
- No pull request and no CI run exist for the branch at review time (`gh pr list --head ...` and `gh run list --branch ...` both returned `[]`). The branch is pushed at `bdbf8851e`.
- Branch coverage: not applicable. Pester does not measure branch coverage, and no PowerShell branch threshold applies.
- Reason for FAIL: coverage verification is mandatory for every language with changed files. The available artifact does not measure two of the four changed production files, including the new enforcement file, and its repo-wide figure is below threshold. The verdict becomes PASS when the CI `poshqc-test-results` artifact for this branch shows each of the four files at or above 85.00% line coverage, the repo-wide PowerShell line figure at or above 85.00% or not regressed from the main baseline run `38315946747`, and no regression on changed lines.

## Evidence Location Compliance

- Validator: `python -I scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no reported paths.
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 27 evidence files are under `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/{baseline,regression-testing,qa-gates,other}/`.
- Result: PASS.

## Remediation Triggers

1. PowerShell coverage evidence (P20): obtain the CI `poshqc-test-results` artifact for this branch and record per-file line coverage for the four changed hook files plus the repo-wide PowerShell figure. This is the same reading that plan task P2-T7 and AC-9 already define. No code change is indicated by this review.

## Summary

- Policy verdicts: 19 PASS, 1 FAIL (P20, coverage evidence).
- Blocking findings: 1 (P20).
