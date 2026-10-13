// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7 <0.9;
pragma experimental ABIEncoderV2;

import "../access/AccessControlUpgradeable.sol";

contract AccessControlUpgradeableWithInit is AccessControlUpgradeable {
    constructor() payable initializer {
        __AccessControl_init();
    }
}
import "../access/extensions/AccessControlDefaultAdminRulesUpgradeable.sol";

contract AccessControlDefaultAdminRulesUpgradeableWithInit is AccessControlDefaultAdminRulesUpgradeable {
    constructor(uint48 initialDelay, address initialDefaultAdmin) payable initializer {
        __AccessControlDefaultAdminRules_init(initialDelay, initialDefaultAdmin);
    }
}
import "../access/extensions/AccessControlEnumerableUpgradeable.sol";

contract AccessControlEnumerableUpgradeableWithInit is AccessControlEnumerableUpgradeable {
    constructor() payable initializer {
        __AccessControlEnumerable_init();
    }
}
import "../access/manager/AccessManagedUpgradeable.sol";

contract AccessManagedUpgradeableWithInit is AccessManagedUpgradeable {
    constructor(address initialAuthority) payable initializer {
        __AccessManaged_init(initialAuthority);
    }
}
import "../access/manager/AccessManagerUpgradeable.sol";

contract AccessManagerUpgradeableWithInit is AccessManagerUpgradeable {
    constructor(address initialAdmin) payable initializer {
        __AccessManager_init(initialAdmin);
    }
}
import "../access/OwnableUpgradeable.sol";

contract OwnableUpgradeableWithInit is OwnableUpgradeable {
    constructor(address initialOwner) payable initializer {
        __Ownable_init(initialOwner);
    }
}
import "../access/Ownable2StepUpgradeable.sol";

contract Ownable2StepUpgradeableWithInit is Ownable2StepUpgradeable {
    constructor() payable initializer {
        __Ownable2Step_init();
    }
}
import "../account/extensions/draft-AccountERC7579Upgradeable.sol";

contract AccountERC7579UpgradeableWithInit is AccountERC7579Upgradeable {
    constructor() payable initializer {
        __AccountERC7579_init();
    }
}
import "../account/extensions/draft-AccountERC7579HookedUpgradeable.sol";

contract AccountERC7579HookedUpgradeableWithInit is AccountERC7579HookedUpgradeable {
    constructor() payable initializer {
        __AccountERC7579Hooked_init();
    }
}
import "../account/paymaster/extensions/PaymasterERC721OwnerUpgradeable.sol";

contract PaymasterERC721OwnerUpgradeableWithInit is PaymasterERC721OwnerUpgradeable {
    constructor(IERC721 token_) payable initializer {
        __PaymasterERC721Owner_init(token_);
    }
}
import "../crosschain/bridges/BridgeERC1155Upgradeable.sol";

contract BridgeERC1155UpgradeableWithInit is BridgeERC1155Upgradeable {
    constructor(IERC1155 token_) payable initializer {
        __BridgeERC1155_init(token_);
    }
}
import "../crosschain/bridges/BridgeERC20Upgradeable.sol";

contract BridgeERC20UpgradeableWithInit is BridgeERC20Upgradeable {
    constructor(IERC20 token_) payable initializer {
        __BridgeERC20_init(token_);
    }
}
import "../crosschain/bridges/BridgeERC721Upgradeable.sol";

contract BridgeERC721UpgradeableWithInit is BridgeERC721Upgradeable {
    constructor(IERC721 token_) payable initializer {
        __BridgeERC721_init(token_);
    }
}
import "../crosschain/bridges/BridgeERC7802Upgradeable.sol";

contract BridgeERC7802UpgradeableWithInit is BridgeERC7802Upgradeable {
    constructor(IERC7802 token_) payable initializer {
        __BridgeERC7802_init(token_);
    }
}
import "../crosschain/CrosschainRemoteExecutorUpgradeable.sol";

contract CrosschainRemoteExecutorUpgradeableWithInit is CrosschainRemoteExecutorUpgradeable {
    constructor(address initialGateway, bytes memory initialController) payable initializer {
        __CrosschainRemoteExecutor_init(initialGateway, initialController);
    }
}
import "../finance/VestingWalletUpgradeable.sol";

