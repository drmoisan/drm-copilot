"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolveBundledPolicyAuditTemplateAsset = resolveBundledPolicyAuditTemplateAsset;
exports.copyBundledPolicyAuditTemplateAsset = copyBundledPolicyAuditTemplateAsset;
const fs = __importStar(require("node:fs"));
const path = __importStar(require("node:path"));
const POLICY_AUDIT_TEMPLATE_ASSET_METADATA = {
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
function normalizeRepoPath(filePath) {
    return filePath.replace(/\\/g, "/");
}
function resolveBundledPolicyAuditTemplateAsset(extensionRoot, asset) {
    const assetMetadata = POLICY_AUDIT_TEMPLATE_ASSET_METADATA[asset];
    const bundledSourcePath = normalizeRepoPath(path.join(extensionRoot, "resources", "templates", "policy_audit", assetMetadata.fileName));
    return {
        assetId: assetMetadata.assetId,
        bundledSourcePath,
    };
}
function copyBundledPolicyAuditTemplateAsset(bundledSourcePath, targetPath) {
    const normalizedTargetPath = normalizeRepoPath(targetPath);
    if (normalizedTargetPath === bundledSourcePath) {
        return normalizedTargetPath;
    }
    fs.mkdirSync(path.dirname(normalizedTargetPath), { recursive: true });
    fs.copyFileSync(bundledSourcePath, normalizedTargetPath);
    return normalizedTargetPath;
}
