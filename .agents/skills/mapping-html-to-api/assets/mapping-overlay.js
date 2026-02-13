/**
 * {{PROJECT_NAME}} Content & Interaction & API Mapping Overlay
 * Generated: {{GENERATED_DATE}}
 *
 * 機能:
 * - データタイプ可視化 (static/dynamic/dynamic_list/config/asset/user_asset)
 * - インタラクション可視化 (navigate/modal/disabled/loading)
 * - APIマッピング可視化 (data-api-endpoint, data-api-response-field, etc.)
 * - JSONプレビュー（凡例下部にハイライト付き表示）
 * - リアルタイム状態表示 (hover/active/focus/selected)
 * - フィルタリング機能
 *
 * 対応HTML属性:
 * - data-figma-content-id: 一意識別子（snake_case）
 * - data-figma-content-type: text/icon/ui_state/number/list等
 * - data-figma-content-classification: static/dynamic/dynamic_list/config/asset/user_asset
 * - data-figma-content-value: Figmaでの表示値
 * - data-figma-content-notes: 補足説明
 * - data-figma-content-data-type: string/number/svg等
 * - data-api-endpoint: APIエンドポイント (例: GET /api/users)
 * - data-api-response-field: レスポンスフィールドパス
 * - data-api-request-body: リクエストボディテンプレート
 * - data-api-contract: 契約ファイル名
 */

// ========================================
// Contract JSONデータ (GET APIのみ)
// ========================================
// contract/*.md のJSONサンプルをここに埋め込む
// 未登録のContractは凡例に警告表示される

const CONTRACT_DATA = {
  // === サンプル ===
  // 'get_api_endpoint_name.md': {
  //   endpoint: 'GET /api/endpoint/{id}',
  //   json: {
  //     "field1": "value1",
  //     "field2": 123,
  //     "nested": {
  //       "subfield": "value"
  //     }
  //   }
  // },
  {{CONTRACT_ENTRIES}}
};

// ========================================
// タイプ設定
// ========================================

// タイプ別の色設定
const TYPE_COLORS = {
  // データタイプ（classification）
  static: { bg: '#e0e0e0', text: '#333', border: '#999' },
  dynamic: { bg: '#d4edda', text: '#155724', border: '#28a745' },
  dynamic_list: { bg: '#cce5ff', text: '#004085', border: '#007bff' },
  config: { bg: '#e8daef', text: '#4a235a', border: '#8e44ad' },
  asset: { bg: '#fff3cd', text: '#856404', border: '#ffc107' },
  user_asset: { bg: '#ffe0b2', text: '#e65100', border: '#ff9800' },
  // インタラクションタイプ
  navigate: { bg: '#ffe0ec', text: '#8b0a50', border: '#de30ca' },
  modal: { bg: '#ffeeba', text: '#856404', border: '#ff9800' },
  disabled: { bg: '#f5f5f5', text: '#999', border: '#ccc' },
  loading: { bg: '#e3f2fd', text: '#1565c0', border: '#2196f3' },
  // APIマッピングタイプ
  api: { bg: '#e8f5e9', text: '#1b5e20', border: '#4caf50' },
  api_get: { bg: '#e3f2fd', text: '#0d47a1', border: '#2196f3' },
  api_post: { bg: '#fff3e0', text: '#e65100', border: '#ff9800' },
  api_action: { bg: '#ffebee', text: '#c62828', border: '#ef5350' },
  local: { bg: '#f3e5f5', text: '#6a1b9a', border: '#ab47bc' }
};

// タイプ別のラベル
const TYPE_LABELS = {
  static: '静的',
  dynamic: '動的',
  dynamic_list: '動的リスト',
  config: '設定',
  asset: 'アセット',
  user_asset: 'ユーザー画像',
  navigate: '画面遷移',
  modal: 'モーダル',
  disabled: '無効',
  loading: '読込中',
  api: 'API連携',
  api_get: 'GET',
  api_post: 'POST',
  api_action: 'API(POST/PUT)',
  local: 'ローカル状態'
};

// ========================================
// HTMLからマッピングデータを自動抽出
// ========================================

