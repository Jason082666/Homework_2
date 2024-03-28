# 2024-Spring-HW2

Please complete the report problem below:

## Problem 1

> Solution

step 1 : B -> A , amount in => 5.0000 , amount out => 5.655321988655321988
step 2 : A -> D , amount in => 5.655321988655321988 , amount out => 2.458781317097933552
step 3 : D -> C , amount in => 2.458781317097933552 , amount out => 5.088927293301515695
step 4 : C -> B , amount in => 5.088927293301515695 , amount out => 20.129888944077446732

## Problem 2

What is slippage in AMM, and how does Uniswap V2 address this issue? Please illustrate with a function as an example.

> Solution

Slippage refers to the difference between the expected price of a trade and the price at which the trade is executed. This discrepancy arises due to the price movement caused by the trade itself, especially in markets with lower liquidity where large orders can significantly move prices.

Uniswap V2 allows traders to specify a maximum slippage they are willing to accept for their trade. This is done through the transaction's parameters, where the user sets a minimum amount of the output token they are willing to accept. If the actual amount received from the trade, after considering the current state of the liquidity pool and the size of the trade, is less than this minimum, the transaction fails.

### function & example:

The price of a trade is determined by the product of the quantities of the two tokens in the liquidity pool, according to the formula x _ y = k, where x and y are the quantities of the two tokens, and k is a constant.
Supposed we have a liquidity pool with 10,000 units of Token A and 5,000 units of Token B, so k = 10000 _ 5000 = 50,000,000, You want to trade 1,000 units of Token A for Token B. So the amount_out will be : 5000 - 50000000 / (10000 + 1000) = 5000 - 4545.45 = 4545.55

So, you expect to receive 454.55 units of Token B for your 1,000 units of Token A.
If the expected price was 1 Token A for 0.5 Token B (based on the initial pool state), the expected amount of Token B for 1,000 units of Token A would be 500.
So the slippage will be (1 - 4545.55/500) \* 100 % = 9.09 %

## Problem 3

Please examine the mint function in the UniswapV2Pair contract. Upon initial liquidity minting, a minimum liquidity is subtracted. What is the rationale behind this design?

> Solution

In the Uniswap V2 Pair contract, a minimum liquidity amount of 10\*\*3 tokens are permanently locked by minting it to the zero address. This design decision serves several important purposes:

- Prevents Manipulation: By locking away a small amount of liquidity permanently, it prevents anyone from being able to completely drain the liquidity pool. This is particularly important in the initial phase when the liquidity pool might be small, and the total supply of liquidity tokens is zero. Without this mechanism, it would be theoretically possible for someone to add liquidity and then remove it all, including what was supposed to be the initial seed, leaving the pool empty.
- Creates a Non-zero Floor: The minting of a minimum liquidity to the zero address ensures that the total supply of the liquidity tokens starts above zero. This helps in avoiding issues related to division by zero in the liquidity math. By ensuring the total supply cannot start at zero, calculations for liquidity additions and removals are more straightforward and less prone to rounding errors.

## Problem 4

Investigate the minting function in the UniswapV2Pair contract. When depositing tokens (not for the first time), liquidity can only be obtained using a specific formula. What is the intention behind this?

> Solution

This intention is centered around maintaining the constant product formula, which is fundamental to Uniswap's automated market maker (AMM) model.

Uniswap V2, relies on the constant product formula x ∗ y = k for its liquidity pools, This formula ensures that the product of the quantities of the two tokens remains constant after every trade, excluding fees. The intention is to provide a mathematical model that ensures liquidity is always available, regardless of the size of the trade, although the price can vary based on the trade size.

### Minting Liquidity Tokens

When liquidity providers deposit tokens into a pool, they are minted liquidity tokens in proportion to their share of the pool. These tokens represent their share of the pool and can be burned to withdraw their portion of the pool's assets. The formula used for minting after the first deposit ensures that new liquidity providers receive a fair share of the pool based on the current ratio of the two assets in the pool.

### Specific Formula for Subsequent Deposits

For deposits made after the initial liquidity provision, the contract calculates the amount of liquidity tokens to mint based on the lesser of two ratios:

- The amount of token0 deposited relative to the existing amount of token0 in the pool, multiplied by the total supply of liquidity tokens.
- The amount of token1 deposited relative to the existing amount of token1 in the pool, multiplied by the total supply of liquidity tokens.
  This calculation ensures that the amount of liquidity tokens minted reflects the proportional increase in the pool's liquidity, maintaining fairness among all liquidity providers.

### Intention Behind the Formula

The primary intentions behind this specific minting formula are:

- Fair Distribution: Ensure that liquidity providers are rewarded in proportion to their contribution to the pool's liquidity. This encourages participation in the liquidity provision and maintains fairness in the distribution of fees collected from traders.
- Price Impact Minimization: The formula helps in maintaining the market's stability by ensuring that large deposits do not disproportionately affect the pool's price, thus minimizing the price impact of trades.
- Constant Product Maintenance: By adjusting the minting of liquidity tokens based on the current state of the pool, the formula helps in maintaining the constant product, which is crucial for the AMM model to function effectively.

## Problem 5

What is a sandwich attack, and how might it impact you when initiating a swap?

> Solution

A sandwich attack is a type of manipulation tactic in automated market maker (AMM) platforms. It targets users initiating token swaps on decentralized exchanges (DEXs). It has several steps :

- Detection of a Pending Swap: Attacker monitors the blockchain for pending swap transactions submitted by users to a DEX. These transactions are visible in the blockchain's memory pool before they are processed.
- Execution of the Attack: Once the attacker identifies a profitable swap transaction, they execute the attack by placing two transactions of their own, one before and one after the user's pending transaction, so the user's transaction is "sandwiched" between the attacker's transactions.
  - Front-Running Transaction: The attacker makes a transaction with a higher gas fee to ensure it gets processed before the user's transaction. This first transaction typically buys up the token that the user is aiming to buy, thereby increasing its price due to the added demand.
  - Back-Running Transaction: After the user's transaction is processed, which now buys the token at an inflated price, the attacker sells the token they previously bought, profiting from the artificially increased price. This second transaction also typically has a higher gas fee to ensure it gets processed immediately after the user's transaction.

Impact on the User:

- Financial Loss: The user ends up buying the token at an inflated price and may sell tokens at a deflated price, leading to immediate financial loss.
- Market Manipulation: Beyond individual losses, such attacks can contribute to market manipulation, leading to less stability and confidence in the DeFi ecosystem.
- Increased Transaction Costs: Users might feel compelled to increase their gas fees to outpace attackers, leading to unnecessarily high transaction costs.
