# Code Review: cd-chained-command-recurring-deny (#1165)

**Review Date:** 2026-11-10
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/cd-chained-command-recurring-deny-1165`
**Feature Folder Selection Rule:** named by the caller; matches the branch issue number 1165
**Base Branch:** `main` (merge base `ff9d8afc0a61ac723cd449b0c0658ea42680cd2e`)
**Head Branch:** `bug/cd-chained-command-recurring-deny-1165` (head `eaf42f48d8792c7099ef5c411025d43413f0dca2`)
**Review Type:** Initial review

---

## Executive Summary

The branch addresses the recurring fleet notice for the Claude `validate-bash.ps1` cd-chained deny by changing guidance only. The deny decision, its pattern, its read-word family, `Get-CdChainedReadCommandMatch`, and the leading `Forbidden Bash pattern:` sentence are unchanged; only the final remedy sentence is replaced with intent-specific text built by a new pure helper. The same intent-to-form table is published on a launch-loaded Claude rule, a Codex skill, a Copilot instruction, and the six `execution-environment` brief copies. Two contributing drivers are also fixed: the `WORKTREE_VENV_BLOCKED:` reason now names `poetry -C <worktree root>`, and `parallel-orchestrate` no longer instructs a `git -C ... reset --hard` that the hook denies.

**What changed:**
`validate-bash.ps1` gains one guarded dot-source and a one-line change in `Get-BashBlockReason`. The new `bash-command-shape-guidance.ps1` (178 lines) reads the existing scanner segments, finds the `cd` target and the `git`/`poetry`/`npm`/`npx` tools after it, and composes the guidance. All mirrors are byte-identical at head (13 blob comparisons). Tests: two new Pester files (90 tests), one new Python contract file (6 tests), and additions to three existing test files.

**Top 3 risks:**
1. The intent-specific reasons may split the Claude Code fleet-notice grouping into several messages that share the `Forbidden Bash pattern:` prefix (spec operational note); no repository contract depends on the grouping.
2. Tool detection does not see a tool behind `sudo` or invoked by absolute path (`/usr/bin/git`); such commands receive the plain-read guidance. The decision is unaffected.
3. The Codex surface is a skill, which Codex loads on demand rather than at launch; since Codex has no cd-chained deny, the impact is limited to guidance reach.

**PR readiness recommendation:** **Go** — the implementation is correct and fully tested, and the two coverage-evidence findings of the 01-15 review were resolved by reviewer gate runs at head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `artifacts/python/lcov.info` | item worktree | Resolved: the 01-15 review found the Python coverage artifact absent although `test_bash_command_shape_surfaces.py`, `test_claude_rules_frontmatter.py`, and `test_execution_environment_brief_contracts.py` changed (policy-audit PA-1). | None; the reviewer run at head gives 97.11% lines and 94.38% branches. | Coverage verification is mandatory for every language with changed files. | `ls artifacts/python` fails in the worktree; `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` command has no `--cov`. |
| Info | `artifacts/pester/powershell-coverage.xml` | item worktree | Resolved: the coverage artifact was written at 00:52:23Z, before the commit at 01:07:06Z, so the Stop-hook freshness gate rejects it (policy-audit PA-2). All changed `.ps1` files were last modified before the write, so the figures are correct. | None; the reviewer rerun at 01:38:48Z reproduced 95.80% lines and 100% for the helper. | The freshness gate blocks completion of the review. | `date -u -r` on the artifact and on each changed `.ps1` file. |
| Minor | `.claude/hooks/bash-command-shape-guidance.ps1` | `Get-CdChainedCommandIntent`, after-`cd` branch | `cd /x && sudo git log ... head` and `cd /x && /usr/bin/git log ... head` report no tools, so the reason gives the plain-read remedy instead of `git -C`. The `env` wrapper is found only because the scanner reads env-led segments raw. | Optional follow-up within the item: treat `sudo` like `env`, or accept as documented. | Guidance quality for uncommon shapes; no decision impact. | Reviewer direct-call probe `probe1165.ps1` (17 shapes). |
| Info | `.agents/skills/bash-command-shape/SKILL.md` | whole file | The Codex equivalent is a shared skill (converter classification of an unscoped rule), not an always-loaded surface. | None required; the skill states that the deny exists only on Claude Code. | Matches spec scope; limits Codex reach only. | `scripts/dev_tools/codex_native_converter/classifier_claude.py` rule branch. |
| Info | `.claude/skills/parallel-orchestrate/SKILL.md` | conflict-resolution step (c) | `reset --keep HEAD~1` keeps uncommitted local changes and refuses when they overlap the reverted commit, where `--hard` discarded them. After a failed `csharpier check` or `build` the tracked tree is expected to be clean, so the revert behaves as before. | None required. | Semantic difference noted for operators. | Diff of the step; hook probe: `--keep` allowed, `--hard` denied. |
| Info | `.claude/hooks/validate-bash.ps1` | `bash -c "cd /x && git log ... head"` | The wrapper-led form with a pipe-filter read is allowed by the hook at base and at head; the decision set is unchanged by design. | None; out of scope (decision changes are a non-goal). | Records an observed allow for the owner. | Decision corpus row `Blocked = $false`; reviewer probe. |

No Blocker or Major findings. The two evidence findings of the 01-15 review are resolved: `evidence/qa-gates/pytest-coverage.2026-11-10T01-28.md` and `evidence/qa-gates/pester-coverage.2026-11-10T01-38.md`.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well

- Only test code changed. `test_bash_command_shape_surfaces.py` asserts the same forms across the rule, Codex skill, Copilot instruction, and brief, plus the Copilot bundle byte comparison, which previously had no parity test.
- `test_claude_rules_frontmatter.py` introduces `LAUNCH_LOADED_RULES` and a dedicated test that fails if a `paths:` key is added, which protects the launch-loading property.

#### Typing and API notes

- No new public Python API surface was added.

#### Error handling and logging

- Defect lists accumulate every offending file before asserting.

### PowerShell implementation audit (if applicable)

#### What changed well

- The helper is pure: no disk, process, network, clock, or environment access, and it dot-sources nothing.
- Detection is not duplicated; the helper reuses scanner segments and runs only after `Get-CdChainedReadCommandMatch` reports a match.
- The tool pattern excludes path components and hyphenated words with look-arounds, avoiding false tool mentions.

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType()]`, and explicit `AllowNull`/`AllowEmptyString` attributes; PSScriptAnalyzer 0 findings; formatter 0 differences.
- The `CdTarget` value is echoed into the reason text inside single quotes. The reason is advisory text returned to the agent, so this introduces no execution path.

