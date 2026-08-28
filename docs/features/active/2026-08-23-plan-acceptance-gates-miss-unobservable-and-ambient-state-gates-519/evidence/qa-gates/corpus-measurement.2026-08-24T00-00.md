# Corpus Measurement — [P6-T3] and [P6-T4]

Timestamp: 2026-08-26T13-32
Tasks: [P6-T3] (counts and classification) and [P6-T4] (vacuity declaration and driver-integrity checks)
Command: `poetry run python scripts/dev_tools/_tmp_plan_gate_corpus_driver.py`, then `--findings`, then `--g7-classify`, then `--integrity`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

Every invocation exited 0. Each exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect; no pipe stands between any command and its capture.

## The pre-declared decision rule, reproduced verbatim ahead of the counts

The rule below is reproduced from `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/corpus-measurement-decision-rule.2026-08-24T00-00.md`, which was written and committed as `7a339fac` **before** the corpus driver was written and before any count below was taken. That commit exists so the ordering is verifiable from git history rather than only asserted in prose.

> ### G7 — write-mode command with no observation marker
>
> The shipped severity of G7 is **the blocking channel if and only if both of the following hold**:
>
> 1. the total G7 finding count over the measured corpus is greater than zero, **and**
> 2. the recorded G7 false-positive count over that same measurement is zero.
>
> **Otherwise the shipped severity of G7 is the warning channel.**
>
> ### G8 — unanchored `git diff`
>
> The shipped severity of G8 is **the blocking channel if and only if both of the following hold**:
>
> 1. the total G8 finding count over the measured corpus is greater than zero, **and**
> 2. the recorded G8 false-positive count over that same measurement is zero.
>
> **Otherwise the shipped severity of G8 is the warning channel.**
>
> ### G8b — name-listing diff with no companion span
>
> **The shipped severity of G8b is the warning channel, unconditionally.**
>
> G8b is exempt from the two-condition rule above and cannot reach the blocking channel by any measured outcome. The reason is that it carries the highest false-positive surface of the set. [...] A measurement that happens to record no G8b false positive does not license promoting it, because a false-positive count taken over one corpus does not bound the false-positive surface of the predicate.
>
> ### G9 — coverage command with no terminal reporter
>
> The shipped severity of G9 is **the blocking channel if and only if both of the following hold**:
>
> 1. the total G9 finding count over the measured corpus is greater than zero, **and**
> 2. the recorded G9 false-positive count over that same measurement is zero.
>
> **Otherwise the shipped severity of G9 is the warning channel.**

The false-positive definition the rule consumes is likewise reproduced from that artifact and is applied strictly below:

> A finding is a false positive when the acceptance condition it reports is in fact falsifiable — that is, when the plan states an observation sufficient to distinguish a passing run from a failing one, by a mechanism the rule's predicate does not recognise. A finding is a true positive when the acceptance condition it reports genuinely cannot fail, or can only be satisfied vacuously.

## Predicate fidelity

Findings come from the shipped entry point `evaluate_plan_gates` with a real `PlanGateContext` built by the shipped `build_plan_gate_context`, so they are produced by the shipped predicates in the shipped order. Candidate enumeration calls the shipped helpers `_matching_entry`, `_git_diff_index`, `_diff_operands`, and `is_cov_flag_token` and the shipped flag tuples `_INDEX_FLAGS` and `_NAME_LISTING_FLAGS`. No rule is paraphrased in the driver. Check 4 below asserts the containment that makes the claim checkable.

## Corpus

Corpus root: `docs/features`. Naming convention: a Markdown file whose name begins `plan`, at any depth. The enumeration covers the `active`, `completed`, and `archive` trees.

**corpus_files = 194**

## Verbatim count output

```
corpus_files=194
rule  candidates  findings
G7           519       466
G8           237        82
G8b           47        19
G9           273         8
```

## The five integers per rule

| Rule | Corpus files | Candidates | Findings | True positives | False positives |
| --- | --- | --- | --- | --- | --- |
| **G7** | 194 | 519 | 466 | 444 | **22** |
| **G8** | 194 | 237 | 82 | 75 | **7** |
| **G8b** | 194 | 47 | 19 | 19 | **0** |
| **G9** | 194 | 273 | 8 | 4 | **4** |

