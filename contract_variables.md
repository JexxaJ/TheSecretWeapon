THex token address  0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39



tokenA = 0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39
tokenB = 0x5A9780Bfe63f3ec57f01b087cD65BD656C9034A8
tokenA_amount = 99
tokenB_amount = 1
total_tokenA_threshold = 700000000
liquidityPool = 0x5aDbcC7885311Fc621B3Ac59D685b355Ae4507F5


ERC20 public lpToken = ERC20(0x...); // The address of the LP token





in baseV2 we are using a constructor arg lpToken 
we will not know what the LP token is going to be at the time of contract creation so this cannot be defined at this point. also looking through the code I do not see where this is referenced for use at any point. do we need it?