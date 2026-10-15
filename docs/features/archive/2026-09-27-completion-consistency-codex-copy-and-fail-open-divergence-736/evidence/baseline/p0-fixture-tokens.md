# Fixture tokens ([P0-T5])

Timestamp: 2026-10-08T17-31
Command: grep -c -F "S8_create_pr" <not-ready fixture> ; grep -c -F "not_started" <not-ready fixture> ; grep -c -F "ci_gate" <not-ready fixture> ; grep -c -F "this is not valid json" <invalid-json fixture> ; wc -c <empty fixture>
EXIT_CODE: 0
Output Summary: printed values 1, 2, 0, 1, 0 in order, matching the acceptance values (ci_gate count 0 is the gate value; grep exits 1 on that count).

S8_create_pr=1
not_started=2
ci_gate=0
invalid_json_token=1
empty_fixture_bytes=0
