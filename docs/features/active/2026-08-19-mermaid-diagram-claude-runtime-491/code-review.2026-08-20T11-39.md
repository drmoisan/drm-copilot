# Code Review: Mermaid Diagram Claude Runtime Port (#491)

---

**Review Date:** 2026-08-20
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491`
**Feature Folder Selection Rule:** Single active folder whose suffix matches the issue number in scope; confirmed by the changed scoping docs in the PR context summary.
**Base Branch:** `main` (merge base `71aebdb9`)
**Head Branch:** `drm-copilot-wt-2026-08-19T08-39` @ `3338400c`
**Review Type:** Initial review

---

## Executive Summary

This branch ports the Mermaid Chart Copilot instruction pack into the native Claude runtime as four coordinated surfaces: a path-scoped rule (`.claude/rules/mermaid.md`), a skill with nine per-type syntax references (`.claude/skills/mermaid-diagram/`), a PreToolUse hook (`.claude/hooks/enforce-mermaid-validation.ps1`), and a four-module dependency-free structural validator (`.claude/lib/mermaid/`). Distribution (17 byte-identical mirrors, 16 `core.json` entries, dual runsettings registration) is part of the same change. The scope is 92 changed files; all production code is PowerShell.

The implementation quality is high. The validator's false-positive discipline — quote-aware scanning, statement-keyword exemptions, arrow masking, post-colon cutoffs, and a seven-item fail-open policy — is implemented exactly as researched, and each safeguard is covered by a named accept-path test. The hook is thin, read-only, and protocol-correct (deny travels in JSON, exit is 0 in every case). The reviewer independently re-ran every gate (analyzer, formatter, full 3107-test Pester run with coverage regeneration at head, both pytest distribution suites, Jest completeness, nine live hook probes) and reproduced every executor-reported figure exactly.

**What changed:**
5 new PowerShell production files (390–496 lines each), 6 new + 1 modified Pester suites (300 net-new tests), rule/skill/references docs, `settings.json` hook registration (repo + mirror), `core.json` manifest entries, runsettings coverage registration (repo + bundled parity copy), the upstream instruction pack under `.github/instructions/`, the feature folder with 30 evidence artifacts, and five `docs/features/potential/` entries for out-of-scope latent defects.

**Top 3 risks:**
1. False-positive blocking of ordinary Markdown writes is the feature's structural risk; it is mitigated by the accept matrix (22 constructs), the fail-open policy (all seven items tested), the opt-out marker, and live-probe confirmation — residual risk is low but nonzero for Mermaid constructs outside the researched catalogue.
2. Keyword-allowlist staleness as Mermaid adds diagram types; mitigated by warn-and-allow drift behavior (tested) and the pinned-version header, but the warning is only visible in the decision reason.
3. The validator is deliberately weaker than a real parse; semantically invalid diagrams that render as GitHub error boxes for deep-grammar reasons still pass. Recorded honestly in the rule ("What the gate does NOT do") and spec D1.

**PR readiness recommendation:** **Go** — zero Blocker/Major findings; all gates green on independently re-run evidence.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1` | managed-diagram Context (lines ~207–256) | No single test combines the opt-out marker with a managed diagram to assert the marker cannot suppress the managed guard (a spec D3 statement). | Optionally add one case in a follow-up: a Markdown-style marker payload against a managed `.mmd` path, asserting `MERMAID_MANAGED_DIAGRAM_BLOCKED`. No change required now. | Suppression is structurally impossible today — the marker path exists only inside `Get-MermaidFenceBlock` (Markdown fences), while the managed gate runs first in `Invoke-MermaidValidationDecision` keyed on `.mmd`/`.mermaid` paths — but a regression test would pin the property against future refactors. | Code inspection of `Invoke-MermaidValidationDecision` ordering; live probe P8 (managed Edit denied); marker probes P4/P7. |
| Info | `artifacts/pester/pester-junit.xml` | run totals | Executor's recorded run counted 3086 passed; the reviewer's fresh run at the same head counted 3107 (both 0 failed, 9 skipped). The +21 delta lies in repo-state-dependent dynamically generated cases outside this feature's suites. | None. Noted so a future reader does not misread the drift as a missing/added test in this feature. | This feature's own contribution is exactly 300 tests in both runs; coverage figures for the five new files are byte-identical across both runs. | `evidence/qa-gates/final-poshqc-test.2026-08-20T11-40.md` vs the reviewer's `Invoke-PoshQCTest` run (3107/0/9). |
| Info | `.claude/hooks/enforce-mermaid-validation.ps1` | `Invoke-MermaidValidationDecision`, Markdown-with-no-fence path | A Markdown write with zero Mermaid fences returns `$null` (silent allow) while an Edit payload returns an explicit-allow decision; two allow styles coexist in one function. | None required; the distinction is deliberate ("none of this hook's business" vs "judged and allowed") and documented in the function help. | Behavior is identical from the harness's perspective (exit 0; absent or `allow` JSON both allow). | Live probes P2 (explicit allow) and P6 (silent allow, empty stdout, exit 0). |
| Info | `.github/instructions/mermaid.instructions.md` | whole file | The branch adds a file under `.github/instructions/`, the canonical policy surface agents must not modify. | None. This is the upstream Mermaid Chart pack, downloaded verbatim in user-authored commit `90085df9`; it is the source artifact the feature ports, not an agent policy edit. | Distinguishing a user-supplied upstream source from an agent policy modification prevents a false policy-violation flag. | `git log -1 --format='%an %ae' 90085df9` -> Dan Moisan. |

