# devuntu - Containerized Development Environment

WSL上のDockerで動作する、最強の自分専用開発環境（Portable Dotfiles）です。
Ubuntu 24.04をベースに、Neovim、Node.js (Volta)、Bun、uv、Docker CLIなどがプリインストールされています。

## 特徴

- **ホスト同期**: `home/` フォルダがコンテナの `/home/ubuntu` にマウントされます。コンテナ内での設定変更は即座にホストのリポジトリに反映されます。
- **永続化**: Neovimのプラグインやツール類のキャッシュはホストに保存されるため、コンテナを破棄しても次回起動時に再インストールは不要です。
- **ホストネットワーク**: `network_mode: host` により、ホストのブラウザからコンテナ内の開発サーバー（localhost）に直接アクセス可能です。
- **Docker連携**: コンテナ内からホスト側のDockerを操作（docker ps, lazygit, lazydocker等）できます。

## 前提条件 (Host)

ホストマシン（WSL等）に Docker がインストールされている必要があります。未インストールの場合は以下を実行してください。

```bash
# Dockerのインストール
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh && rm get-docker.sh

# ユーザーをdockerグループに追加（sudoなしで実行可能にする）
sudo gpasswd -a $USER docker

# Dockerサービスの再起動（またはWSLの再起動）
sudo service docker restart
```

## 構成

```text
.
├── home/               # ホストと同期されるホームディレクトリ
│   ├── .bashrc         # Ubuntuデフォルト + カスタム設定の自動読み込み
│   ├── .bash_aliases   # エイリアス管理
│   ├── .bash_functions # 自作関数 (activate, tree, xcat等)
│   ├── .config/nvim/   # Neovim (Lazy.nvim) 設定
│   └── .gemini/        # Gemini CLI 設定
├── tools/              # ビルド時に実行されるツール別セットアップスクリプト
├── apt-packages.txt    # 追加したいaptパッケージのリスト
├── Dockerfile          # 環境構築レシピ
├── compose.yaml        # コンテナ実行設定
└── entrypoint.sh       # 起動時の自動設定 (PATH, Docker権限)
```

## 使い方（セットアップ）

1. **リポジトリをクローン**
   ```bash
   git clone https://github.com/smdhnz/devuntu.git
   cd devuntu
   ```

2. **イメージのビルド**
   ```bash
   docker compose build
   ```

3. **環境の起動**
   ```bash
   docker compose run --rm devuntu
   ```
   ※ `--rm` をつけることで、終了時にコンテナが自動削除され、常にクリーンな状態を保てます。

4. **Git の初期設定（初回のみ）**
   コンテナ内で Git を使用する場合、以下の設定を行ってください。
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your-email@example.com"
   ```
   ※ 設定は `home/.gitconfig` に保存され、コンテナを再起動しても保持されます。

5. **GitHub 連携 (SSH キーの設定)**
   GitHub へのプッシュ等を行う場合は、コンテナ内で SSH キーを生成し、公開鍵を GitHub に登録してください。
   ```bash
   ssh-keygen -t ed25519
   cat $HOME/.ssh/id_ed25519.pub
   ```
   表示された公開鍵をコピーし、[GitHub の SSH 設定](https://github.com/settings/keys) に登録して保存してください。
   ※ 生成された鍵は `home/.ssh/` に保存され、コンテナを再起動しても保持されます。

## 便利な使い方

ホスト側の `~/.bashrc` に以下のエイリアスを追記しておくと、どこからでも `devuntu` と打つだけで環境を起動できて便利です（パスは環境に合わせて書き換えてください）。

```bash
alias devuntu='cd ~/.dotfiles && docker compose run --rm devuntu'
```

## カスタマイズ方法

### パッケージの追加
- **標準的なツール**: `apt-packages.txt` にパッケージ名を追記してビルド。
- **特殊なツール**: `tools/` フォルダに新しい `.sh` スクリプトを作成し、`Dockerfile` に `RUN bash /tmp/tools/your-script.sh` のように追記してビルド。

### エイリアス・関数の追加
- `home/.bash_aliases` または `home/.bash_functions` を編集してください。コンテナ内・ホスト側のどちらで編集しても、即座に同期されます。

### SSHキー
- コンテナ内で `ssh-keygen` を実行すると、鍵は `home/.ssh/` に保存されます（`.gitignore` で保護されています）。

## 注意事項
- 初回起動時は `home/` 内に Ubuntu デフォルトの `.bashrc` 等が配置されます。
- `docker.sock` の権限は起動時に `entrypoint.sh` によって自動的に調整されます。