function extractMappingDataFromHTML() {
  const mappingData = {};

  // data-figma-content-id を持つ全要素を検索
  document.querySelectorAll('[data-figma-content-id]').forEach(el => {
    const contentId = el.dataset.figmaContentId;
    const classification = el.dataset.figmaContentClassification || 'static';
    const contentType = el.dataset.figmaContentType || 'text';
    const value = el.dataset.figmaContentValue || '';
    const notes = el.dataset.figmaContentNotes || '';
    const dataType = el.dataset.figmaContentDataType || 'string';
    const nodeId = el.dataset.figmaNode || '';

    // API属性を抽出
    const apiEndpoint = el.dataset.apiEndpoint || '';
    const apiResponseField = el.dataset.apiResponseField || '';
    const apiRequestBody = el.dataset.apiRequestBody || '';
    const apiContract = el.dataset.apiContract || '';

    // ラベル生成: notes > value > テキストコンテンツ
    let label = notes || value || el.textContent?.trim().substring(0, 30) || contentId;
    if (label.length > 40) label = label.substring(0, 37) + '...';

    // キーとして data-figma-content-id を使用
    const key = `data-figma-content-id="${contentId}"`;

    mappingData[key] = {
      type: classification,
      contentType: contentType,
      dataType: dataType,
      label: label,
      nodeId: nodeId,
      value: value,
      notes: notes,
      // API情報
      apiEndpoint: apiEndpoint,
      apiResponseField: apiResponseField,
      apiRequestBody: apiRequestBody,
      apiContract: apiContract,
      hasApi: !!(apiEndpoint || apiResponseField || apiRequestBody)
    };
  });

  // data-api-endpoint を持つが data-figma-content-id がない要素も検索
  document.querySelectorAll('[data-api-endpoint]:not([data-figma-content-id])').forEach(el => {
    const apiEndpoint = el.dataset.apiEndpoint || '';
    const apiResponseField = el.dataset.apiResponseField || '';
    const apiRequestBody = el.dataset.apiRequestBody || '';
    const apiContract = el.dataset.apiContract || '';
    const nodeId = el.dataset.figmaNode || '';

    // ユニークキー生成
    const key = `data-api-endpoint="${apiEndpoint}"_${nodeId || Math.random().toString(36).substr(2, 9)}`;

    let label = el.textContent?.trim().substring(0, 30) || apiEndpoint;
    if (label.length > 40) label = label.substring(0, 37) + '...';

    // タイプ決定
    let type = 'api_get';
    if (apiEndpoint === 'none') {
      type = 'local';
    } else if (apiEndpoint.startsWith('POST') || apiEndpoint.startsWith('PUT')) {
      type = 'api_post';
    }

    mappingData[key] = {
      type: type,
      contentType: 'api',
      label: label,
      nodeId: nodeId,
      apiEndpoint: apiEndpoint,
      apiResponseField: apiResponseField,
      apiRequestBody: apiRequestBody,
      apiContract: apiContract,
      hasApi: true
    };
  });

  return mappingData;
}

// グローバル変数として保持（初期化時に設定）
let MAPPING_DATA = {};

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

// JSONプレビューパネルを作成（ドラッグ可能、ヘッダー常時表示、ホールド機能）
function createJsonPreviewPanel(legend) {
  const panel = document.createElement('div');
  panel.id = 'json-preview-panel';
  panel.style.cssText = `
    position: fixed;
    left: 10px;
    top: 50px;
    z-index: 10001;
    background: #1e1e1e;
    border: 1px solid #333;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    font-family: "SF Mono", "Monaco", "Consolas", monospace;
    font-size: 12px;
    max-width: 450px;
  `;
  document.body.appendChild(panel);

  // ホールド状態
  let isHeld = false;

  // ドラッグハンドル（ヘッダー）- 常時表示
  const dragHandle = document.createElement('div');
  dragHandle.id = 'json-preview-header';
  dragHandle.style.cssText = `
    padding: 8px 12px;
    background: #2d2d2d;
    border-radius: 8px;
    cursor: move;
    user-select: none;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 8px;
  `;

  // タイトル部分
  const titleSpan = document.createElement('span');
  titleSpan.style.cssText = 'color: #888; font-size: 11px;';
  titleSpan.textContent = '📋 JSON Preview';
  dragHandle.appendChild(titleSpan);

  // 右側のコントロール
  const controls = document.createElement('div');
  controls.style.cssText = 'display: flex; align-items: center; gap: 8px;';

  // ホールド（ピン留め）ボタン
  const holdBtn = document.createElement('button');
  holdBtn.id = 'json-preview-hold-btn';
  holdBtn.style.cssText = `
    background: transparent;
    border: 1px solid #555;
    border-radius: 4px;
    color: #888;
    font-size: 12px;
    padding: 2px 6px;
    cursor: pointer;
    transition: all 0.15s ease;
  `;
  holdBtn.textContent = '📌';
  holdBtn.title = 'ホールド: マウスアウトしても表示を維持';
  controls.appendChild(holdBtn);

  // ドラッグインジケーター
  const dragIndicator = document.createElement('span');
  dragIndicator.style.cssText = 'color: #666; font-size: 10px;';
  dragIndicator.textContent = '⋮⋮';
  controls.appendChild(dragIndicator);

  dragHandle.appendChild(controls);
  panel.appendChild(dragHandle);

  // ホールドボタンのクリックイベント
  holdBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    isHeld = !isHeld;
    if (isHeld) {
      holdBtn.style.background = '#4caf50';
      holdBtn.style.borderColor = '#4caf50';
      holdBtn.style.color = 'white';
      panel.style.borderColor = '#4caf50';
    } else {
      holdBtn.style.background = 'transparent';
      holdBtn.style.borderColor = '#555';
      holdBtn.style.color = '#888';
      panel.style.borderColor = '#333';
    }
  });

  // コンテンツエリア（非表示で開始）
  const content = document.createElement('div');
  content.id = 'json-preview-content';
  content.style.cssText = `
    padding: 12px;
    overflow: auto;
    display: none;
    border-top: 1px solid #444;
  `;
  panel.appendChild(content);

  // ドラッグ機能
  let isDragging = false;
  let startX, startY, startLeft, startTop;

  dragHandle.addEventListener('mousedown', (e) => {
    // ホールドボタンのクリックはドラッグ開始しない
    if (e.target === holdBtn || e.target.closest('#json-preview-hold-btn')) return;
    isDragging = true;
    startX = e.clientX;
    startY = e.clientY;
    startLeft = panel.offsetLeft;
    startTop = panel.offsetTop;
    e.preventDefault();
  });

  document.addEventListener('mousemove', (e) => {
    if (!isDragging) return;
    const dx = e.clientX - startX;
    const dy = e.clientY - startY;
    let newLeft = startLeft + dx;
    let newTop = startTop + dy;

    // 画面内に収める
    newLeft = Math.max(0, Math.min(newLeft, window.innerWidth - panel.offsetWidth));
    newTop = Math.max(0, Math.min(newTop, window.innerHeight - 50));

    panel.style.left = newLeft + 'px';
    panel.style.top = newTop + 'px';
  });

  document.addEventListener('mouseup', () => {
    isDragging = false;
  });

  // 画面内に収まるようサイズを調整
  panel.updatePosition = function() {
    const availableHeight = window.innerHeight - parseInt(panel.style.top) - 20;
    content.style.maxHeight = Math.max(150, availableHeight) + 'px';
  };

  // コンテンツ表示
  panel.showContent = function() {
    content.style.display = 'block';
    dragHandle.style.borderRadius = '8px 8px 0 0';
  };

  // コンテンツ非表示（ホールド中は無視）
  panel.hideContent = function() {
    if (isHeld) return;  // ホールド中は非表示にしない
    content.style.display = 'none';
    dragHandle.style.borderRadius = '8px';
  };

  // コンテンツ更新用メソッド
  panel.setContent = function(html) {
    content.innerHTML = html;
  };

  // ホールド状態の取得
  panel.isHeld = function() {
    return isHeld;
  };

  // パネル全体を表示
  panel.show = function() {
    panel.style.display = 'block';
  };

  // パネル全体を非表示
  panel.hide = function() {
    panel.style.display = 'none';
  };

  return panel;
}

