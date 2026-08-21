# Stormworks 弾道計算機比較・解析メモ

更新日: 2026-08-19

## 対象
- Ballistic Calculator V5
- test7.lua
- test8.lua
- test9.lua
- test10.lua

重要:
- 各 test*.lua は原則として別作者・別系統として扱う。
- test10.lua は test9.lua の作者が説明していた新方式に対応する実装とみられる。
- V5 は各ステップ内で解析解を使うため、単純なEuler法ではなく piecewise analytic integration に近い。

---

## 1. V5

### 基本思想
各区間で

\[
\dot v=-Kv+a
\]

を解析的に解く。

\[
v(t)=\left(v_0-\frac{a}{K}\right)e^{-Kt}+\frac{a}{K}
\]

\[
x(t)=x_0+
\frac{\left(v_0-\frac{a}{K}\right)(1-e^{-Kt})+at}{K}
\]

時間刻みではなく高度変化を基準に超広ステップを使う。

代表値:
```lua
ALT_INTERVAL = 2000
MIN_INTERVAL = 60*(ALT_INTERVAL/1000)
MAX_INTERVAL = sqrt(240*ALT_INTERVAL)
MAX_EULER = floor(3600/MIN_INTERVAL)
```

概ね

\[
\Delta t\approx\frac{2000}{|v_z|}
\]

で刻み、頂点付近は

\[
\Delta t_{max}=\sqrt{240\,ALT\_INTERVAL}
\]

とする。最大約11.5秒級。

各区間では時間平均高度に近い代表高度を求め、

\[
\bar h_i\rightarrow g(\bar h_i),\rho(\bar h_i)
\]

とする。

求解は方位角の外側求根＋仰角の内側求根。Brent/割線系。

強み:
- 移動目標
- 目標加速度
- 母機速度
- 風
- 高度依存重力
- 高度依存風影響
- 高角/低角
- ロケット
- 強風押し戻しのような特殊弾道
- 砲塔制御・スタビ

---

## 2. test7.lua

### 基本思想
固定刻み:

```lua
dt=6
```

6 tick = 0.1 s ごとに trajectory を進める。

各step内は解析解。

```lua
k_base=-log(1-base_drag)
ex=exp(-k_base*dt)
```

Stormworksの離散drag \(d\) に対し

\[
K=-\ln(1-d)
\]

を使う。

### LUT
高度0〜44 km程度について気圧と重力を100 m刻みでテーブル化し線形補間。

ただし
```lua
raw_h=(startH+py)/100
I=floor(max(0,min(441,raw_h)))
frac=raw_h-I
```
なので、範囲外では `I` だけclampされ `frac` が大きな外挿値になる可能性がある。

### solver
- 仰角: 二分法
- 方位角: 単純固定点補正

\[
\phi_{n+1}=\phi_n+(\phi_T-\phi_S)
\]

### 到達判定
標的方向の平面ではなく、

\[
x_s^2+z_s^2\ge x_T^2+z_T^2
\]

という射手中心の円筒面との交差。

### 成功判定の弱点
```lua
if abs(errY)<0.1 then f=true break end
```
で鉛直誤差だけを見て終了する。

さらに
```lua
if abs(next_th-th)<0.0001 then f=true break end
```
でも成功扱い。

横誤差が残っていても命中判定になる可能性がある。

### 実測
条件:
- 1500 m
- 曲射
- 風 30 m/s
- 風影響100%

結果:
- V5: 約5〜10 m誤差
- test7: 数十m、約50 m級
- test7: 約7 ms
- V5: 約1 ms

弾道計算部分だけなら7倍以上差がある可能性。

1500 mで2度の横角誤差なら

\[
1500\tan2^\circ\approx52.4\text{ m}
\]

で実測誤差と一致するため、主因は積分誤差より方位未収束・到達判定・成功判定の可能性が高い。

総評:
trajectory evaluator自体は十分細かいが、solver / hit criterion が弱い。

---

## 3. test8.lua

### 基本思想
弾丸を逐次数値積分せず、未知数を飛翔時間 \(t\) だけに落とす。

飛翔時間が決まれば

\[
\theta=\theta(t)
\]

\[
\phi=\phi(t)
\]

を解析的に逆算。

必要初速度の大きさが砲口初速に一致する条件

\[
|\mathbf v_0(t)|=V_0
\]

を1次元二分法で解く。

低角/高角は時間区間で分離。

長所:
- 非常に軽い
- 静止目標・定常環境では美しい
- trajectory loop不要

短所:
- 移動目標対応が弱い
- 高度依存環境なし
- 母機速度対応が限定的
- 特殊弾道の枝選択に制約

---

## 4. test9.lua（旧版）

解析式中心の時間1変数型。

- 移動目標
- 加速度目標
- 母機速度
- 風
- 高角/低角
- ロケット

