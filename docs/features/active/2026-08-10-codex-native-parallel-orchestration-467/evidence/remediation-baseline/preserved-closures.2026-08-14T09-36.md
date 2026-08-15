# Preserved Closure Hash Baseline

Timestamp: 2026-08-14T23-42
Command: Resolve the prior Python, TypeScript, Bash, root/bundle parity, authority/payload, root `testResults.xml`, and `.claude/**` closure receipts named by the remediation inputs and hash each file with `Get-FileHash -Algorithm SHA256`.
EXIT_CODE: 0
Output Summary: All 21 pre-cycle closure receipts exist and were bound to exact SHA-256 values for P4-T5 and final-QA preservation comparisons.

| Closure | Receipt | SHA-256 |
|---|---|---|
| Python format | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-final-black.2026-08-13T15-38.md` | `D018934A22416423298C75A53119BCD76ACEB510BABCC63D7C7EDFC46954ADA9` |
| Python lint | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-final-ruff.2026-08-13T15-38.md` | `8E4DD380B9FE0A9AE66E8DD8D376DBCDB08D2FEB115314172F01AC8F9689D942` |
| Python types | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-final-pyright.2026-08-13T15-38.md` | `56C5B48C34AC4A3517ED05F9C31EC797B0448269578E3315F2CE2EDC38806EF1` |
| Python tests/coverage | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-final-test-coverage.2026-08-13T15-38.md` | `2B5194F112DAFE7DF66D98A759F090370B29751BD59DE0347FED9C9637197F3B` |
| Python coverage JSON | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-final-coverage.2026-08-13T15-38.json` | `619752D8B786E007716D5767221EB682DD05CE776688D7BAE3D9FA8AF7DA6141` |
| Python canonical comparison | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-canonical-comparison.2026-08-13T15-38.md` | `C8DC55232E58000AB63266E00A0CEA3B4BC737C5F4DA5C4DD377C1C8F3C78625` |
| TypeScript format | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-format.2026-08-13T15-38.md` | `8F2D00FB88A1643074DD711039621BA7A62942B1C5EACEC402BAEA3AAD76CC6B` |
| TypeScript lint | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-lint.2026-08-13T15-38.md` | `4FECA38FEE79A9EC195212D51DF2331A43E928F40D7F4524D9D1EB9DD55D9117` |
| TypeScript types | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-typecheck.2026-08-13T15-38.md` | `4F728380764C1B15E65B676A2B73F670BF6D8CDAE18B8AAACA13D4240412AC66` |
| TypeScript tests/coverage | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-test-coverage.2026-08-13T15-38.md` | `988C55554310119A24CA6D0B94007B54E7E6C3BC3C2E80A74FFCA491AE7C377F` |
| Bash format | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-format.2026-08-13T15-38.md` | `5BC006BDBD937C9ED954F4135058327E831300C792FE969FA3D8B504C4356431` |
| Bash lint | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-check.2026-08-13T15-38.md` | `D7CA06638248FE8416DBA6C3A0C405AF7AA2CFD42AE5164572FB8E9B992AECB6` |
| Bash tests/coverage | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-test-coverage.2026-08-13T15-38.md` | `EF979181E681A5785D599400EAEB103E08FD6AB1DF7CDD88083945A4D7D3DFB8` |
| Root/bundle byte parity | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/final-root-bundle-byte-parity.2026-08-13T15-38.md` | `87A393B3AD9707DDAD25D87A7E53CA2E3987F637B5DD1D5FFDAB4A09DD2F38FF` |
| Python authority/customization | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/final-python-customization-integrity.2026-08-13T15-38.md` | `D623501DCF02CE3325CFA5E0949B15526EDB6C1D1E5E20EBC76993B5ECBDD039` |
| TypeScript authority/customization | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/final-typescript-customization-integrity.2026-08-13T15-38.md` | `C9E3AB97DBFBE8447F43B40A40253EA3A6FF1797058CC5DCA9C8DEBD738CC38F` |
| Payload portability | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/final-payload-only-integrity.2026-08-13T15-38.md` | `C7AF248581C3026EA2320C3A24DD97399861E2B72E9A81E032ADD1423EDDCDB3` |
| Root test-results restoration | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/root-test-results-restoration.2026-08-13T15-38.md` | `64611AB36A76BE07C76FEAB4D7135C4EB04F6092E268B47E2006CE054D0A6E6B` |
| Root test-results final diff | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/final-testresults-diff.2026-08-13T15-38.md` | `22FD3518A0832F64E3A719CC7B0E307D1A4065D5831FF865DD1893365CEFAF02` |
| `.claude/**` tracked diff | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/final-claude-tracked-diff.2026-08-13T15-38.md` | `66B60F10C7D354A21ACA361045E714C6372CA2BC7B03E70A8232D5092DCE6924` |
| `.claude/**` worktree status | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/final-claude-worktree-status.2026-08-13T15-38.md` | `27611B0FF672A191F0390838D6603BA33BF8F4369EA4F7C2ADA9CDAAEA5E41F2` |
