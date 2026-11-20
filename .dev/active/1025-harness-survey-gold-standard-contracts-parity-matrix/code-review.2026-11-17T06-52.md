# Code Review: Harness Survey, Gold-Standard Contracts and Parity Matrix (#1025)

---

**Review Date:** 2026-11-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`
**Feature Folder Selection Rule:** the folder whose name carries the canonical issue number 1025, named by the delegation prompt.
**Base Branch:** `epic/shared-agent-harness-layer-integration` (merge base `bba58bac90a30fd9f4bd3b6bf5ae8d69bf86a0ee`)
**Head Branch:** `feature/harness-survey-gold-standard-contracts-parity-matrix-1025` (head `d3ad430482b75bbc3631d5fe93448e3f135c446d`)
**Review Type:** Re-audit (R4) after remediation cycle 2 (prior review `code-review.2026-11-16T06-14.md`)

---

## Executive Summary

The branch delivers epic #1018 child 1: the skill survey, the difference classification and approval record, 65 gold-standard contracts at `.agents/skills/<name>/references/standard.md` with byte-identical bundle copies, the parity matrix (655 entries) with its Draft 2020-12 schema, and three PowerShell modules with four Pester test files. This re-audit covered the full diff `bba58bac..d3ad430` (318 files) and, in detail, remediation cycle 2 (`8a18e10f6..d3ad430`, 107 files: 43 contracts, their 43 bundle copies, the remediation plan and evidence).

**Findings R3, R4 and R5 are closed.** All 29 named items, the 2 D-C2-1 items, the CR-14 qualifier and the 56 sweep fixes were read against the `SKILL.md` section each names; every rewritten item is one complete, tool-neutral sentence that states the section's behavior as a whole and names every member of the set or order. The closure greps return no match in either tree and `cmp -s` finds no differing pair among the 65 contract pairs.

The reviewer then swept all 262 Observable Behavior items of the 65 contracts for the R3, R4 and R5 classes, independently of the executor's sweep. Two residual instances remain, both missed by the cycle 2 sweep:

- CR-15 (class R5): `python-change-budget-router` OB-3 still reads "If the MCP server or required tool is unavailable, stop before promotion." Cycle 1 rewrote the identical source sentence in the C# and PowerShell router contracts to tool-neutral wording; the Python sibling was left as the raw mechanism statement.
- CR-16 (class R4): `execution-environment` OB-4 reads "Two separate mechanisms restrict Bash command text." The source section names the two mechanisms (the runtime worktree isolation guard and the repository Bash hooks); the item names neither, so it states a count instead of the behavior.

**What changed since the prior review:**
86 contract files (43 contracts plus bundle copies), the remediation plan check-offs and 20 evidence records. No code, test, schema, matrix or configuration file changed.

**Top 3 risks:**
1. `python-change-budget-router` states the small-path stop rule through the MCP server mechanism while its two sibling router contracts state the same source rule tool-neutrally (CR-15); child 3 would compare three parallel contracts that disagree in form.
2. `execution-environment` OB-4 gives child 3 no observable behavior for `## Command-Text Restrictions` (CR-16).
3. `python-change-budget-router` OB-1 states only the estimate step of the routing rules, while the C# and PowerShell siblings now state the full routing (CR-17, Nit; non-blocking under the CR-12 acceptance).

