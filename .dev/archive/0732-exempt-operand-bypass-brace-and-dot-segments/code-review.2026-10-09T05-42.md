# Code Review: Exempt-operand bypass, per-segment epic-scope targets, trailer documentation, and Codex shell finding (#732, bundles #738, #745, #735)

**Review Date:** 2026-10-09
**Branch:** `bug/exempt-operand-bypass-brace-and-dot-segments-exec-732` (local `c1b-732-resume`), head `d7b0d524ffe51819243946e632cb34eec0a36521`
**Base:** `origin/epic/enforcement-hook-precision-integration` (merge base `497cb504ad9a4e5435dc8946333ebc28baea50c4`)
**Scope:** `git diff origin/epic/enforcement-hook-precision-integration...HEAD` (117 files). Code reviewed: the 7 canonical PowerShell production files (mirrors verified byte-identical by SHA-256), the 15 changed Pester suites, the 6 skill documents, and the 2 pack manifests.

---

## Executive Summary

The change is well-scoped and fails closed. The operand check is now a short, readable allowlist; the command-text check denies every shape whose meaning differs between POSIX shells and PowerShell; and per-segment target resolution is isolated in a new pure file that consumes the C1a scanner and option table without re-implementing tokenization. Tests are behavior-focused, deterministic, and cover both surfaces from one suite through `-ForEach` over the hook roots. The reviewer reran 1042 tests across 30 suites (0 failures), PSScriptAnalyzer (0 findings), and a formatter round trip (no drift) at HEAD.

The reviewer ran behavioral probes against `Get-OrchestrationCommandTarget` and `Test-ExemptOrchestrationOperand` (scratchpad script `probe732.ps1`, output quoted in the findings). They identified one functional gap in the path leg (CR-1, UNC and extended-length spellings resolve to the session root) and one over-broad fail-closed check (CR-2). Neither is a regression relative to the base, and neither contradicts an acceptance criterion. All findings are Non-blocking.

