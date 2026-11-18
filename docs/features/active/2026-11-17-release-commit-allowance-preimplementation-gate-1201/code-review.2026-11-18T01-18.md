# Code Review: Release-commit allowance leg of the preimplementation gates (#1201)

---

**Review Date:** 2026-11-18
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201`
**Feature Folder Selection Rule:** named by the caller; the folder's `issue.md` and `spec.md` carry issue #1201.
**Base Branch:** `main` (merge base `1b9e5746eaa5e32366de695e3f511dbc28700b08`, equal to `origin/main` after a fetch; `git merge-tree` reports no conflict)
**Head Branch:** `bug/release-commit-allowance-gate` at `89d0e58610eac3b66504ca2ba27a6d22a8f15312`
**Review Type:** Initial review (concurrent with CI on PR #1202)

---

## Executive Summary

The branch adds a release-commit allowance leg to the Claude and Codex preimplementation gates. A destination repository that commits `.claude/release-commit-allowance.json` can let an agent run `git add <allowed paths>` and `git commit -m '<message>'` on a branch matching a configured pattern without an orchestration checkpoint. The leg is allow-side only, runs after every existing leg and immediately before the final deny, and appends one ` Release allowance not applied: <CODE>: <detail>` suffix as the last term of the deny text. Without the file the leg declines before any branch, staged-index, or container read, and the deny text is unchanged.

**What changed:**
- New `hook-release-allowance-context.ps1` (495 lines, pure) and `enforce-orchestration-preimplementation-gate-release.ps1` (166 lines, seams and leg entry), each byte-identical across `.claude/hooks`, `.codex/hooks`, and both bundle hook roots (one SHA-256 per file set, verified).
- Each of the four gate copies gains one guarded dot-source line, one leg line, and `+ $release.DenySuffix` as the last deny term; each bundle gate equals its source (`cmp`).
- `.claude/release-commit-allowance.json` added to `EXCLUDED_RELATIVE_PATHS` in `claude-customizations.ts` and `push_down_claude_customizations.py`; both core pack manifests list both new hook files; no manifest lists the allowance file and no copy of it exists in the repository.
- Documentation: six byte-identical execution-environment copies, the `.agents` orchestrate skill and bundle, `.claude/rules/orchestrator-state.md` and bundle, and a `CHANGELOG.md` entry.
- Tests: 600 new Pester tests in six files and 3 Jest tests; no pre-existing test file changed.

**Top 3 risks:**
1. The `-C` value is compared with the target root case-insensitively (spec AD-5). On a case-sensitive file system a case-variant path that names a different directory would pass the comparison; this requires a deliberately created case-variant repository and is recorded as a Minor finding.
2. The evaluated set for a commit is computed before the preceding `git add` runs (pre-tool hook), so it is an approximation by design (AD-1); every add operand is itself held to the allowance, so the approximation cannot admit an unlisted path.
3. Destinations receive the leg only after an extension release and push-down refresh, and epic #1018 may require adaptation; this is a rollout dependency, not a defect.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; all gates recorded green locally and CI on the PR head is pending.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/hook-release-allowance-context.ps1` (and three mirrors) | `Get-ReleaseAllowanceGlobalOptionFailure`, lines 333-339 | The `-C` value is compared with R using `OrdinalIgnoreCase` after separator normalization only. On Linux or macOS with a case-sensitive file system, `git -C /x/REPO add package.json` can pass when R is `/x/repo` and `/x/REPO` is a different repository. | No change on this branch: the behavior is specified by AD-5 ("ordinal, case-insensitive") and pinned by row `AC8-add-target-root-case`. When the leg is adapted for epic #1018, consider an ordinal comparison of everything except a Windows drive letter. | Fail-closed posture: the gap requires two case-variant directories and is a policy-level control. | Reviewer probe: `git -C c:/W/REPO add package.json` with R `C:/w/repo` returned Allowed true. |
| Info | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | line 35 | The release sibling is dot-sourced before `hook-command-invocation.ps1`, which defines `Test-CommandLineTokenLiteral` used by the leg. | None; the function is resolved at call time, after all dot-sources complete. | The Codex decision suite exercises the `-C` path through the Codex gate and passed (102/102). | JUnit `enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1` tests=102 failures=0. |
| Info | `.claude/hooks/hook-release-allowance-context.ps1` | lines 394-401 | `git commit -m -a` is accepted with `-a` read as the message value. | None; git's option parser also consumes the next argument as the value of `-m`, so no `-a` behavior occurs. | Parity with git semantics. | Reviewer probe returned Allowed true; git parse-options takes the following argv entry for a required-argument option. |
| Info | `.claude/hooks/hook-release-allowance-context.ps1` | line 55 (`$script:ReleaseAllowancePathRule`) | The path rule admits a dash-leading entry such as `-A`. It can only be added after `--` (before `--` any dash token is an option and is denied), where git reads it as a literal file name. | None. | No fail-open: probe `git add -A` is denied with `RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED` even when `-A` is an allowed path. | Reviewer probe with `allowed_paths` `["package.json","CHANGELOG.md","-A"]`. |
| Info | `coverage/lcov.info` (gitignored) | n/a | The root TypeScript coverage artifact was absent at review start because the executor wrote the Jest report to the scratch directory. | The reviewer ran `node run-jest.cjs --coverage` once (5717 passed; 98.3% lines, 93.78% branches) and recorded it. | The canonical TypeScript artifact is the root `coverage/lcov.info`. | `evidence/qa-gates/jest-gate.2026-11-18T01-22.md`. |