**PR readiness recommendation:** **Needs Revision** — two contained, autonomous content findings in two files already on the branch (plus their bundle copies). The prior cycle took the full path, so this cycle may take the light path.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.agents/skills/python-change-budget-router/references/standard.md` and its bundle copy | `## Observable Behaviors` OB-3 | CR-15 (class R5): "If the MCP server or required tool is unavailable, stop before promotion." states the behavior through the repository MCP server mechanism. | Restate tool-neutrally, matching the cycle 1 wording of the sibling contracts: promotion and folder lifecycle steps run through the repository automation tools, and when the required tool is unavailable the skill stops before promotion begins. Keep the `- **OB-3** Orchestrated Small-Path Requirements: ` prefix and the `AC-<n>` text; copy the file byte for byte to its bundle mirror. | Spec `### Contract Format` rule 6. The source sentence in `.agents/skills/python-change-budget-router/SKILL.md` `## Orchestrated Small-Path Requirements` is identical to the C# and PowerShell sources, whose OB-2 items cycle 1 rewrote to neutral wording. The section's subject is the small-path lifecycle, not MCP availability, so the plan's mechanism-subject acceptance does not apply (the executor's source-comparison row 502 accepted it on that ground). | `grep -n "MCP" .agents/skills/*/references/standard.md`; `git show 6ad9b31f6 -- .agents/skills/csharp-change-budget-router/references/standard.md` |
| Major | `.agents/skills/execution-environment/references/standard.md` and its bundle copy | `## Observable Behaviors` OB-4 | CR-16 (class R4): "Two separate mechanisms restrict Bash command text." names a count and neither member; it is the lead-in sentence of a section that enumerates the members. | State the section's behavior as a whole: command text is restricted by two separate mechanisms with different causes and fixes, the runtime worktree isolation guard (which refuses command text it cannot show stays inside an agent-isolated worktree and is not a repository hook) and the repository command hooks (which deny destructive patterns and a directory change followed by a file-reading command), and the preferred forms name the directory on the tool instead of changing into it. Keep prefix and `AC-<n>` text; copy byte for byte to the bundle mirror. Mechanism names stay allowed under the mechanism-subject acceptance, because this contract's subject is the execution environment. | Plan `## Defect Class Tests` R4: the section enumerates two or more required members and the item names a proper subset (none). Same form as the `These are ...` lead-in items that cycle 2 fixed as R3 and R4. | `.agents/skills/execution-environment/SKILL.md` `## Command-Text Restrictions` (bullets "Worktree isolation guard", "Repository hooks", "Preferred forms") |
| Nit | `.agents/skills/python-change-budget-router/references/standard.md` | OB-1 | CR-17: "Estimate rough change budget first based on likely production Python files touched." states step 1 of the three-step `## Canonical Routing Rules` (estimate, route 1-3 files small and more than 3 large, test files not counted). Cycle 2 rewrote the C# and PowerShell OB-1 items to state the full routing. | Optional, recommended in the same edit as CR-15 because the file is edited anyway: state the full routing (estimate from production Python files, 1 to 3 production files to the small path in direct mode, more than 3 to the large path with no production-file cap, test files not counted). | Accepted under CR-12 (a complete sentence stating one real step, the same form as `pr-base-branch-merge-base` OB-2), so it does not gate; the change only aligns three sibling contracts. | `.agents/skills/python-change-budget-router/SKILL.md` `## Canonical Routing Rules` |
| Info | `.agents/skills/{atomic-plan-contract,epic-orchestrate,test-execution-policy}/references/standard.md` | `atomic-plan-contract` OB-3, `epic-orchestrate` OB-1 and OB-2, `test-execution-policy` OB-4 | CR-18: these items state an applicability condition ("This rule applies only when ...", "This section applies only to ...") or one narrow clause (`XDG_RUNTIME_DIR` is not used) of a multi-rule section. | No change in this item. Child 3 may strengthen them when it ports these skills. | Complete sentences whose demonstratives resolve to the item's own heading; accepted under CR-12 and the prior review's boundary. | Reviewer sweep of 262 items |
| Info | `.agents/skills/policy-audit-template-usage/references/standard.md` | OB-1 | CR-19: "The resolved MCP asset is authoritative even when a matching repo file also exists." names the MCP asset. | No change. | The source section `## Template Source` is about that asset, so the mechanism-subject acceptance applies; the MCP template resolution is the same mechanism in every runtime (CR-13 precedent). | `.agents/skills/policy-audit-template-usage/SKILL.md` `## Template Source` |
| Info | 45 items accepted in the prior review plus the executor's further CR-12 acceptances | `## Observable Behaviors` | CR-12 (carried): complete sentences stating one real rule of a multi-rule section. | No change. | Floor standard; boundary set by the prior review. | `evidence/other/source-comparison.2026-11-17T05-30.md` |
| Info | `.agents/skills/{docs-author-page,docs-plan-ia,docs-reconcile-behavior}/references/standard.md` | `## Observable Behaviors` | CR-13 (carried): docs MCP tool names. | No change. | Same mechanism in every runtime that runs these skills. | Prior review |
| Info | `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/survey/difference-approval.md` | `## Bulk Approval Set`, line 4 | CR-3 and CR-4 (carried): templated rationales; `Approved-By` records the autonomous decision. | No change. | Approved owner decision. | Prior review |
| Info | `config/harness-parity-matrix.json` | `claude:mcp-server:drm-copilot`, `codex:mcp-server:drm-copilot` | CR-5 (carried): two entries stay `provisional`. | No change. | Schema rule `pending-source-requires-provisional`. | Prior review |
| Info | `scripts/harness/HarnessInventory.psm1` | 466-477 | CR-6 (carried): the default listing enumerates the working tree. | No change required now. | Spec `### Constraints & Risks` accepts this risk. | Prior review |
| Nit | `scripts/harness/HarnessParityMatrix.psm1` | 237-242 | CR-7 (carried): `SupportsShouldProcess` on a function that changes no state. | Optional. | No behavior impact. | Code inspection |

