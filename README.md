# gollum-k8s

Recipe and configuration for a Gollum wiki on Kubernetes, with replication and a load balancer.

This implementation uses a stateful set to maintain the backing repository state throughout pod lifecycles. This provides stable storage to the pods and prevents unnecessary new checkouts.

Scripts git-init.sh and git-sync.sh keep all replicas up to date. Changes are pushed up to the Github backing store as soon as they are made, and will be fetched within 1 minute by a cronjob on each replica.

### To deploy

0. Create a namespace for Gollum to use. This is not strictly necessary but is a best practice. If you choose not to do this, leave `--namespace gollum` off of your future calls to kubectl.

`kubectl create -f namespaces/gollum-namespace.yml`

1. Create your backing repository -- we recommend Github. If you don't need this repository to be private, skip to step 5 or 6, but we do recommend it. Edit deployments/gollum.yml and replace YOUR_BACKING_REPO_HERE with the SSH url to clone this repo.

2. Create a new Github user for the Gollum replicas and grant it read+write access to the repository you've made.

3. Create a directory called secrets, which is protected by this repo's .gitignore. Enter this directory and generate a new SSH keypair to be used by the Gollum replicas for checkout. 

`ssh-keygen`

Enter a unique filename (gollum_id_rsa) when prompted.

Log in as the new Gollum user you created on Github. Go to this user's SSH keys and add a new key. Copy the contents of the public key you've generated here. (ex. gollum_id_rsa.pub).

4. Set up a Kubernetes secret to store these keys on the cluster. Copy secrets.example/gollum-git-secret.yml to the secrets directory, and edit the copy as follows:

    * Replace B64_ENCODED_PRIVATE_KEY_FOR_GIT_USER with the output of `cat gollum_id_rsa | base64`.

    * Replace B64_ENCODED_PUBLIC_KEY_FOR_GIT_USER with the output of `cat gollum_id_rsa.pub | base64`.

Do NOT check this file into the repository -- the .gitignore should help protect you.

DO install this secret into your Kubernetes cluster:

`kubectl --namespace gollum create -f gollum-git-secret.yml`

5. OPTIONAL -- if you want to use a custom Docker image, now's the time. Create your remote Docker repo and replace the value of the Gollum container image in `deployments/gollum.yml`. Don't forget to create your image pull secret and add it to the deployment -- if you got this far we will assume you know how to do that.

6. Create the actual replicaset. Sanity check before doing this to make sure you have a valid container image, have set the environment variable GOLLUM_GIT_REPO to the repository you created in step 1, and you've set your image pull secret if needed. Then:

`kubectl --namespace gollum create -f deployments/gollum.yml`

At this point you should monitor the cluster until all pods are created and ready.

`kubectl --namespace gollum get pods`

7. Create the load balancer. If you want to restrict access to your wiki to a whitelist of IPs, you can uncomment the loadBalancerSourceRanges block and set it to one or more CIDR blocks that make sense for you.

`kubectl --namespace gollum create -f services/gollum-svc.yml`

That's it! You should be done. Monitor the load balancer until it's ready, create any CNAME you wanted for your brand new wiki, then head on over and start documenting.



