# Feature Audit: Shared-source harness generators (#1028)

**Audit Date:** 2026-11-18
**Feature Folder:** `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028`
**Base Branch:** `epic/shared-agent-harness-layer-integration`
**Head Branch:** `feature/shared-source-generators-skills-rules-mcp-agents-1028`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/shared-agent-harness-layer-integration` (commit `03767033e45d4cf7fe5044da8f6f12b85c984946`)
- **Head branch/commit:** `feature/shared-source-generators-skills-rules-mcp-agents-1028` (commit `0620bfc52be80376168e97d115a037deae7eb47a`)
- **Merge base:** `03767033e45d4cf7fe5044da8f6f12b85c984946`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-18 02:25 UTC at head `0620bfc52`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/evidence/**`
  - Additional evidence: coverage artifacts `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info` re-parsed by this review; `git diff --name-status 03767033e..HEAD`
- **Feature folder used:** `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources; the early-draft list in `issue.md` is not authoritative.
- **Scope note:** Comparisons use the merge base of the integration branch and `HEAD`, as the spec's `Comparison base` item requires. The CI-dependent criteria are listed as pending-CI; the orchestrator verifies them at S9.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/spec.md` — primary source (40 checkbox items under `## Acceptance Criteria`)
- `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/user-story.md` — secondary source (15 checkbox items under `## Acceptance Criteria`)

### Acceptance criteria

The criteria are the checkbox items of the two files, quoted in the source files and summarized by label in the evaluation table below (S-n for `spec.md` in file order, U-n for `user-story.md` in file order).

---

## Acceptance Criteria Evaluation

