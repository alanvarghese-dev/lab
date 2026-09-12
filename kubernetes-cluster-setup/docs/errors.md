ERRORS ENCOUNTERED AND THINGS I LEARNED FROM THIS PROJECT

1. Kubernetes API Server Connection Refused

Error:
The connection to the server 127.0.0.1:<port> was refused.

What happened:
kubectl was trying to connect to the Kubernetes API server through
127.0.0.1, but the Kubernetes cluster was running inside Docker.

What I learned:
localhost inside the DevPod container is not necessarily the same as
localhost on the Docker host. Network namespaces and container
networking need to be considered when troubleshooting Kubernetes.

Solution:
I verified that the Kubernetes API server was running inside the
kind control-plane container and accessed it through the Docker
network instead.


2. Kubernetes API Server Was Actually Healthy

Problem:
kubectl could not connect even though the cluster appeared to be
running.

Investigation:
I checked the control-plane container and verified that the
kube-apiserver process was running and listening on port 6443.

I also tested:

curl -k https://172.26.0.2:6443/healthz

Result:

ok

What I learned:
A kubectl connection failure does not necessarily mean that the
Kubernetes API server is down.

It is important to separate:
- Kubernetes component health
- Network connectivity
- TLS/certificate validation
- kubectl configuration


3. Docker Port Mapping and DevPod Networking

Problem:
The kind cluster published the Kubernetes API server on a dynamically
assigned host port.

Example:

6443/tcp -> 0.0.0.0:<port>

However, connecting to localhost:<port> from inside DevPod failed.

What I learned:
A port published by Docker is exposed on the Docker host. The
localhost inside another container is a different network namespace.

I learned to use host.docker.internal when communication from a
container to the Docker host is required.


4. TLS Certificate Hostname Mismatch

Error:

tls: failed to verify certificate:
x509: certificate is valid for kubernetes,
kubernetes-lab-control-plane,
kubernetes.default,
kubernetes.default.svc,
kubernetes.default.svc.cluster.local,
localhost,
not host.docker.internal

What happened:
The Kubernetes API server certificate did not contain
host.docker.internal as a valid Subject Alternative Name (SAN).

What I learned:
TLS certificates are validated against the hostname being used to
connect to the server.

Even if the server is reachable, kubectl will reject the connection
when the hostname is not included in the certificate SANs.


5. Unsupported kind Configuration Property

Problem:
I initially tried to use:

apiServerCertSANs

in the kind configuration.

Error:
The apiServerCertSANs property was not allowed.

What I learned:
Not every Kubernetes/kind configuration option can be placed directly
inside kind-config.yaml.

For kind, additional kubeadm configuration may need to be supplied
through kubeadmConfigPatches.

I removed the unsupported property instead of keeping an invalid
configuration.


6. Container DNS Resolution Problem

Problem:
The DevPod container could not resolve:

kubernetes-lab-control-plane

Error:
Could not resolve host.

What I learned:
Docker container names and Docker-network DNS are not automatically
available from every container/network namespace.

A container being able to communicate with a Docker network IP does
not necessarily mean that it can resolve the container's Docker
hostname.


7. Using /etc/hosts to Resolve the Control Plane

Solution:
I mapped the kind control-plane IP to the hostname that already
existed in the Kubernetes certificate:

kubernetes-lab-control-plane

This allowed the hostname to resolve to the control-plane IP.

What I learned:
DNS/hosts resolution and TLS certificate validation are separate
problems, but solving both with the same valid hostname can make the
connection work correctly.

I also learned that a dynamically assigned container IP means this
manual mapping may need to be updated if the cluster is recreated.


8. curl Certificate Error

Error:

SSL certificate problem:
unable to get local issuer certificate

What happened:
curl did not trust the Kubernetes cluster's internal CA.

What I learned:
The CA used by a kind Kubernetes cluster is not necessarily trusted
by the normal operating-system CA store.

Using:

curl -k

is useful for testing connectivity, but it disables certificate
verification and should not be considered a proper TLS trust solution.

