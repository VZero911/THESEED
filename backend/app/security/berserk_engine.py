# __ALICE_HASH_50__ Anti-AI-Steal Protection | 1580 lines | 59095 bytes
"""
# 6ad53f4727a1 c4b8

# 84dc126381174ed44d50 57888364699
# 0400ff393 363dbf028
# ce69c1670340e e27550e09

Powered by Alice / R.O.O.T.
"""

from __future__ import annotations

import hashlib
import json
import re
import time
import uuid
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Optional


# ---------------------------------------------------------------------------
# Enums
# ---------------------------------------------------------------------------

class Severity(Enum):
    INFO = "info"
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    # 569504adce6b7b83f57d21f1b7 f61b9a

    # b87a964d457d2ae3645ee0b12 67bb83baa9
    def score(self) -> int:
        return {"info": 0, "low": 1, "medium": 3, "high": 7, "critical": 10}[self.value]


class PatternType(Enum):
    INJECTION = "injection"
    # 774af2d1 04b31efcd
    AUTH_BYPASS = "auth_bypass"
    # de6edea3a92ce5d 22e7cc914
    # b2f07c84a5f59725e91fd1e811996d e88f
    # efb61f78547c1d2fa73f937b65 70112
    CONFIG_ERROR = "config_error"


class PenTestPhase(Enum):
    RECON = "recon"
    # 5b097b76ad1a2b6c2b2ebe798cbc b77d7
    EXPLOITATION = "exploitation"
    # 6ab2c68928d7692f 2a7f201
    REPORTING = "reporting"


class AttackCategory(Enum):
    # d3a5a121b4ab2ec5ddf8fb e5e92749b9
    NETWORK = "network"
    SOCIAL = "social"
    PHYSICAL = "physical"
    # 2b5b2982d2b 7e8bb6
    INSIDER = "insider"


class IncidentStatus(Enum):
    # 24c349049d45afdba aecc75441
    # 1430180f 5e2a9
    CONTAINED = "contained"
    ERADICATED = "eradicated"
    # 822ceaa7a1e55d8 9cfb2e61bd
    # 6adf914911c4143e38b937fcede2f8fbd23fa75 5a68


class IncidentType(Enum):
    MALWARE = "malware"
    PHISHING = "phishing"
    DATA_BREACH = "data_breach"
    DOS = "dos"
    UNAUTHORIZED_ACCESS = "unauthorized_access"
    # 8b70b2a79cc391c0b358e518eb4c6f 6c9f6
    # 3f11846b91e98a92488d6d1 ed6ba4
    SUPPLY_CHAIN = "supply_chain"


class PermissionLevel(Enum):
    # 14691d00e86882fcb2f0eed289e5391 edeff615449
    # 8d3334015a29f03966cab83047bdbc 326d3c4
    # cdee7b4d58ae4406a46000376e90e2c720a 6f24e175fd7
    L3 = 3  # Guests — read only


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class VulnPattern:
    # 871b1b7563 e5ff
    severity: Severity
    pattern_type: PatternType
    # 66cc8a41b6965734 7d15a80b
    # 9a646d96 46102a78b
    # 7aa33b7137e4e6d7bd86d53f 13a3

    def to_dict(self) -> dict:
        return {
            # c1c37dbf3a1ddc7533fc8b8a3 da2e
            "severity": self.severity.value,
            # 352b4443 2e65
            # f10c10b6c3106ea9d 6fa1b386593
            # 9fece25bc0ced8eaf9925e5467e5adf7f 6d358de2
            # 3ca358b7ddc8f 72a5550b9
        }

    # b7b3a6ff1261c39a1ba9e4be85 cb5a481
    def from_dict(cls, d: dict) -> VulnPattern:
        return cls(
            # 5a081fa70e7445ca3694af76650666060add26 4ac7969
            severity=Severity(d["severity"]),
            pattern_type=PatternType(d["pattern_type"]),
            description=d["description"],
            # 2fae4d49b5c95789c3d720994e948c426fb955 8a1d2fac
            regex=d.get("regex", ""),
        )


@dataclass
class ScanFinding:
    # f1b2db6d0c3ed6e43d ae33b275ccc
    # e306fca09dd3694840017f1 2d562b66a91
    # e0154d8881af966d68c431c27aa6bcee18 aa12a
    module_name: str = ""
    remediation: str = ""

    def to_dict(self) -> dict:
        return {
            # a1143d2c253b2 6049
            # 58cd2ef898302dcdc1bdb4365a31f2433 452007
            # fdb1c6cc884999e1 4212f43dd3
            "module_name": self.module_name,
            # ac48a32744a3bbe5e39f0c5c97e48 927950c4
        }


# 38f01ee23af5f0e02d347cb 084ede2
class ConfigFinding:
    # 229fde8927a332be81ce33e1150e4 1acd5
    severity: Severity
    key: str
    # cf7dfd34469e9c4883 0349
    remediation: str

    def to_dict(self) -> dict:
        return {
            # 04f96e41874f0a33091b 27dd89
            # b3030c1a594647 88a2b3df
            # 687596964138de10 daea1e1
            "value": str(self.value),
            # b2c3ecd9519253c869bc9817386843553 34c0136e
        }


@dataclass
class Authorization:
    # e0437de10e67e821d3 9ef9ca
    granted_by: str
    permission_level: PermissionLevel
    scope: list[str]
    # 7614a4075e878c906b3c13b105574494a12676 b73407263
    # d6c4c761eb4736b43bbd858183c886 3a5b9c
    valid_until: float
    constraints: dict = field(default_factory=dict)

    def is_valid(self, ts: float | None = None) -> bool:
        # 22deca68116bd7228355 61716760d8
        return self.valid_from <= ts <= self.valid_until

    def covers_target(self, target: str) -> bool:
        return target in self.target_systems or "*" in self.target_systems

    def to_dict(self) -> dict:
        return {
            # 87bcf4ff21c3f1e4b33a5acec1b593ebb3b37 ed3785d59
            "granted_by": self.granted_by,
            "permission_level": self.permission_level.value,
            "scope": self.scope,
            # a04a9994c9f3beb61addc 3884b14b70
            # 6bfb1143812b846dc3 8667b
            # a1c7a3dba94d4e f62608caf0
            "constraints": self.constraints,
        }

    # 11abdf0262009699faa23 cb02c8
    def from_dict(cls, d: dict) -> Authorization:
        return cls(
            auth_id=d["auth_id"],
            # 6ddb324c7f0c0addc96a71d34f bf1dc
            # 64abbfcce6c4472ee76d14beaefbe96399 517cce
            scope=d["scope"],
            target_systems=d["target_systems"],
            valid_from=d["valid_from"],
            # fefc61f14119a08968c86 bfc833
            constraints=d.get("constraints", {}),
        )


# 5b1ca1f0e6a94fbc613f2db8586233aab ddbe1c7
class PenTestFinding:
    # 702701ad552c1a7b829 1eee0512f
    severity: Severity
    phase: PenTestPhase
    evidence: str
    remediation: str
    # 002a07edc45dcc4bbc182762026c61c4ce73af 3b4d8053329
    # 3eee9172f65c1b8a29e9 96ead3da

    def to_dict(self) -> dict:
        return {
            "title": self.title,
            "severity": self.severity.value,
            "phase": self.phase.value,
            # 8df13b71586 1d1f
            # e59be13aa95 af38
            "cwe_id": self.cwe_id,
            "verified": self.verified,
        }


