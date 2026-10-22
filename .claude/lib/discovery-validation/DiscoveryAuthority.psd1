@{
    # Module manifest for the shared native discovery authority primitives (issue #980).
    # Importing this manifest loads the authority, manifest and payload modules together
    # so a hook can take every narrow primitive from one import.
    RootModule        = 'DiscoveryAuthority.psm1'
    ModuleVersion     = '2.0.0'
    GUID              = '5d0b8e5e-3b7f-4a2a-9f8e-2f9f0b9a7c11'
    Author            = 'drm-copilot'
    CompanyName       = 'drm-copilot'
    Copyright         = '(c) drm-copilot. All rights reserved.'
    Description       = 'Protected discovery authority location, activation decoding, input-manifest freshness and host envelope normalization for native discovery hooks.'
    PowerShellVersion = '7.0'
    NestedModules     = @('DiscoveryEncoding.psm1', 'DiscoveryManifest.psm1', 'DiscoveryPayload.psm1', 'DiscoveryAuthorization.psm1', 'DiscoveryStartRecord.psm1', 'DiscoveryStart.psm1', 'DiscoveryStop.psm1')
    FunctionsToExport = @(
        'Get-DiscoverySha256Hex',
        'Get-DiscoveryBytesSha256Hex',
        'ConvertTo-DiscoveryCanonicalJson',
        'Invoke-DiscoveryStoreSeam',
        'Resolve-DiscoveryAuthorityLocation',
        'Get-DiscoveryTrustedHostEnvironment',
        'Get-DiscoveryPartitionName',
        'Get-DiscoverySessionDirectory',
        'Get-DiscoveryInvocationDirectory',
        'Get-DiscoveryActivationRecordPath',
        'Test-DiscoveryProtectedPath',
        'Test-DiscoveryRelativePath',
        'ConvertFrom-DiscoveryActivationRecord',
        'Read-DiscoveryActivationState',
        'ConvertFrom-DiscoveryInputManifest',
        'Get-DiscoveryInputManifestDigest',
        'Get-DiscoveryWorkspacePath',
        'Compare-DiscoveryInputManifest',
        'Assert-DiscoveryInputsFresh',
        'Test-DiscoverySupportedHost',
        'ConvertFrom-DiscoveryHostEnvelope',
        'ConvertFrom-DiscoveryHostPayloadText',
        'Get-DiscoveryTrustedPrincipal',
        'Get-DiscoveryHostEnvironmentValueTable',
        'Get-DiscoveryPayloadAnomalyReason',
        'Resolve-DiscoveryToolName',
        'Get-DiscoveryToolOperation',
        'Get-DiscoveryInputDigest',
        'Find-DiscoveryAgentInvocation',
        'ConvertTo-DiscoveryToolAuthorizationRecord',
        'Get-DiscoveryDefaultStore',
        'Get-DiscoveryAuthorizationNonce',
        'Get-DiscoveryPreToolDecision',
        'ConvertTo-DiscoveryPreToolHookOutput',
        'Get-DiscoveryAgentRole',
        'Get-DiscoveryAgentProfilePath',
        'ConvertFrom-DiscoveryMarkdownProfile',
        'Read-DiscoveryAgentProfile',
        'ConvertTo-DiscoveryUtcInstant',
        'ConvertTo-DiscoveryStartedInvocationText',
        'ConvertTo-DiscoveryStartAttestationRecord',
        'Get-DiscoveryStartStore',
        'Get-DiscoveryStartAttestationFileName',
        'Find-DiscoveryPreparedInvocation',
        'Get-DiscoveryDeploymentMismatch',
        'Get-DiscoveryCapabilityMismatch',
        'Get-DiscoveryStartDecision',
        'Get-DiscoveryAuthorizationNonceText',
        'ConvertTo-DiscoveryStartHookOutput',
        'Find-DiscoveryAgentInvocationForStop',
        'Get-DiscoveryReceiptMismatch',
        'Get-DiscoveryStopDecision',
        'Get-DiscoveryStopVerdict'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags = @('drm-copilot', 'discovery', 'hooks')
        }
    }
}
