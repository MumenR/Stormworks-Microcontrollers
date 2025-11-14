function think()
    if math.random() > 0.5 then
        return "はい"
    else
        think()
    end
end

print("考えた結果:", think())


