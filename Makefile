TERRAFORM_CMD := docker run -i -t -e SCALEWAY_TOKEN="$(SCALEWAY_TOKEN)" -e SCALEWAY_ORGANIZATION="$(SCALEWAY_ORGANIZATION)" -v $(PWD)/infra:$(PWD)/infra -w $(PWD)/infra hashicorp/terraform:0.9.4
RESOURCE?=""

# infra/ssh/deployer:
/home/vagrant/.ssh/deployer:
	mkdir -p infra/ssh
	ssh-keygen -t rsa -b 4096 -C "deployer@taskpond.com" -f /home/vagrant/.ssh/deployer
	echo
	read -p "Now publish /home/vagrant/.ssh/deployer.pub to the hosting provider... then press enter to continue" bogus

infra-show:
	$(TERRAFORM_CMD) show

infra-plan:
	$(TERRAFORM_CMD) plan

infra-apply: /home/vagrant/.ssh/deployer
	$(TERRAFORM_CMD) apply

infra-destroy:
	$(TERRAFORM_CMD) destroy -force $(RESOURCE)

infra-taint:
	$(TERRAFORM_CMD) taint $(RESOURCE)