No covered file in the branch diff is at or above 700 logical lines (largest `scripts/harness/HarnessInventory.psm1`, 515), so no Warning row applies. `config/file-size-baseline.json` is not in the branch diff.

---

## Cycle 2 Verification

### R3, R4 and R5 closure

| Check | Command | Result |
|---|---|---|
| R1 truncation and dangling-phrase grep, both trees | `grep -n ';\.$\|,\.$\|:\.$\|listed above\|listed below' <tree>/*/references/standard.md` | no match |
| R2 placeholder grep, both trees | `grep -l "Produce the outcome that the" <tree>/*/references/standard.md` | no match |
| R3–R5 grep, both trees | `grep -n "^- \*\*OB-" ... \| grep -E 'AGENTS\.md\|`Read`\|<canonical\|: 1\) \|list order\|that epic'` | no match |
| Cycle 1 sweep grep, both trees | `grep -n "^- \*\*OB-" ... \| grep -E "these \|this (exact )?order\|this closed set\|the following\|below\|above\|\(issue\.$\|skills//\|The skill defines its"` | no match |
| Mirror identity | `cmp -s` of each of the 65 base contracts against its bundle copy | 0 differing pairs |
| Checkbox and product-name scan | `grep -- '- \[[ x]\]'` and `grep TaskMaster.sln` over the contracts | no match |
| Scope of cycle 2 | `git diff --name-only 8a18e10f6 HEAD` | 86 contract files, the remediation plan and 20 evidence files; no `SKILL.md`, survey, matrix, schema, module or test |

### Source accuracy of the rewritten text

