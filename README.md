# ai_agent_orchestra

## セットアップ

### 設定フォルダのコピー

このリポジトリの設定フォルダ（`.agents`, `.claude`, `.cursor`, `.github`）をホームディレクトリにコピーします。

#### 方法1: リポジトリをクローンして実行

```bash
git clone https://github.com/farmanlab/ai_agent_orchestra.git
cd ai_agent_orchestra
./scripts/copy_to_home.sh
```

強制上書きする場合:

```bash
./scripts/copy_to_home.sh -f
```

#### 方法2: GitHub CLIで直接実行

リポジトリをクローンせずに、ghコマンドで直接スクリプトを実行できます。

確認ありでコピー:

```bash
bash <(gh api repos/farmanlab/ai_agent_orchestra/contents/scripts/copy_to_home.sh --jq '.content' | base64 -d)
```

強制上書き:

```bash
bash <(gh api repos/farmanlab/ai_agent_orchestra/contents/scripts/copy_to_home.sh --jq '.content' | base64 -d) -f
```

または、curlを使用する場合。

確認ありでコピー:

```bash
bash <(curl -s https://raw.githubusercontent.com/farmanlab/ai_agent_orchestra/main/scripts/copy_to_home.sh)
```

強制上書き:

```bash
bash <(curl -s https://raw.githubusercontent.com/farmanlab/ai_agent_orchestra/main/scripts/copy_to_home.sh) -f
```
