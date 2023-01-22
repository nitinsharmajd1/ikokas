const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

exports.sendOTP = functions.https.onCall((data, context) => {
  return new Promise(function(resolve, reject) {
    const transporter = nodemailer.createTransport({
      host: "smtp.gmail.com",
      port: 465,
      secure: true,
      auth: {
        user: "nitinsharma.jd1@gmail.com",
        pass: "hwfwytjjrtomdeau",
      },
    });

    // setup email data
    const mailOptions = {
      from: "\"Nitin Sharma\" <nitinsharma.jd1@gmail.com>",
      to: data.email,
      subject: "Verify email using OTP from Flutter APP",
      text: "This is OTP to login in Application "+data.otp,
      html: "<p>OTP to login in App<h2><b><u>"+data.otp+"</b></u></h2></p>",
    };

    // send email
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        resolve( {status: "error"});
      } else {
        resolve( {status: "success"});
      }
    });
  });
});
