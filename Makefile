TERRAFORM_CMD := cd infra && terraform
RESOURCE?=

# infra/ssh/deployer:
/home/vagrant/.ssh/deployer:
	mkdir -p infra/ssh
	ssh-keygen -t rsa -b 4096 -C "deployer@taskpond.com" -f /home/vagrant/.ssh/deployer
	echo
	read -p "Now publish /home/vagrant/.ssh/deployer.pub to the hosting provider... then press enter to continue" bogus

dockerme:
	curl -o dockerme 'https://gist.githubusercontent.com/tinoadams/c300f7cd75c93c606f75f305329ad8e5/raw/2e13ee375e4b632fcfb9378a1aa180a9eb3ce5a4/dockerme'
	chmod +x dockerme

infra-show: dockerme
	$(TERRAFORM_CMD) show

infra-plan: dockerme
	$(TERRAFORM_CMD) plan

infra-apply: dockerme /home/vagrant/.ssh/deployer
	$(TERRAFORM_CMD) apply

infra-destroy: dockerme
	$(TERRAFORM_CMD) destroy -force $(RESOURCE)

infra-taint: dockerme
	$(TERRAFORM_CMD) taint $(RESOURCE)