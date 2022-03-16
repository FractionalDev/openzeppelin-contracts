// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;
import "../token/ERC1155/ERC1155.sol";
import "../security/Pausable.sol";
import  "../access/AccessControlEnumerable.sol";

contract JumpMultiToken is Context, AccessControlEnumerable, ERC1155, Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    mapping(uint256 => uint256) private _totalSupply;


    constructor(string memory uri) ERC1155(uri) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(BURNER_ROLE, _msgSender());
    }

    function setURI(string memory newuri) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "must be admin");
        _setURI(newuri);
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public {
        require(hasRole(BURNER_ROLE, _msgSender()), "must have burner role");
        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public {
        require(hasRole(BURNER_ROLE, _msgSender()), "must have burner role" );
        _burnBatch(account, ids, values);
    }

 /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     *
     * See {ERC1155-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "must have minter role to mint");

        _mint(to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "must have minter role to mint");
        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC1155Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public {
        require(hasRole(PAUSER_ROLE, _msgSender()), "must have pauser role to pause");
        _pause();
    }

     /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC1155Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public {
        require(hasRole(PAUSER_ROLE, _msgSender()), "must have pauser role to unpause");
        _unpause();
    }

    /**
    * @dev See {IERC165-supportsInterface}.
    */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return JumpMultiToken.totalSupply(id) > 0;
    }


     /**
     * Combines ERC115Pausable with ERC1155Supply
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        
        // Pausable
        require(!paused(), "token transfer while paused");

        // ERC1155Supply
        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }
}