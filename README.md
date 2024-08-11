# tf-aws-kinesis-lambda

## build

### zip nodejs app

```bash
terraform apply --auto-approve --target=data.archive_file.consumer_js
```

```bash
terraform apply --auto-approve --target=data.archive_file.processor_mjs
```

```bash
terraform apply --auto-approve
```

### send test event

```bash
aws kinesis put-record \
    --stream-name kinesis-lambda-kh70nyu5 \
    --partition-key $(uuidgen) \
    --data $(echo -n '{"sensorId": 42, "currentTemperature": 85, "status": "OK"}' | base64 | tr -d '\n')
```

## cleanup

### workaround for cloudformation not able to handle deleting a non-empty s3 bucket, replace bucket name

```bash
aws s3 rm s3://kinesis-lambda-ap5rt24p-cognito-se-stagings3bucket-dosjzztakwnt --recursive
```

```bash
terraform destroy --auto-approve
```

### workaround for cloudformation not handling cognito user pool deletion

get the user pool id

```bash
aws cognito-idp list-user-pools --max-results 10 --query "UserPools[?Name=='Kinesis Data-Generator Users'].Id" --output text
```

delete using the user pool id

```bash
aws cognito-idp delete-user-pool --user-pool-id <REPLACE-WITH-USER-POOL-ID>
```

get the identity pool id

```bash
aws cognito-identity list-identity-pools --max-results 10
```

delete using the identity pool id

```bash
aws cognito-identity delete-identity-pool --identity-pool-id <REPLACE-WITH-IDENTITY-POOL-ID>
```

### workaround for cloudformation not handling cloudwatch log group deletion

```bash
aws logs delete-log-group --log-group-name /aws/lambda/KinesisDataGeneratorCognitoSetup
aws logs delete-log-group --log-group-name /aws/lambda/bootstrapStagingLambdaSetup
```

## reference

<https://github.com/aws-samples/serverless-patterns/blob/main/kinesis-lambda-terraform/README.md>
