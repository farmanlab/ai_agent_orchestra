/**
 * {{PROJECT_NAME}} - Content & Interaction Mapping Overlay
 * Generated: {{GENERATED_DATE}}
 *
 * 機能:
 * - データタイプ可視化 (static/dynamic/dynamic_list/local/asset)
 * - インタラクション可視化 (navigate/modal/disabled/loading)
 * - リアルタイム状態表示 (hover/active/focus/selected)
 * - フィルタリング機能
 */

// ========================================
// マッピングデータ (spec.md「コンテンツ分析」セクションから生成)
// ========================================
const MAPPING_DATA = {
  // フォーマット:
  // 'data-figma-node="NODE_ID"': {
  //   type: 'static|dynamic|dynamic_list|local|asset',
  //   endpoint: 'GET /api/...',  // dynamic/dynamic_list の場合
  //   apiField: 'response.field',
  //   label: '日本語ラベル'
  // },

  {{MAPPING_ENTRIES}}
};

// ========================================
// タイプ設定
// ========================================

// タイプ別の色設定
const TYPE_COLORS = {
  // データタイプ
  static: { bg: '#e0e0e0', text: '#333', border: '#999' },
  dynamic: { bg: '#d4edda', text: '#155724', border: '#28a745' },
  dynamic_list: { bg: '#cce5ff', text: '#004085', border: '#007bff' },
  local: { bg: '#e8daef', text: '#4a235a', border: '#8e44ad' },
  asset: { bg: '#fff3cd', text: '#856404', border: '#ffc107' },
  // インタラクションタイプ
  navigate: { bg: '#ffe0ec', text: '#8b0a50', border: '#de30ca' },
  modal: { bg: '#ffeeba', text: '#856404', border: '#ff9800' },
  disabled: { bg: '#f5f5f5', text: '#999', border: '#ccc' },
  loading: { bg: '#e3f2fd', text: '#1565c0', border: '#2196f3' }
};

// タイプ別のラベル
const TYPE_LABELS = {
  static: '静的',
  dynamic: '動的',
  dynamic_list: '動的リスト',
  local: 'ローカル',
  asset: 'アセット',
  navigate: '画面遷移',
  modal: 'モーダル',
  disabled: '無効',
  loading: '読込中'
};

// ========================================
// ユーティリティ関数
// ========================================

// ツールチップ要素を作成
function createTooltip() {
  const tooltip = document.createElement('div');
  tooltip.id = 'mapping-tooltip';
  tooltip.style.cssText = `
    position: fixed;
    z-index: 10000;
    background: white;
    border: 2px solid #333;
    border-radius: 8px;
    padding: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    font-family: "Hiragino Sans", sans-serif;
    font-size: 12px;
    max-width: 400px;
    display: none;
    pointer-events: none;
  `;
  document.body.appendChild(tooltip);
  return tooltip;
}

// マッピング情報を取得
function getMappingInfo(element) {
  const attrs = element.attributes;
  for (let i = 0; i < attrs.length; i++) {
    const attrName = attrs[i].name;
    const attrValue = attrs[i].value;
    const key = `${attrName}="${attrValue}"`;
    if (MAPPING_DATA[key]) {
      return { attr: key, ...MAPPING_DATA[key] };
    }
  }
  return null;
}

// インタラクション情報を取得（リアルタイム状態付き）
function getInteractionInfo(element) {
  const interaction = element.dataset.figmaInteraction;
  const navigate = element.dataset.figmaNavigate;
  const states = element.dataset.figmaStates;
  const state = element.dataset.state;

  if (!interaction && !navigate && !states) {
    return null;
  }

  let type = 'navigate';
  let label = '';
  let target = '';

  if (interaction) {
    const parts = interaction.split(':');
    const action = parts[1];
    target = parts.slice(2).join(':');

    if (action === 'show-modal') {
      type = 'modal';
      label = `モーダル表示: ${target}`;
    } else if (action === 'navigate') {
      type = 'navigate';
      label = `画面遷移: ${target}`;
    }
  } else if (navigate) {
    type = 'navigate';
    label = `画面遷移: ${navigate}`;
    target = navigate;
  }

  // 状態による上書き
  if (state === 'disabled') {
    type = 'disabled';
  } else if (state === 'loading') {
    type = 'loading';
  }

  // リアルタイム状態を検出
  const activeStates = detectActiveStates(element);

  return {
    type,
    label,
    target,
    states: states ? states.split(',') : [],
    currentState: state || 'default',
    activeStates,
    interaction
  };
}

