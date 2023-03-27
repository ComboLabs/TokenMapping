pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ComboMapping is Ownable {
    address public combo;
    address public cocos;
    address public withdrawAddress;

    // black list
    mapping(address => bool) public blackAccountMaps;

    event UpdateComboToken(address notWorkingCombo, address combo);
    event Mapping(address account, uint256 amount);
    event UpdateWithdrawAddress(address withdrawAddress);

    event AddBlackAccount(address blackAccount);
    event DelBlackAccount(address blackAccount);
    event EmergencyWithdraw(address account, uint256 banlance);

    constructor(address combo_, address cocos_, address withdrawAddress_) {
        combo_ = combo_;
        cocos_ = cocos_;
        withdrawAddress = withdrawAddress_;
    }

    function updateComboToken(address comboToken) external onlyOwner {
        address notWorkingCombo = combo;
        combo = comboToken;
        UpdateComboToken(notWorkingCombo, combo);
    }

    function mappingToken() external {
        address account = msg.sender;
        require(!blackAccountMaps[account], "in black list");
        uint256 amount = IERC20(cocos).balanceOf(account);
        require(
            IERC20(cocos).transferFrom(account, address(this), amount),
            "COCOS transfer failed."
        );

        require(
            IERC20(combo).transfer(account, amount),
            "COMBO transfer failed."
        );

        emit Mapping(account, amount);
    }

    function emergencyWithdraw(
        IERC20 token,
        address withdrawAddr
    ) external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(withdrawAddr, balance);
        emit EmergencyWithdraw(withdrawAddr, balance);
    }

    function addBlackAccount(address _blackAccount) external onlyOwner {
        require(!blackAccountMaps[_blackAccount], "has in black list");
        blackAccountMaps[_blackAccount] = true;
        emit AddBlackAccount(_blackAccount);
    }

    function delBlackAccount(address _blackAccount) external onlyOwner {
        require(blackAccountMaps[_blackAccount], "not in black list");

        blackAccountMaps[_blackAccount] = false;
        emit DelBlackAccount(_blackAccount);
    }

    function updateWithdrawAddress(
        address _withdrawAddress
    ) external onlyOwner {
        withdrawAddress = _withdrawAddress;
        emit UpdateWithdrawAddress(withdrawAddress);
    }
}