Five integers per rule. True positives plus false positives equal the finding count in every row.

## Every false positive, named by plan path and offending span

### G7 — 22 false positives in two classes

**Class 1 — read-only argv shape (2 findings).** The `prettier-write` register entry matches the argv shape `npm run format` and declares no exclusion for a check flag, so a check-mode invocation is matched as if it wrote. The command does not write and exits non-zero on drift, so its acceptance condition is falsifiable by the exit code alone.

| Plan path | Task | Offending span |
| --- | --- | --- |
| `docs/features/completed/2026-06-27-fix-csharp-push-down-pack-name-256/plan.2026-06-27T14-16.md` | `[P0-T2]` | `npm run format -- --check` |
| `docs/features/completed/2026-07-02-epic-orchestrate-275/plan.2026-07-02T19-13.md` | `[P0-T9]` | `npm run format -- --check` |

**Class 2 — the task observes the tree rather than the tool's stdout (20 findings).** The attributed task text carries a `git status --porcelain` or `git status` span, so the plan can distinguish a clean run from a repairing one by comparing the tree before and after. G7's marker set recognises tool-output observation only, so it does not see this mechanism.

| Plan path | Task | Offending span |
| --- | --- | --- |
| `docs/features/active/2026-08-07-parallel-schema-validators-444/plan.2026-08-07T11-11.md` | `[P0-T6]` | `npm run format` |
| `docs/features/active/2026-08-07-parallel-schema-validators-444/plan.2026-08-07T11-11.md` | `[P7-T2]` | `poetry run ruff check .` |
| `docs/features/active/2026-08-07-parallel-schema-validators-444/plan.2026-08-07T11-11.md` | `[P7-T5]` | `npm run format` |
| `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/plan.2026-08-23T23-24.md` | `[P0-T7]` | `npm run format` |
| `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/plan.2026-08-23T23-24.md` | `[P6-T5]` | `npm run format` |
| `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md` | `[P3-T3]` | `poetry run ruff check` |
| `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md` | `[P4-T2]` | `poetry run ruff check` |
| `docs/features/completed/2026-07-09-subagent-tree-mcp-and-dropdown-334/plan.2026-07-09T10-30.md` | `[P8-T1]` | `npm run format` |
| `docs/features/completed/2026-07-17-legacy-discovery-mcp-vscode-370/plan.2026-07-17T15-08.md` | `[P0-T2]` | `cd extensions/drm-copilot && npm run format` |
| `docs/features/completed/2026-07-22-mcp-promotion-tooling-defects-401/plan.2026-07-22T09-56.md` | `[P5-T1]` | `npm run format` |
| `docs/features/completed/2026-07-22-mcp-promotion-tooling-defects-401/plan.2026-07-22T09-56.md` | `[P5-T5]` | `poetry run black scripts/dev_tools tests/scripts/dev_tools` |
| `docs/features/completed/2026-07-25-claude-rules-vitest-jest-divergence-422/plan.2026-07-25T21-44.md` | `[P6-T1]` | `poetry run black .` |
| `docs/features/completed/2026-07-25-jest-rootdir-testmatch-dot-directory-423/plan.2026-07-25T21-48.md` | `[P4-T1]` | `npm run format` |
| `docs/features/completed/2026-07-25-orchestration-state-contract-divergences-412/plan.2026-07-25T15-37.md` | `[P5-T5]` | `npm run format` |
| `docs/features/completed/2026-07-25-orchestration-state-contract-divergences-412/plan.2026-07-25T15-37.md` | `[P5-T5]` | `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` |
| `docs/features/completed/2026-08-15-blast-radius-module-map-forces-serial-runs-472/plan.2026-08-15T09-48.md` | `[P0-T4]` | `npm run format` |
| `docs/features/completed/2026-08-15-blast-radius-module-map-forces-serial-runs-472/plan.2026-08-15T09-48.md` | `[P0-T8]` | `poetry run black .` |
| `docs/features/completed/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/plan.2026-08-16T22-09.md` | `[P7-T5]` | `npm run format` |
| `docs/features/completed/2026-08-17-blast-radius-false-conflict-edges-489/plan.2026-08-17T20-44.md` | `[P8-T10]` | `npm run format` |
| `docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md` | `[P0-T10]` | `npm run format` |

