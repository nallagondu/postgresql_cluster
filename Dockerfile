FROM debian:bookworm-slim
LABEL maintainer="Vitaliy Kukharik vitabaks@gmail.com"

USER root

# Copy postgresql_cluster repository
COPY . /postgresql_cluster

# Install required packages, Python dependencies, Ansible requirements, and perform cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/partial \
    && apt-get update -o Acquire::CompressionTypes::Order::=gz \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
       ca-certificates gnupg git python3 python3-dev python3-pip keychain ssh-client sshpass gcc g++ cmake make libssl-dev \
    && pip3 install --break-system-packages --no-cache-dir -r \
      /postgresql_cluster/requirements.txt \
    && ansible-galaxy install --force -r \
       /postgresql_cluster/requirements.yml \
    && ansible-galaxy install --force -r \
       /postgresql_cluster/roles/consul/requirements.yml \
    && ansible-galaxy collection list \
    && pip3 install --break-system-packages --no-cache-dir -r \
       /root/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt \
    && apt-get autoremove -y --purge gnupg git python3-dev gcc g++ cmake make libssl-dev \
    && apt-get clean -y autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && chmod +x /postgresql_cluster/entrypoint.sh

# Set environment variable for Ansible collections paths
ENV ANSIBLE_COLLECTIONS_PATH=/root/.ansible/collections/ansible_collections:/usr/local/lib/python3.11/dist-packages/ansible_collections
ENV USER=root

WORKDIR /postgresql_cluster

ENTRYPOINT ["./entrypoint.sh"]
