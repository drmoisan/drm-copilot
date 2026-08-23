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
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS = exports.WORK_MODE_OPTIONS = exports.POTENTIAL_PROMOTION_TYPES = exports.FEATURE_NAME_PATTERN = exports.SHORT_NAME_PATTERN = void 0;
exports.normalizeStringArguments = normalizeStringArguments;
exports.normalizeRequiredText = normalizeRequiredText;
exports.normalizeOptionalText = normalizeOptionalText;
exports.validateChoice = validateChoice;
exports.validatePromotionType = validatePromotionType;
exports.validateWorkMode = validateWorkMode;
exports.validatePolicyAuditTemplateAssetSelector = validatePolicyAuditTemplateAssetSelector;
exports.validateShortName = validateShortName;
exports.validateFeatureName = validateFeatureName;
exports.validateIssueNumber = validateIssueNumber;
exports.validateRequiredIssueNumber = validateRequiredIssueNumber;
exports.getShortNameValidationMessage = getShortNameValidationMessage;
exports.getRequiredIssueNumberValidationMessage = getRequiredIssueNumberValidationMessage;
exports.getFeatureNameValidationMessage = getFeatureNameValidationMessage;
exports.normalizeWorkspaceRoot = normalizeWorkspaceRoot;
exports.isAbsolutePathLike = isAbsolutePathLike;
exports.normalizeWorkspaceDestinationPath = normalizeWorkspaceDestinationPath;
exports.parseWorkflowCommandArguments = parseWorkflowCommandArguments;
exports.getOptionalFlagValue = getOptionalFlagValue;
exports.getRequiredFlagValue = getRequiredFlagValue;
const path = __importStar(require("node:path"));
exports.SHORT_NAME_PATTERN = /^[a-z0-9]+(-[a-z0-9]+)*$/;
exports.FEATURE_NAME_PATTERN = /^[a-z0-9]+(?:[-_][a-z0-9]+)*$/;
exports.POTENTIAL_PROMOTION_TYPES = [
    "epic",
    "feature",
    "refactor",
    "bug",
];
exports.WORK_MODE_OPTIONS = [
    "minor-audit",
    "full-feature",
    "full-bug",
    "full",
];
exports.POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS = [
    "template",
    "agents",
    "code-review-template",
    "feature-audit-template",
];
function formatAllowedFlags(allowedFlags) {
    return [...allowedFlags].join(", ");
}
function normalizeStringArguments(rawArgs) {
    const candidateArgs = rawArgs.length === 1 && Array.isArray(rawArgs[0]) ? rawArgs[0] : rawArgs;
    return candidateArgs.map((arg, index) => {
        if (typeof arg !== "string") {
            throw new Error(`Workflow command arguments must be strings. Argument ${index + 1} has type ${typeof arg}.`);
        }
        return arg;
    });
}
function normalizeRequiredText(value, fieldName) {
    if (typeof value !== "string") {
        throw new Error(`Field '${fieldName}' must be a string.`);
    }
    const trimmed = value.trim();
    if (trimmed.length === 0) {
        throw new Error(`Field '${fieldName}' is required.`);
    }
    return trimmed;
}
function normalizeOptionalText(value, fieldName) {
    if (value === undefined) {
        return undefined;
    }
    return normalizeRequiredText(value, fieldName);
}
function validateChoice(value, fieldName, allowedValues) {
    const matchedChoice = allowedValues.find((allowedValue) => allowedValue === value);
    if (matchedChoice === undefined) {
        const readableFieldName = fieldName
            .replace(/^-+/, "")
            .replace(/_/g, " ")
            .replace(/-/g, " ");
        throw new Error(`${readableFieldName} must be one of: ${allowedValues.join(", ")}.`);
    }
    return matchedChoice;
}
function validatePromotionType(value, fieldName) {
    return validateChoice(value, fieldName, exports.POTENTIAL_PROMOTION_TYPES);
}
function validateWorkMode(value, fieldName) {
    return validateChoice(value, fieldName, exports.WORK_MODE_OPTIONS);
}
function validatePolicyAuditTemplateAssetSelector(value, fieldName) {
    return validateChoice(value, fieldName, exports.POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS);
}
function validateShortName(shortName, fieldName) {
    if (!exports.SHORT_NAME_PATTERN.test(shortName)) {
        throw new Error(`${fieldName} must use kebab-case letters and numbers only (e.g., api-timeout).`);
    }
    return shortName;
}
function validateFeatureName(featureName, fieldName = "--feature-name") {
    if (!exports.FEATURE_NAME_PATTERN.test(featureName)) {
        throw new Error(`${fieldName} must use kebab-case or underscore-case letters and numbers only.`);
    }
    return featureName;
}
function validateIssueNumber(issueNumber) {
    if (issueNumber === undefined) {
        return undefined;
    }
    if (!/^\d+$/.test(issueNumber)) {
        throw new Error("Issue number must be digits only when provided.");
    }
    return issueNumber;
}
function validateRequiredIssueNumber(issueNumber, fieldName) {
    const normalizedIssueNumber = normalizeRequiredText(issueNumber, fieldName);
    if (!/^\d+$/.test(normalizedIssueNumber)) {
        throw new Error(`${fieldName} must be digits only.`);
    }
    return normalizedIssueNumber;
}
function getShortNameValidationMessage(value, fieldName) {
    const trimmed = value.trim();
    if (trimmed.length === 0) {
        return "Short name is required.";
    }
    try {
        validateShortName(trimmed, fieldName);
        return undefined;
    }
    catch (error) {
        return error instanceof Error ? error.message : String(error);
    }
}
function getRequiredIssueNumberValidationMessage(value, fieldName) {
    const trimmed = value.trim();
    if (trimmed.length === 0) {
        return `${fieldName} is required.`;
    }
    return /^\d+$/.test(trimmed)
        ? undefined
        : `${fieldName} must be digits only.`;
}
function getFeatureNameValidationMessage(value) {
    const trimmed = value.trim();
    if (trimmed.length === 0) {
        return "Feature name is required.";
    }
    try {
        validateFeatureName(trimmed, "Feature name");
        return undefined;
    }
    catch (error) {
        return error instanceof Error ? error.message : String(error);
    }
}
/**
 * Normalizes a caller-supplied `workspace_root` value, failing closed when it
 * is omitted and no explicit fallback is supplied.
 *
 * The MCP server is a single long-running process shared across concurrent
 * worktree-isolated agents, so it cannot infer which checkout a given call
 * originated from. Returning `process.cwd()` for an omitted value silently
 * misdirects writes to the server's own checkout. To prevent that, an omitted
 * value with no explicit fallback now throws. Callers that legitimately have a
 * workspace context (the VS Code command surface) pass it explicitly via
 * `fallbackWorkspaceRoot` and retain their previous behavior.
 *
 * @param value The caller-supplied workspace root (string), or `undefined`.
 * @param fallbackWorkspaceRoot Optional explicit fallback. When omitted and
 *   `value` is `undefined`, the function throws instead of defaulting.
 * @returns The normalized absolute workspace root.
 * @throws Error when `value` is `undefined` and no explicit fallback is
 *   supplied, or when `value` is present but not a valid non-empty string.
 */
