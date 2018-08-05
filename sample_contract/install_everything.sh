#!/bin/bash



#install Loom binary
echo "Install Loom binary"
#su -c "wget https://private.delegatecall.com/loom/linux/build-330/loom -O /usr/local/bin/loom; chmod +x /usr/local/bin/loom" || true

#install Truffle framework
echo "Install Truffle framework"
#su -c "npm -g install truffle" || true

#install Loom and Truffle javascript API
#npm install loom-js --save
#npm install loom-truffle-provider --save

#install Web3.js
#npm install web3




#init empty blockchain
loom init

# start Loom blockchain
loom run &
sleep 5



# create new directory for the new contract project
mkdir contract
cd contract

#setup new Truffle project
truffle init

#create RSA keypair for the new contract
loom genkey -a public.key -k private.key

#write sample contract code
cat <<EOF >contracts/SimpleStore.sol

pragma solidity ^0.4.22;

contract SimpleStore {
  uint value;

  event NewValueSet(uint _value);

  function set(uint _value) public {
    value = _value;
    emit NewValueSet(value);
  }

  function get() public view returns (uint) {
    return value;
  }
}

EOF

#indicate the new "migration" is the new contract
cat <<EOF >migrations/2_simplestore.js

var SimpleStore = artifacts.require("./SimpleStore.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStore);
};

EOF

#tell Truffle to install contract on the Loom blockchain
cat <<EOF >truffle.js

const { readFileSync } = require('fs')
const LoomTruffleProvider = require('loom-truffle-provider')

const chainId    = 'default'
const writeUrl   = 'http://127.0.0.1:46658/rpc'
const readUrl    = 'http://127.0.0.1:46658/query'
const privateKey = readFileSync('./private.key', 'utf-8')

const loomTruffleProvider = new LoomTruffleProvider(chainId, writeUrl, readUrl, privateKey)

module.exports = {
  networks: {
    loom_dapp_chain: {
      provider: loomTruffleProvider,
      network_id: '*'
    }
  }
}

EOF

#perform the installation
truffle deploy --network loom_dapp_chain

#get the newly deployed contract address
contract_address="$(cat build/contracts/SimpleStore.json | fgrep 'address' | cut -d'"' -f4)"
echo "CONTRACT_ADDRESS: ${contract_address}"

#exit the contract project directory
cd ..



#contract test script
cat <<EOF >test_contract.js
const {
  NonceTxMiddleware, SignedTxMiddleware, Client,
  Contract, Address, LocalAddress, CryptoUtils
} = require('loom-js')
const { readFileSync } = require('fs')
const LoomTruffleProvider = require('loom-truffle-provider')
const Web3 = require('web3')

// Generate "user" RSA keypair for interacting with the contract.
const privateKey = CryptoUtils.generatePrivateKey()
const publicKey = CryptoUtils.publicKeyFromPrivateKey(privateKey)
const from = LocalAddress.fromPublicKey(publicKey).toString()

//
const chainId    = 'default'
const writeUrl   = 'http://127.0.0.1:46658/rpc'
const readUrl    = 'http://127.0.0.1:46658/query'
const loomTruffleProvider = new LoomTruffleProvider(chainId, writeUrl, readUrl, privateKey)
const loomProvider = loomTruffleProvider.getProviderEngine()
const web3 = new Web3(loomProvider)

// SimpleStore contract ABI (set, get, NewValueSet).
const ABI = [{"anonymous":false,"inputs":[{"indexed":false,"name":"_value","type":"uint256"}],"name":"NewValueSet","type":"event"},{"constant":false,"inputs":[{"name":"_value","type":"uint256"}],"name":"set","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}]

// Contract address (
const contractAddress = process.argv[2]
console.log(contractAddress)

// Instantiate the contract and let it ready to be used.
const contract = new web3.eth.Contract(ABI, contractAddress, {from})

// Work with the contract.
async function work_with_contract() {
  const tx = await contract.methods.set(79).send()
  const value = await contract.methods.get().call()
  console.log("If we are here, that means the contract worked. (" + value + ")")
}

work_with_contract()

EOF

#test the newly deployed contract
node test_contract.js "${contract_address}"



#kill the blockchain process
killall loom

