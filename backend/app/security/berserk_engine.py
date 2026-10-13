"""
BERSERK â€” Cybersecurity red-team simulation engine.

Authorized penetration testing and vulnerability scanning for YOUR OWN systems only.
Every operation requires valid authorization. No external targeting.
All operations logged in immutable audit trail.

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
    CRITICAL = "critical"

    @property
    def score(self) -> int:
        return {"info": 0, "low": 1, "medium": 3, "high": 7, "critical": 10}[self.value]


class PatternType(Enum):
    INJECTION = "injection"
    XSS = "xss"
    AUTH_BYPASS = "auth_bypass"
    INFO_LEAK = "info_leak"
    RACE_CONDITION = "race_condition"
    CRYPTO_WEAKNESS = "crypto_weakness"
    CONFIG_ERROR = "config_error"


class PenTestPhase(Enum):
    RECON = "recon"
    SCANNING = "scanning"
    EXPLOITATION = "exploitation"
    POST_EXPLOITATION = "post_exploitation"
    REPORTING = "reporting"


class AttackCategory(Enum):
    WEB = "web"
    NETWORK = "network"
    SOCIAL = "social"
    PHYSICAL = "physical"
    SUPPLY_CHAIN = "supply_chain"
    INSIDER = "insider"


class IncidentStatus(Enum):
    OPEN = "open"
    INVESTIGATING = "investigating"
    CONTAINED = "contained"
    ERADICATED = "eradicated"
    RECOVERED = "recovered"
    CLOSED = "closed"


class IncidentType(Enum):
    MALWARE = "malware"
    PHISHING = "phishing"
    DATA_BREACH = "data_breach"
    DOS = "dos"
    UNAUTHORIZED_ACCESS = "unauthorized_access"
    INSIDER_THREAT = "insider_threat"
    RANSOMWARE = "ransomware"
    SUPPLY_CHAIN = "supply_chain"


class PermissionLevel(Enum):
    L0 = 0  # V â€” full access
    L1 = 1  # Alice/BERSERK â€” authorized scans
    L2 = 2  # Agents â€” execute only
    L3 = 3  # Guests â€” read only


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class VulnPattern:
    name: str
    severity: Severity
    pattern_type: PatternType
    description: str
    cwe_id: str
    regex: str = ""

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "severity": self.severity.value,
            "pattern_type": self.pattern_type.value,
            "description": self.description,
            "cwe_id": self.cwe_id,
            "regex": self.regex,
        }

    @classmethod
    def from_dict(cls, d: dict) -> VulnPattern:
        return cls(
            name=d["name"],
            severity=Severity(d["severity"]),
            pattern_type=PatternType(d["pattern_type"]),
            description=d["description"],
            cwe_id=d["cwe_id"],
            regex=d.get("regex", ""),
        )


@dataclass
class ScanFinding:
    pattern: VulnPattern
    line_number: int
    line_content: str
    module_name: str = ""
    remediation: str = ""

    def to_dict(self) -> dict:
        return {
            "pattern": self.pattern.to_dict(),
            "line_number": self.line_number,
            "line_content": self.line_content,
            "module_name": self.module_name,
            "remediation": self.remediation,
        }


@dataclass
class ConfigFinding:
    issue: str
    severity: Severity
    key: str
    value: Any
    remediation: str

    def to_dict(self) -> dict:
        return {
            "issue": self.issue,
            "severity": self.severity.value,
            "key": self.key,
            "value": str(self.value),
            "remediation": self.remediation,
        }


@dataclass
class Authorization:
    auth_id: str
    granted_by: str
    permission_level: PermissionLevel
    scope: list[str]
    target_systems: list[str]
    valid_from: float
    valid_until: float
    constraints: dict = field(default_factory=dict)

    def is_valid(self, ts: float | None = None) -> bool:
        ts = ts or time.time()
        return self.valid_from <= ts <= self.valid_until

    def covers_target(self, target: str) -> bool:
        return target in self.target_systems or "*" in self.target_systems

    def to_dict(self) -> dict:
        return {
            "auth_id": self.auth_id,
            "granted_by": self.granted_by,
            "permission_level": self.permission_level.value,
            "scope": self.scope,
            "target_systems": self.target_systems,
            "valid_from": self.valid_from,
            "valid_until": self.valid_until,
            "constraints": self.constraints,
        }

    @classmethod
    def from_dict(cls, d: dict) -> Authorization:
        return cls(
            auth_id=d["auth_id"],
            granted_by=d["granted_by"],
            permission_level=PermissionLevel(d["permission_level"]),
            scope=d["scope"],
            target_systems=d["target_systems"],
            valid_from=d["valid_from"],
            valid_until=d["valid_until"],
            constraints=d.get("constraints", {}),
        )


@dataclass
class PenTestFinding:
    title: str
    severity: Severity
    phase: PenTestPhase
    evidence: str
    remediation: str
    cwe_id: str = ""
    verified: bool = False

    def to_dict(self) -> dict:
        return {
            "title": self.title,
            "severity": self.severity.value,
            "phase": self.phase.value,
            "evidence": self.evidence,
            "remediation": self.remediation,
            "cwe_id": self.cwe_id,
            "verified": self.verified,
        }


@dataclass
class PenTest:
    name: str
    target_system: str
    scope: list[str]
    authorization_id: str
    test_id: str = field(default_factory=lambda: str(uuid.uuid4())[:12])
    phase: PenTestPhase = PenTestPhase.RECON
    findings: list[PenTestFinding] = field(default_factory=list)
    timeline: list[dict] = field(default_factory=list)
    status: str = "pending"
    created_at: float = field(default_factory=time.time)

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "target_system": self.target_system,
            "scope": self.scope,
            "authorization_id": self.authorization_id,
            "test_id": self.test_id,
            "phase": self.phase.value,
            "findings": [f.to_dict() for f in self.findings],
            "timeline": self.timeline,
            "status": self.status,
            "created_at": self.created_at,
        }

    @classmethod
    def from_dict(cls, d: dict) -> PenTest:
        pt = cls(
            name=d["name"],
            target_system=d["target_system"],
            scope=d["scope"],
            authorization_id=d["authorization_id"],
            test_id=d.get("test_id", str(uuid.uuid4())[:12]),
            phase=PenTestPhase(d.get("phase", "recon")),
            status=d.get("status", "pending"),
            created_at=d.get("created_at", time.time()),
        )
        pt.findings = [
            PenTestFinding(
                title=f["title"],
                severity=Severity(f["severity"]),
                phase=PenTestPhase(f["phase"]),
                evidence=f["evidence"],
                remediation=f["remediation"],
                cwe_id=f.get("cwe_id", ""),
                verified=f.get("verified", False),
            )
            for f in d.get("findings", [])
        ]
        pt.timeline = d.get("timeline", [])
        return pt


@dataclass
class AttackPattern:
    name: str
    category: AttackCategory
    technique: str
    mitre_id: str
    countermeasure: str
    description: str = ""
    severity: Severity = Severity.MEDIUM

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "category": self.category.value,
            "technique": self.technique,
            "mitre_id": self.mitre_id,
            "countermeasure": self.countermeasure,
            "description": self.description,
            "severity": self.severity.value,
        }

    @classmethod
    def from_dict(cls, d: dict) -> AttackPattern:
        return cls(
            name=d["name"],
            category=AttackCategory(d["category"]),
            technique=d["technique"],
            mitre_id=d["mitre_id"],
            countermeasure=d["countermeasure"],
            description=d.get("description", ""),
            severity=Severity(d.get("severity", "medium")),
        )


@dataclass
class RedTeamAction:
    timestamp: float
    action: str
    target: str
    result: str
    detected: bool = False
    detection_method: str = ""

    def to_dict(self) -> dict:
        return {
            "timestamp": self.timestamp,
            "action": self.action,
            "target": self.target,
            "result": self.result,
            "detected": self.detected,
            "detection_method": self.detection_method,
        }


@dataclass
class RedTeamOperation:
    name: str
    objective: str
    team: list[str]
    rules_of_engagement: dict
    operation_id: str = field(default_factory=lambda: str(uuid.uuid4())[:12])
    authorization_id: str = ""
    actions: list[RedTeamAction] = field(default_factory=list)
    status: str = "planning"
    created_at: float = field(default_factory=time.time)
    report: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "objective": self.objective,
            "team": self.team,
            "rules_of_engagement": self.rules_of_engagement,
            "operation_id": self.operation_id,
            "authorization_id": self.authorization_id,
            "actions": [a.to_dict() for a in self.actions],
            "status": self.status,
            "created_at": self.created_at,
            "report": self.report,
        }


@dataclass
class Incident:
    incident_id: str
    severity: Severity
    incident_type: IncidentType
    title: str
    description: str
    status: IncidentStatus = IncidentStatus.OPEN
    timeline: list[dict] = field(default_factory=list)
    evidence: list[dict] = field(default_factory=list)
    containment_actions: list[str] = field(default_factory=list)
    created_at: float = field(default_factory=time.time)
    resolved_at: float = 0.0
    playbook_id: str = ""

    def to_dict(self) -> dict:
        return {
            "incident_id": self.incident_id,
            "severity": self.severity.value,
            "incident_type": self.incident_type.value,
            "title": self.title,
            "description": self.description,
            "status": self.status.value,
            "timeline": self.timeline,
            "evidence": self.evidence,
            "containment_actions": self.containment_actions,
            "created_at": self.created_at,
            "resolved_at": self.resolved_at,
            "playbook_id": self.playbook_id,
        }


@dataclass
class Playbook:
    playbook_id: str
    name: str
    incident_type: IncidentType
    steps: list[dict]
    severity_threshold: Severity = Severity.LOW

    def to_dict(self) -> dict:
        return {
            "playbook_id": self.playbook_id,
            "name": self.name,
            "incident_type": self.incident_type.value,
            "steps": self.steps,
            "severity_threshold": self.severity_threshold.value,
        }


@dataclass
class ThreatActor:
    name: str
    motivation: str
    capabilities: list[str]
    known_techniques: list[str]
    threat_level: Severity = Severity.MEDIUM
    actor_id: str = field(default_factory=lambda: str(uuid.uuid4())[:12])

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "motivation": self.motivation,
            "capabilities": self.capabilities,
            "known_techniques": self.known_techniques,
            "threat_level": self.threat_level.value,
            "actor_id": self.actor_id,
        }

    @classmethod
    def from_dict(cls, d: dict) -> ThreatActor:
        return cls(
            name=d["name"],
            motivation=d["motivation"],
            capabilities=d["capabilities"],
            known_techniques=d["known_techniques"],
            threat_level=Severity(d.get("threat_level", "medium")),
            actor_id=d.get("actor_id", str(uuid.uuid4())[:12]),
        )


@dataclass
class IOC:
    ioc_type: str  # hash, ip, domain, url, email
    value: str
    source: str
    confidence: float = 0.5
    first_seen: float = field(default_factory=time.time)
    tags: list[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            "ioc_type": self.ioc_type,
            "value": self.value,
            "source": self.source,
            "confidence": self.confidence,
            "first_seen": self.first_seen,
            "tags": self.tags,
        }


@dataclass
class ThreatFeed:
    feed_id: str
    name: str
    source_url: str
    feed_type: str
    iocs: list[IOC] = field(default_factory=list)
    last_updated: float = 0.0

    def to_dict(self) -> dict:
        return {
            "feed_id": self.feed_id,
            "name": self.name,
            "source_url": self.source_url,
            "feed_type": self.feed_type,
            "iocs": [i.to_dict() for i in self.iocs],
            "last_updated": self.last_updated,
        }


@dataclass
class BerserkLink:
    alice_id: str
    berserk_id: str
    shared_context: dict = field(default_factory=dict)
    task_queue: list[dict] = field(default_factory=list)
    shared_threat_model: dict = field(default_factory=dict)
    link_status: str = "active"

    def to_dict(self) -> dict:
        return {
            "alice_id": self.alice_id,
            "berserk_id": self.berserk_id,
            "shared_context": self.shared_context,
            "task_queue": self.task_queue,
            "shared_threat_model": self.shared_threat_model,
            "link_status": self.link_status,
        }


@dataclass
class AuditEntry:
    timestamp: float
    actor: str
    permission_level: PermissionLevel
    action: str
    target: str
    result: str
    details: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "timestamp": self.timestamp,
            "actor": self.actor,
            "permission_level": self.permission_level.value,
            "action": self.action,
            "target": self.target,
            "result": self.result,
            "details": self.details,
        }


# ---------------------------------------------------------------------------
# Default vulnerability patterns
# ---------------------------------------------------------------------------

DEFAULT_VULN_PATTERNS: list[VulnPattern] = [
    VulnPattern(
        "SQL Injection", Severity.CRITICAL, PatternType.INJECTION,
        "Possible SQL injection via string concatenation",
        "CWE-89",
        r"""(?:execute|cursor\.execute|query)\s*\(\s*(?:f[\"']|[\"'].*%s|[\"'].*\+\s*\w+|[\"'].*\.format)""",
    ),
    VulnPattern(
        "Command Injection", Severity.CRITICAL, PatternType.INJECTION,
        "Possible OS command injection",
        "CWE-78",
        r"""(?:os\.system|os\.popen|subprocess\.call|subprocess\.run|subprocess\.Popen)\s*\(\s*(?:f[\"']|[\"'].*\+|[\"'].*%|[\"'].*\.format)""",
    ),
    VulnPattern(
        "XSS via innerHTML", Severity.HIGH, PatternType.XSS,
        "Direct innerHTML assignment may enable XSS",
        "CWE-79",
        r"""\.innerHTML\s*=\s*(?!['"]<)""",
    ),
    VulnPattern(
        "Hardcoded Secret", Severity.HIGH, PatternType.INFO_LEAK,
        "Possible hardcoded secret or API key",
        "CWE-798",
        r"""(?:password|secret|api_key|apikey|token|private_key)\s*=\s*['\"][^'\"]{8,}['\"]""",
    ),
    VulnPattern(
        "Weak Hash", Severity.MEDIUM, PatternType.CRYPTO_WEAKNESS,
        "Use of weak hash algorithm (MD5/SHA1) for security",
        "CWE-328",
        r"""(?:hashlib\.md5|hashlib\.sha1|MD5|SHA1)\s*\(""",
    ),
    VulnPattern(
        "Debug Mode", Severity.MEDIUM, PatternType.CONFIG_ERROR,
        "Debug mode enabled in production config",
        "CWE-489",
        r"""(?:DEBUG\s*=\s*True|debug\s*=\s*True|app\.debug\s*=\s*True)""",
    ),
    VulnPattern(
        "CORS Wildcard", Severity.MEDIUM, PatternType.CONFIG_ERROR,
        "CORS allows all origins",
        "CWE-942",
        r"""(?:Access-Control-Allow-Origin.*\*|CORS_ORIGINS.*\*|allow_origins.*\*)""",
    ),
    VulnPattern(
        "Eval Usage", Severity.HIGH, PatternType.INJECTION,
        "Use of eval() can execute arbitrary code",
        "CWE-95",
        r"""(?<!\w)eval\s*\(""",
    ),
    VulnPattern(
        "Pickle Deserialization", Severity.HIGH, PatternType.INJECTION,
        "Pickle deserialization of untrusted data",
        "CWE-502",
        r"""pickle\.loads?\s*\(""",
    ),
    VulnPattern(
        "Insecure Random", Severity.LOW, PatternType.CRYPTO_WEAKNESS,
        "Use of random module for security-sensitive operations",
        "CWE-330",
        r"""(?:random\.random|random\.randint|random\.choice)\s*\(""",
    ),
    VulnPattern(
        "Open Redirect", Severity.MEDIUM, PatternType.AUTH_BYPASS,
        "Possible open redirect vulnerability",
        "CWE-601",
        r"""redirect\s*\(\s*(?:request\.|user_input|url_param)""",
    ),
    VulnPattern(
        "Missing Auth Check", Severity.HIGH, PatternType.AUTH_BYPASS,
        "Route handler without authentication decorator",
        "CWE-862",
        r"""@(?:app|router)\.(?:get|post|put|delete|patch)\s*\([^)]*\)\s*\n(?:(?!@(?:login_required|auth|require|permission)).)""",
    ),
    VulnPattern(
        "Race Condition TOCTOU", Severity.MEDIUM, PatternType.RACE_CONDITION,
        "Time-of-check to time-of-use race condition",
        "CWE-367",
        r"""(?:os\.path\.exists|os\.access)\s*\([^)]+\)[\s\S]{0,100}(?:open|os\.remove|os\.rename)\s*\(""",
    ),
]


DEFAULT_ATTACK_PATTERNS: list[AttackPattern] = [
    AttackPattern(
        "SQL Injection", AttackCategory.WEB,
        "Inject malicious SQL via user inputs",
        "T1190", "Use parameterized queries and input validation",
        "Exploits unsanitized user input in SQL queries",
        Severity.CRITICAL,
    ),
    AttackPattern(
        "Cross-Site Scripting", AttackCategory.WEB,
        "Inject client-side scripts via web inputs",
        "T1059.007", "Content Security Policy, output encoding, input validation",
        "Injects malicious scripts that execute in victim browser",
        Severity.HIGH,
    ),
    AttackPattern(
        "Brute Force", AttackCategory.WEB,
        "Systematically try all possible credentials",
        "T1110", "Rate limiting, account lockout, MFA",
        "Automated credential guessing against authentication endpoints",
        Severity.MEDIUM,
    ),
    AttackPattern(
        "Phishing", AttackCategory.SOCIAL,
        "Deceptive communications to steal credentials",
        "T1566", "Security awareness training, email filtering, MFA",
        "Social engineering via fraudulent emails or messages",
        Severity.HIGH,
    ),
    AttackPattern(
        "Supply Chain Compromise", AttackCategory.SUPPLY_CHAIN,
        "Compromise through trusted third-party software",
        "T1195", "Dependency pinning, hash verification, vendoring",
        "Attacking through upstream dependencies or tools",
        Severity.CRITICAL,
    ),
    AttackPattern(
        "Insider Threat", AttackCategory.INSIDER,
        "Malicious actions by authorized users",
        "T1078", "Least privilege, monitoring, separation of duties",
        "Exploitation of legitimate access for unauthorized purposes",
        Severity.HIGH,
    ),
    AttackPattern(
        "Network Sniffing", AttackCategory.NETWORK,
        "Capture network traffic to extract data",
        "T1040", "TLS everywhere, network segmentation, VPN",
        "Passive interception of unencrypted network traffic",
        Severity.MEDIUM,
    ),
    AttackPattern(
        "Physical Access", AttackCategory.PHYSICAL,
        "Gain unauthorized physical access to hardware",
        "T1200", "Physical security controls, disk encryption, USB lockdown",
        "Direct hardware access to bypass software controls",
        Severity.HIGH,
    ),
]


DEFAULT_PLAYBOOKS: list[Playbook] = [
    Playbook(
        "PB-001", "Malware Response", IncidentType.MALWARE,
        [
            {"phase": "detection", "action": "Isolate affected system from network"},
            {"phase": "containment", "action": "Block C2 domains and IPs at firewall"},
            {"phase": "eradication", "action": "Remove malware artifacts and persistence"},
            {"phase": "recovery", "action": "Restore from clean backup, patch vulnerability"},
            {"phase": "review", "action": "Update signatures, document lessons learned"},
        ],
        Severity.HIGH,
    ),
    Playbook(
        "PB-002", "Data Breach Response", IncidentType.DATA_BREACH,
        [
            {"phase": "detection", "action": "Determine scope of data exposure"},
            {"phase": "containment", "action": "Revoke compromised credentials, close access"},
            {"phase": "eradication", "action": "Patch exploitation vector"},
            {"phase": "recovery", "action": "Rotate all affected secrets, notify stakeholders"},
            {"phase": "review", "action": "Regulatory notification, post-incident review"},
        ],
        Severity.CRITICAL,
    ),
    Playbook(
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

CONFIG_CHECKS: list[dict] = [
    {"key": "debug", "bad_values": [True, "true", "1", "yes"],
     "severity": Severity.HIGH, "issue": "Debug mode enabled",
     "remediation": "Set debug=False in production"},
    {"key": "secret_key", "min_length": 32,
     "severity": Severity.CRITICAL, "issue": "Secret key too short",
     "remediation": "Use a randomly generated key of at least 32 characters"},
    {"key": "allowed_hosts", "bad_values": [["*"], "*"],
     "severity": Severity.MEDIUM, "issue": "Allowed hosts too permissive",
     "remediation": "Restrict allowed_hosts to specific domains"},
    {"key": "ssl_redirect", "bad_values": [False, "false", "0", "no"],
     "severity": Severity.MEDIUM, "issue": "SSL redirect disabled",
     "remediation": "Enable SSL redirect in production"},
    {"key": "session_cookie_secure", "bad_values": [False, "false"],
     "severity": Severity.MEDIUM, "issue": "Session cookie not secure",
     "remediation": "Set session_cookie_secure=True"},
    {"key": "csrf_enabled", "bad_values": [False, "false", "0"],
     "severity": Severity.HIGH, "issue": "CSRF protection disabled",
     "remediation": "Enable CSRF protection"},
    {"key": "password_min_length", "max_bad": 7,
     "severity": Severity.MEDIUM, "issue": "Minimum password length too short",
     "remediation": "Set minimum password length to at least 12"},
]

SECRET_PATTERNS: list[tuple[str, str]] = [
    (r"""(?:AKIA|ABIA|ACCA|ASIA)[0-9A-Z]{16}""", "AWS Access Key"),
    (r"""ghp_[0-9a-zA-Z]{36}""", "GitHub Personal Access Token"),
    (r"""sk-[0-9a-zA-Z]{32,}""", "API Secret Key"),
    (r"""-----BEGIN (?:RSA |EC |DSA )?PRIVATE KEY-----""", "Private Key"),
    (r"""eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}""", "JWT Token"),
    (r"""xox[bpors]-[0-9a-zA-Z]{10,}""", "Slack Token"),
]


# ---------------------------------------------------------------------------
# BerserkEngine
# ---------------------------------------------------------------------------

class BerserkEngine:
    def __init__(self) -> None:
        self._authorizations: dict[str, Authorization] = {}
        self._vuln_patterns: list[VulnPattern] = list(DEFAULT_VULN_PATTERNS)
        self._attack_patterns: list[AttackPattern] = list(DEFAULT_ATTACK_PATTERNS)
        self._pentests: dict[str, PenTest] = {}
        self._operations: dict[str, RedTeamOperation] = {}
        self._incidents: dict[str, Incident] = {}
        self._playbooks: dict[str, Playbook] = {p.playbook_id: p for p in DEFAULT_PLAYBOOKS}
        self._threat_actors: dict[str, ThreatActor] = {}
        self._iocs: list[IOC] = []
        self._threat_feeds: dict[str, ThreatFeed] = {}
        self._audit_log: list[AuditEntry] = []
        self._links: dict[str, BerserkLink] = {}
        self._metrics: dict[str, list[float]] = {
            "mttd": [],
            "mttr": [],
            "vuln_density": [],
            "patch_compliance": [],
        }
        self._scan_history: list[dict] = []

    # -- Audit --

    def _audit(self, actor: str, level: PermissionLevel, action: str,
               target: str, result: str, details: dict | None = None) -> None:
        self._audit_log.append(AuditEntry(
            timestamp=time.time(), actor=actor, permission_level=level,
            action=action, target=target, result=result,
            details=details or {},
        ))

    def get_audit_log(self, limit: int = 100) -> list[dict]:
        return [e.to_dict() for e in self._audit_log[-limit:]]

    # -- Authorization --

    def create_authorization(self, granted_by: str, level: PermissionLevel,
                             scope: list[str], targets: list[str],
                             valid_hours: float = 24,
                             constraints: dict | None = None) -> Authorization:
        if level.value > PermissionLevel.L0.value:
            raise PermissionError("Only L0 (V) can create authorizations")
        auth = Authorization(
            auth_id=str(uuid.uuid4())[:12],
            granted_by=granted_by,
            permission_level=level,
            scope=scope,
            target_systems=targets,
            valid_from=time.time(),
            valid_until=time.time() + valid_hours * 3600,
            constraints=constraints or {},
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
            self._audit("system", PermissionLevel.L0, "revoke_auth", auth_id, "success")
            return True
        return False

    def _require_auth(self, auth_id: str, target: str, action: str) -> Authorization:
        auth = self._authorizations.get(auth_id)
        if not auth:
            self._audit("unknown", PermissionLevel.L3, action, target, "denied:no_auth")
            raise PermissionError(f"Authorization {auth_id} not found")
        if not auth.is_valid():
            self._audit("unknown", auth.permission_level, action, target, "denied:expired")
            raise PermissionError(f"Authorization {auth_id} expired")
        if not auth.covers_target(target):
            self._audit("unknown", auth.permission_level, action, target, "denied:scope")
            raise PermissionError(f"Authorization does not cover target: {target}")
        for ext in ("external", "internet", "public", "prod"):
            if ext in target.lower() and "allow_" + ext not in auth.constraints:
                self._audit("unknown", auth.permission_level, action, target,
                            f"denied:external_{ext}")
                raise PermissionError(f"Cannot target external/production systems: {target}")
        return auth

    # -- Vulnerability Scanner --

    def add_vuln_pattern(self, pattern: VulnPattern) -> None:
        self._vuln_patterns.append(pattern)

    def get_vuln_patterns(self) -> list[VulnPattern]:
        return list(self._vuln_patterns)

    def scan_module(self, code: str, module_name: str = "unknown") -> list[ScanFinding]:
        findings: list[ScanFinding] = []
        lines = code.split("\n")
        for pattern in self._vuln_patterns:
            if not pattern.regex:
                continue
            try:
                compiled = re.compile(pattern.regex, re.IGNORECASE)
            except re.error:
                continue
            for i, line in enumerate(lines, 1):
                if compiled.search(line):
                    findings.append(ScanFinding(
                        pattern=pattern,
                        line_number=i,
                        line_content=line.strip(),
                        module_name=module_name,
                        remediation=f"Fix {pattern
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  æ×µªšÝßÚ£ïÄ×’<:Ä\Ù?Ó'×ÏÅº˜¤%;Ûª