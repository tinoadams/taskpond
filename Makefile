infra/ssh/deployer:
	mkdir -p infra/ssh
	ssh-keygen -t rsa -b 4096 -C "deployer@taskpond.com" -f infra/ssh/deployer
	echo
	read -p "Now publish infra/ssh/deployer.pub to the hosting provider... then press enter to continue" bogus

infra-plan:
	docker run -i -t -v $(PWD)/infra:$(PWD)/infra -w $(PWD)/infra hashicorp/terraform:0.9.4 plan

infra-apply: infra/ssh/deployer
	docker run -i -t -v $(PWD)/infra:$(PWD)/infra -w $(PWD)/infra hashicorp/terraform:0.9.4 apply

infra-destroy:
	docker run -i -t -v $(PWD)/infra:$(PWD)/infra -w $(PWD)/infra hashicorp/terraform:0.9.4 destroy -force