# Code Review: Shared-source harness generators (#1028)

**Review Date:** 2026-11-18
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028`
**Feature Folder Selection Rule:** the folder whose name carries the canonical issue number 1028; no version subfolder exists
**Base Branch:** `epic/shared-agent-harness-layer-integration` (merge base `03767033e45d4cf7fe5044da8f6f12b85c984946`)
**Head Branch:** `feature/shared-source-generators-skills-rules-mcp-agents-1028` (head `0620bfc52be80376168e97d115a037deae7eb47a`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds seven PowerShell files under `scripts/harness-generation/` (a framework module, five surface modules and an entry script), eight Pester suites including a repository gate, 85 JSON and Markdown generator sources with four JSON schemas under `config/harness-generation/`, and the parity-matrix upkeep. It rewrites `AGENTS.md` as the hand-authored instruction source imported by `CLAUDE.md`, and changes the Codex native converter in both its TypeScript port (five files) and Python package (four files) so standing guidance is reported as not emitted instead of being written to `AGENTS.md`. Generated targets are, apart from small repairs (frontmatter delimiters, trailing newlines), byte-equal to the pre-branch files, so the first generation produced a small, reviewable diff.

Evidence reviewed: the full branch diff, the seven new PowerShell files (read in full for the framework, skill-mirror and agent modules), the TypeScript and Python converter diffs, the repository gate suite, the three coverage artifacts (re-parsed per file by this review), and the final QA records under `evidence/qa-gates/`. Implementation quality is good: pure render functions, a single injected I/O seam, validation of the whole file map before any write, ordinal comparisons throughout, and explicit errors that name the source path.

**What changed:**
New generator framework and surfaces (`HarnessGeneration.psm1`, `HarnessSkillMirror.psm1`, `HarnessRuleGeneration.psm1`, `HarnessMcpConfig.psm1`, `HarnessAgentGeneration.psm1`, `HarnessInstructions.psm1`, `Invoke-HarnessGeneration.ps1`); sources under `scripts/harness-generation/sources/`; converter redirection (`planTargetPaths` / `plan_target_paths` return a null target plus `STANDING_GUIDANCE_NOT_EMITTED_NOTE`; `renderMergedStandingGuidance` and the `AGENTS.md` duplicate-target exemption removed in both languages); `quality-tiers.yml` T4 entry; three append-only `coverageThreshold` entries in `jest.config.cjs`; execution-environment brief updated in six copies; D-12 amendment of child 2's spec section.

**Top 3 risks:**
1. The repository gate is the only drift enforcement and runs inside `poshqc / PowerShell QC`; it has not yet run in CI on Linux (CI-dependent, S9).
2. The skill mirror relies on 39 exact-once substitution files; any later edit to a shared skill that touches a substitution `find` text fails generation. This is intended fail-closed behavior, but it raises the cost of skill edits until the Claude/Codex wording converges.
3. Eleven skills (D-14) and the four Claude-only frontmatter keys stay hand-maintained, so drift on those surfaces is still not detected by this gate.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; the open criteria are CI-dependent and verified at S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/evidence/other/ac-file-size-interpretation.2026-11-18T01-58.md` | Decision, first bullet | The record states that `config/harness-parity-matrix.json` is "the one file above 800 lines". `scripts/harness-generation/sources/rules/parallel-orchestration.md`, added by this branch, has 852 logical lines. It is Markdown and exempt under `## File Size Limit`, so the conclusion holds, but the record is incomplete. | Add a new, separately timestamped evidence record (append-only) that lists both files above 800 lines and the exemption basis of each; optionally amend the spec criterion text to "covered by the file-size policy". | Evidence accuracy; an owner reading the record literally would miss one of the two affected files. | Logical line count of the branch-diff files (awk `NR`), this review |
| Nit | `scripts/harness-generation/HarnessAgentGeneration.psm1` | `ConvertTo-HarnessAgentBody`, lines 120-132 | The exact-once substitution loop duplicates `Get-HarnessOccurrenceCount` / `Invoke-HarnessSkillSubstitution` in `HarnessSkillMirror.psm1`, and unlike the skill path it does not normalize `find`/`replace` with `ConvertTo-HarnessGeneratedText`. A CRLF in an agent substitution would surface later as a write-validation error rather than at the substitution. | Move the occurrence count and replacement into `HarnessGeneration.psm1` and use it from both modules. | Reusability; one behavior for both surfaces. | Inspection of both modules |
| Info | `scripts/harness-generation/HarnessSkillMirror.psm1` | `Get-HarnessSkillMirrorExcludedFile` | `references/standard.md` is excluded from the mirror in addition to `agents/openai.yaml`; the spec lists only the latter. | None required; the plan names the exclusion (child 1 contract files are Codex-side judging contracts). | Traceability. | `plan.2026-10-30T18-30.md`, `HarnessSkillMirror.Tests.ps1` case `never mirrors agents/openai.yaml or references/standard.md` |
| Info | `scripts/harness-generation/sources/skills/*.substitutions.json` | n/a | Claude-only frontmatter keys (`allowed-tools`, `argument-hint`, `context`, `agent`) for five skills are carried by substitutions instead of the superset `.agents` frontmatter, a recorded deviation from the settled design. | Track the four missing `codex:skill-frontmatter-field` matrix entries in the item that adopts superset frontmatter. | Design intent (superset frontmatter) is deferred, not lost. | `evidence/qa-gates/skill-ports.2026-11-17T22-06.md` (Deviation) |
| Info | `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` | lines 35-41 | A selected entry with an empty or absent `generated_from` is skipped silently by the upkeep assertion (the reader returns `$null`). Child 1's schema requires the field for `generated` entries, so no current entry is affected. | Optionally report an empty `generated_from` as a problem. | Fail-closed preference. | Inspection |

