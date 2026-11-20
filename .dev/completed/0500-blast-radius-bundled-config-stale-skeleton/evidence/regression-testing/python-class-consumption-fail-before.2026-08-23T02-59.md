Timestamp: 2026-08-23T02-59 (UTC)
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 1 failed. AssertionError: "Every Class 2 and Class 3 registry key must be consumed by its registered assertion; unresolved pairs (('invented_key', 'test_class_two_bundled_shared_surfaces_are_the_portable_set'),)." This is the demonstration perturbation: "invented_key" was added to config/blast-radius.json, its bundled mirror, and CLASS_TWO_KEY_ASSERTIONS (mapped to the unrelated, pre-existing test_class_two_bundled_shared_surfaces_are_the_portable_set), with no assertion genuinely referencing "invented_key". A full-module run (poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py) confirms the failure is isolated: 1 failed, 16 passed -- neither the exhaustiveness case nor any of the three pre-existing membership asserts fires, because invented_key is present in both copies and in the derived CLASS_TWO_KEYS / DECLARED_TOP_LEVEL_KEYS.

git diff --stat confirming all four files changed:
 config/blast-radius.json                           |  1 +
 .../claude-customizations/config/blast-radius.json |  1 +
 .../BlastRadius.KeyPartition.Tests.ps1             | 57 ++++++++++++++--
 .../dev_tools/blast_radius_parity_test_support.py  | 77 +++++++++++++++++++---
 4 files changed, 123 insertions(+), 13 deletions(-)
