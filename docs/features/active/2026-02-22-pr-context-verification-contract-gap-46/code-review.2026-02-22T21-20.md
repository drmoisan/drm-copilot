# Code Review — pr-context-verification-contract-gap-46

- **Date:** 2026-02-22
- **Base branch:** development
- **Feature folder selection rule:** user-provided folder path was used directly: `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46`.

## Executive Summary

This change closes a contract gap in PR-context generation by making canonical evidence files discoverable, parseable, and reportable in summary output, while preserving anti-hallucination constraints in PR authoring guidance.

Top 3 risks:
1. **Evidence schema drift risk**: malformed evidence records can reduce verification signal quality.
2. **Prompt/collector drift risk**: prompt wording rules and collector output contract could diverge in future edits.
3. **Scope-diff ambiguity risk**: branch-level baseline contains unrelated historical commits, so reviewers should prioritize this feature’s scoped files.

**PR readiness recommendation:** **Go** (ready), with one minor maintenance follow-up noted below.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/dev_tools/pr_context/collector.py` | verification-evidence render path | Collector reads evidence files and skips unreadable files silently. | Consider optional debug-level aggregation of skipped files in future hardening pass. | Improves diagnosability without changing current tolerant behavior. | `_render_verification_evidence_section(...)` + passing fallback tests in `test_collect_pr_context_part4.py`. |
| Nit | `.github/prompts/generate-pr.prompt.md` | Verification rules | Prompt contains strong constraints and new evidence-backed gate. | Keep integration test aligned when prompt text evolves. | Prevents prompt text regressions from silently weakening contract guarantees. | `test_prompt_contract_allows_evidence_backed_verification_only_when_enumerated`. |

No blocker or major findings were identified.

## Typed Python Audit

- **Type strength:** ✅ New module `verification_evidence.py` is strongly typed (`dataclass`, `Literal`, typed returns).
- **Any usage:** ✅ No new `Any` introduced.
- **Type-check posture:** ✅ No type-check weakening; `pyright` clean.
- **Protocols/structured models:** ✅ `VerificationEvidenceRecord` provides a clear typed data contract.
- **Exception handling:** ✅ Explicit handling for parse failures (`ValueError`) and file reads (`OSError` boundary in collector).
- **Public API clarity:** ✅ New helpers are cohesive and documented; behavior is deterministic and test-covered.

## Test Quality Audit

- **Deterministic/isolated:** ✅ Tests use monkeypatched stubs for Git/GH and local evidence files only.
- **Focused behavior coverage:** ✅ Added tests map directly to acceptance criteria:
  - evidence path enumeration
  - verification section rendering
  - unparseable fallback behavior
  - heading fallback parity (`Verification` before `Test Plan`)
  - prompt contract wording gate
- **Execution quality:** ✅ Full suite run passed (`776 passed`).
- **Coverage signal:** ✅ New module observed at 94% line coverage; total repo coverage remains 81%.

## Security and Correctness Checks

- **Secrets exposure:** ✅ None observed in changed files.
- **Unsafe subprocess usage:** ✅ None introduced in reviewed scope.
- **Input boundary validation:** ✅ Evidence parser enforces required fields and integer coercion for `EXIT_CODE`; malformed input yields `unparseable` status.
- **Claim safety:** ✅ Prompt still prohibits citing non-enumerated files.

## Verification Commands Run (This Review)

- `poetry run black --check .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

All commands succeeded.
