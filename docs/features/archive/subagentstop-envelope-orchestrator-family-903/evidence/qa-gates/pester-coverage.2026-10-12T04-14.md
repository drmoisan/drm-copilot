# Final Pester with Coverage, Pass 1 ([P7-T3])

Timestamp: 2026-10-12T04-14
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 -TestPath <S-COV-SUITES-20, comma-joined> -CoveragePath .claude/hooks/validate-orchestrator-output.ps1,.claude/hooks/validate-orchestrator-output-routing.ps1,.claude/hooks/validate-orchestrator-output-resolution.ps1,.claude/hooks/validate-executor-output.ps1,.claude/hooks/validate-planner-output.ps1,.claude/hooks/validate-required-artifact-output.ps1 -CoverageOutputPath <SCRATCHPAD>/final-coverage.xml -ReportPath <SCRATCHPAD>/final-coverage-report.txt
EXIT_CODE: 0
Output Summary:
TotalCount=288
PassedCount=288
FailedCount=0
FailedContainersCount=0
COVERAGE file=.claude/hooks/validate-orchestrator-output.ps1 AnalyzedLines=110 CoveredLines=109 LinePercent=99.09
COVERAGE file=.claude/hooks/validate-orchestrator-output-routing.ps1 AnalyzedLines=28 CoveredLines=28 LinePercent=100
COVERAGE file=.claude/hooks/validate-orchestrator-output-resolution.ps1 AnalyzedLines=94 CoveredLines=93 LinePercent=98.94
COVERAGE file=.claude/hooks/validate-executor-output.ps1 AnalyzedLines=119 CoveredLines=117 LinePercent=98.32
COVERAGE file=.claude/hooks/validate-planner-output.ps1 AnalyzedLines=200 CoveredLines=199 LinePercent=99.5
COVERAGE file=.claude/hooks/validate-required-artifact-output.ps1 AnalyzedLines=61 CoveredLines=60 LinePercent=98.36

Test paths (S-COV-SUITES-20, all under tests/scripts/claude-hooks/): validate-orchestrator-output.Tests.ps1, validate-orchestrator-output.model-routing.Tests.ps1, validate-orchestrator-output.artifact-type-dispatch.Tests.ps1, validate-orchestrator-output.WaveBarrier.Tests.ps1, validate-orchestrator-output.WorktreeResolution.Tests.ps1, validate-orchestrator-output-resolution.Tests.ps1, validate-executor-output.Tests.ps1, validate-planner-output.Tests.ps1, validate-planner-output.Coverage.Tests.ps1, validate-required-artifact-output.Tests.ps1, hook-import-failure-exemptions.FailClosed.Tests.ps1, validate-orchestrator-output.human-interaction.Tests.ps1, validate-orchestrator-output.Envelope.Tests.ps1, validate-executor-output.Envelope.Tests.ps1, validate-required-artifact-output.Envelope.Tests.ps1, validate-orchestrator-output.Reentry.Tests.ps1, validate-executor-output.Reentry.Tests.ps1, validate-planner-output.Reentry.Tests.ps1, validate-required-artifact-output.Reentry.Tests.ps1, subagentstop-envelope-orchestrator-family.Registration.Tests.ps1.

Post-Change Coverage:
- .claude/hooks/validate-orchestrator-output.ps1: 99.09
- .claude/hooks/validate-orchestrator-output-routing.ps1: 100
- .claude/hooks/validate-orchestrator-output-resolution.ps1: 98.94
- .claude/hooks/validate-executor-output.ps1: 98.32
- .claude/hooks/validate-planner-output.ps1: 99.5
- .claude/hooks/validate-required-artifact-output.ps1: 98.36