まで解析式へ押し込む。

旧版の高角環境近似:

\[
P_{eff}=0.35P_{launch}+0.65P_{apex}
\]

後に test10.lua が作者説明に対応する新版だと判明。

---

## 5. test10.lua

### test9との最大の違い
旧版の2点平均が消え、

```lua
function aW(c)
    aD=s+_*K*sin(i.v)
    au=(c*aD/_^2-c^2*s/(2*_)+aD*(exp(-c*_)-1)/_^3)/c
    return au<0 and 0 or au
end
```

が追加。

これは弾道全体の時間平均高度を解析的に求める式。

---

## 6. test10 の平均高度解析

一定重力 \(g\)、線形抗力 \(k\)、初速 \(V_0\)、仰角 \(\theta\) なら

\[
v_y(t)=
\left(V_0\sin\theta+\frac{g}{k}\right)e^{-kt}
-\frac{g}{k}
\]

\[
h(t)=
\frac{g+kV_0\sin\theta}{k^2}(1-e^{-kt})
-\frac{g}{k}t
\]

飛翔時間 \(T\) 全体の時間平均高度:

\[
\bar h=
\frac1T\int_0^T h(t)dt
\]

積分すると

\[
\boxed{
\bar h=
\frac1T
\left[
\frac{AT}{k^2}
-\frac{gT^2}{2k}
+\frac{A(e^{-kT}-1)}{k^3}
\right]
}
\]

ただし

\[
A=g+kV_0\sin\theta
\]

これは `aW(c)` と一致。

つまり test10 は

\[
\boxed{
\bar h=\frac1T\int_0^T h(t)dt
}
\]

を数値積分なしで厳密に求める。

---

## 7. test10 の環境更新

```lua
aw=aW(c)
ag=aC*az(aw)*.965
s=30*exp(-1/60*aw/1000)
```

したがって

\[
\rho_{eff}=0.965\,\rho(\bar h)
\]

\[
g_{eff}=g(\bar h)
\]

重要:
直接

\[
\frac1T\int_0^T\rho(h(t))dt
\]

を求めているわけではない。

実際は

\[
\rho\left(\frac1T\int hdt\right)
\]

であり、

\[
\frac1T\int \rho(h)dt
\]

ではない。

---

## 8. test10 の自己整合反復

初期状態では標準環境で飛翔時間 \(T_0\) を求める。

その後、

\[
T_0
\rightarrow
\theta_0
\rightarrow
\bar h_0
\rightarrow
g(\bar h_0),\rho(\bar h_0)
\]

と更新。

更新環境で再び飛翔時間を求根。

\[
T_n
\rightarrow
\bar h_n
\rightarrow
(g_n,\rho_n)
\rightarrow
T_{n+1}
\]

という固定点反復。

さらに

```lua
c=(aV+c)/2
```

で

\[
T_{n+1}\leftarrow\frac{T_n+T_{new}}2
\]

とアンダーリラクゼーションを入れる。

---

## 9. V5 と test10 の関係

V5:

\[
\bar h_i
=
\frac1{\Delta t_i}
\int h_i(t)dt
\]

\[
g_i=g(\bar h_i),\qquad
\rho_i=\rho(\bar h_i)
\]

各区間ごとに環境を更新し、その区間を解析解で進める。

test10:

\[
\bar h
=
\frac1T\int_0^T h(t)dt
\]

\[
g_{eff}=g(\bar h),\qquad
\rho_{eff}=\rho(\bar h)
\]

飛翔時間全体を1区間として扱い、代表環境が自己整合するまで反復。

したがって、

\[
\boxed{
\text{test10 は V5 の1ステップを弾道全体まで巨大化した版に近い}
}
\]

違い:
- V5: 局所環境更新
- test10: 大域代表環境＋自己整合反復

---

## 10. 実測性能

- test10: 約2.1 ms
- V5: 約1.3 ms

V5は test10 より約38%軽い。

\[
\frac{1.3}{2.1}\approx0.62
\]

test10 は解析式型だが、外側自己整合反復と各反復内のBrent求根があるため、必ずしも軽くない。

V5は数値積分型に見えるが、実際には数十回程度の piecewise analytic evaluation しか行わない。

---

## 11. 1次元探索に落とせるのか？

重要な未解決テーマ。

一定条件下では本当に可能。

初速度ベクトル

\[
\mathbf v_0=(v_x,v_y,v_z)
\]

砲口初速固定:

\[
|\mathbf v_0|=V_0
\]

時刻 \(t\) に目標へ到達する条件から、もし

\[
\mathbf v_0=\mathbf v_0(t)
\]

と逆算できるなら、残る条件は

\[
\boxed{
|\mathbf v_0(t)|=V_0
}
\]

のみ。

したがって

\[
F(t)=|\mathbf v_0(t)|^2-V_0^2
\]

について

