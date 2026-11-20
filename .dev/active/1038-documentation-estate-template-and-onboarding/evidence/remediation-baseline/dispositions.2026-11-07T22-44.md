# Re-derived dispositions of existing tests ([P0-T3])

Timestamp: 2026-11-07T22-44
Command: grep -rl -F -e <token> tests/ for each of Invoke-EstateDocumentElement, EPIC_MANIFEST_KEY_MISSING, DispositionOnly, PinOnly, "PowerShell 7 session"; grep -rl -F "consumer-onboarding.md" tests/ docs/engineering/; grep -n -F "consumer-onboarding.md" over each hit to identify the page it names
EXIT_CODE: 0
Output Summary: every hit file maps to a row of the plan's dispositions table or is a recorded non-reader. No unlisted test. Execution continues to [P1-T1].

## Hits by token

| Token | Hit file | Disposition row | Note |
|---|---|---|---|
| `Invoke-EstateDocumentElement` | `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | 3 | defined and called only inside this file |
| `EPIC_MANIFEST_KEY_MISSING` | `tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1` | 1, 2 | the support module emits the code; no test file asserts it |
| `DispositionOnly` | `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | 3 | helper switch, replaced by [P3-T1] |
| `PinOnly` | `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | 3 | helper switch, replaced by [P3-T1] |
| `PowerShell 7 session` | none under `tests/` | 5 | no test asserts the edited phrase |

## Readers of `consumer-onboarding.md`

| Hit file | Reader of ONB/consumer-onboarding.md | Disposition |
|---|---|---|
| `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` | yes (test) | row 5: `states the PowerShell 7.4 prerequisite` asserts the `## Prerequisites` sentence, which is not edited; `finds no consumer-identifier digest in the template pair or the onboarding pages` hashes page tokens and the `7.4` token is no consumer identifier. The file's other page reads (`states that the optional python pack enables the native Python analyzer`, `states that linting is optional and check is the required page gate`) assert sentences that [P2-T1] does not edit. |
| `docs/engineering/documentation-estate/README.md` | yes (non-test, link only) | links the page and asserts no page text |
| `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` | no | reads `docs/engineering/legacy-discovery-and-parity/consumer-onboarding.md` (its `DOC` root is the legacy-discovery folder) |
| `docs/engineering/legacy-discovery-and-parity/README.md` | no | links the separate legacy-discovery page |
| `docs/engineering/legacy-discovery-and-parity/examples/taskmaster-tmw.md` | no | links `../consumer-onboarding.md` in the legacy-discovery folder |

No hit falls outside the dispositions table.