Full report:
TotalCount=288
PassedCount=288
FailedCount=0
FailedContainersCount=0
COVERAGE file=.claude/hooks/validate-orchestrator-output.ps1 AnalyzedLines=110 CoveredLines=109 LinePercent=99.09
HIT file=.claude/hooks/validate-orchestrator-output.ps1 Lines=51,53,55,56,57,58,59,60,61,62,63,64,65,84,85,88,89,125,128,129,132,133,134,137,138,140,141,142,144,145,147,148,151,152,155,156,159,160,161,163,164,167,168,173,193,198,199,201,202,204,205,206,207,209,210,211,212,214,240,241,247,250,252,253,254,258,259,260,263,264,268,270,273,274,275,276,277,278,282,283,284,287,288,291,292,293,296,297,299,300,307,308,309,311,312,318,319,321,326,327,328,331,335,338,339,340,342,343,344
MISSED file=.claude/hooks/validate-orchestrator-output.ps1 Lines=234
COVERAGE file=.claude/hooks/validate-orchestrator-output-routing.ps1 AnalyzedLines=28 CoveredLines=28 LinePercent=100
HIT file=.claude/hooks/validate-orchestrator-output-routing.ps1 Lines=56,57,58,61,119,124,125,127,128,129,130,133,136,137,138,139,145,146,147,154,155,156,157,159,160,161,168,169
MISSED file=.claude/hooks/validate-orchestrator-output-routing.ps1 Lines=
COVERAGE file=.claude/hooks/validate-orchestrator-output-resolution.ps1 AnalyzedLines=94 CoveredLines=93 LinePercent=98.94
HIT file=.claude/hooks/validate-orchestrator-output-resolution.ps1 Lines=24,25,26,27,32,33,34,37,38,59,60,61,62,63,64,65,84,85,88,91,92,94,95,97,116,117,118,119,120,121,122,123,124,146,147,148,150,151,152,153,154,155,156,157,158,159,160,161,162,164,194,195,196,198,201,202,203,208,209,212,213,214,215,216,217,218,219,220,221,223,225,226,229,233,234,236,237,238,240,258,259,260,261,275,296,298,301,302,303,305,308,309,310
MISSED file=.claude/hooks/validate-orchestrator-output-resolution.ps1 Lines=89
COVERAGE file=.claude/hooks/validate-executor-output.ps1 AnalyzedLines=119 CoveredLines=117 LinePercent=98.32
HIT file=.claude/hooks/validate-executor-output.ps1 Lines=35,37,38,39,40,50,51,54,55,56,58,59,62,73,74,75,76,79,80,81,85,96,107,108,110,111,112,113,114,115,116,117,122,136,137,138,139,140,143,144,145,156,170,171,174,175,178,182,196,197,199,200,202,203,204,205,207,227,228,231,232,233,236,237,238,241,242,243,244,246,247,249,252,253,256,257,258,259,261,262,263,264,265,267,268,272,273,276,277,278,279,280,281,283,284,285,288,289,292,293,294,295,298,299,300,301,305,306,307,310,313,317,318,319,320,321,322
MISSED file=.claude/hooks/validate-executor-output.ps1 Lines=82,179
COVERAGE file=.claude/hooks/validate-planner-output.ps1 AnalyzedLines=200 CoveredLines=199 LinePercent=99.5
HIT file=.claude/hooks/validate-planner-output.ps1 Lines=37,39,40,41,42,52,53,56,57,58,60,61,64,75,76,81,82,85,86,87,88,91,102,103,114,125,126,127,128,129,130,131,133,134,135,137,138,140,141,145,146,149,150,151,152,155,156,160,161,162,163,167,168,169,170,171,172,174,175,179,180,181,183,184,185,186,190,191,192,194,195,196,198,199,200,201,204,205,206,208,209,210,211,216,218,220,221,223,224,225,226,229,230,231,234,245,246,247,248,249,250,251,252,253,255,256,257,259,260,261,262,263,264,268,269,270,271,274,275,276,277,281,282,286,287,288,289,290,294,295,299,300,301,303,304,307,308,310,311,312,315,316,319,322,323,324,327,328,331,332,335,336,337,339,340,344,345,346,347,348,350,351,354,367,368,369,370,372,373,375,376,377,378,380,399,400,403,404,407,408,409,412,413,414,417,418,419,420,423,424,425,428,431,434,435,436,438,439,440
MISSED file=.claude/hooks/validate-planner-output.ps1 Lines=157
COVERAGE file=.claude/hooks/validate-required-artifact-output.ps1 AnalyzedLines=61 CoveredLines=60 LinePercent=98.36
HIT file=.claude/hooks/validate-required-artifact-output.ps1 Lines=36,38,39,40,41,51,62,63,64,67,68,69,70,85,86,87,88,89,92,93,94,98,114,115,117,118,120,121,122,123,125,147,148,151,152,154,157,160,161,162,166,167,171,172,176,177,178,181,184,188,189,190,191,192,193,194,195,197,198,199
MISSED file=.claude/hooks/validate-required-artifact-output.ps1 Lines=95
