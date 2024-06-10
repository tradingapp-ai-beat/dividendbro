const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const cors = require('cors')({ origin: true });

admin.initializeApp();

// Configure the email transporter with your SMTP settings
const transporter = nodemailer.createTransport({
  host: 'webdomain04.dnscpanel.com', // Replace with your SMTP host
  port: 465, // Replace with your SMTP port (usually 587 for TLS)
  secure: true, // Use true for port 465, false for other ports
  auth: {
    user: 'support@dividendbeat.com', // Replace with your domain email address
    pass: '!Yy2u3ae02' // Replace with your email password
  }
});

exports.sendPasswordResetEmail = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    console.log('Request received:', req.method, req.headers, req.body);

    if (req.method !== 'POST') {
      console.log('Invalid request method:', req.method);
      return res.status(405).send({ success: false, message: 'Method Not Allowed' });
    }

    const email = req.body.email;
    if (!email) {
      console.log('Email is missing from request body:', req.body);
      return res.status(400).send({ success: false, message: 'Email is required' });
    }

    try {
      const link = await admin.auth().generatePasswordResetLink(email);
      console.log('Password reset email link generated:', link);

      const mailOptions = {
        from: 'DividendBeat Support <support@dividendbeat.com>', // Replace with your domain email
        to: email,
        subject: 'Reset your password for DividendBeat',
        text: `Hello,

You recently requested to reset your password for your DividendBeat account. Click the link below to reset it.

${link}

If you did not request a password reset, please ignore this email or reply to let us know.

Thanks,

Your DividendBeat team`
      };

      await transporter.sendMail(mailOptions);
      console.log('Password reset email sent successfully to:', email);
      res.status(200).send({ success: true });
    } catch (error) {
      console.error('Error sending password reset email:', error);
      res.status(500).send({ success: false, message: error.message });
    }
  });
});
