# Code Review: parallel-surface-destination-portability-bash (#462)

**Review Date:** 2026-08-10
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462`
**Feature Folder Selection Rule:** single active folder whose suffix matches the canonical issue number 462 and whose scoping docs carry the material changes.
**Base Branch:** `main` (merge-base `a26286e87137780ee9e5f59ba2753c2307617572`)
**Head Branch:** `drm-copilot-wt-2026-08-10T09-25` @ `aec5e539338851b5e6c1eb2eb347dd897fecd683`
**Review Type:** Initial review

---

## Executive Summary

The branch adds a destination-portable bash runtime layer for the parallel orchestration surface (nine files under `.claude/lib/bash/` with byte-identical bundled mirrors), extends the Claude push-down to publish `config/` with a single-path merging publish for `orchestration-routing.json`, corrects the core pack manifest and hardens its completeness test, extends Shell-QC discovery and kcov measurement to the new library, and repoints the parallel skills/agents at the interpreter-free entry points. The diff spans 164 files (+11449/−145); roughly two thirds is committed test fixtures, tests, and feature-folder evidence. Implementation quality is high: the bash port is decomposed by concern under the 500-line cap, determinism hazards (locale, octal, associative-array iteration) are addressed with explicit countermeasures, and the parity discipline binds the port to the Python authority through shared committed corpora asserted by both CI lanes with count floors.

**What changed:**
Production: `.claude/lib/bash/*` (9 new), `claude-customizations.ts` (+`ROOT_FOLDERS` entry, decorator wiring), `claude-routing-merge.ts` (new, 308 lines), `scripts/bash/shell_qc_lib.sh` (third discovery/kcov root), `core.json` (+13 entries), bundled `config/` (2 new), `.claude/settings.json` and two agent definitions (+1 allowlist pattern), `.gitignore` (fixture negation), `_shell-coverage.yml` (+1 check step). Tests: 2 pytest parity suites, 9 new + 2 extended bats suites, 3 Jest files, 73 fixtures.

**Top 3 risks:**
1. The `Bash(bash .claude/lib/bash/*)` allowlist entry uses prefix-wildcard semantics; the disclosure artifact overstates its narrowness in two respects (see Finding 1). The grant is still far narrower than the pre-existing `Bash(pwsh *)` and `Bash(git *)` entries.
2. The two file-wide SC2015 suppressions silence that check for all future edits to two production shell libraries, not only the eight benign pre-existing sites (Finding 2).
3. Parity binding between the bash port and the Python authority is two-hop (Python change fails the pytest lane against the corpus; a corpus edit then fails the bats lane), which is sound but depends on both CI lanes remaining mandatory; neither lane's trigger was weakened by this diff.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; all toolchain gates re-verified green at head; the Minor findings are follow-up material that does not change runtime behavior.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/other/permission-surface-callout.2026-08-10T17-08.md` | "Why the pattern is narrow" | Two narrowness claims are overstated: the trailing `*` in `Bash(bash .claude/lib/bash/*)` matches any continuation of the command string, so the pattern does match nested subdirectories (`bash .claude/lib/bash/sub/x.sh`) and does not prevent `..` traversal (`bash .claude/lib/bash/../../other.sh` retains the matching prefix). | Correct the two sentences before pasting the callout into the PR body; optionally narrow the grant to three entry-point prefixes (`Bash(bash .claude/lib/bash/compute-cohorts.sh *)` etc.), which also stops direct invocation of the six sourceable library files and of any future file dropped into the directory. | A permission-surface disclosure whose narrowness claims are inaccurate undermines the review it exists to enable, even when the grant itself is reasonable and consistent with the repo's existing prefix-pattern posture. | Inspected callout text lines 37–41 against Claude Code Bash prefix-wildcard permission semantics; `.claude/settings.json:8`. |
| Minor | `scripts/bash/shell_qc_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh` | file headers (lines 13–17 / 17–21) | File-wide `# shellcheck disable=SC2015` covers the whole file, not only the eight pre-existing `<test> && <assign> \|\| true` sites (7 + 1). A future genuine `A && B \|\| C` if-then-else confusion in either file will no longer be flagged. The justification also states that `.claude/rules/shell.md` "mandates" the idiom; the rule mandates capturing legitimate non-zero exits and names `\|\| rc=$?` as its example. | Follow-up: replace with per-line `# shellcheck disable=SC2015` directives on the eight sites, or rewrite them as `if <test>; then <assign>; fi`, which eliminates the finding without any suppression. Not blocking: the reason is stated inline as the rule requires, and each suppressed site is the benign `\|\| true` capture genuinely needed under `set -e`. | shell.md permits suppressions "only when justified inline ... stating the reason"; the letter is met, but the scope exceeds the eight findings it resolves, and the repo's Python/TypeScript suppression policies both prohibit file-level scope as a matter of principle. | `grep -n '&& .+ \|\|' scripts/bash/*.sh` — exactly 8 idiom sites; diff hunks in both files; `.claude/rules/shell.md:81-85`. |
| Nit | `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` | line 123 | `return parsed as JsonObject;` is a type assertion without an inline justification comment. It is safe (the preceding guard excludes null, non-object, and array), but `typescript.md` asks that assertions be justified. | Add a brief trailing comment (for example: narrowing from `unknown` to an indexed JSON shape is not expressible without an assertion) or convert to a typed predicate helper. | Keeps the repo's assertion-hygiene signal intact in a file that is otherwise exemplary about documenting rationale. | Read of `claude-routing-merge.ts:112-124`; `.claude/rules/typescript.md` "Strong typing". |
| Info | `.gitignore` | lines 33–37 | The generic Python-artifact `lib/` rule matches any directory named `lib/` at any depth and now requires a fourth negation pair. The added negation is correct and complete (`git check-ignore` exit 1; `tests/fixtures/shell_qc/.claude/lib/bash/lib_entry.sh` is tracked), and the silent-exclusion failure mode is now loud: the discovery bats test pins the fixture as `lines[0]` of an exact-count-6 assertion, so its absence fails CI. The trap remains for future checked-in `lib/` trees. | Consider a follow-up that scopes the Python build-artifact rule (for example anchoring it to the Python package roots) so new fixture trees do not each need a bespoke negation. | Root-cause is a broad pattern, not this change; this change handles it correctly and documents why. | `git check-ignore -v` exit 1; `tests/shell/test_shell_qc_discovery.bats` count-6 pinned-order assertion; .gitignore comment block. |
| Info | `.claude/skills/parallel-add/SKILL.md` | line 73–86 | `decide_admission(...)` and `recolor_unstarted(...)` remain named as Python functions with no destination-runtime invocation form. This matches the feature's documented residual-gap posture (execution-phase F6/F8 surfaces stay Python-only at destinations), but `parallel-add` is itself partly execution-phase, so a destination running `/parallel-add` will still hit an interpreter dependency at the admission step. | Record `parallel-add` admission/recolor as an explicit entry in the known residual destination gaps (spec Non-Goals names the drift and mutation-abandon CLIs but not these two functions), or route recoloring through `compute-cohorts.sh` in a follow-up. | Prevents the next destination-portability audit from rediscovering the gap. | grep of `parallel-add/SKILL.md`; spec.md Non-Goals section. |
| Info | `.claude/skills/feature-review-workflow/SKILL.md` | line 75 (outside this diff) | The skill names `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` as the supporting validator for the `modified-workflow-needs-green-run` rule; no such file exists in the repository (`git ls-files` finds no match). Pre-existing docs drift, not introduced by this branch. The rule was discharged manually in this review (`gh run view 31411775305`: headSha == branch head, conclusion success). | File a docs-drift issue to either land the script or correct the skill reference. | A reviewer following the skill verbatim would look for a validator that does not exist. | `git ls-files \| grep -i ModifiedWorkflow` → no match. |
| Info | `artifacts/pr_context.summary.txt` | "Close candidates" (generated artifact, not in diff) | The author-asserted autoclose list contains `#ISO-8601` (an invalid reference token) alongside #393, #394, #462. GitHub verification was unavailable to the context generator. | The PR author should curate the autoclose list before PR creation; #462 is the canonical closing issue, and #393/#394 should be included only if this branch genuinely completes them. | An invalid autoclose token in the PR body is noise; incorrect autoclose of #393/#394 would close open work. | pr_context.summary.txt lines 32–36. |

No Blocker or Major findings.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- The merging publish is placed at exactly the right seam: a `PushDownFileSystem` decorator closest to the real adapter, so the shared engine, `rewriteReferences` (which sees source text only), and the Copilot/Codex entry points are untouched. The file-level doc comment explains why the two rejected placements would be wrong.
- The merge rule is pinned for idempotency (destination key order preserved, source-order appends, fixed 2-space + trailing-newline serialization) and each property is asserted by a dedicated Jest case, including byte-stability across a second push and untouched destination bytes on parse failure.
- `ROOT_FOLDERS` extension carries a doc comment recording the enumeration-order contract, and Jest non-regression cases pin the Copilot and Codex `ROOT_FOLDERS` constants and published sets.

#### Type safety and maintainability

- A recursive `JsonValue`/`JsonObject` type replaces any temptation toward `any`; `parseRoutingObject` narrows from `unknown` with explicit guards. One assertion (`as JsonObject`, line 123) is safe but uncommented (Nit above). No new ESLint or TS suppressions anywhere in the TS diff.
- `RoutingMergeError` carries a typed `path` field so the run summary can name the offending file.

#### Error handling and logging

- Parse failures fail exactly one file with an explicit message and never clobber destination bytes; the behavior is Jest-asserted rather than merely documented.

### Bash implementation audit (destination-runtime library)

#### What changed well

- Clean decomposition under the 500-line cap: common helpers (pythonRepr, enum-error templates, locale guard), a fail-closed restricted YAML scanner/emitter pair, item validation, cohort computation, and three thin CLI entry points with a documented 0/1/2 exit-code contract.
- Determinism hazards named in the spec are countered in code: `pc_enforce_c_locale`, `sort -n`, strict integer lexis rejecting leading zeros fail-closed (with the octal rationale in the header), and no associative-array iteration reaching output.
- Source-guard pattern (`BASH_SOURCE[0] == $0`) lets every entry point be sourced by tests without side effects, and main's return code is re-exited explicitly.

#### API and safety notes

- The library never `eval`s manifest content; the YAML scanner is a lexical subset parser that refuses anything outside the machine-authored manifest shape (exit 2 with `PM_SUBSET_DETAIL`).
- The two shellcheck suppressions in the modified pre-existing libraries are the only suppressions in the shell diff; the nine new files are shellcheck-clean with no directives (one `SC1091` source-path informational disable at each source site, which is the standard pattern for runtime-resolved paths).

#### Error handling and logging

- Exact Python error strings are emitted on stderr with exit 1; lexical/usage errors are distinguished as exit 2 so a destination caller can tell contract violations from misuse.

### Python implementation audit

#### What changed well

- No production Python changed — the authority modules stay frozen, which is the point. The two parity suites are typed end-to-end, use guard helpers that raise diagnostic `TypeError`s naming the dotted fixture path, and enforce corpus floors so the parametrized set cannot silently empty.

#### Typing and API notes

- No new public Python API surface was added. Guard helpers return narrowed types (`list[int]`, `list[tuple[int, int]]`) rather than casting at use sites.

#### Error handling and logging

- Error fixtures pin exact `ParallelCohortInputError` messages via `pytest.raises` plus string equality, which is the right strictness for a parity contract.

---

## Test Quality Audit

Verification evidence is unusually complete for this repository: three language lanes with baselines captured before Phase 1, final gates at the near-terminal commit, a head-SHA-matched CI discharge, and a coverage-delta artifact comparing like-for-like lanes. This review re-ran every locally executable stage at head and re-derived the CI conclusion rather than accepting recorded artifacts.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` / `test_parallel_manifest_bash_parity.py` — Python-lane corpus assertions with floors (20/24); re-run at head, 31 + 83 cases green. The four suite headers carry an identical declared-divergence statement (M1 PyYAML text; non-printable repr escapes), so the verified scope cannot drift silently between lanes.
- `tests/shell/parallel_cohorts_parity.bats` / `parallel_manifest_parity.bats` — bash-lane corpus loops with the same floors plus a post-loop `checked >= floor` re-assertion, so a silently skipping loop cannot pass; green in CI run 31411775305 at head.
- `tests/shell/parallel_payload_only.bats` — the strongest destination claim: entry points run from a payload-only directory under a PATH exposing only four checked-in coreutils shims, with `python`, `python3`, and `poetry` positively asserted unreachable.
- `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` — 15 cases covering publish, pack-scoped publish, the six merge behaviors, three-copy byte pins, and Copilot/Codex non-regression; re-run at head.
- `evidence/qa-gates/final-shell-gate-head.2026-08-10T17-00.md` — candid about its own one-commit-behind ordering constraint and instructs re-derivation; this review re-derived: run 31411775305 headSha `aec5e539...` == branch head, conclusion success, `Bash coverage (lines): 92.4%`.
- `evidence/qa-gates/coverage-delta.2026-08-10T16-52.md` — per-language baseline/final comparison; figures reproduced exactly by this review's re-runs.

### Parity contract durability (caller examination item 4)

The binding is corpus-mediated: the pytest lane asserts the Python authority reproduces every fixture; the bats lane asserts the bash port reproduces the same fixtures. A change to the Python reference therefore fails the pytest lane first; bringing the corpus up to date then fails the bats lane until the bash port is updated. Both lanes run in CI (`_quality-checks.yml` pytest; `_shell-coverage.yml` bats), both enforce floors (20/30 and 24/43 committed), and both loops re-assert the checked count. This is a sound two-hop binding; its one dependency is that both CI lanes remain required, which this diff does not weaken. Direct cross-process execution (bash invoked from pytest) was deliberately avoided — correct for this repository, whose Python lane runs on win32 where the bash toolchain is unavailable.

### Quality assessment prompts

- **Determinism:** no clock/RNG/network in any new test; locale pinned; corpora committed and read-only.
- **Isolation:** per-fixture parametrization; per-behavior Jest cases; per-clause bats tests.
- **Speed:** pytest 17.81s / Jest 6.97s measured by this review.
- **Diagnostics:** divergence output names the fixture and prints status/actual/expected; corpus-floor failures explain the remediation.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no tokens, keys, or credentials; new configs are routing tables and a blast-radius default. |
| No unsafe subprocess or command construction | ✅ PASS | No `eval` of input anywhere in the bash library; manifest text is parsed lexically, never executed; TS code performs no process spawning. |
| Input validation at boundaries | ✅ PASS | Strict integer lexis with fail-closed leading-zero rejection; YAML subset parser refuses out-of-subset constructs (exit 2); `parseRoutingObject` guards null/array/non-object roots. |
| Error handling remains explicit | ✅ PASS | Typed `RoutingMergeError`; documented per-entry-point exit-code contract; no broad catch-and-continue added. |
| Configuration / path handling is safe | ✅ PASS | Merge target matched by normalized destination-relative equality (`relativeToPosix`), not substring; entry points resolve their own directory via `BASH_SOURCE` so cwd is irrelevant. |
| Permission surface | ⚠️ PARTIAL | One new allowlist pattern in three files plus bundled mirrors, disclosed in a dedicated evidence artifact; grant is reasonable and narrower than existing entries, but two disclosure claims are inaccurate (Finding 1) and a three-prefix narrowing is available. |

---

## Research Log

No external research was required. The review relied on repository policy files, the feature folder's research/spec/plan artifacts, direct diff inspection, re-execution of the local toolchains, and `gh` API verification of the CI run at head. The one external-knowledge item applied is Claude Code's Bash permission prefix-wildcard matching semantics, used to assess Finding 1.

---

## Verdict

The change is ready for normal PR flow. The implementation matches its spec closely, the schema freeze was verified against the diff rather than assumed, coverage rose or held in every measured lane, and the destination-portability claim is proven by a genuinely interpreter-free end-to-end test rather than by assertion. The findings are two Minors (disclosure wording; suppression scope), one Nit, and three Infos — none alters runtime behavior, and none warrants a remediation cycle. The single operational caveat: the head-SHA-matched shell-gate discharge is invalidated by any further commit to this branch, so if the PR author amends anything, one fresh `_shell-coverage.yml` dispatch is required before merge.