No Blockers or Major findings. No Minor findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- **Module decomposition matches the researched seams.** Grammar data, single-line scanning, fence tracking, and orchestration are four files with a strictly linear import graph; the hook holds only I/O, scope checks, and protocol formatting. All logic is importable and unit-testable without a subprocess.
- **The false-positive machinery is precise, not heuristic.** Quoted spans are masked before bracket counting and arrow scanning; arrow tokens are masked before bracket counting (so ER `||--o{` braces are not brackets); statement-keyword lines are exempt from arrow and bracket judgement but not the quote check; closers are clamped at zero with an explicit comment explaining why (`class Animal {` exemption asymmetry). Each rule traces to a named research §4 construct and a named accept test.
- **The fail-open policy is genuinely fail-open.** All seven decline-to-judge paths return allow (four verified by live probe, all seven by tests), and the near-miss misspelling rejection is bounded to a one-edit radius so it cannot swallow genuinely new diagram types (documented at the check site).
- **The 500-line limit was met by real compaction, not splitting games.** `MermaidGrammar.psm1` at 491 lines holds the full 11.17.0 keyword and arrow tables with per-entry provenance flags (`Verified`).
- **Distribution was treated as part of the deliverable (D5).** The nine `references/*.md` files — the class neither completeness suite enumerates — have explicit `core.json` entries, and the negative-control evidence proves both suites fail without the mirrors/entries.

#### API and safety notes

- Every function is an advanced function with `[CmdletBinding()]`, `[OutputType()]`, and deliberate `[AllowEmptyString()]`/`[AllowNull()]` annotations; the reviewer specifically verified the empty-content path through `Get-MermaidFenceBlock` cannot throw a parameter-binding error (it accepts and returns an empty array).
- The hook is a read-only gate: no file writes, no state, no subprocess, no Python (gate-verified by `enforcement-hooks-no-python-invocation.Tests.ps1`).
- `Test-MermaidManagedDiagram` requires a non-empty `id:` value, so an unconnected placeholder does not lock a file — a thoughtful edge the tests pin (`does not report a managed diagram when the id value is empty`).
- The structured result (`Verdict`/`DiagramType`/`Findings`/`Warnings`) is the promised CI-deep-check seam; findings carry class, line, and message, and `LineOffset` keeps fence-embedded line numbers file-relative (tested).

#### Error handling and logging

- Narrow `try/catch` only around the three genuinely fallible operations (JSON parse, module import, file read), each converting to a documented fail-open sentinel. The DELIBERATE DIVERGENCE header note explains why this hook allows on malformed input where `enforce-evidence-locations.ps1` throws — exactly the annotation that prevents a well-meaning "fix" into a false-positive machine.
- No logging by design: the hook communicates exclusively through the decision JSON, and warnings travel in the decision reason. Consistent with the hook protocol (stdout belongs to the harness).

---

## Test Quality Audit

