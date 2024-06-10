import 'package:flutter/material.dart';

class DisclaimerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disclaimer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Disclaimer',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'DividendBeat, including its directors, employees, and agents, cannot be held responsible for the financial performance of your portfolio. We are not liable for any losses, claims, costs, or expenses resulting from our advisory services, or for any damages caused by market volatility.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'DividendBeat and its related entities, directors, or employees do not provide any guarantees, make representations, or assume liability for the accuracy, reliability, timeliness, or completeness of the information presented now or in the future. While we strive to provide accurate information, DividendBeat does not take responsibility for any inaccuracies or actions taken based on the information available on this app.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'DividendBeat reserves the right to amend and update the content on this site without prior notification.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'All tips and advice are based on our research, judgments, and the information available at the time. However, directors, employees, or technicians of the site are not accountable for any financial losses or gains resulting from the provided advice. Members should exercise caution and use the tips at their own risk. We are also not responsible for any network or internet connectivity issues.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'All views and recommendations are valid only until the specified stop loss level is breached. Once the stop loss is triggered, the recommendations should be considered void.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'DividendBeat does not guarantee returns in any of its services. Investors should be cautious of any claims promising guaranteed returns.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'By using and accessing the information on this site, you agree to this disclaimer. All Rights Reserved.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'This agreement is subject to the jurisdiction of Portugal.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'This information does not represent investment advice, recommendation, or inducement to buy or sell financial instruments.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
