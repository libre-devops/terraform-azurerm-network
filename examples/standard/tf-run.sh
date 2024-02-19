#!/usr/bin/env bash

#######################################################
# tf-run.sh Usage:
#
# By default, this script runs Terraform related checks.
#
# Options:
#   --append : Appends this script execution command to the user's .bashrc.
#######################################################

# Append script execution to .bashrc
append_to_bashrc() {
    echo "Appending script execution command to .bashrc"
    echo "" >> ~/.bashrc
    echo "# Execute tf-run.sh for Terraform tasks" >> ~/.bashrc
    echo "${PWD}/tf-run.sh" >> ~/.bashrc
}

# If --append flag is provided, add script execution to .bashrc and exit
if [[ $1 == "--append" ]]; then
    append_to_bashrc
    exit 0
fi

# Initial setup: Remove any residual files
rm -rf .terraform tfplan* terraform.lock.hcl

# Check if required packages are installed
for pkg in tfenv terraform terraform-compliance tfsec checkov; do
    if ! command -v $pkg &> /dev/null; then
        echo "$pkg is not installed. Exiting." && exit 1
    fi
done
echo "All packages are installed"

# Environment Variables
checkov_skipped_tests=""
terraform_compliance_policy_path="git:https://github.com/cyber-scot/utilities.git//terraform/helpers/terraform-compliance-tests?ref=main"
terraform_version="1.5.5"

# Setup Tfenv and Install terraform
setup_tfenv() {
    if [ -z "${terraform_version}" ]; then
        echo "terraform_version is empty or not set., setting to latest"
        export terraform_version="latest"
    else
        echo "terraform_version is set, installing terraform version ${terraform_version}"
    fi
    tfenv install ${terraform_version} && tfenv use ${terraform_version}
}

# Terraform Init, Validate & Plan
terraform_plan() {
    terraform init && \
    terraform validate && \
    terraform fmt -recursive && \
    terraform plan -out "$(pwd)/tfplan.plan"
    terraform show -json tfplan.plan | tee tfplan.json >/dev/null
}

# Terraform-Compliance Check
terraform_compliance_check() {
    terraform-compliance -p "$(pwd)/tfplan.json" -f ${terraform_compliance_policy_path}
}

# TFSec Check
tfsec_check() {
    tfsec . --force-all-dirs
}

# CheckOv Check
checkov_check() {
    checkov -f tfplan.json --skip-check "${checkov_skipped_tests}"
}

# Cleanup tfplan
cleanup_tfplan() {
    rm -rf "$(pwd)/tfplan.plan" "$(pwd)/tfplan.json"
}

# Call the functions in sequence
setup_tfenv && \
terraform_plan && \
terraform_compliance_check && \
tfsec_check && \
checkov_check && \
cleanup_tfplan
