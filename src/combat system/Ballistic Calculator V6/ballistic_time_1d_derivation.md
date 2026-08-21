# 3次元・飛翔時間1変数型 弾道計算の導出

更新日: 2026-08-19

## 1. 目的

Stormworks の弾道計算を、仰角・方位角の多変数探索ではなく、飛翔時間 \(t\) の1次元求根へ縮約する。

本メモでは次を仮定する。

- 3次元空間
- 砲口を原点とする
- \(X,Y\) は水平面、\(Z\) は上向き
- 砲初速の大きさは一定
- 弾速減衰は線形
- 気圧一定
- 重力加速度一定
- ワールド風一定
- 風の \(Z\) 成分は 0
- 標的は等加速度運動
- 母機速度は今回は考慮しない
- ロケット推力は今回は考慮しない

求めるものは飛翔時間、方位角、仰角。

---

## 2. 入力パラメータ

砲口初速:

\[
V
\]

1 tick あたりの減速率:

\[
d
\]

標的初期位置:

\[
\mathbf R=
\begin{pmatrix}
R_x\\
R_y\\
R_z
\end{pmatrix}
\]

標的速度:

\[
\mathbf V_T=
\begin{pmatrix}
V_{Tx}\\
V_{Ty}\\
V_{Tz}
\end{pmatrix}
\]

標的加速度:

\[
\mathbf A_T=
\begin{pmatrix}
A_{Tx}\\
A_{Ty}\\
A_{Tz}
\end{pmatrix}
\]

ワールド風ベクトル:

\[
\mathbf W=
\begin{pmatrix}
W_x\\
W_y\\
0
\end{pmatrix}
\]

気圧を \(P\)、風影響度を \(C_W\)、重力加速度の大きさを \(g\) とする。

---

## 3. 1 tick 減速率から連続減衰係数への変換

1 tick 後に

\[
v\rightarrow(1-d)v
\]

となるとする。

連続時間モデルを

\[
v(t)=v_0e^{-kt}
\]

と置くと、

\[
e^{-k}=1-d
\]

なので、

\[
\boxed{
k=-\ln(1-d)
}
\]

となる。

---

## 4. 風加速度と重力

条件より風による弾丸加速度は

\[
\mathbf A_W=PC_W\mathbf W
\]

したがって、

\[
\mathbf A_W=
\begin{pmatrix}
PC_WW_x\\
PC_WW_y\\
0
\end{pmatrix}
\]

重力加速度ベクトルは、

\[
\mathbf G=
\begin{pmatrix}
0\\
0\\
-g
\end{pmatrix}
\]

よって線形抗力以外の弾丸加速度を

\[
\mathbf A_B=\mathbf A_W+\mathbf G
\]

とすると、

\[
\boxed{
\mathbf A_B=
\begin{pmatrix}
PC_WW_x\\
PC_WW_y\\
-g
\end{pmatrix}
}
\]

となる。

---

## 5. 発射方向

発射方向の単位ベクトルを

\[
\mathbf n=
\begin{pmatrix}
n_x\\
n_y\\
n_z
\end{pmatrix}
\]

とする。

\[
|\mathbf n|=1
\]

砲口初速ベクトルは、

\[
\boxed{
\mathbf v_0=V\mathbf n
}
\]

である。

通常なら \(\mathbf n\) の2自由度、すなわち仰角・方位角を探索するが、本方式ではこれらを解析的に消去する。

---

## 6. 弾丸の運動方程式

線形減衰と一定加速度より、

\[
\boxed{
\frac{d\mathbf v}{dt}
=
-k\mathbf v+\mathbf A_B
}
\]

初期条件は、

\[
\mathbf v(0)=V\mathbf n
\]

である。

これを解くと、

\[
\boxed{
\mathbf v(t)
=
Ve^{-kt}\mathbf n
+
\frac{\mathbf A_B}{k}(1-e^{-kt})
}
\]

となる。

---

## 7. 弾丸位置

砲口を原点とし、

\[
\mathbf r_B(0)=\mathbf 0
\]

とする。

速度を積分すると、

\[
\mathbf r_B(t)
=
V\mathbf n\frac{1-e^{-kt}}{k}
+
\mathbf A_B
\left[
\frac{t}{k}
-
\frac{1-e^{-kt}}{k^2}
\right]
\]

