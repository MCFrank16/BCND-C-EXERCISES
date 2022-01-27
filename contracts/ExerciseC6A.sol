pragma solidity >=0.4.25;

contract ExerciseC6A {
    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    uint constant M = 2;

    struct UserProfile {
        bool isRegistered;
        bool isAdmin;
    }

    address private contractOwner; // Account used to deploy contract
    mapping(address => UserProfile) userProfiles; // Mapping for storing user profiles

    bool private operational = true;

    address[] multiCalls = new address[](0);

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    // No events

    /**
     * @dev Constructor
     *      The deploying account becomes contractOwner
     */
    constructor() public {
        contractOwner = msg.sender;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
     * @dev Modifier that requires the "ContractOwner" account to be the function caller
     */
    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /**
     * @dev Modifier that requires the operational variable to be true
     * this is used on all state changing functions to pause the contract
     * in the event there is an issue that needs to be fixed
     */
    modifier requireIsOperational() {
        require(operational, 'Contract is currently not operational');
        _; // this indicates where the body will be called
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
     * @dev Check if a user is registered
     *
     * @return A bool that indicates if the user is registered
     */
    function isUserRegistered(address account) external view returns (bool) {
        require(account != address(0), "'account' must be a valid address.");
        return userProfiles[account].isRegistered;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    function registerUser(address account, bool isAdmin) external requireIsOperational requireContractOwner {
        require(
            !userProfiles[account].isRegistered,
            "User is already registered."
        );

        userProfiles[account] = UserProfile({
            isRegistered: true,
            isAdmin: isAdmin
        });
    }

    /**
     * @dev get the operational status of the contract
     *
     * @return A bool that indicates if the contract is operational
     */
    function isOperational() public view returns(bool) {
        return operational;
    }  

    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    

    function setOperatingStatus (bool mode) external {
        require(mode != operational, "New mode must be different from existing mode");
        require(userProfiles[msg.sender].isAdmin, "Caller must be an admin");

        bool isDuplicate = false;
        for(uint call = 0; call < multiCalls.length; call++) {
            if (multiCalls[call] == msg.sender) {
                isDuplicate = true;
                break;
            }
        }
        require(!isDuplicate, "Caller has already called this function");

        multiCalls.push(msg.sender);
        if (multiCalls.length >= M) {
            operational = mode;
            multiCalls = new address[](0);
        }
    }
}
