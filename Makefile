################################################################################
# DEPLOYMENT
## Target hostname
REMOTE=www.johannesgontrum.com

NAME=portfolio

## Path on the remote machine to copy the site to
REMOTE_PATH=~/www/$(NAME)

## SHH config for this server
SSH_KEY=~/.ssh/id_rsa
SSH_USER=root

################################################################################
# COMMANDS
SSH=ssh -i $(SSH_KEY) -oStrictHostKeyChecking=no $(SSH_USER)@$(REMOTE)
SCP=scp -i $(SSH_KEY) -oStrictHostKeyChecking=no

# Leave this empty, if you do not use '$(SUDO)'
SUDO=sudo
################################################################################

all: clean remote_upload remote_site_stop remote_site_start
	@echo "[$(NAME)] Deployment complete."

remote_upload:
	@echo "[$(NAME)] Uploading to the remote machine..."
	@$(SSH) 'rm -rf $(REMOTE_PATH)'
	@$(SSH) 'mkdir -p $(REMOTE_PATH)'
	@$(SCP) -r . $(SSH_USER)@$(REMOTE):$(REMOTE_PATH)/
	@$(SSH) 'cd $(REMOTE_PATH) && rm Makefile'
	@$(SSH) 'cd $(REMOTE_PATH) && docker build -t jgontrum/$(NAME) .'

remote_site_start:
	@echo "[$(NAME)] Starting in a Docker container..."
	@$(SSH) 'docker run --name $(NAME) -d -p 127.0.0.1:8091:80 jgontrum/$(NAME)'
	@echo "[$(NAME)] The webiste is running now."

# Stop the site
remote_site_stop:
	@$(SSH) 'docker stop $(NAME) > /dev/null; docker rm $(NAME) > /dev/null 2>/dev/null; true' 2> /dev/null
	@echo "[$(NAME)] Stopped."

clean:
	@find . -name "*.swp" -exec rm {} \;
	@find . -name ".DS_Store" -exec rm {} \;

remote_site_restart: remote_site_stop remote_site_start
