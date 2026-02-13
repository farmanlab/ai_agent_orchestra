#!/usr/bin/env node

'use strict';

const { execFileSync } = require('child_process');
const path = require('path');
const { COMMANDS, printHelp, printVersion } = require('../lib/commands');
const { findProjectRoot, findAgentsDir } = require('../lib/project');
const { runInit, runUpdate } = require('../lib/init');

// ── Argument parsing ───────────────────────────────────────────────

const args = process.argv.slice(2);
const flags = { verbose: false, dryRun: false, dir: null, agents: null };
const positional = [];

for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  switch (arg) {
    case '-h': case '--help':
      printHelp();
      process.exit(0);
    case '-v': case '--version':
      printVersion();
      process.exit(0);
    case '--verbose':
      flags.verbose = true;
      break;
    case '--dry-run':
      flags.dryRun = true;
      break;
    case '--dir':
      flags.dir = args[++i];
      break;
    case '--agents':
      flags.agents = args[++i];
      break;
    default:
      if (arg.startsWith('--dir=')) {
        flags.dir = arg.split('=')[1];
      } else if (arg.startsWith('--agents=')) {
        flags.agents = arg.split('=')[1];
      } else {
        positional.push(arg);
      }
  }
}

const command = positional[0];
const subCommand = positional[1];

if (!command) {
  printHelp();
  process.exit(0);
}

// ── Command dispatch ───────────────────────────────────────────────

const projectRoot = findProjectRoot(process.cwd());

if (!projectRoot) {
  console.error('Error: Not inside a git repository.');
  console.error('Run "git init" first, then try again.');
  process.exit(1);
}

// Node-handled commands
if (command === 'init') {
  runInit(projectRoot, flags).catch(err => {
    console.error(err.message);
    process.exit(1);
  });
} else if (command === 'update') {
  runUpdate(projectRoot);
} else {
  // Shell-delegated commands
  const agentsDir = findAgentsDir(projectRoot);
  if (!agentsDir) {
    console.error(`Error: No agents directory found in ${projectRoot}`);
    console.error('Run "aao init" first.');
    process.exit(1);
  }

  const syncScript = path.join(agentsDir, 'scripts', 'sync', 'sync.sh');

  // Map CLI commands to sync.sh arguments
  let shellArgs = [];

  if (flags.verbose) shellArgs.push('--verbose');
  if (flags.dryRun) shellArgs.push('--dry-run');

  switch (command) {
    case 'sync':
      shellArgs.push(subCommand || 'all');
      break;
    case 'reverse':
      if (subCommand) {
        shellArgs.push(`reverse-${subCommand}`);
      } else {
        shellArgs.push('reverse');
      }
      break;
    case 'validate':
    case 'check-size':
    case 'check-quality':
    case 'plugins':
    case 'clean':
    case 'install-hooks':
      shellArgs.push(command);
      break;
    case 'prune':
      if (!subCommand) {
        console.error('Error: prune requires a path argument.');
        console.error('Example: aao prune rules/foo.md');
        process.exit(1);
      }
      shellArgs.push('prune', subCommand);
      break;
    default:
      console.error(`Unknown command: ${command}`);
      console.error('Run "aao --help" for usage.');
      process.exit(1);
  }

  try {
    execFileSync(syncScript, shellArgs, {
      stdio: 'inherit',
      cwd: projectRoot,
    });
  } catch (err) {
    process.exit(err.status || 1);
  }
}
