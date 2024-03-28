import itertools

liquidity = {
    ("tokenA", "tokenB"): (17, 10),
    ("tokenA", "tokenC"): (11, 7),
    ("tokenA", "tokenD"): (15, 9),
    ("tokenA", "tokenE"): (21, 5),
    ("tokenB", "tokenC"): (36, 4),
    ("tokenB", "tokenD"): (13, 6),
    ("tokenB", "tokenE"): (25, 3),
    ("tokenC", "tokenD"): (30, 12),
    ("tokenC", "tokenE"): (10, 8),
    ("tokenD", "tokenE"): (60, 25),
}

# 計算交換函數，不考慮交換後流動池的代幣數量變化，因設計的演算法中不同的代幣交換對最多只用一次
def calculate_exchange(balance, from_token, to_token, liquidity):
    if (from_token, to_token) in liquidity:
        reserve_from, reserve_to = liquidity[(from_token, to_token)]
    else:
        reserve_to, reserve_from = liquidity[(to_token, from_token)]
    # 利用 x * y = k 的公式來計算交換後的 balance ，且不考慮 gas 
    k = reserve_from * reserve_to
    new_reserve_from = reserve_from + balance
    new_reserve_to = k / new_reserve_from
    balance_after = reserve_to - new_reserve_to
    return balance_after

# 遍歷所有交換路徑
tokens = ['tokenA', 'tokenC', 'tokenD', 'tokenE']  # tokenB 作為開頭與結束，不放在 list 當中
best_balance = 0
best_path = []

for path in itertools.permutations(tokens, 3):  # 只考慮交換路徑為 3 的情況，避免算法複雜
    path = ['tokenB'] + list(path) + ['tokenB']
    balance = 5  # 設定初始 token B 的 balance
    for i in range(len(path) - 1):
        balance = calculate_exchange(balance, path[i], path[i+1], liquidity)
        if balance <= 0:
            break  # 如果餘額變成負值，則跳出
    if balance > best_balance:
        best_balance = balance
        best_path = path

# 輸出結果
print(f"Best path: {'->'.join(best_path)}, tokenB balance={best_balance:.6f}")
