#!/bin/bash
# 使い方: ./tmux-ssh.sh [<ユーザ名>] <サーバリストファイル>
# 例1: ./tmux-ssh.sh servers.txt  (ユーザ名はデフォルトのubuntu)
# 例2: ./tmux-ssh.sh myuser servers.txt  (ユーザ名を指定)
DEFAULT_USER="ubuntu"  # デフォルトのSSHユーザー名
# 引数のチェック
if [ $# -eq 0 ]; then
    echo "Usage: $0 [<username>] <server_list_file>"
    echo "  <username>: Optional SSH username (default: $DEFAULT_USER)"
    echo "  <server_list_file>: Required server list file"
    exit 1
elif [ $# -eq 1 ]; then
    SSH_USER="$DEFAULT_USER"
    SERVER_FILE="$1"
elif [ $# -eq 2 ]; then
    SSH_USER="$1"
    SERVER_FILE="$2"
else
    echo "Error: Too many arguments."
    echo "Usage: $0 [<username>] <server_list_file>"
    exit 1
fi
# サーバリストファイルの存在チェック
if [ ! -f "$SERVER_FILE" ]; then
    echo "Error: Server list file '$SERVER_FILE' not found."
    exit 1
fi
# サーバリストを配列に読み込む（古いBash対応）
SERVERS=()
while IFS= read -r line; do
    # 空行やコメント（#始まり）をスキップ（オプション）
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    SERVERS+=("$line")
done < "$SERVER_FILE"
if [ ${#SERVERS[@]} -eq 0 ]; then
    echo "Error: No servers found in '$SERVER_FILE'."
    exit 1
fi
# tmuxセッション内かをチェック
if [ -z "$TMUX" ]; then
    # tmuxセッション外の場合、新しいセッションを開始してウィンドウを作成
    SESSION_NAME="tmux"  # セッション名
    WINDOW_NAME="${SERVER_FILE%.txt}"  # ファイル名から拡張子を除去
    WINDOW_NAME="${WINDOW_NAME##*/}"   # パスを除去してファイル名のみ
    # 最初のサーバーでセッションを開始（ウィンドウ名を設定）
    tmux new-session -d -s "$SESSION_NAME" -n "$WINDOW_NAME" "ssh $SSH_USER@${SERVERS[0]}"
    # 残りのサーバーごとにペインを分割
    for ((i=1; i<${#SERVERS[@]}; i++)); do
        tmux split-window -t "$SESSION_NAME" -v "ssh $SSH_USER@${SERVERS[$i]}"
    done
    # レイアウトを横に均等配置
    tmux select-layout -t "$SESSION_NAME" even-vertical
    # ペイン同期を有効化
    tmux set-window-option -t "$SESSION_NAME" synchronize-panes on
    # 最初のペインを選択
    tmux select-pane -t "$SESSION_NAME":0.0
    # セッションにアタッチ
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi
# tmuxセッション内の場合、ウィンドウ名を設定
WINDOW_NAME="${SERVER_FILE%.txt}"  # ファイル名から拡張子を除去
WINDOW_NAME="${WINDOW_NAME##*/}"   # パスを除去してファイル名のみ
tmux rename-window "$WINDOW_NAME"
# 現在のペインで最初のサーバーにSSHログイン（履歴に残さない）
tmux send-keys " ssh $SSH_USER@${SERVERS[0]}" C-m
# 残りのサーバーごとにペインを分割してSSHログイン
for ((i=1; i<${#SERVERS[@]}; i++)); do
    tmux split-window -v "ssh $SSH_USER@${SERVERS[$i]}"  # -v で垂直分割（横に分割）
done
# レイアウトを横に均等配置（ペインを均等に配置）
tmux select-layout even-vertical
# ペイン同期を有効化（すべてのペインで入力を同期）
tmux setw synchronize-panes on
# 最初のペインを選択
tmux select-pane -t 0
echo "SSH panes created with synchronize-panes enabled."