The last row is the finding [P5-T5] examined independently in `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/regression-testing/corrected-forms-no-fire.2026-08-24T00-00.md` and classified there as a false positive in substance. It is carried into this measurement under the same classification, which is why that artifact says it is carried here.

### G8 — 7 false positives in two classes

**Class 1 — `--no-index` (6 findings).** `git diff --no-index` compares two named paths on disk. It does not compare the worktree against the index, so G8's stated claim — that the comparison "passes vacuously once the change is committed" — is false for this form. The acceptance condition is falsifiable.

| Plan path | Task | Offending span |
| --- | --- | --- |
| `docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/plan.2026-06-13T11-51.md` | `[P1-T5]` | `git diff --no-index` |
| `docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/plan.2026-06-13T11-51.md` | `[P7-T2]` | `git diff --no-index` |
| `docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/plan.2026-06-13T11-51.md` | `[P7-T4]` | `git diff --no-index` |
| `docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/plan.2026-06-13T11-51.md` | `[P7-T6]` | `git diff --no-index` |
| `docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/plan.2026-06-13T11-51.md` | `[P7-T8]` | `git diff --no-index` |
| `docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/plan.2026-06-13T11-51.md` | `[P11-T6]` | `git diff --no-index` |

**Class 2 — unmerged-path filter (1 finding).** `--diff-filter=U` selects conflicted paths during a merge or rebase. In that state the worktree-against-index comparison is the correct one and does not become vacuous on commit, because the conflict is precisely what is not yet committed.

| Plan path | Task | Offending span |
| --- | --- | --- |
| `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/plan.2026-08-07T11-11.md` | `[P2-T9]` | `git diff --name-only --diff-filter=U` |

### G8b — 0 false positives

Every one of the 19 G8b findings reports a name-listing diff whose attributed task text carries neither a staging span nor a porcelain-status span, and in every case the claim holds: the invocation enumerates tracked changes only, so a path the plan creates is invisible to it.

Three sub-classes were examined individually and each was retained as a true positive under the declared definition, because in none of them is the acceptance condition falsifiable:

- **Placeholder ref operand** — `git diff --name-only <merge-base(origin/main, HEAD)> HEAD` (`docs/features/active/2026-08-07-parallel-drift-detection-446/plan.2026-08-07T11-11.md`, `[P3-T1]`), `git diff <merge-base> --name-only` (`docs/features/active/2026-08-07-parallel-orchestrator-surface-441/plan.2026-08-07T11-11.md`, `[P5-T2]`), and `git diff --name-only <baseline-SHA from P0-T2>` (`docs/features/completed/2026-07-22-mcp-promotion-tooling-defects-401/plan.2026-07-22T09-56.md`, `[P5-T11]`). The placeholder resolves to a real ref at run time; it does not make the diff able to see an untracked path.
- **Artifact-field label inside the span** — `Command: git diff --name-only origin/main...HEAD` (`docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/plan.2026-08-23T23-23.md`, `[P6-T6]`). The span carries a field label, which is cosmetic; the underlying acceptance condition is the one the finding describes. The bare span in the same task window is reported separately, so this task contributes two findings for one command.
- **Pathspec written without the `--` separator** — `git diff --name-only tests/fixtures/` (`docs/features/completed/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/plan.2026-08-16T22-09.md`, `[P3-T13]`). The predicate reads `tests/fixtures/` as a ref operand and reports G8b, whereas at run time git resolves it as a pathspec and the diff is in fact unanchored. The G8b claim still holds, so it is a true positive for G8b. It is recorded here as a **G8 false negative**: the same span should also have been reported by G8, and was not.

### G9 — 4 false positives

