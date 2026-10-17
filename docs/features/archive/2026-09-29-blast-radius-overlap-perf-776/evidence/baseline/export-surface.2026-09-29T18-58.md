# Baseline Export Surface (P0-T9)

Timestamp: 2026-09-29T18-58
Command: sh SCRATCH/run-ps.sh SCRATCH/export-surface.ps1
EXIT_CODE: 0
Output Summary:
- 64 SURFACE lines across the 10 modules under .claude/lib/blast-radius (recorded verbatim below).
- SURFACE-COUNT=64
- SURFACE-SHA256=B7EB83344720E96C1BCBE7340D415983E17674A33E8EF0A1F488E9F48CD9FE3C
- Result: PASS. P2-T11 compares against this count and SHA.

SURFACE lines (verbatim):

```
SURFACE module=BlastRadius.psm1 function=Get-BlastRadius cmdletbinding=True output=System.Collections.Hashtable params=ComputedAt:System.String:True;Config:System.Object:True;FeatureFolder:System.String:True;PlanText:System.String:True;Source:System.String:False;SpecText:System.String:True
SURFACE module=BlastRadius.psm1 function=Get-BlastRadiusConflictEdge cmdletbinding=True output=System.Collections.Hashtable params=Config:System.Object:True;Item:System.Object[]:True;Relation:System.Management.Automation.ScriptBlock:False
SURFACE module=BlastRadius.psm1 function=Get-BlastRadiusFromObservedPaths cmdletbinding=True output=System.Collections.Hashtable params=ComputedAt:System.String:True;Config:System.Object:True;ObservedPaths:System.Object:True
SURFACE module=BlastRadius.psm1 function=Get-BlastRadiusPairDecision cmdletbinding=True output=System.Collections.Hashtable params=BandA:System.Object:False;BandB:System.Object:False;Config:System.Object:True;RadiusA:System.Object:True;RadiusB:System.Object:True;Relation:System.Management.Automation.ScriptBlock:False
SURFACE module=BlastRadius.psm1 function=Get-ConfigPathRoot cmdletbinding=True output=System.Object[] params=Config:System.Object:True
SURFACE module=BlastRadius.psm1 function=Get-NormalizedDeclaredRadius cmdletbinding=True output=System.Collections.Hashtable params=Config:System.Object:True;Radius:System.Object:True
SURFACE module=BlastRadius.psm1 function=Get-PlanPathForConfig cmdletbinding=True output=System.Object[] params=Config:System.Object:True;PlanText:System.String:True;RootSurface:System.String[]:False
SURFACE module=BlastRadius.psm1 function=Get-PlanPaths cmdletbinding=True output=System.Object[] params=PlanText:System.String:True;RootSurface:System.String[]:False
SURFACE module=BlastRadius.psm1 function=Get-WriteIntentPlanPath cmdletbinding=True output=System.Object[] params=PathRoot:System.String[]:False;PlanText:System.String:True;RootSurface:System.String[]:False
SURFACE module=BlastRadius.psm1 function=Get-WriteIntentSpecContract cmdletbinding=True output=System.Object[] params=SpecText:System.String:True
SURFACE module=BlastRadius.psm1 function=Select-WriteIntentPathEntry cmdletbinding=True output=System.Object[] params=Entry:System.String[]:True;PathRoot:System.String[]:False;RootSurface:System.String[]:False
SURFACE module=BlastRadius.psm1 function=Test-BlastRadius cmdletbinding=True output=System.Object[] params=Config:System.Object:True;PlanText:System.String:True;Radius:System.Object:True;TrackedFileCount:System.Object:True
SURFACE module=BlastRadius.psm1 function=Test-BlastRadiusConflict cmdletbinding=True output=System.Collections.Hashtable params=Config:System.Object:True;RadiusA:System.Object:True;RadiusB:System.Object:True
SURFACE module=BlastRadius.psm1 function=Test-WriteIntentExtractionEnabled cmdletbinding=True output=System.Boolean params=Config:System.Object:True
SURFACE module=BlastRadiusConfig.psm1 function=Get-ConfigMandateRead cmdletbinding=True output=System.Object[] params=Config:System.Object:True
SURFACE module=BlastRadiusConfig.psm1 function=Get-ConfigModuleEntry cmdletbinding=True output=System.Object[] params=Config:System.Object:True
SURFACE module=BlastRadiusConfig.psm1 function=Get-ConfigOverBreadthFraction cmdletbinding=True output=System.Double params=Config:System.Object:True
SURFACE module=BlastRadiusConfig.psm1 function=Get-ConfigRootSurface cmdletbinding=True output=System.Object[] params=Config:System.Object:True
SURFACE module=BlastRadiusConfig.psm1 function=Get-ConfigStringList cmdletbinding=True output=System.Object[] params=Config:System.Object:True;Key:System.String:True
SURFACE module=BlastRadiusConfig.psm1 function=Get-RequiredMapping cmdletbinding=True output=System.Collections.Hashtable params=FieldName:System.String:True;Value:System.Object:True
SURFACE module=BlastRadiusConfig.psm1 function=Get-RequiredStringList cmdletbinding=True output=System.Object[] params=FieldName:System.String:True;Value:System.Object:True
SURFACE module=BlastRadiusConfig.psm1 function=Get-RequiredText cmdletbinding=True output=System.String params=AllowEmpty:System.Management.Automation.SwitchParameter:False;FieldName:System.String:True;Value:System.Object:True
SURFACE module=BlastRadiusConfig.psm1 function=Resolve-BlastRadiusSharedSurface cmdletbinding=True output=System.Object[] params=ConcretePath:System.String[]:True;Config:System.Object:True
SURFACE module=BlastRadiusConflict.psm1 function=Get-ConfigMergeablePath cmdletbinding=True output=System.Object[] params=Config:System.Object:True
SURFACE module=BlastRadiusConflict.psm1 function=Get-NonMergeablePathEntry cmdletbinding=True output=System.Object[] params=Entry:System.String[]:True;MergeablePath:System.String[]:True
SURFACE module=BlastRadiusConflict.psm1 function=Get-SmallestCommonEntry cmdletbinding=True output=System.String params=Left:System.String[]:True;Right:System.String[]:True
SURFACE module=BlastRadiusConflict.psm1 function=Get-SmallestPathOverlap cmdletbinding=True output=System.String params=PathA:System.String[]:True;PathB:System.String[]:True
SURFACE module=BlastRadiusConflict.psm1 function=Test-MergeablePath cmdletbinding=True output=System.Boolean params=Entry:System.String:True;MergeablePath:System.String[]:True
SURFACE module=BlastRadiusExtraction.psm1 function=ConvertTo-NormalizedLine cmdletbinding=True output=System.Object[] params=Text:System.String:True
SURFACE module=BlastRadiusExtraction.psm1 function=Get-InlineCodeToken cmdletbinding=True output=System.Object[] params=Line:System.String:True
SURFACE module=BlastRadiusExtraction.psm1 function=Get-OrdinalSortedEntry cmdletbinding=True output=System.Object[] params=Entry:System.String[]:True
SURFACE module=BlastRadiusExtraction.psm1 function=Get-PathFromLine cmdletbinding=True output=System.Object[] params=Line:System.String[]:True;RootSurface:System.String[]:False
SURFACE module=BlastRadiusExtraction.psm1 function=Get-PathTokenKind cmdletbinding=True output=System.String params=RootSurface:System.String[]:False;Token:System.String:True
SURFACE module=BlastRadiusExtraction.psm1 function=Get-PlanLineScan cmdletbinding=True output=System.Collections.Hashtable params=PlanText:System.String:True
SURFACE module=BlastRadiusExtraction.psm1 function=Get-PlanPaths cmdletbinding=True output=System.Object[] params=PlanText:System.String:True;RootSurface:System.String[]:False
SURFACE module=BlastRadiusExtraction.psm1 function=Test-MultipleFeatureFolderSpan cmdletbinding=True output=System.Boolean params=Token:System.String:True
SURFACE module=BlastRadiusExtraction.psm1 function=Test-PlaceholderMarker cmdletbinding=True output=System.Boolean params=Token:System.String:True
SURFACE module=BlastRadiusGlob.psm1 function=Get-ConcreteEntry cmdletbinding=True output=System.Object[] params=Entry:System.String[]:True
SURFACE module=BlastRadiusGlob.psm1 function=Get-LiteralPrefix cmdletbinding=True output=System.String params=Entry:System.String:True
SURFACE module=BlastRadiusGlob.psm1 function=Get-OrdinalSmallestEntry cmdletbinding=True output=System.String params=Entry:System.String[]:True
SURFACE module=BlastRadiusGlob.psm1 function=Get-OrdinalSortedEntry cmdletbinding=True output=System.Object[] params=Entry:System.String[]:True
SURFACE module=BlastRadiusGlob.psm1 function=Test-EntryOverlap cmdletbinding=True output=System.Boolean params=EntryA:System.String:True;EntryB:System.String:True
SURFACE module=BlastRadiusGlob.psm1 function=Test-GlobEntry cmdletbinding=True output=System.Boolean params=Entry:System.String:True
SURFACE module=BlastRadiusGlob.psm1 function=Test-GlobMatch cmdletbinding=True output=System.Boolean params=Candidate:System.String:True;Pattern:System.String:True
SURFACE module=BlastRadiusGlob.psm1 function=Test-PathSubsumed cmdletbinding=True output=System.Boolean params=CoveringPath:System.String[]:True;Path:System.String:True
SURFACE module=BlastRadiusNormalization.psm1 function=Get-ContractIdentifier cmdletbinding=True output=System.Object[] params=SpecText:System.String:True
SURFACE module=BlastRadiusNormalization.psm1 function=Get-NonMandateReadEntry cmdletbinding=True output=System.Object[] params=Entry:System.String[]:True;MandateRead:System.String[]:True
SURFACE module=BlastRadiusNormalization.psm1 function=Resolve-BlastRadiusModule cmdletbinding=True output=System.Object[] params=Config:System.Object:True;PathEntry:System.String[]:True
SURFACE module=BlastRadiusNormalization.psm1 function=Test-MandateRead cmdletbinding=True output=System.Boolean params=Entry:System.String:True;MandateRead:System.String[]:True
SURFACE module=BlastRadiusScheduling.psm1 function=Get-BlastRadiusConflictEdge cmdletbinding=True output=System.Collections.Hashtable params=Config:System.Object:True;Item:System.Object[]:True;Relation:System.Management.Automation.ScriptBlock:False
SURFACE module=BlastRadiusScheduling.psm1 function=Get-BlastRadiusPairBenefit cmdletbinding=True output=System.Int64 params=BandA:System.Object:False;BandB:System.Object:False;Tolerance:System.Collections.Hashtable:True
SURFACE module=BlastRadiusScheduling.psm1 function=Get-BlastRadiusPairCost cmdletbinding=True output=System.Int64 params=Config:System.Object:True;RadiusA:System.Object:True;RadiusB:System.Object:True;Tolerance:System.Collections.Hashtable:True
SURFACE module=BlastRadiusScheduling.psm1 function=Get-BlastRadiusPairDecision cmdletbinding=True output=System.Collections.Hashtable params=BandA:System.Object:False;BandB:System.Object:False;Config:System.Object:True;RadiusA:System.Object:True;RadiusB:System.Object:True;Relation:System.Management.Automation.ScriptBlock:False
SURFACE module=BlastRadiusScheduling.psm1 function=Get-ConfigConflictTolerance cmdletbinding=True output=System.Collections.Hashtable params=Config:System.Object:True
SURFACE module=BlastRadiusTokenShape.psm1 function=Test-MultipleFeatureFolderSpan cmdletbinding=True output=System.Boolean params=Token:System.String:True
SURFACE module=BlastRadiusTokenShape.psm1 function=Test-PlaceholderMarker cmdletbinding=True output=System.Boolean params=Token:System.String:True
SURFACE module=BlastRadiusValidation.psm1 function=ConvertTo-NormalizedBlastRadius cmdletbinding=True output=System.Collections.Hashtable params=Radius:System.Object:True
SURFACE module=BlastRadiusValidation.psm1 function=Test-BlastRadius cmdletbinding=True output=System.Object[] params=Config:System.Object:True;PlanText:System.String:True;Radius:System.Object:True;TrackedFileCount:System.Object:True
SURFACE module=BlastRadiusWriteIntent.psm1 function=Get-ConfigPathRoot cmdletbinding=True output=System.Object[] params=Config:System.Object:True
SURFACE module=BlastRadiusWriteIntent.psm1 function=Get-PlanPathForConfig cmdletbinding=True output=System.Object[] params=Config:System.Object:True;PlanText:System.String:True;RootSurface:System.String[]:False
SURFACE module=BlastRadiusWriteIntent.psm1 function=Get-WriteIntentPlanPath cmdletbinding=True output=System.Object[] params=PathRoot:System.String[]:False;PlanText:System.String:True;RootSurface:System.String[]:False
SURFACE module=BlastRadiusWriteIntent.psm1 function=Get-WriteIntentSpecContract cmdletbinding=True output=System.Object[] params=SpecText:System.String:True
SURFACE module=BlastRadiusWriteIntent.psm1 function=Select-WriteIntentPathEntry cmdletbinding=True output=System.Object[] params=Entry:System.String[]:True;PathRoot:System.String[]:False;RootSurface:System.String[]:False
SURFACE module=BlastRadiusWriteIntent.psm1 function=Test-WriteIntentExtractionEnabled cmdletbinding=True output=System.Boolean params=Config:System.Object:True
SURFACE-COUNT=64
SURFACE-SHA256=B7EB83344720E96C1BCBE7340D415983E17674A33E8EF0A1F488E9F48CD9FE3C
```
