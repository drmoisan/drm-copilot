Timestamp: 2026-10-20T18-12
Command: `SCRATCH/issue-980-p6t1-gateway-nio1-freeze.py`
EXIT_CODE: 0
Output Summary: NIO1 scoped repair passes ordered static gates and 89 distinct in-memory controls; source and tests are frozen.

The public `workspace_identity(path: str) -> PurePath` wrapper reuses the unchanged
strict absolute parser. One local predicate handles the request, optional captured
root and writer root. Windows drive/UNC identity accepts equivalent slash/case
spellings; POSIX remains case-sensitive and rejects backslash aliases.

Scope: path_policy.py (497 lines), gateway_local.py (403), and
test_gateway_boundaries.py (425). No other source or test changed.

Black, Ruff and Pyright pass in loop2. The 57 new controls pass, followed by 32
existing authority, reader and path controls. The original 98-case gateway proof
remains historical. The loop1 test-only attribute diagnostic and the initial
evidence-helper zero-body diagnostic remain retained; no failed behavioral run
was discarded.

Fresh executable-body coverage is 4/4 for workspace_identity, 4/4 for
_matches_workspace, 13/14 for authorize, and 3/3 for writer. The changed bodies
lose no measured coverage. Declarations and docstrings are excluded.

The proof records current 89-case coverage separately from qualified historical
coverage of exact unchanged bodies. That composition covers path_policy 161/161
lines and 86/86 branches; gateway_local 130/131 lines and 37/38 branches. It is
not a new full-file or repository-wide execution result.

The exact source archives, original-to-current AST/range maps, source diff,
coverage bytes and 57 new plus 32 retained IDs are in
`evidence/qa-gates/p6t1-gateway-nio1-proof.2026-10-20T18-10.json`.

The independent source confirmation is `p6t1-executor-root-identity-source-confirmation.2026-10-20T18-09.json`. Final result
reconciliation remains with the coordinator's reviewer. No service/native retry,
package regeneration, final combined isolation, Git or checkpoint mutation ran
in this repair. The generated manifest is outside these proof inputs; its
coordinator-owned rebuild window is released against the frozen source.
