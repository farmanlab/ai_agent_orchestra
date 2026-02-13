'use strict';

const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { findAgentsDir } = require('./project');

const AVAILABLE_AGENTS = ['claude', 'copilot'];
const AGENT_LABELS = { claude: 'Claude Code', copilot: 'GitHub Copilot' };
const DEFAULT_DIR = '.agents';

// ── Interactive prompts ────────────────────────────────────────────

function createRl() {
  return readline.createInterface({ input: process.stdin, output: process.stdout });
}

function ask(rl, question) {
  return new Promise(resolve => rl.question(question, resolve));
}

async function promptDirName(rl) {
  const answer = await ask(rl, `Unified folder name (${DEFAULT_DIR}): `);
  return answer.trim() || DEFAULT_DIR;
}

async function promptAgents(rl) {
  console.log('Target agents:');
  const selected = [];
  for (const agent of AVAILABLE_AGENTS) {
    const answer = await ask(rl, `  Enable ${AGENT_LABELS[agent]}? (Y/n): `);
    const no = answer.trim().toLowerCase() === 'n';
    selected.push({ name: agent, enabled: !no });
  }
  return selected;
}

// ── File operations ────────────────────────────────────────────────

function copyDirRecursive(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDirRecursive(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

function renderTemplate(content, vars) {
  return content.replace(/\{\{(\w+)\}\}/g, (_, key) => {
    return vars[key] !== undefined ? String(vars[key]) : `{{${key}}}`;
  });
}

// ── Init command ───────────────────────────────────────────────────

async function runInit(projectRoot, flags) {
  let dirName = flags.dir;
  let agentFlags = flags.agents; // e.g. "claude,copilot"

  // Interactive mode if flags not provided
  if (!dirName || !agentFlags) {
    const rl = createRl();
    try {
      if (!dirName) {
        dirName = await promptDirName(rl);
      }

      if (!agentFlags) {
        const selected = await promptAgents(rl);
        agentFlags = selected
          .filter(a => a.enabled)
          .map(a => a.name)
          .join(',');
      }
    } finally {
      rl.close();
    }
  }

  // Ensure dirName starts with a dot
  if (!dirName.startsWith('.')) {
    dirName = '.' + dirName;
  }

  const enabledList = agentFlags.split(',').map(s => s.trim().toLowerCase());
  const agentsDir = path.join(projectRoot, dirName);
  const pkgDir = path.resolve(__dirname, '..');

  // Check if already initialized
  if (fs.existsSync(path.join(agentsDir, 'scripts', 'sync', 'sync.sh'))) {
    console.error(`Already initialized: ${dirName}/`);
    console.error('Use "aao update" to update sync scripts.');
    process.exit(1);
  }

  console.log('');
  console.log(`Initializing ${dirName}/ ...`);
  console.log('');

  // 1. Create directory structure
  const dirs = [
    'rules', 'agents', 'commands', 'skills',
    'scripts/sync', 'templates', 'plugins',
  ];
  for (const d of dirs) {
    fs.mkdirSync(path.join(agentsDir, d), { recursive: true });
  }
  console.log(`  Created ${dirName}/ directory structure`);

  // 2. Copy sync scripts
  const scriptsSource = path.join(pkgDir, 'scripts', 'sync');
  const scriptsDest = path.join(agentsDir, 'scripts', 'sync');

  if (fs.existsSync(scriptsSource)) {
    for (const file of fs.readdirSync(scriptsSource)) {
      if (!file.endsWith('.sh')) continue;
      const src = path.join(scriptsSource, file);
      const dest = path.join(scriptsDest, file);
      fs.copyFileSync(src, dest);
      fs.chmodSync(dest, 0o755);
    }
    console.log(`  Copied sync scripts to ${dirName}/scripts/sync/`);
  } else {
    console.error('  Warning: scripts/sync/ not found in package');
  }

  // 3. Create config.yaml from template
  const configTemplatePath = path.join(pkgDir, 'templates', 'config.yaml');
  if (fs.existsSync(configTemplatePath)) {
    const template = fs.readFileSync(configTemplatePath, 'utf8');
    const vars = {};
    for (const agent of AVAILABLE_AGENTS) {
      const key = `AGENT_${agent.toUpperCase()}_ENABLED`;
      vars[key] = enabledList.includes(agent) ? 'true' : 'false';
    }
    const rendered = renderTemplate(template, vars);
    fs.writeFileSync(path.join(agentsDir, 'config.yaml'), rendered);
    console.log(`  Created ${dirName}/config.yaml`);
  }

  // 4. Copy starter files (skip if existing)
  const starterFiles = [
    { src: 'templates/rules/_base.md', dest: 'rules/_base.md' },
    { src: 'templates/README.md', dest: 'README.md' },
  ];

  for (const { src, dest } of starterFiles) {
    const srcPath = path.join(pkgDir, src);
    const destPath = path.join(agentsDir, dest);
    if (fs.existsSync(destPath)) {
      console.log(`  Skipped ${dirName}/${dest} (already exists)`);
    } else if (fs.existsSync(srcPath)) {
      fs.mkdirSync(path.dirname(destPath), { recursive: true });
      fs.copyFileSync(srcPath, destPath);
      console.log(`  Created ${dirName}/${dest}`);
    }
  }

  // 5. Print summary
  const enabledNames = enabledList.map(a => AGENT_LABELS[a] || a).join(', ');
  const disabledNames = AVAILABLE_AGENTS
    .filter(a => !enabledList.includes(a))
    .map(a => AGENT_LABELS[a] || a);

  console.log('');
  console.log('Done!');
  console.log('');
  console.log(`  Folder:   ${dirName}/`);
  console.log(`  Enabled:  ${enabledNames}`);
  if (disabledNames.length > 0) {
    console.log(`  Disabled: ${disabledNames.join(', ')}`);
  }
  console.log('');
  console.log('Next steps:');
  console.log(`  1. Edit ${dirName}/rules/_base.md with your project rules`);
  console.log(`  2. Run: aao sync`);
  console.log(`  3. Commit the generated files`);
  console.log('');
}

// ── Update command ─────────────────────────────────────────────────

function runUpdate(projectRoot) {
  const agentsDir = findAgentsDir(projectRoot);

  if (!agentsDir) {
    console.error('No agents directory found. Run "aao init" first.');
    process.exit(1);
  }

  const dirName = path.basename(agentsDir);
  const pkgDir = path.resolve(__dirname, '..');
  const scriptsSource = path.join(pkgDir, 'scripts', 'sync');
  const scriptsDest = path.join(agentsDir, 'scripts', 'sync');

  if (!fs.existsSync(scriptsSource)) {
    console.error('scripts/sync/ not found in package.');
    process.exit(1);
  }

  let updated = 0;
  let skipped = 0;

  for (const file of fs.readdirSync(scriptsSource)) {
    if (!file.endsWith('.sh')) continue;
    const src = path.join(scriptsSource, file);
    const dest = path.join(scriptsDest, file);

    const srcContent = fs.readFileSync(src, 'utf8');
    const destExists = fs.existsSync(dest);
    const destContent = destExists ? fs.readFileSync(dest, 'utf8') : '';

    if (srcContent === destContent) {
      skipped++;
      continue;
    }

    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.copyFileSync(src, dest);
    fs.chmodSync(dest, 0o755);
    updated++;
    console.log(`  Updated: ${dirName}/scripts/sync/${file}`);
  }

  if (updated === 0) {
    console.log('All scripts are up to date.');
  } else {
    console.log(`\nUpdated ${updated} script(s), ${skipped} already current.`);
  }
}

module.exports = { runInit, runUpdate };
