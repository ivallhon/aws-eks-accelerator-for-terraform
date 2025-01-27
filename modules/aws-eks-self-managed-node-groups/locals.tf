locals {

  default_self_managed_ng = {
    node_group_name = "m4_on_demand"
    instance_type   = "m4.large"
    custom_ami_id   = "" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
    capacity_type   = "" # Optional Use this only for SPOT capacity e.g., capacity_type = "spot"
    subnet_ids      = []

    desired_size    = "2"
    max_size        = "3"
    min_size        = "1"
    max_unavailable = "1"
    disk_size       = 50
    disk_type       = "gp2"

    enable_monitoring = true
    eni_delete        = true
    public_ip         = false

    create_worker_security_group = false

    k8s_labels      = {}
    k8s_taints      = []
    additional_tags = {}

    # LAUNCH TEMPLATES
    create_launch_template  = false
    launch_template_os      = "amazonlinux2eks" # amazonlinux2eks/bottlerocket/windows # Used to identify the launch template
    launch_template_id      = null
    launch_template_version = "$Latest"
    pre_userdata            = ""
    post_userdata           = ""
    kubelet_extra_args      = ""
    bootstrap_extra_args    = ""

    # SSH ACCESS
    remote_access         = false
    ec2_ssh_key           = ""
    ssh_security_group_id = ""
  }

  self_managed_node_group = merge(
    local.default_self_managed_ng,
    var.self_managed_ng
  )

  enable_windows_support = local.self_managed_node_group["launch_template_os"] == "windows"

  predefined_ami_names = {
    amazonlinux2eks = "amazon-eks-node-${var.kubernetes_version}-*"
    bottlerocket    = "bottlerocket-aws-k8s-${var.kubernetes_version}-x86_64-*"
    windows         = "Windows_Server-2019-English-Core-EKS_Optimized-${var.kubernetes_version}-*"
  }
  predefined_ami_types  = keys(local.predefined_ami_names)
  default_custom_ami_id = contains(local.predefined_ami_types, local.self_managed_node_group["launch_template_os"]) ? data.aws_ami.predefined[local.self_managed_node_group["launch_template_os"]].id : ""
  custom_ami_id         = local.self_managed_node_group["custom_ami_id"] == "" ? local.default_custom_ami_id : local.self_managed_node_group["custom_ami_id"]

  userdata_params = {
    eks_cluster_id       = var.eks_cluster_id
    cluster_ca_base64    = var.cluster_ca_base64
    cluster_endpoint     = var.cluster_endpoint
    bootstrap_extra_args = local.self_managed_node_group["bootstrap_extra_args"]
    pre_userdata         = local.self_managed_node_group["pre_userdata"]
    post_userdata        = local.self_managed_node_group["post_userdata"]
    kubelet_extra_args   = local.self_managed_node_group["kubelet_extra_args"]
  }

  userdata_base64 = {
    for launch_template_os in local.predefined_ami_types : launch_template_os => base64encode(
      templatefile(
        "${path.module}/templates/userdata-${launch_template_os}.tpl",
        local.userdata_params
      )
    )
  }

  custom_userdata_base64 = contains(local.predefined_ami_types, local.self_managed_node_group["launch_template_os"]) ? local.userdata_base64[local.self_managed_node_group["launch_template_os"]] : null

  policy_arn_prefix = "arn:aws:iam::aws:policy"
  ec2_principal     = "ec2.${data.aws_partition.current.dns_suffix}"

  common_tags = merge(
    var.tags,
    {
      Name                                              = "${var.eks_cluster_id}-${local.self_managed_node_group["node_group_name"]}"
      "k8s.io/cluster-autoscaler/${var.eks_cluster_id}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"               = "TRUE"
      "kubernetes.io/cluster/${var.eks_cluster_id}"     = "owned"
  })

}
