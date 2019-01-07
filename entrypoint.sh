#!/bin/ash -e
# For SSH see:
# - https://docs.gitlab.com/ee/ci/ssh_keys/
# - https://gitlab.com/gitlab-examples/ssh-private-key/blob/master/.gitlab-ci.yml

if [[ ! -z "${SSH_PRIVATE_KEY}" ]]; then
    ##
    ## Run ssh-agent (inside the build environment)
    ##
    eval $(ssh-agent -s) > /dev/null

    ##
    ## Add the SSH key stored in SSH_PRIVATE_KEY variable to the agent store
    ## We're using tr to fix line endings which makes ed25519 keys work
    ## without extra base64 encoding.
    ## https://gitlab.com/gitlab-examples/ssh-private-key/issues/1#note_48526556
    ##
    echo "$SSH_PRIVATE_KEY" | ssh-add - > /dev/null 2>&1

    ##
    ## Create the SSH directory and give it the right permissions
    ##
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    ##
    ## Use ssh-keyscan to scan the keys of your private server. Replace gitlab.com
    ## with your own domain name. You can copy and repeat that command if you have
    ## more than one server to connect to.
    ##
    # ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
    # chmod 644 ~/.ssh/known_hosts

    ##
    ## Alternatively, assuming you created the SSH_SERVER_HOSTKEYS variable
    ## previously, uncomment the following two lines instead.
    ##
    #- echo "$SSH_SERVER_HOSTKEYS" > ~/.ssh/known_hosts'
    #- chmod 644 ~/.ssh/known_hosts

    ##
    ## You can optionally disable host key checking. Be aware that by adding that
    ## you are suspectible to man-in-the-middle attacks.
    ## WARNING: Use this only with the Docker executor, if you use it with shell
    ## you will overwrite your user's SSH config.
    ##
    # [[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
    echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

fi

case $1 in
    playbook)
        shift
        ansible-playbook "$@"
        ;;
    shell)
        /bin/ash
        ;;
    *)
        ansible "$@"
        ;;
esac