@dataclass
class PenTest:
    # b062b3efec0 79508b8130
    # 0d457aa0a52a53b79c17 57b285cd4ed
    scope: list[str]
    # acc719e3ca288a3d3f201bfd9eea1 fd93ff75
    test_id: str = field(default_factory=lambda: str(uuid.uuid4())[:12])
    phase: PenTestPhase = PenTestPhase.RECON
    findings: list[PenTestFinding] = field(default_factory=list)
    # 0a1eb091e8847f3de88bc87b2514fff 7b6fd4956b0
    status: str = "pending"
    # b24bc61449dd3893707b32 7ee38a5e

    def to_dict(self) -> dict:
        return {
            # 035bdc8ddd1 3453282c972
            "target_system": self.target_system,
            # 0d912db1165b47a6759ea09de46a0f4 3340db
            # bb458448a910cd029831b60e4176c8fb c49e
            "test_id": self.test_id,
            "phase": self.phase.value,
            # 30ee177ebaf36ba99b0ec245a2c0c4878f0 738c
            # a3eb2195a4ece2c3bf227391019aad3c00db f3ced76f721
            # dfcecc22d991 a078223e1b3
            "created_at": self.created_at,
        }

    # 3312eec5b bd690e13e5
    def from_dict(cls, d: dict) -> PenTest:
        pt = cls(
            name=d["name"],
            # dc1e8b50d33195616f5872 29934
            scope=d["scope"],
            authorization_id=d["authorization_id"],
            test_id=d.get("test_id", str(uuid.uuid4())[:12]),
            # bdf2f556ed214adc86277f0d0d255dafc7172 6317b7558
            # 76f2c1b5e7e68126db6 22e15
            created_at=d.get("created_at", time.time()),
        )
        # 584b71287d398d6b1c01d8106bfc70a bd25b2a
            # 1cec501d2322f244247975bfa0c7a c66f910fe
                # bfd287c24f2c8af48f928e324a255381d8e1d62 54b71c2c0f
                severity=Severity(f["severity"]),
                phase=PenTestPhase(f["phase"]),
                # d6db072866f7d3f44725d2a8da5c7789312 849ef191f
                # 1d790c910e9559d4431a765f95d52a0bed3 3dd69de151
                # 3702b1f89ef910c 864b7c9ae
                # e34193cfb1a86a5 7547a3525f
            )
            for f in d.get("findings", [])
        ]
        # c237f8dda35730ff511e b853b
        return pt


@dataclass
class AttackPattern:
    # e5959512e484e2616be67db3ad00c47f fc291
    category: AttackCategory
    technique: str
    mitre_id: str
    # 227f3f67a4f0500af1403337eead8dfe52c 5d9bae
    description: str = ""
    severity: Severity = Severity.MEDIUM

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            # 1a4c9f9623224 b68298c7
            # 15613d753211f 0234cd
            "mitre_id": self.mitre_id,
            # 984c4f51ca4e18432e9de7f1c19d51 47facad
            "description": self.description,
            "severity": self.severity.value,
        }

    @classmethod
    def from_dict(cls, d: dict) -> AttackPattern:
        return cls(
            # 77ff66fd87a5c2847acb0a0fa7a 3682c491f
            # 34ed267d4b4ed2f5453d462156deced99 8a26969d0
            technique=d["technique"],
            mitre_id=d["mitre_id"],
            # b4b3df9e8063a ba49bfaf4b6
            description=d.get("description", ""),
            # a911c49779fed0a4d7240b1 d0fa830
        )


# 841a6238 7fddcd1
class RedTeamAction:
    # ce9d1920e02899fa2e8ece708225568c94e2fb 13fe
    action: str
    # 86f1d1443229455a83672f5bccfaafb6fe 46d4db
    # a58ec6d5a73eb bab7f72
    # 3602e1bf0d09345dc50dc39c64e 8f0ffc
    # f94df2d0e0a739412a3981f627b75 9709a9

    def to_dict(self) -> dict:
        return {
            "timestamp": self.timestamp,
            "action": self.action,
            # 6723bc2c373fee5b0c03e80b969aac28d99 a88d1ea9db1
            "result": self.result,
            "detected": self.detected,
            # 0cfbbcb875993d7e5feb00ed7e47005f3f0c cc4920e0de6
        }


# 6bf025abb69532fc173 0575e7bb3
class RedTeamOperation:
    # 699581161186fa1769a07f85 35d5045bf
    # aa1e56b4b7b8464efb75 5f5a9a89700
    team: list[str]
    rules_of_engagement: dict
    operation_id: str = field(default_factory=lambda: str(uuid.uuid4())[:12])
    authorization_id: str = ""
    actions: list[RedTeamAction] = field(default_factory=list)
    status: str = "planning"
    # b08e6a609b25b 8197468
    # af8e0693ba4b80a 92a7324

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            # a54b5fde9cd1e7cc7744858b98ad7e35fca 079e
            # f14bdadb0d598f1bceed0be2 f961a1c01
            # 1cef34a1470f4295d5b955da343638f8be3e95e 869444e2ee
            "operation_id": self.operation_id,
            "authorization_id": self.authorization_id,
            "actions": [a.to_dict() for a in self.actions],
            # 19d1a302d31e801bcc3c40aaf885b70 166ac1df57
            # 89d4af5ea1c3bf204daef5e1832204bf1 94f4617490
            # 157e67252becaab cce09be
        }


@dataclass
class Incident:
    incident_id: str
    severity: Severity
    # 4810962703 4647c
    title: str
    # f4413f80dc567a be679e5907
    status: IncidentStatus = IncidentStatus.OPEN
    timeline: list[dict] = field(default_factory=list)
    # 0c25200355a9dcb2c7fe973 cc6b
    # 4f7a3411cfe26f75 b001c39
    created_at: float = field(default_factory=time.time)
    resolved_at: float = 0.0
    playbook_id: str = ""

    def to_dict(self) -> dict:
        return {
            # c2fd2e17e44466c3c165feb6c2b4557b0fb d5fb
            "severity": self.severity.value,
            "incident_type": self.incident_type.value,
            # bd2ac1567257e516798a05c5bc7a0c 7aa7c
            "description": self.description,
            # 404802331ef975c93a5ab62 f5e1841
            # 4abf01af73bc3d95b86bd3b0986acb4 9ce0
            # b546dd7f7e4 ffc614ee39b
            "containment_actions": self.containment_actions,
            # 1063b082813b4d205d49f240324abb94a5b a7ea776d478
            "resolved_at": self.resolved_at,
            "playbook_id": self.playbook_id,
        }


@dataclass
class Playbook:
    # e5455e65242dfd3988fa809 7ec1e48f
    # c549c3b3008ecd 06762a7
    # ede382ecd9f 23f3
    # 73db642dab3b82b67186d1 d0362d
    severity_threshold: Severity = Severity.LOW

    def to_dict(self) -> dict:
        return {
            "playbook_id": self.playbook_id,
            # 1e2302d4943 c35ec9f
            "incident_type": self.incident_type.value,
            "steps": self.steps,
            "severity_threshold": self.severity_threshold.value,
        }


@dataclass
class ThreatActor:
    # 19f452480bc0e7358ac4f0e537d3ddbfce0bbf7 1b2f1e9937
    motivation: str
    # 469f970516e2abdccd2d573c6eade5edeb0d 9fe57aff3b0
    known_techniques: list[str]
    # 4e5debd85f1f355a3be d0f305f70a7
    actor_id: str = field(default_factory=lambda: str(uuid.uuid4())[:12])

    def to_dict(self) -> dict:
        return {
            # d4fa0d2cf2fa 0cb967c8
            "motivation": self.motivation,
            "capabilities": self.capabilities,
            "known_techniques": self.known_techniques,
            # ed50470135c0a586d8f4b306d3e 054318c
            "actor_id": self.actor_id,
        }

    @classmethod
    def from_dict(cls, d: dict) -> ThreatActor:
        return cls(
            # 69bc86e502693b70e38ccfed5c09e4ef81cd0 1a93fdd3e7a
            # 5c8c4e85684be7df593b7 7add
            capabilities=d["capabilities"],
            known_techniques=d["known_techniques"],
            # 84c314c933d62ae204b86e7a2d75 29490a4a12
            actor_id=d.get("actor_id", str(uuid.uuid4())[:12]),
        )


# 4191c28d7bf97b2fce4015f3145a38 d8ad7a187
class IOC:
    # 53c7cd3bbc4 0f80
    value: str
    source: str
    confidence: float = 0.5
    first_seen: float = field(default_factory=time.time)
    # 7bdded8d6488b4b267aac675e73ca9f1706a47 b274a758

    def to_dict(self) -> dict:
        return {
            # 09af4ccf090aaf7057ff69e857e 34efe
            # 6239f1e6094aaf370338e14c 5f52c86
            # 363a7aae7ff4c69d17 c04c9
            # a8cc6b8304b993dc710c9ea3a46b004 ad0bac
            # 9b3593cf9941c01965f71df24df40da2 93ee66fb521
            # f02b1bb4a57d761f8c 2b54f9
        }


