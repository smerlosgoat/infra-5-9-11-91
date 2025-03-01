.PHONY: init validate format lint refresh plan apply destroy clean output

init:
	terraform init
	tflint --init

validate: lint format
	terraform validate

format:
	terraform fmt --recursive

lint:
	tflint --recursive 

refresh:
	terraform refresh

plan: validate refresh
	terraform plan --out plan.out

apply:
	terraform apply plan.out

destroy: refresh
	if [ "$$TF_DESTROY" = "true" ]; then \
		terraform destroy -auto-approve; \
	else \
		terraform destroy; \
	fi

clean:
	rm -rf .terraform terraform.tfstate terraform.tfstate.backup plan.out

output:
	terraform output --raw inventory_ansible | yq | tee ../ansible/inventory.yaml
	terraform output --raw inventory_fury | yq | tee ../fury/inventory.yaml