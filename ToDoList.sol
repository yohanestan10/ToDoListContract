//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract ToDoList {
    address public assigner;
    address[] public assignee;
    address[] public group;
    uint public taskId;
    bool public idStatus = false;
    

    enum Status{
        Incomplete,
        Complete
    }

    Status public status;

    struct TaskDetail{
        string taskName;
        address taskAssigner;
        address taskAssigned;
        Status status;
    }

    
    mapping(uint256 => TaskDetail) public taskNumber;

    

    constructor() {
        assigner = msg.sender;
        for (uint i = 0; i < group.length; i++) {
            if (msg.sender == group[i]) {
                idStatus = true;
                break;
            }
        }
    }
    
    modifier onlyAssigner{
        require(msg.sender == assigner, "Must be an assigner to call function");
        _;
    }
    
    modifier partofGroup{
        require(idStatus == true, "Invalid address");
        _;
    }
        
    function enterTask() external{
        assignee.push(address(msg.sender));
    }

    function assignTask(string memory _taskName, uint _assignee) public onlyAssigner{
        group.push(address(assignee[_assignee]));
        taskId++;
        taskNumber[taskId] = TaskDetail(
             _taskName,
             msg.sender,
             assignee[_assignee],
             status = Status.Incomplete
        );
    }

    function complete(uint _taskNo) public {
        require(msg.sender == assignee[_taskNo], "Invalid address");
        taskNumber[_taskNo].status = Status.Complete;
    }

    function viewTask(uint _taskNo) public partofGroup view returns(string memory, address, address, Status){
        return (
            taskNumber[_taskNo].taskName,
            taskNumber[_taskNo].taskAssigner,
            taskNumber[_taskNo].taskAssigned,
            taskNumber[_taskNo].status
        );
    }
}