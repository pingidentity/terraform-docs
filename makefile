default: devcheck

fmt:
	@echo "==> Formatting Terraform code with terraform fmt..."
	@terraform fmt -recursive ./examples

fmt-check:
	@echo "==> Checking Terraform code with terraform fmt..."
	@terraform fmt -recursive -check ./examples

validate:
	@echo "==> Checking Terraform code with terraform validate..."
	@for dir in $$(find ./examples -maxdepth 0); do \
		echo $${dir} ; \
		[ -d "$${dir}/" ] && terraform -chdir=$${dir}/ validate . ; \
    done

tflint:
	@echo "==> Checking Terraform code with tflint..."
	@tflint --recursive

tfsec:
	@echo "==> Checking Terraform code with tfsec..."
	@tfsec ./examples

devcheck: fmt fmt-check validate tflint tfsec

.PHONY: devcheck fmt fmt-check validate tflint tfsec