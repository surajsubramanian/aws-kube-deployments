* [cli](https://docs.aws.amazon.com/cli/latest/reference/batch/submit-job.html#examples)
```bash
batch % aws batch submit-job --job-name example2 --job-queue job-queue  --job-definition this-job-definition2
{
    "jobArn": "arn:aws:batch:us-east-1:account:job/jobId",
    "jobName": "example2",
    "jobId": "jobId"
}
```
* [boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/batch.html#Batch.Client.submit_job)
```python3
import boto3
client = boto3.client('batch')


response = client.submit_job(
    jobName='example-boto',
    jobQueue='job-queue',
    jobDefinition='this-job-definition'
)
print(response)
```
