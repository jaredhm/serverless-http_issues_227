# Serverless Nextjs Webapp Demo

### Usage

#### Setup
First, we'll need a few tools
1. Install `volta` (see [here](https://docs.volta.sh/guide/getting-started))
2. Install `tfenv` (see [here](https://github.com/tfutils/tfenv#installation))
3. Install `aws` cli (see [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions))
4. Install `jq` (see [here](https://jqlang.github.io/jq/download/))

### Building and deploying the application
Clone the repo:
```
git clone https://github.com/jaredhm/serverless-http_issues_227.git
```
Install deps:
```
npm i
```
If you're using short-term access keys, make sure to export them:
```
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID="ASIAEXAMPLEEXAMPLE"
export AWS_SECRET_ACCESS_KEY="EXAMPLEEXAMPLEEXAMPLEEXAMPLEEXAMPLE"
export AWS_SESSION_TOKEN="AAAAA3AAA2AAA2AAAAA//////////AAAAAAAAAAAA3AAAAAAAAAAAAAAAA67A5AAA2AAAAAAAAAAAAA5AA0A4AAA8AAAAAA6AAAAAAAAAAA84AAAAAAAAAAAAAAA4AA3AAAAA7AAA8A1AAA5AA0AAAAAAAAAAAA1AAAAAAAAAAA5AAAAAA0AAA14AAAA6AAA6AA9A2A/AAAAAAAAAAAAAAAAA+AAAA3AAAAAA3A2AAAAAAAAAAAAA8AAAAAAAAA2AAAAAAAAAAA38AAAAAAAAAAA84A9A9AA4AAAAAA2AA4A/AAAA0AAAAAAAAA0AA2AAAA8AAA0AAAAA82AAAAA1AAAAAAAAA/AAAA7AAA6AA2AAAAAAAAAAAAAA/AA9AAAAAAA6A3AAA92AA71AAA9+5AA80AAAAAAAA6AA0A6AAAAAAAAAAAAAAA+AAAAAAAAA0AAAA6AAAAAAA5AAAA13A8AAAA0AA0AA/AA/A3AAAAAAAA6AA9AAAAAAA7AA4AAAAAAAAAAAAAA16A/AAAA+A7AAAAAA8AAAAA/AAAAAAA/AAAAAA3AAAAAAAA7AA2A6AAAA/AAAAA8AAAAAAAAAAAAA5AA0AA2AAAAAAAA5A27AAA52A7AAAA2AA0AA6AAA7AAAAAAAA1AAAAAAA3AAA06AAAAA8AAAA+8AAAA8AAAAAAAAAAAAA4AAA49AAAAAA+7AAAAAA2AAA1AAAA3A64AA3AAAAAAAAAAAA2AAA3AAAA/AA8AAAAA+AAAAAAAA6AAAAAA9AAAAAAAA9AAAA8AA4AAAAAAAAAAAA49AAAA4A/A/2AAAAA7AAAAAA8AAAAAAAAAA5AAAAAAAAAAAAA1AA0AAAA0+AAA9AAAAAAAAAAA9AAAAA43AAAAA354AAAAAAAA2A8A9A=="
```
Otherwise, if you're using `aws-vault`, make sure to first run
```
aws-vault exec <profile-name>
```
Finally, if I've done my work reasonably well, you should just be able to run the following from the repository root:
```
./deploy
```

#### Cleanup

Simply run the following to clean up all resources:
```
pushd infra/env/prod && terraform destroy && popd infra/env/prod
```