### From spec.md

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S-1 | Phase 0 gate record covers every owner-decision row (D-1) | PASS | `evidence/baseline/phase0-gate.2026-11-17T18-20.md` (the earlier `17-17` record is the recorded stop answered by D-11 to D-13) | `Read` of both gate records | Stop-then-replan recorded append-only. |
| S-2 | Phase 0 record shows child 1 and child 2 outputs present | PASS | `phase0-gate.2026-11-17T18-20.md` | `Read` | |
| S-3 | No approved difference on a pinned file; D-14 regions; targets exist; edit-set re-check | PASS | `phase0-gate.2026-11-17T18-20.md`; `parallel_orchestrator_surface_expectations.py` unchanged | `git diff --name-only <MB>..HEAD -- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (empty) | |
| S-4 | `-Check` exits 0/non-zero with one line per finding; Pester unit tests | PASS | `Invoke-HarnessGeneration.ps1`, `Format-HarnessDriftReport`; `Invoke-HarnessGeneration.Tests.ps1`, `HarnessGeneration.Tests.ps1` | code inspection; `final-gates.2026-11-18T02-20.md` | |
| S-5 | Malformed source fails before any write and names the source | PASS | `Write-HarnessFileMap` validates the whole map before writing; render-first ordering in `Invoke-HarnessGeneration`; writer-not-called tests | code inspection | |
| S-6 | LF / no-BOM; CRLF, BOM and reparse targets reported as drift | PASS | `ConvertTo-HarnessGeneratedText`, `Compare-HarnessFileMap`; unit tests | code inspection | |
| S-7 | `quality-tiers.yml` T4 entry; `check_quality_tiers` exit 0 | PASS | `quality-tiers.yml` diff; `phase-gate.P1.2026-11-17T20-01.md` | `git diff <MB>..HEAD -- quality-tiers.yml` | |
| S-8 | `AGENTS.md` has no converter/sync header, no embedded rules; cited skill paths exist | PASS | `AGENTS.md`; `HarnessInstructions.Tests.ps1`; `instructions-check.2026-11-17T19-34.md` | `grep -c` for both headers in `AGENTS.md` (0) | |
| S-9 | `CLAUDE.md` line after frontmatter is `@AGENTS.md`; no duplicated H2 body | PASS | `CLAUDE.md` line 4 is `@AGENTS.md` | `sed -n '4p' CLAUDE.md` | |
| S-10 | `AGENTS.md` has no coverage threshold; feature-review coverage hook tests pass unchanged | PASS | no threshold text in `AGENTS.md`; hooks not in diff; Pester 0 failures | `grep -i -E '85%|75%|coverage threshold' AGENTS.md` (no match) | |
| S-11 | Bundle `AGENTS.md` equals `AGENTS.md` | PASS | byte comparison | `cmp AGENTS.md extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md` | |
| S-12 | Converter output has no `AGENTS.md` target or header; apply mode leaves `AGENTS.md`; named tests | PASS | `planTargetPaths` / `plan_target_paths` null target; merged renderer removed; `converter-ts.2026-11-17T20-13.md`, `converter-py.2026-11-17T20-21.md` | diff inspection | |
| S-13 | Report records not-emitted with a reason in both implementations | PASS | `STANDING_GUIDANCE_NOT_EMITTED_NOTE` in `mapping.ts` and `mapping.py` (same text); `converter-parity.2026-11-17T20-23.md` | diff inspection | |
| S-14 | Updated converter tests pass under Jest and pytest | PASS | Jest 5895/5895, pytest 17122 passed | `final-gates.2026-11-18T02-20.md` | |
| S-15 | No new Python module or pushed-down TypeScript file; converter edits in existing files | PASS | name-status shows only `M` under both converter folders | `git diff --name-status <MB>..HEAD` | |
| S-16 | `.mcp.json` and Codex MCP region from one source; `-Surface mcp -Check` exit 0 | PASS | `mcp-first-generation.2026-11-17T19-20.md`; repository gate | `final-gates.2026-11-18T02-20.md` | |
| S-17 | MCP generator leaves bytes outside the region unchanged (unit test) | PASS | `HarnessMcpConfig.Tests.ps1` | code inspection | |
| S-18 | Codex `args` line shape and version; release and contract tests pass unchanged | PASS | `Invoke-FullRelease.ps1` not in diff; pytest and Pester 0 failures | `final-gates.2026-11-18T02-20.md` | |
| S-19 | Selected skills equal rendered mirror; D-14 entries `native`; excluded copies unchanged | PASS | `skills-generation.2026-11-17T22-20.md`; `skill-matrix-native.2026-11-17T22-06.md`; no diff under `.claude/skills/epic-orchestrate` or `.agents/skills/epic-orchestrate` | `git diff --name-only` on excluded paths (empty) | |
| S-20 | Unit tests: unselected skill untouched, `openai.yaml` not mirrored, extra file reported | PASS | `HarnessSkillMirror.Tests.ps1` | code inspection | |
| S-21 | Each approved positive difference applied or recorded `deferred-ledger-region` per Diff ID | PASS | `skill-ports.2026-11-17T22-06.md` lists all 297 Diff IDs | `Read` | 28 positive rows on retained skills are recorded `not-applicable` because the target copy already carries equivalent text or the item is tool-specific mechanism; the reasons are specific, so the criterion's intent is met. See Notes. |
| S-22 | Pinned hashes, frozen epic surfaces and ledger unchanged; related tests pass | PASS | no diff on the named paths; pytest and Pester 0 failures | `git diff --name-only` on the named paths (empty) | |
| S-23 | Rules produced from sources with bundle copies; `-Surface rules -Check` exit 0 | PASS | `rules-generation.2026-11-17T23-05.md`; repository gate | `final-gates.2026-11-18T02-20.md` | |
| S-24 | Rule frontmatter, tier-precedence and TS-toolchain contract tests pass unchanged; unconditional-glob rejection test | PASS | tests not in diff; pytest 0 failures; `HarnessRuleGeneration.Tests.ps1` | diff inspection | |
| S-25 | `general-unit-test.instructions.md` begins with `---` | PASS | first line `---` | `head -1 .github/instructions/general-unit-test.instructions.md` | |
| S-26 | Agents equal rendered output; `-Surface agents -Check` exit 0 | PASS | `agents-generation.2026-11-18T00-10.md`; repository gate | `Read` | |
| S-27 | Python variant generator changes no base file; second run no change; `--check` exit 0; script unchanged | PASS | `agents-generation.2026-11-18T00-10.md`; `generate_codex_agent_variants.py` not in diff | `git diff --name-only` (empty) | |
| S-28 | Write-scope literals pass through exactly; child 2 checker passes | PASS | `ConvertTo-HarnessClaudeAgentText` emits raw values; `HarnessAgentGeneration.Tests.ps1`; Jest 0 failures | code inspection | |
| S-29 | Pack-manifest closure, wrapper, handoff parity and architecture-doc tests pass | PASS | pytest and Pester 0 failures | `final-gates.2026-11-18T02-20.md` | |
| S-30 | Repository gate runs every check mode without a process or git history; negative test | PASS | `HarnessGeneration.RepoGate.Tests.ps1` | code inspection | |
| S-31 | No file under `.github/workflows/` changes | PASS | empty diff | `git diff --name-only <MB>..HEAD -- .github/workflows` | |
| S-32 | `CI Required Gate` passes on the PR head (D-7; CI-dependent) | UNVERIFIED | No PR and no CI run exist at review time | n/a | Pending-CI; orchestrator checks it off at S9. Not a review finding. |
| S-33 | No selected entry with an existing source keeps `pending-source:`; generator set; matrix gate passes | PASS | repository gate case 2; `task-check.P6-T1.2026-11-18T00-43.md` | code inspection | |
| S-34 | Brief names the gate in six byte-identical copies | PASS | one distinct SHA-256 across six copies; gate named | `sha256sum` of the six copies (1 unique) | |
| S-35 | Each new module at least 85% line coverage, per file | PASS | per-file `LINE` counters: six modules 100%, entry script 86.67% | re-parse of `artifacts/pester/powershell-coverage.xml` | |
| S-36 | Final parallel gates zero failures; leak scan passes (D-6) | PASS | `final-gates.2026-11-18T02-20.md` | `Read` | |
| S-37 | No added `.py` or `.ts`; added code files in `## Language Classification` | PASS | 15 added PowerShell files (7 production, 8 tests), none `.py` or `.ts` | `git diff --name-status <MB>..HEAD` | |
| S-38 | No change to blast-radius, child 2 (except D-12 section) or excluded paths | PASS | empty diff on the named paths; child 2 spec diff is one hunk in `### Interface for epic child 3` | `git diff` on the paths | |
| S-39 | No file added or changed exceeds 800 lines; `FileSizePolicy.RepoGate.Tests.ps1` passes | PASS | covered files at most 624 lines; gate passed | logical line count of the branch-diff files | Reviewer judgment on the executor's interpretation below. |
| S-40 | Push-down resource, pack-manifest, issue-824 and variant-generator tests pass after generation | PASS | pytest 0 failures | `final-gates.2026-11-18T02-20.md` | |