// シンプルなJSON表示（ハイライトなし）
function renderJsonSimple(obj, indent) {
  const spaces = '  '.repeat(indent);

  if (obj === null) return `<span style="color: #569cd6;">null</span>`;
  if (typeof obj === 'boolean') return `<span style="color: #569cd6;">${obj}</span>`;
  if (typeof obj === 'number') return `<span style="color: #b5cea8;">${obj}</span>`;
  if (typeof obj === 'string') {
    const escaped = obj.replace(/</g, '&lt;').replace(/>/g, '&gt;');
    const truncated = escaped.length > 40 ? escaped.substring(0, 37) + '...' : escaped;
    return `<span style="color: #ce9178;">"${truncated}"</span>`;
  }

  if (Array.isArray(obj)) {
    if (obj.length === 0) return '<span style="color: #d4d4d4;">[]</span>';
    let html = '<span style="color: #d4d4d4;">[</span>\n';
    obj.forEach((item, i) => {
      html += `${spaces}  ${renderJsonSimple(item, indent + 1)}${i < obj.length - 1 ? ',' : ''}\n`;
    });
    html += `${spaces}<span style="color: #d4d4d4;">]</span>`;
    return html;
  }

  if (typeof obj === 'object') {
    const keys = Object.keys(obj);
    if (keys.length === 0) return '<span style="color: #d4d4d4;">{}</span>';
    let html = '<span style="color: #d4d4d4;">{</span>\n';
    keys.forEach((key, i) => {
      html += `${spaces}  <span style="color: #9cdcfe;">"${key}"</span>: ${renderJsonSimple(obj[key], indent + 1)}${i < keys.length - 1 ? ',' : ''}\n`;
    });
    html += `${spaces}<span style="color: #d4d4d4;">}</span>`;
    return html;
  }

  return String(obj);
}

