define RUNNING_USER
$(shell whoami)
endef

TERRAFORM_FLAGS  	?= -var namespace="$(NAMESPACE)" -var created_by="$(RUNNING_USER)"
PLAN_FILE         	?= yurtah-$(NAMESPACE)-tf.plan

plan: ## run terraform plan with given parameters
	terraform init 	-backend-config="bucket=yurtah-$(NAMESPACE)-tf-state-bucket" \
					-backend-config="key=$(NAMESPACE)-terraform-state" \
					-backend-config="region=us-east-1" \
					-backend-config="encrypt=true"
	terraform plan $(TERRAFORM_FLAGS) -out $(PLAN_FILE)

deploy: $(PLAN_FILE)
	terraform apply $(PLAN_FILE)

clean:
	rm -rf .terraform
	rm -rf .terraform*
	rm -rf terraform*
	rm -rf *.plan
