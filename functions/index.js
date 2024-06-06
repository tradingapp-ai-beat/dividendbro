const functions = require('firebase-functions');
const admin = require('firebase-admin');
const mailgun = require('mailgun-js');

admin.initializeApp();

const DOMAIN = 'https://app.mailgun.com/app/sending/domains/sandboxad07bfc167654ef1a0fe613c7d82272a.mailgun.org'; // Replace with your Mailgun domain
const mg = mailgun({ apiKey: 'db3c093db8f7d101b4f920933432f65e-a4da91cf-111e108f', domain: DOMAIN }); // Replace with your Mailgun API key

exports.sendPasswordResetEmail = functions.https.onCall(async (data, context) => {
  // Check if the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'The function must be called while authenticated.'
    );
  }

  const email = data.email;
  const mailData = {
    from: 'support@dividendbeat.com', // Replace with your email/domain
    to: email,
    subject: 'Password Reset',
    text: 'Click the link below to reset your password.',
    html: '<strong>Click the link below to reset your password.</strong>',
  };

  try {
    await mg.messages().send(mailData);
    console.log(`Password reset email sent to ${email}`);
    return { success: true };
  } catch (error) {
    console.error(`Failed to send password reset email: ${error.message}`, error);
    throw new functions.https.HttpsError('internal', 'Failed to send password reset email');
  }
});




