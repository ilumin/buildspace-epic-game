// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

import "./libraries/Base64.sol";

contract EpicGame is ERC721 {

  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint attackDamage;
  }

  struct BigBoss {
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint attackDamage;
  }

  BigBoss public bigBoss;

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  CharacterAttributes[] defaultCharacters;

  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  mapping(address => uint256) public nftHolders;

  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
  event AttackCompleted(uint256 newBossHp, uint256 newPlayerHp);

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg,
    string memory bigBossName,
    string memory bigBossImageURI,
    uint bigBossHp,
    uint bigBossAttackDmg
  ) 
  ERC721("Heroes", "HERO") 
  {
    bigBoss = BigBoss({
      name: bigBossName,
      imageURI: bigBossImageURI,
      hp: bigBossHp,
      maxHp: bigBossHp,
      attackDamage: bigBossAttackDmg
    });

    console.log(
      "Done initializing boss %s w/ HP %s, img %s",
      bigBoss.name,
      bigBoss.hp,
      bigBoss.imageURI
    );

    for (uint i = 0; i < characterNames.length; i++) {
      defaultCharacters.push(
        CharacterAttributes({
          characterIndex: i,
          name: characterNames[i],
          imageURI: characterImageURIs[i],
          hp: characterHp[i],
          maxHp: characterHp[i],
          attackDamage: characterAttackDmg[i]
        })
      );
      
      CharacterAttributes memory character = defaultCharacters[i];

      console.log(
        "Done initializing %s w/ HP %s, img %s", 
        character.name, 
        character.hp, 
        character.imageURI
      );
    }

    _tokenIds.increment();
  }

  function mintCharacterNFT(uint _characterIndex) external {
    uint256 newItemId = _tokenIds.current();

    _safeMint(msg.sender, newItemId);

    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage
    });

    console.log(
      "Minted NFT w/ tokenId %s and characterIndex %s",
      newItemId,
      _characterIndex
    );

    nftHolders[msg.sender] = newItemId;

    _tokenIds.increment();

    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    CharacterAttributes memory character = nftHolderAttributes[_tokenId];

    string memory strHp = Strings.toString(character.hp);
    string memory strMaxHp = Strings.toString(character.maxHp);
    string memory strAttackDamage = Strings.toString(character.attackDamage);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name":"',
            character.name,
            ' -- NFT #: ',
            Strings.toString(_tokenId),
            '","description":"',
            'This is an NFT that lets people play in the game Metaverse Slayer!',
            '","image": "',
            character.imageURI,
            '","attributes":[',
            '{"trait_type":"Health Points","value":',strHp,',"maxValue":',strMaxHp,'},',
            '{"trait_type":"Attack Damage","value":',strAttackDamage,'}',
            ']}'
          )
        )
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    return output;
  }

  function attackBoss() public {
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

    console.log("\nPlayer /w character %s attacked boss! Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
    console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

    require(player.hp > 0, "Player has no health points left!");
    require(bigBoss.hp > 0, "Boss has no health points left!");

    if (bigBoss.hp < player.attackDamage) {
      bigBoss.hp = 0;
    } else {
      bigBoss.hp -= player.attackDamage;
    }

    if (player.hp < bigBoss.attackDamage) {
      player.hp = 0;
    } else {
      player.hp -= bigBoss.attackDamage;
    }

    console.log("Boss attacked player. Player has %s HP left", player.hp);

    emit AttackCompleted(bigBoss.hp, player.hp);
  }

  function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];

    if (nftTokenIdOfPlayer > 0) {
      return nftHolderAttributes[nftTokenIdOfPlayer];
    }

    CharacterAttributes memory emptyStruct;
    return emptyStruct;
  }

  function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
    return defaultCharacters;
  }

  function getBigBoss() public view returns (BigBoss memory) {
    return bigBoss;
  }
}