// 再帰的にJSONをレンダリング（ハイライト付き）
function renderJsonRecursive(obj, currentPath, targetPath, highlightPaths, indent) {
  const spaces = '  '.repeat(indent);
  const isTarget = currentPath === targetPath;

  if (obj === null) return `<span style="color: #569cd6;">null</span>`;
  if (typeof obj === 'boolean') return `<span style="color: #569cd6;">${obj}</span>`;
  if (typeof obj === 'number') return `<span style="color: #b5cea8;">${obj}</span>`;
  if (typeof obj === 'string') {
    const escaped = obj.replace(/</g, '&lt;').replace(/>/g, '&gt;');
    const truncated = escaped.length > 40 ? escaped.substring(0, 37) + '...' : escaped;
    if (isTarget) {
      return `<span style="color: #ffd500; background: rgba(255, 213, 0, 0.3); padding: 1px 4px; border-radius: 3px; font-weight: bold;">"${truncated}"</span>`;
    }
    return `<span style="color: #ce9178;">"${truncated}"</span>`;
  }

  if (Array.isArray(obj)) {
    if (obj.length === 0) return '<span style="color: #d4d4d4;">[]</span>';
    let html = '<span style="color: #d4d4d4;">[</span>\n';
    obj.forEach((item, i) => {
      const itemPath = currentPath ? `${currentPath}[${i}]` : `[${i}]`;
      const itemIsOnPath = highlightPaths.has(itemPath) || targetPath.startsWith(itemPath + '.') || targetPath.startsWith(itemPath + '[');
      const itemBg = itemIsOnPath ? ' style="background: rgba(255, 213, 0, 0.08);"' : '';
      html += `${spaces}  <span${itemBg}>${renderJsonRecursive(item, itemPath, targetPath, highlightPaths, indent + 1)}</span>${i < obj.length - 1 ? ',' : ''}\n`;
    });
    html += `${spaces}<span style="color: #d4d4d4;">]</span>`;
    return html;
  }

  if (typeof obj === 'object') {
    const keys = Object.keys(obj);
    if (keys.length === 0) return '<span style="color: #d4d4d4;">{}</span>';
    let html = '<span style="color: #d4d4d4;">{</span>\n';
    keys.forEach((key, i) => {
      const keyPath = currentPath ? `${currentPath}.${key}` : key;
      const keyIsTarget = keyPath === targetPath;
      const keyIsOnPath = highlightPaths.has(keyPath) || targetPath.startsWith(keyPath + '.') || targetPath.startsWith(keyPath + '[');

      let keyStyle = 'color: #9cdcfe;';
      let keyId = '';
      if (keyIsTarget) {
        keyStyle = 'color: #ffd500; font-weight: bold; background: rgba(255, 213, 0, 0.3); padding: 1px 4px; border-radius: 3px;';
        keyId = ' id="json-highlight-target"';
      } else if (keyIsOnPath) {
        keyStyle = 'color: #4fc3f7;';
      }

      const valuePart = renderJsonRecursive(obj[key], keyPath, targetPath, highlightPaths, indent + 1);
      html += `${spaces}  <span${keyId} style="${keyStyle}">"${key}"</span>: ${valuePart}${i < keys.length - 1 ? ',' : ''}\n`;
    });
    html += `${spaces}<span style="color: #d4d4d4;">}</span>`;
    return html;
  }

  return String(obj);
}

// ワイルドカードパス（[]）を具体的なインデックス（[0]）に変換
function normalizeWildcardPath(path) {
  if (!path) return path;
  // [] を [0] に置換
  return path.replace(/\[\]/g, '[0]');
}

// パスベースのJSONハイライト（再帰版）
function renderJsonWithHighlightByPath(obj, highlightPath) {
  if (!highlightPath) {
    return renderJsonSimple(obj, 0);
  }

  // ワイルドカードパスを正規化
  const normalizedPath = normalizeWildcardPath(highlightPath);

  // ハイライト対象のパスセットを作成（親パスも含む）
  const highlightPaths = new Set();
  highlightPaths.add(normalizedPath);

  // 親パスも追加
  let parentPath = normalizedPath;
  while (parentPath.includes('.') || parentPath.includes('[')) {
    if (parentPath.lastIndexOf('.') > parentPath.lastIndexOf(']')) {
      parentPath = parentPath.substring(0, parentPath.lastIndexOf('.'));
    } else if (parentPath.includes('[')) {
      parentPath = parentPath.substring(0, parentPath.lastIndexOf('['));
    } else {
      break;
    }
    if (parentPath) highlightPaths.add(parentPath);
  }

  return renderJsonRecursive(obj, '', normalizedPath, highlightPaths, 0);
}

// JSON内で値を検索し、マッチするパスを返す（自動検出用）
function findValueInJson(obj, searchValue, currentPath = '') {
  if (!searchValue || searchValue.length < 3) return [];

  const matches = [];
  const normalizedSearch = String(searchValue).trim().toLowerCase();

  function search(obj, path) {
    if (obj === null || obj === undefined) return;

    if (typeof obj === 'string') {
      const normalizedObj = obj.toLowerCase();
      if (normalizedObj.includes(normalizedSearch) || normalizedSearch.includes(normalizedObj.substring(0, 20))) {
        matches.push({ path, value: obj, exact: normalizedObj === normalizedSearch });
      }
    } else if (typeof obj === 'number' || typeof obj === 'boolean') {
      if (String(obj).toLowerCase() === normalizedSearch) {
        matches.push({ path, value: obj, exact: true });
      }
    } else if (Array.isArray(obj)) {
      obj.forEach((item, i) => {
        search(item, path ? `${path}[${i}]` : `[${i}]`);
      });
    } else if (typeof obj === 'object') {
      Object.keys(obj).forEach(key => {
        search(obj[key], path ? `${path}.${key}` : key);
      });
    }
  }

  search(obj, currentPath);
  matches.sort((a, b) => (b.exact ? 1 : 0) - (a.exact ? 1 : 0));
  return matches;
}

