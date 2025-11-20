#!/bin/bash

# tmux-ssh インストールスクリプト

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# tmux-ssh.sh を /usr/local/bin/tmux-ssh にコピー
echo "tmux-ssh.sh を /usr/local/bin/tmux-ssh にコピーします..."
sudo cp "$SCRIPT_DIR/tmux-ssh.sh" /usr/local/bin/tmux-ssh

# 実行権限を付与
echo "実行権限を付与します..."
sudo chmod +x /usr/local/bin/tmux-ssh

# ~/.zshrc に PATH を追加（重複を避ける）
if ! grep -q 'export PATH="/usr/local/bin:$PATH"' ~/.zshrc; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
    echo "PATH を ~/.zshrc に追加しました。"
else
    echo "PATH は既に ~/.zshrc に設定されています。"
fi

# ~/.zshrc を再読み込みして既存のセッションで有効にする
# zsh で実行されている場合
if [ -n "$ZSH_VERSION" ]; then
    source ~/.zshrc
    rehash  # コマンドハッシュを更新して補完を有効にする
# bash で実行されている場合、zsh を呼び出して source と rehash
elif [ -n "$BASH_VERSION" ]; then
    zsh -c "source ~/.zshrc && rehash"
    hash -r  # bash のコマンドハッシュを更新
fi

echo "インストール完了！"
echo "tmux-ssh が /usr/local/bin に配置され、実行権限が付与されました。"
echo "既存のシェルセッションでも tmux-ssh を使用できます。"