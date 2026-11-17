# Code Review: Harness Survey, Gold-Standard Contracts and Parity Matrix (#1025)

---

**Review Date:** 2026-11-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`
**Feature Folder Selection Rule:** the folder whose name carries the canonical issue number 1025, named by the delegation prompt.
**Base Branch:** `epic/shared-agent-harness-layer-integration` (merge base `bba58bac90a30fd9f4bd3b6bf5ae8d69bf86a0ee`, equal to the current `origin/epic/shared-agent-harness-layer-integration` tip)
**Head Branch:** `feature/harness-survey-gold-standard-contracts-parity-matrix-1025` (head `b1a45cc0f5102930d45e6cf89903f91986969c5f`, pushed)
**Review Type:** Final re-audit after light remediation cycle 3 (prior review `code-review.2026-11-17T06-52.md`)

---

## Executive Summary

The branch delivers epic #1018 child 1: the skill survey, the difference classification and approval record, 65 gold-standard contracts at `.agents/skills/<name>/references/standard.md` with byte-identical bundle copies, the parity matrix (655 entries) with its Draft 2020-12 schema, and three PowerShell modules with four Pester test files. This re-audit covered the full diff `bba58bac..b1a45cc` (326 files) and, in detail, light remediation cycle 3 (`89fa11914..b1a45cc0f`: three contracts, their three bundle copies, two inputs-file checkboxes and five evidence records).

**Findings R6 (CR-15) and R7 (CR-16) are closed, and the CR-17 nit is applied.** Each rewritten item was read against the `SKILL.md` section it names and matches it in substance:

- `python-change-budget-router` OB-3 now reads "Promotion and folder lifecycle steps run through the repository automation tools, and when the required tool is unavailable the skill stops before promotion begins." This is the required text and matches the C# and PowerShell sibling contracts.
- `python-change-budget-router` OB-1 now states the full `## Canonical Routing Rules` (estimate, 1 to 3 production files with tests to the small path in direct mode, more than 3 to the large path with no production-file cap, test files not counted), the same form as the two siblings. The three router contracts no longer diverge.
- `execution-environment` OB-4 now names both mechanisms (the runtime worktree isolation guard and the repository command hooks), the hook deny classes (destructive patterns, a directory change followed by a file-reading command, a direct test runner, merge text not bound to one pull request under concurrent review) and the preferred forms (directory named on the tool, one-number merge in its own command, multi-line inline Python in a file). Every clause has a source bullet in `## Command-Text Restrictions`.

**Executor sweep fix.** `human-exception-runbook` OB-5 said "contains all five required sections" without naming them, a residual R4-class instance that the cycle 2 and prior reviewer sweeps both missed. The fix adds the five names from the source `## Conformance` bullet (Cue, Prerequisites, Step-by-step Instructions, Verification, Source and Citation) and the reference to the Tool Command Version Rule; both match the source verbatim in substance. The edit is outside the scope boundary of `remediation-inputs.2026-11-17T06-52.md`, but it is within the same defect class, is accurate, touches a file already in the branch diff, changes no prefix, numbering or `AC-<n>` text, and is recorded as decision D3. It is accepted.

**Reviewer class sweep.** All 262 Observable Behavior items of the 65 contracts were scanned again for the R1 to R7 classes over both trees. No residual instance remains (method and results under `## Cycle 3 Verification`).

**What changed since the prior review:**
6 contract files (3 contracts plus bundle copies), 2 checkbox markers in `remediation-inputs.2026-11-17T06-52.md`, the R4 review record and 4 evidence records. No code, test, schema, matrix or configuration file changed.

**Top 3 risks:**
1. The contract lint is structural only (D-R6), so sentence content is protected by review, not by a gate; child 3 should treat these contracts as reviewed text, not as test-enforced text.
2. `execution-environment` OB-4 does not restate the literal-absolute-path rule of `## Command-Text Restrictions` (CR-20, Info); child 3 reads the full section when it ports the skill.
3. The two CI-dependent acceptance criteria await CI on the pull request head (expected).