function normalizeWorkspaceRoot(value, fallbackWorkspaceRoot) {
    if (value === undefined) {
        if (fallbackWorkspaceRoot === undefined) {
            throw new Error("workspace_root is required. The MCP server cannot infer the calling agent's checkout; pass the absolute worktree root explicitly.");
        }
        return fallbackWorkspaceRoot;
    }
    return normalizeRequiredText(value, "workspace_root");
}
function isAbsolutePathLike(filePath) {
    return /^(?:[a-zA-Z]:[\\/]|\\\\|\/)/.test(filePath);
}
function normalizeWorkspaceDestinationPath(value, workspaceRoot, fieldName) {
    const targetPath = normalizeRequiredText(value, fieldName);
    const resolvedPath = isAbsolutePathLike(targetPath)
        ? targetPath
        : path.join(workspaceRoot, targetPath);
    return resolvedPath.replace(/\\/g, "/");
}
/**
 * Parses a CLI-style flag array for the extension workflow commands.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @param allowedFlags The exact set of flags accepted for the target workflow.
 * @returns The validated flag-value map for the supplied arguments.
 * @throws Error when an argument is not a string, a flag is unknown or duplicated,
 * a flag is missing a value, or a value appears without a preceding flag.
 */
function parseWorkflowCommandArguments(rawArgs, allowedFlags) {
    const stringArgs = normalizeStringArguments(rawArgs);
    const allowedFlagSet = new Set(allowedFlags);
    const values = new Map();
    for (let index = 0; index < stringArgs.length; index += 2) {
        const flag = stringArgs[index];
        if (flag === undefined) {
            break;
        }
        if (!flag.startsWith("-")) {
            throw new Error(`Unexpected value '${flag}' without a preceding flag. Accepted flags: ${formatAllowedFlags(allowedFlagSet)}.`);
        }
        if (!allowedFlagSet.has(flag)) {
            throw new Error(`Unknown flag '${flag}'. Accepted flags: ${formatAllowedFlags(allowedFlagSet)}.`);
        }
        if (values.has(flag)) {
            throw new Error(`Duplicate flag '${flag}' is not allowed.`);
        }
        const value = stringArgs[index + 1];
        if (value === undefined || value.startsWith("-")) {
            throw new Error(`Flag '${flag}' requires a value.`);
        }
        values.set(flag, value);
    }
    return { values };
}
/**
 * Looks up an optional parsed flag value.
 *
 * @param parsedArgs The parsed flag map returned by {@link parseWorkflowCommandArguments}.
 * @param flag The flag to read.
 * @returns The parsed value when present; otherwise `undefined`.
 */
function getOptionalFlagValue(parsedArgs, flag) {
    return parsedArgs.values.get(flag);
}
/**
 * Looks up a required parsed flag value.
 *
 * @param parsedArgs The parsed flag map returned by {@link parseWorkflowCommandArguments}.
 * @param flag The flag that must be present.
 * @returns The parsed value associated with the flag.
 * @throws Error when the required flag is missing.
 */
function getRequiredFlagValue(parsedArgs, flag) {
    const value = parsedArgs.values.get(flag);
    if (value === undefined) {
        throw new Error(`Missing required flag '${flag}'.`);
    }
    return value;
}
__exportStar(require("./workflow-command-invocations"), exports);
