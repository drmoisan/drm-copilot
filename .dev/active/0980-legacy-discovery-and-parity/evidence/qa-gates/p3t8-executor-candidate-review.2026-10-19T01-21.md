# P3-T8 consolidated candidate review

Timestamp: 2026-10-19T01-19 UTC, captured when the bounded review command began.
Write timestamp: 2026-10-19T01-21 UTC.
Command: `poetry run python SCRATCH/issue-980-p3t8-candidate-review.py`
EXIT_CODE: 1
Output Summary: REVISIONS REQUIRED. One semantic defect has two confirmed variants: selected snapshot integrity reads bypass profile exclusions. Two isolated in-memory cases returned one allowed row while each reading an explicitly excluded input twice. No broad suite or accepted predecessor implementation was replayed. The candidate remains unaccepted.

Raw proof and four source hashes: [p3t8-executor-candidate-review.2026-10-19T01-21.json](p3t8-executor-candidate-review.2026-10-19T01-21.json), SHA-256 `68f91febbbf604a8c60edbde8804fd266734f701c9f4ec6a6a994974e4278429`. Candidate authority: [worker freeze](p3t8-candidate-freeze.2026-10-19T01-16.json). Accepted predecessor identity: [activation](../baseline/p3t8-executor-activation.2026-10-19T00-54.md).

The accepted baseline is `e04136458147cdf24069b6bde563231f3c38c709`. Native `atomic_execution_p3t8` authority matches the C4 Astra/max profile and its recorded SHA-256. This review owns only independent evidence; no source/test/checkpoint/Git change was made. The four frozen candidate sizes are 423, 479, 496 and 496 lines. All 79 class/function definitions have docstrings and every explicit loop has an immediately preceding intent comment.

## Consolidated required repair

- **P3T8-R1 — profile exclusions must apply to snapshot integrity inputs.** `source_reads.py` uses `_profile_allows` at the manifest check (line 237) and each integrity member preflight (line 255), while the exclusion predicate is confined to `_eligible`. The original candidate therefore reads an excluded selected manifest at line 239, or an excluded declared sibling at line 261, and returns the requested allowed member. Both variants are recorded in the raw proof. Factor a shared configured-root/exclusion predicate and apply it to the manifest and all member preflights. Keep output-grant authorization separate: an explicitly selected manifest may authorize integrity reads of nonreturned siblings, but cannot override the profile exclusion. Reject an excluded header before its bytes and an excluded member before payload capture. Add focused negative assertions for both variants and no excluded byte reads.
- **P3T8-R2 — complete the two nested fake-reader contracts.** `test_source_reads.py::unstable` and `test_source_read_limits.py::adding` have purpose docstrings but omit their `path:str` and `limit:int` meaning, bytes return and intentional fault/state-change contract. Add those details in the same repair. `ReadSelection` should describe host read grants, replacing the misleading phrase “host output grants.”

These findings were delivered together to the worker and parent before final gates. No other blocking semantic or API finding was identified. Bounded repair confirmation will compare only the changed code/tests and retained hashes; this is not a request for a second broad review.

## Reviewed contract retained for final acceptance

The reader requires a configured profile and typed host-provided selection independent of request paths. The operation set is list/read/literal-search; regex, multiline query interpretation and executable operations are unavailable. Exact project/file grants do not authorize siblings or directory expansion. Profile/output-root breadth does not independently grant reads. Selected snapshot regions take precedence over broad documentation roots, and target membership is verified through the accepted transport before requested bytes are captured or provenance is released.

The new modules have no shell/process/network/mutation surface. They use the accepted bounded, non-following workspace byte seam and metadata policy. Request state is separate per inspection. Input, file, metadata/queue/depth, line, match, query and serialized-output budgets have independent finite ceilings. Results are deterministic, complete-row pages with content/profile/selection/request/limit-bound continuations; freshness re-reads count toward input limits. Working bytes retain no unproved configured revision; validated imported members preserve their original repository/path/pin and manifest hash, while envelope metadata remains local. Source hashes cover original bytes; UTF-8 spans use one-based lines and end-exclusive Unicode columns.

The unit tests use fresh in-memory stores and immutable shared configuration/catalog values, with committed resource reads only. Their reported candidate result is 125 passing cases, 409/409 statements, 176/176 branches and all 43 measured class/callable ranges at 100%. These candidate metrics are retained history, not substitutes for the clean final ordered gates after the required repair. Native operational composition, exact reverse order, final full-repository type check and final gate reconciliation remain worker/acceptance obligations.

P3-T8 remains unchecked. The plan remains 31/84 and authoritative acceptance criteria remain 11/66. Service/host exposure and trusted invocation-to-read-selection integration remain later planned tasks.
