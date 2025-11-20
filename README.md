# tmux-screenctl

tmux-screenctl は、tmux と SSH を使用して複数のサーバーに同時に接続し、操作を同期させるためのシェルスクリプトです。サーバーリストファイルからサーバー情報を読み込み、各サーバーに SSH 接続した tmux ペインを作成します。

## 機能

- サーバーリストファイルから複数のサーバーを読み込み
- tmux のペインを使用して各サーバーに SSH 接続
- ペイン間の入力を同期（synchronize-panes）
- tmux セッション内外での動作に対応

## 必要条件

- tmux
- SSH クライアント
- Bash

## インストール

このリポジトリをクローンまたはダウンロードしてください。

```bash
git clone https://github.com/yourusername/tmux-screenctl.git
cd tmux-screenctl
```

### 手動インストール

```bash
chmod +x tmux-ssh.sh
# tmux-ssh.sh を PATH の通った場所（例: /usr/local/bin）にコピー
sudo cp tmux-ssh.sh /usr/local/bin/tmux-ssh
sudo chmod +x /usr/local/bin/tmux-ssh
```

### インストールスクリプトを使用

```bash
chmod +x install.sh
./install.sh
```

インストール後、既存のシェルセッションでも `tmux-ssh` コマンドが使用可能になります。tab 補完が機能しない場合は、zsh で `rehash` を実行してください。

## 使用方法

インストール後、以下のコマンドを使用してください。

```bash
tmux-ssh [<username>] <server_list_file>
```

### 引数

- `<username>`: オプション。SSH ユーザー名（デフォルト: ubuntu）
- `<server_list_file>`: 必須。サーバーリストファイルのパス

### 例

1. デフォルトユーザー（ubuntu）でサーバーリストを使用:
   ```bash
   tmux-ssh servers.txt
   ```

2. ユーザー名を指定:
   ```bash
   tmux-ssh myuser servers.txt
   ```

### サーバーリストファイルの形式

サーバーリストファイルは、各行に1つのサーバーアドレスを記述します。空行や `#` で始まる行は無視されます。

例: `servers.txt`
```
server1.example.com
server2.example.com
# コメント行
server3.example.com
```

## 動作

- tmux セッション外の場合: 新しい tmux セッションを作成し、ウィンドウにペインを分割して SSH 接続します。
- tmux セッション内の場合: 現在のウィンドウでペインを分割して SSH 接続します。
- すべてのペインで入力を同期するため、一つのペインでのコマンドがすべてのサーバーに適用されます。

## 注意事項

- SSH キーが設定されていることを確認してください。
- サーバーリストファイルは実行権限は不要ですが、読み取り可能である必要があります。

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。