**Blocking findings: 0. Non-blocking findings: 9 (1 Medium, 5 Low, 3 Info).**

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Medium (Non-blocking) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (all 4 copies) | `$script:OrchestrationTargetAbsolutePattern` (line 31); path-leg loop in `Get-OrchestrationCommandTarget` (line 201) | **CR-1.** A path-leg input spelled as UNC (`\\server\share\...`) or extended-length (`\\?\C:\...`) normalizes to `//...`, fails the absolute pattern `^([A-Za-z]:/|/(?!/))`, and is treated as relative, so it contributes the session root instead of its own target. FR-3 rule 1 states that an absolute `file_path` contributes its own path; plan rule R1 narrowed "absolute" to the R0 pattern. In an epic-scope session whose root is ready, a Write into another, not-ready epic worktree spelled this way is evaluated against the session root. | Treat a path-leg input that begins with `//` as unresolved (for example rule token `path-not-absolute`, reason code `target-unresolvable`) rather than as relative, and add one row per spelling to the targets suite and to `EpicScopeTargets.Tests.ps1`. If deferred, record it as a follow-up candidate (FU-6) next to FU-1. | Fail-closed is the stated norm for an unresolvable target (spec D3). The current behavior equals the pre-change behavior for every path leg, so this is an incomplete closure, not a regression. | Reviewer probe: `UNC Write path | Resolved=True | Targets=C:/wt/coordinator`; `extended-length Write path | Resolved=True | Targets=C:/wt/coordinator`; `drive Write path | Resolved=True | Targets=C:/wt/other/src/x.ps1`. |
| Low (Non-blocking) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `Get-OrchestrationCommandTarget`, relocation loop (lines 223-227) | **CR-2.** The `GIT_DIR`, `GIT_WORK_TREE`, `GIT_COMMON_DIR`, and `GIT_INDEX_FILE` check is an ordinal case-insensitive substring search over the whole segment text. It also matches a file name such as `docs/legit_dir-notes.md` and a commit message that mentions `GIT_DIR`, which makes the target unresolvable and denies in epic scope. | Match the names only as environment-assignment prefix tokens (`NAME=...` before the command word) or as `env NAME=...` / `$env:NAME` forms, using the segment `Tokens` already available. | The error direction is fail-closed, so the cost is a false-positive deny in epic scope only. Documentation commits about git internals in an epic session are a plausible trigger. | Reviewer probe: `filename containing git_dir | Resolved=False | Detail=git-relocation: git -C C:/wt/coordinator add docs/legit_dir-notes.md`; `message mentioning GIT_DIR | Resolved=False`. |
| Low (Non-blocking) | `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `Get-OrchestrationEpicScopeDecision` (Claude lines 275-301; Codex lines 185-217) | **CR-3.** The verdict dispatch, the per-target readiness loop, and the 300-character session-root deny string are duplicated in both epic-scope files. Only the scope-resolver scriptblock and the Codex `apply_patch` leg differ. | Move the shared tail into the targets file (for example `Get-OrchestrationEpicTargetDecision -Verdict <v>`) so each surface supplies only its resolver and leg inputs. | Two copies of a deny string must stay in sync; the existing session-root wording is a contract that consumers match. The Codex gate is at 496 of 500 lines, so further growth in that family needs shared code. | `git diff ...HEAD -- .claude/hooks/...-epic-scope.ps1 .codex/hooks/...-epic-scope.ps1` shows identical added blocks. |
| Low (Non-blocking) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | Lines 25, 109, 146, 152, 202, 219, 231, 237, 270 | **CR-4.** Nine lines exceed 120 characters (maximum 196 at line 152), and several carry compound single-line bodies (`if (...) { ... } elseif (...) { ... } else { ... }` at line 146; `foreach` inside `else` at line 231). | Wrap the long conditions and split compound bodies onto separate lines. | D7 sets 120 characters as the helpers-file target; no analyzer rule enforces it, and the targets file was not in the AC scope. Dense lines make a security-relevant parser harder to review. | Reviewer `awk 'length($0)>120'` over the targets file. |
| Low (Non-blocking) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `Get-OrchestrationTargetResult` (line 97) | **CR-5.** The function constructs a result object but uses the `Get-` verb. It was renamed from `New-` in commit `8918b5c0` to clear `PSUseShouldProcessForStateChangingFunctions`. | Prefer `ConvertTo-OrchestrationTargetResult`, or keep `New-` with a justified `SuppressMessageAttribute` (it changes no system state). | Verb accuracy aids discovery; the rename trades meaning for an analyzer pass. | `git show 8918b5c0 -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`. |
| Low (Non-blocking) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `Get-OrchestrationGitSelectorTarget` (line 129) | **CR-6.** `[array]::IndexOf($Token, 'git') + 1` locates the first literal `git` token. The caller passes only segments whose `CommandWord` is `git`, so the first `git` token is the command word in every tested form. The function itself does not guard against a token array with no `git` (it would start at index 0). | Pass the command-word index from the scanner record, or return an unresolved result when `IndexOf` is -1. | Defensive guard for a function documented as reusable. | Code reading; no failing case found. |
| Info (Non-blocking) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | path-leg loop (line 201) | **CR-7.** A relative path-leg input that climbs (`../other/src/x.ps1`) contributes the session root. This matches FR-3 rule 1 as written. It is relevant mainly to Codex `apply_patch` markers, which are usually relative. | Consider treating a relative path with a `..` segment as unresolved in epic scope, together with FU-1 and FU-4. | Same class as FU-1 (path-leg `..` gap). | Reviewer probe: `relative dotdot path leg | Resolved=True | Targets=C:/wt/coordinator`. |
| Info (Non-blocking) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `Resolve-OrchestrationEpicTargetVerdict` (lines 263-278) | **CR-8.** When target resolution fails and the session root is not epic scope, the verdict is `none` and the single-feature path decides, even if the unresolved selector names an epic worktree. This is the D3 contract (only the session root and resolved targets are candidates). Test file naming: the targets rows added for coverage live in `enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1`, named after the process step rather than the unit. | Keep the behavior (it is specified). Fold the `C1bCoverage` rows into `enforce-orchestration-preimplementation-gate-targets.Tests.ps1` when that file has headroom (306 lines today), or rename the file after the unit. | Unit-named test files are easier to find from the production file. | `EpicScopeTargets.Tests.ps1` rows "keeps the single-feature decision for ... outside epic scope". |
| Info (Non-blocking) | `.agents/skills/epic-plan/SKILL.md` (and mirror) | `## Integration Commit Form` | **CR-9.** The new section lists the single-quoted `$`, single-quoted backtick, and `--trailer` forms but not the one-paragraph multi-`-m` trailer form that the Claude skill documents and the gate admits. | Add the multi-`-m` form for parity with `.claude/skills/epic-plan/SKILL.md`, or state that it is admitted but not recommended. | FR-6.1 names three forms, so the AC is met; the omission is a documentation parity gap between surfaces. | `git diff ...HEAD -- .agents/skills/epic-plan/SKILL.md`. |