**PR readiness recommendation:** **Ready** — no blocking finding remains. The two CI-dependent acceptance criteria are checked off by the orchestrator at S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.agents/skills/execution-environment/references/standard.md` | `## Observable Behaviors` OB-4 | CR-20: the item states both mechanisms, every deny class and the main preferred forms, but not the bullet that worktree and file paths are written as literal absolute paths in each command rather than shell variables. | No change in this item. | A complete sentence that names every counted member; omission of one supporting rule is the CR-12 acceptance (a real rule of a multi-rule section stated completely), not an R4 count-without-members defect. | `.agents/skills/execution-environment/SKILL.md` `## Command-Text Restrictions` |
| Info | `.agents/skills/human-exception-runbook/references/standard.md` and its bundle copy | `## Observable Behaviors` OB-5 | CR-21: executor sweep fix outside the light-path scope boundary (decision D3). | No change. | Same defect class (R4), accurate to the source, no structural change; recorded in evidence. | `evidence/qa-gates/light-remediation-cycle-3.2026-11-17T07-38.md` `## Decisions` |
| Info | `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/remediation-inputs.2026-11-17T06-52.md` | `## Light Fix Tasks` | CR-22: the executor changed the two task boxes to `- [x]` to satisfy its stop hook. | No change. | On the light path the inputs file is the task list of record; only the two markers changed; both tasks were verified first; decision D5 is recorded append-only. | `git diff -U0 64640d75d b1a45cc0f`; `evidence/other/light-cycle-3-inputs-checkoff.2026-11-17T07-41.md` |
| Info | `.agents/skills/{atomic-plan-contract,epic-orchestrate,test-execution-policy}/references/standard.md` | `atomic-plan-contract` OB-3, `epic-orchestrate` OB-1 and OB-2, `test-execution-policy` OB-4 | CR-18 (carried): applicability-condition or single-clause items. | No change in this item. | Accepted under CR-12. | Prior review |
| Info | `.agents/skills/policy-audit-template-usage/references/standard.md` | OB-1 | CR-19 (carried): names the MCP asset. | No change. | Mechanism-subject acceptance. | Prior review |
| Info | 45 items plus the executor's further CR-12 acceptances | `## Observable Behaviors` | CR-12 (carried). | No change. | Floor standard. | `evidence/other/source-comparison.2026-11-17T05-30.md` |
| Info | `.agents/skills/{docs-*,documentation-workflow}/references/standard.md` | OB-1 | CR-13 (carried): docs MCP tool names. | No change. | Same mechanism in every runtime. | Prior review |
| Info | `survey/difference-approval.md` | `## Bulk Approval Set` | CR-3 and CR-4 (carried). | No change. | Approved owner decision. | Prior review |
| Info | `config/harness-parity-matrix.json` | `claude:mcp-server:drm-copilot`, `codex:mcp-server:drm-copilot` | CR-5 (carried): two entries stay `provisional`. | No change. | Schema rule `pending-source-requires-provisional`. | Prior review |
| Info | `scripts/harness/HarnessInventory.psm1` | 466-477 | CR-6 (carried): default listing enumerates the working tree. | No change required now. | Spec `### Constraints & Risks`. | Prior review |
| Nit | `scripts/harness/HarnessParityMatrix.psm1` | 237-242 | CR-7 (carried): `SupportsShouldProcess` on a function that changes no state. | Optional. | No behavior impact. | Code inspection |

CR-15, CR-16 and CR-17 are closed and no longer listed. No covered file in the branch diff is at or above 700 logical lines (largest `scripts/harness/HarnessInventory.psm1`, 515), so no Warning row applies. `config/file-size-baseline.json` is not in the branch diff.

---

## Cycle 3 Verification

### R6, R7 and CR-17 closure

| Check | Command | Result |
|---|---|---|
| Cycle 3 diff | `git diff 89fa11914 HEAD -- .agents` | 4 items in 3 contracts; prefixes, numbering and `AC-<n>` text unchanged |
| Router MCP grep, both trees | `grep -n "^- \*\*OB-" <tree>/python-change-budget-router/references/standard.md \| grep -i mcp` | no match |
| R1 truncation grep, both trees | `grep -n ';\.$\|,\.$\|:\.$\|listed above\|listed below' <tree>/*/references/standard.md` | no match |
| R2 placeholder grep, both trees | `grep -l "Produce the outcome that the" <tree>/*/references/standard.md` | no match |
| R3–R5 grep, both trees | `grep -n "^- \*\*OB-" ... \| grep -E 'AGENTS\.md\|`Read`\|<canonical\|: 1\) \|list order\|that epic'` | no match |
| Cycle 1 sweep grep, both trees | `grep -n "^- \*\*OB-" ... \| grep -E "these \|this (exact )?order\|this closed set\|the following\|below\|above\|\(issue\.$\|skills//\|The skill defines its"` | no match |
| Mirror identity | `cmp -s` of each of the 65 base contracts against its bundle copy | 65 pairs, 0 differing |
| Item count | `grep -h "^- \*\*OB-" .agents/skills/*/references/standard.md \| wc -l` | 262 |

### Source accuracy of the rewritten text

Each of the four rewritten items was read against its source section in `.agents/skills/<name>/SKILL.md`:

- `python-change-budget-router` OB-1 against `## Canonical Routing Rules` (three numbered steps): all three stated; the large path is named tool-neutrally instead of by its prompt-file path.
- `python-change-budget-router` OB-3 against `## Orchestrated Small-Path Requirements` first bullet: tool-neutral restatement of the stop rule, identical in form to the C# and PowerShell OB-2 items.
- `execution-environment` OB-4 against `## Command-Text Restrictions`: worktree isolation guard bullet, repository hooks bullet, preferred-forms bullet, inline-Python bullet, merge-text bullet and test-execution-hook bullet are each represented; the literal-path bullet is not (CR-20, Info).
- `human-exception-runbook` OB-5 against `## Conformance`: all five conformance bullets and the five section names are stated.

