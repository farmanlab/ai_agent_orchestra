/**
 * {{PROJECT_NAME}} HTML to API Mapping Overlay
 * Generated: {{GENERATED_DATE}}
 *
 * マウスオーバーでマッピング情報を表示するオーバーレイスクリプト
 */

// マッピングデータ（content_analysis.md + api_mapping.md から生成）
const MAPPING_DATA = {
  // === {{SECTION_NAME}} ===
  // 以下のフォーマットでエントリを追加:
  //
  // 'data-figma-content-{attribute-name}': {
  //   type: 'static',           // static | dynamic | dynamic_list | local | asset
  //   endpoint: null,           // dynamic/dynamic_list の場合: 'GET /api/endpoint/{id}'
  //   apiField: null,           // APIフィールドパス: 'response.field.path'
  //   transform: null,          // 変換ロジック: 'formatDate(value)' など
  //   label: '日本語ラベル'      // ツールチップに表示するラベル
  // },

  // --- 静的要素 (static) ---
  // 固定テキスト、ラベルなど
  /*
  'data-figma-content-nav-title-static': {
    type: 'static',
    endpoint: null,
    apiField: null,
    transform: null,
    label: 'ナビゲーションタイトル'
  },
  */

  // --- 動的要素 (dynamic) - API ---
  // APIから取得するデータ
  /*
  'data-figma-content-user-name-dynamic': {
    type: 'dynamic',
    endpoint: 'GET /api/users/{id}',
    apiField: 'user.display_name',
    transform: 'そのまま表示',
    label: 'ユーザー名'
  },
  */

  // --- 動的リスト (dynamic_list) - API ---
  // 配列データのリスト
  /*
  'data-figma-content-item-list': {
    type: 'dynamic_list',
    endpoint: 'GET /api/items',
    apiField: 'items[]',
    transform: 'リストレンダリング',
    label: 'アイテム一覧'
  },
  */

  // --- ローカルステート (local) ---
  // useStateなどで管理
  /*
  'data-figma-content-toggle-switch': {
    type: 'local',
    endpoint: null,
    apiField: null,
    transform: 'useState で管理',
    label: 'トグルスイッチ'
  },
  */

  // --- アセット (asset) ---
  // 画像、アイコンなど
  /*
  'data-figma-content-logo': {
    type: 'asset',
    endpoint: null,
    apiField: null,
    transform: null,
    label: 'ロゴ画像'
  },
  */

  // ========================================
  // ここに実際のマッピングデータを追加
  // ========================================
  {{MAPPING_ENTRIES}}
};

// タイプ別の色設定
const TYPE_COLORS = {
  static: { bg: '#e0e0e0', text: '#333', border: '#999' },        // グレー
  dynamic: { bg: '#d4edda', text: '#155724', border: '#28a745' }, // 緑（API）
  dynamic_list: { bg: '#cce5ff', text: '#004085', border: '#007bff' }, // 青（APIリスト）
  local: { bg: '#e8daef', text: '#4a235a', border: '#8e44ad' },   // 紫（ローカル）
  asset: { bg: '#fff3cd', text: '#856404', border: '#ffc107' }    // 黄（アセット）
};

// タイプ別のラベル
const TYPE_LABELS = {
  static: '静的',
  dynamic: '動的(API)',
  dynamic_list: '動的リスト(API)',
  local: '動的(ローカル)',
  asset: 'アセット'
};

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
    if (attrName.startsWith('data-figma-content-') && MAPPING_DATA[attrName]) {
      return { attr: attrName, ...MAPPING_DATA[attrName] };
    }
  }
  return null;
}