となる。

ここで、

\[
\boxed{
L(t)=\frac{1-e^{-kt}}{k}
}
\]

\[
\boxed{
M(t)=
\frac{t}{k}
-
\frac{1-e^{-kt}}{k^2}
}
\]

と定義すると、

\[
\boxed{
\mathbf r_B(t)
=
VL(t)\mathbf n
+
M(t)\mathbf A_B
}
\]

となる。

---

## 8. 標的未来位置

標的を等加速度運動とすれば、

\[
\boxed{
\mathbf r_T(t)
=
\mathbf R
+
\mathbf V_Tt
+
\frac12\mathbf A_Tt^2
}
\]

である。

---

## 9. 着弾条件

命中条件は、

\[
\mathbf r_B(t)=\mathbf r_T(t)
\]

である。

代入すると、

\[
VL(t)\mathbf n
+
M(t)\mathbf A_B
=
\mathbf R
+
\mathbf V_Tt
+
\frac12\mathbf A_Tt^2
\]

したがって、

\[
VL(t)\mathbf n
=
\mathbf R
+
\mathbf V_Tt
+
\frac12\mathbf A_Tt^2
-
M(t)\mathbf A_B
\]

となる。

ここで、

\[
\boxed{
\mathbf Q(t)
=
\mathbf R
+
\mathbf V_Tt
+
\frac12\mathbf A_Tt^2
-
M(t)\mathbf A_B
}
\]

と定義する。

すると、

\[
\boxed{
VL(t)\mathbf n=\mathbf Q(t)
}
\]

である。

---

## 10. 発射方向の解析消去

飛翔時間 \(t\) を固定すれば、

\[
\boxed{
\mathbf n=
\frac{\mathbf Q(t)}{VL(t)}
}
\]

と発射方向を逆算できる。

ただし \(\mathbf n\) は単位ベクトルなので、

\[
|\mathbf n|=1
\]

でなければならない。

よって、

\[
\frac{|\mathbf Q(t)|^2}{V^2L(t)^2}=1
\]

すなわち、

\[
\boxed{
|\mathbf Q(t)|^2=V^2L(t)^2
}
\]

が成立しなければならない。

したがって1次元関数

\[
\boxed{
F(t)
=
|\mathbf Q(t)|^2
-
V^2L(t)^2
}
\]

を定義し、

\[
\boxed{
F(t)=0
}
\]

を解けばよい。

これにより仰角・方位角は探索変数から完全に消去される。

---

## 11. 成分表示

\[
Q_x(t)
=
R_x
+
V_{Tx}t
+
\frac12A_{Tx}t^2
-
PC_WW_xM(t)
\]

\[
Q_y(t)
=
R_y
+
V_{Ty}t
+
\frac12A_{Ty}t^2
-
PC_WW_yM(t)
\]

\[
Q_z(t)
=
R_z
+
V_{Tz}t
+
\frac12A_{Tz}t^2
+
gM(t)
\]

したがって、

\[
\boxed{
F(t)
=
Q_x(t)^2
+
Q_y(t)^2
+
Q_z(t)^2
-
V^2
\left(
\frac{1-e^{-kt}}{k}
\right)^2
}
\]

を解けばよい。

完全形は、

\[
\boxed{
\begin{aligned}
F(t)
={}&
\left[
R_x+V_{Tx}t+\frac12A_{Tx}t^2
-PC_WW_x
\left(
\frac{t}{k}-\frac{1-e^{-kt}}{k^2}
\right)
\right]^2
\\
&+
\left[
R_y+V_{Ty}t+\frac12A_{Ty}t^2
-PC_WW_y
\left(
\frac{t}{k}-\frac{1-e^{-kt}}{k^2}
\right)
\right]^2
\\
&+
\left[
R_z+V_{Tz}t+\frac12A_{Tz}t^2
+g
\left(
\frac{t}{k}-\frac{1-e^{-kt}}{k^2}
\right)
\right]^2
\\
&-
V^2
\left(
\frac{1-e^{-kt}}{k}
\right)^2
\end{aligned}
}
\]

である。

---

## 12. 飛翔時間から方位角・仰角を求める

\(F(t)=0\) の根を \(t_*\) とする。

そのとき、