No Blockers or Major findings. No covered file reaches 700 logical lines, so there is no file-size Warning row.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- One entry, `Path(".claude/release-commit-allowance.json")`, appended to the existing `EXCLUDED_RELATIVE_PATHS` tuple, following the `config/blast-radius.local.json` precedent.

#### Typing and API notes

- No new public Python API surface was added; no new Python module or test (AC-32).

#### Error handling and logging

- No new control flow.

### TypeScript implementation audit

#### What changed well

- One entry appended to `EXCLUDED_RELATIVE_PATHS`; the Jest contract test proves both refresh paths (no packs, `core` pack) leave a differing destination file byte-identical and omit it from `summary.files`.

#### Type safety and maintainability

- The constant keeps its `ReadonlyArray<string>` type; no suppression added; ESLint, Prettier, and TSC clean.

#### Error handling and logging

- No new behavior beyond the exclusion lookup already in place.

### PowerShell implementation audit

#### What changed well

- Clear split between a pure decision file and a two-seam I/O file; the decision order in the file headers matches spec steps 1-10 exactly.
- Decline paths perform no I/O before the config seam reports a file: blank command, `*** Begin Patch` text, irrelevant lines, an empty checkpoint path, and an absent file all return an empty suffix. The absent-file path makes no branch, staged-index, or container call (asserted with `-Times 0 -Exactly`).
- Fail-closed command modelling, verified by a direct in-process probe of 23 additional lines beyond the test table: a newline-chained `rm`, a `#` comment, a `2>` redirection, a pipe to `cat`, an env-prefixed `GIT_DIR=x git add`, `./package.json`, an abbreviated `--mess=x`, `-C <R>/.`, and a second relative `-C` are all denied; `||`, `&`, and `;` chains of modelled segments are evaluated as a single allowance. The staged index is read with `--no-renames`, so a rename's deleted side is visible to the staged-path check.
- Script-scope state is limited to eight read-only constants with the unique `$script:ReleaseAllowance` prefix.

#### API and safety notes

- All functions are advanced functions with approved verbs; none changes state, so `ShouldProcess` does not apply. PSScriptAnalyzer and the formatter check reported zero findings.
- The gate call-site change is minimal: one dot-source line in the guarded single-statement form, one leg line, one deny term per gate. The Codex gate is 487 lines (limit 500).

#### Error handling and logging

