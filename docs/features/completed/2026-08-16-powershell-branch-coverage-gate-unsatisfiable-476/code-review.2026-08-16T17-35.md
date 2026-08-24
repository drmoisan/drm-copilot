# Code Review: PowerShell Branch-Coverage Gate Exemption (#476)

**Review Date:** 2026-08-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476`
**Feature Folder Selection Rule:** Single active folder whose numeric suffix matches the issue number in the branch name.
**Base Branch:** `main` (`origin/main` @ `687380a6`)
**Head Branch:** `bug/powershell-branch-coverage-gate-unsatisfiable-476` @ `0cb97bcf`
**Review Type:** Initial review
**Template source:** Bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` (the file the MCP resolver serves), read directly because MCP tools are unavailable in this session.

---

## Executive Summary

The branch amends repository coverage policy so the `>= 75%` branch-coverage threshold applies only to languages whose tooling measures branch coverage, exempting PowerShell (Pester) and bash (kcov). The diff is 42 Markdown files: 9 root policy/documentation edits (including `README.md`), 8 byte-identical bundle mirrors, and 25 new feature-folder documents and evidence artifacts. No production code, test, hook, script, workflow, or configuration file changed.

**What changed:** `.claude/rules/powershell.md` replaces its former unconditional branch-threshold bullet with a four-part carve-out structurally parallel to the existing bash precedent (`.claude/rules/shell.md:68-70`): it names Pester and its actual metrics (command/instruction and line coverage), preserves the `>= 85%` line threshold with the `quality-tiers.md` cross-reference, states that branch coverage is not measurable by Pester, and disclaims the existence of a PowerShell branch-coverage gate. The shared files (`general-unit-test.md`, `quality-tiers.md`, `feature-review-workflow/SKILL.md`, `agents/feature-review.md`, `powershell-qa-gate/SKILL.md`, the two `.agents/**` Codex restatements, and `README.md:298`) attach the same qualification to the branch clause only, leaving the line clause and the no-regression clause unconditional.

This reviewer is the gate whose prior application of the unqualified rule produced the finding this change resolves. The amendment was therefore evaluated on independently verified evidence, not accepted on assertion: Pester 5.6.1's module source contains zero occurrences of the string `branch` (recursive `Select-String` over the installed module), so the tool cannot emit a `BRANCH` counter in any output format and the former threshold was unevaluable by construction. The enforcement hook `validate-feature-review-coverage.ps1` already returned `$null` for zero-`BRANCH`-counter reports (line 195) and skipped the 75% floor on `$null` (lines 323-324), so the change closes a prose/mechanism gap without weakening any operating gate. The amendment does not relax any other gate: the `>= 85%` line threshold, the no-regression clause, and the Python/TypeScript/C# branch gates are textually intact, and the exemption is explicitly a threshold exemption rather than a measurement exclusion (the denominator obligation is restated at three amended sites).

**Top 3 risks:**
1. Future drift could reintroduce an unqualified PowerShell branch requirement, since no test pins the new carve-out wording (the spec records a content-substring pin as an optional follow-up; not adopted in this change).
2. The known, separately-filed `CodeCoverage.Path` opt-in allow-list in `pester.runsettings.psd1` still excludes unlisted PowerShell production files from measurement, which is in tension with the Coverage Exclusion Policy; this change deliberately does not address it and correctly documents it as a follow-up.
3. Downstream consumers keep the stale policy until the next extension/mcp-server release and push-down re-run; the stalled consumer remediation cycle is unblocked only after that release.

