import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
const s3 = new S3Client();

export const handler = async (event) => {
  const bucketName = process.env.BUCKET_NAME;
  const prefix = process.env.PREFIX || "kinesis-records/"; // Default prefix if not set

  console.log("Received Kinesis records:", JSON.stringify(event, null, 2));

  // Check if Records key exists and is an array
  const records = event.Records;
  if (!Array.isArray(records)) {
    console.error("Event does not contain records");
    return {
      statusCode: 500,
      body: "Event does not contain records",
    };
  }

  // Process each record
  for (const record of records) {
    const payload = Buffer.from(record.kinesis.data, "base64").toString(
      "utf-8"
    );
    console.log("Record payload:", payload);

    const sequenceNumber = record.kinesis.sequenceNumber;

    const s3Params = {
      Bucket: bucketName,
      Key: `$${prefix}$${sequenceNumber}.json`,
      Body: payload,
      ContentType: "application/json",
    };

    try {
      const command = new PutObjectCommand(s3Params);
      await s3.send(command);
      console.log(`Successfully written record to S3: $${s3Params.Key}`);
    } catch (err) {
      console.error(`Failed to write record to S3: $${err}`);
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Processed Kinesis records successfully",
    }),
  };
};
