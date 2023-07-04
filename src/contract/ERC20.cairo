#[contract]

mod ERC20{

    use starknet::ContractAddress;
    use zeroable::Zeroable;
    use starknet::contract_address_const;
    use integer::BoundedInt;
    use starknet::get_caller_address;

    struct Storage{
        _name:felt252,
        _symbol:felt252,
        _decimal:u8,
        _total_supply: u256,
        _balances: LegacyMap::<ContractAddress, u256>,
        _allowance: LegacyMap::<(ContractAddress, ContractAddress), u256>
  }

    #[event]
    fn Transfer(from:ContractAddress, to:ContractAddress, amount:u256){}
    
    #[event]
    fn  Approval(owner:ContractAddress, spender:ContractAddress, amount:u256){}

    #[constructor]
    fn constructor(name:felt252, symbol:felt252, decimal:u8){
        _name::write(name);
        _symbol::write(symbol);
        _decimal::write(decimal);
    }

    #[view]
    fn get_name() -> felt252{
    return _name::read();
    }

    #[view]
    fn get_symbol() -> felt252{
    return _symbol::read();
    }

    #[view]

    fn get_decimal() -> u8 {
    return _decimal::read();
    }

    #[view]
    fn get_total_supply() -> u256{
    return _total_supply::read();
    }  

    #[view]
    fn balance_of(account: ContractAddress)-> u256{
    return _balances::read(account);
    }

    #[view]

    fn get_allowance(owner:ContractAddress, spender:ContractAddress) -> u256{
    return  _allowance::read((owner,spender));
    }

    #[external]
    fn mint(recipient:ContractAddress, amount: u256) {
    assert(!recipient.is_zero(), 'ERC20: address_zero');
    // read prev total supply
    let prev_total_supply = _total_supply::read();
    // read prev recipient balance
    let prev_recipient_balance = _balances::read(recipient);
    // update total_supply
    _total_supply::write(prev_total_supply + amount);
    // update user balance
    _balances::write(recipient, prev_recipient_balance + amount);
    Transfer(Zeroable::zero(), recipient, amount);
    }


    #[external]
    fn transfer_from(from:ContractAddress, to:ContractAddress, amount:u256) -> bool{
        let msgSender = get_caller_address();
        // _spend_allowance
        _spend_allowance(from, msgSender, amount);
        //_transfer
        _transfer(from, to, amount);
        return true;
    } 

    #[external]
    fn transfer(from:ContractAddress, to:ContractAddress, amount:u256) -> bool{
        assert(!to.is_zero(), 'Address_zero');
        _transfer(from, to, amount);
        return true;
    }

        #[internal]
    fn burn(account:ContractAddress, amount:u256) {
    assert(!account.is_zero(), 'ERC20: address_zero');
    _total_supply::write(_total_supply::read() - amount);
    _balances::write(account, _balances::read(account) - amount);
    Transfer(Zeroable::zero(), account, amount);
    }

    #[internal]
    fn _transfer(from:ContractAddress, to:ContractAddress, amount:u256){
        assert(!from.is_zero(), 'ERC20: address_zero');
        assert(!to.is_zero(), 'ERC20: address_zero');
        // alice send bob
        _balances::write(from, _balances::read(from) - amount);
        _balances::write(to, _balances::read(to) + amount);
    }



    #[internal]
    fn _approve(owner:ContractAddress, spender:ContractAddress, amount:u256) {
    assert(!owner.is_zero(), 'ERC20: address_zero');
    assert(!spender.is_zero(), 'ERC20: address_zero');
    _allowance::write((owner, spender), amount);
    Approval(owner, spender, amount);
    }

    #[internal]
    fn _spend_allowance(owner:ContractAddress, spender:ContractAddress, amount:u256){
        let current_allowance = _allowance::read((owner, spender));
        if current_allowance != BoundedInt::max(){
            _approve(owner, spender, current_allowance - amount);
        }
    }
}