\[
\mathbf Q_*=\mathbf Q(t_*)
\]

を計算する。

命中解では、

\[
|\mathbf Q_*|=VL(t_*)
\]

なので、

\[
\mathbf n=
\frac{\mathbf Q_*}{|\mathbf Q_*|}
\]

で発射方向が得られる。

Stormworks で前方を \(+Y\)、右を \(+X\)、上を \(+Z\) とすれば、方位角は、

\[
\boxed{
\phi=
\operatorname{atan2}(Q_x,Q_y)
}
\]

仰角は、

\[
\boxed{
\theta=
\operatorname{atan2}
\left(
Q_z,
\sqrt{Q_x^2+Q_y^2}
\right)
}
\]

となる。

---

## 13. \(\mathbf Q(t)\) の物理的意味

標的未来位置は、

\[
\mathbf r_T(t)
\]

である。

一方、重力・風だけで弾丸が移動する分は、

\[
M(t)\mathbf A_B
\]

である。

よって、

\[
\mathbf Q(t)=\mathbf r_T(t)-M(t)\mathbf A_B
\]

は、

「重力と風による移動を差し引いた後、砲口初速が担当しなければならない変位」

を意味する。

砲口初速 \(V\) が減衰込みで時間 \(t\) の間に作れる変位の大きさは、

\[
VL(t)
=
V\frac{1-e^{-kt}}{k}
\]

である。

したがって、

\[
|\mathbf Q(t)|=VL(t)
\]

となる時間だけが物理的に実現可能な着弾時間である。

---

## 14. 無風・静止目標の場合

\[
\mathbf V_T=\mathbf 0,\qquad
\mathbf A_T=\mathbf 0,\qquad
\mathbf W=\mathbf 0
\]

なら、

\[
Q_x=R_x,\qquad
Q_y=R_y,\qquad
Q_z=R_z+gM(t)
\]

となる。

水平距離を

\[
R_h=\sqrt{R_x^2+R_y^2}
\]

とすると、

\[
\boxed{
F(t)
=
R_h^2+
[R_z+gM(t)]^2
-
[V L(t)]^2
}
\]

となる。

これは秋雨弾道計算機 `test10.lua` の時間方程式 `J(t)` と同型である。

---

## 15. 抗力ゼロ極限による検算

\(k\rightarrow0\) とすると、

\[
1-e^{-kt}
=
kt-\frac12k^2t^2+\cdots
\]

なので、

\[
L(t)\rightarrow t
\]

また、

\[
M(t)\rightarrow\frac12t^2
\]

となる。

したがって、

\[
\mathbf r_B(t)
=
Vt\mathbf n
+
\frac12\mathbf A_Bt^2
\]

となり、通常の等加速度運動へ一致する。

---

## 16. 低角解・高角解

同じ標的に対して \(F(t)=0\) が複数の正の根を持つ場合がある。

一般に、

\[
t_{\mathrm{low}}<t_{\mathrm{high}}
\]

となり、

- 短時間根 \(t_{\mathrm{low}}\): 低角解
- 長時間根 \(t_{\mathrm{high}}\): 高角解

に対応する。

したがって、

\[
\boxed{
\text{低角 / 高角}
\Longleftrightarrow
\text{短時間根 / 長時間根}
}
\]

と解釈できる。

---

## 17. 導関数

\[
F(t)=\mathbf Q\cdot\mathbf Q-V^2L^2
\]

なので、

\[
F'(t)
=
2\mathbf Q\cdot\mathbf Q'
-
2V^2LL'
\]

である。

\[
L'(t)=e^{-kt}
\]

また、

\[
M'(t)=L(t)
\]

である。

したがって、

\[
\mathbf Q'
=
\mathbf V_T
+
\mathbf A_Tt
-
L(t)\mathbf A_B
\]

よって、

\[
\boxed{
F'(t)
=
2\mathbf Q(t)\cdot
\left[
\mathbf V_T+\mathbf A_Tt-L(t)\mathbf A_B
\right]
-
2V^2L(t)e^{-kt}
}
\]

となる。