The reviewer read every rewritten item against its source section and checked a cross-section of the sources directly: `policy-compliance-order` OB-1 (full four-tier order with the Python, PowerShell, TypeScript and C# rule files), `feature-review-workflow` OB-1 (all seven shared skills), `evidence-and-timestamp-conventions` OB-5 (all twelve discovery locations stated as six feature folders then the same six under the epic root, with the remediation-reconciliation exception and the non-canonical rule), `invoke-powershell-engineer` OB-5 (all nine preloaded skills), `adjudicate-unspecified-behavior` OB-1 to OB-3 (every input, the full routing rule set and every artifact kind), `pr-author` OB-3 (all eleven body sections in order), `research-issue` OB-2 (both paths, template and placement rules), `translate-copilot-to-claude` OB-4 (all six target kinds, stated tool-neutrally) and `commit-message` OB-4 (block, header, body and reference rules). Each matches its source in substance, and the tool-specific source text (`AGENTS.md`, `.codex/...`, `Read`) is stated neutrally.

### Residue sweep (class, not instance)

Method: all 262 Observable Behavior items were extracted from the 65 contracts and read in full against the plan's `## Defect Class Tests`, and targeted scans were run for runtime mechanism names (`MCP`, `Claude`, `Codex`, `AGENTS.md`, `Read`), demonstratives at item start (`This`, `These`, `That`, `It`, `They`) and count words without named members. Results:

- Mechanism names: outside the eight docs prerequisite items, 6 items name MCP. Five are mechanism-subject or CR-13 acceptances (`execution-environment` OB-5, `feature-promotion-lifecycle` OB-1, `human-exception-runbook` OB-3 and OB-5, `policy-audit-template-usage` OB-1). One, `python-change-budget-router` OB-3, fails R5 (CR-15). The docs prerequisite items name the docs MCP tools (CR-13).
- Demonstratives: 5 items (`atomic-plan-contract` OB-3, `epic-orchestrate` OB-1 and OB-2, `evidence-and-timestamp-conventions` OB-1, `execution-environment` OB-1); each resolves to the item's own heading or skill and is accepted (CR-18 for the applicability-only ones).
- Count words: 32 items matched a count-word scan; 31 name every member they count. `execution-environment` OB-4 names none (CR-16).
- Sibling consistency: the three change-budget-router contracts were compared side by side; CR-15 and CR-17 are the only divergences.

---

## Implementation Audit

### PowerShell implementation audit

No PowerShell file changed in cycle 2. The prior assessment stands: file listing and reading are injected script-block parameters with on-disk defaults; the identifier encoder and decoder follow spec `### Parity Matrix: Identifier Encoding`; `Get-HarnessParityMatrixRuleSet` returns the rules as data and the repository gate compares the schema against it; ordering and uniqueness use ordinal comparison.

#### API and safety notes

- Each module exports only its documented functions; helpers stay private.
- All functions are advanced functions with `OutputType`; PSScriptAnalyzer reports zero findings.
- The 515-line inventory module is in the 500-line guidance tier only.

#### Error handling and logging

- Violations are returned as objects with `Subject`, `Rule` and `Message`; the gate prints every message.
- Non-canonical ids, more than 99 same-file duplicates and unknown kinds throw with specific messages.

---

## Test Quality Audit

The cycle 2 final parallel Pester gate passed (27468 passed, 0 failed, 18 skipped; counts identical to the cycle 2 `Phase 0 baseline`), including the repository gate (7 passed, 0 skipped) and the contract unit tests; the Python bundle-parity set passed (92). The harness modules remain at 100.00%, 99.25% and 100.00% line coverage. The contract lint checks structure only (D-R6), which is why CR-15 and CR-16 pass every gate; their closure is verified by source comparison, and a sentence-content test stays outside this item's spec.

### Reviewed test and QA artifacts

- `evidence/qa-gates/final-pester-c2.2026-11-17T06-37.md` — full parallel gate, attempt 1 exit 75 (queue timeout), attempt 2 exit 0.
- `evidence/qa-gates/final-contract-checks-c2.2026-11-17T06-37.md` — Python contract set 92 passed, generator check and tier check exit 0.
- `evidence/qa-gates/final-contract-text-c2.2026-11-17T06-38.md` — contract lint over all 65 pairs (0 violations), `cmp` (0 differing), greps (0 lines).
- `evidence/qa-gates/final-qc-static-powershell-c2.2026-11-17T06-37.md` — format and PSSA clean on loop pass 3.
- `evidence/other/source-comparison.2026-11-17T05-30.md` and `evidence/other/sweep-fixes.2026-11-17T05-40.md` — 589-row comparison and 56 sweep fixes.

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
| Generated content correctness | ⚠️ PARTIAL | R3 to R5 closed and 56 sweep fixes accurate; CR-15 and CR-16 leave 2 items in 2 contracts that do not meet the class tests. |

---

## Research Log

No external research was required. The review used the spec, the remediation inputs and plan, the cycle 2 evidence, the branch diff, the source `SKILL.md` files and `artifacts/pester/powershell-coverage.xml`.

---

## Verdict

R3, R4 and R5 are closed in every named item and every bundle copy, and the 56 sweep fixes are accurate to their sources. The code, tests, schema and matrix are unchanged and remain ready. Two residual instances of the same defect classes remain (CR-15, class R5; CR-16, class R4), each a single item in a file already on the branch. They are contained, autonomous fixes recorded in `remediation-inputs.2026-11-17T06-52.md` on the light path. CR-17 is an optional alignment that can be made in the CR-15 edit.