**PR readiness recommendation:** **Go** — zero Blocker/Major/Minor findings; two informational observations below require no action.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/ac14-edit-surface.2026-08-16T17-39.md` | Output Summary | The evidence states `git diff --name-only 687380a6` returns exactly 17 files; at the committed branch head the same command returns 42 because the feature folder (25 documentation/evidence files, then untracked and noted as such in the artifact) is now committed. | No action. The 25 additional files are all under the feature's own folder, which the artifact itself identifies as permitted alongside the closed 17-file edit surface. | The 17-file claim concerns the policy edit surface, which this reviewer confirmed is exactly 17 (all 17 `M` entries match the enumerated list; all 25 `A` entries are feature documentation). | `git diff --name-status 687380a6..HEAD`: 17 `M` + 25 `A`, zero non-`.md` entries |
| Info | `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/` | artifact filename timestamps | Several evidence timestamps (up to `17-51`) postdate the sole branch commit's author time (`17:30:22 -0400`) and the review-session wall clock, indicating a clock or timezone offset between the executor session and this environment. | No action. Content, not timestamps, was verified: every load-bearing evidence claim was independently re-checked at head `0cb97bcf`. | Timestamps are advisory ordering metadata; the git commit is the authoritative content anchor. | `git log --format="%h %ad" --date=iso-local 687380a6..HEAD` vs artifact filenames |
| Nit | `.claude/rules/quality-tiers.md` (and mirrors, and `.agents/skills/quality-tiers/SKILL.md`) | Rationale paragraph | The added sentence uses the British spelling "licence" ("not a licence to exclude files from measurement") in a repository that otherwise uses American spellings. | Optional: normalize to "license" in a future editorial pass. Parity is unaffected because all four copies carry the identical spelling. | Consistency of prose style; no semantic effect. | Diff hunk for `.claude/rules/quality-tiers.md:51` |

No Blocker, Major, or Minor findings.

---

## Verification Detail

### Claims verified independently (not accepted on assertion)

| Claim | Method | Result |
|---|---|---|
| Pester emits no `BRANCH` counter in any output format | Recursive `Select-String -Pattern 'branch'` over installed Pester 5.6.1 module source (`.ps1`/`.psm1`) | 0 matches; claim confirmed |
| Hook already `$null`-skips absent branch metric | Read `.claude/hooks/validate-feature-review-coverage.ps1` | Line 195 returns `$null` on zero `BRANCH` counters; lines 323-324 gate the floor check on `$null -ne` — confirmed; hook and mirror absent from the diff |
| `>= 85%` line threshold and no-regression preserved for PowerShell | Diff inspection of all 9 root edits | Confirmed: `.claude/rules/powershell.md:63` and the changed-lines bullet are untouched; every qualification attaches to the branch clause only |
| Python/TypeScript/C# retain `>= 75%` branch gates | Diff inspection + `git diff --name-only` on the three language rule files | Confirmed: `>= 75%` restated for branch-capable languages at every amended site; `python.md`, `typescript.md`, `csharp.md` unmodified |
| Threshold exemption, not measurement exclusion | Read-through of every added line in the policy diff | Confirmed: denominator obligation restated in `powershell.md`, `general-unit-test.md`, `quality-tiers.md`; no exclusionary wording found |
| 8 root files each have a byte-identical bundle mirror in the same change | SHA256 per pair + reviewer re-run of the three parity/completeness pytest suites | 8 of 8 MATCH; 20 tests passed, exit 0 |
| No command-coverage gate introduced | Diff inspection | Confirmed: both command-coverage mentions are descriptive and carry explicit no-threshold disclaimers |
| Inventory swept (no residual unqualified binding) | Independent `rg -i --hidden` sweep over `.claude/`, `.agents/`, `README.md`, and both bundle payloads at head | Zero unqualified PowerShell branch-threshold bindings remain; `shell.md` byte-unchanged |

### Structural parallel to the bash precedent

The carve-out reproduces the four-part shape of `.claude/rules/shell.md:68-70` (tool + measured metrics; line threshold with cross-reference; incapability statement; gate disclaimer) and adds one sentence making the threshold-versus-measurement distinction explicit. The deviation from the bash precedent — touching shared files rather than only the language rule file — is justified in `spec.md` Root Cause Analysis by the enumeration asymmetry: PowerShell, unlike bash, is explicitly enumerated with FAIL instructions in the feature-review surface, so a language-file-only carve-out would have left the shared files contradicting it.

### Tone and documentation quality

All amended prose is factual, neutral, and evidence-first, consistent with `.claude/rules/tonality.md`. The amendments state capabilities as facts about tools, preserve exact numeric thresholds, and avoid hedged or promotional wording. Feature-folder documentation (issue, spec, plan, research, 21 evidence artifacts) is complete and internally consistent, with one timestamp caveat noted in the findings table.

### Typed-Python review

Not applicable: zero Python files changed on the branch.

---

## Readiness

**Go.** The change set is minimal, closed, mirrored, independently verified, and leaves every evaluable gate intact. Blocking findings: 0.