// 自動検出したパスをハイライト用に変換
function getAutoDetectedPath(json, elementValue, elementText) {
  const searchValues = [elementValue, elementText].filter(v => v && v.trim().length >= 3);

  for (const searchValue of searchValues) {
    const matches = findValueInJson(json, searchValue);
    if (matches.length > 0) {
      return matches[0].path;
    }
  }
  return null;
}

// JSONプレビューを更新（自動検出対応）
function updateJsonPreview(panel, contractFile, responseField, element = null) {
  if (!contractFile) {
    panel.hideContent();
    return;
  }

  // 未登録Contractの場合は警告表示
  if (!CONTRACT_DATA[contractFile]) {
    panel.setContent(`
      <div style="color: #ff5722; font-size: 12px; font-weight: bold; margin-bottom: 8px;">
        ⚠️ 未登録Contract
      </div>
      <div style="color: #ffab91; font-size: 11px; margin-bottom: 8px;">
        <code style="background: #3e2723; padding: 2px 6px; border-radius: 4px;">${contractFile}</code>
      </div>
      <div style="color: #808080; font-size: 10px; border-top: 1px solid #333; padding-top: 8px;">
        CONTRACT_DATA に追加してください：
        <pre style="margin: 4px 0 0 0; color: #a5d6a7; font-size: 9px;">'${contractFile}': {
  endpoint: 'GET /...',
  json: { /* sample */ }
}</pre>
      </div>
    `);
    panel.showContent();
    return;
  }

  const contract = CONTRACT_DATA[contractFile];

  // パス決定: responseFieldが指定されていればそれを優先、なければ自動検出
  let detectedPath = null;
  let isAutoDetected = false;

  if (responseField) {
    // 指定されたパスを使用
    detectedPath = responseField;
  } else if (element) {
    // 自動検出: 要素の値からJSONパスを検出（responseFieldがない場合のみ）
    const elementValue = element.dataset.figmaContentValue || '';
    const elementText = element.textContent?.trim() || '';
    const autoPath = getAutoDetectedPath(contract.json, elementValue, elementText);

    if (autoPath) {
      detectedPath = autoPath;
      isAutoDetected = true;
    }
  }

  const jsonHtml = renderJsonWithHighlightByPath(contract.json, detectedPath);

  panel.setContent(`
    <div style="color: #808080; font-size: 10px; margin-bottom: 8px; padding-bottom: 8px; border-bottom: 1px solid #333;">
      <span style="color: #4fc3f7;">📄 ${contractFile}</span>
      ${detectedPath ? `<br><span style="color: ${isAutoDetected ? '#69f0ae' : '#ffd500'};">${isAutoDetected ? '🔍 自動検出: ' : '→ '}${detectedPath}</span>` : ''}
    </div>
    <pre style="margin: 0; line-height: 1.5; color: #d4d4d4;">${jsonHtml}</pre>
  `);
  panel.showContent();
  panel.updatePosition();

  // ハイライト箇所までスクロール
  requestAnimationFrame(() => {
    const content = panel.querySelector('#json-preview-content');
    const target = content?.querySelector('#json-highlight-target');
    if (target) {
      target.scrollIntoView({ block: 'center', behavior: 'instant' });
    }
  });
}

