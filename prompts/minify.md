# 目的：LifeBoatAPIでminifyしやすい形のコードを書く

## すべきこと
1. 下記の特徴及び制約、ミニファイ対象のコードを理解する
1. それに沿ってコード全文を修正する
1. 下記の手順を参考に修正後のコードをLifeBoatAPIでminifyする
1. `_build/out/release`の出力文字数を確認する
1. 文字数が前回より増えている場合は、原因を調査してコードを修正する
1. 最初のステップに戻り、再び修正・ミニファイを繰り返す
1. 文字数が減らなくなるまで繰り返す(最大ループ数は10回)

## 最適化の際すべきこと
- minifyの仕様上、原文コードは可読性を犠牲にする必要はない。可読性を維持しつつ最適化を行うこと。
- 適宜コメントを入れ、どのような意図のコードなのか明確にすること
- 個人的なLuaコーディングルールに従うこと
- 繰り返し処理をfor文にするなどの構文レベルの最適化を行う
- 不要な変数や関数の削除
- デバッグ用出力は削除しないこと
- 最終的に出力される値が同じであれば、処理内容が変わっても構わない
- コード全体をマクロで見たときの構文最適化を主任務とする

## CodexからLifeBoatAPIのminifyを実行する手順
VS Code拡張コマンド`lifeboatapi.build`はPowerShellから直接実行できない。Codexから実行する場合は、VS Code拡張`REST Control`を経由してVS Code内でコマンドを呼ぶ。

1. VS Codeで対象プロジェクトを開く
1. REST Controlの待受ポートは通常`37100`を使う。この環境ではVS Code左下のステータスバーに`RC Port: 37100`と表示されている
1. PowerShellからREST Controlへ疎通確認する

```powershell
Invoke-RestMethod -Uri "http://127.0.0.1:37100" -Method Post -ContentType "application/json" -Body '{"command":"custom.workspaceFolders"}'
```

1. 対象LuaファイルをVS Codeのアクティブエディタにしてから`lifeboatapi.build`を実行する。LifeBoatAPIはアクティブエディタから現在のworkspaceを決めるため、先に対象ファイルを開くこと

```powershell
$port = 37100
$target = "C:/Users/yosuk/OneDrive/Stormworks/Microcontrollers/src/combat system/FCS Type 8/FCS 8-1.lua"
$code = "vscode.workspace.openTextDocument(vscode.Uri.file('$target')).then(doc=>vscode.window.showTextDocument(doc)).then(()=>vscode.commands.executeCommand('lifeboatapi.build'))"
$body = @{ command = 'custom.eval'; args = @($code) } | ConvertTo-Json -Depth 10 -Compress
Invoke-RestMethod -Uri "http://127.0.0.1:$port" -Method Post -ContentType "application/json" -Body $body
```

1. 戻り値が`True`ならVS Code内でビルド開始できている。数秒待ってrelease出力を確認する

```powershell
Get-Item "C:/Users/yosuk/OneDrive/Stormworks/Microcontrollers/src/combat system/FCS Type 8/_build/out/release/fcs 8-1.lua" | Format-List FullName,LastWriteTime,Length
```

- `37100`で接続できない場合は、VS Code左下の`RC Port`が変わっている可能性がある。その場合だけ処理を中断し、ユーザーに現在の`RC Port`を確認する
- REST Controlは`restRemoteControl.port`が未設定の場合、workspace pathからポートを選ぶ。通常は同じworkspaceなら同じ値になるが、ポート衝突や設定変更があると変わる可能性がある
- `custom.eval`を使う理由は、REST Controlの通常コマンド引数では`Uri`型変換がうまく渡らない場合があるため
- `_build/_build.lua`をPowerShellから直接Lua実行するのは、VS Code拡張の実行環境と一致せず、正しいminify結果にならない場合がある

