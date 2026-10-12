# Baseline Pester with Coverage ([P0-T11])

Timestamp: 2026-10-12T00-02
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 -TestPath <S-COV-SUITES-BASE-12, comma-joined> -CoveragePath <S-PROD-5, comma-joined> -CoverageOutputPath <SCRATCHPAD>/baseline-coverage.xml -ReportPath <SCRATCHPAD>/baseline-coverage-report.txt
EXIT_CODE: 0
Output Summary:
TotalCount=160
PassedCount=160
FailedCount=0
FailedContainersCount=0
(no FAILED: lines)
COVERAGE file=.claude/hooks/validate-orchestrator-output.ps1 AnalyzedLines=131 CoveredLines=125 LinePercent=95.42
COVERAGE file=.claude/hooks/validate-orchestrator-output-resolution.ps1 AnalyzedLines=94 CoveredLines=93 LinePercent=98.94
COVERAGE file=.claude/hooks/validate-executor-output.ps1 AnalyzedLines=113 CoveredLines=79 LinePercent=69.91
COVERAGE file=.claude/hooks/validate-planner-output.ps1 AnalyzedLines=194 CoveredLines=190 LinePercent=97.94
COVERAGE file=.claude/hooks/validate-required-artifact-output.ps1 AnalyzedLines=53 CoveredLines=37 LinePercent=69.81

Baseline Coverage:
- .claude/hooks/validate-orchestrator-output.ps1: 95.42
- .claude/hooks/validate-orchestrator-output-resolution.ps1: 98.94
- .claude/hooks/validate-executor-output.ps1: 69.91
- .claude/hooks/validate-planner-output.ps1: 97.94
- .claude/hooks/validate-required-artifact-output.ps1: 69.81

Full report (<SCRATCHPAD>/baseline-coverage-report.txt):
TotalCount=160
PassedCount=160
FailedCount=0
FailedContainersCount=0
COVERAGE file=.claude/hooks/validate-orchestrator-output.ps1 AnalyzedLines=131 CoveredLines=125 LinePercent=95.42
HIT file=.claude/hooks/validate-orchestrator-output.ps1 Lines=47,49,51,53,54,55,56,57,58,59,60,79,80,83,84,120,123,124,127,128,129,132,133,135,136,137,139,140,142,143,146,147,150,151,154,155,156,158,162,163,168,209,210,211,214,272,277,278,280,281,282,283,286,289,290,291,292,298,299,300,307,308,309,310,312,313,314,321,322,342,347,348,350,351,355,357,360,361,362,364,365,370,371,372,376,377,378,381,382,386,388,391,392,393,394,395,396,400,401,402,405,406,409,410,411,414,415,417,418,425,426,427,429,430,436,437,439,444,445,446,449,453,456,457,458
MISSED file=.claude/hooks/validate-orchestrator-output.ps1 Lines=159,460,461,462,463,466
COVERAGE file=.claude/hooks/validate-orchestrator-output-resolution.ps1 AnalyzedLines=94 CoveredLines=93 LinePercent=98.94
HIT file=.claude/hooks/validate-orchestrator-output-resolution.ps1 Lines=24,25,26,27,32,33,34,37,38,59,60,61,62,63,64,65,84,85,88,91,92,94,95,97,116,117,118,119,120,121,122,123,124,146,147,148,150,151,152,153,154,155,156,157,158,159,160,161,162,164,194,195,196,198,201,202,203,208,209,212,213,214,215,216,217,218,219,220,221,223,225,226,229,233,234,236,237,238,240,258,259,260,261,275,294,296,299,300,301,303,306,307,308
MISSED file=.claude/hooks/validate-orchestrator-output-resolution.ps1 Lines=89
COVERAGE file=.claude/hooks/validate-executor-output.ps1 AnalyzedLines=113 CoveredLines=79 LinePercent=69.91
HIT file=.claude/hooks/validate-executor-output.ps1 Lines=32,33,66,67,68,69,72,73,74,78,89,100,101,103,104,105,106,109,115,129,130,131,132,133,136,137,138,149,163,164,167,168,185,186,190,196,197,198,200,204,205,206,209,210,214,215,216,217,219,220,222,225,226,229,230,231,232,234,235,236,240,241,245,249,261,262,265,266,267,268,271,272,273,274,278,279,280,283,286
MISSED file=.claude/hooks/validate-executor-output.ps1 Lines=43,44,47,48,49,51,52,55,75,107,108,110,171,172,175,193,201,211,237,238,246,250,251,252,253,254,256,257,258,290,291,292,293,296
COVERAGE file=.claude/hooks/validate-planner-output.ps1 AnalyzedLines=194 CoveredLines=190 LinePercent=97.94
HIT file=.claude/hooks/validate-planner-output.ps1 Lines=33,35,36,46,47,50,51,52,54,55,58,69,70,75,76,79,80,81,82,85,96,97,108,119,120,121,122,123,124,125,127,128,129,131,132,134,135,139,140,143,144,145,146,149,150,154,155,156,157,161,162,163,164,165,166,168,169,173,174,175,177,178,179,180,184,185,186,188,189,190,192,193,194,195,198,199,200,202,203,204,205,210,212,214,215,217,218,219,220,223,224,225,228,239,240,241,242,243,244,245,246,248,249,250,252,253,254,255,256,260,261,262,263,266,267,268,269,273,277,278,279,280,284,285,289,290,291,293,294,297,298,300,301,302,305,306,309,312,313,314,317,318,321,322,325,326,327,329,330,334,335,336,337,338,340,341,344,353,354,356,357,361,364,367,368,369,371,372,375,376,379,380,381,384,385,386,389,390,391,392,395,396,400,403,406,407,408,410,411,412
MISSED file=.claude/hooks/validate-planner-output.ps1 Lines=151,397,413,416
COVERAGE file=.claude/hooks/validate-required-artifact-output.ps1 AnalyzedLines=53 CoveredLines=37 LinePercent=69.81
HIT file=.claude/hooks/validate-required-artifact-output.ps1 Lines=31,32,53,54,58,59,60,61,76,77,78,79,80,83,84,85,89,101,106,112,113,114,116,120,121,123,129,130,131,135,136,140,145,146,147,150,153
MISSED file=.claude/hooks/validate-required-artifact-output.ps1 Lines=42,55,86,102,109,117,126,141,157,158,159,162,166,167,168,171
