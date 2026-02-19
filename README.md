# devuntu

Docker上で動作するUbuntu 24.04ベースの開発環境です。
WSL 2やLinuxサーバーなど、Dockerがインストールされている環境で動作します。

## プリインストール済みツール
- Neovim
- Node.js (Volta)
- Bun
- uv (Python)
- lazygit
- Docker CLI

## 仕様
- **マルチアーキテクチャ**: x86_64 および arm64 (Apple Silicon等) に対応しています。
- **ディレクトリ同期**: ホストの `./home` をコンテナの `/home/ubuntu` にマウントします。
- **ネットワーク**: `network_mode: host` 設定により、ホストのネットワーク構成をそのまま使用します。
- **Docker操作**: `/var/run/docker.sock` をマウントしているため、コンテナ内からホストのDockerコマンドを実行可能です。
- **データ永続化**: 設定ファイルやツールのキャッシュは `./home` 内に保持されます。
- **パス管理**: 各ツールは `/etc/profile.d/` に設定ファイルを生成することで自動的に `PATH` を通しています。`Dockerfile` で `ENV PATH` を直接編集する必要はありません。

## 使用方法

### ビルド
```bash
docker compose build
```

### 実行
```bash
docker compose run --rm devuntu
```

## カスタマイズ
- **パッケージ追加**: `apt-packages.txt` にパッケージ名を追記して再ビルドしてください。
- **設定変更**: `home/` 内の各設定ファイル（`.bashrc` 等）を編集してください。
- **ツール追加**: `tools/` にインストールスクリプトを配置し、`Dockerfile` から実行するように追記してください。パスを通す必要がある場合は、スクリプト内で `/etc/profile.d/` に設定ファイルを書き出すようにしてください。

## 補足
- WSL環境でのパス互換性のため、`compose.yaml` で `/mnt` をマウントしています。Linuxサーバー等で不要な場合は無視するか、必要に応じて `compose.yaml` を編集してください。
