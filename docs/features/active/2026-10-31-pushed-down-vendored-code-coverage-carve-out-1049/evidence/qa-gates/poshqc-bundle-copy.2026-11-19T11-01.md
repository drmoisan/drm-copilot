# PoshQC Bundle Copy - [P2-T9]

Timestamp: 2026-11-19T11-01
Command: sh SCRATCH/issue-1049-bundle-copy.sh (cp of each file from scripts/powershell/PoshQC/ to extensions/drm-copilot/resources/powershell/PoshQC/, then sha256sum of both copies)
EXIT_CODE: 0
Output Summary: Six pairs copied; all six SHA-256 pairs EQUAL.

| File | scripts/powershell/PoshQC SHA-256 | extensions/drm-copilot/resources/powershell/PoshQC SHA-256 | Result |
| --- | --- | --- | --- |
| PoshQC.VendoredCoverage.psm1 | 46603a744954883fc6b23d8c9d27e8e10d964e79e30fc59dde4dddf9d70109dd | 46603a744954883fc6b23d8c9d27e8e10d964e79e30fc59dde4dddf9d70109dd | EQUAL |
| PoshQC.Coverage.psm1 | 8e31d22ac2f8ca01e9b8b5a63545808aa1caaeba14dd4d12e77c15476847902d | 8e31d22ac2f8ca01e9b8b5a63545808aa1caaeba14dd4d12e77c15476847902d | EQUAL |
| PoshQC.Testing.psm1 | 0ad7c109c87d4f92c9b6f841f4cea475819b4dcadf3327648af721f9c0133bc8 | 0ad7c109c87d4f92c9b6f841f4cea475819b4dcadf3327648af721f9c0133bc8 | EQUAL |
| PoshQC.psm1 | 5b2505305ec9ee9abfae62a3e49f0c5bed5cdea6d46c1df888e853fedb6e9280 | 5b2505305ec9ee9abfae62a3e49f0c5bed5cdea6d46c1df888e853fedb6e9280 | EQUAL |
| PoshQC.psd1 | d533b2cddc1c81628514c6a8bb36594e65bc4f86e045e8d49ed70eed7c819feb | d533b2cddc1c81628514c6a8bb36594e65bc4f86e045e8d49ed70eed7c819feb | EQUAL |
| README.md | d0a413a337807b3ac42c1b7c209ec152e463d2039e928b8d789f8783d6966fa6 | d0a413a337807b3ac42c1b7c209ec152e463d2039e928b8d789f8783d6966fa6 | EQUAL |
