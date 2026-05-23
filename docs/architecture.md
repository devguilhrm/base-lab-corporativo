# Arquitetura do Laboratorio

## VMs e funcoes

| VM | Sistema | CPU/RAM | Funcao |
|---|---|---|---|
| vm-zabbix | Ubuntu Server 22.04 | 2 vCPU / 4 GB | Zabbix + Grafana + PostgreSQL |
| vm-dc01 | Windows Server 2022 | 2 vCPU / 4 GB | AD DS + DNS + DHCP |
| vm-fs01 | Windows Server 2022 | 2 vCPU / 2 GB | File Server + DFS |
| vm-linux01 | Ubuntu Server 22.04 | 1 vCPU / 1 GB | Aplicacao monitorada |
| vm-linux02 | Rocky Linux 9 | 1 vCPU / 1 GB | Web server |
| vm-pfsense | pfSense 2.7 | 1 vCPU / 1 GB | Gateway + Firewall + SNMP |

## Topologia de rede

- Rede principal: `192.168.10.0/24`
- VLAN 10 (Linux): `10.10.10.0/24`
- VLAN 20 (Windows): `10.10.20.0/24`
- VLAN 99 (Management): `10.10.99.0/24`
- Gateway e firewall inter-VLAN: `pfSense`

## Servicos monitorados (base)

- Linux: CPU, memoria, disco, servicos, autenticacao SSH
- Windows: AD, DNS, DHCP, EventLog seguranca
- Rede: interfaces, latencia, disponibilidade via SNMP
- Aplicacao: SSL expiry, disponibilidade HTTP, process health

## Enderecamento sugerido

| Host | IP sugerido |
|---|---|
| vm-zabbix | 10.10.10.10 |
| vm-linux01 | 10.10.10.11 |
| vm-linux02 | 10.10.10.12 |
| vm-dc01 | 10.10.20.10 |
| vm-fs01 | 10.10.20.11 |
| vm-pfsense (LAN) | 10.10.99.1 |

## Observacoes de seguranca

- Nunca versionar senhas reais.
- Rotacionar credenciais padrao apos bootstrap.
- Restringir acesso da UI Zabbix/Grafana via ACL/VPN.
- Habilitar NTP consistente para evitar drift em alertas.

