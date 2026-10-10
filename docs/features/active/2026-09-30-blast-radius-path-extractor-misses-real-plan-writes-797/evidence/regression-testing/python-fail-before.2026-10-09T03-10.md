# Python Fail-Before (P1-T8, expect-fail)

Timestamp: 2026-10-09T03-10
Command: poetry run pytest "tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_a_file_shaped_token_797" "tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_the_dotted_directory_residual_797" "tests/scripts/dev_tools/test_blast_radius_extraction.py::test_classify_path_token_accepts_recognized_extension_outside_known_segments[alpha/beta.unknownext]" "tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_radius[derivation-file-shaped-tokens]" -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: final line `10 failed in 0.24s` with no `passed` term. The ten failures are the seven FL-1 classifier cases (each observed None), the dotted-directory residual (observed None), the alpha/beta.unknownext contract-change case (observed None), and the derivation-file-shaped-tokens fixture radius (derived only the feature-folder glob and scripts/dev_tools/compute_blast_radius.py; modules lacked `tests`). The code under test is the unmodified classifier.

## Failing node IDs

```text
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_a_file_shaped_token_797[bats]
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_a_file_shaped_token_797[cjs]
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_a_file_shaped_token_797[out]
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_a_file_shaped_token_797[agents-bats]
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_a_file_shaped_token_797[shellcheckrc]
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_a_file_shaped_token_797[dockerfile]
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_a_file_shaped_token_797[bats-line-suffix]
FAILED tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_the_dotted_directory_residual_797
FAILED tests/scripts/dev_tools/test_blast_radius_extraction.py::test_classify_path_token_accepts_recognized_extension_outside_known_segments[alpha/beta.unknownext]
FAILED tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_radius[derivation-file-shaped-tokens]
10 failed in 0.24s
```