// 要素のリアルタイム状態を検出
function detectActiveStates(element) {
  const activeStates = [];

  if (element.matches(':hover')) activeStates.push('hover');
  if (element.matches(':active')) activeStates.push('active');
  if (element.matches(':focus') || element.matches(':focus-within')) activeStates.push('focus');
  if (element.dataset.state) activeStates.push(element.dataset.state);
  if (element.classList.contains('active')) activeStates.push('selected');
  if (element.getAttribute('aria-current')) activeStates.push('current');
  if (element.getAttribute('aria-disabled') === 'true') activeStates.push('disabled');
  if (element.getAttribute('aria-pressed') === 'true') activeStates.push('pressed');

  return activeStates;
}

// ========================================
// ツールチップ描画
// ========================================

// データタイプ用ツールチップ
function renderTooltipContent(info) {
  const colors = TYPE_COLORS[info.type] || TYPE_COLORS.static;
  const typeLabel = TYPE_LABELS[info.type] || info.type;

  let html = `
    <div style="margin-bottom: 8px;">
      <span style="
        display: inline-block;
        padding: 2px 8px;
        border-radius: 4px;
        background: ${colors.bg};
        color: ${colors.text};
        border: 1px solid ${colors.border};
        font-weight: bold;
      ">${typeLabel}</span>
      <span style="margin-left: 8px; color: #666;">${info.label}</span>
    </div>
    <div style="font-size: 11px; color: #888; margin-bottom: 4px;">
      ${info.attr}
    </div>
  `;

  if (info.endpoint) {
    html += `
      <div style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #eee;">
        <div style="font-weight: bold; color: #333; margin-bottom: 4px;">Endpoint:</div>
        <code style="display: block; background: #e8f4fd; padding: 4px 8px; border-radius: 4px; font-family: monospace; font-size: 11px; color: #0066cc;">${info.endpoint}</code>
      </div>
    `;
  } else if (info.type === 'dynamic' || info.type === 'dynamic_list') {
    html += `<div style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #eee; color: #999; font-style: italic;">API未確定</div>`;
  }

  if (info.apiField) {
    html += `
      <div style="margin-top: 8px;">
        <div style="font-weight: bold; color: #333; margin-bottom: 4px;">API Field:</div>
        <code style="display: block; background: #f5f5f5; padding: 4px 8px; border-radius: 4px; font-family: monospace; font-size: 11px;">${info.apiField}</code>
      </div>
    `;
  }

  return html;
}

