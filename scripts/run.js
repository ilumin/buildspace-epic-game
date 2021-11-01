const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("EpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Leo", "Aang", "Pikachu"],
    [
      "https://i.imgur.com/pKd5Sdk.png",
      "https://i.imgur.com/xVu4vFL.png",
      "https://i.imgur.com/WMB6g9u.png",
    ],
    [100, 200, 300],
    [100, 50, 25],
    "Elon Musk",
    "https://i.imgur.com/AksR0tt.png",
    10000,
    50
  );
  await gameContract.deployed();
  console.log(`Contract deployed to: ${gameContract.address}`);

  let txn;

  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();
  console.log(`Minted character NFT for player 0`);

  txn = await gameContract.mintCharacterNFT(1);
  await txn.wait();
  console.log(`Minted character NFT for player 1`);

  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();
  console.log(`Minted character NFT for player 2`);

  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();
  console.log(`Minted character NFT for player 3`);

  txn = await gameContract.attackBoss();
  await txn.wait();

  console.log(`Done deploying and minting!`);
};

const run = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

run();
