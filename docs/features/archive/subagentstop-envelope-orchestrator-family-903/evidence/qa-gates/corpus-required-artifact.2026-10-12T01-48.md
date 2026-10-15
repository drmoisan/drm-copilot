# Required-Artifact Corpus Gate ([P2-T15])

Timestamp: 2026-10-12T01-48
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/corpus-gate.ps1 -Validator required-artifact -CorpusRef 2ef8d361e978ca8b7733a545d76a87e8418005ce -OracleScript <SCRATCHPAD>/corpus-oracle.py -WorkDirectory <SCRATCHPAD>/corpus-required-artifact
EXIT_CODE: 0
Output Summary: ENTRY_BINDING=RawPayload, four SPEC agent= lines (prd-feature 49, epic-review 0, staged-review 0, status-updater 0), CORPUS_TOTAL=49, EXPECTED_PASS=49, FALSE_POSITIVES=0, FALSE_NEGATIVES=0, EXCEPTIONS=0, CORPUS_VACUOUS=False, MEMBER_LIST_SHA256=CDC3549378F8CB5083312921EAB8BFAE2022D6D20EDB04C56EBBB29F347D4826. No rule change was required. The epic-review, staged-review, and status-updater specs match no tracked path at the pinned commit, so only the prd-feature spec contributes members.

Full A13 output:
CORPUS_VALIDATOR=required-artifact
CORPUS_REF_SHA=2ef8d361e978ca8b7733a545d76a87e8418005ce
SPEC agent=prd-feature Members=49
SPEC agent=epic-review Members=0
SPEC agent=staged-review Members=0
SPEC agent=status-updater Members=0
ENTRY_BINDING=RawPayload
MEMBER_LIST_SHA256=CDC3549378F8CB5083312921EAB8BFAE2022D6D20EDB04C56EBBB29F347D4826
CORPUS_TOTAL=49
EXPECTED_PASS=49
EXPECTED_BLOCK=0
UNCLASSIFIED=0
FALSE_POSITIVES=0
FALSE_NEGATIVES=0
EXCEPTIONS=0
CORPUS_VACUOUS=False
