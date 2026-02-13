'use strict';

const fs = require('fs');
const path = require('path');

/**
 * Find the project root by walking up from startDir looking for .git/
 */
function findProjectRoot(startDir) {
  let dir = path.resolve(startDir);
  while (true) {
    if (fs.existsSync(path.join(dir, '.git'))) {
      return dir;
    }
    const parent = path.dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

/**
 * Find the agents directory within a project root.
 * Looks for any directory containing scripts/sync/sync.sh.
 */
function findAgentsDir(projectRoot) {
  try {
    const entries = fs.readdirSync(projectRoot, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isDirectory()) continue;
      if (!entry.name.startsWith('.')) continue;
      const candidate = path.join(projectRoot, entry.name, 'scripts', 'sync', 'sync.sh');
      if (fs.existsSync(candidate)) {
        return path.join(projectRoot, entry.name);
      }
    }
  } catch (_) {
    // ignore
  }
  return null;
}

/**
 * Read config.yaml and return enabled agents.
 * If config.yaml doesn't exist, all agents are enabled by default.
 */
function readConfig(agentsDir) {
  const defaults = { claude: true, cursor: true, copilot: true };
  const configPath = path.join(agentsDir, 'config.yaml');

  if (!fs.existsSync(configPath)) {
    return defaults;
  }

  const content = fs.readFileSync(configPath, 'utf8');
  const result = { ...defaults };

  // Simple YAML parsing for agents.<name>.enabled pattern
  const lines = content.split('\n');
  let currentAgent = null;
  let inAgents = false;

  for (const line of lines) {
    const trimmed = line.trimEnd();

    if (/^agents\s*:/.test(trimmed)) {
      inAgents = true;
      continue;
    }

    if (inAgents && /^\S/.test(trimmed) && !/^agents\s*:/.test(trimmed)) {
      inAgents = false;
      currentAgent = null;
      continue;
    }

    if (inAgents) {
      const agentMatch = trimmed.match(/^\s{2}(\w+)\s*:/);
      if (agentMatch) {
        currentAgent = agentMatch[1];
        continue;
      }

      if (currentAgent) {
        const enabledMatch = trimmed.match(/^\s{4}enabled\s*:\s*(true|false)/);
        if (enabledMatch && currentAgent in result) {
          result[currentAgent] = enabledMatch[1] === 'true';
        }
      }
    }
  }

  return result;
}

module.exports = { findProjectRoot, findAgentsDir, readConfig };
