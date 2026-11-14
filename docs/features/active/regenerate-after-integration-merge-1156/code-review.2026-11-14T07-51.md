# Code Review: Regenerate path after an integration merge (#1156)

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/regenerate-after-integration-merge-1156`
**Feature Folder Selection Rule:** named by the caller; matches branch `feature/regenerate-after-integration-merge-1156` and issue #1156
**Base Branch:** `main` (resolved `origin/main` at `2c8dee6dd3a82f210561d9efe623767ae902de51`, equal to the merge base; 0 commits ahead of the branch at 07:51 UTC)
**Head Branch:** `feature/regenerate-after-integration-merge-1156` at `e25b4e07c249bc76a2ed1ee09aab07d890ca6230`
**Review Type:** Re-audit after remediation cycle 2 (prior set `*.2026-11-14T05-56.md`; cycle inputs `remediation-inputs.2026-11-14T06-19.md`, findings C2-1, C2-2, C2-3)

---

## Executive Summary

The re-audit covers the full branch diff from the merge base `2c8dee6dd` to the head `e25b4e07c` (171 files, 14921 insertions, 49 deletions). Cycle 2 changed three production-side files and their bundle copies, two test files, and one `spec.md` bullet; every other commit in the cycle adds evidence only. No main sync occurred after the prior review, so the prior whole-branch findings stand for the unchanged files.

C2-1 (CR-3) is closed: `Get-RegenerationProcessStartSpec` now throws `batch file path '<path>' holds a quote or a cmd.exe metacharacter` for a batch `ResolvedPath` matching `["&|<>^%]`, after the ComSpec check and before the argument loop. Non-batch paths return before the screen, so Linux and direct `.exe` starts are unchanged. The executor's probe shows the `amp&dir` and `pct%OS%dir` folders refused with no marker written; the reviewer's independent probe confirms that a `.cmd` under `p (x86) q` still starts with exit 0 and receives its argument unchanged.

C2-2 (CR-4) is closed: the same sentence (resolution through PATH and PATHEXT, `ComSpec /d /c` for `.cmd` and `.bat`, the path refusal set, the argument refusal set) is now in item 2 of `## Merge-Conflict Remediation` of the orchestrate skill and in the `Config rules,` paragraph of the rules file, and a new contract test pins it in both scopes and both surfaces, plus a once-only occurrence check. `spec.md` states the path refusal in the `command` bullet. The skill, rules file, and spec agree on both character sets.

C2-3 is closed: the argument refusal table has one row per character of `[\s"&|<>^%()]` plus a tab (11 rows), and a new path table has one row per character of `["&|<>^%]` (7 rows). Removing any character from either class, or removing the path screen, makes at least one row fail.

No blocking finding remains.

**What changed:**
Since the prior review: a 3-line path screen and 1 help line in `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` (788 to 792 logical lines) and its bundle copy; one sentence in `.claude/skills/orchestrate/SKILL.md` and `.claude/rules/orchestrator-state.md` and their bundle copies; 16 cases in `Invoke-RegenerationPath.ProcessStart.Tests.ps1`; 4 cases in `regeneration-path-skill-contract.Tests.ps1`; one extended `spec.md` bullet; cycle 2 plan and evidence.

**Top 3 risks:**
1. `Invoke-RegenerationPath.ps1` is 792 logical lines, 8 below the 800-line hard limit; any further logic needs a split first (Warning).
2. The cmd.exe refusals are verified on Windows only by real-process probes; CI runs the pure rows on both hosts but does not start a batch file (Info).
3. `Get-Command -Name` wildcard interpretation in the resolver default, carried from the prior review (Info).

**PR readiness recommendation:** **Ready** — C2-1, C2-2, and C2-3 are closed; the remaining items are non-blocking.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Warning | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | whole file | 792 logical lines (700-line advisory tier; 800-line hard limit). | Do not add further logic to this file; a later split of the Merge and Tip flows into a module would bring it below 700. | File-size advisory tier. | Logical line count 792 (split on line terminators, trailing terminator not counted) |
| Warning | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | whole file | 792 logical lines (byte copy of the source). | Same as above. | File-size advisory tier. | Equal SHA-256 with the source |
| Info | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | `Get-RegenerationProcessStartSpec` path screen | The path screen allows `!`, `,`, `;`, and `=`. With delayed expansion off by default under `/d /c` and the path quoted, none of them alters the command line; the reviewer's probe of a quoted path with a space and parentheses confirms that cmd.exe keeps a single-quoted-pair path intact. | No change required. | Behavior recorded for completeness. | Reviewer probe in the session scratchpad; `evidence/other/process-start-probe.2026-11-14T06-36.md` |
| Info | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | `Resolve-RegenerationExecutable` `-Resolver` default | Carried: `Get-Command -Name` treats `*`, `?`, and `[` as wildcards. | No change required. | Declared argv is repository-controlled. | Diff inspection |
| Info | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | `Invoke-RegenerationMergeFlow`, `Invoke-RegenerationTipFlow`, `Invoke-RegenerationTipRestore` | Carried: no `SupportsShouldProcess` on the state-changing adapter functions, consistent with the other orchestration entry points. | Non-blocking. | `.claude/rules/powershell.md` ShouldProcess guidance. | Diff inspection |

No Blocker, Major, or Minor finding.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Unchanged since the prior review: test-only edits; no `.py` file changed in cycle 2.

#### Typing and API notes

- No new public Python API surface.

#### Error handling and logging

- No production Python code changed.

### TypeScript implementation audit

#### What changed well

- Unchanged since the prior review: one appended validator case; no `.ts` file changed in cycle 2.

#### Type safety and maintainability

- No production TypeScript changed.

#### Error handling and logging

- Not affected.

### PowerShell implementation audit

#### What changed well

- The path screen is placed after the batch decision and the ComSpec check, so it costs nothing on non-batch starts and keeps the ComSpec message for an unset ComSpec.
- The two character classes are deliberately different and each is documented: the quoted path allows whitespace and parentheses; arguments, which are not quoted by cmd.exe, refuse them.
- The message (`batch file path ... holds a quote or a cmd.exe metacharacter`) is distinct from the argument message, so the tests can tell the two refusals apart; the step wrapper reports it on stderr with `Started = $false` (executor probe).
- The adapter and its bundle copy are byte-identical (SHA-256 `957247bc...`); the skill and rules pairs are byte-identical (`f86eb6fc...`, `051e0b00...`).
- Coverage: lines 149 and 150 have instruction counts 1 and 2 and no missed instruction; file total 91.33%.

#### API and safety notes

- With both screens in place, neither the path nor an argument can carry a cmd.exe metacharacter into the `/c` command tail, so the function's contract (input reaches the batch file unchanged or the start is refused) now holds for the path as well as the arguments.

#### Error handling and logging

- Refusal messages name the refused path or argument.

---

## Test Quality Audit

Discrimination was judged by inspecting each row against the two regular expressions (OD-4: no single-file runs by the reviewer). Each argument row holds exactly one character of `[\s"&|<>^%()]` and otherwise clean text, so dropping any character from the class makes its row stop throwing; each path row holds exactly one character of `["&|<>^%]` with clean arguments `run` and `gen`, so dropping a character or removing the screen fails its row. The path rows expect `*batch file path*`, which the ComSpec message (`batch file <path> cannot be started`) does not match, so a row cannot pass through the wrong throw. The positive case `keeps a batch path containing parentheses as one item` fails if the screen wrongly includes `(` or `)`. The new contract test asserts all five literals within the scoped item or paragraph and that `is refused before the start` occurs exactly once per file, which detects a duplicated or relocated sentence.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.ProcessStart.Tests.ps1` — 33 cases, 140 logical lines.
- `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1` — 56 cases, 350 logical lines.
- `evidence/other/process-start-probe.2026-11-14T06-36.md` — executor probe: `&` and `%` folders refused with no marker; the parentheses-and-space folder starts with exit 0 and writes its marker.
- `evidence/qa-gates/phase-gate.P1.2026-11-14T07-21.md`, `evidence/qa-gates/powershell-final-qc.2026-11-14T07-22.md`, `evidence/qa-gates/pester-final.2026-11-14T07-38.md`, `evidence/qa-gates/pytest-final.2026-11-14T07-43.md`, `evidence/qa-gates/self-review.2026-11-14T07-44.md`.
- `artifacts/pester/powershell-coverage.xml` — parsed by the reviewer (repo-wide 40928/42662 = 95.94%; adapter 295/323 = 91.33%).

### Quality assessment prompts

- **Determinism:** literal paths and ComSpec values; no PATH read or process start.
- **Isolation:** one refused character per row.
- **Speed:** pure function calls only.
- **Diagnostics:** distinct expected-message wildcards per refusal kind.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token literal in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | One `ArgumentList` item per argument; batch paths and batch arguments holding cmd.exe metacharacters are refused before the start; no `Invoke-Expression` and no `Start-Process`. |
| Input validation at boundaries | ✅ PASS | Config rules 1 to 9 before any git call; unresolvable names throw; batch path and argument refusal. |
| Error handling remains explicit | ✅ PASS | Resolution and start failures map to `Started = $false`, exit 1, and the fallback. |
| Configuration / path handling is safe | ✅ PASS | Relative `-ConfigPath` only; the config file is never bundled. |

---

## Research Log

No external research was required. cmd.exe quote handling for a quoted batch path containing a space and parentheses was confirmed by direct execution on the review host (reviewer probe in the session scratchpad; no tracked file written).

---

## Verdict

C2-1, C2-2, and C2-3 are closed with code, tests, documentation in all three surfaces, mirror parity, and real-process evidence. The whole-branch diff has no Blocker, Major, or Minor finding; the 792-line Warning on the adapter and its bundle copy and three Info rows are non-blocking. The branch is ready for PR authoring and CI.
