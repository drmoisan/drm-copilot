# Code Review: legacy-discovery-agent-roles (#365)

**Review Date:** 2026-07-18
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365`
**Feature Folder Selection Rule:** Single active feature folder whose suffix matches the issue number (365) in the branch name; single-version (no `v1/`/`v2/` subfolders), so artifacts are written at the feature root.
**Base Branch:** `origin/epic/legacy-discovery-and-parity-integration` (merge base `f18c1c16`)
**Head Branch:** `feature/legacy-discovery-agent-roles-365` (HEAD `5335075c`)
**Review Type:** Initial review

Template source: bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`, the asset resolved by the `code-review-template` selector; read directly from the bundled source path because the MCP server surface was unavailable in this session.

---

## Executive Summary

The branch adds four domain-neutral agent persona definitions under `.claude/agents/` and a 485-line Pester structural test at `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1`, plus feature-folder evidence and acceptance-criteria check-offs. The scope is small, well-bounded, and matches the spec exactly: no executable production code, no skills, no hooks, no `settings.json` entries, and no `resources/` mirror copies. Evidence reviewed includes the full branch diff, refreshed PR-context artifacts, the executor's baseline and final QA-gate evidence, the JUnit and JaCoCo artifacts under `artifacts/pester/`, and an independent reviewer re-run of the new test suite at HEAD (15/15 pass).

**What changed:**
Four ~64-line Markdown persona files (`legacy-parity-analyst`, `runtime-characterization-analyst`, `requirements-reconciler`, `migration-coverage-reviewer`), each with the uniform frontmatter contract (`name`, `description`, `model: sonnet`, `tools: Read/Grep/Glob/"Write(discovery/**)"`, `memory: project`) and a body that names its consumed schemas, produced schema, domain-profile fields, and the runtime `artifacts.root` deferral to #9004. One structural test proves the detection logic on in-memory fixtures before asserting the seven spec'd invariants on the real files.

**Top 3 risks:**
1. The personas reference the #9001 domain-profile and #9002 schema contracts, which are not yet present on the integration tip; a contract drift in those parallel features would require persona-body updates (documented, accepted epic risk).
2. Frontmatter conformance beyond the seven test assertions (exact `tools` list, `memory` value, absence of `skills:`/`hooks:`) is not machine-checked; a future edit could drift without failing the suite (Info finding below).
3. The `Write(discovery/**)` static scope is a default, not an enforcement mechanism; enforcement is deferred to #9004 as the spec decides — downstream feature ordering matters.

**PR readiness recommendation:** **Go** — all toolchain gates pass with independent confirmation, all spec'd invariants are machine-verified, and no Blocker or Major findings exist.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` | assertions 2-4 (lines 374-427) | The suite checks presence of `tools:` and `memory:` but not the exact tool list, the `memory: project` value, or the absence of `skills:`/`hooks:` fields (spec AC2/AC3). This matches the spec's deliberate seven-assertion scope; the criteria are verified by executor grep evidence and reviewer inspection. | Optional follow-up (non-blocking): extend the suite with tools-exactness, `memory` value, and `skills:`/`hooks:` absence assertions when #9008 revisits these personas. | Machine-checked invariants resist silent drift better than review-time greps. | Reviewer grep `^(skills\|hooks):` over the four personas: zero matches; file reads confirm exact tool lists and `memory: project`. |
| Info | `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` | `Get-FrontmatterScalar` (lines 130-140) | `$Field` is interpolated into a regex pattern unescaped. All call sites pass literal field names (`name`, `model`), so there is no current defect. | None required; if the helper is ever reused with caller-supplied field names, escape with `[regex]::Escape($Field)`. | Defensive-regex hygiene for a helper that could be copied elsewhere. | Inspection of lines 130-140 and both call sites (lines 400, 419). |
| Info | `docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/issue.md` | `## Acceptance Criteria (early draft)` | The GitHub issue #365 body still carries placeholder criteria ("Criterion 1", "Criterion 2") per the PR-context issue digest, and the local `issue.md` AC section is marked "early draft". This is consistent with full-feature mode, where `spec.md` and `user-story.md` are the authoritative AC sources. | None for this review; the PR author may refresh the GitHub issue body when authoring the PR. | Avoids confusion for readers who start from the GitHub issue. | `artifacts/pr_context.summary.txt` "Issue digests" section. |

No Blockers, Major, Minor, or Nit findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fixture-first structure (prove detection logic on synthetic positives/negatives, then run the same helpers over real files) follows the `test-name-uniqueness.Tests.ps1` precedent exactly and makes the suite self-validating: a broken helper fails the fixture tests, not just silently passing real files.
- Repo-root resolution walks up from `$PSScriptRoot` to the nearest `.claude` ancestor with an explicit `throw` on failure, keeping the suite CWD-independent across terminal and Test Explorer execution.
- All collision, banned-substring, and required-reference sets are data-driven (`$script:` arrays/hashtable), so extending to a fifth persona is a data change.
- Aggregate assertions accumulate per-slug failure detail and surface it through `-Because`, producing actionable diagnostics.