\[
\boxed{F(t)=0}
\]

を1次元求根すればよい。

根が得られれば

\[
\mathbf d=\frac{\mathbf v_0(t)}{V_0}
\]

から発射方向が直接得られる。

つまり仰角・方位角は独立探索変数ではなく、

\[
t\rightarrow\theta(t),\phi(t)
\]

となる。

自由度的にも、

未知数:
\[
(v_x,v_y,v_z,t)
\]

4個。

条件:
1. X位置一致
2. Y位置一致
3. Z位置一致
4. 初速大きさ固定

4個。

前3条件を解析消去できれば \(t\) だけが残る。

---

## 12. 低角・高角と多根

1次元だから根が1個とは限らない。

\[
t_{low},\quad t_{high}
\]

など複数根を持つ。

正確には

\[
\boxed{
\text{各弾道枝ごとに1次元探索}
}
\]

test10 は時間方程式の極値を使い低角/高角を分離。

極端な強風では、押し戻し弾道などでさらに複数根になる可能性がある。

ただし

\[
t\rightarrow\mathbf v_0(t)
\]

を一意に構築できる限り、2次元探索へ戻らず「1次元多根問題」として扱える可能性がある。

この点は未検証。

---

## 13. 1次元化が難しくなる要素

- 高度ごとに風向が変わる
- 非線形drag
- 速度二乗drag
- マグヌス効果
- 揚力
- 姿勢依存力
- 時間変化する制御入力
- 推力方向変化
- 地形衝突
- その他の状態依存非線形項

この場合は Broyden / shooting method / 2変数求根が必要になる可能性が高い。

---

## 14. V6 候補

### 案A: V5発展型
- 超広step維持
- Stormworks離散物理へ変更
- 3D直接trajectory
- 局所解析解
- 改良された代表環境
- 射程外早期棄却

### 案B: 局所Broyden
絶対仰角・方位角ではなく、初期発射方向からの局所偏差

\[
(\Delta\alpha,\Delta\beta)
\]

を解く。

ただしtest10の1次元化を見た後では、本当にBroydenが必要か再検討すべき。

### 案C: 飛翔時間1次元ソルバー
可能なら

\[
F(t)=|\mathbf v_0(t)|^2-V_0^2
\]

だけをBrentで解く。

角度探索を完全に消す。

---

## 15. 現時点の総評

### V5
現時点で総合性能トップ。

- 高精度
- 高速
- 柔軟
- 特殊弾道対応
- 実測約1.3 ms

### test10
外部コードでは最も興味深い。

- 数学的に美しい
- 飛翔時間1変数化
- 弾道全体の平均高度を解析積分
- 自己整合環境更新
- V5同等級またはそれ以上の精度を示すケース
- 実測約2.1 ms

### test8
静止目標・定常環境なら軽く美しい。

### test7
- 実測精度が低い
- 実測で重い
- solver / hit criterion に問題がある可能性
- 離散drag解釈やLUTは参考になる

---

## 16. 次スレッドで優先して考えるべきこと

### 16.1 本当にV6を1次元探索化できるか
- Stormworks離散物理でも \(\mathbf v_0(t)\) を逆算できるか
- 高度依存 \(g(h),\rho(h)\) をどう自己整合させるか
- 強風押し戻し弾道でも多根問題として処理できるか
- ロケット推力を含めても1次元化できるか
- 母機速度・目標加速度を完全に組み込めるか
- Stormworksの離散更新順序が逆算式にどう影響するか

### 16.2 平均高度ではなく実効環境を直接求める
V5/test10は概ね

\[
\bar h\rightarrow g(\bar h),\rho(\bar h)
\]

だが、

\[
\rho\left(\frac1T\int hdt\right)
\neq
\frac1T\int \rho(h)dt
\]

さらに風の着弾位置への影響なら、応答カーネル付きの重み付き平均

\[
\rho_{eff}
=
\frac{
\int_0^T w(t)\rho(h(t))dt
}{
\int_0^T w(t)dt
}
\]

の方が自然。

少数点求積や解析近似で安く出せれば、test10の軽さとV5の精度の中間を狙える。

---

## 17. 一言まとめ

- test7: 「安いstepを大量に回す」
- V5: 「高精度な巨大stepを少数だけ回す」
- test8: 「弾を飛ばさず飛翔時間を解く」
- test9: 「解析式へ極力押し込む旧版」
- test10: 「飛翔時間1変数 + 弾道全体の平均高度解析 + 自己整合反復」

最大の未解決テーマ:

\[
\boxed{
\text{そもそも弾道計算は仰角・方位角の2次元探索である必要があるのか？}
}
\]

test10は、

\[
\boxed{
\text{工夫すれば飛翔時間 }t\text{ の1次元探索へ縮約できる}
}
\]

可能性を強く示している。

ただしV6への一般化は未検証。