### From user-story.md

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| U-1 | Execution stops before any change on a gate failure, with reason recorded | PASS | `phase0-gate.2026-11-17T17-17.md` (stop) and `18-20` (pass after re-plan) | `Read` | |
| U-2 | Each surface `-Check` exits 0 on the tree and names drifted files | PASS | as S-4, S-16, S-19, S-23, S-26 | as above | |
| U-3 | Regular LF, UTF-8-without-BOM files with bundle copies | PASS | as S-6; `Get-HarnessBundlePath` | code inspection | |
| U-4 | Malformed source stops generation and names the file | PASS | as S-5 | code inspection | |
| U-5 | `AGENTS.md` hand-authored; `CLAUDE.md` imports it with Claude-only text | PASS | as S-8, S-9 | as above | |
| U-6 | Converter no longer writes `AGENTS.md`; report lists not-emitted; TS and Python behave the same | PASS | as S-12, S-13 | as above | |
| U-7 | MCP from one list; rest of TOML untouched; version pin works | PASS | as S-16 to S-18 | as above | |
| U-8 | Shared skills generated from `.agents/skills`; tool-only skills and Codex metadata not mirrored | PASS | as S-19, S-20 | as above | |
| U-9 | Rules generated with native glob frontmatter; existing tests pass | PASS | as S-23, S-24 | as above | |
| U-10 | Agents from one definition; variant generator no drift; write-scope literals exact | PASS | as S-26 to S-28 | as above | |
| U-11 | Check modes run in the existing `poshqc / PowerShell QC` shards; `CI Required Gate` passes | UNVERIFIED | No CI run at review time | n/a | Pending-CI; checked off at S9. |
| U-12 | Parity-matrix entries record `generated_from` and `generator`; matrix gate passes | PASS | as S-33 | as above | |
| U-13 | No new Python or TypeScript file; new code files are PowerShell and classified | PASS | as S-37 | as above | |
| U-14 | New modules at least 85% line; parallel gates and leak scan pass; no added or changed file exceeds 800 lines | PASS | as S-35, S-36, S-39 | as above | Same interpretation as S-39. |
| U-15 | No blast-radius, child 2 (except D-12) or excluded-path file changed | PASS | as S-38 | as above | |

