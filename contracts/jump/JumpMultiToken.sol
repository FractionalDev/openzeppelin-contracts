// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;
import "../token/ERC1155/ERC1155.sol";
import "../security/Pausable.sol";
import  "../access/Ownable.sol";

contract JumpMultiToken is ERC1155, Pausable, Ownable {

    constructor(string memory uri) ERC1155(uri) {
    }

    mapping(uint256 => uint256) private _totalSupply;

    function pause() public onlyOwner {
        _pause();
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
        require(!paused(), "ERC1155Pausable: token transfer while paused");

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
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }
}