\(F'(t)=0\) の極値を使えば、低角枝・高角枝の根区間を分離できる可能性がある。

---

## 18. Lua 実装の最小形

```lua
k = -math.log(1 - drag)

function F(t)
    local e = math.exp(-k*t)
    local L = (1 - e)/k
    local M = t/k - (1 - e)/(k*k)

    local Qx = Rx + VTx*t + ATx*t*t/2 - Awx*M
    local Qy = Ry + VTy*t + ATy*t*t/2 - Awy*M
    local Qz = Rz + VTz*t + ATz*t*t/2 + g*M

    return Qx*Qx + Qy*Qy + Qz*Qz - (V*L)^2
end
```

ここで、

```lua
Awx = P*Cw*Wx
Awy = P*Cw*Wy
```

である。

Brent 法などで、

```lua
t = brent(F, tMin, tMax)
```

として根を求める。

その後、

```lua
local e = math.exp(-k*t)
local L = (1 - e)/k
local M = t/k - (1 - e)/(k*k)

local Qx = Rx + VTx*t + ATx*t*t/2 - Awx*M
local Qy = Ry + VTy*t + ATy*t*t/2 - Awy*M
local Qz = Rz + VTz*t + ATz*t*t/2 + g*M

local azimuth = math.atan(Qx, Qy)
local elevation = math.atan(Qz, math.sqrt(Qx*Qx + Qy*Qy))
```

とすれば、飛翔時間・方位角・仰角が得られる。

---

## 19. 1次元化が成立する本質

本方式が成立する理由は、固定した \(t\) に対して弾丸終点が初速度ベクトルの一次式になることにある。

\[
\boxed{
\mathbf r_B(t)
=
A(t)\mathbf v_0+\mathbf b(t)
}
\]

という形で書けるため、

\[
\mathbf v_0
=
\frac{\mathbf r_T(t)-\mathbf b(t)}{A(t)}
\]

と解析的に逆算できる。

その後、砲口初速の大きさが固定されている条件

\[
|\mathbf v_0|=V
\]

だけが残る。

したがって本来、

\[
(\theta,\phi,t)
\]

の3未知数として見える問題を、

\[
\boxed{
F(t)=0
}
\]

という飛翔時間1変数の問題へ縮約できる。

---

## 20. 現時点での制約と次の課題

この導出では次を仮定している。

- \(g\) 一定
- \(P\) 一定
- 風一定
- 線形抗力
- 風加速度一定
- 標的は等加速度運動
- 母機速度なし
- ロケット推力なし

高度依存の

\[
g(h),\qquad P(h)
\]

を入れると、環境が軌道そのものに依存するため、この式だけでは厳密解ではなくなる。

秋雨弾道計算機は、弾道全体の平均高度から代表環境を求め、

\[
t
\rightarrow
\theta
\rightarrow
\bar h
\rightarrow
g(\bar h),P(\bar h)
\rightarrow
t_{\mathrm{new}}
\]

という固定点反復で自己整合させている。

V6 では、この時間1変数構造を維持しながら、

- 高度依存重力
- 高度依存気圧
- Stormworks の離散更新則
- 母機速度
- ロケット推力
- 強風押し戻し弾道
- 多根探索

まで一般化できるかが次の検討課題となる。

---

## 21. 最終式

一定気圧・一定重力・線形抗力・一定風の3次元弾道問題は、

\[
\boxed{
F(t)
=
\left|
\mathbf R
+
\mathbf V_Tt
+
\frac12\mathbf A_Tt^2
-
M(t)\mathbf A_B
\right|^2
-
V^2L(t)^2
=0
}
\]

ただし、

\[
L(t)=\frac{1-e^{-kt}}{k}
\]

\[
M(t)=
\frac{t}{k}
-
\frac{1-e^{-kt}}{k^2}
\]

\[
k=-\ln(1-d)
\]

\[
\mathbf A_B=
\begin{pmatrix}
PC_WW_x\\
PC_WW_y\\
-g
\end{pmatrix}
\]

という1次元求根問題に縮約できる。

根 \(t_*\) が得られれば、

\[
\phi=
\operatorname{atan2}
(Q_x(t_*),Q_y(t_*))
\]

\[
\theta=
\operatorname{atan2}
\left(
Q_z(t_*),
\sqrt{Q_x(t_*)^2+Q_y(t_*)^2}
\right)
\]

から方位角・仰角を直接求められる。

すなわち、この条件下では仰角・方位角を独立に探索する必要はない。