// ツールチップの内容を生成
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
        <code style="
          display: block;
          background: #e8f4fd;
          padding: 4px 8px;
          border-radius: 4px;
          font-family: monospace;
          font-size: 11px;
          color: #0066cc;
        ">${info.endpoint}</code>
      </div>
    `;
  }

  if (info.apiField) {
    html += `
      <div style="margin-top: 8px;">
        <div style="font-weight: bold; color: #333; margin-bottom: 4px;">API Field:</div>
        <code style="
          display: block;
          background: #f5f5f5;
          padding: 4px 8px;
          border-radius: 4px;
          font-family: monospace;
          font-size: 11px;
        ">${info.apiField}</code>
      </div>
    `;
  }

  if (info.transform) {
    html += `
      <div style="margin-top: 8px;">
        <div style="font-weight: bold; color: #333; margin-bottom: 4px;">変換:</div>
        <code style="
          display: block;
          background: #fff8e1;
          padding: 4px 8px;
          border-radius: 4px;
          font-family: monospace;
          font-size: 11px;
          white-space: pre-wrap;
        ">${info.transform}</code>
      </div>
    `;
  }

  return html;
}

// オーバーレイモードの初期化
function initMappingOverlay() {
  const tooltip = createTooltip();
  let isEnabled = true;

  // トグルボタンを作成
  const toggleBtn = document.createElement('button');
  toggleBtn.id = 'mapping-toggle';
  toggleBtn.innerHTML = 'Mapping';
  toggleBtn.style.cssText = `
    position: fixed;
    top: 10px;
    right: 10px;
    z-index: 10001;
    padding: 8px 16px;
    background: #0070e0;
    color: white;
    border: none;
    border-radius: 8px;
    font-family: "Hiragino Sans", sans-serif;
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
  `;
  document.body.appendChild(toggleBtn);

  toggleBtn.addEventListener('click', () => {
    isEnabled = !isEnabled;
    toggleBtn.style.background = isEnabled ? '#0070e0' : '#999';
    toggleBtn.innerHTML = isEnabled ? 'Mapping' : 'OFF';
    if (!isEnabled) {
      tooltip.style.display = 'none';
      removeHighlights();
    } else {
      highlightElements();
    }
  });

  // 要素をハイライト
  function highlightElements() {
    // 動的にセレクタを構築してハイライト
    Object.keys(MAPPING_DATA).forEach(attr => {
      document.querySelectorAll(`[${attr}]`).forEach(el => {
        const info = getMappingInfo(el);
        if (info) {
          const colors = TYPE_COLORS[info.type] || TYPE_COLORS.static;
          el.style.outline = `2px dashed ${colors.border}`;
          el.style.outlineOffset = '2px';
          el.dataset.mappingEnabled = 'true';
        }
      });
    });
  }

  // ハイライトを削除
  function removeHighlights() {
    document.querySelectorAll('[data-mapping-enabled]').forEach(el => {
      el.style.outline = '';
      el.style.outlineOffset = '';
      delete el.dataset.mappingEnabled;
    });
  }

  // マウスイベントを設定
  document.addEventListener('mouseover', (e) => {
    if (!isEnabled) return;

    let target = e.target;
    while (target && target !== document.body) {
      const info = getMappingInfo(target);
      if (info) {
        tooltip.innerHTML = renderTooltipContent(info);
        tooltip.style.display = 'block';

        // ツールチップ位置を計算
        const rect = target.getBoundingClientRect();
        let top = rect.bottom + 10;
        let left = rect.left;

        // 画面外にはみ出す場合の調整
        if (top + tooltip.offsetHeight > window.innerHeight) {
          top = rect.top - tooltip.offsetHeight - 10;
        }
        if (left + tooltip.offsetWidth > window.innerWidth) {
          left = window.innerWidth - tooltip.offsetWidth - 10;
        }

        tooltip.style.top = `${Math.max(10, top)}px`;
        tooltip.style.left = `${Math.max(10, left)}px`;
        return;
      }
      target = target.parentElement;
    }
  });

  document.addEventListener('mouseout', (e) => {
    let target = e.target;
    while (target && target !== document.body) {
      if (getMappingInfo(target)) {
        tooltip.style.display = 'none';
        return;
      }
      target = target.parentElement;
    }
  });

  // 初期ハイライト
  highlightElements();

  console.log('Mapping Overlay initialized. Hover over highlighted elements to see mapping info.');
}

// DOM読み込み完了後に初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initMappingOverlay);
} else {
  initMappingOverlay();
}