contract VestingWalletUpgradeableWithInit is VestingWalletUpgradeable {
    constructor(address beneficiary, uint64 startTimestamp, uint64 durationSeconds) payable initializer {
        __VestingWallet_init(beneficiary, startTimestamp, durationSeconds);
    }
}
import "../finance/VestingWalletCliffUpgradeable.sol";

contract VestingWalletCliffUpgradeableWithInit is VestingWalletCliffUpgradeable {
    constructor(uint64 cliffSeconds) payable initializer {
        __VestingWalletCliff_init(cliffSeconds);
    }
}
import "../governance/TimelockControllerUpgradeable.sol";

contract TimelockControllerUpgradeableWithInit is TimelockControllerUpgradeable {
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors, address admin) payable initializer {
        __TimelockController_init(minDelay, proposers, executors, admin);
    }
}
import "../metatx/ERC2771ContextUpgradeable.sol";

contract ERC2771ContextUpgradeableWithInit is ERC2771ContextUpgradeable {
    constructor(address trustedForwarder_) ERC2771ContextUpgradeable(trustedForwarder_) payable initializer {

    }
}
import "../metatx/ERC2771ForwarderUpgradeable.sol";

contract ERC2771ForwarderUpgradeableWithInit is ERC2771ForwarderUpgradeable {
    constructor(string memory name) payable initializer {
        __ERC2771Forwarder_init(name);
    }
}
import "./AccessManagedTargetUpgradeable.sol";

contract AccessManagedTargetUpgradeableWithInit is AccessManagedTargetUpgradeable {
    constructor() payable initializer {
        __AccessManagedTarget_init();
    }
}
import "./AccessManagerMockUpgradeable.sol";