// マッピング情報を取得（data-figma-content-id から）
function getMappingInfo(element) {
  const contentId = element.dataset.figmaContentId;
  if (contentId) {
    const key = `data-figma-content-id="${contentId}"`;
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
  `;

  // コンテンツ詳細
  if (info.contentType || info.dataType) {
    html += `
      <div style="font-size: 11px; color: #888; margin-bottom: 4px;">
        type: ${info.contentType || '-'} / data: ${info.dataType || '-'}
      </div>
    `;
  }

  // ノードID
  if (info.nodeId) {
    html += `
      <div style="font-size: 11px; color: #888; margin-bottom: 4px;">
        node: ${info.nodeId}
      </div>
    `;
  }

  // 値
  if (info.value) {
    html += `
      <div style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #eee;">
        <div style="font-weight: bold; color: #333; margin-bottom: 4px;">値:</div>
        <code style="display: block; background: #f5f5f5; padding: 4px 8px; border-radius: 4px; font-family: monospace; font-size: 11px;">${info.value}</code>
      </div>
    `;
  }

  // API情報
  if (info.apiEndpoint) {
    const isPost = info.apiEndpoint.startsWith('POST') || info.apiEndpoint.startsWith('PUT');
    const isLocal = info.apiEndpoint === 'none';
    const apiColors = isLocal ? TYPE_COLORS.local : (isPost ? TYPE_COLORS.api_post : TYPE_COLORS.api_get);
    const methodLabel = isLocal ? 'LOCAL' : (isPost ? (info.apiEndpoint.startsWith('PUT') ? 'PUT' : 'POST') : 'GET');

    html += `
      <div style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #eee;">
        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
          <span style="font-weight: bold; color: #333;">API:</span>
          <span style="padding: 2px 6px; border-radius: 4px; background: ${apiColors.bg}; color: ${apiColors.text}; border: 1px solid ${apiColors.border}; font-size: 10px; font-weight: bold;">
            ${methodLabel}
          </span>
        </div>
        ${!isLocal ? `<code style="display: block; background: #f8f9fa; padding: 6px 8px; border-radius: 4px; font-family: monospace; font-size: 11px; color: #333; border-left: 3px solid ${apiColors.border};">${info.apiEndpoint}</code>` : ''}
      </div>
    `;

    // レスポンスフィールド
    if (info.apiResponseField) {
      const isLocalState = info.apiResponseField.startsWith('local:');
      html += `
        <div style="margin-top: 8px;">
          <div style="font-weight: bold; color: #333; margin-bottom: 4px; font-size: 11px;">${isLocalState ? 'State Key:' : 'Response Field:'}</div>
          <code style="display: block; background: ${isLocalState ? '#f3e5f5' : '#e3f2fd'}; padding: 4px 8px; border-radius: 4px; font-family: monospace; font-size: 11px; color: ${isLocalState ? '#6a1b9a' : '#0d47a1'};">${info.apiResponseField}</code>
        </div>
      `;
    }

    // リクエストボディ
    if (info.apiRequestBody) {
      let formattedBody = info.apiRequestBody;
      try {
        formattedBody = JSON.stringify(JSON.parse(info.apiRequestBody), null, 2);
      } catch (e) {}
      html += `
        <div style="margin-top: 8px;">
          <div style="font-weight: bold; color: #333; margin-bottom: 4px; font-size: 11px;">Request Body:</div>
          <pre style="display: block; background: #fff3e0; padding: 6px 8px; border-radius: 4px; font-family: monospace; font-size: 10px; color: #e65100; margin: 0; white-space: pre-wrap; word-break: break-all;">${formattedBody}</pre>
        </div>
      `;
    }

    // 契約ファイル
    if (info.apiContract) {
      html += `
        <div style="margin-top: 8px;">
          <div style="font-weight: bold; color: #333; margin-bottom: 4px; font-size: 11px;">Contract:</div>
          <code style="display: block; background: #e8f5e9; padding: 4px 8px; border-radius: 4px; font-family: monospace; font-size: 10px; color: #1b5e20;">📄 ${info.apiContract}</code>
        </div>
      `;
    }
  } else if (info.type === 'dynamic' || info.type === 'dynamic_list') {
    html += `<div style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #eee; color: #999; font-style: italic;">⚠️ API未確定</div>`;
  }

  return html;
}

// インタラクション用ツールチップ（データタイプ情報も含む）
function renderInteractionTooltipContent(info, mappingInfo = null, element = null) {
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

  // API情報
  const apiEndpoint = element?.dataset.apiEndpoint || mappingInfo?.apiEndpoint;
  const apiResponseField = element?.dataset.apiResponseField || mappingInfo?.apiResponseField;
  const apiRequestBody = element?.dataset.apiRequestBody || mappingInfo?.apiRequestBody;
  const apiContract = element?.dataset.apiContract || mappingInfo?.apiContract;

  if (apiEndpoint) {
    const isPost = apiEndpoint.startsWith('POST') || apiEndpoint.startsWith('PUT');
    const isLocal = apiEndpoint === 'none';
    const apiColors = isLocal ? TYPE_COLORS.local : (isPost ? TYPE_COLORS.api_post : TYPE_COLORS.api_get);
    const methodLabel = isLocal ? 'LOCAL' : (isPost ? 'POST' : 'GET');

    html += `
      <div style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #eee;">
        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
          <span style="font-weight: bold; color: #333;">API:</span>
          <span style="padding: 2px 6px; border-radius: 4px; background: ${apiColors.bg}; color: ${apiColors.text}; border: 1px solid ${apiColors.border}; font-size: 10px; font-weight: bold;">
            ${methodLabel}
          </span>
        </div>
        ${!isLocal ? `<code style="display: block; background: #f8f9fa; padding: 6px 8px; border-radius: 4px; font-family: monospace; font-size: 11px; color: #333; border-left: 3px solid ${apiColors.border};">${apiEndpoint}</code>` : ''}
      </div>
    `;

    if (apiResponseField) {
      html += `
        <div style="margin-top: 8px;">
          <div style="font-weight: bold; color: #333; margin-bottom: 4px; font-size: 11px;">Response Field:</div>
          <code style="display: block; background: #e3f2fd; padding: 4px 8px; border-radius: 4px; font-family: monospace; font-size: 11px; color: #0d47a1;">${apiResponseField}</code>
        </div>
      `;
    }

    if (apiRequestBody) {
      let formattedBody = apiRequestBody;
      try {
        formattedBody = JSON.stringify(JSON.parse(apiRequestBody), null, 2);
      } catch (e) {}
      html += `
        <div style="margin-top: 8px;">
          <div style="font-weight: bold; color: #333; margin-bottom: 4px; font-size: 11px;">Request Body:</div>
          <pre style="display: block; background: #fff3e0; padding: 6px 8px; border-radius: 4px; font-family: monospace; font-size: 10px; color: #e65100; margin: 0; white-space: pre-wrap; word-break: break-all;">${formattedBody}</pre>
        </div>
      `;
    }

    if (apiContract) {
      html += `
        <div style="margin-top: 8px;">
          <div style="font-weight: bold; color: #333; margin-bottom: 4px; font-size: 11px;">Contract:</div>
          <code style="display: block; background: #e8f5e9; padding: 4px 8px; border-radius: 4px; font-family: monospace; font-size: 10px; color: #1b5e20;">📄 ${apiContract}</code>
        </div>
      `;
    }
  }

  return html;
}

