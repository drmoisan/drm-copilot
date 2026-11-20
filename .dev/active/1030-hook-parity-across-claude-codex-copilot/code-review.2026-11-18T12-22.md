# Code Review: Hook parity across Claude Code, Codex and Copilot (#1030)

**Review Date:** 2026-11-18
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030`
**Feature Folder Selection Rule:** the folder whose name carries the canonical issue number 1030; no version subfolder exists
**Base Branch:** `epic/shared-agent-harness-layer-integration` (merge base `2d487f5b070b401a6d14271a039b1207a6e0383f`)
**Head Branch:** `feature/hook-parity-across-claude-codex-copilot-1030` (head `f9f358e9055db7b2b4ca7ce8d7d33ca1ebf67691`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds three PowerShell production files (`.codex/hooks/validate-pr-author-output.ps1`, `.codex/hooks/subagentstop-envelope.ps1`, `scripts/harness/HarnessHookParity.psm1`) with byte-identical bundle copies of the two hooks, one `[[hooks.SubagentStop]]` table in `.codex/config.toml` (root and bundle), two Codex core pack-manifest entries, five new Pester suites, edits to five existing suites and helpers, dispositions for all 96 `hook-registration` entries in `config/harness-parity-matrix.json`, the child 5 disposition record, and a generator-source correction (`scripts/harness-generation/sources/rules/orchestrator-state.{md,json}`) that removes drift inherited from a main sync.

Evidence reviewed: the full branch diff, the three production files (read in full), the repository gate suite and the Codex behavior suite, the edited test diffs, the coverage artifact (re-parsed per file), the parity matrix (summarized with `ConvertFrom-Json`), and the final QA records. Implementation quality is good: the rule module is pure and reads no file, the Codex hook keeps the decision in in-process functions with a thin entry tail, the twin functions are pinned text-identical to the Claude source by AST comparison, and every failure path fails closed with exit 2.

**What changed:**
Codex pr-author SubagentStop validator with the one-continuation rule (`Get-CodexPrAuthorStopDecision`); envelope helper twin; hook-parity rules H1 to H5 and a repository gate with in-memory negative cases; matrix parity groups, gap classes (`GAP:NOT-APPLICABLE: `, `GAP:NOT-EXPRESSIBLE: `, `GAP:DEFER: `, `CODEX-NATIVE: ` note prefixes), divergence notes; no-Python scan extended to `.github/hooks`; expected lists in three Codex contract suites extended; generator source section `release-commit-allowance-scope` added.

**Top 3 risks:**
1. The new Codex suites have run on Windows only; their Linux run in `poshqc / PowerShell hook suites (Linux)` is pending CI (S-16, U-10), and `codex-pretooluse-integration.Tests.ps1` is CI-only.
2. Gap classes are encoded as `notes` prefixes (OQ-2), so a later edit to a note that drops the prefix is caught only by the repository gate, not by the matrix schema.
3. The Codex hook's guard is the PR-reference text in the last assistant message, which is forgeable by the agent; the header states this is a policy guardrail, not a security control, matching the Claude source.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; the open criteria are CI-dependent and verified at S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Nit | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | `paths`, last two entries | The two new `.codex/hooks/*.ps1` entries are appended after `.codex/agents/migration-coverage-reviewer-c4.toml` instead of inside the sorted `.codex/hooks/` block (lines 69 onward). The closure and completeness tests pass, so order is not contractual. | Optionally move the entries into the `.codex/hooks/` block in a later edit of this manifest. | Readability of a hand-maintained list. | `git diff <MB>..HEAD -- .../pack-manifests/core.json`; `task-check.P1-T1.2026-11-18T08-40.md` (append recorded) |
| Info | `config/harness-parity-matrix.json`, `.../pack-manifests/core.json` | whole file | `format_json --check` reports `would reformat` for both files; the merge-base versions report the same, so the layout is inherited, and no CI workflow runs `format_json`. | None for this branch; a repository-wide JSON layout decision belongs elsewhere. | Not introduced by this branch; no gate fails. | `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.format_json --check` on head and merge-base copies (this review) |
| Info | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | assertion message, `'enumerated paths outside the scan roots: ' +((...` | Missing space after `+`. The PoshQC formatter accepted it. | None required. | Cosmetic. | branch diff |
| Info | `.codex/hooks/validate-pr-author-output.ps1` | `Get-CodexPrAuthorStopDecision`, line 143 | The envelope is parsed a second time to read `StopHookActive` after `Get-PrAuthorOutputDecision` parsed it. The cost is one JSON parse of a small payload, and keeping `Get-PrAuthorOutputDecision` text-identical to the Claude source (twin rule) is the reason. | None required. | Twin-rule fidelity outweighs one extra parse. | Inspection |
| Info | `.codex/hooks/subagentstop-envelope.ps1` | `Read-SubagentStopEnvelope`, stdin branch | Two uncovered lines (stdin read and its `catch`) remain because the twin must stay text-identical to the Claude helper and the Codex hook always passes `-InputText`. File coverage 96.67%. | None required. | Above threshold; documented in `pester-coverage.2026-11-18T11-16.md`. | Per-file `LINE` counter re-parsed by this review |

No Blockers or Major findings. No covered file in the branch diff is at or above 700 logical lines (largest `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, 609), so no `Warning` row applies; `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python file changed (owner language rule); the existing push-down and manifest contract tests ran unchanged and passed.

#### Typing and API notes

- No Python API surface changed.

#### Error handling and logging

- Not applicable.

### TypeScript implementation audit

#### What changed well

- No TypeScript file changed; Jest ran as a regression gate only.

#### Type safety and maintainability

- Not applicable.

#### Error handling and logging

- Not applicable.

### PowerShell implementation audit

#### What changed well

- `HarnessHookParity.psm1` judges groups by ecosystem membership (H1, H2) and entries individually (H3 to H5), compares ordinally throughout, and selects by `name`, never by parsing `id`, as the spec requires.
- `Get-HarnessHookGapClass` returns `INVALID` for a recognized prefix with a blank reason and for an unrecognized `GAP:` prefix, so a malformed gap note cannot satisfy H1 or H5.
- The Codex hook loads its helpers through the existing dependency-guard pattern and fails closed with `PR_AUTHOR_OUTPUT_MISSING:` on a load failure, a dependency failure, or a validator exception; the completeness row was added to `hook-dependency-failure.Codex.Tests.ps1`.
- The one-continuation rule allows a blocked stop only when `stop_hook_active` parses as true; a malformed payload therefore stays blocked.
- The registration matches existing entries: `pwsh -NoProfile -File` with `command_windows` twin and `timeout = 30`.

#### API and safety notes

- Advanced functions with `[OutputType()]`; explicit `Export-ModuleMember`. PSScriptAnalyzer reports 0 findings over the 15 changed PowerShell files.
- No Codex hook file at or above 490 physical lines at Phase 0 was edited (`scope.2026-11-18T11-18.md`).

#### Error handling and logging

- The hook writes no stdout and emits the block reason to stderr through `Exit-SubagentStopBlock`, matching the Codex SubagentStop contract.

---

## Test Quality Audit

The Pester gate at the reviewed head reports 29194 passed and 0 failed, and this review re-parsed the coverage artifact per file: `validate-pr-author-output.ps1` 100%, `HarnessHookParity.psm1` 100%, `subagentstop-envelope.ps1` 96.67%.

### Reviewed test and QA artifacts

- `tests/scripts/codex-hooks/codex-validate-pr-author-output.Tests.ps1` — twin-rule AST pin, allow and block decision cases from the Claude suite on Codex payloads, one-continuation, entrypoint in-process and in child processes, registration in root and bundle `config.toml`.
- `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1` — committed-matrix H1 to H5, C1 (`#555`) and C2 (`agent_type`), every DEFER stem, the AD-8 group, stem-to-group membership for four cross-stem groups, recorded divergences, Copilot `owner_child` 6, and two in-memory negative cases.
- `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1` — byte identity of the Phase 0 helper set.
- `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/evidence/regression-testing/pester-gate.2026-11-18T12-14.md` — the gate after the generator-source correction.

### Quality assessment prompts

- **Determinism:** in-memory payloads; console redirection restored in `finally`; no clock, sleep or temporary file.
- **Isolation:** one behavior per `It`; `AfterAll` removes the modules the gate imported.
- **Speed:** 180 new tests within an eight-shard run of 760.85 s.
- **Diagnostics:** the gate prints each violation message in `-Because`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token in any added file; leak scan 0 failures. |
| No unsafe subprocess or command construction | ✅ PASS | The hook starts no process; no `Invoke-Expression`. Tests start the current `pwsh` with an argument list. |
| Input validation at boundaries | ✅ PASS | Payload anomalies classified by the envelope helper and blocked as `PR_AUTHOR_OUTPUT_MALFORMED`. |
| Error handling remains explicit | ✅ PASS | Every error path exits 2 with a prefixed reason. |
| Configuration / path handling is safe | ✅ PASS | Helpers resolved with `Join-Path $PSScriptRoot`; registration uses `git rev-parse --show-toplevel` like existing entries; no hook invokes Python (scan extended to `.github/hooks`). |

---

## Research Log

No external research was required; all findings derive from the branch diff, repository rules and the feature evidence.

---

## Verdict

The change is ready for the normal PR flow. The findings are one Nit and four Info notes; none blocks merge under the cost-benefit rule, and none is carried into remediation inputs. The CI-dependent criteria (the Linux hook-suite job and the CI-only integration suite) remain for the orchestrator at S9.
