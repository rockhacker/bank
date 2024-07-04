// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

// 定义一个Bank合约
contract Bank {
    // 存储管理员地址
    address public admin;

    // 存储每个地址的存款金额
    mapping(address => uint256) public deposits;

    // 记录存款金额前3名的地址
    address[3] public topDepositors;

    // 合约构造函数，设置管理员
    constructor() {
        admin = msg.sender; // 部署合约的地址为管理员
    }

    // 存款函数，接收ETH并记录存款金额
    function deposit() public payable {
        require(msg.value > 0, unicode"存款金额必须大于0");
        _handleDeposit(msg.sender, msg.value);
    }

    // 处理存款逻辑
    function _handleDeposit(address depositor, uint256 amount) internal {
        // 更新存款金额
        deposits[depositor] += amount;
        
        // 更新存款金额前3名的记录
        updateTopDepositors(depositor);
    }

    // 更新存款金额前3名
    function updateTopDepositors(address depositor) internal {
        uint256 currentDeposit = deposits[depositor];
        for (uint i = 0; i < 3; i++) {
            if (topDepositors[i] == depositor) {
                break;
            }
            if (deposits[topDepositors[i]] < currentDeposit) {
                for (uint j = 2; j > i; j--) {
                    topDepositors[j] = topDepositors[j - 1];
                }
                topDepositors[i] = depositor;
                break;
            }
        }
    }

    // 提现函数，仅管理员可以调用
    function withdraw() public {
        require(msg.sender == admin, unicode"只有管理员可以提取资金");
        uint256 balance = address(this).balance;
        require(balance > 0, unicode"合约余额为0");

        // 将所有ETH发送给管理员
        payable(admin).transfer(balance);
    }

    // 获取合约的ETH余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // receive 函数，当直接发送ETH到合约地址时调用
    receive() external payable {
        require(msg.value > 0, unicode"存款金额必须大于0");
        _handleDeposit(msg.sender, msg.value);
    }

    // fallback 函数，当调用不存在的函数或调用数据为空时调用
    fallback() external payable {
        require(msg.value > 0, unicode"存款金额必须大于0");
        _handleDeposit(msg.sender, msg.value);
    }
}