| Plan path | Task | Offending span | Why the acceptance condition is falsifiable |
| --- | --- | --- | --- |
| `docs/features/completed/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md` | `[P2-T2]` | `--cov tests/foo` | The span is a test-data literal inside a sentence asserting a helper's return values, not a command. The acceptance asserts the helper returns a specific list. |
| `docs/features/completed/2026-07-25-codex-pretooluse-hook-transport-415/plan.2026-07-25T18-07.md` | `[P0-T6]` | `--cov --cov-branch` | The span is a flag pair quoted in prose to describe the suite the task declares out of scope. The acceptance asserts an artifact records the pass/fail state of two modules. |
| `docs/features/completed/2026-04-25-canonical-evidence-locations-non-overridable-158/plan.2026-04-25T14-37.md` | `[P5-T7]` | `poetry run pytest --cov` | A truncated restatement of the command on the task line, which is `poetry run pytest --cov --cov-report=term-missing` and does supply a terminal reporter. The coverage percentage the acceptance requires is printed. |
| `docs/features/completed/2026-07-03-two-axis-model-selection-286/plan.2026-07-03T16-19.md` | `[P2-T5]` | `poetry run pytest tests/scripts/dev_tools/test_compute_complexity_floor.py tests/scripts/dev_tools/test_resolve_delegation_model.py --cov --cov-branch` | The acceptance is "tests read signal catalog and table from the live matrix; all pass", which the pass count and exit code decide. No coverage number is asserted. |

The remaining four G9 findings are true positives: `docs/features/completed/2026-08-17-blast-radius-false-conflict-edges-489/plan.2026-08-17T20-44.md` `[P0-T8]` and `[P8-T4]`, whose acceptance requires "the numeric total line and branch coverage percentages"; `docs/features/completed/2026-07-02-epic-orchestrate-275/plan.2026-07-02T19-13.md` `[P6-T3]`, whose acceptance requires "`Output Summary:` with numeric line/branch coverage"; and `docs/features/completed/2026-06-24-push-down-language-packs-csharp-variant-226/plan.2026-06-24T13-04.md` `[P3-T1]`, whose acceptance requires "both paths covered". In each case the command supplies no terminal reporter, the project `addopts` supplies only an LCOV reporter, and the number the acceptance demands is therefore never printed.

## [P6-T4] — Vacuity declaration

**No rule recorded a finding count of zero.** The invalid-measurement declaration therefore does not apply to any rule in this measurement, and is recorded as not applying, per rule, with the count:

| Rule | Finding count | Vacuity declaration |
| --- | --- | --- |
| G7 | 466 | **Does not apply.** The count is greater than zero, so the measurement is not vacuous. |
| G8 | 82 | **Does not apply.** The count is greater than zero, so the measurement is not vacuous. |
| G8b | 19 | **Does not apply.** The count is greater than zero, so the measurement is not vacuous. |
| G9 | 8 | **Does not apply.** The count is greater than zero, so the measurement is not vacuous. |

This is the outcome the G5 precedent did not have: the G5 corpus measurement produced a total finding count of zero, which made its zero false-positive count measure nothing. Here every rule found findings, so each rule's false-positive count is a count over an examined population rather than over an empty one.

## [P6-T4] — The four driver-integrity checks

The four checks are required only for a rule whose finding count is zero, and no rule's is. They were run and recorded anyway, because a measurement that decides four shipped severity constants should be shown to be sound rather than assumed to be. Verbatim output:

```
### CHECK 1 - non-vacuous candidate enumeration
G7: candidates=519 -> NON-VACUOUS
G8: candidates=237 -> NON-VACUOUS
G8b: candidates=47 -> NON-VACUOUS
G9: candidates=273 -> NON-VACUOUS
### CHECK 2 - working repository seam
read_tracked_text('pyproject.toml') length=5856
contains addopts=True
is_tracked_file('scripts/dev_tools/plan_gate_observability.py')=True
is_tracked_directory('scripts/dev_tools')=True
### CHECK 3 - self-hit on every sampled lookup
docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/plan.2026-08-08T09-43.md: self_hit=True matches=1
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md: self_hit=True matches=1
docs/features/archive/2026-03-04-expose-pr-context-script-77/plan.2026-03-04T23-07.md: self_hit=True matches=1
docs/features/archive/2026-04-05-push-down-codex-agents-customizations-124/plan.2026-04-05T13-45.md: self_hit=True matches=1
docs/features/completed/2026-06-16-bump-and-publish-task-191/plan.2026-06-16T19-49.md: self_hit=True matches=1
docs/features/completed/2026-06-24-require-pr-author-agent-for-prs-231/plan.2026-06-24T15-17.md: self_hit=True matches=61
docs/features/completed/2026-07-03-pester-completion-consistency-301/plan.2026-07-03T22-46.md: self_hit=True matches=20
docs/features/completed/2026-07-17-legacy-discovery-acceptance-scenarios-364/plan.2026-07-17T14-37.md: self_hit=True matches=1
docs/features/completed/2026-07-22-mcp-promotion-tooling-defects-401/plan.2026-07-22T09-56.md: self_hit=True matches=1
docs/features/completed/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/plan.2026-08-17T15-00.md: self_hit=True matches=1
sampled=10 self_hits=10
### CHECK 4 - predicate-order equivalence with the shipped rule
G7: findings=466 candidates=509 findings_subset_of_candidates=True
G8: findings=82 candidates=229 findings_subset_of_candidates=True
G8b: findings=19 candidates=45 findings_subset_of_candidates=True
G9: findings=8 candidates=270 findings_subset_of_candidates=True
```

