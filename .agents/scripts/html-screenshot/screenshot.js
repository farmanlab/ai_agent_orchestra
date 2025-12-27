#!/usr/bin/env node
/**
 * HTML Screenshot Tool
 *
 * Usage:
 *   node screenshot.js <html-file-path> [output-path] [--width=375] [--height=812]
 *
 * Examples:
 *   node screenshot.js ./top.html
 *   node screenshot.js ./top.html ./screenshot.png --width=375 --height=812
 */

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

async function takeScreenshot(htmlPath, outputPath, options = {}) {
  const { width = 375, height = 812, fullPage = true } = options;

  // Resolve absolute path
  const absoluteHtmlPath = path.resolve(htmlPath);

  if (!fs.existsSync(absoluteHtmlPath)) {
    console.error(`Error: File not found: ${absoluteHtmlPath}`);
    process.exit(1);
  }

  // Default output path
  if (!outputPath) {
    const baseName = path.basename(htmlPath, '.html');
    outputPath = path.join(path.dirname(absoluteHtmlPath), `${baseName}_screenshot.png`);
  }

  console.log(`Taking screenshot of: ${absoluteHtmlPath}`);
  console.log(`Viewport: ${width}x${height}`);
  console.log(`Output: ${outputPath}`);

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  try {
    const page = await browser.newPage();

    // Set viewport to match Figma design (iPhone size)
    await page.setViewport({
      width: parseInt(width),
      height: parseInt(height),
      deviceScaleFactor: 2 // Retina quality
    });

    // Navigate to local HTML file
    await page.goto(`file://${absoluteHtmlPath}`, {
      waitUntil: 'networkidle0',
      timeout: 30000
    });

    // Wait for fonts and images to load
    await page.evaluate(() => document.fonts.ready);
    await new Promise(resolve => setTimeout(resolve, 500));

    // Disable and hide mapping overlay if present and option is set
    if (options.noMapping) {
      const mappingDisabled = await page.evaluate(() => {
        const toggleBtn = document.getElementById('mapping-toggle');
        const tooltip = document.getElementById('mapping-tooltip');

        // Click to disable if enabled
        if (toggleBtn && toggleBtn.innerHTML.includes('Mapping') && !toggleBtn.innerHTML.includes('OFF')) {
          toggleBtn.click();
        }

        // Hide the toggle button completely
        if (toggleBtn) {
          toggleBtn.style.display = 'none';
        }

        // Hide tooltip if present
        if (tooltip) {
          tooltip.style.display = 'none';
        }

        return !!toggleBtn;
      });
      if (mappingDisabled) {
        console.log('Mapping overlay disabled and hidden');
        await new Promise(resolve => setTimeout(resolve, 200));
      }
    }

    // Take screenshot
    await page.screenshot({
      path: outputPath,
      fullPage: fullPage,
      type: 'png'
    });

    console.log(`Screenshot saved: ${outputPath}`);
    return outputPath;

  } finally {
    await browser.close();
  }
}

// Parse command line arguments
function parseArgs(args) {
  const options = {
    width: 375,
    height: 812,
    fullPage: true,
    noMapping: true  // Default: disable mapping overlay
  };

  const positional = [];

  for (const arg of args) {
    if (arg.startsWith('--width=')) {
      options.width = parseInt(arg.split('=')[1]);
    } else if (arg.startsWith('--height=')) {
      options.height = parseInt(arg.split('=')[1]);
    } else if (arg === '--no-full-page') {
      options.fullPage = false;
    } else if (arg === '--no-mapping') {
      options.noMapping = true;
    } else if (arg === '--with-mapping') {
      options.noMapping = false;
    } else if (!arg.startsWith('--')) {
      positional.push(arg);
    }
  }

  return { positional, options };
}

// Main
const { positional, options } = parseArgs(process.argv.slice(2));

if (positional.length === 0) {
  console.log(`
HTML Screenshot Tool

Usage:
  node screenshot.js <html-file-path> [output-path] [options]

Options:
  --width=N       Viewport width (default: 375)
  --height=N      Viewport height (default: 812)
  --no-full-page  Capture only viewport, not full page

Examples:
  node screenshot.js ./top.html
  node screenshot.js ./top.html ./output.png --width=375
  `);
  process.exit(0);
}

takeScreenshot(positional[0], positional[1], options)
  .catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
  });
