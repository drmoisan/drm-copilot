# Code Review: CI gate vacuous on empty check list (#841, also closes #795)

---

**Review Date:** 2026-10-10
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841`
**Feature Folder Selection Rule:** the only active folder in the branch diff; its suffix matches issue 841 in the branch name.
**Base Branch:** `main` (`origin/main` @ `793731a12`, equal to the merge base)
**Head Branch:** `bug/ci-gate-vacuous-on-empty-check-list-841` @ `87f57d4f5`
**Review Type:** Initial review

---

## Executive Summary

The branch closes the vacuous-green gap in the S9 CI gate for epic-child PRs. `Invoke-CiGateParser.ps1` gains an opt-in `-RequireWorkflow` parameter; when set, an empty or null check set, a set with no passing check from the named workflow, or a set whose only matching checks are `skipping` yields `pending` instead of `success`. Failure and pending precedence over all observed checks is unchanged, and the default path (no parameter) is byte-for-byte the previous derivation. The orchestrate skill now wires `-RequireWorkflow CI` into S9 step 3 when `epic_mode` is true and describes the conclusion over the queried checks. The `modified-workflow-needs-green-run` rule gains a satisfiable predecessor-head alternative, and the `.agents` feature-review skill now defines the rule its citers reference (#795). The code delta is small (parser +79/-7, Pester +206/-1, new pytest file +312, three Markdown sources +15/-4 plus their mirrors); all four source/mirror pairs are byte-identical.

Evidence reviewed: the full branch diff, `artifacts/pr_context.summary.txt` (head 87f57d4f5), the 39 evidence files, reviewer-run Black/Ruff/Pyright/pytest (1299 passed), byte comparison of mirrors, the coverage XML on disk, and the pre-change CI run 38054308295 logs. Implementation quality is good: the guard is minimal, fail-fast on invalid input, StrictMode-safe, and every behavior-matrix row in `spec.md` has a dedicated test that failed before the fix (18 failures recorded in `evidence/regression-testing/pester-before-fix.2026-10-08T22-17.md`).

**What changed:**
- `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (+ mirror): `[string]$RequireWorkflow = ''` on the script, `Invoke-CiGateParser`, and `Get-CiGateConclusion`; whitespace-only rejection; `$requiredWorkflowPassed` tracking in the `pass` branch using a `-ceq` comparison guarded by a `PSObject.Properties` check; post-loop presence rule; help text and a new `.EXAMPLE`.
- `.claude/skills/orchestrate/SKILL.md` (+ mirror): S9 step 2 epic-child paragraph, step 3 wording and `-RequireWorkflow CI` variant, `head_sha` schema bullet.
- `.claude/skills/feature-review-workflow/SKILL.md` (+ mirror): qualifying-run definition with alternatives (a) and (b).
- `.agents/skills/feature-review-workflow/SKILL.md` (+ Codex mirror): new `## Policy Rules` section.
- Tests: 18 new Pester tests; new `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (26 nodes).

**Top 3 risks:**
1. Enforcement still depends on S9 passing `-RequireWorkflow CI`; the parser does not detect epic mode itself. Mitigated by the AC-11 text contract pinning the token in both orchestrate copies.
2. Codex S9 (`.agents/skills/orchestrate/SKILL.md`) still lacks the epic-child guard; recorded in the spec as a follow-up candidate, explicitly out of scope.
3. CI has not run on this branch (no PR). The PowerShell QC job on the PR is the first cross-host run of the new Pester tests; local evidence and the pre-change CI run indicate no expected failure.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; all ACs verified; remaining items are Nit/Info and spec-recorded follow-ups.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Nit | `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` | help `:20-24`, `:46`, `:121`; comments `:191`, `:206-207`; throw `:197` | Help text and comments still say "required check(s)" although the parser now also evaluates the unfiltered epic-child check set. The skill text was updated (CR-4) but the parser's own wording was not. | In a follow-up, change "required check" to "check" or "queried check" in the help and comments; update the mirror in the same commit. Leave the throw message unchanged unless tests are updated with it. | Consistency with the CR-4 wording; avoids implying the parser applies only to `--required` output. Not required by any AC. | `grep -n "required check" .claude/lib/ci-gate/Invoke-CiGateParser.ps1` (8 lines) |
| Nit | `.claude/skills/orchestrate/SKILL.md` | S9 step 2 epic-child paragraph (`:292`) | The pre-existing #658 sentence "every observed `CI` check must succeed" reads more strictly than the implemented and step-3 behavior, where a `skipping` `CI` check beside a passing `CI` check yields `success` ("passed or was skipped"). | Optionally reword to "no observed `CI` check may fail, be cancelled, or be pending" in a later wording pass. | Minor text tension; the parser and step 3 agree with each other, and spec matrix row "CI only skipping -> pending" is implemented. | `git diff origin/main...HEAD -- .claude/skills/orchestrate/SKILL.md` |
| Nit | `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` | `section()` `:114-125` | `lines.index(heading)` raises a bare `ValueError` ("... is not in list") when a heading is renamed, which is less descriptive than the fragment-list assertion messages used elsewhere. | Optionally assert `heading in lines` with a message naming the copy before indexing. | Diagnostic clarity on a future heading rename; behavior is already fail-closed. | Code inspection |
| Info | `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` | `:338` | The default `$NowProvider` delegate in the `Invoke-CiGateParser` param block is the only uncovered executable line (97.83% file coverage). It was uncovered at baseline (line 270). | None required. | Pre-existing; every test injects a fixed clock by design. | `evidence/qa-gates/final-pester-coverage.2026-10-08T22-17.md`, `evidence/baseline/pester-ci-gate-coverage.2026-10-08T22-17.md` |
| Info | `.agents/skills/orchestrate/SKILL.md` | CI Green Gate | Codex S9 has no epic-child guard equivalent (CR-1 parity). | Track as the follow-up listed in `spec.md` Rollout & Follow-up. | Spec non-goal; file explicitly excluded from this branch. | `spec.md` Scope & Non-Goals |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The gitignored coverage XML on disk was overwritten at 09:40 by the later `tests/scripts/claude-runtime` run and reports the parser at 0/46. Its 46 executable line numbers match the 09:37 evidence exactly. | None; reviewers should read the 09:37 evidence file for the parser figure. | Explains why the on-disk artifact differs from the recorded 97.83%. | Reviewer XML parse; `evidence/qa-gates/final-claude-runtime-pester.2026-10-08T22-17.md` |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well

- The contract module reads committed files only, normalizes whitespace before fragment matching (robust to reflow), and scopes each search to the relevant section (`S9`, schema, rule heading) rather than the whole file, so a fragment elsewhere cannot satisfy the contract.
- The #795 resolver resolves bundle-copy citations against the bundle root (`bundle_root`), so the Codex mirrors are checked against the Codex mirror of the cited file, not the source.
- A synthetic negative case and a synthetic positive case prove the resolver can fail, using in-memory text only.

#### Typing and API notes

- All functions are fully annotated (`tuple[str, ...]`, `dict[str, str]`, `list[str]`); Pyright reports 0 errors. No public Python API surface was added (test module only).

#### Error handling and logging

- No exception handling or logging; failures surface as assertion messages naming the copy and the missing fragments.

### PowerShell implementation audit (if applicable)

#### What changed well

- The guard is opt-in with an empty-string default, so `--required` callers (non-epic S9, `epic-orchestrate` final PR) are unaffected; all 15 pre-existing tests pass unchanged.
- Precedence is preserved: `fail`/`cancel` still short-circuit, `pending` is evaluated before the presence rule, and the presence rule runs last.
- `PSObject.Properties.Name -contains 'workflow'` before reading `$check.workflow` keeps elements without the property (status contexts) from throwing under `Set-StrictMode -Version Latest`; this mirrors the existing `bucket` check.
- Case-sensitive `-ceq` matches the GitHub workflow name exactly (`.github/workflows/ci.yml` declares `name: CI`).

#### API and safety notes

- Whitespace-only input throws with a message naming `-RequireWorkflow`, rather than silently disabling the guard (spec A-4). `ValidateNotNullOrEmpty` is correctly not used because `''` is the documented off value.
- No new functions; approved verbs retained; PSScriptAnalyzer 0 findings.

#### Error handling and logging

- One new fail-fast throw; existing throws unchanged. No logging changes, consistent with the existing script.

---

## Test Quality Audit

The new Pester tests cover every row of the spec behavior matrix, the whitespace rejection, the script-level `process`-block forwarding, and the parameter/help surface via the AST (no execution needed). The before-fix run records 18 failures, each naming `RequireWorkflow`, with the 15 pre-existing tests passing, which demonstrates the tests detect the defect. The pytest module pins the CR-4, PA-N9, and #795 text contracts in all source and mirror copies.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` — 33 tests (18 new), 0 failures; behavior tests assert only `conclusion`.
- `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` — 26 nodes, 0 failures (reviewer run, 0.10 s).
- `evidence/regression-testing/pester-before-fix.2026-10-08T22-17.md` — 18 expected failures before the parser change.
- `evidence/regression-testing/pytest-before-fix.2026-10-08T22-17.md` — text contracts failing before the skill edits.
- `evidence/qa-gates/final-pester-coverage.2026-10-08T22-17.md`, `coverage-comparison.2026-10-08T22-17.md` — 97.83% file, 100% changed executable lines.
- `evidence/qa-gates/final-mirror-hashes.2026-10-08T22-17.md` — mirror parity; reviewer `cmp` confirms all four pairs identical.