### Class sweep (all 65 contracts)

Method: all 262 Observable Behavior lines were scanned for runtime mechanism names (`MCP`, `Claude`, `Codex`, `AGENTS`, `.claude`, `.codex`), item-leading demonstratives (`This`, `These`, `That`, `It`, `They`), count words (`two` to `twelve`, `several`, `multiple`, `both`, and a digit before a member noun) and unnamed set references (`all required`, `every required`, `the required <noun>`, `etc`). Every hit was read in full.

- Mechanism names: the same set as the prior review minus `python-change-budget-router` OB-3; all remaining hits are mechanism-subject or CR-13 acceptances.
- Demonstratives: the same five accepted items (CR-18 and own-heading references).
- Count words: every counted set names its members; spot counts confirmed `invoke-csharp-engineer` OB-5 (8 of 8), `invoke-python-engineer` OB-5 (8 of 8), `invoke-powershell-engineer` OB-5 (9 of 9) and `pr-author` OB-3 (11 of 11).
- Unnamed set references: one hit, `evidence-and-timestamp-conventions` OB-4 "(`v1/`, `v2/`, etc.)", which illustrates an open version series and is not a closed set; accepted.
- Sibling consistency: the three change-budget-router contracts now state routing and the small-path stop rule in the same form.

---

## Implementation Audit

### PowerShell implementation audit

No PowerShell file changed in cycle 2 or cycle 3. The prior assessment stands: file listing and reading are injected script-block parameters with on-disk defaults; the identifier encoder and decoder follow spec `### Parity Matrix: Identifier Encoding`; `Get-HarnessParityMatrixRuleSet` returns the rules as data and the repository gate compares the schema against it; ordering and uniqueness use ordinal comparison.

#### API and safety notes

- Each module exports only its documented functions; helpers stay private.
- All functions are advanced functions with `OutputType`; PSScriptAnalyzer reports zero findings.
- The 515-line inventory module is in the 500-line guidance tier only.

#### Error handling and logging

- Violations are returned as objects with `Subject`, `Rule` and `Message`; the gate prints every message.
- Non-canonical ids, more than 99 same-file duplicates and unknown kinds throw with specific messages.

---

## Test Quality Audit

The cycle 3 full parallel Pester gate passed (27468 passed, 0 failed, 18 skipped; identical to the cycle 2 final gate), including the repository gate (7 passed, 0 skipped). The Python bundle-parity contract set passed (92) on attempt 7 after six queue timeouts (exit 75, machine test-suite lock held by another suite), which is a scheduling wait, not a failure. The harness modules remain at 100.00%, 99.25% and 100.00% line coverage, confirmed by the reviewer's parse of `artifacts/pester/powershell-coverage.xml` (written 2026-11-17T07-38 UTC).

### Reviewed test and QA artifacts

- `evidence/qa-gates/light-remediation-cycle-3.2026-11-17T07-38.md` — Gates 1 to 4 (contract lint 0 violations, cmp 0 differing, greps 0 lines, four-file Pester selection 269 passed, Python contract set 92 passed, full Pester gate 27468 passed), source check and class sweep.
- `evidence/other/task-check.P0-T1.2026-11-17T07-07.md`, `evidence/other/task-check.P0-T2.2026-11-17T07-10.md` — per-task checks.
- `evidence/other/light-cycle-3-inputs-checkoff.2026-11-17T07-41.md` — decision D5.

### Quality assessment prompts

- **Determinism:** no clock, randomness or network; injected I/O; ordinal ordering.
- **Isolation:** one rule per `It`; `-ForEach` tables isolate enumerated cases.
- **Speed:** unit tests operate on in-memory data; the repository gate reads the tree once.
- **Diagnostics:** each failure lists the offending id or contract path.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials or tokens in the diff; leak scan 0 failures (plan B). |
| No unsafe subprocess or command construction | ✅ PASS | The modules start no process and use no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Matrix entries are validated field by field; ids are validated against the anchored pattern before decoding. |
| Error handling remains explicit | ✅ PASS | Specific `throw` messages; no silent catch. |
| Configuration / path handling is safe | ✅ PASS | Paths are normalized to forward-slash relative form; `Test-HarnessRepositoryPath` rejects leading `/`, drive letters, backslashes and `..`. |
| Generated content correctness | ✅ PASS | R1 to R7 closed; the reviewer class sweep over all 262 items finds no residual instance. |

---

## Research Log

No external research was required. The review used the spec, the remediation inputs, the cycle 3 evidence, the branch diff, the source `SKILL.md` files and `artifacts/pester/powershell-coverage.xml`.

---

## Verdict

R6, R7 and CR-17 are closed in every named item and every bundle copy, the executor's same-class sweep fix is accurate, and the reviewer's class sweep finds no further instance. The code, tests, schema and matrix are unchanged and remain ready. No blocking finding remains; `remediation-inputs.2026-11-17T07-48.md` records `Review-Verdict: PASS`.