#### Error handling and logging

- The load is guarded with the single-statement `try`/`catch` that calls `Add-HookDependencyFailure`, so a broken helper produces the existing `HOOK_DEPENDENCY_LOAD_FAILED:` deny (fail closed); `hook-dependency-guard-completeness.Tests.ps1` passes 731 of 731.

---

## Test Quality Audit

The executor recorded one full parallel Pester run (21311 tests, 0 failures, 8 workers) and one parallel pytest run over `tests/scripts/dev_tools` (8852 passed). The reviewer re-ran the nine touched or contract pytest modules at head under `pytest -n auto` (145 passed) and probed the helper by direct calls on 17 shapes; each intent reason matched the spec text. Pester was not re-run by the reviewer, because the owner's parallel-only rule excludes single-file runs and the full-tree parallel run takes about 12 minutes; the coverage artifact was parsed instead.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/validate-bash.CdChainGuidance.Tests.ps1` — 60-row decision corpus with a recorded pre-edit baseline run (60 of 60), constant pins on the pattern and read words, and reason-shape assertions with present and absent tokens per intent.
- `tests/scripts/claude-hooks/bash-command-shape-guidance.Tests.ps1` — 22 direct tests; 100% line coverage of the helper.
- `tests/scripts/dev_tools/test_bash_command_shape_surfaces.py` — cross-surface consistency and frontmatter contracts.
- `evidence/qa-gates/scope-check.2026-11-10T00-57.md` — confirms the excluded paths are untouched and the brief hunks stay in two sections.

### Quality assessment prompts

- **Determinism:** literal strings only; no clock or randomness.
- **Isolation:** decision and reason shape in separate Contexts.
- **Speed:** pure string tests; the touched pytest modules ran in 7.52 s.
- **Diagnostics:** `-Because` messages name the intent and the token.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or host paths. |
| No unsafe subprocess or command construction | ✅ PASS | The helper builds text only; it starts no process. |
| Input validation at boundaries | ✅ PASS | Null and empty input return a defined intent. |
| Error handling remains explicit | ✅ PASS | Guarded load routes to the dependency-failure deny. |
| Deny decision unchanged | ✅ PASS | Decision corpus 60 of 60 before and after; destructive reasons byte-equal. |
| Mirror parity | ✅ PASS | 13 blob-identity comparisons at head. |

---

## Research Log

No external research was required. The launch-loading behavior of unscoped `.claude/rules` files is taken from the research record, section 3.1.

---

## Verdict

The implementation meets the spec: the deny decision is preserved, the reason names the replacement form for each intent, and the always-loaded and brief surfaces state the same forms with byte-identical mirrors. The change is ready for normal PR flow. The Minor and Info rows are non-blocking.