// ========================================
// メイン初期化
// ========================================
function initMappingOverlay() {
  // HTMLからマッピングデータを抽出
  MAPPING_DATA = extractMappingDataFromHTML();
  const mappingCount = Object.keys(MAPPING_DATA).length;

  const tooltip = createTooltip();
  let jsonPreviewPanel = null;
  let isEnabled = true;
  let activeFilters = new Set();
  let currentHoveredElement = null;
  let stateUpdateInterval = null;

  // トグルボタン
  const toggleBtn = document.createElement('button');
  toggleBtn.id = 'mapping-toggle';
  toggleBtn.innerHTML = `Mapping (${mappingCount})`;
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

  // 使用されているタイプを検出
  const usedTypes = new Set();
  Object.values(MAPPING_DATA).forEach(info => usedTypes.add(info.type));

  // 凡例
  const legend = document.createElement('div');
  legend.id = 'mapping-legend';

  let dataTypeBadges = '';
  ['static', 'dynamic', 'dynamic_list', 'config', 'asset', 'user_asset'].forEach(type => {
    if (usedTypes.has(type)) {
      dataTypeBadges += createFilterBadge(type, TYPE_LABELS[type], TYPE_COLORS[type]);
    }
  });

  const apiCount = Object.values(MAPPING_DATA).filter(info => info.hasApi).length;

  legend.innerHTML = `
    <div style="font-weight: bold; margin-bottom: 8px;">
      凡例
      <span id="filter-reset" style="font-size: 10px; color: #999; font-weight: normal; cursor: pointer; margin-left: 4px; display: none;">[リセット]</span>
    </div>
    <div style="margin-bottom: 8px;">
      <div style="font-size: 10px; color: #666; margin-bottom: 4px;">データタイプ</div>
      <div style="display: flex; flex-wrap: wrap; gap: 4px;">
        ${dataTypeBadges}
      </div>
    </div>
    <div style="margin-bottom: 8px;">
      <div style="font-size: 10px; color: #666; margin-bottom: 4px;">API連携 (${apiCount})</div>
      <div style="display: flex; flex-wrap: wrap; gap: 4px;">
        ${createFilterBadge('api_get', 'GET', TYPE_COLORS.api_get)}
        ${createFilterBadge('api_post', 'POST', TYPE_COLORS.api_post)}
        ${createFilterBadge('local', 'LOCAL', TYPE_COLORS.local)}
      </div>
    </div>
    <div style="margin-bottom: 8px;">
      <div style="font-size: 10px; color: #666; margin-bottom: 4px;">インタラクション</div>
      <div style="display: flex; flex-wrap: wrap; gap: 4px;">
        ${createFilterBadge('navigate', '遷移', TYPE_COLORS.navigate)}
        ${createFilterBadge('modal', 'モーダル', TYPE_COLORS.modal)}
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

  // JSONプレビューパネル
  jsonPreviewPanel = createJsonPreviewPanel(legend);

  // Contract未登録チェック
  const missingContracts = new Map();
  document.querySelectorAll('[data-api-contract]').forEach(el => {
    const contract = el.dataset.apiContract;
    if (contract && !CONTRACT_DATA[contract]) {
      missingContracts.set(contract, (missingContracts.get(contract) || 0) + 1);
    }
  });

  if (missingContracts.size > 0) {
    const warningSection = document.createElement('div');
    warningSection.style.cssText = `
      margin-top: 8px; padding-top: 8px; border-top: 1px solid #ffcdd2;
      background: #fff3e0; margin: 8px -12px -12px -12px; padding: 8px 12px;
      border-radius: 0 0 8px 8px;
    `;
    warningSection.innerHTML = `
      <div style="font-size: 10px; color: #e65100; font-weight: bold; margin-bottom: 4px;">
        ⚠️ 未登録Contract (${missingContracts.size})
      </div>
      <div style="font-size: 9px; color: #bf360c; max-height: 80px; overflow-y: auto;">
        ${Array.from(missingContracts.entries()).map(([name, count]) =>
          `<div style="margin-bottom: 2px;">• ${name} <span style="color: #999;">(${count})</span></div>`
        ).join('')}
      </div>
    `;
    legend.appendChild(warningSection);
    console.warn('⚠️ 未登録のContract files:', Array.from(missingContracts.keys()));
  }

  // フィルタリング機能
  function elementMatchesFilter(el) {
    const mappingInfo = getMappingInfo(el);
    const interactionInfo = getInteractionInfo(el);

    if (mappingInfo && activeFilters.has(mappingInfo.type)) return true;
    if (interactionInfo && activeFilters.has(interactionInfo.type)) return true;

    if (mappingInfo && mappingInfo.hasApi) {
      const isPost = mappingInfo.apiEndpoint?.startsWith('POST') || mappingInfo.apiEndpoint?.startsWith('PUT');
      const isLocal = mappingInfo.apiEndpoint === 'none';
      if (activeFilters.has('api_get') && !isPost && !isLocal) return true;
      if (activeFilters.has('api_post') && isPost) return true;
      if (activeFilters.has('local') && isLocal) return true;
    }

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

  toggleBtn.addEventListener('click', () => {
    isEnabled = !isEnabled;
    toggleBtn.style.background = isEnabled ? '#0070e0' : '#999';
    toggleBtn.innerHTML = isEnabled ? `Mapping (${mappingCount})` : 'OFF';
    legend.style.display = isEnabled ? 'block' : 'none';
    if (!isEnabled) {
      tooltip.style.display = 'none';
      jsonPreviewPanel.hide();  // パネル全体を非表示
      removeHighlights();
      activeFilters.clear();
    } else {
      jsonPreviewPanel.show();  // パネル全体を表示（ヘッダーのみ）
      highlightElements();
      applyFilters();
    }
  });

  function highlightElements() {
    document.querySelectorAll('[data-figma-content-id]').forEach(el => {
      const info = getMappingInfo(el);
      if (info) {
        const colors = TYPE_COLORS[info.type] || TYPE_COLORS.static;
        el.style.outline = `2px dashed ${colors.border}`;
        el.style.outlineOffset = '2px';
        el.dataset.mappingEnabled = 'true';
      }
    });

    document.querySelectorAll('[data-figma-interaction], [data-figma-navigate]').forEach(el => {
      const interactionInfo = getInteractionInfo(el);
      if (interactionInfo) {
        const colors = TYPE_COLORS[interactionInfo.type] || TYPE_COLORS.navigate;
        el.style.outline = `3px solid ${colors.border}`;
        el.style.outlineOffset = '2px';
        el.dataset.interactionEnabled = 'true';
      }
    });
  }

  function removeHighlights() {
    document.querySelectorAll('[data-mapping-enabled]').forEach(el => {
      el.style.outline = '';
      el.style.outlineOffset = '';
      delete el.dataset.mappingEnabled;
    });
    document.querySelectorAll('[data-interaction-enabled]').forEach(el => {
      el.style.outline = '';
      el.style.outlineOffset = '';
      el.style.boxShadow = '';
      delete el.dataset.interactionEnabled;
    });
  }

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
    const mappingInfo = getMappingInfo(target);

    if (hasInteraction) {
      const interactionInfo = getInteractionInfo(target);
      if (interactionInfo) tooltip.innerHTML = renderInteractionTooltipContent(interactionInfo, mappingInfo, target);
    } else if (mappingInfo) {
      tooltip.innerHTML = renderTooltipContent(mappingInfo);
    }
  }

  document.addEventListener('mouseover', (e) => {
    if (!isEnabled) return;
    let target = e.target;
    while (target && target !== document.body) {
      if (target.dataset.interactionEnabled || target.dataset.mappingEnabled) {
        currentHoveredElement = target;
        updateTooltipContent(target);
        tooltip.style.display = 'block';
        updateTooltipPosition(target);

        const apiEndpoint = target.dataset.apiEndpoint;
        const apiContract = target.dataset.apiContract;
        const apiResponseField = target.dataset.apiResponseField;

        if (apiContract) {
          if (apiEndpoint && apiEndpoint.startsWith('GET')) {
            updateJsonPreview(jsonPreviewPanel, apiContract, apiResponseField, target);
          } else if (!CONTRACT_DATA[apiContract]) {
            updateJsonPreview(jsonPreviewPanel, apiContract, null, target);
          } else {
            jsonPreviewPanel.hideContent();
          }
          jsonPreviewPanel.updatePosition();
        } else {
          jsonPreviewPanel.hideContent();
        }

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
      if (target.dataset.mappingEnabled || target.dataset.interactionEnabled) {
        if (stateUpdateInterval) { cancelAnimationFrame(stateUpdateInterval); stateUpdateInterval = null; }
        currentHoveredElement = null;
        tooltip.style.display = 'none';
        jsonPreviewPanel.hideContent();
        return;
      }
      target = target.parentElement;
    }
  });

  document.addEventListener('mousedown', () => { if (currentHoveredElement) updateTooltipContent(currentHoveredElement); });
  document.addEventListener('mouseup', () => { if (currentHoveredElement) updateTooltipContent(currentHoveredElement); });

  highlightElements();
  console.log(`Mapping Overlay initialized. ${mappingCount} elements detected.`);
  console.log('- データタイプ: 破線枠');
  console.log('- インタラクション: 実線枠');
  console.log('- 凡例クリックでフィルタリング');
  console.log('- Hoverで JSONプレビュー表示');
}

// DOM読み込み完了後に初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initMappingOverlay);
} else {
  initMappingOverlay();
}
