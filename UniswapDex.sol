
//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <=0.8.7;

import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";

// Network          : Goerli
// Factory          : 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
// Router Addresss  : 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
// USDC             : 0xD87Ba7A50B2E7E660f678A895E4B72E7CB4CCd9C
// USDT             : 0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49

// WETH             : 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
// usdc-weth        : 0x00B64e468d2C705A0907F58505536a6C8c49Ab26
// usdt-weth        : 0xFa06EAe0ea3540F6Ce2DfFfa15cB95E48E4f6470

contract UniswapDex{
IUniswapV2Factory factory;
IUniswapV2Router02 router;
IUniswapV2Pair USDC_WETH_PAIR;
IUniswapV2Pair USDT_WETH_PAIR;


constructor(address factoryAddress,address uniswapRouterAddress,address usdc_weth_pair_address,address usdt_weth_pair_address)public {
factory=IUniswapV2Factory(factoryAddress);
router=IUniswapV2Router02(uniswapRouterAddress);
USDC_WETH_PAIR=IUniswapV2Pair(usdc_weth_pair_address);
USDT_WETH_PAIR=IUniswapV2Pair(usdt_weth_pair_address);

}


// utitlity function to convert UniswapV2 pair into an array of addresses of tokens involved
function toAddressArray(IUniswapV2Pair _pair) public view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(IUniswapV2Pair(_pair).token0());
        path[1] = address(IUniswapV2Pair(_pair).token1());
        return path;
    }


/*
*
*   Swapping assets in realtime using Uniswap
*/
function swap(address tokenIn,uint amountIn, uint amountOutMin, address to) public {
    address[] memory usdt_weth_path = toAddressArray(USDT_WETH_PAIR); // give it in the correct format of array of addresses for swap function
    address[] memory usdc_weth_path = toAddressArray(USDC_WETH_PAIR); // give it in the correct format of array of addresses for swap function
    require(tokenIn==usdc_weth_path[0]|| tokenIn==usdc_weth_path[1] ||tokenIn==usdt_weth_path[0]|| tokenIn==usdt_weth_path[1],"Invalid Token Address");
    address[] memory path=new address[](2);

    if(tokenIn==usdc_weth_path[1]){
        path[0]=usdc_weth_path[1];
        path[1]=usdc_weth_path[0];

    }else if(tokenIn==usdt_weth_path[1]){
        path[0]=usdt_weth_path[1];
        path[1]=usdt_weth_path[0];

    }
    else if(tokenIn==usdt_weth_path[0]){
        path[0]=usdt_weth_path[0];
        path[1]=usdt_weth_path[1];

    }
    else{
    path[0]=usdc_weth_path[0];
    path[1]=usdc_weth_path[1];
    }

    // take tokens from user
    // Make sure you have sent the amountIn Tokens to the contract

    IERC20(tokenIn).transferFrom( msg.sender,address(this),amountIn);
    // approve the router contract to spend the tokens
    IERC20(tokenIn).approve( address( router),amountIn);
     
    // spend the tokens
    router.swapExactTokensForTokens(
        amountIn,
        amountOutMin,
        path,
        to, 
        block.timestamp + 60// if swap has not occured in a minute , cancle it
        ); 
  }


}