### Quality assessment prompts

- **Determinism:** fixed clock delegate; in-memory check sets; no `gh`, network, or temp files.
- **Isolation:** one `It` per matrix row; one pytest function per contract, parametrized by copy.
- **Speed:** Pester folder 0.834 s; pytest file 0.10 s.
- **Diagnostics:** pytest messages list the copy and missing fragments; Pester names describe the expected conclusion. See the `section()` Nit.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | No process execution added; the forwarding test invokes the script in-process. |
| Input validation at boundaries | ✅ PASS | Whitespace-only `-RequireWorkflow` rejected; missing/unknown `bucket` still throws. |
| Error handling remains explicit | ✅ PASS | New throw names the parameter; no catch blocks added. |
| Configuration / path handling is safe | ✅ PASS | Pytest builds paths from a fixed `REPO_ROOT` and constant relative paths. |
| Default behavior preserved | ✅ PASS | Empty-array and null-set tests without the parameter still return `success`. |

---

## Research Log

No external research was required for the review. The design basis `research/research.2026-10-09T02-25.md` records the `gh pr checks` zero-check behavior (verified against cli/cli source, not the local `gh` version; spec A-6), which the S9 text covers for both the error and the `[]` forms.

---

## Verdict

The change is ready for normal PR flow. The parser guard is minimal, opt-in, and fully tested against the specified behavior matrix; the skill text changes are pinned by text-contract tests in every source and mirror copy; mirrors are byte-identical; and no excluded file was touched. The three Nits (parser help wording, a pre-existing S9 sentence, and a test-helper diagnostic) and the Info items do not affect correctness and do not require remediation. The orchestrator S9 CI green gate on the PR head remains the final check.
