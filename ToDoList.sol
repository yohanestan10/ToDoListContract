//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract ToDoList_revised {
    address public assigner;
    mapping(address => bool) public addressToMembership;
    ToDo[] toDos;

    enum STATUS {
        COMPLETE,
        INCOMPLETE,
        FAILED
    }

    STATUS status;

    struct ToDo {
        uint32 taskId;
        string taskName;
        uint32 taskDeadline;
        address taskAssigner;
        address taskAssignee;
        STATUS status;
    }

    event TaskAdded(ToDo);
    event LogCurrentUnixTime(uint unixTime);

    constructor() {
        assigner = msg.sender;
        addressToMembership[msg.sender] = true;
    }

    //Check whether a certain task is complete or not

    function assignTask(string memory _taskName, uint32 _deadline, address _assignee) public onlyAssigner{
    ToDo memory newTask  = ToDo(
            uint32(toDos.length),
            _taskName,
            _deadline,
             msg.sender,
             _assignee,
             status = STATUS.INCOMPLETE
        );
    
    toDos.push(newTask);

    addressToMembership[_assignee] = true;

    emit TaskAdded(newTask);        
    }

    function reassignTask(uint32 _taskId, address _assignee) public onlyAssigner {
        require(toDos[_taskId].status == STATUS.INCOMPLETE, "Task is completed, cannot reassign task.");
        require(toDos[_taskId].taskAssignee != _assignee, "New assignee address is the same as original assignee.");
        
        toDos[_taskId].taskAssignee = _assignee;
        addressToMembership[_assignee] = true;

    }

    function checkDeadlineValid(uint _deadline, uint currentUnixTime) public pure returns (bool){
        if (currentUnixTime < _deadline) {
            return true; 
        }
        return false;
    }

    function refreshTask() external onlyAssigner {
        emit LogCurrentUnixTime(block.timestamp);
        for (uint i = 0; i < toDos.length; i++){
            //only incomplete tasks' status can be updated to failed if passed deadline
            if (toDos[i].status == STATUS.INCOMPLETE && !checkDeadlineValid(toDos[i].taskDeadline, block.timestamp)){
                toDos[i].status = STATUS.FAILED;
            }
        }
    }

    function completeTask(uint32 _taskId) external onlyMember {
        require(toDos[_taskId].taskAssignee == msg.sender, "Only assignee can complete task");
        require(toDos[_taskId].status == STATUS.INCOMPLETE, "Task status is complete or passed the deadline.");

        bool isDeadlineValid = checkDeadlineValid(toDos[_taskId].taskDeadline, block.timestamp);

        if (!isDeadlineValid) {
            toDos[_taskId].status = STATUS.FAILED;
        }
        require(isDeadlineValid, "Task has passed the deadline");
        toDos[_taskId].status = STATUS.COMPLETE;
    }

    function removeMembership(address _member) external onlyAssigner{
        addressToMembership[_member] = false;
    }

    function viewAllTasks() public view onlyMember returns(ToDo[] memory) {
        return toDos;
    }

    //Validate assigner
    modifier onlyAssigner{
        require(msg.sender == assigner, "Must be an assigner to call function");
        _;
    }

    //Go through the array of 'group' to validate addresses
    modifier onlyMember(){
        require(addressToMembership[msg.sender], "Must be a member to call function");
        _;
    }

}
