# G5 Corpus Measurement and Severity Determination

Timestamp: 2026-08-20T12-02
Tasks: [P5-T1], [P5-T2], [P5-T3], [P5-T5]
Issue: #486
Spec acceptance criterion: AC7
Working directory: worktree root `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a61259d5432e08b89`

## Measurement run

Command: `poetry run python "C:/Users/DANMOI~1/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot/73acdafc-7722-4904-b9f6-50feaae9cb08/scratchpad/measure_g5_corpus_486.py"`

EXIT_CODE: 0

Output Summary (verbatim driver stdout):

```
PLAN_FILES_SCANNED: 166
CANDIDATE_LITERALS_EVALUATED: 100
Candidate literals for which the tree-absence condition held: 0
G5_FINDING_TOTAL: 0
PLAN_PATH | TASK_ID | LITERAL
SAMPLE_TREE_LOOKUPS:
  'def _cache_path' -> 2 tracked files; self-hit=True
  'def _load_schema' -> 3 tracked files; self-hit=True
  'shell-qc' -> 141 tracked files; self-hit=True
  'grep' -> 811 tracked files; self-hit=True
  'gh pr create' -> 194 tracked files; self-hit=True
```

## Recorded counts

- Number of plan files scanned: **166** (every file matching `docs/features/**/plan*.md`).
- Number of candidate literals evaluated: **100** (commands whose `kind` is `grep` and whose pattern operand is a checkable literal).
- `Candidate literals for which the tree-absence condition held: 0`
- Total G5 finding count: **0**
- True-positive count: **0**
- False-positive count: **0**
- False positives enumerated, one line each naming plan path and literal: **none** (the finding list is empty).

## MEASUREMENT INVALID

`MEASUREMENT INVALID: zero G5 findings produced; a zero false-positive count measures nothing`

The total G5 finding count is `0`, so the zero false-positive count carries no information and does not license the Blocking severity. Per plan task [P5-T3], `G5_SEVERITY` is therefore set to `"warning"` and the driver was re-examined for a defect before Phase 5 was checked off.

## Driver re-examination

The re-examination identified **no driver defect**. Checks performed:

1. **Enumeration is non-vacuous.** The driver scanned 166 plan files and evaluated 100 candidate literals. A driver that failed to enumerate or failed to classify would have reported zero candidates; it reported 100.
2. **The repository seam works.** The `SAMPLE_TREE_LOOKUPS` block shows the first five candidate literals encountered, each of which `git grep -F -l` matched in 2 to 811 tracked files. A broken adapter would report zero matches for every literal, which is the opposite of what was observed.
3. **Every sampled lookup was a self-hit.** For each sampled literal, the plan file that quotes it is itself among the tracked files matched (`self-hit=True`). This is the direct mechanism behind the zero result.
4. **G5 predicate order is correct.** The driver applies the tree-absence check, then the plan-quotation check, then the cross-line check, in the same order as `_evaluate_literal` in `scripts/dev_tools/plan_gate_discrimination.py`, so the corpus was evaluated against the shipped predicate rather than a paraphrase of it.

## Structural reason for the zero count

`no G5 instances present in the corpus`

Every committed plan is a tracked file. A `git grep -F -l` for a literal that is quoted inside a committed plan therefore always finds at least that plan itself, so the tree-absence condition holds for no committed candidate. The zero total is a property of the corpus, not a driver defect. Preflight predicted exactly this outcome: a total G5 finding count of `0` together with a non-zero candidate-literals count, which together show that the driver enumerated and evaluated candidates rather than failing. Both predicted signals are present (100 candidates evaluated, 0 findings).

This also means the corpus cannot, in principle, produce a G5 true positive while the plan under measurement is itself committed. The rule remains meaningful for its intended use: the validator runs against a single plan artifact at authoring time, when that plan is typically uncommitted and therefore untracked, so its own text does not satisfy the tracked-tree presence test. The plan-quotation condition (`_plan_quotes_literal`) is what exonerates a literal the plan tells the executor to create.

## Severity determination

Rule (pre-declared by the spec and by plan task [P5-T3]): `G5_SEVERITY` is `"blocking"` if and only if the total G5 finding count is greater than `0` **and** the recorded false-positive count is `0`; otherwise `"warning"`.

- Total G5 finding count: `0` — the first conjunct fails.
- Resulting value: **`G5_SEVERITY = "warning"`**

The value is set in `scripts/dev_tools/plan_gate_discrimination.py` with a source comment naming this artifact.

## [P5-T5] Throwaway driver deletion

Scratchpad driver absolute path:
`C:\Users\DANMOI~1\AppData\Local\Temp\claude\C--Users-DanMoisan-repos-drm-copilot\73acdafc-7722-4904-b9f6-50feaae9cb08\scratchpad\measure_g5_corpus_486.py`

Post-deletion check result: `not found`

Repository check command: `git status --porcelain --untracked-files=all -- scripts tests extensions`

Repository check result: no listed file's name contains `measure` or `g5_corpus`. The pathspec restricts the assertion to the source tree because this evidence artifact is itself an untracked file whose basename contains `measure`, and an unscoped listing would reject the artifact Phase 5 is required to produce.
