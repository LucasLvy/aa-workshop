use core::option::OptionTrait;
use starknet::ContractAddress;
use snforge_std::signature::StarkCurveKeyPairTrait;
use snforge_std::{ start_spoof, stop_spoof, start_prank, stop_prank };
use aa::{ IAccountDispatcher, IAccountDispatcherTrait };
use super::utils::{deploy_contract, create_call_array_mock, create_tx_info_mock };

#[test]
fn accept_valid_tx_signature() {
    let mut signer = StarkCurveKeyPairTrait::from_private_key(123);
    let contract_address = deploy_contract(signer.public_key);
    let dispatcher = IAccountDispatcher{ contract_address };

    let tx_hash_mock = 123;
    let tx_version_mock = 1;
    let tx_info_mock = create_tx_info_mock(tx_hash_mock, ref signer, tx_version_mock);

    let call_array_mock = create_call_array_mock();
    let zero_address: ContractAddress = 0.try_into().unwrap();

    start_prank(contract_address, zero_address);
    start_spoof(contract_address, tx_info_mock);
    dispatcher.__validate__(call_array_mock);
    stop_spoof(contract_address);
    stop_prank(contract_address);
}

#[test]
#[should_panic]
fn reject_invalid_tx_signature() {
    let mut signer = StarkCurveKeyPairTrait::from_private_key(123);
    let contract_address = deploy_contract(signer.public_key);
    let dispatcher = IAccountDispatcher{ contract_address };

    let tx_hash_mock = 123;
    let mut hacker = StarkCurveKeyPairTrait::from_private_key(456);
    let tx_version_mock = 1;
    let tx_info_mock = create_tx_info_mock(tx_hash_mock, ref hacker, tx_version_mock);

    let call_array_mock = create_call_array_mock();
    let zero_address: ContractAddress = 0.try_into().unwrap();

    start_prank(contract_address, zero_address);
    start_spoof(contract_address, tx_info_mock);
    dispatcher.__validate__(call_array_mock);
    stop_spoof(contract_address);
    stop_prank(contract_address);
}

