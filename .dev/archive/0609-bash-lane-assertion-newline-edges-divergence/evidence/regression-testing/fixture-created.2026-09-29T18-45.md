# Fixture Created (P1-T3)

Timestamp: 2026-10-01T23:24:00-04:00
Command: poetry run pytest "tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py::test_reference_reproduces_every_corpus_fixture[edges_newline_separated]" ; git add tests/fixtures/parallel_lane_assertion/edges_newline_separated.json ; git status --porcelain -- tests/fixtures/parallel_lane_assertion/edges_newline_separated.json
EXIT_CODE: 0
Output Summary: pytest reported `1 passed in 0.08s` (collected 1 item); porcelain printed `A  tests/fixtures/parallel_lane_assertion/edges_newline_separated.json` (staged, newly added).

The `expected_stdout` field was taken from the P1-T2 recorded stdout of the Python authority (trailing newline removed, line breaks as `\n` escapes). The `1 passed` node result proves the stored value equals the authority output for the same manifest and edges. The `manifest_text` was copied from `edges_endpoint_interior_whitespace.json`; `test_manifest_text_matches_manifest_path` also passes (see python-parity-control artifact).
