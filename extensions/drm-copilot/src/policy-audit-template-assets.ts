import * as fs from "node:fs";
import * as path from "node:path";
import type { PolicyAuditTemplateAssetSelector } from "./workflow-command-arguments";

export interface PolicyAuditTemplateAssetLocation {
  readonly assetId: string;
  readonly bundledSourcePath: string;
}

const POLICY_AUDIT_TEMPLATE_ASSET_METADATA: Readonly<
  Record<
    PolicyAuditTemplateAssetSelector,
    {
      readonly assetId: string;
      readonly fileName: string;
    }
  >
> = {
  template: {
    assetId: "policy_audit.template",
    fileName: "policy-audit.yyyy-MM-ddTHH-mm.md",
  },
  agents: {
    assetId: "policy_audit.agents",
    fileName: "AGENTS.md",
  },
  "code-review-template": {
    assetId: "policy_audit.code_review_template",
    fileName: "code-review.yyyy-MM-ddTHH-mm.md",
  },
  "feature-audit-template": {
    assetId: "policy_audit.feature_audit_template",
    fileName: "feature-audit.yyyy-MM-ddTHH-mm.md",
  },
};

function normalizeRepoPath(filePath: string): string {
  return filePath.replace(/\\/g, "/");
}

export function resolveBundledPolicyAuditTemplateAsset(
  extensionRoot: string,
  asset: PolicyAuditTemplateAssetSelector,
): PolicyAuditTemplateAssetLocation {
  const assetMetadata = POLICY_AUDIT_TEMPLATE_ASSET_METADATA[asset];
  const bundledSourcePath = normalizeRepoPath(
    path.join(
      extensionRoot,
      "resources",
      "templates",
      "policy_audit",
      assetMetadata.fileName,
    ),
  );

  return {
    assetId: assetMetadata.assetId,
    bundledSourcePath,
  };
}

export function copyBundledPolicyAuditTemplateAsset(
  bundledSourcePath: string,
  targetPath: string,
): string {
  const normalizedTargetPath = normalizeRepoPath(targetPath);
  if (normalizedTargetPath === bundledSourcePath) {
    return normalizedTargetPath;
  }

  fs.mkdirSync(path.dirname(normalizedTargetPath), { recursive: true });
  fs.copyFileSync(bundledSourcePath, normalizedTargetPath);
  return normalizedTargetPath;
}
