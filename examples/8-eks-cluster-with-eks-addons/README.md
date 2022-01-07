# EKS Cluster with EKS Managed Add-ons

This example deploys a new EKS Cluster into a new VPC with EKS managed Add-ons

 - Creates a new VPC, 3 Private Subnets and 3 Public Subnets
 - Creates an Internet gateway for the Public Subnets and a NAT Gateway for the Private Subnets
 - Creates an EKS Cluster Control plane with public endpoint with one managed node group
 - Creates EKS managed Addons (`vpc-cni`, `coredns`, `kube-proxy`, `aws-ebs-csi-driver`)

## How to Deploy

### Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
3. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

#### Step2: Run Terraform INIT
to initialize a working directory with configuration files

```shell script
cd examples/8-eks-cluster-with-eks-addons/
terraform init
```

#### Step3: Run Terraform PLAN
to verify the resources created by this execution

```shell script
export AWS_REGION="eu-west-1"   # Select your own region
terraform plan
```

#### Step4: Finally, Terraform APPLY
to create resources

```shell script
terraform apply
```

Enter `yes` to apply

### Configure kubectl and test cluster
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step5: Run update-kubeconfig command.

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region eu-west-1 update-kubeconfig --name <cluster-name>

#### Step6: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step7: List all the pods running in kube-system namespace

    $ kubectl get pods -n kube-system

## How to Destroy
```shell script
cd examples/8-eks-cluster-with-eks-addons
terraform destroy
```

<!--- BEGIN_TF_DOCS --->

<!--- END_TF_DOCS --->