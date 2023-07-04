// use simple_contract::contract::ERC20;
use array::ArrayTrait;
use result::ResultTrait;
use traits::Into;

const name:felt252 = 'ERC20';
const symbol:felt252 = 'ERCT';
const account:felt252 = 01001111;

fn __set__up () -> felt252{
let mut calldata = ArrayTrait::new();
calldata.append(name);
calldata.append(symbol);
calldata.append(18);
let address = deploy_contract('ERC20', @calldata).unwrap();
return address;
}

#[test]
fn test_constructor(){
    let deployment_address = __set__up();
    let name = call(deployment_address, 'get_name', @ArrayTrait::new()).unwrap();
    let symbol = call(deployment_address, 'get_symbol', @ArrayTrait::new()).unwrap();
    assert(*name.at(0_u32) == 'ERC20', 'invalid name');
    assert(*symbol.at(0_u32) == 'ERCT', 'invalid symbol');
     
}

#[test]

fn test_mint(){
let deployment_address = __set__up();
let mut calldata = ArrayTrait::new();
let mint_amount = u256 {high: 20, low: 0};
calldata.append(account);
calldata.append(mint_amount.high.into());
calldata.append(mint_amount.low.into());
invoke(deployment_address, 'mint', @calldata).unwrap();

let mut calldata2 = ArrayTrait::new();
calldata2.append(account);
let retdata = call(deployment_address, 'balance_of',@calldata2).unwrap();
assert(*retdata.at(0_u32) != 0, 'amount_is_zero');
}