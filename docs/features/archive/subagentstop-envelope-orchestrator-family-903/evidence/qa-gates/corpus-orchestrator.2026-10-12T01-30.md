# Orchestrator Corpus Gate ([P2-T12])

Timestamp: 2026-10-12T01-30
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/corpus-gate.ps1 -Validator orchestrator -CorpusRef 2ef8d361e978ca8b7733a545d76a87e8418005ce -OracleScript <SCRATCHPAD>/corpus-oracle.py -WorkDirectory <SCRATCHPAD>/corpus-orchestrator
EXIT_CODE: 0
Output Summary: ENTRY_BINDING=RawPayload, ORACLE_EXIT_CODE=0, CORPUS_TOTAL=7, EXPECTED_PASS=3, EXPECTED_BLOCK=4, UNCLASSIFIED=0, FALSE_POSITIVES=0, FALSE_NEGATIVES=2 (informational), EXCEPTIONS=1, CORPUS_VACUOUS=False. The single EXCEPTION is on the expected-block member evidence/other/invalid-checkpoint.json (an intentionally invalid fixture) and counts as a block, not a false positive. No rule change was required.

Full A13 output:
CORPUS_VALIDATOR=orchestrator
CORPUS_REF_SHA=2ef8d361e978ca8b7733a545d76a87e8418005ce
ORACLE_EXIT_CODE=0
ENTRY_BINDING=RawPayload
EXCEPTION path=docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/evidence/other/invalid-checkpoint.json message=The property 'Name' cannot be found on this object. Verify that the property exists.
FALSE-NEGATIVE path=docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/other/orchestrator-state.blocked.2026-10-08T22-50.json
FALSE-NEGATIVE path=docs/features/completed/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-one-unmerged.json
MEMBER_LIST_SHA256=646BFDEEAA177D24E05AC4F612E30B19B8C18CFC0B5A08CEB53662F26389C1C8
CORPUS_TOTAL=7
EXPECTED_PASS=3
EXPECTED_BLOCK=4
UNCLASSIFIED=0
FALSE_POSITIVES=0
FALSE_NEGATIVES=2
EXCEPTIONS=1
CORPUS_VACUOUS=False
