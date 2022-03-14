const hre = require('hardhat');
const { LedgerSigner } = require('@anders-t/ethers-ledger');

async function main () {
  const ledger = new LedgerSigner(hre.ethers.provider);
  const Jump = await hre.ethers.getContractFactory('JumpMultiToken');
  const contractFactory = await Jump.connect(ledger);
  const jump = await contractFactory.deploy();
  await jump.deployed();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
