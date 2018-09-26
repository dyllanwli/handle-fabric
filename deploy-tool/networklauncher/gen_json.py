from __future__ import print_function
import sys
import json
import codecs
import os
import yaml
if sys.version.startswith('2'):
    print(sys.version)
else:
    print(sys.version)

# ======================== #
# user defined parameters
crypto_config_path = 'fabric/common/tools/cryptogen/crypto-config'
artifact_config_pre_path = '/artifacts/'
network_ip = "localhost"


# ======================== #
# parameters below is used for golbal parameters
domain = ""

orderer_name = ""
orderer_id = ""
orderer_server_hostnames = []
orderer_urls = []
# orderer_tls_cacerts = []
# use a single orderer tls cacert instead of a cacert list
orderer_tls_cacert = ""

org_names = []
org_ids = []
org_admin_keys = []
org_admin_certs = []
org_peers = []
peers_ports = {}
cas_ports = {}


# default is adaptived for single orderer
default_orderers = {
    "name": "",
    "mspid": "",
    "url": "grpcs://localhost:$ORDERER_PORT",
    "server-hostname": "",
    "tls_cacerts": ""
}


def load_configtx():
    global orderer_name
    global orderer_id
    with open("configtx.yaml") as yaml_file:
        print("Loading configtx file...")
        configtx = yaml.load(yaml_file)
        for role in configtx:
            if role == "Organizations":
                for items in configtx[role]:
                    if items["Name"].startswith("Orderer"):
                        orderer_name = items["Name"]
                        orderer_id = items["ID"]
                    else:
                        org_names.append(items["Name"])
                        org_ids.append(items["ID"])
            elif role == "Orderer":
                for items in configtx[role]:
                    if items.startswith("Addresses"):
                        for i in configtx[role][items]:
                            orderer_server_hostnames.append(i.split(":")[0])
                            orderer_urls.append(
                                "grpcs://{}:{}".format(network_ip, i.split(":")[1]))
                print("")  # print break line
    return


def load_port(compose, role):
    for component in compose["services"][role]:
        if component == "ports":
            port = compose["services"][role][component]
            port = [x.split(":")[0] for x in port]
    return port


def load_env(compose, role, arg):
    for component in compose["services"][role]["environment"]:
        if component.find(arg) > -1:
            print(component)


def load_docker_compose():
    with open("docker-compose.yml") as dokcer_compose_file:
        print("Loading docker file...")
        docker_compose = yaml.load(dokcer_compose_file)
        for role in docker_compose["services"]:
            if role.startswith("peer"):
                peers_ports[role] = load_port(docker_compose, role)
            elif role.startswith("ca"):
                cas_ports[role] = load_port(docker_compose, role)
                load_env(docker_compose, role, "FABRIC_CA_SERVER_CA_NAME")
        print(peers_ports)
        print(cas_ports)
    print()
    # break line print
    return


def load_orderer_role(path):
    global orderer_tls_cacert
    global domain
    orderer_path = os.path.join(path, "ordererOrganizations")
    print("Loading ordererOrganizations file...")
    for i in os.listdir(orderer_path):
        if i.endswith(".com"):
            domain = i
            domain_path = os.path.join(orderer_path, domain)
            tlsca_path = os.path.join(domain_path, "tlsca")
            tls_pem = [i for i in os.listdir(
                tlsca_path) if i.endswith("pem")][0]
            # get the crypto pem file name from this tlscacert folder
            orderer_tls_cacert = os.path.join(
                tlsca_path, tls_pem).split("cryptogen")[1]
            break
    return


def load_peer_role(org_path, org):
    peer_tls_cacerts = []
    for i in os.listdir(os.path.join(org_path, "peers")):
        print("Loading", i)
        peer_tls_path = os.path.join(
            org_path, "peers", i, "msp/tlscacerts/tlsca.{}.example.com-cert.pem".format(org))
        peer_tls_cacerts.append(peer_tls_path)
    return peer_tls_cacerts


def load_org_role(path):
    peer_path = os.path.join(path, "peerOrganizations")
    print("Loading peerOrganizations file...")
    for i in os.listdir(peer_path):
        org = i.split(".")[0]
        print("Loading org", org)
        org_path = os.path.join(peer_path, i)
        org_admin_keys.append(os.path.join(
            org_path, "users", "Admin@{}".format(i), "msp", "keystore"))
        org_admin_certs.append(os.path.join(
            org_path, "users", "Admin@{}".format(i), "msp", "signcerts"))
        org_peers.append(load_peer_role(org_path, org))
        # load each peer from orgs folder
        # print(org_path)


def write_json(output):
    with codecs.open("network-config.json", "w", 'utf-8') as file:
        file.write(json.dumps(output, ensure_ascii=False))


def load_json():
    with open("template_network_config.json") as file:
        template = json.load(file)
        output = template
        write_json(output)


def __init__():
    args = sys.argv[1:]
    print("Input: ", args)
    load_json()
    load_orderer_role(crypto_config_path)
    load_org_role(crypto_config_path)
    load_configtx()
    load_docker_compose()
    print()
    print("domain", domain)
    print("orderer_tls_cacert", orderer_tls_cacert)
    print("org_names", org_names)
    print("org_ids", org_ids)
    print("orderer_name", orderer_name)
    print("orderer_id", orderer_id)
    print("orderer_urls", orderer_urls)
    print("orderer_server_hostnames", orderer_server_hostnames)
    print()
    print("org_admin_keys", org_admin_keys)
    print("org_admin_certs", org_admin_certs)
    print("org_peers", org_peers)


if __name__ == "__main__":
    __init__()
