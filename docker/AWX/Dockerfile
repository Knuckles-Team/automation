FROM ubuntu:latest AS awx_dependencies
RUN apt update && apt upgrade -y && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y --no-install-recommends vim nano libssl-dev libffi-dev dos2unix wget curl open-vm-tools-desktop net-tools git python3-pip python3-virtualenv python-is-python3
RUN curl -sSL https://get.docker.com/ | sh
RUN python -m pip install --upgrade pip
RUN python -m pip install --upgrade docker-compose ansible
RUN git clone -b 21.10.2 https://github.com/ansible/awx.git
RUN ansible-playbook -i ./awx/tools/docker-compose/inventory ./awx/tools/docker-compose/ansible/sources.yml \
	    -e awx_image=ghcr.io/ansible/awx_devel \
	    -e awx_image_tag=awx \
	    -e receptor_image=quay.io/ansible/receptor:devel \
	    -e control_plane_node_count=1 \
	    -e execution_node_count=0 \
	    -e minikube_container_group=false \
	    -e enable_keycloak=false \
	    -e enable_ldap=false \
	    -e enable_splunk=false \
	    -e enable_prometheus=false \
	    -e enable_grafana=false