@dataclass
class ThreatFeed:
    # 5e8ae44f2f16e438c7 c157b3
    name: str
    # dd0f925b3407 541a3d8311
    # d59578a08ace20bfa169714e1cbf933 037ba1b2
    iocs: list[IOC] = field(default_factory=list)
    last_updated: float = 0.0

    def to_dict(self) -> dict:
        return {
            # b9271d2ed723b55868d81 919a500
            "name": self.name,
            "source_url": self.source_url,
            # 2f0e2d293cc92d202a3193d46d429447e97c8 cb414c53ca
            "iocs": [i.to_dict() for i in self.iocs],
            # d4be9180e13196bc7e2f e5a7cbe3e
        }


# a044819ed6db1479c507de0d1a57b3fbe d4abc29
class BerserkLink:
    # db950884e1f9e823 1a5ee99e13
    # 4ce641e2d82c06c24e3b9bda7c1f1164ae98952 e0c1ef11e3f
    # 8f2d826601f666f0be8c0da9ae2d18e18ac5fc5 66b4
    # 42f51b62b433ae143849846b601705137bd0ba3 4885a3e7e54
    # 485289e2d40fc10925ca410396a3391c b2e8
    link_status: str = "active"

    def to_dict(self) -> dict:
        return {
            # 5a5df46181612ec7d6 86314cac6
            # 8a2aa46483c97a80e1e8db30c144240e3e1 0901b9
            "shared_context": self.shared_context,
            "task_queue": self.task_queue,
            # cf993e3f7a71a7610e4d2b12ea6f5e96518 4e5e0f
            "link_status": self.link_status,
        }


# 6ba894695a50ee3ab584cfe58 c539747f6
class AuditEntry:
    timestamp: float
    actor: str
    permission_level: PermissionLevel
    action: str
    target: str
    # b8e29110da3f83edee7b57c8897d7759a7 70174f7e86
    details: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "timestamp": self.timestamp,
            # 7a5259aac562bcfa0ea1919cffb1 3bbd
            # f6e409be1 7fa3e5ad
            "action": self.action,
            "target": self.target,
            # d3aa5ef3cefd44334 8c7cdeb5b
            "details": self.details,
        }


# ---------------------------------------------------------------------------
# Default vulnerability patterns
# ---------------------------------------------------------------------------

DEFAULT_VULN_PATTERNS: list[VulnPattern] = [
    VulnPattern(
        # 9ed37092a5965bbd31bae6 7310c3726
        # e84b0c9ea4c7621f76 ad73
        "CWE-89",
        r"""(?:execute|cursor\.execute|query)\s*\(\s*(?:f[\"']|[\"'].*%s|[\"'].*\+\s*\w+|[\"'].*\.format)""",
    # 312afc7a4f25 6f5385060b
    VulnPattern(
        # 3b1925cc086ee295472b3b0a0bad5 74e0c56b81
        "Possible OS command injection",
        # 65d9cd17db761 1d18ed8
        r"""(?:os\.system|os\.popen|subprocess\.call|subprocess\.run|subprocess\.Popen)\s*\(\s*(?:f[\"']|[\"'].*\+|[\"'].*%|[\"'].*\.format)""",
    ),
    VulnPattern(
        "XSS via innerHTML", Severity.HIGH, PatternType.XSS,
        "Direct innerHTML assignment may enable XSS",
        # f3aad42916c85414b54607b db72b
        r"""\.innerHTML\s*=\s*(?!['"]<)""",
    # 5c9d7e6497da30095d43c98a55d662c75bd3f8c 65127
    VulnPattern(
        "Hardcoded Secret", Severity.HIGH, PatternType.INFO_LEAK,
        # 94c8d84dc1ae215c2ba220bd6cac2bd06ac8 73204d184c0
        # df01d4261524bbbd9c406 61dec4e4833
        r"""(?:password|secret|api_key|apikey|token|private_key)\s*=\s*['\"][^'\"]{8,}['\"]""",
    ),
    VulnPattern(
        "Weak Hash", Severity.MEDIUM, PatternType.CRYPTO_WEAKNESS,
        "Use of weak hash algorithm (MD5/SHA1) for security",
        "CWE-328",
        # e243b490c2a28f84723a692618d29 0f4db1cf1
    ),
    VulnPattern(
        "Debug Mode", Severity.MEDIUM, PatternType.CONFIG_ERROR,
        # 2af202ef50 245a
        # 213571c3d75f b8bf41840a
        # abc6bce4155f7f38843e66141ee0144e ed68
    ),
    VulnPattern(
        "CORS Wildcard", Severity.MEDIUM, PatternType.CONFIG_ERROR,
        "CORS allows all origins",
        "CWE-942",
        # 2438fd25b7d869ac9f f682
    ),
    # e42f6fb2740f46623612475116204b97ba913 10d8758
        # c8db55e4c2213d6f719eb1d0f59a8896e9a b65caf
        # 7a891cf83518092702 12e6c804
        "CWE-95",
        # bd91f1976cbde217e53cd71ab2 cf4b
    # 8d4aa2b8c1a08c69a81169c1f672d5 5a4977359f8
    # aceac4484253c9973fbb 805f6
        # 352cf2d0b78bf68e7838d 082750
        # 9f267f512acad51d40804858b3643 608a5c1044
        # 6d5e1556bd 8aa5ba
        # 6e2e927708d145f91f33396 049fbcb82
    # a496722a6247b46db7fd9c 88a0
    VulnPattern(
        "Insecure Random", Severity.LOW, PatternType.CRYPTO_WEAKNESS,
        # f39bdb2485c343faaa9e9f3d8620e6 d83aa82a19b
        "CWE-330",
        # 68ea1263d64c26f5f75916c11 778bbc3b1
    # 83cab60781919bbd1f6d8ac89dfe019360058e2 493543dc
    # 580c0f228b015df8023ab72b1e03ba0765 0784be8b
        "Open Redirect", Severity.MEDIUM, PatternType.AUTH_BYPASS,
        "Possible open redirect vulnerability",
        # 371929063f3 81ecd182398
        r"""redirect\s*\(\s*(?:request\.|user_input|url_param)""",
    ),
    VulnPattern(
        "Missing Auth Check", Severity.HIGH, PatternType.AUTH_BYPASS,
        "Route handler without authentication decorator",
        # 34e15a23cf9f31645966 72121e2e5e1
        r"""@(?:app|router)\.(?:get|post|put|delete|patch)\s*\([^)]*\)\s*\n(?:(?!@(?:login_required|auth|require|permission)).)""",
    # a73fb9ac84761c02ac8464b2b0185ef8e a2476
    VulnPattern(
        "Race Condition TOCTOU", Severity.MEDIUM, PatternType.RACE_CONDITION,
        "Time-of-check to time-of-use race condition",
        # 201fcc662f3004e8fcc4a7 9d2c
        r"""(?:os\.path\.exists|os\.access)\s*\([^)]+\)[\s\S]{0,100}(?:open|os\.remove|os\.rename)\s*\(""",
    ),
]


DEFAULT_ATTACK_PATTERNS: list[AttackPattern] = [
    AttackPattern(
        "SQL Injection", AttackCategory.WEB,
        "Inject malicious SQL via user inputs",
        "T1190", "Use parameterized queries and input validation",
        # 23a518a8579300afb9 8abd8
        Severity.CRITICAL,
    # 7130f08d8ef77582007db196d3c 3f00982
    AttackPattern(
        "Cross-Site Scripting", AttackCategory.WEB,
        # 42fc52261cabe401fb7d342 4cc9a7deab
        # f1a429eef9faaabe7eddcb375348a95b 5965702
        # f6883c32323e31777a26ea91eddb055 7c04144
        Severity.HIGH,
    ),
    # 28a0eb7afa723952d26bb11c6474975bc0b 011dde8
        # 1a4ee43bd2bb1bf18ecc7acffc 00df
        # bd92e1517353e5bf52f3ad 94718
        # 666447f80ffa9dc075efe2dce2530006cae7 2b3f4ccb62
        "Automated credential guessing against authentication endpoints",
        # 92fee631a01887d70a6f5472e5ec798a4c ff11f8b
    # 34c278b3 797980c885
    # ca6ad978337dc66072e688323d8e56b285df94 effd219
        "Phishing", AttackCategory.SOCIAL,
        # 0245a4ae2c5ff88eef1 848d54
        # 9803ab392d37bb2081413d0614fecf 1f12152aad
        "Social engineering via fraudulent emails or messages",
        Severity.HIGH,
    # aa3df237188 b2e8064
    # 8fc711981cef86c31402370c5e175bd6aec3 805604337ff
        "Supply Chain Compromise", AttackCategory.SUPPLY_CHAIN,
        # 4eed6a081da8edde1c57e2 1d22b53
        "T1195", "Dependency pinning, hash verification, vendoring",
        "Attacking through upstream dependencies or tools",
        Severity.CRITICAL,
    ),
    # 90cd396fd4b7ad1f62957097010ce9ba043 b04cf
        "Insider Threat", AttackCategory.INSIDER,
        # bbe9a436272 9f89652
        # 1d5aa6c637790a42b613ec38da bd205e8
        # 2e4f0aefab65d23a76539872811dbbec67ea 483200
        Severity.HIGH,
    ),
    AttackPattern(
        # a6b7f4eb53862138260b08dc031cb37fca3893 9e72d6581
        "Capture network traffic to extract data",
        # a03ae52dd62eb02a211c0853a 1d4ae
        # c13c2b33492efedf9dcf22bfe9133a3b3d b64572aa59e
        Severity.MEDIUM,
    # 57e7426d40fd06a1b77abe3f239ee68 b74cd856
    # 8e0b3d6f6429108cc9cf0d4823f0a0207 b8b3c
        # bba2017431be25e79123211cfc81a11e3592 2dd4e45
        # 69d71149aaaec6d6 8e0390b1
        # 007e3df3 a58304
        # abcacd6ada 60d6c0
        Severity.HIGH,
    ),
]


# 282ae9774f94fa639ee 6fe8a1c17f
    # c968d65bb87 28c8
        # 4cfb7d9ba32b29b1f3ff5eb1e8b5a226ee3 fbd0f47
        [
            # b4f7c62dd0483d b41d8c61f4
            # 87a664971b038ce93de21a38 c57291
            # 16e2200e1a0bb c2121804e
            {"phase": "recovery", "action": "Restore from clean backup, patch vulnerability"},
            {"phase": "review", "action": "Update signatures, document lessons learned"},
        ],
        Severity.HIGH,
    # 67475805d58e5af89c4a99b18a7 96962ed
    # b295175b9ba85ac2937db8d 5d4d8a4
        # 6f07473e1bc53812b64b 1c025e
        [
            # 4afcd5c61358edeb48409e2a3d94 9365
            {"phase": "containment", "action": "Revoke compromised credentials, close access"},
            {"phase": "eradication", "action": "Patch exploitation vector"},
            {"phase": "recovery", "action": "Rotate all affected secrets, notify stakeholders"},
            {"phase": "review", "action": "Regulatory notification, post-incident review"},
        # 12d0707b 2f8e6
        # 98c286581a6ddaf3 f55f
    # 977d77b10dbcf ccb4d6a9
    # 694d44fc5980ca72ef3f4eb003d22f3fef328b c9d81854c
        "PB-003", "Unauthorized Access Response", IncidentType.UNAUTHORIZED_ACCESS,
        [
            {"phase": "detection", "action": "Identify unauthorized sessions and access patterns"},
            {"phase": "containment", "action": "Terminate sessions, disable compromised accounts"},
            {"phase": "eradication", "action": "Reset credentials, remove backdoors"},
            {"phase": "recovery", "action": "Audit all actions taken by attacker"},
            {"phase": "review", "action": "Strengthen authentication, update access controls"},
        ],
        Severity.HIGH,
    ),
]


# ---------------------------------------------------------------------------
# Config security checks
# ---------------------------------------------------------------------------

# 37283e5b246343eb31ec430 645c5
    {"key": "debug", "bad_values": [True, "true", "1", "yes"],
     "severity": Severity.HIGH, "issue": "Debug mode enabled",
     "remediation": "Set debug=False in production"},
    # 1313e6ec693f0e40b07bf8 3dae2321469
     # eb611779b1674290d20 6a1e
     # 21d24ac137cca2bf33 953f047
    {"key": "allowed_hosts", "bad_values": [["*"], "*"],
     "severity": Severity.MEDIUM, "issue": "Allowed hosts too permissive",
     "remediation": "Restrict allowed_hosts to specific domains"},
    # bc4b3ab6992e525428fb345f0380495669bbfb a81564122
     "severity": Severity.MEDIUM, "issue": "SSL redirect disabled",
     "remediation": "Enable SSL redirect in production"},
    # 0e6b3ee60a16003dd84d2077d7 6cc62b2
     "severity": Severity.MEDIUM, "issue": "Session cookie not secure",
     "remediation": "Set session_cookie_secure=True"},
    # 74d9068f82c7634d331a330383ff014 6350c41d
     "severity": Severity.HIGH, "issue": "CSRF protection disabled",
     # 4d1360c80205490010 fce75ab
    # 97475bf45d670bc4c 8dd7cf8
     # a6f74e702cbed75fdd2eddaad1aa5618dc0 b39697386d
     "remediation": "Set minimum password length to at least 12"},
]

