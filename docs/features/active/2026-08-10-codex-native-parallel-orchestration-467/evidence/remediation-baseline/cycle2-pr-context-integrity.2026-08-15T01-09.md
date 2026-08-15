# Cycle 2 PR Context Integrity Receipt

Timestamp: 2026-08-15T01-34
Command: Get-FileHash artifacts/pr_context.summary.txt,artifacts/pr_context.appendix.txt -Algorithm SHA256; Select-String <each artifact> -SimpleMatch e693a2a32d1c5a936f8a95494900c840139a9b55
EXIT_CODE: 0
Output Summary: Both canonical PR-context artifacts match the authorized SHA-256 values and each contains two exact reviewed-head references.

- Reviewed HEAD: `e693a2a32d1c5a936f8a95494900c840139a9b55`
- `artifacts/pr_context.summary.txt` SHA-256: `8BD213C3796A8F8136AEEF386EF96459DA0C4F14BD40A74CC9E2D6DAF1586EF7`
- Summary reviewed-head occurrences: 2
- `artifacts/pr_context.appendix.txt` SHA-256: `54E58599CBD9A7B52F16AE1BD50B2B2CB98C84432974B2430AD061901F3B84C8`
- Appendix reviewed-head occurrences: 2

Result: PASS
