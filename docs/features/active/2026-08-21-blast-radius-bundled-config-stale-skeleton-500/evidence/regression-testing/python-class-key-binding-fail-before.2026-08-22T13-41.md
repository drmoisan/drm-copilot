Timestamp: 2026-08-22T13-41
Command: temporarily edit tests/scripts/dev_tools/blast_radius_parity_test_support.py so CLASS_THREE_KEYS = () (removing "modules"), leaving config/blast-radius.json and the bundled copy untouched; then poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_three_bundled_modules_are_payload_modules_only tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_top_level_key_is_classified_and_shared_by_both_copies
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 2 failed. test_class_three_bundled_modules_are_payload_modules_only fails with
"AssertionError: assert 'modules' in ()" (the class-3 membership assertion added in P3-T2).
test_every_top_level_key_is_classified_and_shared_by_both_copies fails with "Every top-level key
in either committed copy must be classified by DECLARED_TOP_LEVEL_KEYS; unclassified keys
['modules']" (DECLARED_TOP_LEVEL_KEYS no longer includes 'modules' once CLASS_THREE_KEYS is
emptied). Both cases pass on the unperturbed file per P3-T2, so this is a genuine before/after
distinction on the support module's own source, not on the committed configuration data.

Note on restore mechanism: this file (tests/scripts/dev_tools/blast_radius_parity_test_support.py)
already carries the legitimate, uncommitted P3-T1 edit (CLASS_TWO_KEYS/CLASS_THREE_KEYS/
DECLARED_TOP_LEVEL_KEYS) at the time this perturbation is applied. A literal
`git checkout -- tests/scripts/dev_tools/blast_radius_parity_test_support.py` would revert the
file all the way to HEAD (the cycle-3 opening commit), discarding the P3-T1 fix along with the
P3-T4 perturbation, since committing mid-cycle is out of scope for this executor ("committing is
mine" per the delegation). P3-T5 therefore restores from an in-memory backup of the file's
post-P3-T1 content captured immediately before this perturbation, verified byte-identical by diff,
rather than via `git checkout --`. `git status --short` for this path continues to show the file
as modified relative to HEAD both before and after this perturb/restore cycle, which is expected
and correct: it reflects the legitimate P3-T1 change, not an incomplete restoration.