contract AccessManagerMockUpgradeableWithInit is AccessManagerMockUpgradeable {
    constructor(address initialAdmin) payable initializer {
        __AccessManagerMock_init(initialAdmin);
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountMockUpgradeableWithInit is AccountMockUpgradeable {
    constructor() payable initializer {
        __AccountMock_init();
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountECDSAMockUpgradeableWithInit is AccountECDSAMockUpgradeable {
    constructor() payable initializer {
        __AccountECDSAMock_init();
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountP256MockUpgradeableWithInit is AccountP256MockUpgradeable {
    constructor() payable initializer {
        __AccountP256Mock_init();
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountRSAMockUpgradeableWithInit is AccountRSAMockUpgradeable {
    constructor() payable initializer {
        __AccountRSAMock_init();
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountWebAuthnMockUpgradeableWithInit is AccountWebAuthnMockUpgradeable {
    constructor() payable initializer {
        __AccountWebAuthnMock_init();
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountEIP7702MockUpgradeableWithInit is AccountEIP7702MockUpgradeable {
    constructor() payable initializer {
        __AccountEIP7702Mock_init();
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountEIP7702WithModulesMockUpgradeableWithInit is AccountEIP7702WithModulesMockUpgradeable {
    constructor() payable initializer {
        __AccountEIP7702WithModulesMock_init();
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountERC7579MockUpgradeableWithInit is AccountERC7579MockUpgradeable {
    constructor(address validator, bytes memory initData) payable initializer {
        __AccountERC7579Mock_init(validator, initData);
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountERC7579HookedMockUpgradeableWithInit is AccountERC7579HookedMockUpgradeable {
    constructor(address validator, bytes memory initData) payable initializer {
        __AccountERC7579HookedMock_init(validator, initData);
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountERC7913MockUpgradeableWithInit is AccountERC7913MockUpgradeable {
    constructor() payable initializer {
        __AccountERC7913Mock_init();
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountMultiSignerMockUpgradeableWithInit is AccountMultiSignerMockUpgradeable {
    constructor() payable initializer {
        __AccountMultiSignerMock_init();
    }
}
import "./account/AccountMockUpgradeable.sol";

contract AccountMultiSignerWeightedMockUpgradeableWithInit is AccountMultiSignerWeightedMockUpgradeable {
    constructor() payable initializer {
        __AccountMultiSignerWeightedMock_init();
    }
}
import "./account/modules/ERC7579MockUpgradeable.sol";

contract ERC7579ModuleMockUpgradeableWithInit is ERC7579ModuleMockUpgradeable {
    constructor(uint256 moduleTypeId) payable initializer {
        __ERC7579ModuleMock_init(moduleTypeId);
    }
}
import "./account/modules/ERC7579MockUpgradeable.sol";

contract ERC7579ModuleMaliciousMockUpgradeableWithInit is ERC7579ModuleMaliciousMockUpgradeable {
    constructor() payable initializer {
        __ERC7579ModuleMaliciousMock_init();
    }
}
import "./account/modules/ERC7579MockUpgradeable.sol";

contract ERC7579HookMockUpgradeableWithInit is ERC7579HookMockUpgradeable {
    constructor() payable initializer {
        __ERC7579HookMock_init();
    }
}
import "./account/modules/ERC7579MockUpgradeable.sol";

contract ERC7579FallbackHandlerMockUpgradeableWithInit is ERC7579FallbackHandlerMockUpgradeable {
    constructor() payable initializer {
        __ERC7579FallbackHandlerMock_init();
    }
}
import "./account/modules/ERC7579MockUpgradeable.sol";

contract ERC7579ValidatorMockUpgradeableWithInit is ERC7579ValidatorMockUpgradeable {
    constructor() payable initializer {
        __ERC7579ValidatorMock_init();
    }
}
import "./account/paymaster/PaymasterERC20MockUpgradeable.sol";

contract PaymasterERC20MockUpgradeableWithInit is PaymasterERC20MockUpgradeable {
    constructor() payable initializer {
        __PaymasterERC20Mock_init();
    }
}
import "./account/paymaster/PaymasterERC20MockUpgradeable.sol";

contract PaymasterERC20GuarantorMockUpgradeableWithInit is PaymasterERC20GuarantorMockUpgradeable {
    constructor() payable initializer {
        __PaymasterERC20GuarantorMock_init();
    }
}
import "./account/paymaster/PaymasterERC721OwnerMockUpgradeable.sol";

contract PaymasterERC721OwnerContextNoPostOpMockUpgradeableWithInit is PaymasterERC721OwnerContextNoPostOpMockUpgradeable {
    constructor() payable initializer {
        __PaymasterERC721OwnerContextNoPostOpMock_init();
    }
}
import "./account/paymaster/PaymasterERC721OwnerMockUpgradeable.sol";

contract PaymasterERC721OwnerMockUpgradeableWithInit is PaymasterERC721OwnerMockUpgradeable {
    constructor() payable initializer {
        __PaymasterERC721OwnerMock_init();
    }
}
import "./account/paymaster/PaymasterSignerMockUpgradeable.sol";

contract PaymasterSignerContextNoPostOpMockUpgradeableWithInit is PaymasterSignerContextNoPostOpMockUpgradeable {
    constructor() payable initializer {
        __PaymasterSignerContextNoPostOpMock_init();
    }
}
import "./account/paymaster/PaymasterSignerMockUpgradeable.sol";

contract PaymasterSignerMockUpgradeableWithInit is PaymasterSignerMockUpgradeable {
    constructor() payable initializer {
        __PaymasterSignerMock_init();
    }
}
import "./account/utils/ERC7579UtilsMockUpgradeable.sol";

contract ERC7579UtilsGlobalMockUpgradeableWithInit is ERC7579UtilsGlobalMockUpgradeable {
    constructor() payable initializer {
        __ERC7579UtilsGlobalMock_init();
    }
}
import "./ArraysMockUpgradeable.sol";

contract Uint256ArraysMockUpgradeableWithInit is Uint256ArraysMockUpgradeable {
    constructor(uint256[] memory array) payable initializer {
        __Uint256ArraysMock_init(array);
    }
}
import "./ArraysMockUpgradeable.sol";

contract AddressArraysMockUpgradeableWithInit is AddressArraysMockUpgradeable {
    constructor(address[] memory array) payable initializer {
        __AddressArraysMock_init(array);
    }
}
import "./ArraysMockUpgradeable.sol";

contract Bytes32ArraysMockUpgradeableWithInit is Bytes32ArraysMockUpgradeable {
    constructor(bytes32[] memory array) payable initializer {
        __Bytes32ArraysMock_init(array);
    }
}
import "./ArraysMockUpgradeable.sol";

contract BytesArraysMockUpgradeableWithInit is BytesArraysMockUpgradeable {
    constructor(bytes[] memory array) payable initializer {
        __BytesArraysMock_init(array);
    }
}
import "./ArraysMockUpgradeable.sol";

contract StringArraysMockUpgradeableWithInit is StringArraysMockUpgradeable {
    constructor(string[] memory array) payable initializer {
        __StringArraysMock_init(array);
    }
}
import "./AuthorityMockUpgradeable.sol";

contract NotAuthorityMockUpgradeableWithInit is NotAuthorityMockUpgradeable {
    constructor() payable initializer {
        __NotAuthorityMock_init();
    }
}
import "./AuthorityMockUpgradeable.sol";

contract AuthorityNoDelayMockUpgradeableWithInit is AuthorityNoDelayMockUpgradeable {
    constructor() payable initializer {
        __AuthorityNoDelayMock_init();
    }
}
import "./AuthorityMockUpgradeable.sol";

contract AuthorityDelayMockUpgradeableWithInit is AuthorityDelayMockUpgradeable {
    constructor() payable initializer {
        __AuthorityDelayMock_init();
    }
}
import "./AuthorityMockUpgradeable.sol";

contract AuthorityNoResponseUpgradeableWithInit is AuthorityNoResponseUpgradeable {
    constructor() payable initializer {
        __AuthorityNoResponse_init();
    }
}
import "./AuthorityMockUpgradeable.sol";

contract AuthorityObserveIsConsumingUpgradeableWithInit is AuthorityObserveIsConsumingUpgradeable {
    constructor() payable initializer {
        __AuthorityObserveIsConsuming_init();
    }
}
import "./Base64DirtyUpgradeable.sol";

contract Base64DirtyUpgradeableWithInit is Base64DirtyUpgradeable {
    constructor() payable initializer {
        __Base64Dirty_init();
    }
}
import "./BatchCallerUpgradeable.sol";

contract BatchCallerUpgradeableWithInit is BatchCallerUpgradeable {
    constructor() payable initializer {
        __BatchCaller_init();
    }
}
import "./BlockHeaderMockUpgradeable.sol";

contract BlockHeaderMultiReadMockUpgradeableWithInit is BlockHeaderMultiReadMockUpgradeable {
    constructor() payable initializer {
        __BlockHeaderMultiReadMock_init();
    }
}
import "./CallReceiverMockUpgradeable.sol";

contract CallReceiverMockUpgradeableWithInit is CallReceiverMockUpgradeable {
    constructor() payable initializer {
        __CallReceiverMock_init();
    }
}
import "./CallReceiverMockUpgradeable.sol";

contract CallReceiverMockTrustingForwarderUpgradeableWithInit is CallReceiverMockTrustingForwarderUpgradeable {
    constructor(address trustedForwarder_) payable initializer {
        __CallReceiverMockTrustingForwarder_init(trustedForwarder_);
    }
}
import "./compound/CompTimelockUpgradeable.sol";

contract CompTimelockUpgradeableWithInit is CompTimelockUpgradeable {
    constructor(address admin_, uint256 delay_) payable initializer {
        __CompTimelock_init(admin_, delay_);
    }
}
import "./ConstructorMockUpgradeable.sol";

contract ConstructorMockUpgradeableWithInit is ConstructorMockUpgradeable {
    constructor(RevertType err) payable initializer {
        __ConstructorMock_init(err);
    }
}
import "./ContextMockUpgradeable.sol";

contract ContextMockUpgradeableWithInit is ContextMockUpgradeable {
    constructor() payable initializer {
        __ContextMock_init();
    }
}
import "./ContextMockUpgradeable.sol";

contract ContextMockCallerUpgradeableWithInit is ContextMockCallerUpgradeable {
    constructor() payable initializer {
        __ContextMockCaller_init();
    }
}
import "./crosschain/ERC7786GatewayMockUpgradeable.sol";

contract ERC7786GatewayMockUpgradeableWithInit is ERC7786GatewayMockUpgradeable {
    constructor() payable initializer {
        __ERC7786GatewayMock_init();
    }
}
import "./crosschain/ERC7786RecipientMockUpgradeable.sol";

contract ERC7786RecipientMockUpgradeableWithInit is ERC7786RecipientMockUpgradeable {
    constructor(address gateway_) payable initializer {
        __ERC7786RecipientMock_init(gateway_);
    }
}
import "./docs/access-control/AccessControlERC20MintBaseUpgradeable.sol";

contract AccessControlERC20MintBaseUpgradeableWithInit is AccessControlERC20MintBaseUpgradeable {
    constructor(address minter) payable initializer {
        __AccessControlERC20MintBase_init(minter);
    }
}
import "./docs/access-control/AccessControlERC20MintMissingUpgradeable.sol";

contract AccessControlERC20MintMissingUpgradeableWithInit is AccessControlERC20MintMissingUpgradeable {
    constructor() payable initializer {
        __AccessControlERC20MintMissing_init();
    }
}
import "./docs/access-control/AccessControlERC20MintOnlyRoleUpgradeable.sol";

contract AccessControlERC20MintUpgradeableWithInit is AccessControlERC20MintUpgradeable {
    constructor(address minter, address burner) payable initializer {
        __AccessControlERC20Mint_init(minter, burner);
    }
}
import "./docs/access-control/AccessControlModifiedUpgradeable.sol";

contract AccessControlModifiedUpgradeableWithInit is AccessControlModifiedUpgradeable {
    constructor() payable initializer {
        __AccessControlModified_init();
    }
}
import "./docs/access-control/AccessManagedERC20MintBaseUpgradeable.sol";

contract AccessManagedERC20MintUpgradeableWithInit is AccessManagedERC20MintUpgradeable {
    constructor(address manager) payable initializer {
        __AccessManagedERC20Mint_init(manager);
    }
}
import "./docs/access-control/MyContractOwnableUpgradeable.sol";

contract MyContractUpgradeableWithInit is MyContractUpgradeable {
    constructor(address initialOwner) payable initializer {
        __MyContract_init(initialOwner);
    }
}
import "./docs/AccessManagerEnumerableUpgradeable.sol";

contract AccessManagerEnumerableUpgradeableWithInit is AccessManagerEnumerableUpgradeable {
    constructor() payable initializer {
        __AccessManagerEnumerable_init();
    }
}
import "./docs/account/MyAccountEIP7702Upgradeable.sol";

contract MyAccountEIP7702UpgradeableWithInit is MyAccountEIP7702Upgradeable {
    constructor() payable initializer {
        __MyAccountEIP7702_init();
    }
}
import "./docs/account/MyFactoryAccountUpgradeable.sol";

contract MyFactoryAccountUpgradeableWithInit is MyFactoryAccountUpgradeable {
    constructor(address impl_) payable initializer {
        __MyFactoryAccount_init(impl_);
    }
}
import "./docs/account/paymaster/PaymasterECDSASignerUpgradeable.sol";

contract PaymasterECDSASignerUpgradeableWithInit is PaymasterECDSASignerUpgradeable {
    constructor(address signerAddr) payable initializer {
        __PaymasterECDSASigner_init(signerAddr);
    }
}
import "./docs/ERC20WithAutoMinerRewardUpgradeable.sol";

contract ERC20WithAutoMinerRewardUpgradeableWithInit is ERC20WithAutoMinerRewardUpgradeable {
    constructor() payable initializer {
        __ERC20WithAutoMinerReward_init();
    }
}
import "./docs/ERC4626FeesUpgradeable.sol";

contract ERC4626FeesUpgradeableWithInit is ERC4626FeesUpgradeable {
    constructor() payable initializer {
        __ERC4626Fees_init();
    }
}
import "./docs/governance/MyGovernorUpgradeable.sol";

contract MyGovernorUpgradeableWithInit is MyGovernorUpgradeable {
    constructor(
        IVotes _token,
        TimelockControllerUpgradeable _timelock
    ) payable initializer {
        __MyGovernor_init(_token, _timelock);
    }
}
import "./docs/governance/MyTokenUpgradeable.sol";

contract MyTokenUpgradeableWithInit is MyTokenUpgradeable {
    constructor() payable initializer {
        __MyToken_init();
    }
}
import "./docs/governance/MyTokenTimestampBasedUpgradeable.sol";

contract MyTokenTimestampBasedUpgradeableWithInit is MyTokenTimestampBasedUpgradeable {
    constructor() payable initializer {
        __MyTokenTimestampBased_init();
    }
}
import "./docs/governance/MyTokenWrappedUpgradeable.sol";

contract MyTokenWrappedUpgradeableWithInit is MyTokenWrappedUpgradeable {
    constructor(
        IERC20 wrappedToken
    ) payable initializer {
        __MyTokenWrapped_init(wrappedToken);
    }
}
import "./docs/MyNFTUpgradeable.sol";

contract MyNFTUpgradeableWithInit is MyNFTUpgradeable {
    constructor() payable initializer {
        __MyNFT_init();
    }
}
import "./docs/token/ERC1155/GameItemsUpgradeable.sol";

contract GameItemsUpgradeableWithInit is GameItemsUpgradeable {
    constructor() payable initializer {
        __GameItems_init();
    }
}
import "./docs/token/ERC1155/MyERC1155HolderContractUpgradeable.sol";

contract MyERC1155HolderContractUpgradeableWithInit is MyERC1155HolderContractUpgradeable {
    constructor() payable initializer {
        __MyERC1155HolderContract_init();
    }
}
import "./docs/token/ERC20/GLDTokenUpgradeable.sol";

contract GLDTokenUpgradeableWithInit is GLDTokenUpgradeable {
    constructor(uint256 initialSupply) payable initializer {
        __GLDToken_init(initialSupply);
    }
}
import "./docs/token/ERC6909/ERC6909GameItemsUpgradeable.sol";

contract ERC6909GameItemsUpgradeableWithInit is ERC6909GameItemsUpgradeable {
    constructor() payable initializer {
        __ERC6909GameItems_init();
    }
}
import "./docs/token/ERC721/GameItemUpgradeable.sol";

contract GameItemUpgradeableWithInit is GameItemUpgradeable {
    constructor() payable initializer {
        __GameItem_init();
    }
}
import "./docs/utilities/Base64NFTUpgradeable.sol";

contract Base64NFTUpgradeableWithInit is Base64NFTUpgradeable {
    constructor() payable initializer {
        __Base64NFT_init();
    }
}
import "./docs/utilities/MulticallUpgradeable.sol";

contract BoxUpgradeableWithInit is BoxUpgradeable {
    constructor() payable initializer {
        __Box_init();
    }
}
import "./DummyImplementationUpgradeable.sol";

contract DummyImplementationUpgradeableWithInit is DummyImplementationUpgradeable {
    constructor() payable initializer {
        __DummyImplementation_init();
    }
}
import "./DummyImplementationUpgradeable.sol";

contract DummyImplementationV2UpgradeableWithInit is DummyImplementationV2Upgradeable {
    constructor() payable initializer {
        __DummyImplementationV2_init();
    }
}
import "./EIP712VerifierUpgradeable.sol";

contract EIP712VerifierUpgradeableWithInit is EIP712VerifierUpgradeable {
    constructor() payable initializer {
        __EIP712Verifier_init();
    }
}
import "./ERC1271WalletMockUpgradeable.sol";

contract ERC1271WalletMockUpgradeableWithInit is ERC1271WalletMockUpgradeable {
    constructor(address originalOwner) payable initializer {
        __ERC1271WalletMock_init(originalOwner);
    }
}
import "./ERC1271WalletMockUpgradeable.sol";

contract ERC1271MaliciousMockUpgradeableWithInit is ERC1271MaliciousMockUpgradeable {
    constructor() payable initializer {
        __ERC1271MaliciousMock_init();
    }
}
import "./ERC165MockUpgradeable.sol";

contract SupportsInterfaceWithLookupMockUpgradeableWithInit is SupportsInterfaceWithLookupMockUpgradeable {
    constructor() payable initializer {
        __SupportsInterfaceWithLookupMock_init();
    }
}
import "./ERC165MockUpgradeable.sol";

contract ERC165InterfacesSupportedUpgradeableWithInit is ERC165InterfacesSupportedUpgradeable {
    constructor(bytes4[] memory interfaceIds) payable initializer {
        __ERC165InterfacesSupported_init(interfaceIds);
    }
}
import "./ERC165MockUpgradeable.sol";

contract ERC165RevertInvalidUpgradeableWithInit is ERC165RevertInvalidUpgradeable {
    constructor(bytes4[] memory interfaceIds) payable initializer {
        __ERC165RevertInvalid_init(interfaceIds);
    }
}
import "./ERC165MockUpgradeable.sol";

contract ERC165MaliciousDataUpgradeableWithInit is ERC165MaliciousDataUpgradeable {
    constructor() payable initializer {
        __ERC165MaliciousData_init();
    }
}
import "./ERC165MockUpgradeable.sol";

contract ERC165MissingDataUpgradeableWithInit is ERC165MissingDataUpgradeable {
    constructor() payable initializer {
        __ERC165MissingData_init();
    }
}
import "./ERC165MockUpgradeable.sol";

contract ERC165NotSupportedUpgradeableWithInit is ERC165NotSupportedUpgradeable {
    constructor() payable initializer {
        __ERC165NotSupported_init();
    }
}
import "./ERC165MockUpgradeable.sol";

contract ERC165ReturnBombMockUpgradeableWithInit is ERC165ReturnBombMockUpgradeable {
    constructor() payable initializer {
        __ERC165ReturnBombMock_init();
    }
}
import "./ERC2771ContextMockUpgradeable.sol";

contract ERC2771ContextMockUpgradeableWithInit is ERC2771ContextMockUpgradeable {
    constructor(address trustedForwarder) ERC2771ContextMockUpgradeable(trustedForwarder) payable initializer {

    }
}
import "./ERC3156FlashBorrowerMockUpgradeable.sol";

contract ERC3156FlashBorrowerMockUpgradeableWithInit is ERC3156FlashBorrowerMockUpgradeable {
    constructor(bool enableReturn, bool enableApprove) payable initializer {
        __ERC3156FlashBorrowerMock_init(enableReturn, enableApprove);
    }
}
import "./EtherReceiverMockUpgradeable.sol";

contract EtherReceiverMockUpgradeableWithInit is EtherReceiverMockUpgradeable {
    constructor() payable initializer {
        __EtherReceiverMock_init();
    }
}
import "./governance/GovernorCountingOverridableMockUpgradeable.sol";

contract GovernorCountingOverridableMockUpgradeableWithInit is GovernorCountingOverridableMockUpgradeable {
    constructor() payable initializer {
        __GovernorCountingOverridableMock_init();
    }
}
import "./governance/GovernorCrosschainUpgradeable.sol";

contract GovernorCrosschainMockUpgradeableWithInit is GovernorCrosschainMockUpgradeable {
    constructor() payable initializer {
        __GovernorCrosschainMock_init();
    }
}
import "./governance/GovernorFractionalMockUpgradeable.sol";

contract GovernorFractionalMockUpgradeableWithInit is GovernorFractionalMockUpgradeable {
    constructor() payable initializer {
        __GovernorFractionalMock_init();
    }
}
import "./governance/GovernorMockUpgradeable.sol";

contract GovernorMockUpgradeableWithInit is GovernorMockUpgradeable {
    constructor() payable initializer {
        __GovernorMock_init();
    }
}
import "./governance/GovernorNoncesKeyedMockUpgradeable.sol";

contract GovernorNoncesKeyedMockUpgradeableWithInit is GovernorNoncesKeyedMockUpgradeable {
    constructor() payable initializer {
        __GovernorNoncesKeyedMock_init();
    }
}
import "./governance/GovernorPreventLateQuorumMockUpgradeable.sol";

contract GovernorPreventLateQuorumMockUpgradeableWithInit is GovernorPreventLateQuorumMockUpgradeable {
    constructor(uint256 quorum_) payable initializer {
        __GovernorPreventLateQuorumMock_init(quorum_);
    }
}
import "./governance/GovernorProposalGuardianMockUpgradeable.sol";

contract GovernorProposalGuardianMockUpgradeableWithInit is GovernorProposalGuardianMockUpgradeable {
    constructor() payable initializer {
        __GovernorProposalGuardianMock_init();
    }
}
import "./governance/GovernorQueueingFailedMockUpgradeable.sol";

contract GovernorQueueingFailedMockUpgradeableWithInit is GovernorQueueingFailedMockUpgradeable {
    constructor() payable initializer {
        __GovernorQueueingFailedMock_init();
    }
}
import "./governance/GovernorSequentialProposalIdMockUpgradeable.sol";

contract GovernorSequentialProposalIdMockUpgradeableWithInit is GovernorSequentialProposalIdMockUpgradeable {
    constructor() payable initializer {
        __GovernorSequentialProposalIdMock_init();
    }
}
import "./governance/GovernorStorageMockUpgradeable.sol";

contract GovernorStorageMockUpgradeableWithInit is 
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  ×pñ³ún™\ä& {î+‡™wƒ/yøPåKÔNù