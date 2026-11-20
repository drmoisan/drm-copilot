# #797 CR-1 Python Fail-Before (P4-T6) [expect-fail]

Timestamp: 2026-10-13T11-23
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_token_shapes.py -v
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 1 failed, 34 passed in 0.12s, run after adding the two rows (P4-T5) and before the production fix (P4-T7). `[kelvin-sign-extension]` FAILED and `[dotted-capital-i-extension]` PASSED, which matches the research expectation. No deviation.

## Observed node outcomes

| Node | Observed |
|---|---|
| test_is_file_shaped_component_classifies_a_component[kelvin-sign-extension] | FAILED |
| test_is_file_shaped_component_classifies_a_component[dotted-capital-i-extension] | PASSED |

Failure text:

```
E       AssertionError: Expected 'notes.K' to report False; observed True.
E       assert True is False
```

The Kelvin sign (U+212A) lower-cases to ASCII `k`, so `FILE_EXTENSION_RE.fullmatch(extension.lower())` matched before the fix. The dotted capital I (U+0130) lower-cases to `i` followed by U+0307 (combining dot above), which the ASCII pattern does not match, so that row already reported `False`.

Summary line: `======================== 1 failed, 34 passed in 0.12s =========================`