No Blockers or Major findings. No covered file in the branch diff is at or above 700 logical lines (largest `extensions/drm-copilot/jest.config.cjs`, 624), so no `Warning` row applies; `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The standing-guidance branch is removed in place in `mapping.py`, `engine.py`, `pipeline.py` and `validation.py`; no module is added (owner language rule).
- `STANDING_GUIDANCE_NOT_EMITTED_NOTE` carries the same text as the TypeScript constant, giving one reason string per implementation.
- The `AGENTS.md` duplicate-target exemption is removed, so a future record that resolves to `AGENTS.md` is reported as a duplicate rather than merged silently.

#### Typing and API notes

- No new public Python API surface was added beyond the module constant; `dataclasses.replace` keeps the record immutable.

#### Error handling and logging

- Unchanged pattern; no new exception handler or print.

### TypeScript implementation audit

#### What changed well

- `planTargetPaths` returns `targetPath: null` and appends the note; `renderMergedStandingGuidance` and its re-export are removed, and the standing-guidance wrap branch is gone, so no code path can emit `# Converted standing guidance`.
- `standingGuidanceSourcePaths` is derived from the role alone, so reference rewrites to `AGENTS.md` in other outputs are unchanged, as the spec requires.

#### Type safety and maintainability

- No new `any`, no suppression, no new file; `jest.config.cjs` change is append-only (PQ-2 option (a)).

#### Error handling and logging

- Behavior at boundaries is unchanged; validation now applies uniformly to every target path.

### PowerShell implementation audit

#### What changed well

- `Write-HarnessFileMap` validates every path (repository-relative POSIX, no `..`) and every text (LF, no BOM) before the first write, which satisfies the malformed-source-before-write criterion structurally.
- `Invoke-HarnessGeneration` renders every selected surface before writing and rejects a path produced by two surfaces.
- `Compare-HarnessFileMap` treats reparse points as drift and classifies CRLF and BOM differences in the detail text.
- The MCP generator owns only the `[mcp_servers.*]` region as text; no TOML parser is introduced.
- `ConvertTo-HarnessGeneratedText` uses an ordinal character test for U+FEFF and documents why.

#### API and safety notes

- Advanced functions throughout, `SupportsShouldProcess` on both writers, `ValidateSet` on surfaces, explicit `Export-ModuleMember` lists. PSScriptAnalyzer reports 0 findings over 965 files.
- `Write-HarnessRepositoryFile` uses `New-Item -Path` (not `-LiteralPath`) for the parent folder; generated paths are validated against wildcard-free patterns upstream in practice, so this is not reported as a finding.

#### Error handling and logging

- Every throw names the source path; the entry script maps exceptions to exit 1 and argument rejection to exit 2, and prints one `<KIND> <path>` line per finding plus a summary line.

---

## Test Quality Audit

All three parallel gates report 0 failures at the reviewed head, and this review re-parsed the coverage artifacts per file: the six new modules are at 100% line coverage and the entry script at 86.67%; every modified converter file is at or above 85/75 and at or above its Phase 0 figure.

### Reviewed test and QA artifacts

- `tests/scripts/harness-generation/HarnessGeneration.Tests.ps1` — framework selection, comparison (CRLF, BOM, reparse, missing, extra), write validation, report format, ordering.
- `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` — committed-tree check of every surface, matrix upkeep, and a drifted-reader negative case naming `.mcp.json`.
- `tests/scripts/harness-generation/HarnessAgentGeneration.Tests.ps1` — alias form, write-scope literal pass-through, malformed sources.
- `extensions/drm-copilot/test/lib/codex-native-converter/*.test.ts` and `tests/scripts/dev_tools/codex_native_converter/test_*.py` — not-emitted disposition and reason, no `AGENTS.md` target, apply-mode non-modification.
- `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/evidence/qa-gates/final-gates.2026-11-18T02-20.md` — Pester 28292 passed, pytest 17122 passed, Jest 5895 passed, leak scan 0 failures.

### Quality assessment prompts

- **Determinism:** in-memory contexts per test; no clock, network, process or temporary file.
- **Isolation:** one behavior per `It`, one `Context` per function.
- **Speed:** the seven harness-generation suites run in about 150 s under 7 workers; the repository gate reads the full tree once.
- **Diagnostics:** the repository gate lists every drifted path in `-Because`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token in any added file. |
| No unsafe subprocess or command construction | ✅ PASS | The generators and the gate start no process; no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Sources validated before any write; JSON schemas for all 85 sources; exact-once substitutions. |
| Error handling remains explicit | ✅ PASS | Throws name the source; no silent catch. |
| Configuration / path handling is safe | ✅ PASS | `Test-HarnessGeneratedPath` rejects absolute, drive, backslash, `.` and `..` paths; agent target paths must equal the fixed `.claude/agents/<name>.md` and `.codex/agents/<name>.toml` forms. |

---

## Research Log

No external research was required; all findings derive from the branch diff, repository rules and the feature evidence.

---

## Verdict

The change is ready for the normal PR flow. The findings are one Minor evidence-completeness item, one Nit and three Info notes; none blocks merge under the cost-benefit rule, and none is carried into remediation inputs. The CI-dependent criteria (`CI Required Gate`, the CI-run integration stage) remain for the orchestrator at S9.
