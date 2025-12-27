#!/usr/bin/env node
/**
 * Figma Screenshot Tool
 *
 * Downloads a screenshot of a Figma frame using the Figma API.
 *
 * Prerequisites:
 *   - FIGMA_TOKEN environment variable must be set
 *   - Or pass token via --token option
 *
 * Usage:
 *   node figma-screenshot.js <figma-url> [output-path]
 *   node figma-screenshot.js --file-key=xxx --node-id=xxx [output-path]
 *
 * Examples:
 *   node figma-screenshot.js "https://www.figma.com/design/abc123/MyFile?node-id=1-2" ./figma.png
 *   node figma-screenshot.js --file-key=abc123 --node-id=1:2 ./figma.png
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

function parseArgs(args) {
  const result = {
    url: null,
    fileKey: null,
    nodeId: null,
    output: null,
    token: process.env.FIGMA_TOKEN,
    scale: 2
  };

  for (const arg of args) {
    if (arg.startsWith('--file-key=')) {
      result.fileKey = arg.split('=')[1];
    } else if (arg.startsWith('--node-id=')) {
      result.nodeId = arg.split('=')[1];
    } else if (arg.startsWith('--token=')) {
      result.token = arg.split('=')[1];
    } else if (arg.startsWith('--scale=')) {
      result.scale = parseInt(arg.split('=')[1], 10);
    } else if (arg.startsWith('http')) {
      result.url = arg;
    } else if (!arg.startsWith('--')) {
      result.output = arg;
    }
  }

  // Parse URL if provided
  if (result.url) {
    const parsed = parseFigmaUrl(result.url);
    result.fileKey = parsed.fileKey;
    result.nodeId = parsed.nodeId;
  }

  return result;
}

function parseFigmaUrl(url) {
  // https://www.figma.com/design/{fileKey}/{fileName}?node-id={nodeId}
  const match = url.match(/figma\.com\/(?:design|file)\/([^\/]+)\/[^?]+\?.*node-id=([^&]+)/);
  if (!match) {
    throw new Error('Invalid Figma URL format');
  }
  return {
    fileKey: match[1],
    nodeId: match[2].replace('-', ':')
  };
}

function fetchJson(url, token) {
  return new Promise((resolve, reject) => {
    const options = {
      headers: {
        'X-Figma-Token': token
      }
    };

    https.get(url, options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode !== 200) {
          reject(new Error(`API error ${res.statusCode}: ${data}`));
          return;
        }
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(new Error(`Failed to parse response: ${data}`));
        }
      });
    }).on('error', reject);
  });
}

function downloadImage(url, outputPath) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(outputPath);
    https.get(url, (res) => {
      if (res.statusCode === 302 || res.statusCode === 301) {
        // Follow redirect
        downloadImage(res.headers.location, outputPath).then(resolve).catch(reject);
        return;
      }
      if (res.statusCode !== 200) {
        reject(new Error(`Download failed with status ${res.statusCode}`));
        return;
      }
      res.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve();
      });
    }).on('error', (err) => {
      fs.unlink(outputPath, () => {});
      reject(err);
    });
  });
}

async function getFigmaScreenshot(fileKey, nodeId, token, scale = 2) {
  const url = `https://api.figma.com/v1/images/${fileKey}?ids=${encodeURIComponent(nodeId)}&format=png&scale=${scale}`;
  console.log(`Fetching image URL from Figma API...`);

  const response = await fetchJson(url, token);

  if (response.err) {
    throw new Error(`Figma API error: ${response.err}`);
  }

  const imageUrl = response.images[nodeId];
  if (!imageUrl) {
    throw new Error(`No image URL returned for node ${nodeId}`);
  }

  return imageUrl;
}

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args.includes('--help')) {
    console.log(`
Figma Screenshot Tool

Downloads a screenshot of a Figma frame using the Figma API.

Prerequisites:
  Set FIGMA_TOKEN environment variable or use --token option

Usage:
  node figma-screenshot.js <figma-url> [output-path]
  node figma-screenshot.js --file-key=xxx --node-id=xxx [output-path]

Options:
  --file-key=xxx   Figma file key
  --node-id=xxx    Node ID (use : not -)
  --token=xxx      Figma API token (or set FIGMA_TOKEN env var)
  --scale=N        Image scale (default: 2)

Examples:
  node figma-screenshot.js "https://www.figma.com/design/abc123/MyFile?node-id=1-2" ./figma.png
  node figma-screenshot.js --file-key=abc123 --node-id=1:2 ./figma.png
    `);
    process.exit(0);
  }

  const config = parseArgs(args);

  if (!config.token) {
    console.error('Error: FIGMA_TOKEN not set. Use --token option or set environment variable.');
    process.exit(1);
  }

  if (!config.fileKey || !config.nodeId) {
    console.error('Error: file-key and node-id are required.');
    process.exit(1);
  }

  // Generate default output path
  if (!config.output) {
    config.output = `figma_${config.nodeId.replace(':', '-')}_screenshot.png`;
  }

  console.log(`File Key: ${config.fileKey}`);
  console.log(`Node ID: ${config.nodeId}`);
  console.log(`Scale: ${config.scale}x`);
  console.log(`Output: ${config.output}`);

  try {
    const imageUrl = await getFigmaScreenshot(config.fileKey, config.nodeId, config.token, config.scale);
    console.log(`Downloading image...`);
    await downloadImage(imageUrl, config.output);
    console.log(`Screenshot saved: ${config.output}`);
  } catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
  }
}

main();