Coverage, regression, distribution, and end-to-end evidence are all present and were independently re-executed. No verification gap remains.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1` — 43-case verdict matrix: per-type accepts, every reject class with line-number assertions, CRLF/LF byte-equivalence, frontmatter variants, line offsets, all seven fail-open items, managed-diagram detection. Re-run green.
- `tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1` — 22 accept cases; reviewer cross-checked one-for-one against the research §4 false-positive catalogue: all eleven constructs covered (quoted-label brackets; `#quot;`/entities with trailing-backslash-before-quote; Markdown backtick strings; Unicode; `%%` in quoted spans; subgraph+direction; all eight statement keywords individually; `<br/>`/angle brackets; sequence post-colon text; free-text-type unbalanced look-alikes; backslashes), plus generics (`~T~`), ER word aliases, and mid-arrow text forms beyond the catalogue.
- `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1` — 28 cases spanning every decision path, the opt-out scope rules (honored / one-block-only / blank-line-not-honored), the mocked on-disk seam (including a call-count assertion), the fail-open matrix, the missing-module guard, a named negative control, and 3 real-subprocess protocol cases asserting compact JSON + exit 0.
- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` — hook count 14 -> 15 and a round-tripped deny-shape assertion for the new hook.
- `evidence/regression-testing/distribution-negative-control-{parity,manifest}.*` — genuine observed failures (exit 1, named failing tests, verbatim assertion messages listing the exact missing files), not asserted ones; the reviewer re-ran the after-state green (13 pytest, 15 Jest).
- `evidence/qa-gates/coverage-delta.2026-08-20T11-40.md` — every figure reproduced by the reviewer's own XML parse of both the preserved baseline and a freshly regenerated report at head: 95.97% -> 96.21%, 59 common files, 0 regressions, exactly 5 new files at 99.30/100/100/98.66/89.04%.
- Live probes (reviewer, 9 cases through `pwsh -NoProfile -File`): invalid `.mmd` deny naming class+line+pointer; valid allow; invalid fence deny with file-relative line; opt-out honored; opt-out scoped to one block; nested fence allowed; malformed input silent-allow with exit 0; managed Edit denied with sync pointer; unmanaged Edit allowed.

### Quality assessment prompts

- **Determinism:** pure string fixtures; the only filesystem dependency is mocked; no clock, RNG, sleeps, or network. The three subprocess cases pass fixed env JSON.
- **Isolation:** one construct per `It`; module suites never touch the hook; hook suite dot-sources behind the guard.
- **Speed:** 341 tests in 8.02s; the full 3116-test repo run completes with coverage in minutes.
- **Diagnostics:** assertions name expected verdicts, finding classes, and line numbers, so a failure localizes to a single rule.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; content is grammar tables, scanning logic, docs, and manifests. |
| No unsafe subprocess or command construction | ✅ PASS | The hook starts no subprocess ("invokes no Python and starts no subprocess", verified by inspection and the no-python gate suite); tests spawn only `pwsh -NoProfile -File <fixed path>`. |
| Input validation at boundaries | ✅ PASS | Tool-input JSON parsed with `-ErrorAction Stop` inside try/catch; every field access goes through `Get-MermaidToolInputField` (null-safe PSObject property lookup); path scope checked before any content scan. |
| Error handling remains explicit | ✅ PASS | Each catch returns a documented sentinel; no silent swallow without a stated fail-open rationale. |
| Configuration / path handling is safe | ✅ PASS | Module resolution is `$PSScriptRoot`-relative with `Test-Path -PathType Leaf`; extension matching normalizes `\` to `/` and anchors on the suffix; `-LiteralPath` used for on-disk reads. |
| Read-only gate invariant | ✅ PASS | No `Set-Content`/`New-Item`/`Out-File`/state write anywhere in the hook or modules. |

---

## Research Log

No external research was required beyond the feature's own two research artifacts, which the reviewer read and used as the cross-check baseline: `research/mermaid-validation-technology.2026-08-19T08-39.md` (grammar table, §4 false-positive catalogue, fail-open policy) and `research/claude-runtime-integration-mechanics.2026-08-19T08-39.md` (referenced; hook protocol and distribution mechanics were instead verified directly against the delivered code and live probes). The upstream pack `.github/instructions/mermaid.instructions.md` was read in full for the capability-completeness cross-check.

---

## Verdict

The change is ready for normal PR flow. Zero blocking or major findings; the four Info notes require no action before merge. The implementation is faithful to its spec's seven binding decisions, the false-positive surface is defended by an explicit accept matrix plus a tested fail-open policy, the gate's limits are honestly documented rather than overclaimed, coverage clears the uniform thresholds with zero regressions, and distribution parity is proven by both negative controls and green suites. This conclusion is consistent with the Findings Table and the **Go** recommendation above.