**Check 1 — non-vacuous candidate enumeration.** Every rule enumerated candidates in the hundreds or tens. No rule's finding count could be zero because nothing was examined.

**Check 2 — a working repository seam.** The injected seam returned 5856 characters of `pyproject.toml`, that text contains the literal `addopts`, and both the tracked-file and tracked-directory queries returned true against real paths. G9 is the only context-requiring rule of the four, and this is the exact query it makes; a seam returning nothing would make G9 report zero findings by design.

**Check 3 — a self-hit on every sampled lookup.** Ten corpus files were sampled at even intervals across the sorted enumeration. For each, a long literal line was drawn from the file's own text and passed to the seam's `files_containing`. **All ten lookups returned the sampled file itself: `sampled=10 self_hits=10`.** A lookup that could not find a literal in the file it was drawn from would mean the seam was answering about a different tree.

**Check 4 — predicate-order equivalence with the shipped rule.** For every rule, the set of `(plan path, task identifier, offending span)` triples drawn from the findings is a subset of the triples the driver enumerated as candidates: `findings_subset_of_candidates=True` for all four. No finding was produced that the driver's candidate enumeration did not also reach, so the driver reaches the same commands the shipped predicates decide, in the same order, and its candidate counts bound its finding counts.

The candidate figures in check 4 are lower than those in check 1 (509 against 519, 229 against 237, 45 against 47, 270 against 273) because check 4 deduplicates on the triple while check 1 counts occurrences. A plan that quotes the same span twice in one task window contributes two candidates and one triple. The difference is the duplicate-span population and is not a discrepancy.

## Applying the decision rule

| Rule | Finding count > 0? | False-positive count = 0? | Channel the rule assigns |
| --- | --- | --- | --- |
| G7 | Yes (466) | No (22) | **warning** |
| G8 | Yes (82) | No (7) | **warning** |
| G8b | n/a — exempt | n/a — exempt | **warning** (unconditional) |
| G9 | Yes (8) | No (4) | **warning** |

Every rule takes the warning channel. Three of them take it because the second conjunct fails: each has a non-zero recorded false-positive count. G8b takes it by the unconditional clause declared in advance.

This is a measured outcome, not a chosen one. Had any of G7, G8, or G9 recorded a false-positive count of zero it would have taken the blocking channel by the same rule, and this artifact would record that instead. [P6-T5] performs the assignment.

## Output Summary

All four driver invocations exited 0. Corpus: **194** plan documents under `docs/features`. Per-rule candidates and findings: G7 519/466, G8 237/82, G8b 47/19, G9 273/8. Per-rule true and false positives: G7 444/**22**, G8 75/**7**, G8b 19/**0**, G9 4/**4**. Every false positive is named above by plan path, task identifier, and offending span. No rule recorded a finding count of zero, so the vacuity declaration does not apply to any rule; the four driver-integrity checks were run regardless and all four pass, including a self-hit on 10 of 10 sampled lookups and `findings_subset_of_candidates=True` for all four rules. **Applying the pre-declared decision rule: G7, G8, and G9 take the warning channel because each has a non-zero false-positive count; G8b takes the warning channel unconditionally. All four rules ship in the warning channel.**
