/* Amplify Params - DO NOT EDIT
	ENV
	REGION
Amplify Params - DO NOT EDIT */const { RekognitionClient, DetectLabelsCommand, DetectFacesCommand } = require("@aws-sdk/client-rekognition");
const { S3Client } = require("@aws-sdk/client-s3");
const twilio = require('twilio');

const rekognitionClient = new RekognitionClient({ region: process.env.REGION });
const twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

const OUTDOOR_LABELS = [
  'Outdoors', 'Nature', 'Sky', 'Cloud', 'Tree', 'Building',
  'Street', 'Road', 'Grass', 'Plant', 'Flower', 'Garden',
  'Park', 'Sun', 'Sunlight', 'Daylight', 'Morning', 'Dawn',
  'Landscape', 'Mountain', 'Hill', 'Field', 'Lawn', 'Yard',
  'Sidewalk', 'Pavement', 'Path', 'Trail', 'Patio', 'Deck',
  'Forest', 'Woods', 'Foliage', 'Vegetation', 'Shrub', 'Bush',
  'Architecture', 'Urban', 'Suburban', 'City', 'Town', 'House'
];

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  try {
    const body = JSON.parse(event.body);
    const { photoKey, bucketName, contactPhone, userName, customMessage } = body;

    // Run Rekognition to detect labels
    const rekognitionParams = {
      Image: {
        S3Object: {
          Bucket: bucketName,
          Name: photoKey,
        },
      },
      MaxLabels: 30,
      MinConfidence: 60,
    };

    const rekognitionCommand = new DetectLabelsCommand(rekognitionParams);
    const rekognitionResponse = await rekognitionClient.send(rekognitionCommand);

    console.log('Rekognition labels:', JSON.stringify(rekognitionResponse.Labels));

    // Multi-factor outdoor detection: require at least 2 outdoor labels with >60% confidence
    const outdoorMatches = rekognitionResponse.Labels.filter(label =>
      OUTDOOR_LABELS.includes(label.Name) && label.Confidence > 60
    );

    const isOutdoor = outdoorMatches.length >= 2;

    console.log(`Found ${outdoorMatches.length} outdoor labels:`, outdoorMatches.map(l => `${l.Name} (${l.Confidence.toFixed(1)}%)`));

    // Run face detection to verify it's a selfie
    const faceParams = {
      Image: {
        S3Object: {
          Bucket: bucketName,
          Name: photoKey,
        },
      },
    };

    const faceCommand = new DetectFacesCommand(faceParams);
    const faceResponse = await rekognitionClient.send(faceCommand);

    const hasFace = faceResponse.FaceDetails && faceResponse.FaceDetails.length > 0;
    console.log(`Face detection: ${hasFace ? 'Face found' : 'No face detected'} (${faceResponse.FaceDetails?.length || 0} faces)`);

    // Require both outdoor setting AND a face to be detected
    if (isOutdoor && hasFace) {
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
        // Use custom message if provided, otherwise use default
        const defaultMessage = `${userName || 'Your friend'} missed their Ventus alarm this morning! Time to check in on them 😴`;
        const messageBody = customMessage
          ? customMessage.replace('{username}', userName || 'Your friend')
          : defaultMessage;

        await twilioClient.messages.create({
          body: messageBody,
          from: process.env.TWILIO_PHONE_NUMBER,
          to: contactPhone,
        });
        console.log('Accountability SMS sent to:', contactPhone);
      }

      // Provide specific feedback
      let failureMessage = 'Photo verification failed. ';
      if (!isOutdoor) {
        failureMessage += 'Photo does not appear to be taken outdoors. ';
      }
      if (!hasFace) {
        failureMessage += 'No face detected - make sure you are visible in the selfie.';
      }

      return {
        statusCode: 200,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers": "*"
        },
        body: JSON.stringify({
          success: false,
          message: failureMessage.trim(),
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