## LifeBoatAPIのminifyの特徴
- 出力場所は_build/out/release
- 出力されるファイル名は、もとのファイル名を全て小文字にしたものになる
- 全てのコメントや空白は削除される
- 文字数が4096文字以下で余裕があるなら、著者情報が自動で追加される
- 変数名は自動で短くなる
- a=math.sinのように、繰り返し使う関数も自動で短くなる
- 不要なlocalがあっても削除されない
- 構文レベルでの最適化は行われない（例：a=1+2はa=3に変換されない）

## FCS 8-1 copy.luaで確認したminifyの実例
- 24754文字程度の元ファイルが6444文字程度まで圧縮された。4096文字を超えるため、著者情報コメントは追加されなかった
- `---@section __LB_SIMULATOR_ONLY__`から`---@endsection`までのシミュレータ専用コードはrelease出力から削除される
- `onTick`と`onDraw`はStormworksの入口なので名前が保持される。それ以外の関数名は`euler2Qt`→`aO`、`mulQt`→`F`のように短縮される
- グローバル変数、ローカル変数、関数引数はいずれも短い名前へ置換される。元の意味がある名前はほぼ残らない
- `true`と`false`も`T=true`、`v=false`のように短い変数へ束縛され、以後は`T`/`v`で参照される
- `input`、`output`、`property`、`screen`、`math`、`table`などのライブラリは短い変数へ束縛される。例：`input`→`bV`、`output`→`cd`、`math`→`S`、`table`→`bo`、`screen`→`ck`
- 頻出するメンバ関数はさらに短縮される。例：`input.getNumber`→`a`、`output.setNumber`→`J`、`property.getNumber`→`cq`、`math.sin`→`j`、`math.cos`→`k`、`math.atan`→`ap`、`table.insert`→`aG`、`table.remove`→`cp`
- 低頻度の呼び出しは必ずしも個別短縮されない。今回の例では`string.match`は`string.match(...)`のまま残った
- `0.01`→`.01`、`0.1`→`.1`、`-0.25`→`-.25`のように、先頭の0は削られる
- スペース、インデント、コメントは削除されるが、完全な1行化ではない。`function`境界、`return`後、曖昧になりやすい連結箇所には改行が残る
- 文同士は可能なら空白なしで連結される。例：`R={}z={}function onTick()`や`dh={...}cW={...}`のようになる
- `local`宣言は名前短縮されても保持される。不要な`local`削除やスコープ整理は期待しない
- テーブルリテラルや式の構造は基本的に維持される。アルゴリズムの畳み込みや定数畳み込みを前提にしない
- 出力ファイル名は元ファイル名の空白を保ったまま小文字化される。`FCS 8-1 copy.lua`のrelease出力は`fcs 8-1 copy.lua`

## stormworksの制約
### Lua制約
- 現在の最大文字数は8192文字
- 使用可能な関数
  - pairs
  - ipairs
  - next
  - tostring
  - tonumber
- 使用可能な関数ライブラリ
  - math
  - table
  - string
- Stormworks特有の関数
  - onTick
    - 毎チック呼び出される
    - screenは呼び出し不可
  - onDraw
    - 描画毎に呼び出される
    - ディスプレイの枚数分呼び出される
    - input, outputは呼び出し不可
  - httpGet
  - httpReply
- Stormworks特有の関数ライブラリ
  - input
  - output
  - property
  - screen
### Stormworksの制約
- Physics Sensor
  - 左手系で出力される
  - 位置単位はm
  - 速度単位はm/s
  - 角速度単位はHz

## 個人的なLuaコーディングルール
- 変数名、関数名にはキャメルケースを使用する
- 定数は大文字スネークケースを使用する
- 一時的に使う変数は短い名前を使用する
  -例: x, y, z, i, j, k, a, b, c, Lx, Ly, Lz, Wx, Wy, Wzなど
- 処理内容ごとにセクションをdo-endなどの単一スコープで区切る(VS Codeの折りたたみ機能を活用するため)
- 全て右手系に統一している
- 一部左手系入力の値があるが、入力時点で右手系に変換する
- 単位
  - 位置: m
  - 速度: m/tick
  - 加速度: m/tick^2
  - 角速度: rad/tick