# Code Review: Development-Docs Root Resolver and Feature-Folder Name Parser (#1035)

---

**Review Date:** 2026-11-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035`
**Feature Folder Selection Rule:** the folder whose name carries the canonical issue number 1035, named by the delegation prompt.
**Base Branch:** `epic/shared-agent-harness-layer-integration` (merge base `7ebf1347dd8fb86613d40e66461fa5ad64a07cfb`)
**Head Branch:** `feature/dev-docs-root-resolver-phase1-1035` (head `e3a7b7de2dd82b9968ecb2f698055006515c4853`)
**Review Type:** S6 full feature review (first review)

---

## Executive Summary

The branch implements Phase 1 of #1016 for epic #1018 child 2. The review covered the full two-dot diff `7ebf1347d..e3a7b7de2` (451 files). The merge commit `e3a7b7de2` brings the #1025 harness files from the integration tip; they are outside this diff and do not interact with the change.

The three resolvers implement R-1 to R-8 with the same branch order (file absent or unreadable, parse, object check, key presence, closed-set check, default short-circuit, `.dev` probe, `docs/features` probe, `.dev`). Error messages name `config/orchestration-routing.json`, the key and the value in all three runtimes, and the PowerShell resolver returns a typed result (`Succeeded`, `Root`, `Reason`) that hooks use to fail closed. The area map is a table, not a suffix rule, as D-6 requires. The write-scope contract exports the spec signatures, and the three-direction checker discriminates (a removed `.dev` literal fails it, recorded in `task-check.P7-T5`). The `no-vscode-import` test discriminates (mutant probe recorded). `json_config.py` stays free of `scripts.dev_tools` imports. No closing keyword for #1016 exists in the diff or the commit messages, and OD-P4 (blast-radius derivations take an optional root and do not call the resolver) is implemented as decided.

The blocking findings are coverage findings, not code defects: F1 (nine modified production files below the modified-file thresholds, none regressed) and F2 (Python report older than the newest Python commit; the reviewer regenerated the TypeScript and PowerShell reports, but the pytest launch was refused by a PreToolUse hook). Both are recorded in the policy audit and the remediation inputs.

**Top 3 risks:**
1. BOM and PowerShell-version parity of the routing-file read (CR-2, CR-3): a BOM-prefixed routing file resolves in PowerShell but fails R-3 in Python and TypeScript, and `-DateKind` needs PowerShell 7.5.
2. Six covered files are at or above the 700-line advisory tier, including `EpicCrossDependency.psm1` at 780 lines in three copies, close to the 800-line hard limit.
3. CI-only verification remains for the integration lane and the full suites on the pull request head.

**PR readiness recommendation:** **Not ready** - two blocking coverage findings (F1, F2).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `scripts/dev_tools/copy_research_to_issue.py`, `scripts/dev_tools/plan_progress_report.py`, `scripts/dev_tools/atomic_executor/cli.py`, `.codex/hooks/authorize-root-epic-invocation.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`, `.codex/scripts/epic-child-launch-contract.ps1`, `.codex/scripts/epic-child-launch-runtime.ps1`, `scripts/dev-tools/link-feature-docs.ps1`, `scripts/dev-tools/new-potential-entry.ps1` | whole file | F1: modified production files below the modified-file thresholds in the single gate run (line 50.00% to 83.58% for eight files; `atomic_executor/cli.py` branch 73.08%). None regressed from the Phase 0 baseline. | Add tests until each file reaches 85% line and, for Python, 75% branch; where host-bound code blocks testing, extract it into a testable function per the Coverage Exclusion Policy. | Agent contract: a modified file below the governing thresholds in the gate run is FAIL. | Policy audit 1.2.1 table; `artifacts/python/lcov.info`; `artifacts/pester/powershell-coverage.xml` |
| Blocking | `artifacts/python/lcov.info` | worktree root | F2: the Python report (10:18:35Z) predates commit `32d8b4260` (10:19:58Z). Content equivalence with the head is proven, so the figures stand. The reviewer regenerated root `coverage/lcov.info` and `artifacts/pester/powershell-coverage.xml` at the head; the pytest launch was refused by `PREIMPLEMENTATION_GATE_BLOCKED` in the review session. | Re-run the pytest coverage gate at the remediation head (with the F1 work) and record the evidence. | The coverage Stop hook compares report time with commit time. | Policy audit `## CI Cross-check`; `evidence/qa-gates/reviewer-coverage-rerun.2026-11-17T12-05.md` |
| Warning | `.claude/lib/epic-wave/EpicCrossDependency.psm1` and its two bundle copies | whole file | 780 logical lines (merge base 769); at or above the 700-line advisory tier. | Split before further growth; new logic belongs in the development-docs module. | File-size policy advisory tier. | `evidence/qa-gates/file-size.2026-11-17T11-25.md` |
| Warning | `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` | whole file | 756 logical lines (merge base 695). | Consider a `.DevelopmentDocsRoot.Tests.ps1` sibling for the new cases. | File-size policy advisory tier. | `evidence/qa-gates/file-size.2026-11-17T11-25.md` |
| Warning | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` and its bundle copy | whole file | 711 logical lines (merge base 687). | Split when next edited. | File-size policy advisory tier. | `evidence/qa-gates/file-size.2026-11-17T11-25.md` |
| Minor | `.claude/lib/development-docs/DevelopmentDocsRoot.psm1`, `scripts/dev_tools/json_config.py`, `extensions/drm-copilot/src/lib/development-docs/root.ts` | resolver read and parse | CR-2: a routing file with a UTF-8 BOM resolves in PowerShell (`Get-Content -Raw` drops the BOM) but raises R-3 in Python (`json.loads` rejects a leading BOM) and TypeScript (`JSON.parse` on `readFileSync(..., "utf8")` keeps U+FEFF). Established from documented runtime behavior; not probed. No TypeScript loader in `src/lib` strips a BOM, so the pre-existing routing loaders share the behavior. | Record for epic child 4 (push-down) or strip a leading BOM in the Python and TypeScript readers. | Destinations that write the file with Windows PowerShell 5.1 produce a BOM; the three runtimes would then disagree. | Code inspection |
| Minor | `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` | `Resolve-DevelopmentDocsRoot`, `ConvertFrom-Json ... -DateKind String` | CR-3: `-DateKind` exists from PowerShell 7.5. On 7.0 to 7.4 the call throws a parameter error, which the `catch` reports as "not valid JSON", so every hook that reads the key fails closed. `.claude/hooks/subagentstop-envelope.ps1` already depends on the same parameter. | Accept as an existing 7.5 dependency, or drop `-DateKind` (the key value is a plain string). | The repository rule states PowerShell 7+; the error reason would misstate the cause. | Code inspection |
| Info | `docs/features/active/.../evidence/qa-gates/coverage-delta.2026-11-17T11-24.md`, `file-size.2026-11-17T11-25.md`, `self-review.2026-11-17T11-26.md` | Command lines | CR-4: the executor computed inventories against the merge base of `origin/main`, not of the integration branch. Before the integration-tip merge the production file set is the same; the reviewer re-derived it against `7ebf1347d`. | Use the PR base in future evidence. | Avoids attributing integration-branch content to the item. | `git diff --name-status 7ebf1347d..HEAD` |
| Info | `.codex/hooks/authorize-root-epic-invocation.ps1`, `.codex/hooks/record-subagent-routing-attestation.ps1`, `.codex/scripts/epic-child-launch-runtime.ps1`, `scripts/dev-tools/link-feature-docs.ps1`, `scripts/dev-tools/new-potential-entry.ps1` | changed lines | CR-5: ten PowerShell changed lines are uncovered (script-entry lines, a bundle-layout import branch, two lines of an untested profile function). Per-language changed-line coverage is 97.49%. | Cover with F1 work. | Visibility of per-file shortfalls. | `coverage-delta.2026-11-17T11-24.md` |
| Info | `extensions/drm-copilot/src/lib/development-docs/root.ts` | lines 140, 189 | CR-6: two uncovered branches (`describeValue` undefined rendering, and the `String(error)` arm). File branch coverage 95.74%. | Optional. | Above thresholds. | `extensions/drm-copilot/coverage/lcov.info` |

---

## Implementation Audit

### Python implementation audit

`json_config.py` gains the constants, `resolve_development_docs_root` (injected `read_text`/`is_dir`), `development_docs_path`, `known_root_prefixes`, `parse_feature_folder_name` and `format_feature_folder_name`. `OSError` maps to R-1 only; malformed JSON raises `ValueError` from the parse error. Consumers (`new_active_feature_folder_flow.py`, `new_active_feature_folder_io.py`, `potential_to_issue*.py`, `resolve_*_prompt.py`, `plan_progress_report.py`, pr-context modules, validators) route writers through the resolver and matchers through `known_root_prefixes`. `compute_blast_radius.py` takes an optional `development_docs_root` keyword and rejects an unknown root (OD-P4).

#### API and safety notes

- Keyword-only injection parameters with defaults; no global state.
- The changed existing-test expectations are limited to folder naming and the status line (`0063-json-quality`, `0123-sample`), plus the A-9 items; verified by reading every removed line of the 22 modified test files.

### TypeScript implementation audit

`root.ts`, `feature-folder-name.ts` and `write-scopes.ts` match the spec signatures. `root.ts` uses a structural reader (D-P5) that `FileSystem` satisfies, so the module imports nothing. `ACTIVE_FEATURE_DOCS_DIRECTORY` and `POTENTIAL_DOCS_DIRECTORY` in `extension-command-helpers.ts` are replaced with resolver calls. `compileGlob` now states its include-dot behavior.

#### API and safety notes

- No `any`, no type suppression in the new modules; one `as unknown` after `JSON.parse` followed by narrowing.
- `expandRequiredArtifactPattern` produces the spec pattern `^(?:docs/features|\.dev)/active/.+/spec\.md$`.

### PowerShell implementation audit

`DevelopmentDocsRoot.psm1` performs I/O only through script-block parameters, uses ordinal (`-ceq`, `-ccontains`) comparisons, and exposes `Get-DevelopmentDocsKnownRoot`, the per-area and root-alternation pattern function (OD-P1) and the name parser/formatter. Hooks import it with the guarded pattern; Codex importers probe the bundle-layout sibling first (D-P16). `feature-folder-resolution.ps1` stays pure and byte-identical with a `-RootPattern` default pinned by a test (OD-P2).

#### Error handling and logging

- Resolver failures surface as hook dependency failures with a reason naming the file and key (Pester-asserted).
- CR-3 describes the one case where the reason text would misstate the cause.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- Final gates: `python-tests.2026-11-17T10-18.md`, `typescript-tests.2026-11-17T10-25.md`, `powershell-tests.2026-11-17T11-20.md`; static gates of the same stamps; `coverage-delta.2026-11-17T11-24.md`; `file-size.2026-11-17T11-25.md`; `leak-scan.2026-11-17T11-22.md`; `self-review.2026-11-17T11-26.md`.
- Phase gates P1 to P8 and 62 task checks under `evidence/other/`.

### Quality assessment prompts

- Discrimination: two negative observations are recorded (vscode import mutant; removed `.dev` literal). The hook `.dev` cases fail when the passed root is ignored (BR-* and PA-DDR-* cases, per task checks).
- Coverage fixes during the final gates added tests for pre-existing gaps rather than weakening assertions; one unreachable `?? ""` fallback was removed from `activeFeatureSegment` in two files to make every branch reachable.

---

## Security / Correctness Checks

| Check | Result | Evidence |
|---|---|---|
| No permission broader than the contracted literals | PASS | Reverse-coverage direction of the checker rejects any unproduced `Write(`/`Edit(` scope naming the development-docs roots. |
| Fail-closed configuration handling | PASS | R-3/R-4 errors in three runtimes; typed PowerShell failure; Pester fail-closed test. |
| No `.dev` directory, default unchanged, no folder renamed, no migration command | PASS | `ls .dev` absent; `config/orchestration-routing.json` value `docs/features`; `evidence/other/scope-boundary.2026-11-17T10-13.md`. |
| No Closes/Fixes/Resolves line for #1016 | PASS | Keyword search over added lines and commit messages. |
| Enforcement hooks do not invoke Python | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` in the Pester gate. |
| Mirror parity | PASS | Resource-contract, Codex parity and generator `--check` suites passed. |

---

## Research Log

- Read the spec, user story, issue, the three resolvers, the executor evidence set and the PR context summary.
- Parsed `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info` and `artifacts/pester/powershell-coverage.xml` for repo-wide and per-file figures.
- Compared code-file modification times with report write times for the post-gate commits.
- Read every removed line in modified existing test files.
- Ran `validate_evidence_locations.py --root <worktree>` (exit 0).

---

## Verdict

**REMEDIATION_REQUIRED.** Two blocking findings (F1, F2), both autonomous. The implementation itself meets the spec; no code defect blocks the change.
