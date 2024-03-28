// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ISwapV2Router02} from "../src/Arbitrage.sol";

contract Token is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialMint) ERC20(name, symbol) {
        _mint(msg.sender, initialMint);
    }
}

contract Arbitrage is Test {
    Token tokenA;
    Token tokenB;
    Token tokenC;
    Token tokenD;
    Token tokenE;
    address owner = makeAddr("owner");
    address arbitrager = makeAddr("arbitrageMan");
    ISwapV2Router02 router = ISwapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function _addLiquidity(address token0, address token1, uint256 token0Amount, uint256 token1Amount) internal {
        router.addLiquidity(
            token0,
            token1,
            token0Amount,
            token1Amount,
            token0Amount,
            token1Amount,
            owner,
            block.timestamp
        );
    }

    function setUp() public {
        vm.createSelectFork(vm.envString("RPC_URL"));
        vm.startPrank(owner);

        uint256 initialSupply = 100 ether;

        tokenA = new Token("tokenA", "A", initialSupply);
        tokenB = new Token("tokenB", "B", initialSupply);
        tokenC = new Token("tokenC", "C", initialSupply);
        tokenD = new Token("tokenD", "D", initialSupply);
        tokenE = new Token("tokenE", "E", initialSupply);

        tokenA.approve(address(router), initialSupply);
        tokenB.approve(address(router), initialSupply);
        tokenC.approve(address(router), initialSupply);
        tokenD.approve(address(router), initialSupply);
        tokenE.approve(address(router), initialSupply);

        _addLiquidity(address(tokenA), address(tokenB), 17 ether, 10 ether);
        _addLiquidity(address(tokenA), address(tokenC), 11 ether, 7 ether);
        _addLiquidity(address(tokenA), address(tokenD), 15 ether, 9 ether);
        _addLiquidity(address(tokenA), address(tokenE), 21 ether, 5 ether);
        _addLiquidity(address(tokenB), address(tokenC), 36 ether, 4 ether);
        _addLiquidity(address(tokenB), address(tokenD), 13 ether, 6 ether);
        _addLiquidity(address(tokenB), address(tokenE), 25 ether, 3 ether);
        _addLiquidity(address(tokenC), address(tokenD), 30 ether, 12 ether);
        _addLiquidity(address(tokenC), address(tokenE), 10 ether, 8 ether);
        _addLiquidity(address(tokenD), address(tokenE), 60 ether, 25 ether);

        tokenB.transfer(arbitrager, 5 ether);
        vm.stopPrank();
    }

    function testHack() public pure {
        console2.log("Happy Hacking!");
    }

    function testExploit() public {
        vm.startPrank(arbitrager);
        uint256 tokensBefore = tokenB.balanceOf(arbitrager);
        console.log("Before Arbitrage tokenB Balance: %s", tokensBefore);
        tokenB.approve(address(router), 5 ether);
        /**
         * Please add your solution below
         */
        // 定義交換的路徑
        address[] memory pathBtoA = new address[](2);
        pathBtoA[0] = address(tokenB);
        pathBtoA[1] = address(tokenA);
        
        address[] memory pathAtoD = new address[](2);
        pathAtoD[0] = address(tokenA);
        pathAtoD[1] = address(tokenD);
        
        address[] memory pathDtoC = new address[](2);
        pathDtoC[0] = address(tokenD);
        pathDtoC[1] = address(tokenC);
        
        address[] memory pathCtoB = new address[](2);
        pathCtoB[0] = address(tokenC);
        pathCtoB[1] = address(tokenB);
        
        // 執行交換

        // B -> A
        router.swapExactTokensForTokens(
            5 ether, // amountIn
            0, // amountOutMin, 設為 0 假定交易不會失敗
            pathBtoA,
            address(arbitrager),
            block.timestamp + 120 // deadline
        );
        
        uint256 tokenABalance = tokenA.balanceOf(address(arbitrager));
        tokenA.approve(address(router), tokenABalance);
        console.log("b->a", tokenABalance);
        // A -> D
        router.swapExactTokensForTokens(
            tokenABalance,
            0,
            pathAtoD,
            address(arbitrager),
            block.timestamp + 120
        );
        
        uint256 tokenDBalance = tokenD.balanceOf(address(arbitrager));
        tokenD.approve(address(router), tokenDBalance);       
    console.log("a->d", tokenDBalance);
        // D -> C
        router.swapExactTokensForTokens(
            tokenDBalance,
            0,
            pathDtoC,
            address(arbitrager),
            block.timestamp + 120
        );

        uint256 tokenCBalance = tokenC.balanceOf(address(arbitrager));
        tokenC.approve(address(router), tokenCBalance);
        console.log("d->c", tokenCBalance);
        // C -> B
        router.swapExactTokensForTokens(
            tokenCBalance,
            0,
            pathCtoB,
            address(arbitrager),
            block.timestamp + 120
        );

        // /**
        //  * Please add your solution above
        //  */
        uint256 tokensAfter = tokenB.balanceOf(arbitrager);
        assertGt(tokensAfter, 20 ether);
        console.log("After Arbitrage tokenB Balance: %s", tokensAfter);
    }
}