### Reviewer judgment: file-size criterion interpretation (S-39, U-14)

The executor's record `evidence/other/ac-file-size-interpretation.2026-11-18T01-58.md` reads "no file added or changed ... exceeds 800 lines" as "no file under the repository file-size policy". This review agrees with that reading:

- The criterion names `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` as its check, which covers only code extensions.
- `## File Size Limit` in `.claude/rules/general-code-change.md` applies to production, test and reusable script files and exempts Markdown documentation; a JSON data file is none of the covered kinds.
- The spec itself states, in `### Edge cases`, that Markdown outputs are exempt, and its `File size` risk item names modules and generated TOML only.
- The literal reading cannot be met, because the spec mandates the matrix upkeep of child 1's 11832-line `config/harness-parity-matrix.json`.

The record is, however, incomplete: it calls the matrix "the one file above 800 lines", but `scripts/harness-generation/sources/rules/parallel-orchestration.md` (added, 852 logical lines) also exceeds 800. It is Markdown and exempt, so the verdict does not change. This is recorded as a Minor, non-blocking finding in the code review; the recommended correction is a new, separately timestamped evidence record (evidence is append-only).

### Notes on S-21

Of the positive Diff IDs on the 54 retained skills, 16 are `applied` and 28 are `not-applicable` with a specific reason (equivalent text already carried under a named heading, or a tool-specific mechanism whose counterpart the other copy carries). The criterion names only `applied` and `deferred-ledger-region`. Under the cost-benefit rule (OD-4) this is not a blocking finding: porting text that both copies already carry would duplicate it, and each row names where the equivalent text lives, so the reconciliation is auditable.

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 53 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria (both CI-dependent, pending S9)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. The two UNVERIFIED items are CI-dependent and are verified by the orchestrator at S9.

**Recommended follow-up verification steps:**

1. At S9, confirm `CI Required Gate` (including `poshqc / PowerShell QC` on Linux, which runs `HarnessGeneration.RepoGate.Tests.ps1`) is green on the PR head, then check off S-32 and U-11.
2. Optionally append a supplementary file-size evidence record naming both files above 800 lines and their exemption basis.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/spec.md`, `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/user-story.md`
- Total AC items: 55
- Checked off (delivered): 53
- Remaining (unchecked): 2
- Items remaining: spec.md "The required `CI Required Gate` check passes on the pull request head (D-7; CI-dependent; checked off at S9)."; user-story.md "Every check mode runs in the existing `poshqc / PowerShell QC` shards through one Pester repository gate, with no new CI job, and the required `CI Required Gate` check passes on the pull request head (CI-dependent; checked off at S9)."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 40 | 39 | 1 | Checkbox-backed; the open item is CI-dependent. Definition of Done (not AC): 1 of 3 checked; the two open items depend on CI. |
| `user-story.md` | 15 | 14 | 1 | Checkbox-backed; the open item is CI-dependent. |

No source-file checkbox change was made by this review: every PASS item was already checked by the executor, and the two UNVERIFIED items must stay unchecked until S9.
