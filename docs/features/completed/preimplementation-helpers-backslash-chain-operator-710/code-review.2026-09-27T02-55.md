# Code Review: Preimplementation Gate Helpers Backslash Chain Operator (#710)

---

**Review Date:** 2026-09-27
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/preimplementation-helpers-backslash-chain-operator-710`
**Feature Folder Selection Rule:** Only active folder changed on the branch; suffix `-710` matches the branch issue number.
**Base Branch:** `main` (merge-base `2dce111ef7cb6cf6326db6e661223e59c85e4bec`)
**Head Branch:** `bug/preimplementation-helpers-backslash-chain-operator-710` @ `e5c7a223460a302042840e45192ba6a78924df48`
**Review Type:** Initial review

---

## Executive Summary

The branch fixes a false-deny in the preimplementation gate's command-chain scanner. `Split-OrchestrationCommandLine` previously split on an unquoted `\;`, `\&`, or `\|`; it now tracks a one-character escape state so that a backslash outside single quotes consumes the next character. The production change is two executable lines plus a condensed help block, applied byte-identically to four copies. A new 198-line Pester suite covers the spec's case table against both canonical copies (38 tests), with recorded fail-before (16 failures on base) and pass-after evidence. Format, analyze, the full Pester run, and coverage evidence are clean; the reviewer reran five related suites (297 passed, 0 failed) and recomputed the mirror hashes and coverage counts.

**What changed:**
- `Split-OrchestrationCommandLine` (lines 58-107 of each helper copy): new `$escaped` flag and the guard `if ($escaped -or ($character -eq '\' -and $openQuote -ne "'")) { $escaped = -not $escaped; [void]$current.Append($character); continue }`, placed before quote and operator evaluation. `.DESCRIPTION` condensed from four lines to three; one blank line removed. Net line delta 0 (497 lines).
- New suite `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`.

**Top 3 risks:**
1. The escape rule assumes a POSIX command interpreter. On a host whose `Bash`-named tool executes through PowerShell (plausibly Codex on Windows), a crafted `\;` input is now exempted where the base denied it (Finding 1).
2. CI has not run on the branch head (no PR yet); the Windows CI PoshQC job is the only CI surface for the new suite.
3. Merge ordering with sibling #713, which may edit the same helper file; mitigated by the net-zero line delta and a hunk confined to one function.

**PR readiness recommendation:** **Conditional Go** — no Blocker findings; open the PR, confirm the CI PoshQC Pester job, and file the Finding 1 follow-up.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (and the Codex bundle mirror) | `Split-OrchestrationCommandLine`, line 78 | The escape rule is POSIX-only. The Codex gate routes `tool_name` `Bash` through this scanner, and `.codex/config.toml` defines `command_windows` hooks, so the Codex surface runs on Windows. If that host executes the command through PowerShell, backslash is not an escape and `;` still separates statements. Probe: `git commit -m a\; docs/features/active/x/run.ps1 -- docs/features/active/x/spec.md` is exempt on head (`True`, 1 segment) and denied on base (`False`, 2 segments). Under PowerShell this would run a pathspec-less `git commit -m a\` (which is not exempt when issued alone: base probe `git commit -m a` gives `False`) and then run the second statement. Under POSIX (Claude `Bash` via Git Bash) the input is one exempt commit and the result is correct. | File a follow-up issue to (a) confirm which interpreter executes the Codex `Bash` tool on Windows, and (b) if it is PowerShell, make escape handling dialect-aware (for example, deny unquoted `\` adjacent to a chain operator on the Codex surface, which restores the base fail-toward-deny outcome). Do not block this PR on it. | The spec (Risks, AC-4) states the fix introduces no bypass; that claim holds under POSIX semantics only. The widening requires a deliberately crafted command and the second statement would itself be allowed as a standalone command, so impact is narrow, but it is an allow-side change on one surface. Whether the Codex Windows shell is PowerShell was not verified in-repo. | Reviewer probes `probe2.ps1` (head `.codex/hooks` copy) and `probe3.ps1` (base helper from `git show 2dce111e:...`); `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 474-482; `.codex/config.toml` lines 120, 134-138 |
| Minor | `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/spec.md` | AC-1, AC-10, Test Strategy, Files/modules | The spec names `evidence/coverage/` and `evidence/regression/` as evidence destinations; neither is a canonical evidence kind. The executor correctly used `evidence/qa-gates/` and `evidence/regression-testing/`. | No code action. Future spec authoring should name canonical evidence kinds only. | AC text that points to a non-canonical folder cannot be satisfied literally; here the evidence exists at the canonical location. | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` lines 16-17, 52-54; `evidence/qa-gates/final-coverage-delta.md`; `evidence/regression-testing/fail-before-chain-escape.md` |
| Nit | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (all four copies) | line 78 | Four statements on one line (`$escaped` toggle, append, `continue`) inside a compound `if`. This was chosen to hold the net-zero line delta (spec D5). | Accept as is. If the file later gains headroom, expand to a multi-line block with a short comment stating that the pair (backslash, next character) is consumed together. | Readability; the toggle `$escaped = -not $escaped` encodes both "enter escape" and "leave escape" and is not obvious on first read. | `git diff 2dce111e...HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | line 78 | Inside double quotes the guard consumes any character after a backslash, while POSIX only treats `\` as an escape before `$`, backtick, `"`, `\`, and newline. | None. | Inside double quotes the only character that changes scanner state is `"`, and `\"` is a real escape in POSIX, so segmentation and `Balanced` are identical to POSIX for every input. | Code reading; spec D1 |
| Info | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` | `treats an escaped ampersand as literal`, `treats an escaped pipe as literal`, `still splits after an escaped backslash` | These cases assert segment count and text but not `Balanced`. | Optional: add a `Should -BeTrue` assertion on `$result.Balanced` for symmetry with the other cases. | Low value; `Balanced` depends only on quote state and these inputs contain no quotes. | Test file lines 33-95 |
| Info | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (not changed) | `CodeCoverage.Path` | The two `extensions/drm-copilot/resources/...` helper copies are not in the coverage denominator (0 occurrences in `artifacts/pester/powershell-coverage.xml`). | None for this branch. Pre-existing configuration; identity with the measured copies is enforced by the Parity suite and was recomputed by SHA256 during review. | Not an `exclude` entry added by this branch; recorded for traceability against the Coverage Exclusion Policy. | `grep -c 'extensions/drm-copilot/resources' artifacts/pester/powershell-coverage.xml` = 0 |
| Info | `artifacts/pr_context.summary.txt` | Close candidates | The PR-context generator lists `#510` and `#663` as author-asserted autoclose issues. Both are references (known issue, origin), not fixes. | The PR body should use `Closes #710` only and refer to #510 and #663 without closing keywords. | Prevents unintended closure of unrelated issues at merge. | `artifacts/pr_context.summary.txt` "Auto-close issues (author asserted)" |

No Blocker findings. One Major finding, recommended as a non-blocking follow-up.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The escape state is checked before quote and operator handling, so an escaped `"`, `'`, `;`, `&`, `|`, LF, or CR can never change quote state or end a segment. Pairwise consumption (rather than a lookbehind) handles `\\;` and `\\\;` correctly, which the spec identified as the main bypass risk under POSIX.
- The single-quote exclusion (`$openQuote -ne "'"`) matches POSIX: backslash is literal inside single quotes, and `'a\'; b` still splits.
- Segment text is never rewritten, so downstream tokenization and operand normalization (`ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`) see the same text as before; the spec's D2 reasoning about row 18 and LACS allow 3 holds.
- The edit is confined to `Split-OrchestrationCommandLine` (three hunks at pre-image lines 63, 77, 78), and the four copies are byte-identical.

#### API and safety notes

- Signature and return shape unchanged. No new function, parameter, or dependency.
- The comparison `$openQuote -ne "'"` compares a `[char]` to a one-character string; PowerShell converts the right operand to `[char]`, so the comparison is exact.
- The scanner now diverges from PowerShell parsing for backslash sequences; see Finding 1.

#### Error handling and logging

- No error paths added. The function returns a hashtable; an unbalanced quote still yields `Balanced = $false`, and callers continue to deny on that result.

---

## Test Quality Audit

The new suite is pure: it dot-sources the two canonical helper copies and calls `Split-OrchestrationCommandLine` and `Test-ExemptOrchestrationStagingCommand` directly. It covers every row in the spec's required-results table plus an empty-input case. Fail-before evidence shows exactly the eight expected cases failing per surface on base; pass-after, parity, full-run, and coverage evidence are present.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` — 19 cases x 2 surfaces; reviewer rerun passed.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` — SHA256 identity and 500-line cap across four copies; reviewer rerun passed.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` — 119 + 119 existing contract rows; reviewer rerun passed.
- `evidence/regression-testing/fail-before-chain-escape.md` — 16 failed / 22 passed on base, matching the planned fail-before set.
- `evidence/qa-gates/final-pester-full.md` — 5244 JUnit tests, 0 failures, 0 errors.
- `evidence/qa-gates/final-coverage-delta.md` — 97.04% to 97.08% per canonical copy; changed lines 2 of 2 covered. Reviewer re-parsed `artifacts/pester/powershell-coverage.xml` (written 02:44 local, after fix commit `3fd0c454` at 02:15; only feature-folder docs changed after that commit) and obtained 166/171 per copy and 10034/10455 = 95.97% repo-wide.
- `evidence/qa-gates/test-portability-inspection.md` — no gitignored state, `origin/main`, gate-decision path, or Windows-only filesystem path in the suite.

### Quality assessment prompts

- **Determinism:** no clock, RNG, filesystem write, process, or git access.
- **Isolation:** one input per test; data-driven operator rows are separate expansions.
- **Speed:** pure string functions; negligible runtime.
- **Diagnostics:** `-Because` text on count assertions and `-BeExactly` on text make a failure attributable to a specific case and surface.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | Scanner only reads text; no invocation. |
| Input validation at boundaries | ⚠️ PARTIAL | Correct for POSIX interpreters. Dialect assumption on the Codex surface may widen the staging exemption for crafted input (Finding 1, non-blocking). |
| Error handling remains explicit | ✅ PASS | Unbalanced input still yields `Balanced = $false` and the caller denies. |
| Configuration / path handling is safe | ✅ PASS | Test paths from `$PSScriptRoot` via `Join-Path`; no configuration changed. |
| No-bypass cases under POSIX | ✅ PASS | `a\\; b` -> 2, `a\&& b` -> 2, `'a\'; b` -> 2, `git commit -m fix\\; touch src/x -- ...` -> not exempt (tests and reviewer rerun). |

---

## Research Log

No external research was required. POSIX backslash semantics are cited in the feature research (`research/research.2026-09-26T23-05.md`, section 2) and match the implementation. The PowerShell parsing behaviour used in Finding 1 (backslash is not an escape character; `;` separates statements) is standard PowerShell language behaviour and was incidentally observed during review when a probe command string was parsed by `pwsh`.

---

## Verdict

The change is small, well-scoped, and correct for POSIX shells, which is the execution model of the Claude `Bash` tool (Git Bash on Windows). Tests are thorough for the spec's case table, fail-before and pass-after evidence is present, the four copies are identical, and coverage improves slightly with every changed line executed.

The change is ready for normal PR flow once the CI PoshQC Pester job passes on the PR. Finding 1 describes a narrow allow-side widening that applies only if the Codex `Bash` tool executes commands through PowerShell; it should be filed as a follow-up issue rather than block this PR.
