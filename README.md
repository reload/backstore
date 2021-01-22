# Backstore

Simple container for storing BackstopJS reports, primarily for linking
to from Actions.

## Usage

Backstore is just a simple HTTP server with SSH and rsync. To store a
new report:

Run the service somewhere, mounting in `/srv`. After startup the
identity file needed to push reports is in `.ssh/id_rsa`, use GitHub
Actions secrets to supply this to actions.

### Submitting new report

Generate a sha using `echo $GITHUB_REPOSITORY:$GITHUB_SHA | sha1sum - | cut -d" " -f 1`

Then sync the report:

`rsync -e 'ssh -i <identity file> -p 1984 -o StrictHostKeyChecking=no'
-r report/ store@<hostname>:backstore/<the sha>/`

It will then be available at `http://<hostname>/<the sha>/` (or https
equivalent, if you have a appropriate proxy).
