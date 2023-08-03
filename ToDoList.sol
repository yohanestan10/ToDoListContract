//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract ToDoList_revised {
    address public assigner;
    address[] public group;
    
    enum Status {
        Incomplete,
        Complete
    }

    Status status;

    struct taskDetail {
        string taskName;
        address taskAssigner;
        address taskAssignee;
        Status status;
    }

    taskDetail[] taskList;

    constructor() {
        assigner = msg.sender;
        group.push(msg.sender);
    }

    //Validate assigner
    modifier onlyAssigner{
        require(msg.sender == assigner, "Must be an assigner to call function");
        _;
    }

    //Go through the array of 'group' to validate addresses
    modifier partofGroup(){
        for (uint i = 0; i < group.length; i++) {
            if (msg.sender == group[i]) {
                _;
                break;
            }
        }
    }

    //Check whether a certain task is complete or not 
    modifier checkStatus(uint _taskId){
        require(taskList[_taskId].status == Status.Incomplete, "Task must be incomplete to call function");
        _;
    }

    function assignTask(string memory _taskName, address _assignee) public onlyAssigner{
        taskList.push(taskDetail(
            _taskName,
             msg.sender,
             _assignee,
             status = Status.Incomplete
        ));
        group.push(_assignee);
    }

    function completeTask(uint _taskId) public partofGroup() checkStatus(_taskId) {
        require(msg.sender == taskList[_taskId].taskAssignee);
        taskList[_taskId].status = Status.Complete;
    }

    function reassignTask(uint _taskId, address _newassignee) public onlyAssigner checkStatus(_taskId) {
        taskList[_taskId].taskAssignee = _newassignee;
        delete group[_taskId];
        
    }

    function viewTask() public view partofGroup() returns(taskDetail[] memory) {
        return taskList;
    }
}
