--行列演算ライブラリ
matrix = {
    --和(A+B)
    add = function(A, B)
        local C = {}
        for i = 1, #A do
            C[i] = {}
            for j = 1, #A[1] do
                C[i][j] = A[i][j] + B[i][j]
            end
        end
        return C
    end,

    --差(A-B)
    sub = function(A, B)
        local C = {}
        for i = 1, #A do
            C[i] = {}
            for j = 1, #A[1] do
                C[i][j] = A[i][j] - B[i][j]
            end
        end
        return C
    end,

    --積(A*B)
    mul = function(A, B)
        local C = {}
        for i = 1, #A do
            C[i] = {}
            for j = 1, #B[1] do
                local sum = 0
                for k = 1, #A[1] do
                    sum = sum + A[i][k]*B[k][j]
                end
                C[i][j] = sum
            end
        end
        return C
    end,

    --逆行列（ガウス・ジョルダン法）
    inv = function(A)
        local n, I, M = #A, {}, {}
        for i = 1, n do
            I[i] = {}
            M[i] = {}
            for j = 1, n do
                M[i][j] = A[i][j]
                I[i][j] = (i == j) and 1 or 0
            end
        end

        for i = 1, n do
            -- ピボット正規化
            local pivot = M[i][i]
            if pivot ~= 0 then
                for j = 1, n do
                    M[i][j] = M[i][j] / pivot
                    I[i][j] = I[i][j] / pivot
                end
                -- 他の行から消去
                for k = 1, n do
                    if k ~= i then
                        local factor = M[k][i]
                        for j = 1, n do
                            M[k][j] = M[k][j] - factor * M[i][j]
                            I[k][j] = I[k][j] - factor * I[i][j]
                        end
                    end
                end
            end
        end
        return I
    end,

    --転置
    transpose = function(A)
        local T = {}
        for i = 1, #A[1] do
            T[i] = {}
            for j = 1, #A do
                T[i][j] = A[j][i]
            end
        end
        return T
    end,

    --対角行列へ展開(xをn回)
    diag = function (x, n)
        local xRow, xColumn, M = #x, #x[1], {}

        -- 大きな行列を 0 で初期化
        for i = 1, xRow*n do
            M[i] = {}
            for j = 1, xColumn*n do
                M[i][j] = 0
            end
        end

        -- 各ブロックを対角に配置
        for k = 0, n-1 do
            local rowOffset, colOffset = k*xRow, k*xColumn
            for i = 1, xRow do
                for j = 1, xColumn do
                    M[rowOffset + i][colOffset + j] = x[i][j]
                end
            end
        end

        return M
    end
}

function printMatrix(M)
    for i = 1, #M do
        print(table.concat(M[i], "\t"))  -- 行をタブ区切りで結合
    end
end
A = {{1}}

--printMatrix(matrix.diag(A, 9))

A = {
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9}
}

printMatrix(matrix.diag(A, 3))