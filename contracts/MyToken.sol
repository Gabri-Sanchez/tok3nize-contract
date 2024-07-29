// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../.deps/npm/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../.deps/npm/@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "../.deps/npm/@openzeppelin/contracts/access/Ownable.sol";
import "../.deps/npm/@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

// @author: Gabriel Sánchez (gabrielsanchez.business@proton.me) : Ch3etah blockchain (cheetahblockchain@proton.me)

//////////////////////////////////////////////////////////////////////////
//                     .o;.                               .:o.          //
//                     ;MMNMXko;.    .';c. 'c;'     .;oOXMNMM.          //
//                     ;MN .:xKd' '  WOcM: dN;N0 .. 'd0d:. MM.          //
//                     ;MX     'xNM  WMWM: dMWMK ,MNd.     MM.          //
//                     ;MX   ,xKKKK  WMox: dokMK ,KKKKx'   MM.          //
//                     ;Ml           dxWM: dMNxl           kM.          //
//                     ;, :WWWN, :d;   NM: dM0   :x, :WWWN, l.          //
//                        ,kWMMMOlcc;  NM: dM0  :c:l0MMMXd.             //
//                       .l. :OMMMMNc  NM0xKM0  dWMMMMk, .d             //
//                        .dk:.MMMo ,Oc;:::::,xk. xMMX.lOl.             //
//                       .l. ;OMMM ;MMX:     cNMM'.MMMx' .d             //
//                        'dk; MMM :MMMMN' :WMMMM'.MMN.lOl.             //
//                       .l. ;OMMM  ;OMkc. 'cOMk, .MMMx' .d             //
//                       .WMO;.MMM   ;W:     lW'  .MMN cKMN             //
//                         cXMWMMM    ..     .    .MMMWM0;              //
//                           ,OMMMc               dMMWx.                //
//                       .0;   .dWMWl  k.   'd  dWMNl    cX             //
//                       .MMNl.   :KX  KOooo0k  WO,   .dWMM             //
//                       .MMNMMx.   .  ,.....,  .   ,OMWNMM             //
//                       .MMo.dWMK;    OWMMMNd    cXMXc kMM             //
//                       .MMWNNWMMMNl          .oWMMMNNNWMM             //
//                        ;;;;;;;;;;;,         ,;;;;;;;;;;              //
//////////////////////////////////////////////////////////////////////////


contract Properties is ERC721, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;

    struct Property {
        uint256 propId;
        string owner;
        string ownerId;
        address wallet;
        string location;
        uint256 surface;
        string registry;
        uint256 purchase_price;
        //The date is in seconds since January 1, 1970, UTC 
        uint256 date;
        string notary;
    }

    mapping(uint256 => Property) private datosProperty;
    mapping(string => uint256[]) private propertiesOf;
    mapping(address => uint256[]) private propertiesOfWallet;
    mapping(string => uint256[]) private notaryProperties;


    

    constructor(address initialOwner)
        ERC721("Tokenized Assets", "TOK3NIZED")
        Ownable(initialOwner)
    {}

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

/*

    Problems with this implementation. Using just createPropertyStruct for now


    function createProperty( address to, string calldata owner, string calldata ownerId, string calldata location, uint256 surface, string calldata registry, uint256 purchase_price, uint256 date, string calldata notary) public onlyOwner {
        //require(_ownerOf(tokenId) != address(0));
        uint256 tokenId = _nextTokenId++;

        _safeMint(to, tokenId);
        datosProperty[tokenId] = Property(owner, ownerId, to,
            location,
            surface,
            registry,
            purchase_price,
            date,
            notary

            
        );
        propertiesOf[ownerId].push(tokenId);
        propertiesOfWallet[to].push(tokenId);
    } 
    */

    function createPropertestForTest(address to, Property memory edificio) public onlyOwner {
        //require(_ownerOf(tokenId) != address(0));
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        datosProperty[tokenId] = edificio;
        propertiesOf[edificio.ownerId].push(tokenId);
        propertiesOfWallet[edificio.wallet].push(tokenId);
        notaryProperties[edificio.notary].push(tokenId);
    }

    event Creation (uint256 prop, string toOwnerId, address toWallet);
    
    function createPropertyStruct(address to, Property memory edificio) public onlyOwner {
        require(to != address(0));
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        edificio.propId = tokenId;
        datosProperty[tokenId] = edificio;
        propertiesOf[edificio.ownerId].push(tokenId);
        propertiesOfWallet[edificio.wallet].push(tokenId);
        emit Creation(tokenId, edificio.ownerId, to);
    }

    event Deletion (uint256 prop, string ownerId, address ownerWallet);

    function deleteProperty(uint256 tokenId) public onlyOwner returns (bool) {
        Property memory edificio = datosProperty[tokenId];
        string memory ownerId = edificio.ownerId;
        address wallet = edificio.wallet;
        string memory notary = edificio.notary;
        bool foundNif = false;
        bool foundWallet = false;
        bool foundNotary = false;
        for (
            uint256 i = 0;
            (i < propertiesOf[ownerId].length) || (foundNif);
            i++
        ) {
            if (propertiesOf[ownerId][i] == tokenId) {
                delete propertiesOf[ownerId][i];
                foundNif = true;
            }
        }

        for (uint256 i = 0; (i < propertiesOfWallet[wallet].length) || (foundWallet); i++) {
            if (propertiesOfWallet[wallet][i] == tokenId) {
                delete propertiesOfWallet[wallet][i];
                foundWallet = true;
            }
        }

        for (uint256 i = 0; (i < notaryProperties[notary].length) || (foundWallet); i++) {
            if (notaryProperties[notary][i] == tokenId) {
                delete notaryProperties[notary][i];
                foundNotary = true;
            }
        }
        
        emit Deletion(tokenId, ownerId, wallet);
        
        return foundNif && foundWallet && foundNotary;
        
        

    }

    //Funciones que requieren crear nuevo documento. (Quemamos el anterior token);
    function changeOwner(uint256 tokenId, string calldata ownerIdNew, address to) public onlyOwner {
        //Copiar datos del edificio a uno nuevo
        Property memory newBuilding = datosProperty[tokenId];
        newBuilding.ownerId = ownerIdNew;
        createPropertyStruct(to, newBuilding);
        deleteProperty(tokenId);
    }

    function getPropertiesByOwnerId(string calldata ownerId) public view onlyOwner returns (Property[] memory) {
        uint amount = propertiesOf[ownerId].length;
        Property[] memory properties = new Property[](amount);

        for(uint i=0; i < amount; i++){
            properties[i] = datosProperty[propertiesOf[ownerId][i]];
        }

        return properties;
    }

    function getPropertiesByOwnerWallet(address wallet) public view onlyOwner returns (Property[] memory) {
        uint amount = propertiesOfWallet[wallet].length;
        Property[] memory properties = new Property[](amount);

        for(uint i=0; i < amount; i++){
            properties[i] = datosProperty[propertiesOfWallet[wallet][i]];
        }
        return properties;
    }

    function getPropertiesByNotary(string memory notary) public view onlyOwner returns (Property[] memory) {
        uint amount = notaryProperties[notary].length;
        Property[] memory properties = new Property[](amount);

        for(uint i=0; i < amount; i++){
            properties[i] = datosProperty[notaryProperties[notary][i]];
        }
        return properties;
    }

    function getPropertyByPropId(uint256 propId) public view onlyOwner returns (Property memory) {
        return datosProperty[propId];
    }
}