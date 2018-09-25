FROM ruby
RUN apt-get -y update && apt-get -y install libicu-dev cmake cron && rm -rf /var/lib/apt/lists/*
RUN gem install github-linguist
RUN gem install gollum
RUN gem install org-ruby  # optional

# we have a known public key for github. tell our hosts about it.
RUN mkdir -p /root/.ssh
COPY github_rsa.pub .
RUN cat github_rsa.pub >> /root/.ssh/known_hosts

# scripts for initializing and syncing Gollum's backing store
COPY scripts/git-init.sh /bin
COPY scripts/git-sync.sh /bin

# install commit hooks into Gollum so that changes are pushed up immediately.
RUN mkdir -p /var/share/gollum
COPY scripts/config.rb /var/share/gollum
COPY scripts/post-commit /var/share/gollum
RUN chmod +x /var/share/gollum/post-commit

# crontab to sync (push/pull) every minute.
# INIT SCRIPT MUST START CRON.
COPY scripts/crontab /var/share/gollum
RUN touch /var/log/cron.log

# WD should be the mountpoint for the git volume
WORKDIR /wiki-data
ENTRYPOINT ["gollum", "--port", "80", "--config", "/var/share/gollum/config.rb"]
EXPOSE 80