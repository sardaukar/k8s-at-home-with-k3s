# set your host IP and name
HOST_IP=192.168.1.60
HOST=k3s

#### don't change anything below this line!

KUBECTL=kubectl --kubeconfig ~/.kube/k3s-vm-config

.PHONY: k3s_install base bookstack portainer samba

k3s_install:
	ssh ${HOST} 'export INSTALL_K3S_EXEC=" --no-deploy servicelb --no-deploy traefik --no-deploy local-storage"; \
		curl -sfL https://get.k3s.io | sh -'
	scp ${HOST}:/etc/rancher/k3s/k3s.yaml .
	sed -r 's/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/"${HOST_IP}"/ k3s.yaml > ~/.kube/k3s-vm-config && rm k3s.yaml

base:
	${KUBECTL} apply -f k8s/ingress-nginx-v1.0.4.yml
	${KUBECTL} wait --namespace ingress-nginx \
            --for=condition=ready pod \
            --selector=app.kubernetes.io/component=controller \
            --timeout=60s
	${KUBECTL} apply -f k8s/cert-manager-v1.0.4.yaml
	${KUBECTL} apply -f stacks/default-storage-class.yaml
	@echo
	@echo "waiting for cert-manager pods to be ready... "
	${KUBECTL} wait --namespace=cert-manager --for=condition=ready pod --all --timeout=60s
	${KUBECTL} apply -f k8s/lets-encrypt-staging.yml
	${KUBECTL} apply -f k8s/lets-encrypt-prod.yml

bookstack:
	${KUBECTL} apply -k stacks/bookstack
	@echo
	@echo "waiting for deployments to be ready... "
	@${KUBECTL} wait --namespace=default --for=condition=available deployments/bookstack --timeout=60s
	@${KUBECTL} wait --namespace=default --for=condition=available deployments/bookstack-mysql --timeout=60s
	@echo
	ssh ${HOST} chown 33:33 /zpool/volumes/bookstack/storage-uploads/
	ssh ${HOST} chown 33:33 /zpool/volumes/bookstack/uploads/

portainer:
	${KUBECTL} apply -k stacks/portainer

samba:
	${KUBECTL} apply -k stacks/samba