kubectl is different because the kubeconfig contains the Kubernetes
cluster CA information.


9. Understanding kubeconfig

What I learned:
kubectl does not simply discover the Kubernetes API server.

It uses kubeconfig to determine:

- Which cluster to connect to
- Which API server URL to use
- Which certificate authority to trust
- Which credentials to use

Changing the server address with:

kubectl config set-cluster

allowed kubectl to use the correct API-server hostname.


10. Understanding kind

What I learned:
kind means Kubernetes IN Docker.

The Kubernetes nodes are themselves Docker containers.

My cluster contains:

- 1 control-plane node
- 2 worker nodes

The control plane runs components such as:

- kube-apiserver
- kube-controller-manager
- kube-scheduler
- etcd

The worker nodes run workloads such as application pods.


11. Kubernetes Deployment

What I learned:
A Deployment manages application replicas.

Instead of manually creating individual pods, I defined:

replicas: 3

in the Deployment.

Kubernetes then created and maintained three nginx pods.


12. Kubernetes Service

What I learned:
Pods are ephemeral and their IP addresses can change.

A Kubernetes Service provides a stable network endpoint for a group
of pods selected using labels.

The nginx Service selected pods using:

app: nginx

This allowed traffic to be sent to the nginx replicas without
directly depending on individual pod IP addresses.


13. Kubernetes Scheduling

What I learned:
Kubernetes automatically decides which worker node should run each
pod.

Using:

kubectl get pods -o wide

allowed me to see which node each nginx pod was scheduled on.

The scheduler is responsible for placing workloads on available
nodes.


14. DevPod and Docker Networking

What I learned:
Running Kubernetes inside a DevPod container adds another networking
layer.

The environment can involve:

Mac
  ↓
Docker
  ↓
DevPod
  ↓
kind
  ↓
Kubernetes nodes

Because of these layers, localhost, Docker hostnames, published
ports, container IPs, and Kubernetes service addresses can all mean
different things depending on where a command is executed.


15. Importance of Troubleshooting Layer by Layer

The biggest lesson from this project was to troubleshoot the system
one layer at a time.

The useful troubleshooting sequence was:

1. Check whether the Docker container is running.
2. Check whether kube-apiserver is running.
3. Check whether port 6443 is listening.
4. Test connectivity directly to the API server.
5. Check Docker networking.
6. Check hostname resolution.
7. Check TLS certificate SANs.
8. Check kubeconfig.
9. Test kubectl.
10. Only then troubleshoot Kubernetes workloads.


16. Infrastructure as Code

What I learned:
The cluster should be defined through configuration rather than
manually created every time.

The kind-config.yaml file defines the cluster topology.

The Kubernetes YAML files define the application resources.

This makes the project reproducible and easier to understand.


17. Project Organization

I learned to separate the project into logical areas:

kind-config.yaml
    Cluster configuration

k8s/
    Kubernetes manifests

docs/
    Detailed documentation and troubleshooting notes

README.md
    Project overview and usage instructions

mise.toml
    Development tool versions

.gitignore
    Files that should not be committed


18. Git Repository Structure

I learned that the project itself does not need to be a separate
Git repository.

The Kubernetes project can remain a subdirectory of my main lab
repository.

This allows multiple CS/Kubernetes projects to exist under the same
Git repository while still keeping each project organized.


19. Most Important Lessons

The most important things I learned from this project are:

- Kubernetes networking can be different from normal host networking.
- localhost is relative to the environment where the command runs.
- kind runs Kubernetes nodes as Docker containers.
- Docker networking and Kubernetes networking are different layers.
- TLS certificates must contain the hostname used by the client.
- Certificate trust and network connectivity are separate problems.
- kubeconfig controls how kubectl communicates with the cluster.
- Deployments manage application replicas.
- Services provide stable access to pods.
- Kubernetes automatically schedules pods onto nodes.
- Configuration files make infrastructure reproducible.
- Troubleshooting should be performed layer by layer instead of
  changing multiple things at once.
- Errors encountered during a project are valuable documentation and
  should be recorded for future troubleshooting.