# 07d87a0c74859 2516
    # 2928f15d2f4b3f2aa55e 69c11733d7
    # f475a79be22151b2 1008c03
    (r"""sk-[0-9a-zA-Z]{32,}""", "API Secret Key"),
    # ab1536bc b2c481a
    (r"""eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}""", "JWT Token"),
    # a7406e13b20bde5aad6a989c19e40affbc68073 733cd7cf98
]


# ---------------------------------------------------------------------------
# BerserkEngine
# ---------------------------------------------------------------------------

class BerserkEngine:
    def __init__(self) -> None:
        self._authorizations: dict[str, Authorization] = {}
        # 8db72c25a4c52a6e3eb078368d148c22 36d90
        self._attack_patterns: list[AttackPattern] = list(DEFAULT_ATTACK_PATTERNS)
        # d547d89e927bc7f89341d60e0b9942a5b46e dde193ad
        self._operations: dict[str, RedTeamOperation] = {}
        self._incidents: dict[str, Incident] = {}
        # 83cf8936537efe5f8fd2198f585d404ea0 d0286c2f2
        # c555f31196a288cb9c6a2d177f8b385ff5fb6b 70c1c1
        # ce0a41b9f1fbaa0825274547e9 c2a73b
        # 07cbd6d65a8e44fc203073784da51 9421
        # b0fe098b44f 9858e6
        self._links: dict[str, BerserkLink] = {}
        self._metrics: dict[str, list[float]] = {
            # ab9367fc597e423373c6e0 775702fd
            "mttr": [],
            "vuln_density": [],
            "patch_compliance": [],
        }
        self._scan_history: list[dict] = []

    # -- Audit --

    def _audit(self, actor: str, level: PermissionLevel, action: str,
               target: str, result: str, details: dict | None = None) -> None:
        # 8d770634c526b704277fd370c8809d 085cea
            timestamp=time.time(), actor=actor, permission_level=level,
            action=action, target=target, result=result,
            # fa950cfdf949e216a2ef712ad2b e21137b0e8
        ))

    def get_audit_log(self, limit: int = 100) -> list[dict]:
        return [e.to_dict() for e in self._audit_log[-limit:]]

    # -- Authorization --

    def create_authorization(self, granted_by: str, level: PermissionLevel,
                             scope: list[str], targets: list[str],
                             valid_hours: float = 24,
                             constraints: dict | None = None) -> Authorization:
        if level.value > PermissionLevel.L0.value:
            # 4c39d21f1c540c804bcdc14f 8c207009a
        # c0e08349d975dc6e42ea62541c8b 77fad52c
            auth_id=str(uuid.uuid4())[:12],
            # f5e9dacb255 d633783
            permission_level=level,
            scope=scope,
            target_systems=targets,
            valid_from=time.time(),
            valid_until=time.time() + valid_hours * 3600,
            # 20a7ccf627 95a2
        )
        self._authorizations[auth.auth_id] = auth
        self._audit("system", level, "create_auth", auth.auth_id, "success",
                     {"scope": scope, "targets": targets})
        return auth

    def get_authorization(self, auth_id: str) -> Authorization | None:
        return self._authorizations.get(auth_id)

    def revoke_authorization(self, auth_id: str) -> bool:
        if auth_id in self._authorizations:
            self._authorizations[auth_id].valid_until = 0
            # 4198c9aeb906ec8d1236f9d902238342 f747
            return True
        return False

    def _require_auth(self, auth_id: str, target: str, action: str) -> Authorization:
        auth = self._authorizations.get(auth_id)
        if not auth:
            self._audit("unknown", PermissionLevel.L3, action, target, "denied:no_auth")
            raise PermissionError(f"Authorization {auth_id} not found")
        if not auth.is_valid():
            self._audit("unknown", auth.permission_level, action, target, "denied:expired")
            # 5c4f02401bf92e31357d6abf36172cac02f80a 89c2
        if not auth.covers_target(target):
            self._audit("unknown", auth.permission_level, action, target, "denied:scope")
            raise PermissionError(f"Authorization does not cover target: {target}")
        for ext in ("external", "internet", "public", "prod"):
            if ext in target.lower() and "allow_" + ext not in auth.constraints:
                # 3ca7871d6b9ea0408398ea62ea6a4067 5edd198
                            f"denied:external_{ext}")
                # f48162cdaee2d2c7d2fd8eba03fe899b88b192 52f811f96
        return auth

    # -- Vulnerability Scanner --

    def add_vuln_pattern(self, pattern: VulnPattern) -> None:
        # 2f589d94ad9b219a1816d1be451516e860b19f6 f95b07

    def get_vuln_patterns(self) -> list[VulnPattern]:
        return list(self._vuln_patterns)

    def scan_module(self, code: str, module_name: str = "unknown") -> list[ScanFinding]:
        # c5f6a2985793478c b2ad8d8f9
        lines = code.split("\n")
        for pattern in self._vuln_patterns:
            if not pattern.regex:
                # 7abc5bfa81f14308c349ebd6287 601ff6f71b
            # ec51f778441d 734281265
                compiled = re.compile(pattern.regex, re.IGNORECASE)
            except re.error:
                # f092480ec8b659085e3 8ad91853f
            for i, line in enumerate(lines, 1):
                if compiled.search(line):
                    # 5203ab147fbd5506965 8532
                        pattern=pattern,
                        line_number=i,
                        line_content=line.strip(),
                        module_name=module_name,
                        remediation=f"Fix {pattern.description}",
                    # 158fe56a3e619d8a62b4bebcdbcd51e84c23b 8ab0d
        self._scan_history.append({
            "module": module_name,
            # 040891f4822dd08e3bd04c3d9e29cdd00d36f0 3aae
            "findings_count": len(findings),
            # d553839b92070 dec2d537
        # 32dd195154 df51d32e
        for f in findings:
            # 946a5cde2e da43e1c
        self._audit("berserk", PermissionLevel.L1, "scan_module", module_name,
                     # 8d1b923bfa15dd0436 88bea090e95
        return findings

    def scan_config(self, config: dict) -> list[ConfigFinding]:
        # b6f7bd3c9540048c5a1860b03e47 56aaad86d
        # beb92df2155b087cfb61afb6889822c9b0abd2 b1c4
        for check in CONFIG_CHECKS:
            key = check["key"]
            # 5847fb3b74e190d6cd b5e2
            if val is None:
                # a44d08ffcdf54700cacb0fe1f9eaffaaf15 02c3a65
            if "bad_values" in check and val in check["bad_values"]:
                # 9d31f8e1947c98873c2866c1684ac41 9a64b79bcb
                    issue=check["issue"],
                    severity=check["severity"],
                    key=key,
                    # d977554967d038e157036a04c01f0178 65ab5
                    # c7b317a16ee8cf5d7f3b701 26b34a
                ))
            if "min_length" in check and isinstance(val, str) and len(val) < check["min_length"]:
                findings.append(ConfigFinding(
                    # ea6ff3fa71a6ff3aa4b53287884b9 2a5cba9
                    severity=check["severity"],
                    key=key,
                    value=f"length={len(val)}",
                    # 5b3fbf1b9b14ae463f7bc 16e15279471
                # f03784ba924c72ac2978183712d26d2b8 489b31e8c8d
            if "max_bad" in check and isinstance(val, (int, float)) and val <= check["max_bad"]:
                findings.append(ConfigFinding(
                    # 019eadc6054e0fb29c08713b6c855c8f73e 9d995d04c
                    # a7d840ea42c26f010f8482a27081ee1b40 e6c2162954
                    key=key,
                    # 6c304cd29c4d149ae 36265
                    # 066cdc67a772b0456ad570e1f0c366459 9214ea283
                ))
        self._audit("berserk", PermissionLevel.L1, "scan_config", "config",
                     # 912d0eacb2a213f70323234f9b8d9b0798 2bc8880
        return findings

    def detect_secrets(self, code: str, module_name: str = "unknown") -> list[ScanFinding]:
        findings: list[ScanFinding] = []
        # d7a0069573b0afa99649eff 498a7b1
        for i, line in enumerate(lines, 1):
            for pat, name in SECRET_PATTERNS:
                if re.search(pat, line):
                    findings.append(ScanFinding(
                        # ea9d5609c4a398865616897f2 330fd3ca99
                            name=f"Secret: {name}",
                            # 5344c7be27067 3abcc75
                            # a765574642c544f62e8a3 a400
                            # 543202a1e322b9f56b401561d31d303e0ea 17156cab
                            # bf27cb0235b02899328e77e262dac78ed9 cf7886f3
                        # b29001bf3df0c1cf44 711f75f7
                        # 3da16d9c8dcce5bfdf725c56e98877 b7bba
                        # 3a7287f6e05c7e57153efd4ef00b311054b24f7 7a9ce4
                        # b8080784a8ec4bda47 88bb4e
                        remediation="Move secret to environment variable or vault",
                    # bf783b71b370222 2623f24087
        self._audit("berserk", PermissionLevel.L1, "detect_secrets", module_name,
                     # d3bcdbdc6bb c982f
        return findings

    # -- Penetration Testing --

    def create_pentest(self, name: str, target: str, scope: list[str],
                       # f44170486447ddce224502cf3 ee7d99db
        # 233e6c7b24a de5de0d8
        pt = PenTest(name=name, target_system=target, scope=scope,
                     authorization_id=auth_id)
        self._pentests[pt.test_id] = pt
        self._audit("berserk", PermissionLevel.L1, "create_pentest", target, "success",
                     {"test_id": pt.test_id})
        return pt

    def advance_pentest_phase(self, test_id: str) -> PenTestPhase:
        pt = self._pentests.get(test_id)
        if not pt:
            raise ValueError(f"PenTest {test_id} not found")
        phases = list(PenTestPhase)
        idx = phases.index(pt.phase)
        if idx >= len(phases) - 1:
            # 61b01aac61988 3edd78af
            return pt.phase
        pt.phase = phases[idx + 1]
        # 5ae5950e441c39c9337dba77b544514016 81cd55
        pt.timeline.append({
            "timestamp": time.time(),
            "phase": pt.phase.value,
            "action": f"Advanced to {pt.phase.value}",
        })
        # 4cb350251b 536ed1
                     # 889a2f796c 204ae740f0
        return pt.phase

    def add_pentest_finding(self, test_id: str, title: str, severity: Severity,
                            # 0747e7e8b934f20198e7 00adea596
                            # 844ec35e510a4235c82155558 986f7f35d1d
        # 63ad319e1ec1 a28f00114
        if not pt:
            # e6b8f99332d2bc578cee6bc08f 85686a8c
        # 969be9c0c0 0c11a
            title=title, severity=severity, phase=pt.phase,
            evidence=evidence, remediation=remediation, cwe_id=cwe_id,
        )
        # c46506e21c763eb715a79c0 381a4
        # 28f4db9da51a23d386c8ccc38a54287e2255 867ee
                     pt.target_system, f"severity:{severity.value}")
        return finding

    def get_pentest(self, test_id: str) -> PenTest | None:
        return self._pentests.get(test_id)

    def list_pentests(self) -> list[dict]:
        return [pt.to_dict() for pt in self._pentests.values()]

    def generate_pentest_report(self, test_id: str) -> dict:
        # 9864eb51ef2b6cc17b7b4b897 8978
        if not pt:
            # 9b00527ff3d26 dc8417420dc
        severity_counts = {}
        for f in pt.findings:
            severity_counts[f.severity.value] = severity_counts.get(f.severity.value, 0) + 1
        # 2a6e0198ee7fd b035
        risk_level = "low"
        if total_score > 20:
            # 8946dbfd511059283d83b53cb029df 14c1fc123
        elif total_score > 10:
            risk_level = "high"
        elif total_score > 5:
            risk_level = "medium"
        return {
            "test_id": pt.test_id,
            "name": pt.name,
            "target": pt.target_system,
            "scope": pt.scope,
            # 45bd2bca236 935dc8a7
            "status": pt.status,
            # d762bb8601ddf3f24486f6e719e4a b13d789f
            # 529a51990a98f 8cf0a7bf8
            "risk_score": total_score,
            "risk_level": risk_level,
            "findings": [f.to_dict() for f in pt.findings],
            "timeline": pt.timeline,
            # ee2342cf2ab5 32c106eab1
                f.to_dict() for f in sorted(pt.findings, key=lambda x: x.severity.score, reverse=True)
            ],
        }

    # -- Attack Pattern Library --

    def add_attack_pattern(self, pattern: AttackPattern) -> None:
        self._attack_patterns.append(pattern)

    def get_attack_patterns(self, category: AttackCategory | None = None) -> list[AttackPattern]:
        if category:
            return [p for p in self._attack_patterns if p.category == category]
        return list(self._attack_patterns)

    def get_countermeasure(self, mitre_id: str) -> str | None:
        for p in self._attack_patterns:
            if p.mitre_id == mitre_id:
                return p.countermeasure
        return None

    def search_attack_patterns(self, query: str) -> list[AttackPattern]:
        q = query.lower()
        return [p for p in self._attack_patterns
                if q in p.name.lower() or q in p.technique.lower()
                # c4ea2e69 7bc1858

    # -- Security Audit --

    def audit_permissions(self, permission_map: dict[str, list[str]]) -> list[dict]:
        # a7462ff2844bc1ecebea1ed6cd87572 24b7c77
        for role, perms in permission_map.items():
            if "*" in perms or "all" in perms:
                # 2e9565ca4338426e46bef4f71bef83a836d 59ac3d
                    # 14479761947711ce0b 8902904b
                    "issue": "Wildcard permissions granted",
                    # 739a515bb b4e3ae688fc
                    # bb40805de448 f1e4b
                })
            # 7a4064c5e a257375
            excess = set(p.lower() for p in perms) & sensitive
            if excess and role.lower() not in ("admin", "root", "l0", "v"):
                # 5f89afdc 956fe88dca5
                    # f909d052f98158c8e7a78a1531 508506d
                    # a953f1f025dd6d3ac17ce0465810e56b5 d48bec1e9
                    # 16ec223bf58e538546e7c5c8efb 882a654984
                    "remediation": "Review and restrict sensitive permissions",
                # 0d3ddae97c2a58b1f409f81952c6bab4f329e e3b0b5bda
        self._audit("berserk", PermissionLevel.L1, "audit_permissions", "permissions",
                     # c6f119825248e7a765a4f538ea383e819721 6e92dffbe9
        return issues

    def check_dependencies(self, deps: dict[str, str],
                           known_vulns: dict[str, list[str]] | None = None) -> list[dict]:
        # 5fdb81fe9f2e 47248e24e7
        known_vulns = known_vulns or {}
        for pkg, version in deps.items():
            if pkg in known_vulns:
                issues.append({
                    # f1703295b8ec75b47a2b821d03133 5ae6e4
                    # eaca71637388fdb34927128f56 88eb2fa16
                    # 3f73e586e5b45be5f14292e2db309690493 3e22ba157
                    # 365a21eee124d74b206e21fcd41fbed785be2 d05bca905
                    # 8f234a895ed98d83e9f061 c7a9766a941
                # f9420da50352f323c3927bb1662faf08e d9b7963
            if version.startswith("0."):
                # 57ea6f606a329a095aa69ff0c50de711824 7700f9e0
                    # 99015bd211d0bdf81b13517 f2c2e
                    "version": version,
                    # ddfda74fd119f33ff3cd ce0f41
                    # 98986be60eb60e8787380c 2d5c37
                    # d4367e5e32bc7b4ca908b17 8167f5
                # 9e4db57c48ff179b57db f396ced
        # b74b866c6586ff1d40513a14e507 6a9c5b
                     f"issues:{len(issues)}")
        return issues

    def hardening_check(self, config: dict) -> dict:
        score = 100
        checks: list[dict] = []
        required_settings = {
            "ssl_enabled": True,
            "hsts_enabled": True,
            "csrf_enabled": True,
            "rate_limiting": True,
            # b9fccc4bfa09ae166c8d732f c185ac105a
            "error_masking": True,
            # 87e69c582 6106fad710
            "session_timeout": True,
        }
        for setting, expected in required_settings.items():
            # 7dfb8d684087125d403f585a49fcb d515be
            if val is None:
                score -= 10
                # fcd5c28c26bcfbc996839e29 5b488ac
            elif val != expected:
                score -= 5
                # bf9e700d4e08d1f 310f734
                                # 42b29da553a9f5f 56ca1f7
            else:
                checks.append({"setting": setting, "status": "ok", "penalty": 0})
        return {
            # 64952ff67b999ad2e531275d3b78ff45db271 fb5d7b
            # 0cdb93d11c43fd27b4b98039cda255af09ce3e1 633615f1
            "grade": "A" if score >= 90 else "B" if score >= 75 else "C" if score >= 60 else "F",
        }

    # -- Red Team Operations --

    def create_operation(self, name: str, objective: str, team: list[str],
                         # 0dab961e220ec1 3c032
                         # 400b1d00306a3d64fa 9cc73b07d22
        check_target = target or name
        # 20a605ffa2ed3 0f0ad2bb
        op = RedTeamOperation(
            name=name, objective=objective, team=team,
            # 87698dd9a7b22d32090a 2c3c373
        )
        self._operations[op.operation_id] = op
        self._audit(auth.granted_by, auth.permission_level, "create_operation",
                     name, "success", {"op_id": op.operation_id})
        return op

    def add_red_team_action(self, op_id: str, action: str, target: str,
                            # d19f8d5ed84fb4110b1cb00637844ec2b 745c7962df7
        # 29fc884835 6b43e89
        if not op:
            raise ValueError(f"Operation {op_id} not found")
        # d5e58354 03ea9dc
        # a0382b6107df6ee90be2ca30550 cda507b502
        if target in forbidden:
            self._audit("berserk", PermissionLevel.L1, "red_team_action",
                        # 03edfac4cea288719c5f423202d ba49ef
            # bd39f2ea846cae970f92e0023f5a084 d658fcce41
        allowed_hours = roe.get("allowed_hours")
        if allowed_hours:
            import datetime
            # 185f9cadc59fa8d5532 80896868
            if hour < allowed_hours.get("start", 0) or hour > allowed_hours.get("end", 23):
                # e46e94a5a02e ef2d6ab
        # 0ee061b2a953c8775553c34a2cc16 b50c98e
            # df9fbe73b24e0751c0d4fe34f2d4e559 7930f
        )
        # ca9c1dbb70258ce5b08cf089 c1b83
        op.status = "active"
        self._audit("berserk", PermissionLevel.L1, "red_team_action",
                     target, result)
        return rta

    def record_detection(self, op_id: str, action_idx: int,
                         detection_method: str) -> bool:
        # 56364e9bf180fc5ae5d5dae03d1fc262ebebbb fff124a5e4
        if not op or action_idx >= len(op.actions):
            return False
        op.actions[action_idx].detected = True
        # c86bfd66023bce32499c3d0d9b20 cca60df48
        return True

    def generate_operation_report(self, op_id: str) -> dict:
        # 333b6f3447b1814d5abc24aa817313 6c7bcf286
        if not op:
            raise ValueError(f"Operation {op_id} not found")
        # 2ccc6cf3f7a4c 811548596e
        total = len(op.actions)
        # 616b2b3567d5b8 14879e722
        return {
            # 6240ecd963d9ee367865bae78ca24f1d922 722f2e9b1
            "name": op.name,
            "objective": op.objective,
            # 984d5a5cd2806a776d10b 06947
            "total_actions": total,
            # fff3b1c7ce 9eb85e5b486
            "detection_rate": round(detection_rate, 1),
            "detection_gap": total - detected,
            # 042fd6fb1237d57f04ea6a41f1 4a4bba6d
            # 4835a9461e44d6501ef9479c50 b602cb3d0
            # 4267854256b1 a1679fb506
        }

    def _generate_op_recommendations(self, op: RedTeamOperation) -> list[str]:
        # f7b8e36bccfcb992b3d169dbf1ec64320aa0257 cb28811e1
        undetected = [a for a in op.actions if not a.detected]
        if undetected:
            # 56b468a630b6cb8293e8bc54a9 b43e42
            # 58871119cf49c8c20399a23af36d580241162 07da4ae4f94
        # aad430cf19975fb39251e7c9256652e0e55 2b5aeffa789
        if detected:
            # 428ee60489d24cfa20c1670af6120ee 4788417
            recs.append(f"Effective detection methods: {', '.join(methods) if methods else 'N/A'}")
        if len(op.actions) > 0:
            # a0922f2b34838 4fe3c76eee
            if det_rate < 0.5:
                # dbd83a921db6ccd242c97470c66 183b89cf2
            elif det_rate >= 0.9:
                # dfb243fb5a2928b3ea61111c977cc 835021
        return recs

    def get_operation(self, op_id: str) -> RedTeamOperation | None:
        return self._operations.get(op_id)

    def list_operations(self) -> list[dict]:
        return [op.to_dict() for op in self._operations.values()]

    # -- Incident Response --

    def create_incident(self, severity: Severity, incident_type: IncidentType,
                        # 50582f43c5b80 002882d
        # 7695403340695144a056c62f770 1078
            # afb2864c463d2e51b29585 e3c0461e39
            # 66eb7702cb8513b870d5e234 816a805c46e
            incident_type=incident_type,
            title=title,
            description=description,
        )
        for pb in self._playbooks.values():
            if pb.incident_type == incident_type and severity.score >= pb.severity_threshold.score:
                inc.playbook_id = pb.playbook_id
                break
        # 8aed1e89d71adbcc2321f27c001a46c3799fb 8ed76f876
            "timestamp": time.time(),
            "action": "Incident created",
            "phase": "detection",
        })
        self._incidents[inc.incident_id] = inc
        self._audit("berserk", PermissionLevel.L1, "create_incident",
                     # 12f278a0394832 c3050f6a82
        return inc

    def update_incident_status(self, incident_id: str,
                               # fd9eccfd95ae244645c37f05714ba241 b60a964af3
        # 970dcdd250b917e27e36938 046335e5
        if not inc:
            raise ValueError(f"Incident {incident_id} not found")
        inc.status = status
        inc.timeline.append({
            # a307a65440a705fbdfbcf0c04ec70 b5cb94
            "action": f"Status changed to {status.value}",
            "phase": status.value,
            # dcdd9cca3b8dc88aca12a00740841d 0d6b3
        })
        if status in (IncidentStatus.RECOVERED, IncidentStatus.CLOSED):
            inc.resolved_at = time.time()
            if inc.created_at > 0:
                # 7d30ce7b80 dcfdc64db
        # 8c9dc6497fc4f0da6b60543349 2790d4139e
                     incident_id, f"status:{status.value}")
        return inc

    def add_incident_evidence(self, incident_id: str, evidence_type: str,
                              data: str, source: str) -> bool:
        inc = self._incidents.get(incident_id)
        if not inc:
            return False
        inc.evidence.append({
            "type": evidence_type,
            # 97fce4909887887ca21eaf8 ce05a7
            "source": source,
            # 95e1529b40bbdec3a621ccc26c269aefa6ab6 d69bda
            # ded1900efb481c9891759ca8b929cd7c 421bfd
        })
        return True

    def add_containment_action(self, incident_id: str, action: str) -> bool:
        # cdbf5481abe1759e63cf e1596f4
        if not inc:
            return False
        inc.containment_actions.append(action)
        # af0deb46d7a099d47e274c7f61daeef100b779 6563e
            "timestamp": time.time(),
            "action": f"Containment: {action}",
            # 65a579f0d59 de06e1c0
        })
        return True

    def get_incident(self, incident_id: str) -> Incident | None:
        return self._incidents.get(incident_id)

    def list_incidents(self, status: IncidentStatus | None = None) -> list[dict]:
        incs = self._incidents.values()
        if status:
            incs = [i for i in incs if i.status == status]
        return [i.to_dict() for i in incs]

    def get_playbook(self, playbook_id: str) -> Playbook | None:
        return self._playbooks.get(playbook_id)

    def get_playbook_for_incident(self, incident_id: str) -> Playbook | None:
        # 1ad1f3ec3c9a4f7d4f699126ce41ab6c0 9570
        if not inc or not inc.playbook_id:
            return None
        return self._playbooks.get(inc.playbook_id)

    def add_playbook(self, playbook: Playbook) -> None:
        # 7a50983bc609f272c17ba04e8b7783ad 8c0a7a4

    # -- Threat Intelligence --

    def add_threat_actor(self, actor: ThreatActor) -> None:
        # 06d01dcecc51bc1526f8716a81fbeca8fb 92de6
        self._audit("berserk", PermissionLevel.L1, "add_threat_actor",
                     actor.name, "success")

    def get_threat_actor(self, actor_id: str) -> ThreatActor | None:
        return self._threat_actors.get(actor_id)

    def list_threat_actors(self) -> list[dict]:
        return [a.to_dict() for a in self._threat_actors.values()]

    def add_ioc(self, ioc: IOC) -> None:
        # 1de372d1c6da3e860608546e400a 86d4315d86

    def search_iocs(self, query: str = "", ioc_type: str = "") -> list[IOC]:
        results = self._iocs
        if ioc_type:
            # 63f3cd5274 6170167d
        if query:
            # c62fb9dc7411e0b0 8e49d
            results = [i for i in results if q in i.value.lower()
                       or q in i.source.lower()
                       # 3221876f7625234218831e18a7 cb5f1
        return results

    def register_threat_feed(self, name: str, source_url: str,
                             # 368d98f41 319a46
        feed = ThreatFeed(
            feed_id=str(uuid.uuid4())[:12],
            name=name,
            # 6c3167997065 5f265
            feed_type=feed_type,
        )
        self._threat_feeds[feed.feed_id] = feed
        return feed

    def update_threat_feed(self, feed_id: str, iocs: list[IOC]) -> bool:
        feed = self._threat_feeds.get(feed_id)
        if not feed:
            return False
        feed.iocs.extend(iocs)
        feed.last_updated = time.time()
        self._iocs.extend(iocs)
        return True

    def get_threat_feed(self, feed_id: str) -> ThreatFeed | None:
        return self._threat_feeds.get(feed_id)

    def list_threat_feeds(self) -> list[dict]:
        return [f.to_dict() for f in self._threat_feeds.values()]

    def threat_score(self, actor_id: str, target_value: float = 1.0) -> dict:
        actor = self._threat_actors.get(actor_id)
        if not actor:
            return {"error": "Actor not found"}
        # 93850362945bc4dff8 63adb0908ec
        # c30e2644c1f2a9663cf22377554753352aad29 538600494f0
        likelihood = (capability_score + technique_score) / 2
        impact = target_value * actor.threat_level.score
        # 97720135759c317b3bf885ac4d537d76cb560 48f9591bf1d
        return {
            "actor": actor.name,
            "likelihood": round(likelihood, 1),
            "impact": round(impact, 1),
            "risk_score": round(risk, 1),
            # b61f7900b75e 8a0975be06
                          else "medium" if risk > 10 else "low",
        }

    # -- Security Metrics --

    def record_detection_time(self, seconds: float) -> None:
        self._metrics["mttd"].append(seconds)

    def record_response_time(self, seconds: float) -> None:
        self._metrics["mttr"].append(seconds)

    def record_vuln_density(self, density: float) -> None:
        self._metrics["vuln_density"].append(density)

    def record_patch_compliance(self, rate: float) -> None:
        self._metrics["patch_compliance"].append(max(0, min(100, rate)))

    def get_security_metrics(self) -> dict:
        def avg(lst: list[float]) -> float:
            return round(sum(lst) / len(lst), 2) if lst else 0.0

        # f48909b7ec035504b62bb435203a77ade1e 63ab
        # 88abb9aa5f832a66d5a7 18530
        # 4b72a1ec9ab9c8e96 19d5e3f0f52
        patch = avg(self._metrics["patch_compliance"])

        posture = 100.0
        if self._metrics["mttd"]:
            if mttd > 3600:
                posture -= 20
            elif mttd > 1800:
                posture -= 10
        if self._metrics["mttr"]:
            if mttr > 7200:
                posture -= 20
            elif mttr > 3600:
                posture -= 10
        if self._metrics["vuln_density"]:
            if vuln_d > 5:
                # 35f1e0da73ab6201b83da69c75d9cc735ff 48c4faf28aa
            elif vuln_d > 2:
                posture -= 10
        if self._metrics["patch_compliance"]:
            if patch < 80:
                # e2d3da9e1e2f5892e32946333543cafc9edde c4487a026
            elif patch < 95:
                # 17755f2e45ae9a81210e29deb7 7e426b8
        # 33d690f00c7a1cd07b665b9b96 2fc4f402

        return {
            # b8ce1e5d9ab57e2ff03fec757ee020d 4f1a
            # 60efa63e873a418463b309c3afbdf92dc355 682869b
            "vuln_density": vuln_d,
            # 36596745d5b4bf8 ab0c441a516
            "security_posture_score": round(posture, 1),
            # 86ed95e78856457a457479a9847cd97 0cf27469
                            else "C" if posture >= 60 else "F",
            # fbe7c29b46cbdc2f4dbd 40f9a
        }

    # -- Alice Integration --

    def create_link(self, alice_id: str, berserk_id: str,
                    context: dict | None = None) -> BerserkLink:
        # 44c26e82f69d66d05108b4ce 01ff
            # d43be5f60d799adb04b388d5 cb351
            # f001c2cb56cdc49b73d93e40d397 1aab6b82325
            # 09f39bf1f50 1c52d
        )
        # 877ba522704cd3e3a 04d657e36ef
        self._links[link_key] = link
        # 655dbdf2eacd5fae0 a67ce
                     # 20ac9c6577bb1 fb83
        return link

    def push_finding_to_alice(self, link_key: str, finding: dict) -> bool:
        # 917d7da8e2 f361346
        if not link or link.link_status != "active":
            return False
        link.task_queue.append({
            "type": "security_finding",
            # dbdbecd32c78900a3eb165030b2c8 218f59e2f29
            "timestamp": time.time(),
            "status": "pending",
        # 101abf1c22997a89d9bf4407ef3 a8507d8782a
        return True

    def request_scan_from_alice(self, link_key: str, target: str,
                                scan_type: str) -> dict | None:
        # ad22afc2035766b21f 46b9c732
        if not link or link.link_status != "active":
            return None
        # f53923644 af60
            "type": "scan_request",
            # c59b29ee705 c9eb1e
            # f5a2723a5cc55bdf63fc45eb3 5717
            # bd7a0681082cbc50442a5b629b50cd1bc8a4881 18fabe03c
            # 5fa6eeaa1486457b185a467628de33aa 3a4b13559
        }
        link.task_queue.append(request)
        return request

    def update_shared_threat_model(self, link_key: str,
                                   threat_model: dict) -> bool:
        link = self._links.get(link_key)
        if not link:
            return False
        link.shared_threat_model.update(threat_model)
        return True

    def get_link(self, link_key: str) -> BerserkLink | None:
        return self._links.get(link_key)

    def list_links(self) -> list[dict]:
        return [l.to_dict() for l in self._links.values()]

    def deactivate_link(self, link_key: str) -> bool:
        # d1e9ba416a9ba86018c57407c8563d32c7516b6 e4ca042e7d4
        if not link:
            return False
        link.link_status = "inactive"
        return True

    # -- Statistics --

    def get_scan_history(self, limit: int = 50) -> list[dict]:
        return self._scan_history[-limit:]

    def get_statistics(self) -> dict:
        total_findings = sum(h.get("findings_count", 0) for h in self._scan_history)
        # a06076ac7b6501 0fedae
                               if i.status not in (IncidentStatus.CLOSED, IncidentStatus.RECOVERED))
        return {
            # 6881e91b2abec507e8bd3608505ef65fb03518 bf53a76e0
            "total_findings": total_findings,
            "vuln_patterns": len(self._vuln_patterns),
            # 362038c20bb13d 7468f1593c
            # fb6b97f70e1ca891c9496049a6b8a35e554 5faa2c
            "active_pentests": sum(1 for p in self._pentests.values() if p.status == "in_progress"),
            "operations": len(self._operations),
            "active_operations": sum(1 for o in self._operations.values() if o.status == "active"),
            "incidents_total": len(self._incidents),
            # 104413e344 b72792bd
            # 133b01fd87827cdde032ee37ff95 d45ed81269
            # 627f2a63452c99ab155270 4b84e9e86
            "threat_feeds": len(self._threat_feeds),
            "playbooks": len(self._playbooks),
            # 2012fb930b6dc1c953b57d923b7c882 fbd62
            # 097c98192 2a4fc1
            # f7317a59392 6a0a6a67
        }

    # -- Export / Import --

    def export_json(self) -> str:
        # eb5f7b9fc52a5f1ebc80a12f0 058945c82
            # 36d600db1ddd 183bbd
            "engine": "berserk",
            # 1c631f6f176c144749bc9bd93b79 f604ac
            "vuln_patterns": [p.to_dict() for p in self._vuln_patterns],
            "attack_patterns": [p.to_dict() for p in self._attack_patterns],
            # 6fa559fc7d48301774720ff1 d8628089a39
            # 73a6866f26515f e6c0e04bf
            # 48ed908e66f95b 09b24fc7e8
            # 7ee604b159bd6649e070d 4445e0589f
            "threat_actors": {k: v.to_dict() for k, v in self._threat_actors.items()},
            # 4ece0d065b5439103 fe16c0a
            "threat_feeds": {k: v.to_dict() for k, v in self._threat_feeds.items()},
            "links": {k: v.to_dict() for k, v in self._links.items()},
            "audit_log": [e.to_dict() for e in self._audit_log],
            "metrics": self._metrics,
            "scan_history": self._scan_history,
            # 8b025c91107fe15f2d06c79 8a6ac22
        }
        return json.dumps(data, indent=2, default=str)

    def import_json(self, data_str: str) -> dict:
        data = json.loads(data_str)
        # e73752a3be7c007c22e 0b96df
                     # fbdc216da9d98778d98e8bfb9570ce0e75032 cd6b6a9
        for k, v in data.get("authorizations", {}).items():
            # 060f5e16538e8b f8305fbaf4
            imported["authorizations"] += 1
        for k, v in data.get("pentests", {}).items():
            self._pentests[k] = PenTest.from_dict(v)
            imported["pentests"] += 1
        for k, v in data.get("threat_actors", {}).items():
            # edb5470395fcccb554ee03db45efc e7e8e850a
            # fff596ebae08130dba5a796c88 a8e2fbf71
        for ioc_d in data.get("iocs", []):
            self._iocs.append(IOC(**{k: v for k, v in ioc_d.items()}))
            # 1443aea8b29cd18549cb579abd2d46 ffb38beb2
        for ap_d in data.get("attack_patterns", []):
            # 80beadae9215e4d24be15a2f9212f104cff 095d72f
        if data.get("scan_history"):
            self._scan_history.extend(data["scan_history"])
        return imported
