const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("EpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Leo", "Aang", "Pikachu"],
    [
      "bafybeibsifcmwkufr7zwh5s3ekvjkfj5nnadjhweniz4p7lxqelt7mbp74",
      "bafybeibsifcmwkufr7zwh5s3ekvjkfj5nnadjhweniz4p7lxqelt7mbp74",
      "bafybeibsifcmwkufr7zwh5s3ekvjkfj5nnadjhweniz4p7lxqelt7mbp74",
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
