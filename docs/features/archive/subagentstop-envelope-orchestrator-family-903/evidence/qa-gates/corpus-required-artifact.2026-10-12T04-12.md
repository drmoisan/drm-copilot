# Required-Artifact Corpus Re-run ([P6-T16])

Timestamp: 2026-10-12T04-12
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/corpus-gate.ps1 -Validator required-artifact -CorpusRef 2ef8d361e978ca8b7733a545d76a87e8418005ce -OracleScript <SCRATCHPAD>/corpus-oracle.py -WorkDirectory <SCRATCHPAD>/corpus-required-artifact
EXIT_CODE: 0
Output Summary: ENTRY_BINDING=InputText, four SPEC agent= lines (prd-feature 49, epic-review 0, staged-review 0, status-updater 0), CORPUS_TOTAL=49, EXPECTED_PASS=49, FALSE_POSITIVES=0, FALSE_NEGATIVES=0, EXCEPTIONS=0, CORPUS_VACUOUS=False. CORPUS_REF_SHA, MEMBER_LIST_SHA256, and CORPUS_TOTAL equal the [P2-T15] values (evidence/qa-gates/corpus-required-artifact.2026-10-12T01-48.md). No rule change was required.

A13 summary output:
CORPUS_VALIDATOR=required-artifact
CORPUS_REF_SHA=2ef8d361e978ca8b7733a545d76a87e8418005ce
SPEC agent=prd-feature Members=49
SPEC agent=epic-review Members=0
SPEC agent=staged-review Members=0
SPEC agent=status-updater Members=0
ENTRY_BINDING=InputText
MEMBER_LIST_SHA256=CDC3549378F8CB5083312921EAB8BFAE2022D6D20EDB04C56EBBB29F347D4826
CORPUS_TOTAL=49
EXPECTED_PASS=49
EXPECTED_BLOCK=0
UNCLASSIFIED=0
FALSE_POSITIVES=0
FALSE_NEGATIVES=0
EXCEPTIONS=0
CORPUS_VACUOUS=False