// インタラクション用ツールチップ（データタイプ情報も含む）
function renderInteractionTooltipContent(info, mappingInfo = null) {
  let html = '';

  // マッピング情報がある場合は先に表示
  if (mappingInfo) {
    const mappingColors = TYPE_COLORS[mappingInfo.type] || TYPE_COLORS.static;
    const mappingTypeLabel = TYPE_LABELS[mappingInfo.type] || mappingInfo.type;
    html += `
      <div style="margin-bottom: 8px; padding-bottom: 8px; border-bottom: 1px solid #ddd;">
        <div style="font-size: 10px; color: #888; margin-bottom: 4px;">データタイプ</div>
        <span style="display: inline-block; padding: 2px 8px; border-radius: 4px; background: ${mappingColors.bg}; color: ${mappingColors.text}; border: 1px solid ${mappingColors.border}; font-weight: bold; font-size: 11px;">${mappingTypeLabel}</span>
        <span style="margin-left: 8px; color: #666; font-size: 11px;">${mappingInfo.label}</span>
      </div>
    `;
  }

  // インタラクション情報
  const colors = TYPE_COLORS[info.type] || TYPE_COLORS.navigate;
  const typeLabel = TYPE_LABELS[info.type] || info.type;

  html += `
    <div style="margin-bottom: 8px;">
      <div style="font-size: 10px; color: #888; margin-bottom: 4px;">インタラクション</div>
      <span style="display: inline-block; padding: 2px 8px; border-radius: 4px; background: ${colors.bg}; color: ${colors.text}; border: 1px solid ${colors.border}; font-weight: bold;">${typeLabel}</span>
    </div>
  `;

  // 遷移先またはモーダル対象
  if (info.target) {
    html += `
      <div style="margin-bottom: 8px;">
        <div style="font-weight: bold; color: #333; margin-bottom: 4px;">${info.type === 'modal' ? 'モーダルID:' : '遷移先:'}</div>
        <code style="display: block; background: ${info.type === 'modal' ? '#fff3e0' : '#fce4ec'}; padding: 6px 10px; border-radius: 4px; font-family: monospace; font-size: 12px; color: ${info.type === 'modal' ? '#e65100' : '#c2185b'};">${info.target}</code>
      </div>
    `;
  }

  // インタラクション詳細
  if (info.interaction) {
    html += `
      <div style="margin-bottom: 8px;">
        <div style="font-weight: bold; color: #333; margin-bottom: 4px;">トリガー:</div>
        <code style="display: block; background: #f5f5f5; padding: 4px 8px; border-radius: 4px; font-family: monospace; font-size: 11px;">${info.interaction}</code>
      </div>
    `;
  }

  // UI状態一覧（リアルタイム状態付き）
  if (info.states && info.states.length > 0) {
    html += `
      <div style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #eee;">
        <div style="font-weight: bold; color: #333; margin-bottom: 4px;">UI状態:</div>
        <div style="display: flex; flex-wrap: wrap; gap: 4px;">
          ${info.states.map(state => {
            const isActive = info.activeStates && info.activeStates.includes(state);
            const isCurrent = state === info.currentState;
            let bgColor = '#e0e0e0', textColor = '#666', icon = '';

            if (isActive) { bgColor = '#ff5722'; textColor = 'white'; icon = ' ●'; }
            else if (isCurrent) { bgColor = '#4caf50'; textColor = 'white'; icon = ' ✓'; }

            return `<span style="padding: 2px 6px; border-radius: 3px; font-size: 10px; background: ${bgColor}; color: ${textColor}; font-weight: ${isActive || isCurrent ? 'bold' : 'normal'};">${state}${icon}</span>`;
          }).join('')}
        </div>
      </div>
    `;
  }

  return html;
}

