#Requires -Version 7.0
BeforeAll { Import-Module (Join-Path $PSScriptRoot '../../../../.claude/lib/requirements/GeneratedDocumentCounters.psm1') -Force }
Describe 'Get-NamedSectionCheckboxCount' {
    It 'counts only boxes within the named section and respects headings' {
        $document = @'
# Title
- [ ] Outside before
## Acceptance Criteria
- [ ] First
### Detail
- [ ] Nested
## Other
- [ ] Outside after
'@
        Get-NamedSectionCheckboxCount -Document $document -Heading 'Acceptance Criteria' | Should -Be 2
    }
}