---

## Detailed Review

### Helpers (`enforce-orchestration-preimplementation-gate-helpers.ps1`)

- `Test-OrchestrationCommandTextUnresolvable` now returns true for any `\`, which subsumes the two escaped-quote checks and the in-double-quote backslash branch that were removed. The outside-quote set gains `{ } , ( ) @`. The quote-state scan is otherwise unchanged.
- `Test-ExemptOrchestrationOperand` is now: allowlist (`-cnotmatch '^[A-Za-z0-9._/-]+$'`), not rooted, no `..` segment, and an exempt prefix. The empty-string guard is subsumed by the `+` quantifier. Probe results: `docs/features/active/./x/a.md` exempt; `docs/features/active/../../src/x.ps1`, `docs/features/active/x/*.md`, `docs/features/activex/a.md`, and `docs/features/active` not exempt.
- `$script:PathspecWildcardCharacters` stays for `Test-ExemptOrchestrationSelector`; its comment was updated accordingly.
- Header comments cite #735 and the research artifact. Line 83 (144 characters) predates the branch and is optional under D7.

### Targets (`enforce-orchestration-preimplementation-gate-targets.ps1`)

- Pure string logic; no dot-source of its own; dependencies are documented in `.NOTES`. It calls only `Read-CommandLineSegment`, `Get-CommandLineGlobalOption`, and `Get-CommandLineInvocation` from C1a and never the helpers splitter or tokenizer (reviewer `grep` count 0).
- Rule order is first-failure-wins with a single rule token in `Detail`, which keeps deny reasons diagnosable.
- `-c core.worktree=...` is treated as relocation, which goes beyond FR-3 rule 5 in the fail-closed direction.
- Distinct-target computation is quadratic through a pipeline; target counts are small, so this has no practical cost.

### Epic-scope decisions (both surfaces)

- The session-root deny wording is unchanged, so existing consumers that match on it continue to work; new denies carry `PREIMPLEMENTATION_GATE_BLOCKED: <reason-code>: ...`.
- The Codex surface detects an `apply_patch` body by its first non-empty line and decides it as a path leg over the marker paths, including `*** Move to:`.

### Tests

- New suites run once per surface through `-ForEach @{ Surface = ... }`, which keeps the four byte-identical copies honest without duplicating rows.
- Gate-level suites mock only the worktree I/O seams inside `EpicScopeResolution` and use synthetic roots; no file is created.
- Fail-before evidence exists for every new deny row of #732 and #738 (`fail-before-732.md`: 58 planned failures; `fail-before-738.md`: 20). The #745 trailer rows passed before the change; they pin existing behavior rather than demonstrate a fix.

### Documentation

- Quoting-rule paragraphs in all six skill files state the backslash rule, the `{ } , ( ) @` rule, and the operand character set. Mirrors are byte-identical.

---

## Positive Observations

- The allowlist replaces five special-case checks (colon magic, drive letters, separator rewrite, wildcard literal prefix, and empty input) with one rule that also covers non-ASCII look-alikes.
- The scope resolver is injected as a scriptblock, so the targets file does not depend on either surface's resolution module.
- The plan recorded the merged C1a API before any edit and adjusted when the first verification found a removed helper (`c1a-api-verification.round1-blocked.md`).

---

## Verdict

**Approve with Non-blocking recommendations.** Blocking findings: 0. CR-1 is the most material item; it is recommended either as a small pre-merge change or as a recorded follow-up.
