#!/usr/bin/env node

/**
 * file: render-graphs.js
 * description: Graphviz 图表渲染工具 · 从 SKILL.md 提取 dot 代码块并渲染为 SVG
 * description-en: Graphviz diagram renderer · Extract dot blocks from SKILL.md and render to SVG
 * author: YanYuCloudCube Team <admin@0379.email>
 * version: v1.0.0
 * created: 2026-04-29
 * updated: 2026-04-29
 * status: active
 * tags: [util],[graphviz],[svg],[skill-tool]
 *
 * copyright: YanYuCloudCube Team
 * license: MIT
 *
 * brief: 渲染 Graphviz 图表为 SVG 文件，支持技能文档可视化
 * brief-en: Render Graphviz diagrams to SVG files, support skill document visualization
 *
 * details:
 * - 从 SKILL.md 中提取所有 ```dot 代码块
 * - 使用 graphviz (dot) 命令行工具渲染为 SVG
 * - 支持单独渲染或合并所有图表
 * - 帮助人类伙伴可视化流程图
 *
 * details-en:
 * - Extract all ```dot blocks from SKILL.md
 * - Render to SVG using graphviz (dot) CLI tool
 * - Support individual or combined rendering
 * - Help human partner visualize process flows
 *
 * usage:
 *   ./render-graphs.js <skill-directory>           # 单独渲染每个图表
 *   ./render-graphs.js <skill-directory> --combine # 合并所有图表为一个
 *
 * dependencies: Node.js fs/path/child_process, graphviz (dot)
 * exports: extractDotBlocks, extractGraphBody, renderGraphs
 * notes: 需要系统安装 graphviz (dot) 工具 / Requires graphviz (dot) installed on system
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

function extractDotBlocks(markdown) {
  const blocks = [];
  const regex = /```dot\n([\s\S]*?)```/g;
  let match;

  while ((match = regex.exec(markdown)) !== null) {
    const content = match[1].trim();

    // Extract digraph name
    const nameMatch = content.match(/digraph\s+(\w+)/);
    const name = nameMatch ? nameMatch[1] : `graph_${blocks.length + 1}`;

    blocks.push({ name, content });
  }

  return blocks;
}

function extractGraphBody(dotContent) {
  // Extract just the body (nodes and edges) from a digraph
  const match = dotContent.match(/digraph\s+\w+\s*\{([\s\S]*)\}/);
  if (!match) return '';

  let body = match[1];

  // Remove rankdir (we'll set it once at the top level)
  body = body.replace(/^\s*rankdir\s*=\s*\w+\s*;?\s*$/gm, '');

  return body.trim();
}

function combineGraphs(blocks, skillName) {
  const bodies = blocks.map((block, i) => {
    const body = extractGraphBody(block.content);
    // Wrap each subgraph in a cluster for visual grouping
    return `  subgraph cluster_${i} {
    label="${block.name}";
    ${body.split('\n').map(line => '  ' + line).join('\n')}
  }`;
  });

  return `digraph ${skillName}_combined {
  rankdir=TB;
  compound=true;
  newrank=true;

${bodies.join('\n\n')}
}`;
}

function renderToSvg(dotContent) {
  try {
    return execSync('dot -Tsvg', {
      input: dotContent,
      encoding: 'utf-8',
      maxBuffer: 10 * 1024 * 1024
    });
  } catch (err) {
    console.error('Error running dot:', err.message);
    if (err.stderr) console.error(err.stderr.toString());
    return null;
  }
}

function main() {
  const args = process.argv.slice(2);
  const combine = args.includes('--combine');
  const skillDirArg = args.find(a => !a.startsWith('--'));

  if (!skillDirArg) {
    console.error('Usage: render-graphs.js <skill-directory> [--combine]');
    console.error('');
    console.error('Options:');
    console.error('  --combine    Combine all diagrams into one SVG');
    console.error('');
    console.error('Example:');
    console.error('  ./render-graphs.js ../subagent-driven-development');
    console.error('  ./render-graphs.js ../subagent-driven-development --combine');
    process.exit(1);
  }

  const skillDir = path.resolve(skillDirArg);
  const skillFile = path.join(skillDir, 'SKILL.md');
  const skillName = path.basename(skillDir).replace(/-/g, '_');

  if (!fs.existsSync(skillFile)) {
    console.error(`Error: ${skillFile} not found`);
    process.exit(1);
  }

  // Check if dot is available
  try {
    execSync('which dot', { encoding: 'utf-8' });
  } catch {
    console.error('Error: graphviz (dot) not found. Install with:');
    console.error('  brew install graphviz    # macOS');
    console.error('  apt install graphviz     # Linux');
    process.exit(1);
  }

  const markdown = fs.readFileSync(skillFile, 'utf-8');
  const blocks = extractDotBlocks(markdown);

  if (blocks.length === 0) {
    console.log('No ```dot blocks found in', skillFile);
    process.exit(0);
  }

  console.log(`Found ${blocks.length} diagram(s) in ${path.basename(skillDir)}/SKILL.md`);

  const outputDir = path.join(skillDir, 'diagrams');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir);
  }

  if (combine) {
    // Combine all graphs into one
    const combined = combineGraphs(blocks, skillName);
    const svg = renderToSvg(combined);
    if (svg) {
      const outputPath = path.join(outputDir, `${skillName}_combined.svg`);
      fs.writeFileSync(outputPath, svg);
      console.log(`  Rendered: ${skillName}_combined.svg`);

      // Also write the dot source for debugging
      const dotPath = path.join(outputDir, `${skillName}_combined.dot`);
      fs.writeFileSync(dotPath, combined);
      console.log(`  Source: ${skillName}_combined.dot`);
    } else {
      console.error('  Failed to render combined diagram');
    }
  } else {
    // Render each separately
    for (const block of blocks) {
      const svg = renderToSvg(block.content);
      if (svg) {
        const outputPath = path.join(outputDir, `${block.name}.svg`);
        fs.writeFileSync(outputPath, svg);
        console.log(`  Rendered: ${block.name}.svg`);
      } else {
        console.error(`  Failed: ${block.name}`);
      }
    }
  }

  console.log(`\nOutput: ${outputDir}/`);
}

main();