// ========================================
// メイン初期化
// ========================================
function initMappingOverlay() {
  const tooltip = createTooltip();
  let isEnabled = true;
  let activeFilters = new Set();
  let currentHoveredElement = null;
  let stateUpdateInterval = null;

  // トグルボタン
  const toggleBtn = document.createElement('button');
  toggleBtn.id = 'mapping-toggle';
  toggleBtn.innerHTML = 'Mapping';
  toggleBtn.style.cssText = `
    position: fixed; top: 10px; right: 10px; z-index: 10001;
    padding: 8px 16px; background: #0070e0; color: white; border: none;
    border-radius: 8px; font-family: "Hiragino Sans", sans-serif;
    font-size: 14px; font-weight: bold; cursor: pointer;
    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
  `;
  document.body.appendChild(toggleBtn);

  // フィルターバッジ生成
  function createFilterBadge(type, label, colors) {
    return `<span class="filter-badge" data-filter-type="${type}" style="
      padding: 2px 6px; border-radius: 4px; background: ${colors.bg};
      color: ${colors.text}; border: 2px solid ${colors.border};
      font-size: 10px; cursor: pointer; user-select: none; transition: all 0.15s ease;
    ">${label}</span>`;
  }

  // 凡例
  const legend = document.createElement('div');
  legend.id = 'mapping-legend';
  legend.innerHTML = `
    <div style="font-weight: bold; margin-bottom: 8px;">
      凡例
      <span id="filter-reset" style="font-size: 10px; color: #999; font-weight: normal; cursor: pointer; margin-left: 4px; display: none;">[リセット]</span>
    </div>
    <div style="margin-bottom: 8px;">
      <div style="font-size: 10px; color: #666; margin-bottom: 4px;">データタイプ</div>
      <div style="display: flex; flex-wrap: wrap; gap: 4px;">
        ${createFilterBadge('static', '静的', TYPE_COLORS.static)}
        ${createFilterBadge('dynamic', '動的', TYPE_COLORS.dynamic)}
        ${createFilterBadge('dynamic_list', 'リスト', TYPE_COLORS.dynamic_list)}
      </div>
    </div>
    <div style="margin-bottom: 8px;">
      <div style="font-size: 10px; color: #666; margin-bottom: 4px;">インタラクション</div>
      <div style="display: flex; flex-wrap: wrap; gap: 4px;">
        ${createFilterBadge('navigate', '遷移', TYPE_COLORS.navigate)}
        ${createFilterBadge('modal', 'モーダル', TYPE_COLORS.modal)}
        ${createFilterBadge('disabled', '無効', TYPE_COLORS.disabled)}
        ${createFilterBadge('loading', '読込中', TYPE_COLORS.loading)}
      </div>
    </div>
    <div style="border-top: 1px solid #eee; padding-top: 8px;">
      <div style="font-size: 10px; color: #666; margin-bottom: 4px;">リアルタイム状態</div>
      <div style="display: flex; flex-wrap: wrap; gap: 4px;">
        <span style="padding: 2px 6px; border-radius: 4px; background: #ff5722; color: white; font-size: 10px;">active ●</span>
        <span style="padding: 2px 6px; border-radius: 4px; background: #4caf50; color: white; font-size: 10px;">default ✓</span>
      </div>
    </div>
    <div id="filter-count" style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #eee; font-size: 10px; color: #666; display: none;"></div>
  `;
  legend.style.cssText = `
    position: fixed; top: 50px; right: 10px; z-index: 10001;
    padding: 12px; background: white; border: 1px solid #ccc;
    border-radius: 8px; font-family: "Hiragino Sans", sans-serif;
    font-size: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); max-width: 180px;
  `;
  document.body.appendChild(legend);

  // ========================================
  // フィルタリング機能
  // ========================================

  function elementMatchesFilter(el) {
    const mappingKey = el.dataset.mappingKey;
    const mappingInfo = mappingKey ? MAPPING_DATA[mappingKey] : null;
    const interactionInfo = getInteractionInfo(el);

    if (mappingInfo && activeFilters.has(mappingInfo.type)) return true;
    if (interactionInfo && activeFilters.has(interactionInfo.type)) return true;
    return false;
  }

  function hasMatchingDescendant(el) {
    const descendants = el.querySelectorAll('[data-mapping-enabled], [data-interaction-enabled]');
    for (const desc of descendants) {
      if (elementMatchesFilter(desc)) return true;
    }
    return false;
  }

  function applyFilters() {
    const filterCount = document.getElementById('filter-count');
    const filterReset = document.getElementById('filter-reset');
    const allElements = document.querySelectorAll('[data-mapping-enabled], [data-interaction-enabled]');
    let matchedCount = 0;

    if (activeFilters.size === 0) {
      allElements.forEach(el => {
        el.style.opacity = '';
        el.removeAttribute('data-filter-dimmed');
      });
      filterCount.style.display = 'none';
      filterReset.style.display = 'none';
    } else {
      const matchedElements = new Set();
      const parentOfMatched = new Set();

      allElements.forEach(el => {
        if (elementMatchesFilter(el)) {
          matchedElements.add(el);
          matchedCount++;
          let parent = el.parentElement;
          while (parent) {
            if (parent.dataset.mappingEnabled || parent.dataset.interactionEnabled) {
              parentOfMatched.add(parent);
            }
            parent = parent.parentElement;
          }
        }
      });

      allElements.forEach(el => {
        if (matchedElements.has(el) || parentOfMatched.has(el) || hasMatchingDescendant(el)) {
          el.style.opacity = '';
          el.removeAttribute('data-filter-dimmed');
        } else {
          el.style.opacity = '0.15';
          el.setAttribute('data-filter-dimmed', 'true');
        }
      });

      filterCount.textContent = `${matchedCount} 件表示中`;
      filterCount.style.display = 'block';
      filterReset.style.display = 'inline';
    }

    // バッジスタイル更新
    document.querySelectorAll('.filter-badge').forEach(badge => {
      const type = badge.dataset.filterType;
      if (activeFilters.has(type)) {
        badge.style.boxShadow = '0 0 0 2px #333';
        badge.style.transform = 'scale(1.1)';
        badge.style.fontWeight = 'bold';
        badge.style.opacity = '';
      } else if (activeFilters.size > 0) {
        badge.style.boxShadow = '';
        badge.style.transform = '';
        badge.style.fontWeight = '';
        badge.style.opacity = '0.5';
      } else {
        badge.style.boxShadow = '';
        badge.style.transform = '';
        badge.style.fontWeight = '';
        badge.style.opacity = '';
      }
    });
  }

  // フィルターバッジクリック
  legend.addEventListener('click', (e) => {
    const badge = e.target.closest('.filter-badge');
    if (badge) {
      const type = badge.dataset.filterType;
      if (activeFilters.has(type)) activeFilters.delete(type);
      else activeFilters.add(type);
      applyFilters();
    }
    if (e.target.id === 'filter-reset') {
      activeFilters.clear();
      applyFilters();
    }
  });

  // ========================================
  // トグル処理
  // ========================================

  toggleBtn.addEventListener('click', () => {
    isEnabled = !isEnabled;
    toggleBtn.style.background = isEnabled ? '#0070e0' : '#999';
    toggleBtn.innerHTML = isEnabled ? 'Mapping' : 'OFF';
    legend.style.display = isEnabled ? 'block' : 'none';
    if (!isEnabled) {
      tooltip.style.display = 'none';
      removeHighlights();
      activeFilters.clear();
    } else {
      highlightElements();
      applyFilters();
    }
  });

  // ========================================
  // ハイライト処理
  // ========================================

  function highlightElements() {
    // MAPPING_DATAに基づくハイライト
    Object.keys(MAPPING_DATA).forEach(key => {
      const match = key.match(/^([^=]+)="([^"]+)"$/);
      if (match) {
        const [, attrName, attrValue] = match;
        document.querySelectorAll(`[${attrName}="${attrValue}"]`).forEach(el => {
          const info = MAPPING_DATA[key];
          if (info) {
            const colors = TYPE_COLORS[info.type] || TYPE_COLORS.static;
            el.style.outline = `2px dashed ${colors.border}`;
            el.style.outlineOffset = '2px';
            el.dataset.mappingEnabled = 'true';
            el.dataset.mappingKey = key;
          }
        });
      }
    });

    // インタラクション要素のハイライト
    document.querySelectorAll('[data-figma-interaction]').forEach(el => {
      const interactionInfo = getInteractionInfo(el);
      if (interactionInfo) {
        const colors = TYPE_COLORS[interactionInfo.type] || TYPE_COLORS.navigate;
        if (el.dataset.mappingEnabled) {
          el.style.boxShadow = `inset 0 0 0 3px ${colors.border}`;
        } else {
          el.style.outline = `3px solid ${colors.border}`;
          el.style.outlineOffset = '-1px';
        }
        el.dataset.interactionEnabled = 'true';
      }
    });
  }

  function removeHighlights() {
    document.querySelectorAll('[data-mapping-enabled]').forEach(el => {
      el.style.outline = '';
      el.style.outlineOffset = '';
      delete el.dataset.mappingEnabled;
      delete el.dataset.mappingKey;
    });
    document.querySelectorAll('[data-interaction-enabled]').forEach(el => {
      el.style.outline = '';
      el.style.outlineOffset = '';
      el.style.boxShadow = '';
      delete el.dataset.interactionEnabled;
    });
  }

  // ========================================
  // ツールチップ処理（リアルタイム更新）
  // ========================================

  function updateTooltipPosition(target) {
    const rect = target.getBoundingClientRect();
    let top = rect.bottom + 10;
    let left = rect.left;
    if (top + tooltip.offsetHeight > window.innerHeight) top = rect.top - tooltip.offsetHeight - 10;
    if (left + tooltip.offsetWidth > window.innerWidth) left = window.innerWidth - tooltip.offsetWidth - 10;
    tooltip.style.top = `${Math.max(10, top)}px`;
    tooltip.style.left = `${Math.max(10, left)}px`;
  }

  function updateTooltipContent(target) {
    const hasInteraction = target.dataset.interactionEnabled;
    const hasMapping = target.dataset.mappingKey;

    if (hasInteraction) {
      const interactionInfo = getInteractionInfo(target);
      const mappingInfo = hasMapping ? { attr: hasMapping, ...MAPPING_DATA[hasMapping] } : null;
      if (interactionInfo) tooltip.innerHTML = renderInteractionTooltipContent(interactionInfo, mappingInfo);
    } else if (hasMapping) {
      const info = { attr: hasMapping, ...MAPPING_DATA[hasMapping] };
      tooltip.innerHTML = renderTooltipContent(info);
    }
  }

  // マウスイベント
  document.addEventListener('mouseover', (e) => {
    if (!isEnabled) return;
    let target = e.target;
    while (target && target !== document.body) {
      if (target.dataset.interactionEnabled || target.dataset.mappingKey) {
        currentHoveredElement = target;
        updateTooltipContent(target);
        tooltip.style.display = 'block';
        updateTooltipPosition(target);

        if (stateUpdateInterval) cancelAnimationFrame(stateUpdateInterval);
        function updateLoop() {
          if (currentHoveredElement === target) {
            updateTooltipContent(target);
            stateUpdateInterval = requestAnimationFrame(updateLoop);
          }
        }
        stateUpdateInterval = requestAnimationFrame(updateLoop);
        return;
      }
      target = target.parentElement;
    }
  });

  document.addEventListener('mouseout', (e) => {
    let target = e.target;
    while (target && target !== document.body) {
      if (target.dataset.mappingKey || target.dataset.interactionEnabled) {
        if (stateUpdateInterval) { cancelAnimationFrame(stateUpdateInterval); stateUpdateInterval = null; }
        currentHoveredElement = null;
        tooltip.style.display = 'none';
        return;
      }
      target = target.parentElement;
    }
  });

  document.addEventListener('mousedown', () => { if (currentHoveredElement) updateTooltipContent(currentHoveredElement); });
  document.addEventListener('mouseup', () => { if (currentHoveredElement) updateTooltipContent(currentHoveredElement); });

  // 初期化
  highlightElements();
  console.log('Mapping Overlay initialized.');
  console.log('- データタイプ: 破線枠');
  console.log('- インタラクション: 実線枠');
  console.log('- 凡例クリックでフィルタリング');
}

// DOM読み込み完了後に初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initMappingOverlay);
} else {
  initMappingOverlay();
}
