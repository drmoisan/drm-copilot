# P5-T1 consolidated candidate review

Timestamp: 2026-10-20T04-12 UTC
Command: `.venv/Scripts/python.exe SCRATCH/issue-980-p5t1-candidate-reconcile.py`
EXIT_CODE: 0
Output Summary: CANDIDATE_REVIEW_PASS_READY_FOR_CHECKED_WIP_AND_FINAL_GATES.

The eight frozen producer, validator and test files match the retained manifests.
PR1–PR4 are closed. No new finding or open probe remains. The original review and
accepted helper/legacy proof are reused; no accepted predecessor suite was rerun.

Five retained repair reproductions pass. Missing ledger authority gives null
selection metrics and retains known inventory references. A real empty ledger
retains both selected missing components. The 1,024-root workload rejects before
any predicate call or partial selection; the 16/128-root controls remain bounded.

The graph ordered loop passed 49 cases with 224/226 statements, 72/76 branches and
17 measured ranges at or above 90% statement coverage. The validator's ordered
targeted loop passed 13 cases. Its 141/150 statement and 44/52 branch result is
narrow diagnostic evidence; final full caller coverage remains pending.

Runtime required/observed/verified/missing counts use explicit component units and
accepted source evidence. Scenario counts and authored statuses remain separate.
Coverage diagnostics preserve requested-mode results and nonrecursive report
recomputation. Common complete-source assessments are cached only within one
immutable validation operation; mode-specific parity/completion checks remain.

The original graph fixture failures, changing-dependency qualification, and
validator 135-pass/1-fixture-failure receipt remain preserved. A local checker
initially read an object binding as a bare SHA; its exact diagnostic and corrected
reader are archived. No behavioral restart was needed for that evidence-only fix.
Current working bytes and expected Git LF bytes are recorded separately.

Review details: `p5t1-executor-consolidated-candidate-review.2026-10-20T04-12.json`.
Exact executable/output payload: `p5t1-executor-candidate-review-payload.2026-10-20T04-12.json`.

This is a checked-candidate milestone. P5-T1 stays unchecked; the final ordered
sequence, reversed graph/helper/caller populations, contracts and native proof
remain pending. Plan status stays 41/84; acceptance criteria stay 17/66.
Next tasks: P5-T1 coverage, P5-T2 parity, P5-T3 completion, P5-T4 acceptance records,
and P5-T5 Markdown/Gherkin rendering.