- The config seam throws for a non-file item or a failed read, reported as `RELEASE_ALLOWANCE_CONFIG_INVALID: the file could not be read`; a container-probe throw is reported per entry. Any other exception is caught, logged with `Write-Debug "PREIMPL_RELEASE_LEG_ERROR: ..."`, and returns a declined result, which leaves the gate's existing deny in place.

---

## Test Quality Audit

The test design is table-driven with exact-text assertions. The shared cases file holds 101 rows driven through `Invoke-OrchestrationPreimplementationGateDecision` of both gates, each asserting the hook decision, the full reason text with `Should -BeExactly`, and seam call counts where the spec requires them. Only I/O seams are mocked; the parser, tokenizers, decision, and suffix composition run for real. Coverage of both new files is 100% lines per measured copy; the three changed lines of each gate are covered.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1` — 314 tests, both surface copies: every AC-1 parser row, AC-2 branch rows, relevance and shape rows.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-release.Tests.ps1` — 44 tests: config and container seams with mocked `Test-Path`/`Get-Content`, every decline path, the catch path through the debug stream, and reader call counts.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ReleaseAllowance.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1` — 102 tests each; the Codex suite loads the shared cases file by a path relative to its own `$PSScriptRoot`.
- `tests/scripts/claude-hooks/hook-release-allowance-context.Parity.Tests.ps1` — 38 tests: byte identity, line bounds, gate wiring, manifest entries, allowance-file absence, the Python tuple text, documentation tokens, and no `python`/`poetry` in the new files.
- `extensions/drm-copilot/test/lib/push-down/claude-customizations-release-allowance.test.ts` — 3 tests with `buildInMemoryFileSystem` and `fixedClock`.
- `evidence/qa-gates/final-qc-pester.2026-11-18T01-05.md`, `coverage-comparison.2026-11-18T01-10.md`, `final-qc-static-*.md`, `jest-gate.2026-11-18T01-22.md` — gate runs and coverage figures, cross-checked against `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml`, `artifacts/python/lcov.info`, and `coverage/lcov.info`.

### Quality assessment prompts

- **Determinism:** no clock, randomness, live git, environment read, or temporary file (scan of all seven new test files returned no match for the prohibited APIs).
- **Isolation:** one row per `It`; Pester mocks are It-scoped.
- **Speed:** 21.3 s total for the 600 new Pester tests across the parallel shards.
- **Diagnostics:** each assertion carries `-Because "row <Id>"`, and row ids carry the AC number.

Test discrimination was judged by fixture inspection and direct-call probes rather than mutant runs, in keeping with the owner's parallel-only test-run rule; the exact-text assertions and seam call counts make most single-token mutations of the codes, details, or decision order observable.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Inspection of the diff; leak scan 0 failures. |
| No unsafe subprocess or command construction | ✅ PASS | The new files start no process; git reads go through the existing bounded `Invoke-DocsOnlyGitExe` seam (staged index) and a HEAD file read (branch). No Python invocation. |
| Input validation at boundaries | ✅ PASS | Strict schema-version-1 parser with ordinal key checks; command text must be resolvable and balanced; every option outside the accepted set is denied. |
| Error handling remains explicit | ✅ PASS | Specific codes per failure; the outer catch declines (gate deny stands) and logs `PREIMPL_RELEASE_LEG_ERROR`. |
| Configuration / path handling is safe | ⚠️ PARTIAL | Paths are compared ordinally against a restricted character set; directory entries are rejected by the container seam. The `-C` root comparison is case-insensitive by spec (Minor finding above). |

---

## Research Log

No external research was required. Git option-parsing behavior for `-m <value>` and pathspec handling was assessed from the existing repository helpers and the spec's research artifact.

---

## Verdict

The change is ready for normal PR flow. The leg is localized, allow-side only, and fail-closed for every forbidden form the spec enumerates and for the additional forms probed during review; the absent-file path is inert, existing deny text is unchanged, and all mirror and manifest invariants hold. The single Minor finding follows the specified design (AD-5) and is suited to the planned epic #1018 adaptation rather than a remediation cycle. Merge readiness depends on CI on PR #1202 at head `89d0e5861`.
