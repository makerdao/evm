# EVM
Experimental repository to write smart contracts directly in EVM bytecode without the use of Solidity or any other intermediate language

## Why?
Both EVM and Solidity are new and experimental technologies. Being able to get closer to the actual machine code that gets executed can provide significant advantages.

### Gas Efficency
In a context where gas prices are very high, being able to save gas can have a profound impact.

### Security
The Solidity compiler and the Solidity optimizer can introduce bugs. However, not having the guardrails and protections provided by these tools can also introduce bugs. Furthermore, the fact that fewer people are able to audit a smart contract written in bytecode is also a very troubling possible avenue for bugs.

## Improving Maker's Oracle infrastructure

### Medianizers
The [Medianizer](https://github.com/makerdao/median/blob/master/src/median.sol) is one of the gas-critical components of the MakerDAO smart contract infrastructure. It is the on-chain gateway of Maker's decentralized oracle network. Take a look at [this transaction](https://etherscan.io/tx/0xb76e20d0e31864ef7514190d174429336f88281c63a25179a76efa8e26f3e1aa). It costed 29 dollars at a moment when the network congestion was relatively low (59 Gwei). Since Maker's oracle relayers make several such calls a day, their annual cost can be extremely high, which has repercussions in Maker's security model.

### A medianizer implementation in bytecode
I wrote a proof-of-concept bytecode [implementation of the Medianizer](https://github.com/makerdao/evm/blob/main/src/median.evm) and [deployed it to Goerli](https://goerli.etherscan.io/address/0xdd4c4906a5da4a3a4e9d76591e8bbbe79dcedd40) in order to compare its gas consumption with the Solidity one. The results were as follows:

implementation | function | parameters | gas consumption | link
---------------|----------|------------|-----------------|------
Solidity       | poke     | bar: 13    | 138,303         | [https://etherscan.io/tx/0xb76e2...e1aa](https://etherscan.io/tx/0xb76e20d0e31864ef7514190d174429336f88281c63a25179a76efa8e26f3e1aa)
bytecode       | poke     | bar: 13    | 137,506         | [https://goerli.etherscan.io/tx/0x8108...74b9](https://goerli.etherscan.io/tx/0x81080f88711626a3415282581c3e5d4b23d148f12d7733147366ca6bbd4c74b9)

As you can see, the gas savings are modest. The bytecode implementation is 0.58% cheaper than the Solidity implementation. However, as EVM bytecode offers many possibilities for gas optimization, further research needs to be done in order to determine whether better results are possible.
