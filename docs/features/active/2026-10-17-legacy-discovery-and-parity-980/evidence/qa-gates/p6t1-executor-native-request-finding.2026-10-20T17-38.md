# P6-T1 native request diagnosis

Status: **HARNESS_CORRECTION_REQUIRED**. One finding: NR1.

The retained common `request()` constructor sets `format='both'` for every operation. Frozen request rules require `format='json'` for non-report operations. The exact 748-byte `init-dry` request passes JSON/schema validation but fails that operation/format rule and produces the retained `SERVICE_REQUEST` finding at `/`. A diagnostic copy changing only `format` to `json` parses successfully.

The remaining constructor inventory has no additional request-shape issue: 12 valid non-report object shapes need JSON, three completion-report shapes remain `both`, the unknown operation remains rejected, and the separate malformed JSON control remains rejected. These are pure parsing results, not authority or downstream operation proof.

The minimal repair is limited to the existing harness: default a representation parameter to `json`, use it in the format field, and pass `both` explicitly for `report-dry`, `report-publish` and `report-repeat`. Preserve all other request data and assertions. No production/schema change or package rebuild is required by this finding.

The original native failure is an actual invalid-request rejection, not a reader error. Installed identity passed in 1.314 seconds; init-dry returned exit 2 in 1.515 seconds; the remaining 16 child invocations did not run. Original requests, outputs and hashes remain unchanged. This diagnosis made no service call, native replay or fixture write.

Receipt: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-executor-native-request-finding.2026-10-20T17-38.json`; SHA-256 `bf4afb5502ae86e8cff4a623237b1c6d19925b75286d633bba2033787920eef5`. Exact pure diagnostic script/result are retained losslessly in that receipt.

P6-T1 remains unaccepted; the final 207-case plus four-contract run remains disabled. Counts remain 46/84 tasks and 23/66 source ACs. Next five: P6-T1, P6-T2, P6-T3, P7-T1, P7-T2.
