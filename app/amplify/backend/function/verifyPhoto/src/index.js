/* Amplify Params - DO NOT EDIT
	ENV
	REGION
Amplify Params - DO NOT EDIT */const { RekognitionClient, DetectLabelsCommand } = require("@aws-sdk/client-rekognition");
const { S3Client } = require("@aws-sdk/client-s3");
const twilio = require('twilio');

const rekognitionClient = new RekognitionClient({ region: process.env.REGION });
const twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

const OUTDOOR_LABELS = [
  'Outdoors', 'Nature', 'Sky', 'Cloud', 'Tree', 'Building',
  'Street', 'Road', 'Grass', 'Plant', 'Flower', 'Garden'
];

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  try {
    const body = JSON.parse(event.body);
    const { photoKey, bucketName, contactPhone, userName } = body;

    // Run Rekognition to detect labels
    const rekognitionParams = {
      Image: {
        S3Object: {
          Bucket: bucketName,
          Name: photoKey,
        },
      },
      MaxLabels: 20,
      MinConfidence: 70,
    };

    const rekognitionCommand = new DetectLabelsCommand(rekognitionParams);
    const rekognitionResponse = await rekognitionClient.send(rekognitionCommand);

    console.log('Rekognition labels:', JSON.stringify(rekognitionResponse.Labels));

    // Check if any outdoor labels are detected
    const isOutdoor = rekognitionResponse.Labels.some(label =>
      OUTDOOR_LABELS.includes(label.Name) && label.Confidence > 70
    );

    if (isOutdoor) {
      return {
        statusCode: 200,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers": "*"
        },
        body: JSON.stringify({
          success: true,
          message: 'Outdoor photo verified successfully!',
          isOutdoor: true,
        }),
      };
    } else {
      // Send accountability SMS
      if (contactPhone) {
        await twilioClient.messages.create({
          body: `${userName || 'Your friend'} didn't wake up on time this morning! They missed their Ventus alarm. 😴`,
          from: process.env.TWILIO_PHONE_NUMBER,
          to: contactPhone,
        });
        console.log('Accountability SMS sent to:', contactPhone);
      }

      return {
        statusCode: 200,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers": "*"
        },
        body: JSON.stringify({
          success: false,
          message: 'Photo does not appear to be taken outdoors',
          isOutdoor: false,
        }),
      };
    }
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "*"
      },
      body: JSON.stringify({
        success: false,
        error: error.message,
      }),
    };
  }
};
