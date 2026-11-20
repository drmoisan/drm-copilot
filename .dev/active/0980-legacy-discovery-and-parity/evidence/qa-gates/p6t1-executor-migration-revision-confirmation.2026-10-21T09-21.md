# P6-T1 migration revision confirmation

Issue: 980. Status: **READY_FOR_BOUNDED_REPAIR**.

The two-input fixture now reaches a production composition mismatch. Initialization gives the empty scope and ledger the same observed current repository revision. The coverage-ledger conversion then forces only the ledger revision to null, so the unchanged identity validator correctly rejects the graph.

Remove only `revision=None` from the coverage-ledger update in `migration_conversion.py`. Keep components and inventory references empty. This retains current trusted target ownership; it does not supply missing legacy provenance. The original v1 document, path and hash, draft disposition and open reconciliation records remain unchanged, as required by spec.md:461.

Minimum controls are the two existing service migration variants and the coverage-ledger cases for original metadata retention, null-pin draft behavior and strict trusted-pin mismatch refusal. Exact selectors and frozen bindings are in the paired JSON. No broader matrix is required.

No implementation, tests, runtime invocation or Git mutation occurred. The retained result remains zero passes and two COVERAGE_IDENTITY failures. Full focused proof, package identity and P6-T1 acceptance remain pending.

Current phase: P6-T1. Next five: P6-T1, P6-T2, P6-T3, P7-T1, P7-T2.