#### API and safety notes

- `Set-StrictMode -Version Latest` at file top; approved verbs on all six helpers; `[Parameter(Mandatory)]` throughout with deliberate `[AllowEmptyString()][AllowNull()]` on the frontmatter parameter to handle the missing-frontmatter edge case.
- Assertion 5 correctly excludes the four expected slugs from the "other basenames" set before the disjointness check, avoiding self-collision false positives.
- PSScriptAnalyzer: 0 errors, 0 warnings (executor evidence, `ok: true`, no autofix rewrite).

#### Error handling and logging

- Fail-fast `throw` with an actionable message when the repository root cannot be resolved. No logging is needed in a structural test; Pester output carries the diagnostics.

### Markdown persona audit (agent definitions)

- All four personas share an identical structural skeleton (Role, Schemas Consumed, Schema Produced or Updated, Domain Profile, Artifacts Root and Write Scope, Constraints), which keeps them reviewable side by side and matches the spec's Per-Persona Design mapping exactly (consumed/produced schemas and domain-profile fields verified line by line against spec sections for all four).
- Domain neutrality holds: independent case-insensitive grep for the seven banned identifiers over all four files returned zero matches, corroborating structural-test assertion 6.
- Each body documents the runtime-`artifacts.root` authority and the #9004 enforcement deferral, implementing spec Decision 1 faithfully.

---

## Test Quality Audit

Coverage, regression, and QA evidence are all present and internally consistent. The executor recorded baseline (pre-change) and final (post-change) runs in coverage mode with identical scoped counters (LINE 0/2068), demonstrating no regression; the reviewer parsed the JaCoCo artifact independently and re-ran the new suite at HEAD.

### Reviewed test and QA artifacts

- `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` — 15 tests covering all seven spec assertions plus fixture-proofing of every helper; reviewer re-run at HEAD: 15/15 pass in 565 ms.
- `artifacts/pester/pester-junit.xml` — full claude-runtime scope: tests=35, failures=0, errors=0, disabled=0 (includes the four pre-existing suites, all green).
- `artifacts/pester/powershell-coverage.xml` — JaCoCo counters parsed by reviewer: INSTRUCTION 0/2815, LINE 0/2068, METHOD 0/181, CLASS 0/28; identical to the recorded baseline headline.
- `evidence/baseline/*` and `evidence/qa-gates/*` (8 files) — schema-valid (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`), covering Phase 0 instruction reads, format/analyze/test baselines, final QC loop, and AC closure.

### Quality assessment prompts

- **Determinism:** No randomness, no wall-clock use, no network; in-memory fixtures; CWD-independent path resolution. Reviewer re-run reproduced executor results exactly.
- **Isolation:** Each `It` targets one helper behavior or one structural assertion; failures name the offending persona and violation.
- **Speed:** 565 ms for 15 tests (reviewer measurement); 3.618 s for the 35-test scope (JUnit).
- **Diagnostics:** `-Because` clauses carry accumulated per-slug failure lists (e.g., which persona, which banned term, which absent reference).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: Markdown personas and a structural test only; no credentials, tokens, or endpoints. |
| No unsafe subprocess or command construction | ✅ PASS | The test invokes no external commands; pure string/regex/filesystem-read logic. |
| Input validation at boundaries | ✅ PASS | Mandatory parameters; null/empty frontmatter handled explicitly; regex escaping applied where caller data is matched (`[regex]::Escape($token)` in `Get-MissingReference`). |
| Error handling remains explicit | ✅ PASS | Explicit `throw` on unresolvable repo root; `Set-StrictMode -Version Latest`. |
| Configuration / path handling is safe | ✅ PASS | `Join-Path` throughout; no string-concatenated paths; least-privilege `Write(discovery/**)` tool scope on all four personas with enforcement deferral documented. |

---

## Research Log

No external research was required. All review inputs were repository-local: the branch diff, refreshed PR-context artifacts, feature-folder docs and evidence, bundled templates, and repo validators.

---

## Verdict

The change is ready for the normal PR flow. The implementation matches the spec's resolved decisions precisely (uniform `sonnet` model, four-tool least-privilege allowlist, omitted `skills:`/`hooks:`, machine-checked AC4 body content), the epic-wide domain-neutrality and naming-collision invariants are verified both by the structural test and by independent reviewer checks, and the toolchain evidence is complete, schema-valid, and independently confirmed at HEAD. The three Info findings are non-blocking observations; none requires remediation before merge.
